# Implementation Plan: Task Pomodoro Statistics

## Overview

This plan implements a read-only Pomodoro activity summary on the task edit screen. The work is organized into small, testable increments: domain result object and repository query, Isar implementation and use case, controller for async state, localized responsive UI widget, task edit-screen integration, essential tests, and manual verification.

## Tasks

- [x] 1. Domain result and repository query
  - [x] 1.1 Create TaskPomodoroStats entity
    - Create `lib/features/pomodoro/domain/entities/task_pomodoro_stats.dart`
    - Immutable class with `completedPomodoros` (int) and `focusedDuration` (Duration)
    - Use const constructor
    - _Requirements: 1.3, 1.4_
  - [x] 1.2 Add getByTaskId to PomodoroSessionRepository interface (if not present)
    - Verify `lib/features/pomodoro/domain/repositories/pomodoro_session_repository.dart` exposes `Future<List<PomodoroSession>> getByTaskId(int taskId)`
    - Add the method signature if missing
    - _Requirements: 1.5, 7.1_

- [x] 2. Isar implementation and use case
  - [x] 2.1 Implement getByTaskId in IsarPomodoroSessionRepository (if not present)
    - Verify `lib/features/pomodoro/data/repositories/` contains the Isar implementation for `getByTaskId`
    - Query by indexed `taskId` field, return completed Focus-mode sessions
    - No new Isar instance — reuse existing one
    - _Requirements: 1.5, 7.3_
  - [x] 2.2 Create GetTaskPomodoroStatsUseCase
    - Create `lib/features/pomodoro/domain/use_cases/get_task_pomodoro_stats_use_case.dart`
    - Accept `PomodoroSessionRepository` via constructor injection
    - `call(int taskId)` fetches sessions via `getByTaskId`, counts them, sums `actualDurationSeconds`, returns `TaskPomodoroStats`
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 7.1, 7.2_
  - [x] 2.3 Register GetTaskPomodoroStatsUseCase in dependency injection
    - Add `Provider<GetTaskPomodoroStatsUseCase>` at app level consuming existing `PomodoroSessionRepository`
    - _Requirements: 7.3_

- [x] 3. Task statistics controller
  - [x] 3.1 Create TaskPomodoroStatsController
    - Create `lib/features/todo/presentation/controllers/task_pomodoro_stats_controller.dart`
    - Extend `ChangeNotifier` with `TaskPomodoroStatsStatus` enum (loading, loaded, error)
    - Expose `status` and nullable `stats` getters
    - `load()` calls use case, transitions state, catches exceptions without rethrowing
    - Triggers `load()` on construction
    - _Requirements: 6.1, 6.2, 6.3, 7.2_

- [x] 4. Localized responsive UI section
  - [x] 4.1 Add ARB localization keys
    - Add keys to `app_es.arb` and `app_en.arb`: `taskPomodoroActivity`, `taskCompletedPomodoros`, `taskEquivalentCycles`, `taskFocusedTime`, `taskNoPomodoroActivity`, `taskPomodoroCount` (ICU plural), `taskEquivalentCycleCount` (ICU plural)
    - Run code generation for localization
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_
  - [x] 4.2 Create TaskPomodoroStatsSection widget
    - Create `lib/features/todo/presentation/widgets/task_pomodoro_stats_section.dart`
    - Stateless widget receiving `status`, `stats`, `cyclesBeforeLongBreak`, `l10n`
    - Compute equivalent cycles: `completedPomodoros ~/ cyclesBeforeLongBreak`
    - Render Material 3 Card with section header
    - Use `Wrap` layout for metric items (icon + value + label columns)
    - Handle loading (small indicator), error (fallback text), empty-state (localized message), and loaded (three metrics) states
    - Format focused time via existing `formatDuration` utility
    - Provide `Semantics` labels for each metric value
    - Use `Theme.of(context)` for all colors
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.3, 3.4, 3.5, 3.6, 3.7, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 6.1, 6.2_

- [x] 5. Task edit-screen integration
  - [x] 5.1 Integrate controller and widget into TaskFormScreen
    - In edit mode (`initialTask != null`): create `TaskPomodoroStatsController` scoped to the screen
    - Insert `TaskPomodoroStatsSection` below form fields
    - Read `cyclesBeforeLongBreak` from `SettingsController`
    - On screen focus return, call `controller.load()` to refresh stats
    - In create mode: do not instantiate or display the stats section
    - Ensure form remains fully functional regardless of stats state
    - _Requirements: 3.1, 3.2, 6.3, 6.4, 7.4, 7.5, 7.6_

- [x] 6. Checkpoint
  - Ensure the app builds without errors. Run `flutter analyze` and fix any issues. Ask the user if questions arise.

- [ ] 7. Essential tests
  - [ ]* 7.1 Unit test GetTaskPomodoroStatsUseCase
    - Test with zero sessions → returns 0 pomodoros and Duration.zero
    - Test Pomodoro count by matching taskId (mock repository returns N sessions)
    - Test that sessions from other tasks are ignored (repository mock scoped to taskId)
    - Test focused-time summation across multiple sessions
    - _Requirements: 1.1, 1.2, 1.4_
  - [ ]* 7.2 Unit test equivalent cycles calculation
    - Test integer division for cyclesBeforeLongBreak values 1 through 6
    - Test with 0 completed pomodoros
    - _Requirements: 2.1_
  - [ ]* 7.3 Unit test TaskPomodoroStatsController state transitions
    - Test loading → loaded on success
    - Test loading → error on exception
    - Test that form independence is maintained (error does not propagate)
    - _Requirements: 6.1, 6.2, 6.3_
  - [ ]* 7.4 Property-based test: session count correctness
    - **Property 1: Session count correctness**
    - Generate random session lists (0–100 items), verify `completedPomodoros == sessions.length`
    - **Validates: Requirements 1.1**
  - [ ]* 7.5 Property-based test: duration summation correctness
    - **Property 2: Duration summation correctness**
    - Generate random session lists, verify `focusedDuration.inSeconds == sum(actualDurationSeconds)`
    - **Validates: Requirements 1.2**
  - [ ]* 7.6 Property-based test: equivalent cycles integer division
    - **Property 3: Equivalent cycles integer division**
    - Generate random `completedPomodoros` (0–10000) and `cyclesBeforeLongBreak` (1–6), verify `equivalentCycles == completedPomodoros ~/ cyclesBeforeLongBreak`
    - **Validates: Requirements 2.1**
  - [ ]* 7.7 Property-based test: empty session list yields zero stats
    - **Property 4: Empty session list yields zero stats**
    - Generate random task IDs with empty session list, verify zero stats
    - **Validates: Requirements 1.4**
  - [ ]* 7.8 Widget tests for TaskPomodoroStatsSection
    - Test loaded state renders three metrics
    - Test empty-state message when completedPomodoros is 0
    - Test loading indicator when status is loading
    - Test error fallback display
    - Test edit mode includes stats section, create mode does not
    - _Requirements: 3.1, 3.2, 3.3, 3.6_
  - [ ]* 7.9 Golden, integration, and accessibility tests
    - Golden tests for light/dark theme rendering
    - Integration test for end-to-end flow
    - Accessibility audit (Semantics labels present)
    - _Requirements: 4.4, 4.5, 4.6_

- [ ] 8. Final checkpoint
  - Ensure all tests pass. Ask the user if questions arise.

- [ ] 9. Manual verification
  - [ ] 9.1 Verify feature behavior manually
    - Task with no Pomodoros → empty-state message displayed
    - Task with several Pomodoros → correct count, duration, and cycles
    - Sessions belonging to another task are excluded from stats
    - Focused duration matches sum of actual durations
    - Changing cycles-before-long-break in Settings updates equivalent cycles on return
    - Changing Settings does not modify persisted sessions
    - Spanish and English labels display correctly
    - Light and dark themes render without issues
    - Layout works at 360dp width without overflow
    - 200% text scaling does not break layout
    - _Requirements: 1.1, 1.2, 2.1, 2.2, 3.1, 3.3, 3.6, 4.1, 4.3, 4.4, 5.1–5.7, 7.4, 7.5_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP.
- Each task references specific requirements for traceability.
- Checkpoints ensure incremental validation.
- Property tests validate universal correctness properties from the design document.
- Unit tests (7.1–7.3) are mandatory; widget/golden/integration tests (7.8–7.9) are optional.
- Manual verification (9.1) covers scenarios that automated tests cannot fully replicate (theme rendering, text scaling, real device layout).

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["2.1", "4.1"] },
    { "id": 2, "tasks": ["2.2"] },
    { "id": 3, "tasks": ["2.3", "3.1"] },
    { "id": 4, "tasks": ["4.2"] },
    { "id": 5, "tasks": ["5.1"] },
    { "id": 6, "tasks": ["7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7"] },
    { "id": 7, "tasks": ["7.8", "7.9"] },
    { "id": 8, "tasks": ["9.1"] }
  ]
}
```
