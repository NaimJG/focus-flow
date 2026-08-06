# Requirements Document

## Introduction

This feature adds a "Start Pomodoro" action button to the task edit screen (TaskFormScreen) for existing persisted tasks. When tapped, the button selects the current task in the app-scoped PomodoroController and navigates the user to the Pomodoro screen — without starting the timer. This bridges the Todo and Pomodoro features, allowing users to begin a focused session on a specific task directly from the task detail view.

## Glossary

- **TaskFormScreen**: The Flutter screen used for both creating new tasks and editing existing persisted tasks.
- **PomodoroController**: The app-level ChangeNotifier that manages all Pomodoro timer state, including task selection.
- **PomodoroScreen**: The standalone Pomodoro timer screen, accessible both as a tab in HomeScreen and as a pushed route.
- **Timer_Status**: An enum representing the lifecycle state of the Pomodoro timer: idle, running, paused, or completed.
- **Start_Pomodoro_Button**: The new FilledButton.tonalIcon widget that triggers task selection and navigation to the Pomodoro screen.
- **Persisted_Task**: A task entity with a valid database ID (id > 0) that has been saved to Isar.
- **Localization_System**: The Flutter ARB-based localization infrastructure providing translated strings.

## Requirements

### Requirement 1: Button Visibility

**User Story:** As a user editing an existing task, I want to see a "Start Pomodoro" button, so that I can quickly navigate to the Pomodoro timer with that task pre-selected.

#### Acceptance Criteria

1. WHILE the TaskFormScreen is in edit mode AND widget.initialTask is not null AND widget.initialTask.id is greater than zero, THE Start_Pomodoro_Button SHALL be visible below the TaskPomodoroStatsSection and above the save button.
2. WHILE the TaskFormScreen is in create mode (initialTask is null), THE Start_Pomodoro_Button SHALL NOT be rendered.
3. WHILE the task ID is zero or negative (unsaved entity), THE Start_Pomodoro_Button SHALL NOT be rendered.

### Requirement 2: Button Presentation

**User Story:** As a user, I want the Start Pomodoro button to be visually distinct from Save and Delete actions, so that I can identify its purpose at a glance.

#### Acceptance Criteria

1. THE Start_Pomodoro_Button SHALL use a FilledButton.tonalIcon style with an Icons.timer icon and a localized label.
2. THE Start_Pomodoro_Button SHALL span the full available width (CrossAxisAlignment.stretch behavior).
3. THE Start_Pomodoro_Button SHALL derive all colors from Theme.of(context) using the secondary or tertiary color role to differentiate from the primary FilledButton used for Save.
4. THE Start_Pomodoro_Button SHALL maintain a minimum touch target of 48dp height.
5. THE Start_Pomodoro_Button SHALL render correctly at 360dp screen width and remain usable at 200% text scaling.

### Requirement 3: Task Selection on Tap (Idle/Completed)

**User Story:** As a user, I want tapping "Start Pomodoro" to select the current task in the Pomodoro timer, so that the timer is ready for me to start a focused session.

#### Acceptance Criteria

1. WHEN the Start_Pomodoro_Button is tapped AND the Timer_Status is idle or completed, THE TaskFormScreen SHALL call PomodoroController.selectTask with the persisted task ID and title from widget.initialTask.
2. WHEN selectTask has been called, THE TaskFormScreen SHALL navigate to Routes.pomodoro by pushing the route onto the navigation stack.
3. WHEN navigation completes, THE PomodoroController.status SHALL remain unchanged (idle or completed) — the timer SHALL NOT be started automatically.

### Requirement 4: Active Session Protection

**User Story:** As a user with a running or paused Pomodoro session, I want the app to prevent overwriting my active session and inform me clearly, so that I do not lose focus progress.

#### Acceptance Criteria

1. WHEN the Start_Pomodoro_Button is tapped AND the Timer_Status is running or paused, THE TaskFormScreen SHALL NOT call PomodoroController.selectTask.
2. WHEN the Start_Pomodoro_Button is tapped AND the Timer_Status is running or paused, THE TaskFormScreen SHALL NOT navigate to Routes.pomodoro.
3. WHEN the Start_Pomodoro_Button is tapped AND the Timer_Status is running or paused, THE TaskFormScreen SHALL remain on the current screen.
4. WHEN the Start_Pomodoro_Button is tapped AND the Timer_Status is running or paused, THE TaskFormScreen SHALL show a localized SnackBar message indicating another Pomodoro session is already active.
5. WHEN the Start_Pomodoro_Button is tapped repeatedly while a session is active, THE TaskFormScreen SHALL hide the current SnackBar before showing a new one (no stacking).
6. THE active session warning message SHALL NOT expose the active task ID or modify timer state.

### Requirement 5: Navigation Strategy

**User Story:** As a user, I want to navigate to the Pomodoro screen and easily return to the task I was editing, so that my workflow is not disrupted.

#### Acceptance Criteria

1. WHEN the Start_Pomodoro_Button triggers navigation (status is idle or completed), THE TaskFormScreen SHALL push Routes.pomodoro onto the navigation stack (preserving the TaskFormScreen below).
2. WHEN the user presses Back from the pushed PomodoroScreen, THE TaskFormScreen SHALL be restored with its form state intact.
3. WHEN the user returns to the TaskFormScreen, THE TaskPomodoroStatsController SHALL refresh to reflect any new completed sessions (existing RouteAware behavior via didPopNext).
4. WHEN the Timer_Status is running or paused, THE TaskFormScreen SHALL NOT push any route — no navigation occurs.

### Requirement 6: Form State Handling

**User Story:** As a user, I want the Pomodoro to be associated with the saved version of my task, so that the task identity is reliable regardless of unsaved form edits.

#### Acceptance Criteria

1. THE Start_Pomodoro_Button SHALL use widget.initialTask.id and widget.initialTask.title (persisted values) when calling selectTask, regardless of current form field values.
2. IF the form contains unsaved edits when the user taps Start Pomodoro, THE TaskFormScreen SHALL NOT save the form before navigating — the user may save changes after returning.

### Requirement 7: Localization

**User Story:** As a user in a Spanish or English locale, I want the Start Pomodoro button and its messages localized, so that the interface is consistent with the rest of the application.

#### Acceptance Criteria

1. THE Localization_System SHALL provide a key `taskStartPomodoro` with values "Iniciar Pomodoro" (es) and "Start Pomodoro" (en).
2. THE Localization_System SHALL provide a key `taskStartPomodoroSemantic` with a parameterized template including the task title: "Iniciar Pomodoro para {taskTitle}" (es) / "Start Pomodoro for {taskTitle}" (en).
3. THE Localization_System SHALL provide a key `pomodoroActiveSessionWarning` with values "Ya hay un Pomodoro en curso. Finalízalo o reinícialo antes de iniciar otro." (es) and "A Pomodoro is already in progress. Complete or reset it before starting another one." (en).

### Requirement 8: Accessibility

**User Story:** As a user relying on assistive technology, I want the Start Pomodoro button to have a descriptive label, so that I can understand its action without visual context.

#### Acceptance Criteria

1. THE Start_Pomodoro_Button SHALL have a Semantics label of `taskStartPomodoroSemantic` which includes the task title.
2. THE Start_Pomodoro_Button SHALL meet the 48dp minimum touch target requirement.
3. THE Start_Pomodoro_Button SHALL NOT rely solely on the icon to communicate its purpose — it includes visible text.

### Requirement 9: Preservation of Existing Behavior

**User Story:** As a user, I want all existing functionality to remain unchanged, so that this new feature does not introduce regressions.

#### Acceptance Criteria

1. THE TaskFormScreen SHALL preserve all existing behavior for task creation, editing, validation, and deletion.
2. THE PomodoroController SHALL preserve all existing timer behavior: start, pause, resume, reset, skip, session persistence, and sound playback.
3. THE HomeScreen navigation, statistics, settings, and all other features SHALL remain unmodified.
