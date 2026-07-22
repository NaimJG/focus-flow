import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/isar_category_repository.dart';
import '../../data/repositories/isar_task_repository.dart';
import '../../domain/entities/task.dart';
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
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../controllers/todo_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/filter_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/sort_control.dart';
import '../widgets/task_list_widget.dart';
import 'category_manager_screen.dart';
import 'task_form_screen.dart';

/// The main screen for the todo feature.
///
/// Registers a [TodoController] via [ChangeNotifierProvider] and composes
/// the search bar, filter bar, sort control, and task list (or empty state).
class TodoScreen extends StatefulWidget {
  /// Creates a [TodoScreen] with the given [Isar] instance.
  const TodoScreen({super.key, required this.isar});

  /// The Isar database instance used to construct repositories.
  final Isar isar;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final TodoController _controller;

  @override
  void initState() {
    super.initState();

    final taskRepository = IsarTaskRepository(isar: widget.isar);
    final categoryRepository =
        IsarCategoryRepository(isar: widget.isar);

    _controller = TodoController(
      getAllTasksUseCase:
          GetAllTasksUseCase(taskRepository: taskRepository),
      getAllCategoriesUseCase: GetAllCategoriesUseCase(
        categoryRepository: categoryRepository,
      ),
      createTaskUseCase:
          CreateTaskUseCase(taskRepository: taskRepository),
      editTaskUseCase:
          EditTaskUseCase(taskRepository: taskRepository),
      deleteTaskUseCase:
          DeleteTaskUseCase(taskRepository: taskRepository),
      completeTaskUseCase:
          CompleteTaskUseCase(taskRepository: taskRepository),
      reopenTaskUseCase:
          ReopenTaskUseCase(taskRepository: taskRepository),
      createCategoryUseCase: CreateCategoryUseCase(
        categoryRepository: categoryRepository,
      ),
      renameCategoryUseCase: RenameCategoryUseCase(
        categoryRepository: categoryRepository,
      ),
      deleteCategoryUseCase: DeleteCategoryUseCase(
        categoryRepository: categoryRepository,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToCreateTask() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _controller,
          child: const TaskFormScreen(),
        ),
      ),
    );
  }

  void _navigateToEditTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _controller,
          child: TaskFormScreen(initialTask: task),
        ),
      ),
    );
  }

  void _navigateToCategories() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _controller,
          child: const CategoryManagerScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTask(int taskId) async {
    await ConfirmationDialog.show(
      context,
      title: 'Delete Task',
      message:
          'Are you sure you want to delete this task? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      onConfirm: () async {
        await _controller.deleteTask(taskId);
      },
    );
  }

  EmptyStateVariant _resolveEmptyVariant() {
    if (_controller.allTasks.isEmpty &&
        !_controller.hasActiveFilters &&
        _controller.searchQuery.isEmpty) {
      return EmptyStateVariant.noTasks;
    }
    if (_controller.searchQuery.isNotEmpty) {
      return EmptyStateVariant.noSearchResults;
    }
    if (_controller.categoryFilter != null) {
      return EmptyStateVariant.noCategoryTasks;
    }
    return EmptyStateVariant.noFilterResults;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: _TodoScreenContent(
        controller: _controller,
        onCreateTask: _navigateToCreateTask,
        onEditTask: _navigateToEditTask,
        onDeleteTask: _confirmDeleteTask,
        onCategories: _navigateToCategories,
        resolveEmptyVariant: _resolveEmptyVariant,
      ),
    );
  }
}

class _TodoScreenContent extends StatefulWidget {
  const _TodoScreenContent({
    required this.controller,
    required this.onCreateTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onCategories,
    required this.resolveEmptyVariant,
  });

  final TodoController controller;
  final VoidCallback onCreateTask;
  final ValueChanged<Task> onEditTask;
  final ValueChanged<int> onDeleteTask;
  final VoidCallback onCategories;
  final EmptyStateVariant Function() resolveEmptyVariant;

  @override
  State<_TodoScreenContent> createState() =>
      _TodoScreenContentState();
}

class _TodoScreenContentState extends State<_TodoScreenContent> {

  String? _lastError;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final error = widget.controller.errorMessage;

    if (error != null && error != _lastError) {
      _lastError = error;
      _showErrorSnackBar(error);
      return;
    }

    if (error == null) {
      _lastError = null;
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Reload',
            onPressed: () {
              widget.controller.init();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Semantics(
            label: 'Manage categories',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.category_outlined),
              tooltip: 'Categories',
              onPressed: widget.onCategories,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TodoController>(
          builder: (context, controller, _) {
            if (controller.isLoading &&
                controller.allTasks.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SearchBarWidget(
                    initialQuery: controller.searchQuery,
                    onChanged: controller.setSearchQuery,
                    onClear: () {
                      controller.setSearchQuery('');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: FilterBar(
                    activeStatus: controller.statusFilter,
                    activePriority: controller.priorityFilter,
                    activeCategoryId:
                        controller.categoryFilter,
                    categories:
                        controller.categories.toList(),
                    hasActiveFilters:
                        controller.hasActiveFilters,
                    onStatusChanged:
                        controller.setStatusFilter,
                    onPriorityChanged:
                        controller.setPriorityFilter,
                    onCategoryChanged:
                        controller.setCategoryFilter,
                    onClearAll: controller.clearAllFilters,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      SortControl(
                        activeCriterion:
                            controller.sortCriterion,
                        activeDirection:
                            controller.sortDirection,
                        onCriterionChanged:
                            controller.setSortCriterion,
                        onDirectionChanged:
                            controller.setSortDirection,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TaskListWidget(
                    tasks:
                        controller.displayedTasks.toList(),
                    categories:
                        controller.categories.toList(),
                    onComplete: controller.completeTask,
                    onReopen: controller.reopenTask,
                    onEdit: widget.onEditTask,
                    onDelete: widget.onDeleteTask,
                    emptyVariant:
                        widget.resolveEmptyVariant(),
                    onEmptyAction: widget.onCreateTask,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onCreateTask,
        tooltip: 'Create task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
