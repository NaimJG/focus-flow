# Implementation Plan: Pomodoro Feature

## Overview

Implementation follows Feature-First Clean Architecture from the inside out: domain entities and
enums first, then repository interfaces and use cases, then data layer (Isar), then state
management (PomodoroController), then presentation widgets and screens, and finally navigation
wiring and all test layers. Each task produces a compilable, self-contained increment. The timer
uses absolute `Target_End_Time` timestamps for drift-resistant countdown accuracy. The
`PomodoroController` is provided at the app level so it survives navigation. The controller uses
`WidgetsBindingObserver` for lifecycle handling. Cross-feature task access uses a Pomodoro-owned
`PomodoroTaskOption` type mapped from Todo's `Task` in the composition root. The implementation
language is **Dart / Flutter**.

---

## Tasks

### Group 1 — Domain Layer (Entities + Enums)

- [x] 1. Define domain enums, entities, and value objects
  - [x] 1.1 Create `lib/features/pomodoro/domain/entities/timer_mode.dart`
    - Define `enum TimerMode { focus, shortBreak, longBreak }`.
    - _Requirements: 1.1 / Design: Data Models — TimerMode Enum_
  - [x] 1.2 Create `lib/features/pomodoro/domain/entities/timer_status.dart`
    - Define `enum TimerStatus { idle, running, paused, completed }`.
    - _Requirements: 1.6, 11.3 / Design: Data Models — TimerStatus Enum_
  - [x] 1.3 Create `lib/features/pomodoro/domain/entities/pomodoro_task_option.dart`
    - Define `PomodoroTaskOption` class with `const` constructor: `id` (int), `title` (String),
      `isCompleted` (bool). All fields `final`.
    - This is the Pomodoro-owned minimal read-only task type that decouples the feature from Todo.
    - _Requirements: 8.1, 12.5 / Design: Data Models — PomodoroTaskOption_
  - [x] 1.4 Create `lib/features/pomodoro/domain/entities/pomodoro_config.dart`
    - Immutable class with `const` constructor: `focusDuration` (25 min), `shortBreakDuration`
      (5 min), `longBreakDuration` (15 min), `sessionsBeforeLongBreak` (4).
    - Add `Duration durationFor(TimerMode mode)` helper method.
    - _Requirements: 1.2, 1.3, 1.4, 1.5 / Design: Data Models — PomodoroConfig_
  - [x] 1.5 Create `lib/features/pomodoro/domain/entities/pomodoro_session.dart`
    - Immutable class with `const` constructor: `id`, `timerMode`, `startedAt`, `completedAt`,
      `plannedDurationSeconds`, `actualDurationSeconds`, `taskId?`, `taskTitleSnapshot?`.
    - All fields `final`. No Isar annotations. No `result` field.
    - _Requirements: 9.2, 16.1, 16.2, 16.3 / Design: Data Models — PomodoroSession_
  - [x] 1.6 Create `lib/features/pomodoro/domain/entities/clock.dart`
    - Define `abstract interface class Clock` with `DateTime now()` method.
    - Define `class SystemClock implements Clock` returning `DateTime.now().toUtc()`.
    - All timestamps produced by the Clock are UTC for timezone-independent persistence.
    - _Requirements: 10.1, 10.2 / Design: Timer Lifecycle — Injectable Time Source_
  - [x] 1.7 Create `lib/features/pomodoro/domain/exceptions/persistence_exception.dart`
    - Define `class PersistenceException implements Exception` with `String message` field.
    - _Requirements: 9.7, 17.2 / Design: Error Handling — Domain Exceptions_

---

### Group 2 — Domain Layer (Repository Interface + Use Cases)

- [x] 2. Define repository interface and use cases
  - [x] 2.1 Create `lib/features/pomodoro/domain/repositories/pomodoro_session_repository.dart`
    - Abstract interface with `create(PomodoroSession)`, `getAll()`,
      `getByDateRange({required DateTime start, required DateTime end})`,
      `getByTaskId(int taskId)`, `getByNullTask()`.
    - All query methods return `Future<List<PomodoroSession>>`. `create` returns
      `Future<PomodoroSession>`.
    - _Requirements: 9.1, 16.4, 16.5, 16.6 / Design: Repository Interfaces_
  - [x] 2.2 Create `lib/features/pomodoro/domain/use_cases/save_pomodoro_session_use_case.dart`
    - Constructor-injected `PomodoroSessionRepository`.
    - Single `call(PomodoroSession session)` → delegates to `repository.create(session)`.
    - _Requirements: 9.1, 6.4 / Design: Use Cases — SavePomodoroSessionUseCase_
  - [x] 2.3 Create `lib/features/pomodoro/domain/use_cases/get_sessions_use_case.dart`
    - Constructor-injected `PomodoroSessionRepository`.
    - Single `call()` → delegates to `repository.getAll()`.
    - _Requirements: 16.4 / Design: Use Cases — GetSessionsUseCase_
  - [x] 2.4 Create `lib/features/pomodoro/domain/use_cases/get_sessions_by_date_range_use_case.dart`
    - Constructor-injected `PomodoroSessionRepository`.
    - Single `call({required DateTime start, required DateTime end})` → delegates to
      `repository.getByDateRange(start: start, end: end)`.
    - _Requirements: 16.4, 16.6 / Design: Use Cases — GetSessionsByDateRangeUseCase_
  - [x] 2.5 Create `lib/features/pomodoro/domain/use_cases/get_sessions_by_task_id_use_case.dart`
    - Constructor-injected `PomodoroSessionRepository`.
    - Single `call(int? taskId)` → routes to `repository.getByTaskId(taskId)` when non-null,
      `repository.getByNullTask()` when null.
    - _Requirements: 16.5, 16.6 / Design: Use Cases — GetSessionsByTaskIdUseCase_

---

### Group 3 — Data Layer

- [x] 3. Implement Isar data layer
  - [x] 3.1 Create `lib/features/pomodoro/data/models/pomodoro_session_model.dart`
    - `@collection` class with fields: `id` (Id), `timerModeIndex` (int), `startedAt` (DateTime),
      `completedAt` (DateTime), `plannedDurationSeconds` (int), `actualDurationSeconds` (int),
      `taskId` (int?), `taskTitleSnapshot` (String?).
    - No `resultIndex` field — the MVP only persists completed Focus sessions.
    - Add `@Index(type: IndexType.value)` on `startedAt` and `taskId`.
    - Add `PomodoroSession toEntity()` and `static PomodoroSessionModel fromEntity(PomodoroSession)`
      conversion methods.
    - _Requirements: 9.2, 16.2 / Design: Data Models — PomodoroSessionModel_
  - [x] 3.2 Create `lib/features/pomodoro/data/repositories/isar_pomodoro_session_repository.dart`
    - Implements `PomodoroSessionRepository`. Constructor-injected `Isar` instance.
    - `create(session)`: writes in `writeTxn`, returns entity with assigned id.
    - `getAll()`: reads all `PomodoroSessionModel` records, maps to entities.
    - `getByDateRange(start, end)`: uses Isar `where()` filter on `startedAt` index,
      inclusive start, exclusive end.
    - `getByTaskId(taskId)`: filters by `taskId` index.
    - `getByNullTask()`: filters where `taskId` is null.
    - Wraps Isar exceptions in `PersistenceException`.
    - _Requirements: 9.1, 9.5, 9.7, 16.4, 16.5, 16.6 / Design: Data Layer_
  - [x] 3.3 Update `lib/core/database/isar_database.dart`
    - Add `PomodoroSessionModelSchema` to the `Isar.open(schemas: [...])` call.
    - Import `pomodoro_session_model.dart`.
    - _Requirements: 12.3 / Design: Architecture — Dependency Rules_

---

### Group 4 — State Management

- [x] 4. Implement `PomodoroController`
  - [x] 4.1 Create `lib/features/pomodoro/presentation/controllers/pomodoro_controller.dart`
    - `extends ChangeNotifier with WidgetsBindingObserver`. Constructor parameters:
      `SavePomodoroSessionUseCase`, `List<PomodoroTaskOption> Function() taskListProvider`,
      `PomodoroConfig config` (default const), `Clock clock` (default `SystemClock()`).
    - Declare full state shape: `_currentMode`, `_status`, `_remainingDuration`, `_targetEndTime`,
      `_preservedRemaining`, `_timer`, `_completedMode`, `_cycleCount`, `_sessionStartedAt`,
      `_selectedTaskId`, `_selectedTaskTitle`, `_isLoading`, `_errorMessage`, `_pendingSession`.
    - Expose all public getters: `currentMode`, `status`, `remainingDuration`, `cycleCount`,
      `selectedTaskId`, `selectedTaskTitle`, `isLoading`, `errorMessage`, `hasPendingSession`,
      `config`, `availableTasks`, `completedMode`.
    - `completedMode` getter: returns `_completedMode` (non-null only when `status == completed`).
    - Initial state: `TimerMode.focus`, `TimerStatus.idle`, remaining = 25 min, cycleCount = 0,
      completedMode = null.
    - _Requirements: 1.6, 11.1, 11.2, 11.6 / Design: State Management — State Shape_
  - [x] 4.2 Implement timer lifecycle methods in `PomodoroController`
    - `start()`: precondition `status == idle || completed`. Clear `_completedMode = null`.
      Set `targetEndTime = now + remaining`, status = running, record `_sessionStartedAt`
      for Focus mode. Call `_startTimer()`.
    - `pause()`: precondition `status == running`. Set `_preservedRemaining = targetEndTime - now`,
      status = paused, cancel timer.
    - `resume()`: precondition `status == paused`. Set `targetEndTime = now + _preservedRemaining`,
      status = running. Call `_startTimer()`.
    - `reset()`: precondition `status == running || paused`. Cancel timer, status = idle,
      remaining = full duration of current mode, `_completedMode = null`. Preserve selected task.
    - `skip()`: precondition `status == running || paused`. Cancel timer, advance to next mode
      via `_nextMode()`, status = idle, remaining = full duration of next mode,
      `_completedMode = null`. If skipping Long Break, reset cycleCount to 0.
    - All methods ignore invalid preconditions (no-op).
    - _Requirements: 2.1, 2.2, 2.4, 3.1, 3.2, 3.4, 3.5, 4.1, 4.2, 4.4, 4.5, 5.1, 5.2, 5.4, 5.5, 5.6 / Design: Timer Lifecycle_
  - [x] 4.3 Implement `_onTick`, `_startTimer`, and duplicate completion guard in `PomodoroController`
    - `_startTimer()`: cancel existing timer, create `Timer.periodic(1s, _onTick)`.
    - `_onTick(_)`: FIRST check guard `if (_status != TimerStatus.running) return;`.
      Calculate `remaining = targetEndTime - clock.now()`, clamp to `Duration.zero`.
      If remaining <= zero, call `_onCompletion()`. Otherwise update `_remainingDuration`
      and `notifyListeners()`.
    - The guard ensures that if multiple callbacks fire after backgrounding, only the first
      processes completion.
    - _Requirements: 2.3, 6.1, 6.5, 10.1, 10.2, 10.4, 10.5, 10.6, 19.9 / Design: Timer Lifecycle — Duplicate Completion Prevention_
  - [x] 4.4 Implement `_onCompletion` and cycle progression in `PomodoroController`
    - Guard: `if (_status != TimerStatus.running) return;` (prevents duplicate completion).
    - Cancel timer BEFORE processing: `_timer?.cancel(); _timer = null;`.
    - Store `_completedMode = _currentMode` BEFORE advancing (captures which mode just finished).
    - Set status = completed.
    - If Focus mode: increment cycleCount, persist session via `_saveSessionUseCase.call(...)`.
      Catch exceptions → store error message + pending session for retry.
    - Call `_advanceToNextMode()`: determine next mode via `_nextMode()`, set `_currentMode`,
      set `_remainingDuration = config.durationFor(nextMode)`. If Long Break completed/skipped,
      reset cycleCount to 0.
    - Single `notifyListeners()` at the end — UI sees final consistent state: `completedMode`
      (the mode that finished), `currentMode` (the next mode), `remainingDuration` (next
      mode's full duration).
    - Status remains `Completed` — user sees "Session finished" with Start button.
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.6, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6 / Design: Timer Lifecycle — Natural Completion_
  - [x] 4.5 Implement task association, title resolution, and session building in `PomodoroController`
    - `selectTask(int? taskId, String? taskTitle)`: only effective when idle or completed.
      Stores `_selectedTaskId` and `_selectedTaskTitle`.
    - `_resolveTaskTitleSnapshot()`: if `_selectedTaskId` is null, return null.
      Look up the task in latest `_taskListProvider()` result by id. If found, return its
      current title. If not found (deleted), fall back to `_selectedTaskTitle`.
    - `_buildSession()`: constructs `PomodoroSession` from current state:
      `startedAt = _sessionStartedAt`, `completedAt = clock.now()`,
      `plannedDurationSeconds = config.focusDuration.inSeconds`,
      `actualDurationSeconds = config.focusDuration.inSeconds`,
      `taskId = _selectedTaskId`, `taskTitleSnapshot = _resolveTaskTitleSnapshot()`.
    - _Requirements: 8.3, 8.4, 8.5, 8.6, 8.7 / Design: State Management — Task Title Snapshot Resolution_
  - [x] 4.6 Implement error handling and retry in `PomodoroController`
    - `clearError()`: sets `_errorMessage = null`, notifyListeners. Does NOT clear
      `_pendingSession` — session remains available for retry.
    - `retryPersistence()`: if `_pendingSession != null`, re-attempt
      `_saveSessionUseCase.call(_pendingSession!)`. On success clear pending + error.
      On failure update error message.
    - `hasPendingSession` getter: returns `_pendingSession != null`.
    - _Requirements: 17.2, 17.3, 17.4, 17.5, 17.7 / Design: Error Handling_
  - [x] 4.7 Implement `init()`, `dispose()`, and lifecycle observer in `PomodoroController`
    - `init()`: call `WidgetsBinding.instance.addObserver(this)`, set `_isLoading = false`,
      notifyListeners.
    - `didChangeAppLifecycleState(state)`: if `state == AppLifecycleState.resumed` and
      `_status == TimerStatus.running`, call `_recalculateOnResume()`.
    - `_recalculateOnResume()`: calculate remaining from `_targetEndTime`. If <= 0, call
      `_onCompletion()`. Otherwise update `_remainingDuration` and notifyListeners.
    - `dispose()`: call `WidgetsBinding.instance.removeObserver(this)`, cancel `_timer`,
      call `super.dispose()`.
    - _Requirements: 10.3, 10.5, 10.7, 10.8, 11.6 / Design: Application Lifecycle Handling_

---

### Group 5 — Presentation Widgets

- [x] 5. Implement presentation widgets
  - [x] 5.1 Create `lib/features/pomodoro/presentation/widgets/timer_display.dart`
    - Stateless widget. Parameters: `Duration remainingDuration`, `Duration totalDuration`,
      `TimerStatus status`.
    - Layout: `Stack` with `CircularProgressIndicator` (determinate, value = 1.0 - remaining/total)
      and centered `Text` showing `MM:SS` format. Font size >= 32sp.
    - Semantics node with label "N minutes M seconds remaining".
    - _Requirements: 13.2, 13.3, 15.3, 15.7 / Design: Component Breakdown — TimerDisplay_
  - [x] 5.2 Create `lib/features/pomodoro/presentation/widgets/timer_controls.dart`
    - Stateless widget. Parameters: `TimerStatus status`, `VoidCallback onStart`,
      `VoidCallback onPause`, `VoidCallback onResume`, `VoidCallback onReset`,
      `VoidCallback onSkip`.
    - Button visibility: Idle/Completed → Start only. Running → Pause, Reset, Skip.
      Paused → Resume, Reset, Skip.
    - All buttons >= 48x48dp touch targets with semantic labels.
    - Uses `FilledButton` for primary action, `OutlinedButton` for secondary.
    - _Requirements: 13.4, 13.5, 13.6, 15.1, 15.2, 15.4 / Design: Component Breakdown — TimerControls_
  - [x] 5.3 Create `lib/features/pomodoro/presentation/widgets/task_selector_widget.dart`
    - Stateless widget. Parameters: `List<PomodoroTaskOption> tasks`, `int? selectedTaskId`,
      `bool enabled`, `ValueChanged<(int?, String?)> onChanged`.
    - `DropdownButtonFormField` with first option "No task" (null). Tasks sorted:
      `isCompleted == false` before `isCompleted == true`. Disabled when `enabled == false`.
    - If no tasks exist, show disabled field with "No tasks available" hint.
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.11 / Design: Component Breakdown — TaskSelectorWidget_
  - [x] 5.4 Create `lib/features/pomodoro/presentation/widgets/cycle_progress_indicator.dart`
    - Stateless widget. Parameters: `int cycleCount`.
    - Displays "N / 4" text label where N = cycleCount.
    - _Requirements: 13.9 / Design: Component Breakdown — CycleProgressIndicator_

---

### Group 6 — Screen + Navigation

- [ ] 6. Implement Pomodoro screen and navigation wiring
  - [ ] 6.1 Create `lib/features/pomodoro/presentation/screens/pomodoro_screen.dart`
    - `Scaffold` with centered column: Timer_Mode label, `TimerDisplay`,
      `CycleProgressIndicator`, `TimerControls`, `TaskSelectorWidget`.
    - Uses `context.watch<PomodoroController>()` / `ListenableBuilder` to rebuild on state changes.
    - Shows SnackBar with Retry action when `controller.errorMessage != null`.
    - Shows persistent retry affordance (e.g., small button) when `controller.hasPendingSession`
      is true, even after SnackBar dismissal.
    - TaskSelector enabled only when status is idle or completed.
    - Visually distinguishes Idle, Running, Paused, Completed states with text labels.
    - Completed state: uses `controller.completedMode` to display "Focus session finished" or
      "Short break finished" etc., and `controller.currentMode` to display "Short break ready"
      or "Focus ready". Shows Start button for the next session.
    - Material 3 components, colors via `Theme.of(context)`.
    - Semantics announcement on status change.
    - _Requirements: 6.2, 13.1, 13.7, 13.8, 13.9, 13.10, 13.11, 13.12, 15.5, 15.6, 17.7 / Design: Component Breakdown — PomodoroScreen_
  - [ ] 6.2 Update `lib/app/router.dart` — register `/pomodoro` route
    - Add `static const String pomodoro = '/pomodoro';` to `Routes` class.
    - Add case in `onGenerateRoute` that returns `MaterialPageRoute` to `PomodoroScreen`.
    - Import `PomodoroScreen`.
    - _Requirements: 14.1 / Design: Architecture — Navigation_
  - [ ] 6.3 Update `lib/app/app.dart` — wire `PomodoroController` at app level
    - Replace single `ChangeNotifierProvider<TodoController>` with `MultiProvider` containing
      both `TodoController` and `PomodoroController`.
    - Instantiate `IsarPomodoroSessionRepository`, `SavePomodoroSessionUseCase`.
    - Map tasks: `taskListProvider: () => todoController.allTasks.map((task) =>
      PomodoroTaskOption(id: task.id, title: task.title,
      isCompleted: task.status == TaskStatus.completed)).toList()`.
    - Import `TaskStatus` from `features/todo/domain/entities/task_status.dart` in `app.dart`
      (the composition root is permitted to reference both features).
    - Call `..init()` on the `PomodoroController`.
    - _Requirements: 12.5, 14.2, 14.3, 14.4 / Design: Cross-Feature Task Access + Provider Scope_
  - [ ] 6.4 Update `lib/main.dart` if needed
    - Verify `openIsar()` now includes `PomodoroSessionModelSchema` (handled in 3.3).
    - No additional changes expected unless import paths need updating.
    - _Requirements: 12.1 / Design: Architecture_

---

### Group 7 — Checkpoint

- [ ] 7. Checkpoint — all code compiles and analyzes clean
  - Run `flutter analyze`. Ensure no errors or warnings. Verify `PomodoroScreen` renders on
    device/emulator with idle state showing 25:00. Ask the user if questions arise.

---

### Group 8 — Unit Tests (Controller)

- [ ] 8. Unit tests for `PomodoroController` state transitions
  - [ ]* 8.1 Write unit tests for start, pause, resume state transitions
    - Fake `Clock`, fake `PomodoroSessionRepository` (in-memory list), fake task list provider
      returning `List<PomodoroTaskOption>`.
    - Start from idle: status → running, targetEndTime set.
    - Start from completed: status → running, begins countdown of prepared next mode.
    - Pause from running: status → paused, preservedRemaining captured.
    - Resume from paused: status → running, new targetEndTime = now + preserved.
    - Invalid transitions are no-ops (start when running, pause when idle, etc.).
    - _Requirements: 2.1, 2.4, 3.1, 3.2, 3.4, 3.5, 19.1 / Design: Testing Strategy_
  - [ ]* 8.2 Write unit tests for reset and skip
    - Reset from running: status → idle, mode unchanged, remaining = full duration.
    - Reset from paused: same behavior.
    - Reset preserves selected task association.
    - Skip from running (Focus): advances to next break, status → idle, cycleCount unchanged.
    - Skip from running (ShortBreak): advances to Focus, status → idle.
    - Skip from Long Break: advances to Focus, resets cycleCount to 0, status → idle.
    - Invalid: reset/skip when idle or completed → no-op.
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 4.6, 5.1, 5.2, 5.4, 5.5, 5.6, 19.1 / Design: Testing Strategy_
  - [ ]* 8.3 Write unit tests for full cycle progression
    - Simulate 4 complete focus sessions with natural completion.
    - Verify mode sequence: F→SB→F→SB→F→SB→F→LB.
    - Verify cycleCount increments: 0→1→2→3→4.
    - After Long Break completes: cycleCount resets to 0, mode → Focus.
    - Verify status is `Completed` after each natural completion (not Idle).
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 19.2 / Design: Testing Strategy_
  - [ ]* 8.4 Write unit tests for pause/resume preserves duration
    - Start timer with fake clock at T0. Advance clock to T0+10s, pause.
    - Verify preservedRemaining = (25min - 10s).
    - Advance clock by arbitrary amount (e.g., 5 min). Resume.
    - Verify new targetEndTime = now + preservedRemaining.
    - _Requirements: 3.6, 19.3 / Design: Testing Strategy_
  - [ ]* 8.5 Write unit tests for drift resistance
    - Start timer with fake clock. Advance clock by 3 seconds between ticks.
    - Verify remaining is calculated from targetEndTime, not decremented by 1s per tick.
    - Advance clock past targetEndTime → completion triggered immediately.
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 19.4 / Design: Testing Strategy_
  - [ ]* 8.6 Write unit tests for task association and title snapshot resolution
    - Select task when idle: selectedTaskId and selectedTaskTitle updated.
    - Select task when running: ignored (no change).
    - Complete focus session with task selected (task still in list): persisted session has
      correct taskId and current title from taskListProvider.
    - Complete focus session with task selected (task deleted from list): persisted session
      uses fallback title from selection time.
    - Complete focus session with no task: persisted session has null taskId and null snapshot.
    - _Requirements: 8.3, 8.4, 8.5, 8.6, 8.7, 19.5 / Design: Testing Strategy_
  - [ ]* 8.7 Write unit tests for error handling, retry, and clearError behavior
    - Mock repository throws on create → controller sets errorMessage, pendingSession stored.
    - Timer continues running (status not affected by persistence failure).
    - Call clearError() → error cleared, but `hasPendingSession` remains true.
    - Call retryPersistence with mock succeeding → error cleared, pendingSession cleared,
      `hasPendingSession` becomes false.
    - Call retryPersistence with mock failing again → error updated, pendingSession retained.
    - _Requirements: 9.7, 17.2, 17.3, 17.4, 17.5, 17.7 / Design: Testing Strategy_
  - [ ]* 8.8 Write unit tests for lifecycle observer and duplicate completion prevention
    - Simulate foreground return (call `didChangeAppLifecycleState(resumed)`) while status is
      Running and remaining time has elapsed → verify completion triggered.
    - Simulate foreground return with time remaining → verify remaining recalculated, no
      completion triggered.
    - Simulate `_onTick` firing after `_onCompletion` already ran (status is Completed) → verify
      no-op (guard prevents duplicate processing).
    - Simulate lifecycle resume and tick both detecting remaining <= 0 → verify session persisted
      exactly once.
    - _Requirements: 10.3, 10.8, 19.9 / Design: Testing Strategy — Duplicate Completion Prevention_

---

### Group 9 — Unit Tests (Use Cases + Repository)

- [ ] 9. Unit tests for use cases and repository
  - [ ]* 9.1 Write unit tests for `SavePomodoroSessionUseCase`
    - Fake in-memory repository.
    - Happy path: returned session has assigned id, all fields match input.
    - Repository throws: exception propagates to caller.
    - _Requirements: 9.1, 19.6 / Design: Testing Strategy_
  - [ ]* 9.2 Write unit tests for `GetSessionsByTaskIdUseCase` routing
    - Non-null taskId → calls `getByTaskId(taskId)`.
    - Null taskId → calls `getByNullTask()`.
    - Returns correct filtered results from fake repository.
    - _Requirements: 16.5, 16.6 / Design: Testing Strategy_
  - [ ]* 9.3 Write unit tests for `IsarPomodoroSessionRepository` CRUD
    - Open real Isar in temporary directory.
    - `create`: returns entity with auto-assigned id, retrievable via `getAll`.
    - `getByDateRange`: returns only sessions within range (inclusive start, exclusive end).
    - `getByTaskId`: returns only matching sessions.
    - `getByNullTask`: returns only sessions with null taskId.
    - Empty results return empty list, not error.
    - _Requirements: 9.1, 9.5, 16.4, 16.5, 16.6, 19.6 / Design: Testing Strategy_
  - [ ]* 9.4 Write unit tests for model conversion (toEntity / fromEntity)
    - Create a `PomodoroSession` entity, convert to model via `fromEntity`, convert back via
      `toEntity`. Assert all field values are identical.
    - Test with null taskId/taskTitleSnapshot and with non-null values.
    - _Requirements: 9.2, 19.7 / Design: Testing Strategy_

---

### Group 10 — Property-Based Tests

All property tests use `dart_fast_check`. Each runs a minimum of 100 iterations. In-memory fake
repositories and fake `Clock` — no Isar required.

- [ ] 10. Property-based tests for correctness properties 1–5
  - [ ]* 10.1 Property 1: Timer never produces negative remaining time
    - // Feature: pomodoro, Property 1: Timer never produces negative remaining time
    - Arbitrary: random sequence of start/pause/resume/reset/skip actions with random clock
      advances between each action.
    - Assert `controller.remainingDuration >= Duration.zero` after every action.
    - **Validates: Requirements 6.1, 6.5**
  - [ ]* 10.2 Property 2: Cycle count is always between 0 and 4 inclusive
    - // Feature: pomodoro, Property 2: Cycle count is always between 0 and 4 inclusive
    - Arbitrary: random sequence of timer operations (start, complete, skip, reset) with
      random modes.
    - Assert `0 <= controller.cycleCount <= 4` after every operation.
    - **Validates: Requirements 7.1, 7.2, 7.5, 7.8**
  - [ ]* 10.3 Property 3: Only natural focus completion increments cycle count
    - // Feature: pomodoro, Property 3: Only natural focus completion increments cycle count
    - Arbitrary: random operation sequences.
    - Assert cycleCount changes by +1 only on focus natural completion. Reset/skip/break
      completion never increment (Long Break resets to 0).
    - **Validates: Requirements 4.4, 5.2, 6.3, 6.6**
  - [ ]* 10.4 Property 4: Reset preserves current Timer_Mode
    - // Feature: pomodoro, Property 4: Reset preserves current Timer_Mode
    - Arbitrary: any TimerMode, timer in Running or Paused state.
    - After reset: mode unchanged, remaining = full configured duration for that mode.
    - **Validates: Requirements 4.1**
  - [ ]* 10.5 Property 5: Pause then resume preserves total active countdown time
    - // Feature: pomodoro, Property 5: Pause then resume preserves total active countdown time
    - Arbitrary: any running timer with remaining R, pause at arbitrary point.
    - After resume: targetEndTime = clock.now() + R_at_pause.
    - **Validates: Requirements 3.1, 3.2, 3.6**

- [ ] 11. Property-based tests for correctness properties 6–8
  - [ ]* 11.1 Property 6: Session persistence round-trip
    - // Feature: pomodoro, Property 6: Session persistence round-trip
    - Arbitrary: valid `PomodoroSession` with random field values.
    - Write to fake repository, read back. Assert all fields equal.
    - **Validates: Requirements 9.2, 16.2**
  - [ ]* 11.2 Property 7: Only naturally completed focus sessions are persisted
    - // Feature: pomodoro, Property 7: Only naturally completed focus sessions are persisted
    - Arbitrary: random sequence of timer operations.
    - Assert repository size increases by 1 only on focus natural completion.
    - No records for: reset focus, skipped focus, any break operation.
    - **Validates: Requirements 5.3, 6.4, 6.6, 9.1, 9.3, 9.4**
  - [ ]* 11.3 Property 8: Cycle progression follows the defined sequence
    - // Feature: pomodoro, Property 8: Cycle progression follows the defined sequence
    - Arbitrary: N consecutive natural completions without resets or skips (N in 1..16).
    - Assert mode sequence matches: F→SB→F→SB→F→SB→F→LB repeating.
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

- [ ] 12. Property-based tests for correctness properties 9–12
  - [ ]* 12.1 Property 9: Invalid state transitions are no-ops
    - // Feature: pomodoro, Property 9: Invalid state transitions are no-ops
    - Arbitrary: any timer state + any action whose precondition is not met.
    - Assert all observable state (mode, status, remaining, cycleCount, selectedTask) unchanged.
    - **Validates: Requirements 2.4, 3.4, 3.5, 4.5, 5.6**
  - [ ]* 12.2 Property 10: Task association is stored correctly on persistence
    - // Feature: pomodoro, Property 10: Task association is stored correctly on persistence
    - Arbitrary: complete a focus session with random task selection (some null, some non-null).
    - Assert persisted session's taskId and taskTitleSnapshot match selection state.
    - When task is in provider list: snapshot uses current title from provider.
    - When task is NOT in provider list: snapshot uses fallback title from selection.
    - **Validates: Requirements 8.6, 8.7**
  - [ ]* 12.3 Property 11: Date range and task-id queries return correct subsets
    - // Feature: pomodoro, Property 11: Date range and task-id queries return correct subsets
    - Arbitrary: set of sessions with random startedAt and taskId values + random query params.
    - Assert `getByDateRange` returns exactly sessions where `start <= startedAt < end`.
    - Assert `getByTaskId` returns exactly sessions with matching taskId.
    - Assert `getByNullTask` returns exactly sessions with null taskId.
    - **Validates: Requirements 16.4, 16.5, 16.6**
  - [ ]* 12.4 Property 12: Completion fires at most once per running session
    - // Feature: pomodoro, Property 12: Completion fires at most once per running session
    - Arbitrary: start a focus session, advance clock past end time, invoke `_onTick` multiple
      times and/or `didChangeAppLifecycleState(resumed)`.
    - Assert repository receives exactly one `create` call per completed session.
    - Assert cycleCount increments by exactly 1 per completed focus session.
    - **Validates: Requirements 6.1, 10.3, 10.8**

---

### Group 11 — Widget Tests

- [ ] 13. Widget tests for Pomodoro screen states
  - [ ]* 13.1 Widget test: `PomodoroScreen` — Idle state
    - Mock `PomodoroController` in idle state. Pump `PomodoroScreen`.
    - Assert: Start button visible. Pause, Resume, Reset, Skip NOT visible.
    - Assert: Timer shows "25:00". Mode label shows "Focus".
    - _Requirements: 13.4, 13.10, 19.8 / Design: Testing Strategy — Widget Tests_
  - [ ]* 13.2 Widget test: `PomodoroScreen` — Running state
    - Mock controller in running state with remaining = 20:00.
    - Assert: Pause, Reset, Skip visible. Start, Resume NOT visible.
    - Assert: TaskSelector is disabled.
    - _Requirements: 13.5, 13.8, 19.8 / Design: Testing Strategy_
  - [ ]* 13.3 Widget test: `PomodoroScreen` — Paused state
    - Mock controller in paused state.
    - Assert: Resume, Reset, Skip visible. Start, Pause NOT visible.
    - Assert: Paused state label visible.
    - _Requirements: 13.6, 13.10, 19.8 / Design: Testing Strategy_
  - [ ]* 13.4 Widget test: `PomodoroScreen` — Completed state
    - Mock controller in completed state with `completedMode = TimerMode.focus` and
      `currentMode = TimerMode.shortBreak` (next mode set).
    - Assert: Start button visible. Completed message shows "Focus session finished" (using
      `completedMode`) and "Short break ready" (using `currentMode`).
    - Assert: TaskSelector is enabled.
    - _Requirements: 6.2, 7.6, 13.4, 19.8 / Design: Testing Strategy_
  - [ ]* 13.5 Widget test: `TaskSelectorWidget` — enabled/disabled states
    - Pump TaskSelectorWidget with `enabled = true` and `List<PomodoroTaskOption>`:
      dropdown is tappable.
    - Pump with `enabled = false`: dropdown is disabled.
    - Pump with empty task list: shows "No tasks available" hint.
    - _Requirements: 8.3, 8.4, 8.11 / Design: Testing Strategy_
  - [ ]* 13.6 Widget test: Error SnackBar with Retry
    - Mock controller with `errorMessage = "Could not save session."`.
    - Assert SnackBar visible with error text and Retry action button.
    - Tap Retry: assert `controller.retryPersistence()` invoked.
    - _Requirements: 17.2, 17.4, 17.6 / Design: Testing Strategy_
  - [ ]* 13.7 Widget test: Persistent retry affordance
    - Mock controller with `hasPendingSession = true` and `errorMessage = null`.
    - Assert persistent retry button/indicator is visible.
    - Tap it: assert `controller.retryPersistence()` invoked.
    - _Requirements: 17.5, 17.7 / Design: Testing Strategy_
  - [ ]* 13.8 Widget test: `CycleProgressIndicator` display
    - Pump with cycleCount = 0: shows "0 / 4".
    - Pump with cycleCount = 3: shows "3 / 4".
    - _Requirements: 13.9 / Design: Testing Strategy_
  - [ ]* 13.9 Widget test: `TimerDisplay` MM:SS format
    - Pump with remaining = Duration(minutes: 5, seconds: 3): shows "05:03".
    - Pump with remaining = Duration.zero: shows "00:00".
    - Pump with remaining = Duration(minutes: 25): shows "25:00".
    - _Requirements: 13.2, 15.7 / Design: Testing Strategy_

---

### Group 12 — Integration Tests

- [ ] 14. Integration tests
  - [ ]* 14.1 Integration test: Isar round-trip for `PomodoroSessionModel`
    - Open real Isar in temporary directory. Write a `PomodoroSessionModel`. Read back by id.
    - Assert all fields equal written values (validates Property 6 at DB layer).
    - _Requirements: 9.2, 9.5 / Design: Testing Strategy — Integration Tests_
  - [ ]* 14.2 Integration test: Date-range and task-id queries
    - Populate Isar with multiple sessions spanning different dates and task IDs.
    - Query by date range: assert correct subset returned.
    - Query by taskId: assert correct subset returned.
    - Query with no matches: assert empty list returned.
    - _Requirements: 16.4, 16.5, 16.6 / Design: Testing Strategy — Integration Tests_
  - [ ]* 14.3 Integration test: Full timer lifecycle
    - Instantiate real `PomodoroController` with real Isar repository and fake clock.
    - Start → advance clock past focus duration → verify session persisted in Isar.
    - Verify persisted session fields: `actualDurationSeconds == plannedDurationSeconds ==
      config.focusDuration.inSeconds`.
    - _Requirements: 6.4, 9.1 / Design: Testing Strategy — Integration Tests_

---

### Group 13 — Final Checkpoint

- [ ] 15. Final checkpoint — all tests pass
  - Run `flutter test`. Ensure all unit, property-based, widget, and integration tests pass.
    Run `flutter analyze` to confirm no issues. Ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP build; all test sub-tasks
  fall in this category.
- Each task references specific requirements and design sections for full traceability.
- The implementation language is **Dart / Flutter** throughout.
- Property tests use `dart_fast_check` (confirm latest pub.dev version before implementing).
- Widget tests use a mock or fake `PomodoroController` — no Isar required in widget test scope.
- Integration tests (Group 12) require a real Isar instance opened in a temporary directory.
- Fake clocks in tests must produce controlled UTC DateTime values (e.g.,
  `DateTime.utc(2024, 1, 15, 10, 0, 0)`) to match production `SystemClock` behavior.
- The `PomodoroController` is provided at the app level via `MultiProvider` so it survives
  navigation and the timer continues running when the user navigates away.
- Cross-feature task access uses `PomodoroTaskOption` — a Pomodoro-owned type. The mapping from
  Todo `Task` to `PomodoroTaskOption` happens only in `app.dart` (composition root).
- Checkpoints at tasks 7 and 15 are natural review gates before proceeding to the next phase.
- `SessionResult` was intentionally removed — the MVP only persists naturally completed Focus
  sessions so no discriminator is needed.
- `clearError()` clears the visible error message but does NOT discard `_pendingSession`.
- Natural completion leaves status as `Completed` (not `Idle`). Only Skip and Reset transition
  to Idle.
- `completedMode` is non-null only when `status == completed`. It is cleared to null on `start()`,
  `skip()`, and `reset()`. The UI uses it to display which mode just finished.
- `actualDurationSeconds` equals `plannedDurationSeconds` for naturally completed sessions
  because active countdown time always equals the configured duration.

---

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "2.4", "2.5"] },
    { "id": 3, "tasks": ["3.1"] },
    { "id": 4, "tasks": ["3.2", "3.3"] },
    { "id": 5, "tasks": ["4.1"] },
    { "id": 6, "tasks": ["4.2", "4.3"] },
    { "id": 7, "tasks": ["4.4", "4.5", "4.6"] },
    { "id": 8, "tasks": ["4.7"] },
    { "id": 9, "tasks": ["5.1", "5.2", "5.3", "5.4"] },
    { "id": 10, "tasks": ["6.1"] },
    { "id": 11, "tasks": ["6.2", "6.3", "6.4"] },
    { "id": 12, "tasks": ["8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8"] },
    { "id": 13, "tasks": ["9.1", "9.2", "9.3", "9.4"] },
    { "id": 14, "tasks": ["10.1", "10.2", "10.3", "10.4", "10.5"] },
    { "id": 15, "tasks": ["11.1", "11.2", "11.3"] },
    { "id": 16, "tasks": ["12.1", "12.2", "12.3", "12.4"] },
    { "id": 17, "tasks": ["13.1", "13.2", "13.3", "13.4", "13.5", "13.6", "13.7", "13.8", "13.9"] },
    { "id": 18, "tasks": ["14.1", "14.2", "14.3"] }
  ]
}
```

### Dependency narrative

```
Group 1 (Domain enums + entities) → Group 2 (Repository + Use Cases) → Group 3 (Data Layer)
Group 2 (Use Cases) → Group 4 (State Management — PomodoroController)
Group 3 (Data Layer) → Group 4 (State Management)
Group 4 (State Management) → Group 5 (Presentation Widgets)
Group 5 (Widgets) → Group 6 (Screen + Navigation Wiring)
Group 6 (Wiring) → Group 7 (Checkpoint)
Groups 4–6 → Groups 8–12 (All Test Layers)
Groups 8–12 (Tests) → Group 13 (Final Checkpoint)
```
