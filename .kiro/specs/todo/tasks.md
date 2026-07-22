# Implementation Plan: Todo Feature

## Overview

Implementation follows Feature-First Clean Architecture from the inside out: domain entities and
interfaces first, then use cases, then data layer (Isar), then state management, then presentation
widgets and screens, and finally all test layers. Each task produces a compilable, self-contained
increment. The implementation language is **Dart / Flutter**.

---

## Tasks

### Group 1 — Domain Layer

- [x] 1. Define `Priority` and `TaskStatus` enums with sort weights
  - [x] 1.1 Create `lib/features/todo/domain/entities/priority.dart`
    - Define `enum Priority { high, medium, low }` with a `PriorityWeight` extension that returns
      `sortWeight` as `int` (high→2, medium→1, low→0).
    - _Requirements: 5.1, 5.2 / Design: Data Models — Priority Enum_
  - [x] 1.2 Create `lib/features/todo/domain/entities/task_status.dart`
    - Define `enum TaskStatus { pending, completed }`.
    - _Requirements: 4.1, 4.2 / Design: Data Models — TaskStatus Enum_

- [x] 2. Define `Task` domain entity
  - [x] 2.1 Create `lib/features/todo/domain/entities/task.dart`
    - Immutable class with `const` constructor: `id`, `title`, `description?`, `priority`,
      `status`, `categoryId?`, `createdAt`, `completedAt?`.
    - All fields `final`. No Isar annotations.
    - _Requirements: 1.1, 1.2, 1.3 / Design: Data Models — Domain Entities_

- [x] 3. Define `Category` domain entity
  - [x] 3.1 Create `lib/features/todo/domain/entities/category.dart`
    - Immutable class with `const` constructor: `id`, `name`. All fields `final`.
    - _Requirements: 6.1, 7.1 / Design: Data Models — Domain Entities_

- [x] 4. Define `TaskRepository` abstract interface
  - [x] 4.1 Create `lib/features/todo/domain/repositories/task_repository.dart`
    - Abstract interface with `getAll()`, `findById(int id)`, `create(Task)`, `update(Task)`,
      `delete(int id)` — signatures exactly as in the design.
    - _Requirements: 1.1, 2.1, 3.2, 4.1 / Design: Repository Interfaces_

- [x] 5. Define `CategoryRepository` abstract interface
  - [x] 5.1 Create `lib/features/todo/domain/repositories/category_repository.dart`
    - Abstract interface with `getAll()`, `count()`, `create(Category)`, `update(Category)`,
      `delete(int id)`.
    - _Requirements: 6.1, 7.1, 8.2, 9.1 / Design: Repository Interfaces_

- [x] 6. Define `SortCriterion` and `SortDirection` enums
  - [x] 6.1 Create `lib/features/todo/domain/entities/sort_criterion.dart` and
      `lib/features/todo/domain/entities/sort_direction.dart`
    - `enum SortCriterion { creationDate, priority, alphabetical }`
    - `enum SortDirection { ascending, descending }`
    - _Requirements: 12.1, 12.2 / Design: State Management — State Shape_

- [x] 7. Create `ValidationException` and `NotFoundException` typed errors
  - [x] 7.1 Create `lib/features/todo/domain/exceptions/validation_exception.dart` and
      `lib/features/todo/domain/exceptions/not_found_exception.dart`
    - `ValidationException` carries a `String message` field.
    - `NotFoundException` carries `String message` and `int id` fields.
    - Both extend `Exception`.
    - _Requirements: 1.4, 2.2, 6.2, 7.2 / Design: Error Handling_

---

### Group 2 — Use Cases

- [x] 8. Implement `CreateTaskUseCase`
  - [x] 8.1 Create `lib/features/todo/domain/use_cases/create_task_use_case.dart`
    - Constructor-injected `TaskRepository`. Single `call({required String title, required Priority
      priority, String? description, int? categoryId})` method.
    - Validate `title.trim()` non-empty; throw `ValidationException` otherwise.
    - Set `status = pending`, `completedAt = null`, `createdAt = DateTime.now()`, `id = 0`
      (Isar auto-assign).
    - Delegate to `taskRepository.create(task)` and return the persisted entity.
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6 / Design: Use Cases_

- [x] 9. Implement `EditTaskUseCase`
  - [x] 9.1 Create `lib/features/todo/domain/use_cases/edit_task_use_case.dart`
    - Validate non-empty title; throw `ValidationException` otherwise.
    - Fetch existing task via `findById`; throw `NotFoundException` if absent.
    - Preserve `createdAt`, `status`, `completedAt` from the fetched entity.
    - Delegate to `taskRepository.update(updatedTask)` and return result.
    - _Requirements: 2.1, 2.2, 2.3, 2.4 / Design: Use Cases — Validation_

- [x] 10. Implement `DeleteTaskUseCase`
  - [x] 10.1 Create `lib/features/todo/domain/use_cases/delete_task_use_case.dart`
    - Single `call(int id)` → `taskRepository.delete(id)`. No-op if not found (idempotent).
    - _Requirements: 3.2 / Design: Use Cases_

- [x] 11. Implement `CompleteTaskUseCase`
  - [x] 11.1 Create `lib/features/todo/domain/use_cases/complete_task_use_case.dart`
    - Fetch task; throw `NotFoundException` if absent.
    - Set `status = completed`, `completedAt = DateTime.now()`.
    - Delegate to `taskRepository.update(task)` and return result.
    - _Requirements: 4.1 / Design: Use Cases_

- [x] 12. Implement `ReopenTaskUseCase`
  - [x] 12.1 Create `lib/features/todo/domain/use_cases/reopen_task_use_case.dart`
    - Fetch task; throw `NotFoundException` if absent.
    - Set `status = pending`, `completedAt = null`.
    - Delegate to `taskRepository.update(task)` and return result.
    - _Requirements: 4.2 / Design: Use Cases_

- [x] 13. Implement `GetAllTasksUseCase`
  - [x] 13.1 Create `lib/features/todo/domain/use_cases/get_all_tasks_use_case.dart`
    - Single `call()` → `taskRepository.getAll()`.
    - _Requirements: 10.2, 11.5 / Design: Use Cases_

- [x] 14. Implement `CreateCategoryUseCase`
  - [x] 14.1 Create `lib/features/todo/domain/use_cases/create_category_use_case.dart`
    - Validate `name.trim()` non-empty; throw `ValidationException` otherwise.
    - Delegate to `categoryRepository.create(category)` and return result.
    - _Requirements: 6.1, 6.2 / Design: Use Cases_

- [x] 15. Implement `RenameCategoryUseCase`
  - [x] 15.1 Create `lib/features/todo/domain/use_cases/rename_category_use_case.dart`
    - Validate non-empty name; throw `ValidationException` otherwise.
    - Fetch existing category; throw `NotFoundException` if absent.
    - Preserve `id`; delegate to `categoryRepository.update(category)` and return result.
    - _Requirements: 7.1, 7.2, 7.3 / Design: Use Cases_

- [x] 16. Implement `DeleteCategoryUseCase`
  - [x] 16.1 Create `lib/features/todo/domain/use_cases/delete_category_use_case.dart`
    - Constructor-injected `CategoryRepository` only (no `TaskRepository` needed).
    - Single `call(int id)` method delegates entirely to
      `categoryRepository.deleteWithTaskUnassign(id)`.
    - Atomicity is the responsibility of the repository contract, not the use case.
    - _Requirements: 8.2, 8.4, 8.5 / Design: Use Cases — DeleteCategoryUseCase_

- [x] 17. Implement `GetAllCategoriesUseCase`
  - [x] 17.1 Create `lib/features/todo/domain/use_cases/get_all_categories_use_case.dart`
    - Single `call()` → `categoryRepository.getAll()`.
    - _Requirements: 6.3, 9.1 / Design: Use Cases_

- [x] 18. Implement `SeedDefaultCategoriesUseCase`
  - [x] 18.1 Create `lib/features/todo/domain/use_cases/seed_default_categories_use_case.dart`
    - Guard: `if (await categoryRepository.count() == 0)` create `Trabajo`, `Estudio`, `Hogar`,
      `Personal` in that order.
    - _Requirements: 9.1, 9.2, 9.4 / Design: Use Cases — SeedDefaultCategoriesUseCase_

---

### Group 3 — Data Layer

- [x] 19. Define `TaskModel` Isar collection
  - [x] 19.1 Create `lib/features/todo/data/models/task_model.dart`
    - `@collection` class with all fields from the design table: `id`, `title`, `description?`,
      `priorityIndex`, `statusIndex`, `categoryId?`, `createdAt`, `completedAt?`.
    - Add all five `@Index` annotations as specified in the design.
    - Add `Task toEntity()` and `static TaskModel fromEntity(Task)` conversion methods.
    - _Requirements: 13.1 / Design: Data Models — TaskModel_

- [x] 20. Define `CategoryModel` Isar collection
  - [x] 20.1 Create `lib/features/todo/data/models/category_model.dart`
    - `@collection` class with `id` and `name`.
    - Unique hash index on `name`.
    - Add `Category toEntity()` and `static CategoryModel fromEntity(Category)` methods.
    - _Requirements: 13.2 / Design: Data Models — CategoryModel_

- [x] 21. Implement `IsarTaskRepository`
  - [x] 21.1 Create `lib/features/todo/data/repositories/isar_task_repository.dart`
    - Implements `TaskRepository`. Constructor-injected `Isar` instance.
    - `getAll()`: reads all `TaskModel` records, maps to entities.
    - `findById(id)`: returns entity or null.
    - `create(task)`: writes in `writeTxn`, returns entity with assigned id.
    - `update(task)`: fetch existing, throw `NotFoundException` if missing, write, return entity.
    - `delete(id)`: `writeTxn` delete; no-op if not found.
    - No `bulkUpdate` method — removed from the interface.
    - _Requirements: 13.1, 13.3 / Design: Data Layer_

- [x] 22. Implement `IsarCategoryRepository`
  - [x] 22.1 Create `lib/features/todo/data/repositories/isar_category_repository.dart`
    - Implements `CategoryRepository`. Constructor-injected `Isar` instance.
    - `getAll()`, `count()`, `create()`, `update()`, `delete()` following the same patterns as
      `IsarTaskRepository`.
    - `deleteWithTaskUnassign(categoryId)`: inside a single `isar.writeTxn()`, set
      `categoryId = null` on all `TaskModel` records where `categoryId == categoryId`,
      then delete the `CategoryModel` record. Atomicity guaranteed by the transaction boundary.
    - _Requirements: 8.2, 8.4, 8.5, 13.2, 13.3 / Design: Data Layer_

- [ ] 23. Isar database initialization in `core/database/`
  - [ ] 23.1 Create `lib/core/database/isar_database.dart`
    - `Future<Isar> openIsar()` function that calls `Isar.open(schemas: [...], ...)` with
      `TaskModelSchema` and `CategoryModelSchema`. Returns the opened instance.
    - _Requirements: 13.1, 13.2 / Design: Architecture — Dependency Rules_

- [ ] 24. Wire `SeedDefaultCategoriesUseCase` in `main.dart`
  - [ ] 24.1 Update `lib/main.dart`
    - Call `WidgetsFlutterBinding.ensureInitialized()`, `await openIsar()`, then
      `await SeedDefaultCategoriesUseCase(categoryRepository: IsarCategoryRepository(isar)).call()`,
      then `runApp(FocusFlowApp(isar: isar))`.
    - Pass `isar` down so repositories can be instantiated at the route level.
    - _Requirements: 9.1 / Design: Default Categories Initialization_

---

### Group 4 — State Management

- [ ] 25. Implement `TodoController` with full state shape
  - [ ] 25.1 Create `lib/features/todo/presentation/controllers/todo_controller.dart`
    - `extends ChangeNotifier`. Constructor-injected use cases for all 11 operations.
    - Declare all state fields from the design: `_allTasks`, `_allCategories`, `_searchQuery`,
      `_statusFilter`, `_priorityFilter`, `_categoryFilter`, `_sortCriterion`, `_sortDirection`,
      `_displayedTasks`, `_isLoading`, `_errorMessage`.
    - Expose all public getters including `hasActiveFilters`.
    - `init()` method (called post-construction) loads tasks and categories, then calls
      `_applyPipeline()`.
    - _Requirements: 1.7, 2.5, 3.4, 4.3, 6.3, 7.4, 8.6 / Design: State Management_

- [ ] 26. Implement `_applyPipeline()` inside `TodoController`
  - [ ] 26.1 Implement the search → filter → sort pipeline in `todo_controller.dart`
    - `_applyPipeline()`: synchronous in-memory:
      1. Search: `title` or `description` case-insensitive contains.
      2. Filter: AND of `statusFilter`, `priorityFilter`, `categoryFilter` (sentinel `-1` for
         Uncategorized, `null` for All).
      3. Sort: comparator with primary criterion + tie-breaker `createdAt` descending.
    - Called by every setter and after every mutating operation.
    - _Requirements: 10.1, 10.4, 10.5, 11.4, 11.9, 12.1–12.9 / Design: Search Filter Sort_

- [ ] 27. Wire all mutating operations through `TodoController`
  - [ ] 27.1 Add task mutation methods to `TodoController`
    - `createTask(...)`, `editTask(...)`, `deleteTask(int id)`, `completeTask(int id)`,
      `reopenTask(int id)`: each sets `_isLoading`, invokes use case, reloads `_allTasks`,
      calls `_applyPipeline()`, clears `_isLoading`, catches exceptions to `_errorMessage`.
    - _Requirements: 1.7, 2.5, 3.4, 4.3 / Design: State Management — Controller Responsibilities_
  - [ ] 27.2 Add category mutation methods to `TodoController`
    - `createCategory(String name)`, `renameCategory(int id, String name)`,
      `deleteCategory(int id)`: same loading/error pattern, reload `_allCategories` after each.
    - _Requirements: 6.3, 7.4, 8.6 / Design: State Management — Controller Responsibilities_
  - [ ] 27.3 Add filter/sort setter methods to `TodoController`
    - `setSearchQuery`, `setStatusFilter`, `setPriorityFilter`, `setCategoryFilter`,
      `setSortCriterion`, `setSortDirection`, `clearAllFilters` — each calls `_applyPipeline()`
      before `notifyListeners()`.
    - _Requirements: 10.4, 11.9, 11.11, 12.9 / Design: State Management — Reactivity_

---

### Group 5 — Shared Widget

- [ ] 28. Implement `ConfirmationDialog`
  - [ ] 28.1 Create `lib/shared/widgets/confirmation_dialog.dart`
    - Stateless widget. Parameters: `title`, `message`, `confirmLabel`, `cancelLabel`,
      `onConfirm`.
    - Uses `showDialog` with `AlertDialog` (Material 3). Cancel = `TextButton`, confirm =
      `FilledButton.tonal`. Pops on cancel; fires `onConfirm` and pops on confirm.
    - _Requirements: 3.1, 8.1 / Design: Component Breakdown — ConfirmationDialog_

---

### Group 6 — Presentation Widgets

- [ ] 29. Implement `EmptyStateWidget` with all 4 variants
  - [ ] 29.1 Create `lib/features/todo/presentation/widgets/empty_state_widget.dart`
    - `enum EmptyStateVariant { noTasks, noSearchResults, noFilterResults, noCategoryTasks }`
    - Centered column: illustrative icon + headline + supporting message + optional
      `OutlinedButton` CTA (only for `noTasks` variant). All text ≥ 12sp. Uses `Theme.of(context)`.
    - _Requirements: 14.1, 14.2, 14.3, 14.4 / Design: Component Breakdown — EmptyStateWidget_

- [ ] 30. Implement `TaskCard`
  - [ ] 30.1 Create `lib/features/todo/presentation/widgets/task_card.dart`
    - Material 3 `Card`. Leading: `Checkbox` bound to `task.status`.
    - Body: title + optional description (1-line overflow ellipsis).
    - Trailing: priority chip (icon + text label, not color-only, min 48×48dp), optional category
      label, delete `IconButton` with `Semantics` label.
    - Tapping the card body fires `onEdit`. All interactive targets ≥ 48×48dp.
    - _Requirements: 4.4, 5.1, 15.1, 15.3, 15.4 / Design: Component Breakdown — TaskCard_

- [ ] 31. Implement `TaskListWidget`
  - [ ] 31.1 Create `lib/features/todo/presentation/widgets/task_list_widget.dart`
    - Accepts `List<Task> tasks`, `List<Category> categories`, and the four callbacks:
      `onComplete`, `onReopen`, `onEdit`, `onDelete`.
    - Uses `ListView.builder`. Resolves `categoryName` by matching `task.categoryId` against
      `categories`. Shows `EmptyStateWidget` when list is empty.
    - _Requirements: 1.7, 2.5, 3.4, 4.3 / Design: Component Breakdown — TaskListWidget_

- [ ] 32. Implement `SearchBarWidget`
  - [ ] 32.1 Create `lib/features/todo/presentation/widgets/search_bar_widget.dart`
    - Material 3 `TextField` (or `SearchBar`) with a clear suffix icon.
    - Parameters: `initialQuery`, `onChanged`, `onClear`. Fires `onChanged` on every keystroke.
    - `Semantics` label on the clear button.
    - _Requirements: 10.1, 10.4, 10.5, 15.1 / Design: Component Breakdown — SearchBarWidget_

- [ ] 33. Implement `FilterBar`
  - [ ] 33.1 Create `lib/features/todo/presentation/widgets/filter_bar.dart`
    - Horizontally scrollable row of `FilterChip` widgets for status, priority, category.
    - When `hasActiveFilters` is true, append a "Clear all" chip/button.
    - Parameters: current filter values, all categories list, individual filter-change callbacks,
      `onClearAll`.
    - _Requirements: 11.1, 11.2, 11.3, 11.9, 11.10, 11.11 / Design: Component Breakdown — FilterBar_

- [ ] 34. Implement `SortControl`
  - [ ] 34.1 Create `lib/features/todo/presentation/widgets/sort_control.dart`
    - Compact row: `DropdownButton<SortCriterion>` + direction toggle `IconButton` (arrow icon).
    - `Semantics` label on the direction toggle. Parameters: `activeCriterion`, `activeDirection`,
      change callbacks.
    - _Requirements: 12.1, 12.2, 12.9, 15.1 / Design: Component Breakdown — SortControl_

---

### Group 7 — Screens

- [ ] 35. Implement `TaskFormScreen` — create mode
  - [ ] 35.1 Create `lib/features/todo/presentation/screens/task_form_screen.dart` (create mode)
    - `Scaffold` with form: `TextFormField` title (autofocus, validates non-empty),
      `TextFormField` description (optional), `DropdownButtonFormField<Priority>` (default
      Medium), `DropdownButtonFormField<int?>` for category (lists all categories + "No category").
    - Submit via `FilledButton`; calls `controller.createTask(...)`, pops on success.
    - Catches `ValidationException` and shows inline field error text.
    - _Requirements: 1.1, 1.4, 1.5, 1.6, 5.2 / Design: Component Breakdown — TaskFormScreen_

- [ ] 36. Implement `TaskFormScreen` — edit mode
  - [ ] 36.1 Extend `task_form_screen.dart` to support edit mode
    - Accept optional `Task? initialTask` parameter. When non-null, pre-populate all fields.
    - Submit calls `controller.editTask(...)`, pops on success.
    - `createdAt`, `status`, `completedAt` are never shown or modified by this form.
    - _Requirements: 2.1, 2.2, 2.3, 2.4 / Design: Component Breakdown — TaskFormScreen_

- [ ] 37. Implement `CategoryManagerScreen`
  - [ ] 37.1 Create `lib/features/todo/presentation/screens/category_manager_screen.dart`
    - `Scaffold` with `ListView` of category rows: name + rename `IconButton` + delete
      `IconButton` (≥ 48×48dp). FAB opens an inline `TextField` or mini-form for new category.
    - Rename taps open a dialog with a pre-filled `TextField`; validates and calls
      `controller.renameCategory(...)`.
    - Delete taps show `ConfirmationDialog`; on confirm calls `controller.deleteCategory(...)`.
    - `Semantics` labels on all icon buttons.
    - _Requirements: 6.1, 6.2, 7.1, 7.2, 8.1, 8.2, 8.3, 15.1 / Design: Component Breakdown_

- [ ] 38. Implement `TodoScreen` — orchestrate all widgets, FAB, navigation
  - [ ] 38.1 Create `lib/features/todo/presentation/screens/todo_screen.dart`
    - Registers `TodoController` via `ChangeNotifierProvider` at route level, calls
      `controller.init()` in `initState` (or `didChangeDependencies`).
    - `AppBar`: title + categories action icon.
    - Body (below AppBar): `SearchBarWidget` → `FilterBar` → `SortControl` → `TaskListWidget`
      (or `EmptyStateWidget` per variant).
    - FAB triggers navigation to `TaskFormScreen` (create mode).
    - `TaskListWidget` callbacks: complete/reopen call controller; edit navigates to
      `TaskFormScreen` (edit mode); delete shows `ConfirmationDialog`.
    - Observes `controller.errorMessage` via `ListenableBuilder` and shows `SnackBar` with
      retry action.
    - Observes successful mutations and shows transient `SnackBar` confirmation.
    - _Requirements: 1.7, 2.5, 3.4, 4.3, 11.10, 14.5, 14.6, 14.7 / Design: Component Breakdown — TodoScreen_

- [ ] 39. Register Todo routes in `app/router.dart`
  - [ ] 39.1 Update `lib/app/router.dart`
    - Add routes: `/todo` → `TodoScreen`, `/todo/task/new` → `TaskFormScreen` (create),
      `/todo/task/:id/edit` → `TaskFormScreen` (edit, pass task via extra or query),
      `/todo/categories` → `CategoryManagerScreen`.
    - _Requirements: 1.1, 2.1, 6.1, 8.1 / Design: Architecture — Navigation_

- [ ] 40. Checkpoint — domain + data + state layers complete
  - Ensure all unit tests and integration tests for Groups 1–4 pass. Verify `TodoScreen` renders
    with real Isar data on a device or emulator. Ask the user if questions arise.

---

### Group 8 — Unit Tests (Use Cases)

- [ ] 41. Unit tests for `CreateTaskUseCase`
  - [ ]* 41.1 Write unit tests for `CreateTaskUseCase`
    - Fake `TaskRepository` in-memory implementation.
    - Happy path: returned task matches input, `status = pending`, `completedAt = null`.
    - Empty title → `ValidationException`.
    - Whitespace-only title → `ValidationException`.
    - _Requirements: 1.1, 1.3, 1.4 / Design: Testing Strategy — Unit Tests_

- [ ] 42. Unit tests for `EditTaskUseCase`
  - [ ]* 42.1 Write unit tests for `EditTaskUseCase`
    - Happy path: updated fields reflect input; `createdAt`, `status`, `completedAt` preserved.
    - Whitespace-only title → `ValidationException`.
    - Unknown id → `NotFoundException`.
    - _Requirements: 2.1, 2.2, 2.3, 2.4 / Design: Testing Strategy_

- [ ] 43. Unit tests for `DeleteTaskUseCase`
  - [ ]* 43.1 Write unit tests for `DeleteTaskUseCase`
    - Happy path: task no longer in fake repository after delete.
    - Deleting unknown id: no exception (idempotent).
    - _Requirements: 3.2 / Design: Testing Strategy_

- [ ] 44. Unit tests for `CompleteTaskUseCase` and `ReopenTaskUseCase`
  - [ ]* 44.1 Write unit tests for `CompleteTaskUseCase` and `ReopenTaskUseCase`
    - Complete: `status = completed`, `completedAt != null`.
    - Reopen: `status = pending`, `completedAt == null`.
    - Complete/Reopen on unknown id → `NotFoundException`.
    - _Requirements: 4.1, 4.2 / Design: Testing Strategy_

- [ ] 45. Unit tests for `CreateCategoryUseCase` and `RenameCategoryUseCase`
  - [ ]* 45.1 Write unit tests for `CreateCategoryUseCase` and `RenameCategoryUseCase`
    - Create: returned category has provided name; empty/whitespace → `ValidationException`.
    - Rename: id preserved, name updated; empty name → `ValidationException`; unknown id →
      `NotFoundException`.
    - _Requirements: 6.1, 6.2, 7.1, 7.2, 7.3 / Design: Testing Strategy_

- [ ] 46. Unit tests for `DeleteCategoryUseCase` (cascade null)
  - [ ]* 46.1 Write unit tests for `DeleteCategoryUseCase`
    - All tasks with `categoryId == deletedId` have `categoryId = null` after use case call.
    - Tasks themselves still exist in fake task repository.
    - Category no longer retrievable from fake category repository.
    - _Requirements: 8.2, 8.4, 8.5 / Design: Testing Strategy_

- [ ] 47. Unit tests for `SeedDefaultCategoriesUseCase` (guard logic)
  - [ ]* 47.1 Write unit tests for `SeedDefaultCategoriesUseCase`
    - Fresh repo (count == 0): four categories created with correct names.
    - Non-empty repo (count ≥ 1): no categories created.
    - _Requirements: 9.1, 9.2 / Design: Testing Strategy_

- [ ] 48. Unit tests for the search pipeline step
  - [ ]* 48.1 Write unit tests for `_applyPipeline` search step (extract to a testable function)
    - Non-empty query: only tasks whose title or description contains query (case-insensitive).
    - Empty query: all tasks pass through.
    - _Requirements: 10.1, 10.2 / Design: Testing Strategy_

- [ ] 49. Unit tests for the filter pipeline step
  - [ ]* 49.1 Write unit tests for `_applyPipeline` filter step
    - Status filter: only matching-status tasks; All passes all.
    - Priority filter: only matching-priority tasks; All passes all.
    - Category filter: specific id, `-1` (Uncategorized), null (All).
    - Multi-filter AND conjunction.
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8 / Design: Testing Strategy_

- [ ] 50. Unit tests for the sort pipeline step with tie-breaking
  - [ ]* 50.1 Write unit tests for `_applyPipeline` sort step
    - Each criterion ascending and descending produces correct ordering.
    - Priority descending: High → Medium → Low.
    - Tie-breaking: equal primary criterion → `createdAt` descending.
    - _Requirements: 12.1, 12.2, 12.4, 12.5, 12.6, 12.7, 12.8 / Design: Testing Strategy_

---

### Group 9 — Property-Based Tests

All property tests use `dart_fast_check`. Each runs a minimum of 100 iterations. In-memory fake
repositories only — no Isar required.

- [ ] 51. Property-based tests for Properties 1–3
  - [ ]* 51.1 Property 1: Task creation round-trip preserves all input fields
    - // Feature: todo, Property 1: Task creation round-trip preserves all input fields
    - Arbitrary: non-whitespace title, any `Priority`, optional description, optional `int?` categoryId.
    - Assert returned task fields match inputs exactly.
    - **Validates: Requirement 1.1**
  - [ ]* 51.2 Property 2: Newly created tasks are always Pending with no completion timestamp
    - // Feature: todo, Property 2: Newly created tasks are always Pending with no completion timestamp
    - Arbitrary: same generators as Property 1.
    - Assert `status == pending && completedAt == null`.
    - **Validates: Requirement 1.3**
  - [ ]* 51.3 Property 3: Whitespace-only titles are always rejected
    - // Feature: todo, Property 3: Whitespace-only titles are always rejected
    - Arbitrary: strings composed entirely of `\s` characters.
    - Assert `CreateTaskUseCase` and `EditTaskUseCase` both throw `ValidationException`.
    - **Validates: Requirements 1.4, 2.2**

- [ ] 52. Property-based tests for Properties 4–6
  - [ ]* 52.1 Property 4: Task edit preserves immutable fields
    - // Feature: todo, Property 4: Task edit preserves immutable fields
    - Arbitrary: existing task + valid edit input (new title, priority, description, categoryId).
    - Assert `createdAt`, `status`, `completedAt` are identical to pre-edit values.
    - **Validates: Requirements 2.3, 2.4**
  - [ ]* 52.2 Property 5: Complete → Reopen is a status round-trip
    - // Feature: todo, Property 5: Complete → Reopen is a status round-trip
    - Arbitrary: any pending task.
    - After `CompleteTaskUseCase`: `status == completed && completedAt != null`.
    - After `ReopenTaskUseCase`: `status == pending && completedAt == null`.
    - **Validates: Requirements 4.1, 4.2**
  - [ ]* 52.3 Property 6: Deleted task is no longer retrievable
    - // Feature: todo, Property 6: Deleted task is no longer retrievable
    - Arbitrary: any existing task.
    - After `DeleteTaskUseCase`: `findById(id) == null` and task absent from `getAll()`.
    - **Validates: Requirement 3.2**

- [ ] 53. Property-based tests for Properties 7–9
  - [ ]* 53.1 Property 7: Category rename preserves ID and all task associations
    - // Feature: todo, Property 7: Category rename preserves ID and all task associations
    - Arbitrary: any category + valid new name + any tasks referencing that category.
    - Assert renamed category has same `id`. Assert task `categoryId` values unchanged.
    - **Validates: Requirements 7.1, 7.3**
  - [ ]* 53.2 Property 8: Category deletion nullifies all associated task references
    - // Feature: todo, Property 8: Category deletion nullifies task references without deleting tasks
    - Arbitrary: any category + any set of tasks referencing it.
    - After `DeleteCategoryUseCase`: tasks still exist, `categoryId == null`; category absent.
    - **Validates: Requirements 8.2, 8.4, 8.5**
  - [ ]* 53.3 Property 9: Default category seeding is a no-op when categories already exist
    - // Feature: todo, Property 9: Default category seeding is a no-op when categories already exist
    - Arbitrary: non-empty category collection (count ≥ 1).
    - After `SeedDefaultCategoriesUseCase`: count and contents unchanged.
    - **Validates: Requirements 9.2, 9.4**

- [ ] 54. Property-based tests for Properties 10–12
  - [ ]* 54.1 Property 10: Search returns exactly matching tasks (case-insensitive)
    - // Feature: todo, Property 10: Search returns exactly the tasks that contain the query
    - Arbitrary: non-empty query string + list of tasks.
    - Assert pipeline search step returns exactly tasks satisfying the contains predicate.
    - **Validates: Requirement 10.1**
  - [ ]* 54.2 Property 11: Multi-filter conjunction
    - // Feature: todo, Property 11: Multi-filter conjunction — only tasks satisfying all filters
    - Arbitrary: any combination of status/priority/category filter values + any task list.
    - Assert result equals tasks satisfying all active predicates simultaneously.
    - **Validates: Requirement 11.4**
  - [ ]* 54.3 Property 12: Sort produces stable ordering with correct tie-breaking
    - // Feature: todo, Property 12: Sort produces stable ordering with correct tie-breaking
    - Arbitrary: any task list, any `SortCriterion`, any `SortDirection`.
    - Assert adjacent pairs satisfy the comparator; equal-primary pairs ordered by `createdAt desc`.
    - **Validates: Requirements 12.1, 12.2, 12.4–12.8**

- [ ] 55. Property-based test for Property 13
  - [ ]* 55.1 Property 13: Persistence round-trip — written data fully recovered on read
    - // Feature: todo, Property 13: Persistence round-trip
    - Arbitrary: any `Task` or `Category` object.
    - Written via repository, read back by id: all field values equal originals.
    - Uses in-memory fake repositories (no Isar in unit scope).
    - **Validates: Requirements 13.1, 13.2, 13.3**

---

### Group 10 — Widget Tests

- [ ] 56. Widget tests for `TaskFormScreen`
  - [ ]* 56.1 Widget test: `TaskFormScreen` — valid submit creates task
    - Pump `TaskFormScreen` with mock `TodoController`. Enter valid title, tap submit.
    - Assert `controller.createTask(...)` was called.
    - _Requirements: 1.1 / Design: Testing Strategy — Widget Tests_
  - [ ]* 56.2 Widget test: `TaskFormScreen` — empty title shows validation error
    - Leave title empty, tap submit. Assert validation error text visible on title field.
    - _Requirements: 1.4 / Design: Testing Strategy_

- [ ] 57. Widget tests for `TaskCard`
  - [ ]* 57.1 Widget test: `TaskCard` — checkbox tap toggles status
    - Pump `TaskCard` with a pending task. Tap the `Checkbox`. Assert `onToggleStatus` callback
      fired.
    - _Requirements: 4.4 / Design: Testing Strategy_
  - [ ]* 57.2 Widget test: `TaskCard` — delete tap shows `ConfirmationDialog`
    - Tap the delete `IconButton`. Assert `ConfirmationDialog` is present in the widget tree.
    - _Requirements: 3.1 / Design: Testing Strategy_

- [ ] 58. Widget tests for `ConfirmationDialog`
  - [ ]* 58.1 Widget test: `ConfirmationDialog` — confirm fires callback; cancel does not
    - Pump dialog. Tap confirm button: assert `onConfirm` fired. Pump again, tap cancel: assert
      `onConfirm` not fired and dialog dismissed.
    - _Requirements: 3.1, 8.1 / Design: Testing Strategy_

- [ ] 59. Widget tests for `EmptyStateWidget` and `FilterBar`
  - [ ]* 59.1 Widget test: `EmptyStateWidget` — correct variant displayed per state
    - Pump widget for each of the four `EmptyStateVariant` values. Assert correct headline text
      and presence/absence of CTA button.
    - _Requirements: 14.1, 14.2, 14.3, 14.4 / Design: Testing Strategy_
  - [ ]* 59.2 Widget test: `FilterBar` — clear all resets filters
    - Pump `FilterBar` with active status and priority filters. Tap "Clear all" chip. Assert
      `onClearAll` callback fired.
    - _Requirements: 11.11 / Design: Testing Strategy_

---

### Group 11 — Integration Tests

- [ ] 60. Integration tests for Isar round-trip
  - [ ]* 60.1 Integration test: Isar round-trip for `TaskModel` and `CategoryModel`
    - Open real Isar in a temporary directory. Write a `TaskModel` and a `CategoryModel`. Read
      back by id. Assert all fields equal to written values.
    - _Requirements: 13.1, 13.2, 13.3 / Design: Testing Strategy — Integration Tests_

- [ ] 61. Integration test for `SeedDefaultCategoriesUseCase` end-to-end
  - [ ]* 61.1 Integration test: fresh DB → 4 categories; second run → no change
    - Open real Isar (temp dir). Run use case: assert 4 categories with correct names.
    - Run use case again: assert count still 4 and names unchanged.
    - _Requirements: 9.1, 9.2, 9.4 / Design: Testing Strategy — Integration Tests_

- [ ] 62. Final checkpoint — all tests pass
  - Run `flutter test`. Ensure all unit, property-based, widget, and integration tests pass.
    Ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP build; all test sub-tasks
  fall in this category.
- Each task references specific requirements and design sections for full traceability.
- The implementation language is **Dart / Flutter** throughout.
- Property tests use `dart_fast_check` (confirm latest pub.dev version before implementing).
- Widget tests use a mock or fake `TodoController` — no Isar required in the widget test scope.
- Integration tests (Group 11) require a real Isar instance opened in a temporary directory.
- The `ConfirmationDialog` lives in `shared/widgets/` for reuse across other features.
- Checkpoints at tasks 40 and 62 are natural review gates before proceeding to the next group.

---

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["2.1", "3.1", "6.1", "7.1"] },
    { "id": 2, "tasks": ["4.1", "5.1"] },
    { "id": 3, "tasks": ["8.1", "9.1", "10.1", "11.1", "12.1", "13.1", "14.1", "15.1", "16.1", "17.1", "18.1"] },
    { "id": 4, "tasks": ["19.1", "20.1"] },
    { "id": 5, "tasks": ["21.1", "22.1"] },
    { "id": 6, "tasks": ["23.1"] },
    { "id": 7, "tasks": ["24.1"] },
    { "id": 8, "tasks": ["25.1"] },
    { "id": 9, "tasks": ["26.1"] },
    { "id": 10, "tasks": ["27.1", "27.2", "27.3"] },
    { "id": 11, "tasks": ["28.1"] },
    { "id": 12, "tasks": ["29.1", "30.1", "31.1", "32.1", "33.1", "34.1"] },
    { "id": 13, "tasks": ["35.1", "36.1", "37.1"] },
    { "id": 14, "tasks": ["38.1"] },
    { "id": 15, "tasks": ["39.1"] },
    { "id": 16, "tasks": ["41.1", "42.1", "43.1", "44.1", "45.1", "46.1", "47.1"] },
    { "id": 17, "tasks": ["48.1", "49.1", "50.1"] },
    { "id": 18, "tasks": ["51.1", "51.2", "51.3", "52.1", "52.2", "52.3", "53.1", "53.2", "53.3"] },
    { "id": 19, "tasks": ["54.1", "54.2", "54.3", "55.1"] },
    { "id": 20, "tasks": ["56.1", "56.2", "57.1", "57.2", "58.1", "59.1", "59.2"] },
    { "id": 21, "tasks": ["60.1", "61.1"] }
  ]
}
```

### Dependency narrative

```
Group 1 (Domain enums + entities) → Group 2 (Use Cases) → Group 3 (Data Layer)
Group 2 (Use Cases) → Group 4 (State Management)
Group 3 (Data Layer) → Group 4 (State Management)
Group 4 (State Management) → Groups 5–7 (Shared Widget + Presentation)
Groups 5–7 (Presentation) → Groups 8–11 (Tests)
```
