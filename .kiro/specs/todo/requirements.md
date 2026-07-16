# Requirements Document

## Introduction

The Todo feature is one of the three core pillars of Focus Flow. It enables users to quickly capture, organize, search, and manage their daily tasks in a simple, intuitive, and fully offline experience. Tasks can be assigned a priority, an optional category, and an optional description. Categories group tasks and will support future productivity statistics. Search, filtering, and sorting operate together on local data. This specification covers the Todo feature exclusively; integration with Pomodoro and Statistics is out of scope.

## Glossary

- **Task**: The primary unit of work. It has a mandatory title, an optional description, a priority, a status, creation and completion timestamps, and an optional reference to a Category.
- **Category**: A named grouping that can be assigned to tasks. Categories have a stable unique identifier that never changes, even when the category is renamed.
- **Priority**: An ordered value assigned to a Task. Valid values are: `High`, `Medium`, `Low`.
- **Status**: The lifecycle state of a Task. Valid values are: `Pending`, `Completed`.
- **Uncategorized**: The state of a Task whose category reference is null (no category has been assigned, or its previously assigned category was deleted).
- **Default Categories**: The four categories (`Trabajo`, `Estudio`, `Hogar`, `Personal`) created automatically on first launch when no categories exist.
- **Task_Manager**: The application subsystem responsible for all task creation, modification, deletion, and status transitions.
- **Category_Manager**: The application subsystem responsible for all category creation, modification, and deletion.
- **Search_Engine**: The application subsystem responsible for filtering the task list by a user-supplied query string.
- **Filter_Engine**: The application subsystem responsible for filtering the task list by status, priority, and category.
- **Sort_Engine**: The application subsystem responsible for ordering the task list according to a user-selected criterion and direction.
- **Todo_Screen**: The primary screen of the Todo feature, displaying the task list and the search, filter, and sort controls.
- **Confirmation_Dialog**: A modal dialog that requires explicit user acknowledgment before a destructive action is executed.

---

## Requirements

### Requirement 1: Create a Task

**User Story:** As a user, I want to create a new task with a title, so that I can capture something I need to do.

#### Acceptance Criteria

1. WHEN the user submits the task creation form, THE Task_Manager SHALL create a new Task with the provided title, the provided priority, the provided optional description, and the provided optional category.
2. WHEN a new Task is created, THE Task_Manager SHALL automatically record the creation timestamp as the current device date and time.
3. WHEN a new Task is created, THE Task_Manager SHALL set its status to `Pending` and leave its completion timestamp empty.
4. IF the user submits the task creation form with an empty or whitespace-only title, THEN THE Task_Manager SHALL reject the submission and display a validation error on the title field.
5. THE Task_Manager SHALL allow the description field to be left empty when creating a Task.
6. THE Task_Manager SHALL allow the category field to be left unset when creating a Task.
7. WHEN a new Task is created, THE Todo_Screen SHALL display the new Task in the task list without requiring a manual refresh.

---

### Requirement 2: Edit a Task

**User Story:** As a user, I want to edit an existing task, so that I can correct or update its information.

#### Acceptance Criteria

1. WHEN the user submits the task edit form, THE Task_Manager SHALL update the Task's title, description, priority, and category with the provided values.
2. IF the user submits the task edit form with an empty or whitespace-only title, THEN THE Task_Manager SHALL reject the submission and display a validation error on the title field.
3. WHEN a Task is edited, THE Task_Manager SHALL preserve the original creation timestamp unchanged.
4. WHEN a Task is edited, THE Task_Manager SHALL preserve the current status and completion timestamp unchanged.
5. WHEN a Task is successfully edited, THE Todo_Screen SHALL reflect the updated values immediately without requiring a manual refresh.

---

### Requirement 3: Delete a Task

**User Story:** As a user, I want to delete a task, so that I can remove items I no longer need.

#### Acceptance Criteria

1. WHEN the user initiates task deletion, THE Todo_Screen SHALL display a Confirmation_Dialog before the Task is removed.
2. WHEN the user confirms deletion in the Confirmation_Dialog, THE Task_Manager SHALL permanently remove the Task from storage.
3. WHEN the user cancels deletion in the Confirmation_Dialog, THE Task_Manager SHALL leave the Task unchanged.
4. WHEN a Task is successfully deleted, THE Todo_Screen SHALL remove it from the task list without requiring a manual refresh.

---

### Requirement 4: Complete and Reopen a Task

**User Story:** As a user, I want to mark a task as completed or reopen it as pending, so that I can track which work is done and which is still in progress.

#### Acceptance Criteria

1. WHEN the user marks a `Pending` Task as completed, THE Task_Manager SHALL set its status to `Completed` and record the completion timestamp as the current device date and time.
2. WHEN the user marks a `Completed` Task as pending, THE Task_Manager SHALL set its status to `Pending` and remove its completion timestamp.
3. WHEN a Task's status changes, THE Todo_Screen SHALL reflect the new status immediately without requiring a manual refresh.
4. THE Task_Manager SHALL complete or reopen a Task in a single direct interaction from the task list.

---

### Requirement 5: Task Priority

**User Story:** As a user, I want to assign a priority to each task, so that I can distinguish what needs attention first.

#### Acceptance Criteria

1. THE Task_Manager SHALL require every Task to have a priority value of `High`, `Medium`, or `Low`.
2. WHEN the user creates a Task without explicitly selecting a priority, THE Task_Manager SHALL assign `Medium` as the default priority.
3. WHEN the user edits a Task, THE Task_Manager SHALL allow the priority to be changed to any valid priority value.

---

### Requirement 6: Create a Category

**User Story:** As a user, I want to create custom categories, so that I can organize tasks around my own areas of life.

#### Acceptance Criteria

1. WHEN the user submits the category creation form with a non-empty name, THE Category_Manager SHALL create a new Category with a stable unique identifier and the provided name.
2. IF the user submits the category creation form with an empty or whitespace-only name, THEN THE Category_Manager SHALL reject the submission and display a validation error on the name field.
3. WHEN a new Category is created, THE Todo_Screen SHALL make it available for selection on task creation and edit forms immediately without requiring a manual refresh.

---

### Requirement 7: Rename a Category

**User Story:** As a user, I want to rename a category, so that I can correct its name or adapt it to changing needs.

#### Acceptance Criteria

1. WHEN the user submits the category rename form with a non-empty name, THE Category_Manager SHALL update the Category's display name while preserving its unique identifier unchanged.
2. IF the user submits the category rename form with an empty or whitespace-only name, THEN THE Category_Manager SHALL reject the submission and display a validation error on the name field.
3. WHEN a Category is renamed, THE Task_Manager SHALL preserve all existing Task–Category associations through the Category's unchanged unique identifier.
4. WHEN a Category is renamed, THE Todo_Screen SHALL display the updated name on all Tasks assigned to that Category immediately without requiring a manual refresh.

---

### Requirement 8: Delete a Category

**User Story:** As a user, I want to delete a category I no longer need, so that I can keep the category list clean.

#### Acceptance Criteria

1. WHEN the user initiates category deletion, THE Todo_Screen SHALL display a Confirmation_Dialog before the Category is removed.
2. WHEN the user confirms category deletion, THE Category_Manager SHALL permanently remove the Category from storage.
3. WHEN the user cancels category deletion, THE Category_Manager SHALL leave the Category unchanged.
4. WHEN a Category is deleted, THE Task_Manager SHALL set the category reference of all Tasks previously assigned to that Category to null, making them Uncategorized.
5. WHEN a Category is deleted, THE Task_Manager SHALL not delete any Task.
6. WHEN a Category is deleted, THE Todo_Screen SHALL reflect the updated state of affected Tasks immediately without requiring a manual refresh.

---

### Requirement 9: Default Categories on First Launch

**User Story:** As a new user, I want a set of starter categories to be ready when I first open the app, so that I can start adding tasks right away without manual setup.

#### Acceptance Criteria

1. WHEN the application starts and no categories exist in storage, THE Category_Manager SHALL create the four Default Categories: `Trabajo`, `Estudio`, `Hogar`, and `Personal`.
2. WHEN the application starts and at least one category already exists in storage, THE Category_Manager SHALL not create any Default Categories.
3. THE Category_Manager SHALL treat Default Categories as regular categories: they may be renamed, deleted, or supplemented with user-created categories.
4. WHEN a Default Category has been deleted and the application is restarted, THE Category_Manager SHALL not recreate that deleted Default Category.

---

### Requirement 10: Search Tasks

**User Story:** As a user, I want to search for tasks by typing a query, so that I can quickly find what I am looking for without scrolling through the entire list.

#### Acceptance Criteria

1. WHEN the user types a non-empty query in the search field, THE Search_Engine SHALL update the task list to show only Tasks whose title or description contains the query string, treating letter case as irrelevant.
2. WHEN the search field is empty, THE Search_Engine SHALL apply no search filter and show all Tasks that match the active status, priority, and category filters.
3. WHEN no Tasks match the current search query and active filters, THE Todo_Screen SHALL display a message indicating that no results were found for the current search.
4. THE Search_Engine SHALL update the task list on every keystroke without requiring the user to submit the query.
5. WHEN the user clears the search field, THE Todo_Screen SHALL restore the task list to the state defined by the currently active filters and sort order.
6. WHILE a search query is active, THE Filter_Engine and Sort_Engine SHALL continue to apply their active filter and sort criteria to the search results.

---

### Requirement 11: Filter Tasks

**User Story:** As a user, I want to filter tasks by status, priority, and category, so that I can focus on specific subsets of my task list.

#### Acceptance Criteria

1. THE Filter_Engine SHALL support filtering tasks by Status, accepting the values: `All`, `Pending`, `Completed`.
2. THE Filter_Engine SHALL support filtering tasks by Priority, accepting the values: `High`, `Medium`, `Low`, and `All`.
3. THE Filter_Engine SHALL support filtering tasks by Category, accepting any existing Category identifier, `Uncategorized`, and `All Categories`.
4. WHEN multiple filters are active simultaneously, THE Filter_Engine SHALL return only Tasks that satisfy all active filter criteria.
5. WHEN the Status filter is set to `All`, THE Filter_Engine SHALL include Tasks of any status.
6. WHEN the Priority filter is set to `All`, THE Filter_Engine SHALL include Tasks of any priority.
7. WHEN the Category filter is set to `All Categories`, THE Filter_Engine SHALL include Tasks assigned to any category and Uncategorized Tasks.
8. WHEN the Category filter is set to `Uncategorized`, THE Filter_Engine SHALL return only Tasks whose category reference is null.
9. WHEN the user changes a filter value, THE Todo_Screen SHALL update the task list immediately without requiring a manual refresh.
10. WHEN one or more filters are set to a value other than their default (`All`), THE Todo_Screen SHALL display a visible indicator that active filters are applied.
11. THE Todo_Screen SHALL provide a single control to clear all active filters and reset them to their default values.
12. WHILE a search query is active, THE Filter_Engine SHALL apply the active filters to the search results produced by THE Search_Engine.

---

### Requirement 12: Sort Tasks

**User Story:** As a user, I want to sort my task list by different criteria, so that I can view tasks in the order that is most useful to me.

#### Acceptance Criteria

1. THE Sort_Engine SHALL support sorting tasks by the following criteria: `Creation Date`, `Priority`, `Alphabetical`.
2. THE Sort_Engine SHALL support two sort directions: `Ascending` and `Descending`.
3. WHEN the application first displays the task list and no user sort preference has been set, THE Sort_Engine SHALL sort tasks by `Creation Date` in `Descending` order (most recently created first).
4. WHEN the sort criterion is `Priority` in `Descending` order, THE Sort_Engine SHALL order tasks as `High` before `Medium` before `Low`.
5. WHEN the sort criterion is `Priority` in `Ascending` order, THE Sort_Engine SHALL order tasks as `Low` before `Medium` before `High`.
6. WHEN the sort criterion is `Alphabetical` in `Ascending` order, THE Sort_Engine SHALL order tasks from A to Z by title.
7. WHEN the sort criterion is `Alphabetical` in `Descending` order, THE Sort_Engine SHALL order tasks from Z to A by title.
8. WHEN two Tasks have equal values for the selected sort criterion, THE Sort_Engine SHALL break the tie by `Creation Date` in `Descending` order.
9. WHEN the user changes the sort criterion or direction, THE Todo_Screen SHALL update the task list immediately without requiring a manual refresh.
10. WHILE a search query or filters are active, THE Sort_Engine SHALL sort the filtered and searched results according to the active sort criterion and direction.

---

### Requirement 13: Persistence

**User Story:** As a user, I want my tasks and categories to be saved locally, so that they are available every time I open the application.

#### Acceptance Criteria

1. WHEN a Task is created, edited, completed, reopened, or deleted, THE Task_Manager SHALL persist the change to local storage before confirming the operation to the user interface.
2. WHEN a Category is created, renamed, or deleted, THE Category_Manager SHALL persist the change to local storage before confirming the operation to the user interface.
3. WHEN the application is closed and reopened, THE Todo_Screen SHALL display all Tasks and Categories in the state they were in when the application was last used.
4. THE Task_Manager SHALL store all Task data exclusively on the local device with no network transmission.
5. THE Category_Manager SHALL store all Category data exclusively on the local device with no network transmission.

---

### Requirement 14: Empty and Feedback States

**User Story:** As a user, I want the application to clearly communicate the current state of my task list, so that I always understand why the list looks the way it does.

#### Acceptance Criteria

1. WHEN the total number of Tasks in storage is zero and no search query or filter is active, THE Todo_Screen SHALL display a message indicating that no tasks have been created yet and guide the user toward creating a first task.
2. WHEN the active search query returns no matching Tasks, THE Todo_Screen SHALL display a message indicating that no tasks match the search query, distinguishable from the empty-list state.
3. WHEN the active filters return no matching Tasks and no search query is active, THE Todo_Screen SHALL display a message indicating that no tasks match the active filters, distinguishable from the empty-list state.
4. WHEN a Category filter is active for a specific Category and that Category contains no Tasks, THE Todo_Screen SHALL display a message indicating that the selected category has no tasks, distinguishable from the other empty states.
5. WHEN a destructive operation (Task deletion or Category deletion) succeeds, THE Todo_Screen SHALL display a transient confirmation to the user.
6. WHEN a Task is marked as completed or reopened as pending, THE Todo_Screen SHALL display a transient confirmation to the user.
7. WHEN a persistence operation fails, THE Todo_Screen SHALL display an error message in plain language and offer the user a retry action.

---

### Requirement 15: Accessibility

**User Story:** As a user with accessibility needs, I want the Todo feature to be usable with Android accessibility services, so that I can manage tasks regardless of my abilities.

#### Acceptance Criteria

1. THE Todo_Screen SHALL provide a meaningful semantic label for every interactive control that does not have visible text.
2. THE Todo_Screen SHALL render all text at or above 12sp at the default system font size.
3. THE Todo_Screen SHALL maintain a touch target size of at least 48×48dp for every interactive element.
4. THE Todo_Screen SHALL not rely solely on color to convey the priority level or status of a Task; each value SHALL also be represented by an icon or text label.
