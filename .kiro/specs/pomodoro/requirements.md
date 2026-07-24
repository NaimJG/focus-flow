# Requirements Document

## Introduction

The Pomodoro feature is the second core pillar of Focus Flow. It provides a structured focus timer following the Pomodoro Technique — alternating focused work sessions with short and long breaks in a predictable cycle. Users can optionally associate focus sessions with existing Todo tasks. Completed focus sessions are persisted locally for future statistics. The timer is designed to remain accurate across UI rebuilds, screen navigation, and brief background periods. This specification covers the Pomodoro timer, session persistence, and task integration exclusively; statistics visualization, notifications, sounds, and configurable durations are out of scope.

## Glossary

- **Focus_Session**: A timed work interval of a configured duration during which the user intends to concentrate on a single task or general work.
- **Short_Break**: A brief rest interval that follows a Focus_Session, intended to provide a short recovery before the next Focus_Session.
- **Long_Break**: An extended rest interval that follows the fourth consecutive Focus_Session in a cycle, intended to provide a deeper recovery.
- **Timer_Mode**: The category of the current timer interval. Valid values are: `Focus`, `Short_Break`, `Long_Break`.
- **Timer_Status**: The lifecycle state of the timer. Valid values are: `Idle`, `Running`, `Paused`, `Completed`.
- **Pomodoro_Cycle**: The repeating sequence of timer modes: Focus → Short_Break → Focus → Short_Break → Focus → Short_Break → Focus → Long_Break.
- **Cycle_Count**: The number of Focus_Sessions completed in the current Pomodoro_Cycle, ranging from 0 to 4.
- **Pomodoro_Session**: A persisted record of a finished Focus_Session, capturing timing data and optional task association. Only naturally completed Focus_Sessions are persisted.
- **Timer_Controller**: The application subsystem responsible for timer orchestration, cycle management, state transitions, and session persistence.
- **Session_Repository**: The application subsystem responsible for reading and writing Pomodoro_Session records to local storage.
- **Task_Selector**: The UI component that allows the user to optionally associate a focus session with an existing Todo task.
- **Pomodoro_Screen**: The primary screen of the Pomodoro feature, displaying the timer, controls, mode indicator, and task selector.
- **Target_End_Time**: The absolute timestamp at which the current timer interval is expected to reach zero, used for drift-resistant remaining-time calculations.
- **Task_Title_Snapshot**: A copy of the associated task's current title at the time the Pomodoro_Session is recorded, preserving readability if the original task is later renamed or deleted.
- **PomodoroTaskOption**: A minimal read-only data type owned by the Pomodoro feature that represents a selectable task for association purposes, containing only `id`, `title`, and `isCompleted` fields.

---

## Requirements

### Requirement 1: Timer Modes and Default Durations

**User Story:** As a user, I want the timer to support Focus, Short Break, and Long Break modes with sensible default durations, so that I can follow the Pomodoro Technique without manual configuration.

#### Acceptance Criteria

1. THE Timer_Controller SHALL support exactly three Timer_Mode values: `Focus`, `Short_Break`, and `Long_Break`.
2. THE Timer_Controller SHALL use a default duration of 25 minutes for `Focus` mode.
3. THE Timer_Controller SHALL use a default duration of 5 minutes for `Short_Break` mode.
4. THE Timer_Controller SHALL use a default duration of 15 minutes for `Long_Break` mode.
5. THE Timer_Controller SHALL read duration values from a dedicated duration configuration structure that is separate from the timer orchestration logic, so that duration values can be changed in a single location without modifying state transition or countdown code.
6. WHEN the Timer_Controller is first created, THE Timer_Controller SHALL initialize with Timer_Mode set to `Focus` and Timer_Status set to `Idle`.

---

### Requirement 2: Start the Timer

**User Story:** As a user, I want to start the timer, so that I can begin a focused work session or break.

#### Acceptance Criteria

1. WHEN the user presses Start and the Timer_Status is `Idle` or `Completed`, THE Timer_Controller SHALL transition the Timer_Status to `Running` and begin counting down from the remaining duration of the current Timer_Mode.
2. WHEN the Timer_Status transitions to `Running`, THE Timer_Controller SHALL record the Target_End_Time as the current device time plus the remaining duration.
3. WHILE the Timer_Status is `Running`, THE Pomodoro_Screen SHALL display the remaining time updating approximately every 1 second, using the Target_End_Time to compute the displayed value.
4. IF the user presses Start and the Timer_Status is `Running` or `Paused`, THEN THE Timer_Controller SHALL ignore the action and the Timer_Status SHALL remain unchanged.

---

### Requirement 3: Pause and Resume the Timer

**User Story:** As a user, I want to pause and resume the timer, so that I can handle interruptions without losing my progress.

#### Acceptance Criteria

1. WHEN the user presses Pause and the Timer_Status is `Running`, THE Timer_Controller SHALL transition the Timer_Status to `Paused`, stop the countdown, and preserve the remaining duration calculated as Target_End_Time minus the current device time at the moment of pause.
2. WHEN the user presses Resume and the Timer_Status is `Paused`, THE Timer_Controller SHALL transition the Timer_Status to `Running` and recalculate the Target_End_Time as the current device time plus the preserved remaining duration.
3. WHILE the Timer_Status is `Paused`, THE Pomodoro_Screen SHALL display the frozen remaining time in `MM:SS` format and SHALL display a text label or icon indicating the paused state, distinct from the `Running` and `Idle` states.
4. IF the Timer_Status is not `Running` when a pause action is invoked, THEN THE Timer_Controller SHALL ignore the action and not change the Timer_Status.
5. IF the Timer_Status is not `Paused` when a resume action is invoked, THEN THE Timer_Controller SHALL ignore the action and not change the Timer_Status.
6. WHEN the user pauses and subsequently resumes the timer, THE Timer_Controller SHALL ensure the total accumulated active countdown time (excluding paused intervals) from start to completion equals the configured duration of the Timer_Mode, regardless of the number or duration of pause intervals.

---

### Requirement 4: Reset the Timer

**User Story:** As a user, I want to reset the timer, so that I can start the current session over from the beginning.

#### Acceptance Criteria

1. WHEN the user presses Reset and the Timer_Status is `Running` or `Paused`, THE Timer_Controller SHALL transition the Timer_Status to `Idle`, preserve the current Timer_Mode unchanged, and restore the remaining duration to the full duration of that Timer_Mode.
2. WHEN the timer is reset, THE Timer_Controller SHALL cancel any active countdown resources.
3. WHEN the timer is reset, THE Timer_Controller SHALL not persist a Pomodoro_Session for the interrupted interval.
4. WHEN the timer is reset, THE Timer_Controller SHALL not advance the Cycle_Count.
5. IF the Timer_Status is `Idle` or `Completed`, THEN THE Timer_Controller SHALL ignore a reset request and leave all state unchanged.
6. WHEN the timer is reset, THE Timer_Controller SHALL preserve the currently selected task association so the user does not need to reselect it before starting again.

---

### Requirement 5: Skip the Current Session

**User Story:** As a user, I want to skip the current session, so that I can move to the next phase of the cycle without waiting for the timer to finish.

#### Acceptance Criteria

1. WHEN the user presses Skip and the Timer_Status is `Running` or `Paused`, THE Timer_Controller SHALL cancel any active countdown resources, end the current session, and prepare the next Timer_Mode according to the Pomodoro_Cycle.
2. WHEN the user skips a Focus_Session, THE Timer_Controller SHALL not increment the Cycle_Count.
3. WHEN the user skips a Focus_Session, THE Timer_Controller SHALL not persist a Pomodoro_Session for that session.
4. WHEN the user skips a Short_Break or Long_Break, THE Timer_Controller SHALL advance to the next Timer_Mode in the Pomodoro_Cycle.
5. WHEN a session is skipped, THE Timer_Controller SHALL transition the Timer_Status to `Idle` and set the remaining duration to the full duration of the next Timer_Mode.
6. THE Timer_Controller SHALL prevent skipping when the Timer_Status is `Idle` or `Completed`.

---

### Requirement 6: Timer Completion

**User Story:** As a user, I want the timer to signal completion when it reaches zero, so that I know it is time to transition to the next phase.

#### Acceptance Criteria

1. WHEN the calculated remaining time reaches zero or below zero (due to tick timing), THE Timer_Controller SHALL clamp the displayed remaining time to zero and transition the Timer_Status to `Completed`.
2. WHEN the Timer_Status transitions to `Completed`, THE Timer_Controller SHALL expose the mode that just finished via a `completedMode` getter, and THE Pomodoro_Screen SHALL display a message identifying the completed mode (e.g., "Focus session finished") and the prepared next mode (via `currentMode`), along with a Start button for the next session, distinguishing the `Completed` state from `Idle`, `Running`, and `Paused` states.
3. WHEN a Focus_Session completes naturally, THE Timer_Controller SHALL increment the Cycle_Count by one.
4. WHEN a Focus_Session completes naturally, THE Timer_Controller SHALL persist a Pomodoro_Session.
5. WHILE the Timer_Status is `Running`, THE Timer_Controller SHALL clamp the remaining time to a minimum value of zero, never exposing a negative remaining time to the presentation layer.
6. WHEN a Short_Break or Long_Break completes naturally, THE Timer_Controller SHALL NOT increment the Cycle_Count and SHALL NOT persist a Pomodoro_Session.

---

### Requirement 7: Pomodoro Cycle Progression

**User Story:** As a user, I want the timer to follow the standard Pomodoro cycle automatically, so that I get appropriate breaks after each focus session without manual mode selection.

#### Acceptance Criteria

1. THE Timer_Controller SHALL follow the cycle sequence: Focus → Short_Break → Focus → Short_Break → Focus → Short_Break → Focus → Long_Break.
2. WHEN the Cycle_Count reaches 4 (four Focus_Sessions completed), THE Timer_Controller SHALL select `Long_Break` as the next Timer_Mode.
3. WHILE the Cycle_Count is less than 4, WHEN a Focus_Session completes naturally, THE Timer_Controller SHALL select `Short_Break` as the next Timer_Mode.
4. WHEN a Short_Break or Long_Break completes naturally or is skipped, THE Timer_Controller SHALL select `Focus` as the next Timer_Mode.
5. WHEN a Long_Break completes naturally or is skipped, THE Timer_Controller SHALL reset the Cycle_Count to zero.
6. WHEN a session completes naturally, THE Timer_Controller SHALL set the Timer_Mode to the next mode in the Pomodoro_Cycle, set the remaining duration to the full duration of that next mode, and transition the Timer_Status to `Completed`.
7. THE Timer_Controller SHALL not automatically start the next session; the timer SHALL remain in `Completed` status until the user explicitly presses Start.
8. WHEN the Timer_Controller is first initialized, THE Timer_Controller SHALL set the Cycle_Count to zero and the Timer_Mode to `Focus`.
9. THE Timer_Controller SHALL not persist the Cycle_Count across full application process termination; upon a fresh launch, the cycle SHALL restart from Cycle_Count zero and Timer_Mode `Focus`.

---

### Requirement 8: Task Association

**User Story:** As a user, I want to optionally associate a focus session with one of my existing tasks, so that I can track how much focused time I dedicate to specific work.

#### Acceptance Criteria

1. THE Pomodoro_Screen SHALL display a Task_Selector that lists all tasks provided as PomodoroTaskOption instances in a scrollable list, sorted so that tasks with `isCompleted == false` appear before tasks with `isCompleted == true`.
2. THE Task_Selector SHALL allow the user to select no task (null association) via an explicit "No task" option displayed as the first selectable entry.
3. WHILE the Timer_Status is `Idle` or `Completed`, THE Task_Selector SHALL be enabled and allow the user to change the selected task.
4. WHILE the Timer_Status is `Running` or `Paused`, THE Task_Selector SHALL be disabled and the user SHALL NOT be able to change the selected task.
5. THE Timer_Controller SHALL store the selected task identifier as a nullable `int` value.
6. WHEN a Pomodoro_Session is persisted and a task was selected, THE Session_Repository SHALL store the associated task identifier and a Task_Title_Snapshot capturing the task's current title at the time of persistence.
7. WHEN a Pomodoro_Session is persisted and no task was selected, THE Session_Repository SHALL store null for both the task identifier and the Task_Title_Snapshot.
8. WHEN a Todo task is deleted, THE Session_Repository SHALL preserve all historical Pomodoro_Sessions that reference that task identifier unchanged.
9. WHEN a Focus_Session completes, THE Timer_Controller SHALL NOT modify the completion status of the associated Todo task.
10. THE Session_Repository SHALL NOT create a direct Isar link between the Pomodoro collection and the Todo Task collection; the task identifier SHALL be stored as a plain integer field.
11. IF no tasks are available, THEN THE Task_Selector SHALL display a message indicating no tasks are available and default the selection to null association.

---

### Requirement 9: Session Persistence

**User Story:** As a user, I want my completed focus sessions to be saved locally, so that they are available for future productivity statistics.

#### Acceptance Criteria

1. WHEN a Focus_Session completes naturally (remaining time reaches zero), THE Session_Repository SHALL persist a Pomodoro_Session record to local storage within the same operation that transitions Timer_Status to `Completed`.
2. THE Session_Repository SHALL store each Pomodoro_Session with the following fields: a unique identifier, the Timer_Mode (always `Focus`), the started-at timestamp (UTC, millisecond precision), the completed-at timestamp (UTC, millisecond precision), the planned duration in whole seconds, the actual elapsed duration in whole seconds (equal to planned duration for naturally completed sessions), the optional task identifier, and the optional Task_Title_Snapshot.
3. THE Session_Repository SHALL not persist Focus_Sessions that were reset before the remaining time reached zero.
4. THE Session_Repository SHALL not persist Short_Break or Long_Break sessions regardless of whether they complete naturally, are skipped, or are reset.
5. WHEN the application is closed and reopened, THE Session_Repository SHALL retain all previously persisted Pomodoro_Sessions without data loss or corruption.
6. THE Session_Repository SHALL store all Pomodoro_Session data exclusively on the local device with no network transmission.
7. IF a persistence operation fails (e.g., storage write error), THEN THE Session_Repository SHALL propagate the failure to the Timer_Controller without silently discarding the session data, so that the error can be surfaced to the user.

---

### Requirement 10: Timer Accuracy and Drift Resistance

**User Story:** As a user, I want the timer to remain accurate regardless of UI activity or brief background periods, so that I can trust the countdown reflects real elapsed time.

#### Acceptance Criteria

1. THE Timer_Controller SHALL calculate remaining time as the difference between the Target_End_Time and the current device time, rather than decrementing an integer counter once per second.
2. WHILE the Timer_Status is `Running`, THE Timer_Controller SHALL recalculate remaining time on every tick (once per second) using the Target_End_Time, ensuring the displayed remaining time is within 1 second of the true remaining time at any point during the countdown.
3. WHEN the application returns from a background period (process still alive) while the Timer_Status is `Running`, THE Timer_Controller SHALL recalculate remaining time from the Target_End_Time without losing elapsed seconds. IF the recalculated remaining time is less than or equal to zero, THEN THE Timer_Controller SHALL immediately transition the Timer_Status to `Completed` and persist the session.
4. WHEN multiple timer ticks are delayed, THE Timer_Controller SHALL correct the displayed remaining time on the next tick based on the Target_End_Time.
5. WHEN the timer is stopped, reset, or the controller is disposed, THE Timer_Controller SHALL cancel and dispose the periodic timer subscription so that no further tick callbacks execute.
6. THE Timer_Controller SHALL prevent duplicate concurrent timer instances from being created; IF a start action is requested while a periodic timer is already active, THEN THE Timer_Controller SHALL cancel the existing timer before creating a new one.
7. WHEN the application process is fully terminated while the timer is running, THE Timer_Controller SHALL treat the session as abandoned; the timer does not persist or resume across full process termination.
8. WHEN the application transitions from background to foreground (resumed lifecycle state) and the Timer_Status is `Running`, THE Timer_Controller SHALL immediately recalculate remaining time from the Target_End_Time without waiting for the next periodic tick.

---

### Requirement 11: State Management

**User Story:** As a user, I want the Pomodoro screen to always reflect the current timer state accurately, so that I can see at a glance what mode I am in, how much time remains, and what actions are available.

#### Acceptance Criteria

1. THE Timer_Controller SHALL extend ChangeNotifier and notify listeners on every state mutation, including each timer tick that updates the remaining duration.
2. THE Timer_Controller SHALL expose the current Timer_Mode, Timer_Status, remaining duration, selected task identifier, Cycle_Count, a boolean loading flag, a nullable String error message, a boolean indicating whether a pending session exists, and a nullable `completedMode` getter (non-null only when status is `Completed`, indicating which mode just finished) as read-only getters that widgets cannot mutate directly.
3. THE Timer_Controller SHALL define explicit enums for Timer_Mode (Focus, Short_Break, Long_Break) and Timer_Status (Idle, Running, Paused, Completed).
4. THE Timer_Controller SHALL contain all timer orchestration logic; widgets SHALL only read exposed state and invoke controller methods without performing business logic computations.
5. THE Timer_Controller SHALL delegate persistence operations to the Session_Repository; persistence logic SHALL not reside in widget code.
6. WHEN the Timer_Controller is first constructed and before initialization completes, THE Timer_Controller SHALL expose a default state of Timer_Mode `Focus`, Timer_Status `Idle`, remaining duration equal to the Focus default (25 minutes), Cycle_Count 0, no selected task, loading flag true, and null error message.

---

### Requirement 12: Architecture

**User Story:** As a developer, I want the Pomodoro feature to follow the established feature-first clean architecture, so that the codebase remains consistent and maintainable.

#### Acceptance Criteria

1. THE Pomodoro feature SHALL organize source files under `lib/features/pomodoro/` following the structure: `domain/entities/`, `domain/repositories/`, `domain/use_cases/`, `domain/exceptions/`, `data/models/`, `data/repositories/`, `presentation/controllers/`, `presentation/screens/`, and `presentation/widgets/`.
2. THE domain layer SHALL contain no import statements referencing `package:flutter`, `package:provider`, `package:isar`, or any other framework or persistence package; only `dart:core`, `dart:async`, `dart:math`, and other pure Dart SDK libraries are permitted.
3. THE domain layer SHALL define repository interfaces; concrete Isar implementations SHALL reside in the data layer.
4. THE presentation layer SHALL depend on the domain layer only: screen and widget files SHALL import domain entities for type references and controllers for state and actions, but SHALL NOT import from `data/models/` or `data/repositories/` directly.
5. THE Pomodoro feature SHALL NOT import from the Todo feature's `data/` or `domain/` layers directly; cross-feature data access SHALL be mediated through a Pomodoro-owned `PomodoroTaskOption` type and a provider function that maps external task data at the application composition root.
6. THE Pomodoro feature SHALL be permitted to import from `core/` and `shared/` in any layer, but `core/` and `shared/` SHALL NOT import from any feature.

---

### Requirement 13: Pomodoro Screen Presentation

**User Story:** As a user, I want a clear, focused Pomodoro screen that shows me everything I need — mode, time, progress, and controls — without clutter.

#### Acceptance Criteria

1. THE Pomodoro_Screen SHALL display the active Timer_Mode label as a text element visible without scrolling.
2. THE Pomodoro_Screen SHALL display remaining time in `MM:SS` format using a font size of at least 32sp.
3. THE Pomodoro_Screen SHALL display a circular progress indicator showing the proportion of elapsed time relative to total duration, where 0% elapsed renders an empty indicator and 100% elapsed renders a full indicator.
4. IF the Timer_Status is `Idle` or `Completed`, THEN THE Pomodoro_Screen SHALL display a Start button and SHALL NOT display Pause, Resume, Reset, or Skip buttons.
5. IF the Timer_Status is `Running`, THEN THE Pomodoro_Screen SHALL display Pause, Reset, and Skip buttons and SHALL NOT display Start or Resume buttons.
6. IF the Timer_Status is `Paused`, THEN THE Pomodoro_Screen SHALL display Resume, Reset, and Skip buttons and SHALL NOT display Start or Pause buttons.
7. THE Pomodoro_Screen SHALL display the Task_Selector for optional task association.
8. WHILE the Timer_Status is `Running` or `Paused`, THE Pomodoro_Screen SHALL disable the Task_Selector so the user cannot change the associated task during an active session.
9. THE Pomodoro_Screen SHALL display the current Cycle_Count as a label in the format "N / 4" where N is the number of Focus_Sessions completed in the current cycle.
10. THE Pomodoro_Screen SHALL visually distinguish between `Idle`, `Running`, `Paused`, and `Completed` states by displaying a state-specific text label and by showing only the control buttons applicable to that state.
11. THE Pomodoro_Screen SHALL use Material 3 components and consume colors exclusively through `Theme.of(context)`.
12. THE Pomodoro_Screen SHALL not hardcode feature-specific colors.

---

### Requirement 14: Navigation

**User Story:** As a user, I want to reach the Pomodoro screen through a dedicated route, so that it is independently accessible within the application.

#### Acceptance Criteria

1. THE application router SHALL register a route at `/pomodoro` that displays the Pomodoro_Screen.
2. WHILE the timer is running, WHEN the user navigates away from the Pomodoro_Screen via any in-app navigation action (back button or route push), THE Timer_Controller SHALL continue operating the timer without interruption, maintaining countdown accuracy within 1 second of real elapsed time.
3. WHEN the user returns to the Pomodoro_Screen, THE Pomodoro_Screen SHALL display the current timer state within 1 second of the actual remaining time, including the remaining duration, the current Timer_Mode, and the Cycle_Count.
4. IF the user navigates to `/pomodoro` and the Timer_Controller has no active session, THEN THE Pomodoro_Screen SHALL display the idle state with the configured default Focus duration ready to start.

---

### Requirement 15: Accessibility

**User Story:** As a user with accessibility needs, I want the Pomodoro feature to be usable with Android accessibility services, so that I can use the timer regardless of my abilities.

#### Acceptance Criteria

1. THE Pomodoro_Screen SHALL provide a semantic label that describes the control's action or purpose for every interactive element that does not have visible text.
2. THE Pomodoro_Screen SHALL provide tooltips on icon-only buttons describing their action.
3. THE Pomodoro_Screen SHALL render the remaining-time display at a minimum font size of 24sp, and all other visible text at a minimum font size of 12sp.
4. THE Pomodoro_Screen SHALL maintain a touch target size of at least 48×48dp for every interactive element.
5. THE Pomodoro_Screen SHALL not rely solely on color to distinguish Timer_Mode or Timer_Status; each state SHALL also be represented by an icon or text label.
6. WHEN the Timer_Status changes, THE Pomodoro_Screen SHALL announce the new status value via a semantics announcement so that screen reader users are informed without requiring manual focus navigation.
7. THE Pomodoro_Screen SHALL expose the remaining-time display as a semantics node with a label conveying the current minutes and seconds remaining, so that screen reader users can perceive the countdown value.
8. THE Pomodoro_Screen SHALL maintain a minimum contrast ratio of 4.5:1 for body text and 3:1 for large text (18sp or above) against their background, following WCAG 2.1 AA guidelines.

---

### Requirement 16: Statistics Compatibility

**User Story:** As a developer, I want the persisted session model to support future statistics calculations, so that the Statistics feature can be built without requiring data migration.

#### Acceptance Criteria

1. THE Pomodoro_Session data model SHALL include at minimum the following fields to support statistics calculations: actual elapsed duration (for total focused time), started-at timestamp (for grouping by date), and optional task identifier (for grouping by task).
2. THE Pomodoro_Session data model SHALL store the started-at timestamp as a millisecond-precision UTC DateTime value that preserves year, month, and day components, enabling daily grouping by extracting the date portion.
3. THE Pomodoro_Session data model SHALL store the optional task identifier as a nullable int matching the Todo Task entity's `id` field type.
4. THE Session_Repository SHALL support querying Pomodoro_Sessions by an inclusive-start and exclusive-end date range, and by a specific non-null task identifier, for future statistics use.
5. THE Session_Repository SHALL support querying Pomodoro_Sessions that have a null task identifier, enabling statistics for unassociated focus sessions.
6. WHEN a date range query or task identifier query matches no records, THE Session_Repository SHALL return an empty collection rather than an error.

---

### Requirement 17: Error and Loading States

**User Story:** As a user, I want the Pomodoro screen to handle loading and error states gracefully, so that I always understand what is happening.

#### Acceptance Criteria

1. WHILE the Timer_Controller is loading initial data, THE Pomodoro_Screen SHALL display a centered `CircularProgressIndicator` and SHALL not display timer controls until loading completes or fails.
2. IF a persistence operation fails, THEN THE Timer_Controller SHALL store a plain-language error message describing the problem without technical identifiers, and THE Pomodoro_Screen SHALL display that message to the user.
3. IF a persistence operation fails while the Timer_Status is `Running`, THEN THE Timer_Controller SHALL continue the active countdown without interruption; the error SHALL be displayed non-modally so it does not block timer interaction.
4. WHEN an error is displayed due to a failed persistence operation, THE Pomodoro_Screen SHALL offer a Retry button that re-attempts the failed operation.
5. WHEN the user dismisses the error, THE Timer_Controller SHALL clear the error message but SHALL retain the pending session for future retry.
6. THE Pomodoro_Screen SHALL never display technical exception names or stack traces to the user.
7. WHILE a pending session exists, THE Pomodoro_Screen SHALL display a persistent retry affordance so the user can re-attempt persistence at any time.

---

### Requirement 18: Explicitly Out of Scope

**User Story:** As a developer, I want explicit documentation of excluded capabilities, so that scope boundaries are clear during implementation.

#### Acceptance Criteria

1. THE Pomodoro feature SHALL NOT include a user interface for configuring timer durations (work duration, short break duration, long break duration, or sessions-before-long-break count SHALL NOT be editable by the user).
2. THE Pomodoro feature SHALL NOT include local notifications, background services, vibration, or audio feedback of any kind.
3. THE Pomodoro feature SHALL NOT include achievements, goals, streaks, badges, or gamification elements.
4. THE Pomodoro feature SHALL NOT include cloud synchronization, remote data storage, or authentication mechanisms.
5. THE Pomodoro feature SHALL NOT automatically mark a Todo task as completed when a Focus_Session finishes, nor modify any Todo task state as a side effect of timer operations.
6. THE Pomodoro feature SHALL NOT include statistics charts, a statistics screen, or any data visualization beyond the session count displayed on the timer screen itself.
7. THE Pomodoro feature SHALL NOT include a home dashboard, bottom navigation bar, or any navigation chrome beyond what is required to reach and operate the timer screen.

---

### Requirement 19: Testing

**User Story:** As a developer, I want comprehensive test coverage for the Pomodoro feature, so that regressions are caught early and correctness is maintained.

#### Acceptance Criteria

1. THE Pomodoro feature SHALL include unit tests for Timer_Controller covering all state transitions: start, pause, resume, reset, skip, and completion.
2. THE Pomodoro feature SHALL include unit tests verifying correct Pomodoro_Cycle progression through all eight phases.
3. THE Pomodoro feature SHALL include unit tests verifying that pausing preserves remaining duration and resuming recalculates the Target_End_Time.
4. THE Pomodoro feature SHALL include unit tests verifying timestamp-based drift resistance by simulating delayed ticks using an injectable time source.
5. THE Pomodoro feature SHALL include unit tests verifying task association storage and Task_Title_Snapshot capture.
6. THE Pomodoro feature SHALL include unit tests for Session_Repository persistence and retrieval operations.
7. THE Pomodoro feature SHALL include unit tests for Isar model conversion between domain entities and data models.
8. THE Pomodoro feature SHALL include widget tests for the Pomodoro_Screen covering `Idle`, `Running`, `Paused`, and `Completed` visual states, verifying that only the applicable control buttons are visible in each state.
9. THE Pomodoro feature SHALL include unit tests verifying that completion fires at most once per running session, even when multiple tick callbacks or lifecycle events arrive simultaneously.
