# Requirements Document

## Introduction

This feature adds a read-only Pomodoro activity summary to the task edit screen. When a user edits an existing persisted task, the screen displays how many Pomodoro sessions have been completed for that task, the total focused time, and the equivalent cycles derived from the current settings. The summary does not appear on the new-task form. It is purely informational and does not modify any persisted data.

## Glossary

- **Task_Form_Screen**: The screen used to create new tasks or edit existing persisted tasks.
- **Pomodoro_Stats_Section**: The read-only UI section within Task_Form_Screen that displays Pomodoro activity metrics for the current task.
- **Task_Pomodoro_Stats**: An immutable domain result object containing aggregated Pomodoro metrics (completed pomodoros count and total focused duration) for a specific task.
- **Pomodoro_Session_Repository**: The existing repository responsible for persisting and querying Pomodoro sessions.
- **Settings_Controller**: The application-scoped controller exposing the current AppSettings including cyclesBeforeLongBreak.
- **Duration_Formatter**: The existing utility function that formats seconds into a localized human-readable string.
- **Equivalent_Cycles**: A derived informational value calculated as completedPomodoros integer-divided by the current cyclesBeforeLongBreak setting. Not persisted.

## Requirements

### Requirement 1: Compute Task Pomodoro Statistics

**User Story:** As a user, I want the app to compute Pomodoro activity metrics for a task, so that I can see my focus effort on that task.

#### Acceptance Criteria

1. WHEN a task ID is provided, THE Task_Pomodoro_Stats SHALL count only completed Focus-mode PomodoroSession records whose taskId matches the provided task ID.
2. WHEN a task ID is provided, THE Task_Pomodoro_Stats SHALL sum the actualDurationSeconds from all completed Focus-mode PomodoroSession records whose taskId matches the provided task ID.
3. THE Task_Pomodoro_Stats SHALL return an immutable result containing completedPomodoros (int) and focusedDuration (Duration).
4. WHEN no completed Focus sessions exist for the given task ID, THE Task_Pomodoro_Stats SHALL return completedPomodoros as 0 and focusedDuration as Duration.zero.
5. THE Task_Pomodoro_Stats SHALL reuse the existing Pomodoro_Session_Repository getByTaskId method to obtain session data.
6. THE Task_Pomodoro_Stats SHALL NOT query Isar directly from the presentation layer.

### Requirement 2: Calculate Equivalent Cycles

**User Story:** As a user, I want to see how many full Pomodoro cycles my completed sessions represent, so that I can understand my focus patterns relative to my current settings.

#### Acceptance Criteria

1. WHEN rendering the Pomodoro_Stats_Section, THE Pomodoro_Stats_Section SHALL calculate equivalent cycles as: completedPomodoros integer-divided by Settings_Controller.settings.cyclesBeforeLongBreak.
2. THE Pomodoro_Stats_Section SHALL use the current cyclesBeforeLongBreak value from Settings_Controller at render time.
3. THE Pomodoro_Stats_Section SHALL NOT persist the equivalent cycles value to the database.
4. THE Pomodoro_Stats_Section SHALL label the metric as "Ciclos equivalentes" in Spanish and "Equivalent cycles" in English.

### Requirement 3: Display Pomodoro Activity Summary on Task Edit

**User Story:** As a user, I want to see Pomodoro activity for a task when editing it, so that I can understand how much focused work I have invested in that task.

#### Acceptance Criteria

1. WHEN the Task_Form_Screen receives a non-null initialTask (edit mode), THE Pomodoro_Stats_Section SHALL be visible below the editable task fields.
2. WHEN the Task_Form_Screen receives a null initialTask (create mode), THE Pomodoro_Stats_Section SHALL NOT be displayed.
3. THE Pomodoro_Stats_Section SHALL display three metrics: completed Pomodoros count, equivalent cycles count, and formatted focused time.
4. THE Pomodoro_Stats_Section SHALL use a Material 3 Card or equivalent compact container.
5. THE Pomodoro_Stats_Section SHALL display a section header labeled "Actividad Pomodoro" in Spanish and "Pomodoro activity" in English.
6. WHEN zero completed Focus sessions exist for the task, THE Pomodoro_Stats_Section SHALL display a localized empty-state message: "Todavía no hay actividad Pomodoro para esta tarea" in Spanish and "There is no Pomodoro activity for this task yet" in English.
7. THE Pomodoro_Stats_Section SHALL format the focused time value using the existing Duration_Formatter.

### Requirement 4: Responsive and Accessible Layout

**User Story:** As a user, I want the Pomodoro activity summary to be usable on small screens and with assistive technologies, so that I can access the information regardless of device size or accessibility needs.

#### Acceptance Criteria

1. THE Pomodoro_Stats_Section SHALL support screens as narrow as 360dp without overflow or clipping.
2. THE Pomodoro_Stats_Section SHALL use Wrap or a responsive layout instead of a fixed Row for metric items.
3. THE Pomodoro_Stats_Section SHALL support text scaling up to 200% without layout breakage.
4. THE Pomodoro_Stats_Section SHALL use theme-derived colors obtained via Theme.of(context).
5. THE Pomodoro_Stats_Section SHALL NOT rely solely on color to convey information.
6. THE Pomodoro_Stats_Section SHALL provide localized Semantics labels for each metric value.

### Requirement 5: Localization

**User Story:** As a user, I want the Pomodoro activity summary to be localized in Spanish and English, so that the information matches my language preference.

#### Acceptance Criteria

1. THE Pomodoro_Stats_Section SHALL use ARB key taskPomodoroActivity for the section header ("Actividad Pomodoro" / "Pomodoro activity").
2. THE Pomodoro_Stats_Section SHALL use ARB key taskCompletedPomodoros for the Pomodoros metric label ("Pomodoros" / "Pomodoros").
3. THE Pomodoro_Stats_Section SHALL use ARB key taskEquivalentCycles for the equivalent cycles metric label ("Ciclos equivalentes" / "Equivalent cycles").
4. THE Pomodoro_Stats_Section SHALL use ARB key taskFocusedTime for the focused time metric label ("Tiempo enfocado" / "Focused time").
5. THE Pomodoro_Stats_Section SHALL use ARB key taskNoPomodoroActivity for the empty-state message ("Todavía no hay actividad Pomodoro para esta tarea" / "There is no Pomodoro activity for this task yet").
6. THE Pomodoro_Stats_Section SHALL use ARB key taskPomodoroCount with ICU pluralization for the Pomodoro count value.
7. THE Pomodoro_Stats_Section SHALL use ARB key taskEquivalentCycleCount with ICU pluralization for the equivalent cycles value.

### Requirement 6: Loading and Error Handling

**User Story:** As a user, I want the task edit form to remain functional even if Pomodoro statistics fail to load, so that I can always edit my tasks without disruption.

#### Acceptance Criteria

1. WHILE the Pomodoro statistics are loading, THE Pomodoro_Stats_Section SHALL display a small loading indicator or placeholder.
2. IF the statistics query fails, THEN THE Pomodoro_Stats_Section SHALL display a localized non-blocking fallback state.
3. IF the statistics query fails, THEN THE Task_Form_Screen SHALL continue to allow editing and saving the task without interruption.
4. WHEN the user returns to the Task_Form_Screen after completing a Pomodoro session associated with that task, THE Pomodoro_Stats_Section SHALL refresh the displayed statistics.

### Requirement 7: Architectural Boundaries

**User Story:** As a developer, I want the Pomodoro statistics integration to respect existing architectural boundaries, so that feature modules remain decoupled.

#### Acceptance Criteria

1. THE Task_Pomodoro_Stats SHALL NOT introduce a direct dependency from the Todo domain layer to Pomodoro domain entities.
2. THE Pomodoro_Stats_Section SHALL be composed in the presentation or application layer, not inside the Todo domain.
3. THE Task_Pomodoro_Stats SHALL NOT create a new Isar instance.
4. THE Task_Pomodoro_Stats SHALL NOT modify any persisted Task entity.
5. THE Task_Pomodoro_Stats SHALL NOT modify any persisted PomodoroSession entity.
6. THE Task_Pomodoro_Stats SHALL NOT alter existing task CRUD behavior, Pomodoro timer behavior, session persistence behavior, Settings persistence, Todo filters or sorting, Statistics feature behavior, or localization architecture.
