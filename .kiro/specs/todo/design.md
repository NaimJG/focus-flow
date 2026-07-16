# Design Document — Todo Feature

## Overview

The Todo feature is implemented as a self-contained module under `lib/features/todo/` following
Feature-First Clean Architecture. Isar is used for offline-first local persistence. Domain logic
lives exclusively in use cases; the presentation layer consumes only domain entities and interfaces.
State management is handled by a single `TodoController` (ChangeNotifier) that holds the full
observable state of the screen — task list, categories, search query, active filters, and sort
preference — and reacts to use-case outcomes to notify the UI. Search, filter, and sort are applied
as an in-memory pipeline inside the controller rather than as separate Isar queries, which keeps the
logic testable and avoids over-engineering the query layer for v1.0.

---

## Architecture

The feature maps directly to the standard internal layout:

```
lib/features/todo/
├── data/
│   ├── models/
│   │   ├── task_model.dart          # @collection — Isar schema for Task
│   │   └── category_model.dart      # @collection — Isar schema for Category
│   └── repositories/
│       ├── isar_task_repository.dart
│       └── isar_category_repository.dart
├── domain/
│   ├── entities/
│   │   ├── task.dart                # Pure domain object
│   │   └── category.dart            # Pure domain object
│   ├── repositories/
│   │   ├── task_repository.dart     # Abstract interface
│   │   └── category_repository.dart # Abstract interface
│   └── use_cases/
│       ├── create_task_use_case.dart
│       ├── edit_task_use_case.dart
│       ├── delete_task_use_case.dart
│       ├── complete_task_use_case.dart
│       ├── reopen_task_use_case.dart
│       ├── get_all_tasks_use_case.dart
│       ├── create_category_use_case.dart
│       ├── rename_category_use_case.dart
│       ├── delete_category_use_case.dart
│       ├── get_all_categories_use_case.dart
│       └── seed_default_categories_use_case.dart
├── presentation/
│   ├── screens/
│   │   ├── todo_screen.dart
│   │   ├── task_form_screen.dart
│   │   └── category_manager_screen.dart
│   ├── widgets/
│   │   ├── task_list_widget.dart
│   │   ├── task_card.dart
│   │   ├── search_bar_widget.dart
│   │   ├── filter_bar.dart
│   │   ├── sort_control.dart
│   │   ├── empty_state_widget.dart
│   │   └── confirmation_dialog.dart
│   └── controllers/
│       └── todo_controller.dart
└── todo_module.dart
```

### Dependency Rules

- `presentation/` imports only from `domain/entities/` and `domain/repositories/` (via the
  controller).
- `data/` implements interfaces from `domain/repositories/`.
- The Isar instance is sourced from `core/database/` and injected into repository constructors.
- No feature imports from another feature's `data/` or `domain/` layers.

---

## Data Models

### Priority Enum

```dart
enum Priority {
  high,   // sort weight 2
  medium, // sort weight 1 — default
  low,    // sort weight 0
}
```

Stored as an integer index in Isar. The sort weight is an extension getter:

```dart
extension PriorityWeight on Priority {
  int get sortWeight {
    switch (this) {
      case Priority.high:   return 2;
      case Priority.medium: return 1;
      case Priority.low:    return 0;
    }
  }
}
```

### TaskStatus Enum

```dart
enum TaskStatus {
  pending,
  completed,
}
```

Stored as an integer index in Isar.

### TaskModel (Isar Collection)

| Field           | Dart Type      | Nullable | Notes                                      |
|-----------------|----------------|----------|--------------------------------------------|
| `id`            | `Id`           | No       | Isar auto-increment primary key            |
| `title`         | `String`       | No       | Non-empty, validated before persistence    |
| `description`   | `String?`      | Yes      | Optional; stored as null when omitted      |
| `priorityIndex` | `int`          | No       | Stored index of `Priority` enum            |
| `statusIndex`   | `int`          | No       | Stored index of `TaskStatus` enum          |
| `categoryId`    | `int?`         | Yes      | Foreign key to `CategoryModel.id`; nullable|
| `createdAt`     | `DateTime`     | No       | Set at creation; never mutated             |
| `completedAt`   | `DateTime?`    | Yes      | Set on completion; nulled on reopen        |

**Isar Indexes:**

```dart
@Index(type: IndexType.value)
late int statusIndex;          // fast status filter

@Index(type: IndexType.value)
late int priorityIndex;        // fast priority sort / filter

@Index(type: IndexType.value)
late int? categoryId;          // fast category filter

@Index(type: IndexType.value)
late DateTime createdAt;       // fast creation-date sort

@Index(type: IndexType.hash)
late String title;             // case-insensitive search (lowercased on write)
```

> **Note on search**: To support case-insensitive substring search efficiently,
> `title` and `description` will be queried with Isar's `.contains()` filter. For
> v1.0 the task list is expected to be small enough that in-memory filtering after a
> full collection read is acceptable. The index on `title` aids equality/prefix
> queries but substring search still does a scan; this is a documented trade-off
> acceptable at v1.0 scale.

**Validation rules for TaskModel:**
- `title.trim()` must not be empty.
- `priorityIndex` must be 0, 1, or 2.
- `statusIndex` must be 0 or 1.
- `createdAt` is immutable after creation.

### CategoryModel (Isar Collection)

| Field  | Dart Type | Nullable | Notes                                  |
|--------|-----------|----------|----------------------------------------|
| `id`   | `Id`      | No       | Isar auto-increment; stable identifier |
| `name` | `String`  | No       | Non-empty, validated before persistence|

**Isar Indexes:**

```dart
@Index(unique: true, type: IndexType.hash)
late String name;    // prevent exact-duplicate category names at DB level
```

**Validation rules for CategoryModel:**
- `name.trim()` must not be empty.

### Task–Category Relationship

Tasks reference categories by `categoryId` (the Isar `Id` of `CategoryModel`). This is an
integer foreign key — there is no Isar `IsarLink`. The relationship is managed explicitly in
`DeleteCategoryUseCase`, which nullifies `categoryId` on all affected tasks within a single
Isar write transaction. Renaming a category does not touch any task because the ID is the
stable reference.

### Domain Entities

The domain layer uses plain Dart classes (`Task`, `Category`) without Isar annotations. Repository
implementations map between `TaskModel`/`CategoryModel` and their entity counterparts.

```dart
class Task {
  final int id;
  final String title;
  final String? description;
  final Priority priority;
  final TaskStatus status;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime? completedAt;
}

class Category {
  final int id;
  final String name;
}
```

Both classes use `const` constructors and are fully immutable.

---

## Repository Interfaces (Domain Layer)

### TaskRepository

```dart
abstract interface class TaskRepository {
  /// Returns all tasks, unordered.
  Future<List<Task>> getAll();

  /// Returns a single task by its Isar ID, or null if not found.
  Future<Task?> findById(int id);

  /// Persists a new task and returns the saved entity with its assigned ID.
  Future<Task> create(Task task);

  /// Persists updates to an existing task. Throws if the task does not exist.
  Future<Task> update(Task task);

  /// Permanently removes the task with the given ID. No-op if not found.
  Future<void> delete(int id);
}
```

### CategoryRepository

```dart
abstract interface class CategoryRepository {
  /// Returns all categories, unordered.
  Future<List<Category>> getAll();

  /// Returns the count of categories in storage.
  Future<int> count();

  /// Persists a new category and returns the saved entity with its assigned ID.
  Future<Category> create(Category category);

  /// Persists a name change for an existing category. Throws if not found.
  Future<Category> update(Category category);

  /// Permanently removes the category with the given ID. No-op if not found.
  Future<void> delete(int id);
}
```

---

## Use Cases (Domain Layer)

Each use case is a single class with one public `call()` method. Constructor-injected dependencies
are the relevant repository interfaces only.

| Use Case Class                   | Inputs                                          | Return Type          |
|----------------------------------|-------------------------------------------------|----------------------|
| `CreateTaskUseCase`              | `{title, priority, description?, categoryId?}`  | `Future<Task>`       |
| `EditTaskUseCase`                | `{id, title, priority, description?, categoryId?}` | `Future<Task>`    |
| `DeleteTaskUseCase`              | `int id`                                        | `Future<void>`       |
| `CompleteTaskUseCase`            | `int id`                                        | `Future<Task>`       |
| `ReopenTaskUseCase`              | `int id`                                        | `Future<Task>`       |
| `GetAllTasksUseCase`             | _(none)_                                        | `Future<List<Task>>` |
| `CreateCategoryUseCase`          | `String name`                                   | `Future<Category>`   |
| `RenameCategoryUseCase`          | `{int id, String name}`                         | `Future<Category>`   |
| `DeleteCategoryUseCase`          | `int id`                                        | `Future<void>`       |
| `GetAllCategoriesUseCase`        | _(none)_                                        | `Future<List<Category>>` |
| `SeedDefaultCategoriesUseCase`   | _(none)_                                        | `Future<void>`       |

### Validation

`CreateTaskUseCase` and `EditTaskUseCase` validate that `title.trim()` is non-empty and throw a
typed `ValidationException` if not. `CreateCategoryUseCase` and `RenameCategoryUseCase` do the same
for `name.trim()`. The UI layer catches `ValidationException` and surfaces the message on the
appropriate form field.

### DeleteCategoryUseCase — Cascade Null Strategy

This use case performs two operations in a single logical transaction:
1. Fetch all tasks where `categoryId == id`.
2. Update each affected task to set `categoryId = null`.
3. Delete the category record.

Isar supports wrapping these writes in a single `isar.writeTxn()` block, ensuring atomicity.

### SeedDefaultCategoriesUseCase — Guard Logic

```
if (await categoryRepository.count() == 0) {
  create 'Trabajo', 'Estudio', 'Hogar', 'Personal'
}
```

This check runs once at app startup (called from `main.dart` after Isar initialization). If the
count is zero, four categories are created. If any category exists — including user-created ones or
re-seeded scenarios — the guard prevents re-creation. Deleted default categories are never recreated
because the count check is the only trigger.

---

## State Management

### Approach: ChangeNotifier + Provider

`TodoController extends ChangeNotifier` is the chosen approach. Rationale:

- The screen has a single cohesive state bag (task list, categories, search, filters, sort) that
  naturally belongs together.
- `ChangeNotifier` with `ListenableBuilder` is the simplest Flutter-native solution that satisfies
  this shape without pulling in an additional library.
- Riverpod would add value if multiple features needed to share or react to todo state. At v1.0,
  only `TodoScreen` and its descendants consume this state, so ChangeNotifier is sufficient.

The controller is registered via `ChangeNotifierProvider` at the route level (not app level),
scoping its lifetime to the todo screen tree.

### TodoController Responsibilities

- Load all tasks and categories from use cases on initialization.
- Run the search → filter → sort pipeline whenever any input changes.
- Expose the composed, display-ready task list to the UI.
- Expose current filter state so `FilterBar` can reflect active filters.
- Coordinate all mutating operations (create, edit, delete, complete, reopen, create/rename/delete
  category) and reload state after each success.
- Expose error and loading flags for the UI to render feedback states.

### State Shape

```dart
class TodoController extends ChangeNotifier {
  // --- Raw data (from repository) ---
  List<Task> _allTasks = [];
  List<Category> _allCategories = [];

  // --- Search / Filter / Sort inputs ---
  String _searchQuery = '';
  TaskStatus? _statusFilter;        // null == All
  Priority? _priorityFilter;        // null == All
  int? _categoryFilter;             // null == All; -1 == Uncategorized
  SortCriterion _sortCriterion = SortCriterion.creationDate;
  SortDirection _sortDirection = SortDirection.descending;

  // --- Derived (computed by _applyPipeline) ---
  List<Task> get displayedTasks => _displayedTasks;
  List<Task> _displayedTasks = [];

  // --- Feedback ---
  bool get isLoading => _isLoading;
  bool _isLoading = false;
  String? get errorMessage => _errorMessage;
  String? _errorMessage;

  // --- Accessors ---
  List<Category> get categories => _allCategories;
  String get searchQuery => _searchQuery;
  TaskStatus? get statusFilter => _statusFilter;
  Priority? get priorityFilter => _priorityFilter;
  int? get categoryFilter => _categoryFilter;
  SortCriterion get sortCriterion => _sortCriterion;
  SortDirection get sortDirection => _sortDirection;
  bool get hasActiveFilters =>
      _statusFilter != null || _priorityFilter != null || _categoryFilter != null;
}
```

`SortCriterion` and `SortDirection` are enums defined in the domain layer (or `shared/enums/` if
reused by other features).

### Search + Filter + Sort Pipeline

Every time any of `_searchQuery`, `_statusFilter`, `_priorityFilter`, `_categoryFilter`,
`_sortCriterion`, `_sortDirection`, or `_allTasks` changes, the controller calls `_applyPipeline()`:

```
_displayedTasks = sort( filter( search( _allTasks ) ) )
notifyListeners()
```

This is a synchronous in-memory operation — no async call needed after the initial load. The pipeline
runs in under a millisecond for typical task list sizes and does not need debouncing for v1.0.

---

## Component Breakdown (Presentation Layer)

### TodoScreen

**Purpose:** Primary screen. Orchestrates the full task management experience.  
**Route:** `/todo`  
**Key inputs:** `TodoController` (via `context.read` / `ListenableBuilder`)  
**Key outputs:** Navigates to `TaskFormScreen` (create/edit), `CategoryManagerScreen`. Shows
`ConfirmationDialog` for delete. Shows snackbars for transient confirmations.  
**Layout:** `Scaffold` with `AppBar` containing the app title and a categories action. Below the
app bar: `SearchBarWidget`, `FilterBar`, `SortControl` (collapsible row), then `TaskListWidget` or
`EmptyStateWidget`. FAB triggers task creation.

---

### TaskListWidget

**Purpose:** Renders the list of `displayedTasks` from the controller.  
**Key inputs:** `List<Task> tasks`, `List<Category> categories` (for displaying category name),
`onComplete(int taskId)`, `onReopen(int taskId)`, `onEdit(Task task)`, `onDelete(int taskId)`  
**Key outputs:** Fires the above callbacks to the parent screen.  
**Implementation:** `ListView.builder` with `TaskCard` items. Shows `EmptyStateWidget` if list is
empty.

---

### TaskCard

**Purpose:** Displays a single task's summary and provides inline status toggle and delete trigger.  
**Key inputs:** `Task task`, `String? categoryName`, `VoidCallback onToggleStatus`,
`VoidCallback onEdit`, `VoidCallback onDelete`  
**Key outputs:** Fires the above callbacks.  
**Layout:** Material 3 `Card`. Leading: `Checkbox` or `IconButton` for status toggle (48×48dp min).
Title + optional description line. Trailing row: priority chip (icon + label, not color-only),
optional category label, delete `IconButton`. All interactive targets ≥ 48×48dp. Priority is shown
with both an icon and a text label (never color alone).

---

### TaskFormScreen

**Purpose:** Create or edit a task. Same screen, two modes.  
**Route:** `/todo/task/new`, `/todo/task/:id/edit`  
**Key inputs:** Optional `Task? initialTask` (null = create mode)  
**Key outputs:** Calls `controller.createTask(...)` or `controller.editTask(...)` and pops on
success.  
**Layout:** `Scaffold` with form fields: `TextField` for title (autofocus, validated), `TextField`
for description (optional), `DropdownButton<Priority>` for priority (default Medium),
`DropdownButton<int?>` for category (shows all categories + "No category" option). `FilledButton`
to submit.

---

### CategoryManagerScreen

**Purpose:** List, create, rename, and delete categories.  
**Route:** `/todo/categories`  
**Key inputs:** `TodoController` categories list  
**Key outputs:** Fires create / rename / delete category operations on the controller.  
**Layout:** `Scaffold` with a `ListView` of category rows (name + rename `IconButton` + delete
`IconButton`). FAB or top action to add a new category (inline `TextField` or mini-form).
`ConfirmationDialog` before delete.

---

### SearchBarWidget

**Purpose:** Text input that drives `controller.setSearchQuery(query)` on every keystroke.  
**Key inputs:** `String initialQuery`, `ValueChanged<String> onChanged`, `VoidCallback onClear`  
**Key outputs:** `onChanged` on each character, `onClear` when the clear button is tapped.  
**Implementation:** Material 3 `SearchBar` or a `TextField` with a clear suffix icon. Fires
`onChanged` synchronously; the controller's `_applyPipeline` is the debounce boundary (none needed
at v1.0).

---

### FilterBar

**Purpose:** Displays the active filter chips and exposes controls to change or clear them.  
**Key inputs:** `TaskStatus? activeStatus`, `Priority? activePriority`, `int? activeCategoryId`,
`List<Category> categories`, callbacks for each filter change, `VoidCallback onClearAll`  
**Key outputs:** Filter-change callbacks.  
**Layout:** A horizontal scrollable row of `FilterChip` widgets. When `hasActiveFilters` is true,
a "Clear" chip or button is appended. Each chip shows the active value; tapping opens a
`DropdownMenu` or a bottom sheet with options.

---

### SortControl

**Purpose:** Exposes sort criterion and direction selection.  
**Key inputs:** `SortCriterion activeCriterion`, `SortDirection activeDirection`,
`ValueChanged<SortCriterion> onCriterionChanged`, `ValueChanged<SortDirection> onDirectionChanged`  
**Key outputs:** The above callbacks.  
**Layout:** A compact row with a `DropdownButton<SortCriterion>` and a direction toggle
`IconButton` (ascending/descending arrow icon with a `Semantics` label).

---

### EmptyStateWidget

**Purpose:** Context-sensitive empty state message.  
**Key inputs:** `EmptyStateVariant variant` (enum: `noTasks`, `noSearchResults`,
`noFilterResults`, `noCategoryTasks`)  
**Key outputs:** Optional `VoidCallback? onAction` for a CTA button (e.g., "Create your first
task").  
**Layout:** Centered column with an illustrative icon, a headline, a supporting message, and an
optional `OutlinedButton` CTA. All text ≥ 12sp.

---

### ConfirmationDialog

**Purpose:** Reusable modal dialog for destructive-action confirmation.  
**Key inputs:** `String title`, `String message`, `String confirmLabel`, `String cancelLabel`,
`VoidCallback onConfirm`  
**Key outputs:** Fires `onConfirm` or pops on cancel.  
**Implementation:** `showDialog` with a Material 3 `AlertDialog`. Cancel uses a `TextButton`,
confirm uses a `FilledButton` (or `FilledButton.tonal` for destructive actions). This widget lives
in `shared/widgets/` for reuse across the app.

---

## Components and Interfaces

This section consolidates the public contracts of every component in the Todo feature. These signatures are the implementation targets — nothing more and nothing less than what is needed to satisfy the requirements.

---

### Domain Exceptions

```dart
// lib/features/todo/domain/exceptions/validation_exception.dart
class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
}

// lib/features/todo/domain/exceptions/not_found_exception.dart
class NotFoundException implements Exception {
  const NotFoundException({required this.message, required this.id});
  final String message;
  final int id;
}
```

---

### Domain Enums

```dart
// lib/features/todo/domain/entities/priority.dart
enum Priority { high, medium, low }

extension PriorityWeight on Priority {
  int get sortWeight { ... } // high→2, medium→1, low→0
}

// lib/features/todo/domain/entities/task_status.dart
enum TaskStatus { pending, completed }

// lib/features/todo/domain/entities/sort_criterion.dart
enum SortCriterion { creationDate, priority, alphabetical }

// lib/features/todo/domain/entities/sort_direction.dart
enum SortDirection { ascending, descending }
```

---

### TodoController Public API

```dart
// lib/features/todo/presentation/controllers/todo_controller.dart
class TodoController extends ChangeNotifier {

  // --- Initialisation ---
  Future<void> init();

  // --- Read-only state ---
  List<Task>     get displayedTasks;
  List<Category> get categories;
  bool           get isLoading;
  String?        get errorMessage;
  bool           get hasActiveFilters;

  // --- Current filter / sort state ---
  String         get searchQuery;
  TaskStatus?    get statusFilter;    // null == All
  Priority?      get priorityFilter;  // null == All
  int?           get categoryFilter;  // null == All; -1 == Uncategorized
  SortCriterion  get sortCriterion;
  SortDirection  get sortDirection;

  // --- Filter / sort setters (each calls _applyPipeline + notifyListeners) ---
  void setSearchQuery(String query);
  void setStatusFilter(TaskStatus? status);
  void setPriorityFilter(Priority? priority);
  void setCategoryFilter(int? categoryId);   // pass -1 for Uncategorized
  void setSortCriterion(SortCriterion criterion);
  void setSortDirection(SortDirection direction);
  void clearAllFilters();

  // --- Task mutations ---
  Future<void> createTask({
    required String title,
    required Priority priority,
    String? description,
    int? categoryId,
  });

  Future<void> editTask({
    required int id,
    required String title,
    required Priority priority,
    String? description,
    int? categoryId,
  });

  Future<void> deleteTask(int id);
  Future<void> completeTask(int id);
  Future<void> reopenTask(int id);

  // --- Category mutations ---
  Future<void> createCategory(String name);
  Future<void> renameCategory(int id, String name);
  Future<void> deleteCategory(int id);
}
```

---

### Widget Interfaces

#### ConfirmationDialog
```dart
// lib/shared/widgets/confirmation_dialog.dart
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
}
```

#### EmptyStateVariant and EmptyStateWidget
```dart
// lib/features/todo/presentation/widgets/empty_state_widget.dart
enum EmptyStateVariant {
  noTasks,         // No tasks created yet — shows CTA
  noSearchResults, // Query returned nothing
  noFilterResults, // Active filters returned nothing
  noCategoryTasks, // Selected category has no tasks
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.variant,
    this.onAction,
  });

  final EmptyStateVariant variant;
  final VoidCallback? onAction; // Only shown for noTasks variant
}
```

#### TaskCard
```dart
// lib/features/todo/presentation/widgets/task_card.dart
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.categoryName,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final String? categoryName;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
}
```

#### TaskListWidget
```dart
// lib/features/todo/presentation/widgets/task_list_widget.dart
class TaskListWidget extends StatelessWidget {
  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.categories,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
    required this.emptyVariant,
  });

  final List<Task> tasks;
  final List<Category> categories;
  final ValueChanged<int> onComplete;   // taskId
  final ValueChanged<int> onReopen;     // taskId
  final ValueChanged<Task> onEdit;
  final ValueChanged<int> onDelete;     // taskId
  final EmptyStateVariant emptyVariant;
}
```

#### SearchBarWidget
```dart
// lib/features/todo/presentation/widgets/search_bar_widget.dart
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.initialQuery,
    required this.onChanged,
    required this.onClear,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
}
```

#### FilterBar
```dart
// lib/features/todo/presentation/widgets/filter_bar.dart
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.activeStatus,
    required this.activePriority,
    required this.activeCategoryId,
    required this.categories,
    required this.hasActiveFilters,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onClearAll,
  });

  final TaskStatus? activeStatus;
  final Priority? activePriority;
  final int? activeCategoryId;
  final List<Category> categories;
  final bool hasActiveFilters;
  final ValueChanged<TaskStatus?> onStatusChanged;
  final ValueChanged<Priority?> onPriorityChanged;
  final ValueChanged<int?> onCategoryChanged;
  final VoidCallback onClearAll;
}
```

#### SortControl
```dart
// lib/features/todo/presentation/widgets/sort_control.dart
class SortControl extends StatelessWidget {
  const SortControl({
    super.key,
    required this.activeCriterion,
    required this.activeDirection,
    required this.onCriterionChanged,
    required this.onDirectionChanged,
  });

  final SortCriterion activeCriterion;
  final SortDirection activeDirection;
  final ValueChanged<SortCriterion> onCriterionChanged;
  final ValueChanged<SortDirection> onDirectionChanged;
}
```

#### TaskFormScreen
```dart
// lib/features/todo/presentation/screens/task_form_screen.dart
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({
    super.key,
    this.initialTask, // null = create mode; non-null = edit mode
  });

  final Task? initialTask;
}
```

#### CategoryManagerScreen
```dart
// lib/features/todo/presentation/screens/category_manager_screen.dart
class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});
  // Reads TodoController from context via Provider
}
```

#### TodoScreen
```dart
// lib/features/todo/presentation/screens/todo_screen.dart
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  // Registers TodoController via ChangeNotifierProvider at this route level
}
```

---

## Default Categories Initialization

`SeedDefaultCategoriesUseCase` is called once from `main.dart`, after Isar has been initialized and
before `runApp` registers the root widget:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openIsar();               // core/database/
  await SeedDefaultCategoriesUseCase(
    categoryRepository: IsarCategoryRepository(isar),
  ).call();
  runApp(FocusFlowApp(isar: isar));
}
```

The use case implementation:

```dart
Future<void> call() async {
  final count = await categoryRepository.count();
  if (count == 0) {
    for (final name in ['Trabajo', 'Estudio', 'Hogar', 'Personal']) {
      await categoryRepository.create(Category(id: Isar.autoIncrement, name: name));
    }
  }
}
```

**Why this strategy:**
- The `count() == 0` guard is the single source of truth. It fires exactly once in the app's
  lifetime when no categories exist.
- Deleted default categories reduce the count below 4 but not to 0 (unless the user deletes all
  categories). Even if the count drops to 0 after the user deletes every category, the next app
  start would re-seed — this is acceptable and documented as the designed behavior (see
  Requirements 9.4: a *specific deleted default category* is not recreated, but seeding happens
  fresh if all categories are gone).
- No boolean flag, shared preference, or migration table is needed, keeping the implementation
  simple.

---

## Search, Filter and Sort Composition

### Pipeline Order

```
displayedTasks = sort( filter( search( allTasks ) ) )
```

1. **Search** — applied first. If `searchQuery` is non-empty, retains only tasks where
   `title.toLowerCase().contains(query.toLowerCase())` OR
   `(description ?? '').toLowerCase().contains(query.toLowerCase())`.
2. **Filter** — applied to the search result. Each active filter predicate is ANDed:
   - Status filter: `task.status == activeStatus` (skipped if null/All)
   - Priority filter: `task.priority == activePriority` (skipped if null/All)
   - Category filter:
     - `task.categoryId == categoryFilter` for a specific category ID
     - `task.categoryId == null` when `categoryFilter == -1` (Uncategorized sentinel)
     - No predicate when null (All Categories)
3. **Sort** — applied to the filtered result. A `Comparator<Task>` is built from the active
   `sortCriterion` and `sortDirection`, with a secondary tie-breaker of
   `createdAt descending` always applied last.

### Sort Comparator

```dart
int _compare(Task a, Task b) {
  int primary;
  switch (_sortCriterion) {
    case SortCriterion.creationDate:
      primary = a.createdAt.compareTo(b.createdAt);
    case SortCriterion.priority:
      primary = a.priority.sortWeight.compareTo(b.priority.sortWeight);
    case SortCriterion.alphabetical:
      primary = a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }
  if (_sortDirection == SortDirection.descending) primary = -primary;
  if (primary != 0) return primary;
  // Tie-breaker: creation date descending (most recent first)
  return b.createdAt.compareTo(a.createdAt);
}
```

### Reactivity

All three inputs are properties of `TodoController`. Any setter method (`setSearchQuery`,
`setStatusFilter`, `setPriorityFilter`, `setCategoryFilter`, `setSortCriterion`,
`setSortDirection`) calls `_applyPipeline()` before `notifyListeners()`. Mutations (create, edit,
delete, complete, reopen) reload `_allTasks` from the repository then call `_applyPipeline()`.
The UI rebuilds only the `ListenableBuilder` subtree that wraps `TaskListWidget` and the controls.

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a
system — essentially, a formal statement about what the system should do. Properties serve as the
bridge between human-readable specifications and machine-verifiable correctness guarantees.*

The properties below are derived from the prework analysis of the requirements acceptance criteria.
They are universally quantified statements that will be implemented as property-based tests using
the `dart_test` framework with a property-testing library (e.g., `fast_check` for Dart).
Minimum 100 iterations per property test.

---

### Property 1: Task creation round-trip preserves all input fields

*For any* valid task creation input (non-whitespace title, any priority, optional description, optional
categoryId), the task returned by `CreateTaskUseCase` shall have a title, priority, description, and
categoryId that exactly match the provided inputs.

**Validates: Requirements 1.1**

---

### Property 2: Newly created tasks are always Pending with no completion timestamp

*For any* valid task creation input, the task returned by `CreateTaskUseCase` shall have
`status == TaskStatus.pending` and `completedAt == null`.

**Validates: Requirements 1.3**

---

### Property 3: Whitespace-only titles are always rejected

*For any* string composed entirely of whitespace characters (spaces, tabs, newlines), submitting it
as a task title to `CreateTaskUseCase` or `EditTaskUseCase` shall throw a `ValidationException` and
leave the task store unchanged.

**Validates: Requirements 1.4, 2.2**

---

### Property 4: Task edit preserves immutable fields

*For any* existing task and any valid edit input (new title, priority, description, categoryId),
calling `EditTaskUseCase` shall produce a task where `createdAt` is identical to the original
`createdAt`, and `status` and `completedAt` are identical to their pre-edit values.

**Validates: Requirements 2.3, 2.4**

---

### Property 5: Complete → Reopen is a status round-trip

*For any* pending task, calling `CompleteTaskUseCase` followed by `ReopenTaskUseCase` shall produce
a task with `status == TaskStatus.pending` and `completedAt == null` — identical status to the
original task before the complete call. Conversely, after `CompleteTaskUseCase` alone, the task
shall have `status == TaskStatus.completed` and a non-null `completedAt`.

**Validates: Requirements 4.1, 4.2**

---

### Property 6: Deleted task is no longer retrievable

*For any* existing task, calling `DeleteTaskUseCase` with its ID shall result in
`TaskRepository.findById(id)` returning null, and the task shall not appear in the result of
`GetAllTasksUseCase`.

**Validates: Requirements 3.2**

---

### Property 7: Category rename preserves ID and all task associations

*For any* category and any valid (non-whitespace) new name, calling `RenameCategoryUseCase` shall
produce a category with the same `id` as before and the updated `name`. Furthermore, for any tasks
whose `categoryId` equalled that category's `id` before the rename, their `categoryId` shall be
unchanged after the rename.

**Validates: Requirements 7.1, 7.3**

---

### Property 8: Category deletion nullifies all associated task references without deleting tasks

*For any* category and any set of tasks referencing that category by `categoryId`, calling
`DeleteCategoryUseCase` shall result in: (a) all previously-associated tasks still existing in
storage with `categoryId == null`, and (b) the category itself no longer being retrievable.

**Validates: Requirements 8.2, 8.4, 8.5**

---

### Property 9: Default category seeding is a no-op when categories already exist

*For any* non-empty category collection (count ≥ 1), calling `SeedDefaultCategoriesUseCase` shall
leave the category count and content unchanged.

**Validates: Requirements 9.2, 9.4**

---

### Property 10: Search returns exactly the tasks that contain the query (case-insensitive)

*For any* non-empty search query `q` and any list of tasks, the search pipeline step shall return
exactly those tasks where `title.toLowerCase().contains(q.toLowerCase())` or
`(description ?? '').toLowerCase().contains(q.toLowerCase())` — no more, no less.

**Validates: Requirements 10.1**

---

### Property 11: Multi-filter conjunction — only tasks satisfying all active filters are shown

*For any* combination of active status, priority, and category filter values and any list of tasks,
the filter pipeline step shall return exactly those tasks that satisfy every active (non-All) filter
predicate simultaneously.

**Validates: Requirements 11.4**

---

### Property 12: Sort produces a stable ordering with correct tie-breaking

*For any* list of tasks and any sort criterion and direction, the sort pipeline step shall return a
permutation of the input where: (a) all adjacent pairs satisfy the comparator for the chosen
criterion and direction, and (b) any two tasks that are equal on the primary criterion are ordered
by `createdAt` descending.

**Validates: Requirements 12.1, 12.2, 12.4, 12.8**

---

### Property 13: Persistence round-trip — written data is fully recovered on read

*For any* task or category object written to Isar via the repository, reading it back by its ID
shall return an object with equal field values to the original.

**Validates: Requirements 13.1, 13.2, 13.3**

---

## Error Handling

### Validation Errors

`ValidationException` is thrown by use cases when input does not meet domain rules (empty title,
empty category name). The presentation layer catches this at the form submission call site and
displays the message on the relevant form field using Flutter's `TextFormField` error text
mechanism. No snackbar is shown for validation errors — the inline field error is the feedback.

### Persistence Errors

Any `IsarError` or unexpected exception thrown by a repository is caught by the controller
method that triggered the operation. The controller sets `_errorMessage` to a user-friendly plain-
language string and calls `notifyListeners()`. `TodoScreen` observes `controller.errorMessage` and
displays a `SnackBar` with a "Retry" action that re-invokes the same operation.

### Not-Found Errors

`EditTaskUseCase`, `CompleteTaskUseCase`, `ReopenTaskUseCase`, and `DeleteTaskUseCase` will throw a
`NotFoundException` if the target ID does not exist in storage (e.g., task was deleted from another
code path). The controller treats `NotFoundException` like a persistence error — shows an error
snackbar. For delete specifically, a not-found result is treated as a no-op success (idempotent
delete).

### Category Deletion with Concurrent Task Changes

`DeleteCategoryUseCase` performs its cascade null-update and category deletion in a single Isar
write transaction. If the transaction fails, all writes are rolled back and a `PersistenceException`
propagates to the controller.

---

## Testing Strategy

### Unit Tests (Use Cases)

Use cases are the primary unit-test target. Each use case is tested with an in-memory fake
repository implementation. Tests cover:

- Happy-path creation, edit, delete, complete, reopen, rename, category delete.
- Validation rejection (empty/whitespace title, empty category name).
- Preservation invariants (createdAt, status, categoryId after edits).
- Cascade null on category delete.
- Seeding guard (count > 0 → no-op).

### Property-Based Tests (Use Cases + Pipeline)

The 13 correctness properties defined above are each implemented as a single property-based test.
The chosen library is [`dart_fast_check`](https://pub.dev/packages/dart_fast_check) (the Dart port
of fast-check). Each test:

- Runs a minimum of **100 iterations** per property.
- Uses arbitrary generators for `Task`, `Category`, `String` (including whitespace-only strings),
  `Priority`, `TaskStatus`, and `int` IDs.
- Is tagged with a comment in the format:
  `// Feature: todo, Property N: <property title>`
- Uses in-memory fake repositories — no Isar database is required for property tests.

### Widget Tests (Presentation)

Widget tests cover critical user interactions:

- Task creation form: submit with valid input → task appears in list.
- Task creation form: submit with empty title → validation error shown.
- Task card: tap checkbox → status updates in controller.
- Task card: tap delete → confirmation dialog appears.
- Confirmation dialog: confirm → deletion proceeds; cancel → task unchanged.
- EmptyStateWidget: correct variant shown for each empty-state scenario.
- FilterBar: clear-all resets all filter chips.

Widget tests use a mock `TodoController` (or a real controller with fake repositories) to avoid
Isar in the test environment.

### Integration Tests

- Isar read/write round-trip for `TaskModel` and `CategoryModel` (validates Property 13 at the
  database layer).
- `SeedDefaultCategoriesUseCase` end-to-end: fresh Isar → four categories created; second run →
  no change.

### What Is Not Property-Tested

- UI rendering and layout (widget tests / manual review).
- Accessibility compliance (manual review with TalkBack + automated accessibility scanner).
- Default categories seeding example (single integration test is sufficient; the no-op guard is
  Property 9).

---

## Open Questions

| # | Question | Deferred Rationale |
|---|----------|--------------------|
| 1 | Should `FilterBar` use a bottom sheet or inline chips + dropdowns for filter selection? | UX detail best decided during implementation when the real screen layout is visible. Both approaches satisfy the requirements. |
| 2 | Should `CategoryManagerScreen` be a separate full-screen route or a modal bottom sheet? | Either satisfies the requirements. A full screen is simpler to implement and test; a sheet feels lighter. Deferred to implementation. |
| 3 | Should the `Uncategorized` category filter option use sentinel value `-1` or a separate enum? | A sealed class `CategoryFilterValue` (All, Uncategorized, Specific(int id)) would be cleaner but adds a type not strictly required. Deferred — use the sentinel `-1` int for v1.0 and refactor if the extra type pays off. |
| 4 | Task swipe-to-delete vs. icon button only? | Requirements specify deletion via interaction from the task list but do not prescribe swipe. Swipe is a common Android pattern but adds gesture handling complexity. Deferred — implement icon-button delete first; swipe can be layered on. |
| 5 | Should `dart_fast_check` or another PBT library be used? | `dart_fast_check` is the most actively maintained Dart PBT library at the time of writing. Confirm latest version and API before implementation. |
