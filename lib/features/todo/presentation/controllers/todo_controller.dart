import 'dart:collection';

import 'package:flutter/foundation.dart' hide Category;

import '../../domain/entities/category.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/sort_criterion.dart';
import '../../domain/entities/sort_direction.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/use_cases/complete_task_use_case.dart';
import '../../domain/use_cases/create_category_use_case.dart';
import '../../domain/use_cases/create_task_use_case.dart';
import '../../domain/use_cases/delete_category_use_case.dart';
import '../../domain/use_cases/delete_task_use_case.dart';
import '../../domain/use_cases/edit_task_use_case.dart';
import '../../domain/use_cases/get_all_categories_use_case.dart';
import '../../domain/use_cases/get_all_tasks_use_case.dart';
import '../../domain/use_cases/rename_category_use_case.dart';
import '../../domain/use_cases/reopen_task_use_case.dart';

/// Manages all todo state: tasks, categories, search, filters, and sort.
///
/// Loads data through use cases and exposes a display-ready task list
/// computed by the internal search → filter → sort pipeline.
class TodoController extends ChangeNotifier {
  /// Creates a [TodoController] with the required use cases injected.
  TodoController({
    required this._getAllTasksUseCase,
    required this._getAllCategoriesUseCase,
    required this._createTaskUseCase,
    required this._editTaskUseCase,
    required this._deleteTaskUseCase,
    required this._completeTaskUseCase,
    required this._reopenTaskUseCase,
    required this._createCategoryUseCase,
    required this._renameCategoryUseCase,
    required this._deleteCategoryUseCase,
  });

  // --- Use cases ---

  final GetAllTasksUseCase _getAllTasksUseCase;
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final EditTaskUseCase _editTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  final ReopenTaskUseCase _reopenTaskUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final RenameCategoryUseCase _renameCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  // --- Raw data (from repository) ---

  List<Task> _allTasks = [];
  List<Category> _allCategories = [];

  // --- Search / Filter / Sort inputs ---

  String _searchQuery = '';
  TaskStatus? _statusFilter;
  Priority? _priorityFilter;
  int? _categoryFilter;
  SortCriterion _sortCriterion = SortCriterion.creationDate;
  SortDirection _sortDirection = SortDirection.descending;

  // --- Derived (computed by _applyPipeline) ---

  List<Task> _displayedTasks = [];

  // --- Feedback ---

  bool _isLoading = false;
  String? _errorMessage;

  // --- Public getters ---

  /// All available tasks
  UnmodifiableListView<Task> get allTasks => UnmodifiableListView(_allTasks);

  /// The filtered, sorted list of tasks ready for display.
  UnmodifiableListView<Task> get displayedTasks =>
      UnmodifiableListView(_displayedTasks);

  /// All available categories.
  UnmodifiableListView<Category> get categories =>
      UnmodifiableListView(_allCategories);

  /// The current search query string.
  String get searchQuery => _searchQuery;

  /// Active status filter, or `null` for "All".
  TaskStatus? get statusFilter => _statusFilter;

  /// Active priority filter, or `null` for "All".
  Priority? get priorityFilter => _priorityFilter;

  /// Active category filter: `null` = All, `-1` = Uncategorized.
  int? get categoryFilter => _categoryFilter;

  /// The criterion used to sort displayed tasks.
  SortCriterion get sortCriterion => _sortCriterion;

  /// The direction of the sort (ascending or descending).
  SortDirection get sortDirection => _sortDirection;

  /// Whether data is currently being loaded.
  bool get isLoading => _isLoading;

  /// A user-friendly error message, or `null` if no error.
  String? get errorMessage => _errorMessage;

  /// `true` when any filter (status, priority, or category) is active.
  bool get hasActiveFilters =>
      _statusFilter != null ||
      _priorityFilter != null ||
      _categoryFilter != null;

  // --- Initialization ---

  /// Loads tasks and categories from persistence.
  ///
  /// Call this once after construction to populate the controller state.
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _getAllTasksUseCase.call(),
        _getAllCategoriesUseCase.call(),
      ]);
      _allTasks = results[0] as List<Task>;
      _allCategories = results[1] as List<Category>;
      _applyPipeline();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Pipeline ---

  /// Applies search → filter → sort to [_allTasks] and assigns the result
  /// to [_displayedTasks].
  ///
  /// This is synchronous and does NOT call [notifyListeners] — the caller
  /// is responsible for notification.
  void _applyPipeline() {
    var tasks = _allTasks;

    // 1. Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tasks = tasks.where((task) {
        final titleMatch = task.title.toLowerCase().contains(query);
        final descriptionMatch =
            task.description?.toLowerCase().contains(query) ?? false;
        return titleMatch || descriptionMatch;
      }).toList();
    }

    // 2. Filter (AND logic)
    if (_statusFilter != null) {
      tasks = tasks.where((task) => task.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      tasks = tasks.where((task) => task.priority == _priorityFilter).toList();
    }
    if (_categoryFilter != null) {
      if (_categoryFilter == -1) {
        tasks = tasks.where((task) => task.categoryId == null).toList();
      } else {
        tasks = tasks
            .where((task) => task.categoryId == _categoryFilter)
            .toList();
      }
    }

    // 3. Sort
    tasks = List.of(tasks)..sort(_compareTasks);

    // 4. Assign
    _displayedTasks = tasks;
  }

  /// Comparator applying the primary [_sortCriterion] and [_sortDirection],
  /// with a tie-breaker on [createdAt] descending.
  int _compareTasks(Task a, Task b) {
    final int primary;
    switch (_sortCriterion) {
      case SortCriterion.creationDate:
        primary = a.createdAt.compareTo(b.createdAt);
      case SortCriterion.priority:
        primary = a.priority.sortWeight.compareTo(b.priority.sortWeight);
      case SortCriterion.alphabetical:
        primary = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }

    final directed = _sortDirection == SortDirection.ascending
        ? primary
        : -primary;

    if (directed != 0) return directed;

    // Tie-breaker: createdAt descending
    return b.createdAt.compareTo(a.createdAt);
  }

  // --- Task Mutations ---

  /// Creates a new task and refreshes the displayed list.
  ///
  /// Sets loading state, invokes the create use case, reloads all tasks,
  /// and reapplies the search/filter/sort pipeline.
  Future<void> createTask({
    required String title,
    required Priority priority,
    String? description,
    int? categoryId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _createTaskUseCase.call(
        title: title,
        priority: priority,
        description: description,
        categoryId: categoryId,
      );
      _allTasks = await _getAllTasksUseCase.call();
      _applyPipeline();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Edits an existing task and refreshes the displayed list.
  ///
  /// Preserves immutable fields (createdAt, status, completedAt) via the
  /// use case logic.
  Future<void> editTask({
    required int id,
    required String title,
    required Priority priority,
    String? description,
    int? categoryId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _editTaskUseCase.call(
        id: id,
        title: title,
        priority: priority,
        description: description,
        categoryId: categoryId,
      );
      _allTasks = await _getAllTasksUseCase.call();
      _applyPipeline();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Permanently deletes a task by [id] and refreshes the displayed list.
  Future<void> deleteTask(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteTaskUseCase.call(id);
      _allTasks = await _getAllTasksUseCase.call();
      _applyPipeline();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marks a task as completed and refreshes the displayed list.
  Future<void> completeTask(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _completeTaskUseCase.call(id);
      _allTasks = await _getAllTasksUseCase.call();
      _applyPipeline();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reopens a completed task and refreshes the displayed list.
  Future<void> reopenTask(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reopenTaskUseCase.call(id);
      _allTasks = await _getAllTasksUseCase.call();
      _applyPipeline();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Category Mutations ---

  /// Creates a new category and refreshes the category list.
  Future<void> createCategory(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _createCategoryUseCase.call(name);
      _allCategories = await _getAllCategoriesUseCase.call();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Renames an existing category and refreshes the category list.
  Future<void> renameCategory({required int id, required String name}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _renameCategoryUseCase.call(id: id, name: name);
      _allCategories = await _getAllCategoriesUseCase.call();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a category and refreshes both tasks and categories.
  ///
  /// Because deleting a category also unassigns tasks that referenced it,
  /// both the task list and category list are reloaded.
  ///
  /// If the deleted category was selected as the active filter, the category
  /// filter is reset to show all categories.
  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteCategoryUseCase.call(id);

      if (_categoryFilter == id) {
        _categoryFilter = null;
      }

      final results = await Future.wait([
        _getAllTasksUseCase.call(),
        _getAllCategoriesUseCase.call(),
      ]);

      _allTasks = results[0] as List<Task>;
      _allCategories = results[1] as List<Category>;

      _applyPipeline();
    } on Exception catch (e) {
      _errorMessage = _userFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Filter / Sort Setters ---

  /// Updates the search query and reapplies the pipeline.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyPipeline();
    notifyListeners();
  }

  /// Updates the status filter and reapplies the pipeline.
  ///
  /// Pass `null` to show all statuses.
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    _applyPipeline();
    notifyListeners();
  }

  /// Updates the priority filter and reapplies the pipeline.
  ///
  /// Pass `null` to show all priorities.
  void setPriorityFilter(Priority? priority) {
    _priorityFilter = priority;
    _applyPipeline();
    notifyListeners();
  }

  /// Updates the category filter and reapplies the pipeline.
  ///
  /// Pass `null` for All, `-1` for Uncategorized, or a category ID.
  void setCategoryFilter(int? categoryId) {
    _categoryFilter = categoryId;
    _applyPipeline();
    notifyListeners();
  }

  /// Updates the sort criterion and reapplies the pipeline.
  void setSortCriterion(SortCriterion criterion) {
    _sortCriterion = criterion;
    _applyPipeline();
    notifyListeners();
  }

  /// Updates the sort direction and reapplies the pipeline.
  void setSortDirection(SortDirection direction) {
    _sortDirection = direction;
    _applyPipeline();
    notifyListeners();
  }

  /// Resets all filters (search, status, priority, category) and reapplies
  /// the pipeline.
  void clearAllFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _priorityFilter = null;
    _categoryFilter = null;
    _applyPipeline();
    notifyListeners();
  }

  // --- Helpers ---

  /// Converts an exception into a user-friendly message.
  String _userFriendlyMessage(Exception e) {
    return 'Something went wrong. Please try again.';
  }
}
