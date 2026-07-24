# Design Document — Pomodoro Feature

## Overview

The Pomodoro feature is implemented as a self-contained module under `lib/features/pomodoro/` following Feature-First Clean Architecture. It provides a drift-resistant countdown timer that cycles through Focus, Short Break, and Long Break modes following the standard Pomodoro Technique sequence. The timer uses absolute `Target_End_Time` timestamps rather than decrementing counters to maintain accuracy across UI rebuilds, navigation, and brief background periods. An injectable `Clock` abstraction enables deterministic testing. Completed focus sessions are persisted to Isar for future statistics consumption. Cross-feature task access is mediated through a Pomodoro-owned `PomodoroTaskOption` type — the mapping from Todo's `Task` entity happens exclusively in the app composition root. The `PomodoroController` is provided at the app level so it survives navigation away from the Pomodoro screen. The controller uses `WidgetsBindingObserver` to immediately recalculate remaining time on foreground return.

---

## Architecture

The feature maps to the standard internal layout:

```
lib/features/pomodoro/
├── data/
│   ├── models/
│   │   └── pomodoro_session_model.dart   # @collection — Isar schema
│   └── repositories/
│       └── isar_pomodoro_session_repository.dart
├── domain/
│   ├── entities/
│   │   ├── timer_mode.dart               # Focus, ShortBreak, LongBreak
│   │   ├── timer_status.dart             # Idle, Running, Paused, Completed
│   │   ├── pomodoro_task_option.dart     # Minimal read-only task type
│   │   ├── pomodoro_session.dart         # Immutable domain entity
│   │   ├── pomodoro_config.dart          # Duration configuration value object
│   │   └── clock.dart                    # Injectable time source
│   ├── repositories/
│   │   └── pomodoro_session_repository.dart  # Abstract interface
│   ├── use_cases/
│   │   ├── save_pomodoro_session_use_case.dart
│   │   ├── get_sessions_use_case.dart
│   │   ├── get_sessions_by_date_range_use_case.dart
│   │   └── get_sessions_by_task_id_use_case.dart
│   └── exceptions/
│       └── persistence_exception.dart
├── presentation/
│   ├── controllers/
│   │   └── pomodoro_controller.dart
│   ├── screens/
│   │   └── pomodoro_screen.dart
│   └── widgets/
│       ├── timer_display.dart
│       ├── timer_controls.dart
│       ├── task_selector_widget.dart
│       └── cycle_progress_indicator.dart
└── pomodoro_module.dart
```

### Dependency Rules

- `presentation/` imports only from `domain/entities/` and the controller.
- `data/` implements interfaces from `domain/repositories/`.
- The Isar instance is sourced from `core/database/` and injected into the repository constructor.
- The Pomodoro feature does **not** import from `features/todo/data/` or `features/todo/domain/`.
- Cross-feature task access uses `PomodoroTaskOption` — a type owned by the Pomodoro feature. The mapping from Todo's `Task` to `PomodoroTaskOption` occurs in the app composition root (`app.dart`).

### Provider Scope Decision

The `PomodoroController` is provided at the **app level** (in `FocusFlowApp`), not at the route level. This ensures the timer continues running when the user navigates away from the Pomodoro screen. The `TodoController` is also app-level, so its task list is available for mapping into `PomodoroTaskOption` instances at any time.

---

## Data Models

### TimerMode Enum

```dart
// lib/features/pomodoro/domain/entities/timer_mode.dart
enum TimerMode { focus, shortBreak, longBreak }
```

### TimerStatus Enum

```dart
// lib/features/pomodoro/domain/entities/timer_status.dart
enum TimerStatus { idle, running, paused, completed }
```

### PomodoroTaskOption (Pomodoro-Owned Task Type)

```dart
// lib/features/pomodoro/domain/entities/pomodoro_task_option.dart

/// Minimal read-only representation of a selectable task for the Pomodoro feature.
/// This type is owned by the Pomodoro feature and decouples it from the Todo domain.
class PomodoroTaskOption {
  const PomodoroTaskOption({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final bool isCompleted;
}
```

This type exists so the Pomodoro feature never imports from `features/todo/`. The mapping from Todo `Task` → `PomodoroTaskOption` happens in the app composition root.

### PomodoroConfig (Value Object)

```dart
// lib/features/pomodoro/domain/entities/pomodoro_config.dart
class PomodoroConfig {
  const PomodoroConfig({
    this.focusDuration = const Duration(minutes: 25),
    this.shortBreakDuration = const Duration(minutes: 5),
    this.longBreakDuration = const Duration(minutes: 15),
    this.sessionsBeforeLongBreak = 4,
  });

  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int sessionsBeforeLongBreak;

  /// Returns the duration for the given [mode].
  Duration durationFor(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return focusDuration;
      case TimerMode.shortBreak:
        return shortBreakDuration;
      case TimerMode.longBreak:
        return longBreakDuration;
    }
  }
}
```

This separates duration configuration from timer logic. Durations are changed in one place without touching state transition or countdown code (Requirement 1.5).

### PomodoroSession (Domain Entity)

```dart
// lib/features/pomodoro/domain/entities/pomodoro_session.dart
class PomodoroSession {
  const PomodoroSession({
    required this.id,
    required this.timerMode,
    required this.startedAt,
    required this.completedAt,
    required this.plannedDurationSeconds,
    required this.actualDurationSeconds,
    this.taskId,
    this.taskTitleSnapshot,
  });

  final int id;
  final TimerMode timerMode;          // Always TimerMode.focus for persisted sessions
  final DateTime startedAt;           // UTC, millisecond precision
  final DateTime completedAt;         // UTC, millisecond precision
  final int plannedDurationSeconds;   // Configured focus duration in seconds
  final int actualDurationSeconds;    // Active countdown time in seconds (equals planned for natural completion)
  final int? taskId;                  // Nullable Todo task ID
  final String? taskTitleSnapshot;    // Snapshot of task title at persistence time
}
```

Note: `SessionResult` is intentionally omitted. The MVP only persists naturally completed Focus sessions — there is no need for a result discriminator. Every record in the repository is implicitly a completed Focus session.

### PomodoroSessionModel (Isar Collection)

| Field                    | Dart Type    | Nullable | Notes                                        |
|--------------------------|--------------|----------|----------------------------------------------|
| `id`                     | `Id`         | No       | Isar auto-increment primary key              |
| `timerModeIndex`         | `int`        | No       | Stored index of `TimerMode` enum (always 0)  |
| `startedAt`              | `DateTime`   | No       | UTC, millisecond precision                   |
| `completedAt`            | `DateTime`   | No       | UTC, millisecond precision                   |
| `plannedDurationSeconds` | `int`        | No       | Full focus duration in seconds               |
| `actualDurationSeconds`  | `int`        | No       | Active countdown time in seconds             |
| `taskId`                 | `int?`       | Yes      | Reference to Todo Task ID; nullable          |
| `taskTitleSnapshot`      | `String?`    | Yes      | Task title at time of recording              |

**Isar Indexes:**

```dart
@Index(type: IndexType.value)
late DateTime startedAt;       // date-range queries for statistics

@Index(type: IndexType.value)
late int? taskId;              // task-specific queries for statistics
```

---

## Repository Interfaces

### PomodoroSessionRepository

```dart
// lib/features/pomodoro/domain/repositories/pomodoro_session_repository.dart
abstract interface class PomodoroSessionRepository {
  /// Persists a new session and returns the saved entity with its assigned ID.
  Future<PomodoroSession> create(PomodoroSession session);

  /// Returns all persisted sessions, unordered.
  Future<List<PomodoroSession>> getAll();

  /// Returns sessions whose [startedAt] falls within [start, end).
  /// [start] is inclusive, [end] is exclusive.
  Future<List<PomodoroSession>> getByDateRange({
    required DateTime start,
    required DateTime end,
  });

  /// Returns sessions associated with the given [taskId].
  Future<List<PomodoroSession>> getByTaskId(int taskId);

  /// Returns sessions with no task association (taskId is null).
  Future<List<PomodoroSession>> getByNullTask();
}
```

All query methods return an empty list when no records match (Requirement 16.6).

---

## Use Cases

Each use case is a single class with one public `call()` method. Constructor-injected dependency is the `PomodoroSessionRepository`.

| Use Case Class                        | Inputs                                  | Return Type                    |
|---------------------------------------|-----------------------------------------|-------------------------------|
| `SavePomodoroSessionUseCase`          | `PomodoroSession session`               | `Future<PomodoroSession>`     |
| `GetSessionsUseCase`                  | _(none)_                                | `Future<List<PomodoroSession>>` |
| `GetSessionsByDateRangeUseCase`       | `{DateTime start, DateTime end}`        | `Future<List<PomodoroSession>>` |
| `GetSessionsByTaskIdUseCase`          | `int? taskId`                           | `Future<List<PomodoroSession>>` |

`GetSessionsByTaskIdUseCase` routes to `getByTaskId(taskId)` when taskId is non-null and to `getByNullTask()` when taskId is null.

`SavePomodoroSessionUseCase` delegates directly to `repository.create(session)`. No additional validation is needed — the controller already ensures only completed focus sessions are submitted.

---

## Timer Lifecycle Design

### Core Principle: Target_End_Time

The timer does **not** decrement an integer counter. Instead:

1. On **start**: `targetEndTime = clock.now() + remainingDuration`
2. On each **tick** (~1s): `remaining = targetEndTime - clock.now()`, clamped to `Duration.zero`
3. On **pause**: `_preservedRemaining = targetEndTime - clock.now()`
4. On **resume**: `targetEndTime = clock.now() + _preservedRemaining`

This ensures accuracy regardless of tick jitter, delayed callbacks, or background periods.

### Start

```
precondition: status == Idle || status == Completed
postcondition: status == Running, targetEndTime = now + remainingDuration, completedMode = null
side-effect: records startedAt = now (only for Focus mode), clears completedMode
```

When starting from `Completed` state, the next mode and its full duration have already been prepared during the completion flow. The controller clears `_completedMode = null` and begins the countdown of the already-set `_remainingDuration`.

When starting from `Idle` state after a reset, the remaining duration is already the full duration of the current mode.

**startedAt tracking**: The controller records `_sessionStartedAt = clock.now()` when transitioning to `Running` for a Focus session. This timestamp is NOT updated on resume — it captures when the user first pressed Start.

### Pause

```
precondition: status == Running
postcondition: status == Paused, _preservedRemaining = targetEndTime - now
side-effect: cancels timer subscription
```

### Resume

```
precondition: status == Paused
postcondition: status == Running, targetEndTime = now + _preservedRemaining
side-effect: creates new timer subscription
```

### Pause→Resume Elapsed Time Invariant

Because `_preservedRemaining` captures exactly how much time was left, and resume recalculates `targetEndTime` from that value, the total accumulated active countdown time (excluding paused intervals) from start to completion equals the configured duration, regardless of pause count or duration.

### Reset

```
precondition: status == Running || status == Paused
postcondition: status == Idle, currentMode unchanged, remaining = durationFor(currentMode), completedMode = null
side-effect: cancels timer subscription, does NOT persist session, does NOT increment cycleCount
```

Reset preserves the selected task association so the user can immediately start again without reselecting.

### Skip

```
precondition: status == Running || status == Paused
postcondition: status == Idle, currentMode = nextModeInCycle(), remaining = durationFor(nextMode), completedMode = null
side-effect: cancels timer subscription, does NOT persist session for focus, does NOT increment cycleCount
```

For breaks (Short/Long): skip advances to the next mode (always Focus). If skipping a Long Break, resets `cycleCount` to 0.

### Natural Completion

```
trigger: remaining reaches zero (on tick or on foreground return)
guard: status must be Running (prevents duplicate completion)
action: cancel timer FIRST, then process completion
postcondition: status == Completed, completedMode == mode that just finished, currentMode == next mode, remainingDuration == full duration of next mode
side-effects (Focus only): cycleCount++, persist PomodoroSession
side-effects (Break): no persistence, no cycle increment
```

**Detailed flow (single notifyListeners):**
1. Guard: `if (_status != TimerStatus.running) return;` — prevents duplicate completion.
2. Cancel and null the timer BEFORE processing (prevents re-entrant tick callbacks).
3. Store `_completedMode = _currentMode` — captures which mode just finished.
4. Set `_status = TimerStatus.completed`.
5. If Focus: increment `_cycleCount`, persist session via `_saveSessionUseCase.call(...)`. Catch exceptions → store error message + pending session for retry.
6. Advance to next mode: set `_currentMode = _nextMode()`, set `_remainingDuration = config.durationFor(_currentMode)`.
7. Single `notifyListeners()` at the end — the UI rebuilds once seeing: `status == completed`, `completedMode` (the mode that finished), `currentMode` (the next mode), `remainingDuration` (next mode's full duration).
8. When user presses Start → status transitions from `Completed` to `Running`, `_completedMode` is cleared to null, `targetEndTime = now + _remainingDuration`.

### Duplicate Completion Prevention

The `_onTick` method includes a guard at the top:

```dart
void _onTick(Timer timer) {
  if (_status != TimerStatus.running) return;
  // ... recalculate remaining, check for completion
}
```

Additionally, the timer is cancelled BEFORE processing completion in `_onCompletion()`. This ensures that even if the lifecycle observer and a delayed tick both detect remaining <= 0, only the first one processes the completion. The second invocation exits immediately because status is no longer `Running`.

### Application Lifecycle Handling

The `PomodoroController` implements `WidgetsBindingObserver` to handle background/foreground transitions:

```dart
class PomodoroController extends ChangeNotifier with WidgetsBindingObserver {
  // ...

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    _isLoading = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _status == TimerStatus.running) {
      _recalculateOnResume();
    }
  }

  void _recalculateOnResume() {
    final remaining = _targetEndTime!.difference(_clock.now());
    if (remaining <= Duration.zero) {
      _onCompletion();
    } else {
      _remainingDuration = remaining;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
```

**Design decisions:**
- When `AppLifecycleState.resumed` fires and status is `Running`, the controller immediately recalculates remaining time from `_targetEndTime`. If remaining <= 0, it triggers completion without waiting for the next periodic tick.
- This handles the case where the OS suspended the periodic timer's callbacks while the app was backgrounded longer than the remaining time.
- Full process termination: session is abandoned, no persistence. Controller initializes fresh on next launch.

### Timer Resource Management

- A single `Timer.periodic(Duration(seconds: 1), _onTick)` subscription is the only countdown resource.
- On pause, reset, skip, completion, or dispose: `_timer?.cancel(); _timer = null;`
- On start/resume: if `_timer != null`, cancel first (prevents duplicates), then create new.
- The controller's `dispose()` method removes the lifecycle observer and cancels the timer.

### Duplicate Timer Prevention

Before creating a new `Timer.periodic`, the controller always cancels the existing timer:

```dart
void _startTimer() {
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
}
```

This ensures at most one active timer subscription at any time.

### Full Process Termination

If the OS kills the app process while the timer is running, the session is treated as abandoned. No persistence occurs, no state is saved. On next launch, the controller initializes fresh: `Focus`, `Idle`, `cycleCount = 0`.

### Injectable Time Source (Clock)

```dart
// lib/features/pomodoro/domain/entities/clock.dart
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
```

All timestamps produced by the Clock are UTC. This ensures that persisted `startedAt` and `completedAt` values are timezone-independent and consistent for date-range queries.

The `PomodoroController` accepts a `Clock` parameter (defaulting to `SystemClock()`) so tests can inject a fake clock that returns controlled timestamps.

---

## State Management

### PomodoroController (ChangeNotifier)

The controller is the single source of truth for all Pomodoro timer state. It is provided at the app level via `ChangeNotifierProvider` so it persists across navigation. It implements `WidgetsBindingObserver` for lifecycle handling.

```dart
// lib/features/pomodoro/presentation/controllers/pomodoro_controller.dart
class PomodoroController extends ChangeNotifier with WidgetsBindingObserver {
  PomodoroController({
    required SavePomodoroSessionUseCase saveSessionUseCase,
    required List<PomodoroTaskOption> Function() taskListProvider,
    PomodoroConfig config = const PomodoroConfig(),
    Clock clock = const SystemClock(),
  });
}
```

### State Shape

```dart
class PomodoroController extends ChangeNotifier with WidgetsBindingObserver {
  // --- Configuration ---
  final PomodoroConfig _config;
  final Clock _clock;
  final SavePomodoroSessionUseCase _saveSessionUseCase;
  final List<PomodoroTaskOption> Function() _taskListProvider;

  // --- Timer state ---
  TimerMode _currentMode = TimerMode.focus;
  TimerStatus _status = TimerStatus.idle;
  Duration _remainingDuration;           // Current remaining time
  DateTime? _targetEndTime;              // Absolute end timestamp (when Running)
  Duration? _preservedRemaining;         // Saved on pause
  Timer? _timer;                         // Periodic subscription

  // --- Completion tracking ---
  TimerMode? _completedMode;             // The mode that just finished (non-null only when status == completed)

  // --- Cycle state ---
  int _cycleCount = 0;                   // 0–4 focus sessions completed

  // --- Session tracking ---
  DateTime? _sessionStartedAt;           // When user first pressed Start (Focus only)
  int? _selectedTaskId;                  // Nullable task association
  String? _selectedTaskTitle;            // Title at selection time (fallback for snapshot)

  // --- Feedback ---
  bool _isLoading = false;
  String? _errorMessage;
  PomodoroSession? _pendingSession;      // Stored for retry on persistence failure
}
```

### Public Getters

```dart
  TimerMode get currentMode;
  TimerStatus get status;
  Duration get remainingDuration;
  int get cycleCount;
  int? get selectedTaskId;
  String? get selectedTaskTitle;
  bool get isLoading;
  String? get errorMessage;
  bool get hasPendingSession;            // True when a session failed to persist
  PomodoroConfig get config;
  List<PomodoroTaskOption> get availableTasks;  // Delegates to _taskListProvider()
  TimerMode? get completedMode;          // Non-null only when status == completed; indicates which mode just finished
```

### Public Mutation Methods

```dart
  /// Starts the timer from Idle or Completed state.
  /// No-op if status is Running or Paused.
  void start();

  /// Pauses the timer from Running state.
  /// No-op if status is not Running.
  void pause();

  /// Resumes the timer from Paused state.
  /// No-op if status is not Paused.
  void resume();

  /// Resets the timer from Running or Paused state.
  /// Restores remaining duration to full configured duration for the current mode.
  /// Transitions to Idle. No-op if status is Idle or Completed.
  void reset();

  /// Skips the current session from Running or Paused state.
  /// Advances to the next mode in the cycle without persisting.
  /// Transitions to Idle. No-op if status is Idle or Completed.
  void skip();

  /// Sets the task association. Only effective when Idle or Completed.
  void selectTask(int? taskId, String? taskTitle);

  /// Clears the visible error message. Does NOT discard the pending session.
  void clearError();

  /// Retries the last failed persistence operation.
  /// Callable even after the error message has been cleared.
  Future<void> retryPersistence();

  /// Initializes the controller. Called once after construction.
  /// Registers the lifecycle observer.
  Future<void> init();

  @override
  void dispose();
```

### Cycle Progression Logic

```dart
TimerMode _nextMode() {
  switch (_currentMode) {
    case TimerMode.focus:
      // cycleCount has already been incremented at this point
      if (_cycleCount >= _config.sessionsBeforeLongBreak) {
        return TimerMode.longBreak;
      }
      return TimerMode.shortBreak;
    case TimerMode.shortBreak:
      return TimerMode.focus;
    case TimerMode.longBreak:
      return TimerMode.focus;
  }
}
```

After a Long Break completes or is skipped, `_cycleCount` resets to 0.

### Task Title Snapshot Resolution

At persistence time, the controller resolves the task title as follows:

```dart
String? _resolveTaskTitleSnapshot() {
  if (_selectedTaskId == null) return null;
  final tasks = _taskListProvider();
  final match = tasks.where((t) => t.id == _selectedTaskId).firstOrNull;
  if (match != null) return match.title;
  // Task was deleted — fall back to the title captured at selection time
  return _selectedTaskTitle;
}
```

This ensures the snapshot reflects the task's current title at persistence time. If the task was renamed between selection and completion, the latest title is captured. If the task was deleted, the fallback title from selection time is used.

### Actual Duration Calculation

For naturally completed sessions in the MVP, `actualDurationSeconds` equals `plannedDurationSeconds` (the configured focus duration). This is correct because a naturally completed session always runs for exactly the configured duration of active countdown time — paused intervals do not count toward elapsed time, and the timer completes precisely when the total active countdown reaches zero.

```dart
PomodoroSession _buildSession() {
  return PomodoroSession(
    id: 0, // assigned by repository
    timerMode: TimerMode.focus,
    startedAt: _sessionStartedAt!,
    completedAt: _clock.now(),
    plannedDurationSeconds: _config.focusDuration.inSeconds,
    actualDurationSeconds: _config.focusDuration.inSeconds,
    taskId: _selectedTaskId,
    taskTitleSnapshot: _resolveTaskTitleSnapshot(),
  );
}
```

---

## Component Breakdown (Presentation)

### PomodoroScreen

**Purpose:** Primary screen for the Pomodoro timer. Orchestrates layout of all sub-widgets.
**Route:** `/pomodoro`
**Key inputs:** `PomodoroController` (via `context.read` / `ListenableBuilder`)
**Layout:** `Scaffold` with centered column containing: mode label, `TimerDisplay`, `CycleProgressIndicator`, `TimerControls`, `TaskSelectorWidget`. Error display as a non-modal SnackBar when persistence fails. A persistent retry affordance is shown when `hasPendingSession` is true (even after SnackBar dismissal).

**Completed state display:** When `status == completed`, the screen uses `completedMode` to display a message like "Focus session finished" or "Short break finished" (identifying the mode that just ended), and uses `currentMode` to display "Short break ready" or "Focus ready" (identifying the next mode). The Start button begins the next session.

### TimerDisplay

**Purpose:** Shows the countdown in `MM:SS` format with a circular progress indicator.
**Key inputs:** `Duration remainingDuration`, `Duration totalDuration`, `TimerStatus status`
**Layout:** `Stack` containing a `CircularProgressIndicator` (determinate, showing elapsed proportion) with the `MM:SS` text centered inside. Font size >= 32sp. Progress value = `1.0 - (remaining / total)`.

### TimerControls

**Purpose:** Shows the appropriate action buttons based on current `TimerStatus`.
**Key inputs:** `TimerStatus status`, `VoidCallback onStart`, `VoidCallback onPause`, `VoidCallback onResume`, `VoidCallback onReset`, `VoidCallback onSkip`
**Layout:** Row of `FilledButton`/`OutlinedButton` widgets. Button visibility follows Requirement 13.4–13.6:
- Idle/Completed → Start only
- Running → Pause, Reset, Skip
- Paused → Resume, Reset, Skip

All buttons have minimum 48x48dp touch targets and semantic labels.

### TaskSelectorWidget

**Purpose:** Dropdown selector listing available tasks for optional association.
**Key inputs:** `List<PomodoroTaskOption> tasks`, `int? selectedTaskId`, `bool enabled`, `ValueChanged<(int?, String?)> onChanged`
**Layout:** A `DropdownButtonFormField` or similar Material 3 selector. First option is "No task" (null). Tasks are sorted: `isCompleted == false` before `isCompleted == true`. Disabled state is enforced when `enabled == false` (during Running/Paused). If no tasks exist, shows a disabled field with "No tasks available" hint text.

### CycleProgressIndicator

**Purpose:** Displays the current cycle progress as "N / 4".
**Key inputs:** `int cycleCount`
**Layout:** A `Text` widget showing "N / 4" where N = cycleCount.

---

## Components and Interfaces

This section consolidates the public contracts of every component in the Pomodoro feature. These signatures are the implementation targets.

---

### Domain Exceptions

```dart
// lib/features/pomodoro/domain/exceptions/persistence_exception.dart

/// Thrown when an Isar write operation fails during session persistence.
class PersistenceException implements Exception {
  const PersistenceException(this.message);
  final String message;
}
```

---

### Domain Enums

```dart
// lib/features/pomodoro/domain/entities/timer_mode.dart
enum TimerMode { focus, shortBreak, longBreak }

// lib/features/pomodoro/domain/entities/timer_status.dart
enum TimerStatus { idle, running, paused, completed }
```

---

### Domain Entities

```dart
// lib/features/pomodoro/domain/entities/pomodoro_task_option.dart

/// Minimal read-only task representation owned by the Pomodoro feature.
class PomodoroTaskOption {
  const PomodoroTaskOption({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final bool isCompleted;
}
```

```dart
// lib/features/pomodoro/domain/entities/pomodoro_config.dart

/// Immutable value object holding Pomodoro duration configuration.
class PomodoroConfig {
  const PomodoroConfig({
    this.focusDuration = const Duration(minutes: 25),
    this.shortBreakDuration = const Duration(minutes: 5),
    this.longBreakDuration = const Duration(minutes: 15),
    this.sessionsBeforeLongBreak = 4,
  });

  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int sessionsBeforeLongBreak;

  Duration durationFor(TimerMode mode);
}
```

```dart
// lib/features/pomodoro/domain/entities/pomodoro_session.dart

/// Immutable domain entity representing a completed Pomodoro focus session.
class PomodoroSession {
  const PomodoroSession({
    required this.id,
    required this.timerMode,
    required this.startedAt,
    required this.completedAt,
    required this.plannedDurationSeconds,
    required this.actualDurationSeconds,
    this.taskId,
    this.taskTitleSnapshot,
  });

  final int id;
  final TimerMode timerMode;
  final DateTime startedAt;
  final DateTime completedAt;
  final int plannedDurationSeconds;
  final int actualDurationSeconds;
  final int? taskId;
  final String? taskTitleSnapshot;
}
```

```dart
// lib/features/pomodoro/domain/entities/clock.dart

/// Abstraction over time for testability.
abstract interface class Clock {
  DateTime now();
}

/// Production implementation using system time.
/// All timestamps are UTC to ensure timezone-independent persistence.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
```

---

### Repository Interface

```dart
// lib/features/pomodoro/domain/repositories/pomodoro_session_repository.dart

/// Defines persistence operations for Pomodoro sessions.
abstract interface class PomodoroSessionRepository {
  Future<PomodoroSession> create(PomodoroSession session);
  Future<List<PomodoroSession>> getAll();
  Future<List<PomodoroSession>> getByDateRange({
    required DateTime start,
    required DateTime end,
  });
  Future<List<PomodoroSession>> getByTaskId(int taskId);
  Future<List<PomodoroSession>> getByNullTask();
}
```

---

### Use Cases

```dart
// lib/features/pomodoro/domain/use_cases/save_pomodoro_session_use_case.dart
class SavePomodoroSessionUseCase {
  const SavePomodoroSessionUseCase({
    required PomodoroSessionRepository repository,
  });
  Future<PomodoroSession> call(PomodoroSession session);
}
```

```dart
// lib/features/pomodoro/domain/use_cases/get_sessions_use_case.dart
class GetSessionsUseCase {
  const GetSessionsUseCase({
    required PomodoroSessionRepository repository,
  });
  Future<List<PomodoroSession>> call();
}
```

```dart
// lib/features/pomodoro/domain/use_cases/get_sessions_by_date_range_use_case.dart
class GetSessionsByDateRangeUseCase {
  const GetSessionsByDateRangeUseCase({
    required PomodoroSessionRepository repository,
  });
  Future<List<PomodoroSession>> call({
    required DateTime start,
    required DateTime end,
  });
}
```

```dart
// lib/features/pomodoro/domain/use_cases/get_sessions_by_task_id_use_case.dart
class GetSessionsByTaskIdUseCase {
  const GetSessionsByTaskIdUseCase({
    required PomodoroSessionRepository repository,
  });
  Future<List<PomodoroSession>> call(int? taskId);
}
```

---

### PomodoroController Public API

```dart
// lib/features/pomodoro/presentation/controllers/pomodoro_controller.dart

/// Manages all Pomodoro timer state. Provided at the app level so the timer
/// survives navigation away from the Pomodoro screen. Uses WidgetsBindingObserver
/// to handle background/foreground lifecycle transitions.
class PomodoroController extends ChangeNotifier with WidgetsBindingObserver {
  PomodoroController({
    required SavePomodoroSessionUseCase saveSessionUseCase,
    required List<PomodoroTaskOption> Function() taskListProvider,
    PomodoroConfig config = const PomodoroConfig(),
    Clock clock = const SystemClock(),
  });

  // --- Initialisation ---
  Future<void> init();

  // --- Read-only getters ---
  TimerMode get currentMode;
  TimerStatus get status;
  Duration get remainingDuration;
  int get cycleCount;
  int? get selectedTaskId;
  String? get selectedTaskTitle;
  bool get isLoading;
  String? get errorMessage;
  bool get hasPendingSession;
  PomodoroConfig get config;
  List<PomodoroTaskOption> get availableTasks;
  TimerMode? get completedMode;          // Non-null only when status == completed

  // --- Mutation methods ---
  void start();
  void pause();
  void resume();
  void reset();
  void skip();
  void selectTask(int? taskId, String? taskTitle);
  void clearError();
  Future<void> retryPersistence();

  // --- Lifecycle ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state);

  @override
  void dispose();
}
```

---

### Widget Interfaces

#### TimerDisplay
```dart
// lib/features/pomodoro/presentation/widgets/timer_display.dart
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.remainingDuration,
    required this.totalDuration,
    required this.status,
  });

  final Duration remainingDuration;
  final Duration totalDuration;
  final TimerStatus status;
}
```

#### TimerControls
```dart
// lib/features/pomodoro/presentation/widgets/timer_controls.dart
class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
  });

  final TimerStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onSkip;
}
```

#### TaskSelectorWidget
```dart
// lib/features/pomodoro/presentation/widgets/task_selector_widget.dart
class TaskSelectorWidget extends StatelessWidget {
  const TaskSelectorWidget({
    super.key,
    required this.tasks,
    required this.selectedTaskId,
    required this.enabled,
    required this.onChanged,
  });

  final List<PomodoroTaskOption> tasks;
  final int? selectedTaskId;
  final bool enabled;
  final ValueChanged<(int?, String?)> onChanged;
}
```

#### CycleProgressIndicator
```dart
// lib/features/pomodoro/presentation/widgets/cycle_progress_indicator.dart
class CycleProgressIndicator extends StatelessWidget {
  const CycleProgressIndicator({
    super.key,
    required this.cycleCount,
  });

  final int cycleCount;
}
```

#### PomodoroScreen
```dart
// lib/features/pomodoro/presentation/screens/pomodoro_screen.dart
class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});
}
```

---

## Cross-Feature Task Access

**Decision:** Pass a `List<PomodoroTaskOption> Function()` provider function into `PomodoroController`.

**Rationale:** The Pomodoro controller needs a read-only view of the current task list for the task selector dropdown. To maintain architectural boundaries, the Pomodoro feature owns a minimal `PomodoroTaskOption` type. The mapping from Todo's `Task` entity to `PomodoroTaskOption` happens exclusively in the app composition root (`app.dart`).

**Why not import Task directly?** Importing `Task` from `features/todo/domain/entities/task.dart` would create a compile-time dependency between features, violating the architecture rule that features must not import from other features' `data/` or `domain/` layers.

**Wiring (in `FocusFlowApp.build`):**

```dart
final todoController = TodoController(...);

final pomodoroController = PomodoroController(
  saveSessionUseCase: SavePomodoroSessionUseCase(...),
  taskListProvider: () => todoController.allTasks.map((task) =>
    PomodoroTaskOption(
      id: task.id,
      title: task.title,
      isCompleted: task.status == TaskStatus.completed,
    ),
  ).toList(),
  config: const PomodoroConfig(),
);
```

Both controllers are provided via `MultiProvider` at the app level. The mapping lambda is the only place where `Task` and `PomodoroTaskOption` meet — it lives in `app.dart`, which is the composition root and is permitted to reference both features. Note that `TaskStatus` is imported from `features/todo/domain/entities/task_status.dart` in `app.dart` only.

---

## Error Handling

### Persistence Errors

`PersistenceException` is thrown by the Isar repository implementation when a write operation fails. The controller catches this in the completion flow:

```dart
void _onCompletion() async {
  if (_status != TimerStatus.running) return; // guard against duplicate completion
  _timer?.cancel();
  _timer = null;

  _completedMode = _currentMode; // capture which mode just finished
  _status = TimerStatus.completed;

  if (_currentMode == TimerMode.focus) {
    _cycleCount++;
    final session = _buildSession();
    try {
      await _saveSessionUseCase.call(session);
    } on Exception catch (_) {
      _errorMessage = 'Could not save session. Your focus time was not recorded.';
      _pendingSession = session;
    }
  }
  _advanceToNextMode(); // sets _currentMode and _remainingDuration to next mode
  notifyListeners();    // single notification — UI sees final consistent state
}
```

Key behaviors:
- The timer does **not** stop or block on persistence failure (Requirement 17.3).
- Error is displayed non-modally (SnackBar with Retry action).
- The `_pendingSession` is stored so `retryPersistence()` can re-attempt.
- `clearError()` clears only the `_errorMessage`, NOT the `_pendingSession`. The pending session persists until retry succeeds or the app is terminated.
- `retryPersistence()` is callable even after the error message has been cleared (the user can tap the persistent retry affordance).
- `hasPendingSession` getter allows the UI to show a persistent indicator.
- `_completedMode` is cleared to null when `start()` transitions from Completed to Running, or when `skip()`/`reset()` transitions to Idle.

### clearError() Behavior

```dart
void clearError() {
  _errorMessage = null;
  notifyListeners();
  // NOTE: _pendingSession is NOT cleared here.
  // The session remains available for retryPersistence().
}
```

### retryPersistence() Behavior

```dart
Future<void> retryPersistence() async {
  if (_pendingSession == null) return;
  try {
    await _saveSessionUseCase.call(_pendingSession!);
    _pendingSession = null;
    _errorMessage = null;
    notifyListeners();
  } on Exception catch (_) {
    _errorMessage = 'Could not save session. Please try again.';
    notifyListeners();
  }
}
```

### Error Propagation Strategy

- Repository throws `PersistenceException` on Isar write failure.
- Use case propagates the exception without catching it.
- Controller catches at the call site, stores user-friendly message, notifies listeners.
- UI reads `errorMessage` and shows SnackBar with Retry action.
- UI reads `hasPendingSession` and shows a persistent retry affordance (small button or indicator) even after SnackBar dismissal.
- No technical exception names or stack traces are ever exposed to the user (Requirement 17.6).

---

## Correctness Properties

The properties below are universally quantified statements that will be implemented as property-based tests using the `dart_fast_check` library. Minimum 100 iterations per property test.

---

### Property 1: Timer never produces negative remaining time

*For any* timer state, the `remainingDuration` exposed by the controller SHALL always be greater than or equal to `Duration.zero`. Regardless of tick timing, delayed callbacks, or the relationship between `targetEndTime` and `clock.now()`, the remaining duration is clamped to zero.

**Validates: Requirements 6.1, 6.5**

---

### Property 2: Cycle count is always between 0 and 4 inclusive

*For any* sequence of start, pause, resume, reset, skip, and natural completion operations, the `cycleCount` SHALL always satisfy `0 <= cycleCount <= 4`.

**Validates: Requirements 7.1, 7.2, 7.5, 7.8**

---

### Property 3: Only natural focus completion increments cycle count

*For any* timer operation, the `cycleCount` SHALL increase by exactly 1 only when a Focus session completes naturally (remaining reaches zero while in Focus mode). Reset, skip, and break completions SHALL never change the cycle count (except Long Break completion/skip which resets it to 0).

**Validates: Requirements 4.4, 5.2, 6.3, 6.6**

---

### Property 4: Reset preserves current Timer_Mode

*For any* timer in Running or Paused state with any Timer_Mode, calling reset SHALL result in the Timer_Mode remaining unchanged and the remaining duration being restored to the full configured duration for that mode.

**Validates: Requirements 4.1**

---

### Property 5: Pause then resume preserves total active countdown time

*For any* running timer with remaining duration R, pausing at any point and then resuming SHALL result in a `targetEndTime` that is exactly `clock.now() + R_at_pause`. The total accumulated active countdown time (excluding paused intervals) from initial start to natural completion equals the configured duration, regardless of the number or duration of pause intervals.

**Validates: Requirements 3.1, 3.2, 3.6**

---

### Property 6: Session persistence round-trip

*For any* valid `PomodoroSession` entity written to the repository, reading it back (via `getAll`, `getByDateRange`, or `getByTaskId`) SHALL return a session with all field values equal to the original: `startedAt`, `completedAt`, `plannedDurationSeconds`, `actualDurationSeconds`, `taskId`, and `taskTitleSnapshot`.

**Validates: Requirements 9.2, 16.2**

---

### Property 7: Only naturally completed focus sessions are persisted

*For any* sequence of timer operations, the repository SHALL contain exactly one new session record for each Focus session that completes naturally (remaining reaches zero). No session record SHALL be created for: reset Focus sessions, skipped Focus sessions, completed breaks, skipped breaks, or reset breaks.

**Validates: Requirements 5.3, 6.4, 6.6, 9.1, 9.3, 9.4**

---

### Property 8: Cycle progression follows the defined sequence

*For any* series of naturally completed focus sessions (without resets or skips interrupting the cycle), the Timer_Mode sequence SHALL follow: Focus → Short_Break → Focus → Short_Break → Focus → Short_Break → Focus → Long_Break, and then repeat from Focus with cycleCount reset to 0.

**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

---

### Property 9: Invalid state transitions are no-ops

*For any* timer state, invoking an action whose precondition is not met SHALL leave all observable state unchanged. Specifically: start when Running/Paused, pause when not Running, resume when not Paused, reset when Idle/Completed, skip when Idle/Completed — all produce no state change and no side effects.

**Validates: Requirements 2.4, 3.4, 3.5, 4.5, 5.6**

---

### Property 10: Task association is stored correctly on persistence

*For any* completed Focus session, if a task was selected (`selectedTaskId != null`), the persisted `PomodoroSession` SHALL contain that `taskId` and a non-null `taskTitleSnapshot` reflecting the task's current title from the latest `taskListProvider()` result (or the fallback title if the task was deleted). If no task was selected, both `taskId` and `taskTitleSnapshot` SHALL be null.

**Validates: Requirements 8.6, 8.7**

---

### Property 11: Date range and task-id queries return correct subsets

*For any* set of persisted sessions and any date range `[start, end)`, `getByDateRange(start, end)` SHALL return exactly those sessions whose `startedAt` satisfies `start <= startedAt < end`. For any `taskId`, `getByTaskId(taskId)` SHALL return exactly those sessions with matching `taskId`. `getByNullTask()` SHALL return exactly those sessions where `taskId` is null.

**Validates: Requirements 16.4, 16.5, 16.6**

---

### Property 12: Completion fires at most once per running session

*For any* running timer session, the completion handler SHALL execute at most once. If multiple triggers attempt completion (e.g., a delayed tick callback and a lifecycle resume event arriving simultaneously), only the first trigger transitions the status away from Running. Subsequent triggers observe that status is no longer Running and exit as no-ops.

**Validates: Requirements 6.1, 10.3, 10.8**

---

## Testing Strategy

### Unit Tests (Controller + Use Cases)

The `PomodoroController` is the primary unit-test target. Tests use:
- A **fake `Clock`** that returns controlled UTC timestamps (e.g., `DateTime.utc(2024, 1, 15, 10, 0, 0)`) for deterministic timer behavior.
- A **fake `PomodoroSessionRepository`** (in-memory list) to verify persistence calls.
- A **fake task list provider** returning `List<PomodoroTaskOption>` test data.

Coverage includes:
- All state transitions: start, pause, resume, reset, skip, natural completion.
- Full cycle progression through all 8 phases.
- Pause preserves remaining duration; resume recalculates `targetEndTime`.
- Drift resistance: simulate delayed ticks via fake clock, verify remaining is correct.
- Task association storage and `taskTitleSnapshot` resolution (current title vs fallback).
- Error handling: mock repository failure, verify error state, retry flow, and clearError behavior.
- Lifecycle observer: simulate foreground return after backgrounding past completion time.
- Duplicate completion prevention: simulate rapid/overlapping completion triggers.

Use case tests are thin (delegation only) but verify correct routing in `GetSessionsByTaskIdUseCase`.

### Property-Based Tests (Controller + Repository)

The 12 correctness properties defined above are each implemented as a single property-based test using [`dart_fast_check`](https://pub.dev/packages/dart_fast_check). Each test:

- Runs a minimum of **100 iterations** per property.
- Uses arbitrary generators for `Duration`, `TimerMode`, `TimerStatus`, `int` (task IDs), `DateTime`, and sequences of user actions (start/pause/resume/reset/skip).
- Is tagged with a comment: `// Feature: pomodoro, Property N: <property title>`
- Uses fake `Clock` and in-memory repository — no Isar required for property tests.

### Widget Tests (Presentation)

Widget tests cover critical UI states and interactions:
- Idle state: Start button visible, Pause/Resume/Reset/Skip hidden.
- Running state: Pause, Reset, Skip visible; Start hidden.
- Paused state: Resume, Reset, Skip visible; Start, Pause hidden.
- Completed state: Start button visible (for next session), "Session finished" label visible.
- TaskSelector disabled during Running/Paused.
- TaskSelector enabled during Idle/Completed.
- Error SnackBar appears on persistence failure with Retry button.
- Persistent retry affordance visible when `hasPendingSession` is true.
- CycleProgressIndicator shows correct "N / 4" value.
- Timer display format is `MM:SS`.

Widget tests use a mock `PomodoroController` to avoid timer and persistence dependencies.

### Integration Tests

- Isar read/write round-trip for `PomodoroSessionModel` (validates Property 6 at DB layer).
- Date-range and task-id queries against a populated Isar collection.
- Full timer lifecycle: start → complete → verify session persisted in Isar.

### What Is Not Property-Tested

- UI rendering and layout (widget tests / manual review).
- Accessibility compliance (manual review with TalkBack + automated scanner).
- Navigation persistence (integration test: navigate away and back, verify state).
- Background/foreground transitions (integration test with controlled lifecycle events).

---

## Open Questions

| # | Question | Deferred Rationale |
|---|----------|--------------------|
| 1 | Should `TaskSelectorWidget` use a `DropdownButtonFormField` or a bottom sheet for task selection? | Both satisfy requirements. A dropdown is simpler for small task lists; a bottom sheet scales better. Deferred — implement dropdown first, switch to bottom sheet if the list grows unwieldy. |
| 2 | Should `dart_fast_check` or another PBT library be used? | `dart_fast_check` is the most actively maintained Dart PBT library. Confirm latest version and API compatibility with Dart 3.12+ before implementation. |
