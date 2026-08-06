# Design Document

## Overview

This feature adds a localized "Start Pomodoro" button to the TaskFormScreen in edit mode. The button leverages the existing app-scoped PomodoroController to select the current task, then pushes the existing PomodoroScreen route. No new controllers, state management abstractions, or navigation mechanisms are introduced. The design reuses existing infrastructure: Routes.pomodoro for navigation, PomodoroController.selectTask for task association, and the standard ARB localization system for strings.

## Architecture

### Component Interaction Flow

```
TaskFormScreen (edit mode, task.id > 0)
    │
    ├── Reads PomodoroController via Provider (context.read)
    ├── Checks controller.status
    │
    ├── IF idle/completed:
    │   ├── Calls controller.selectTask(task.id, task.title)
    │   └── Pushes Routes.pomodoro
    │
    └── IF running/paused:
        ├── Shows localized SnackBar (pomodoroActiveSessionWarning)
        ├── Hides current SnackBar first (prevents stacking)
        └── Returns immediately (no navigation, no selectTask)
```

### Navigation Stack

```
Before tap:
  HomeScreen → TaskFormScreen(editMode)

After tap:
  HomeScreen → TaskFormScreen(editMode) → PomodoroScreen

After Back from Pomodoro:
  HomeScreen → TaskFormScreen(editMode)  ← didPopNext refreshes stats
```

This approach preserves the TaskFormScreen below PomodoroScreen. The user presses Back to return and can continue editing or save. The existing RouteAware mixin in TaskFormScreen triggers `didPopNext`, which already calls `_statsController?.load()` to refresh Pomodoro stats.

### Why Push Routes.pomodoro Instead of Tab Switch

The TaskFormScreen is pushed on top of HomeScreen. To switch to the Pomodoro tab, we would need to:
1. Pop back to HomeScreen (losing form state)
2. Signal HomeScreen to change its `_selectedIndex` (no existing mechanism)

Pushing Routes.pomodoro is simpler because:
- PomodoroScreen works standalone (it reads PomodoroController from Provider)
- PomodoroController is app-scoped — the pushed screen sees the same instance
- Form state is preserved below
- No changes to HomeScreen are needed
- The existing route and screen already exist in the router

### Completed State Behavior (Confirmed from PomodoroController)

When `status == TimerStatus.completed`:
- `_completedMode` holds the mode that just finished
- `_currentMode` has already advanced to the next mode (focus → short break, etc.)
- `_remainingDuration` is set to the new mode's configured duration
- `selectTask(taskId, taskTitle)` works correctly: sets the task and notifies listeners
- The PomodoroScreen displays the completion message and the "next mode ready" state
- No additional operations are needed before calling selectTask

Therefore, the Start Pomodoro button can call `selectTask` directly when status is `completed` without any preparatory operations.

### Unsaved Edits Behavior

The button uses `widget.initialTask.id` and `widget.initialTask.title` — the LAST PERSISTED values. If the user has typed a new title in the form but not saved, the Pomodoro will use the old persisted title. This is intentional and correct: the task identity for Pomodoro should be the committed version. The TaskFormScreen remains on the stack — the user can return and save.

## Data Models

No new data entities, collections, or models are required. The feature uses:

- `Task.id` (int) — existing persisted task identifier
- `Task.title` (String) — existing task title
- `TimerStatus` (enum) — existing timer lifecycle state
- `PomodoroController.selectTask(int?, String?)` — existing method

## Components and Interfaces

### Modified Files

| File | Change |
|------|--------|
| `lib/l10n/app_en.arb` | Add 2 localization keys |
| `lib/l10n/app_es.arb` | Add 2 localization keys with Spanish translations |
| `lib/features/todo/presentation/screens/task_form_screen.dart` | Add Start Pomodoro button in edit mode |

### No New Files Required

The feature is entirely contained within modifications to existing files. No new widgets, controllers, services, or routes are created.

## Detailed Design

### Localization Keys

```json
// app_en.arb additions
"taskStartPomodoro": "Start Pomodoro",
"@taskStartPomodoro": {
  "description": "Label for the Start Pomodoro button on the task edit screen"
},
"taskStartPomodoroSemantic": "Start Pomodoro for {taskTitle}",
"@taskStartPomodoroSemantic": {
  "description": "Accessibility label for the Start Pomodoro button including task name",
  "placeholders": {
    "taskTitle": { "type": "String" }
  }
}
```

```json
// app_es.arb additions
"taskStartPomodoro": "Iniciar Pomodoro",
"@taskStartPomodoro": {
  "description": "Label for the Start Pomodoro button on the task edit screen"
},
"taskStartPomodoroSemantic": "Iniciar Pomodoro para {taskTitle}",
"@taskStartPomodoroSemantic": {
  "description": "Accessibility label for the Start Pomodoro button including task name",
  "placeholders": {
    "taskTitle": { "type": "String" }
  }
}
```

```json
// app_en.arb addition
"pomodoroActiveSessionWarning": "A Pomodoro is already in progress. Complete or reset it before starting another one.",
"@pomodoroActiveSessionWarning": {
  "description": "Warning shown when user tries to start a Pomodoro while another session is running or paused"
}
```

```json
// app_es.arb addition
"pomodoroActiveSessionWarning": "Ya hay un Pomodoro en curso. Finalízalo o reinícialo antes de iniciar otro.",
"@pomodoroActiveSessionWarning": {
  "description": "Warning shown when user tries to start a Pomodoro while another session is running or paused"
}
```

### TaskFormScreen Modifications

The button is inserted in the Column children list after the TaskPomodoroStatsSection block and before the error message / save button section. The visibility guard is independent of `_statsController`:

```dart
// After the stats section conditional block:
final task = widget.initialTask;
if (_isEditMode && task != null && task.id > 0) ...[
  const SizedBox(height: 16),
  Semantics(
    label: l10n.taskStartPomodoroSemantic(task.title),
    child: FilledButton.tonalIcon(
      onPressed: _isSubmitting ? null : _onStartPomodoro,
      icon: const Icon(Icons.timer),
      label: Text(l10n.taskStartPomodoro),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
  ),
],
```

### _onStartPomodoro Method

```dart
void _onStartPomodoro() {
  final pomodoroController = context.read<PomodoroController>();
  final status = pomodoroController.status;

  if (status == TimerStatus.running || status == TimerStatus.paused) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.pomodoroActiveSessionWarning)),
      );
    return;
  }

  final task = widget.initialTask!;
  pomodoroController.selectTask(task.id, task.title);
  Navigator.of(context).pushNamed(Routes.pomodoro);
}
```

### Import Additions to TaskFormScreen

```dart
import '../../../pomodoro/domain/entities/timer_status.dart';
import '../../../pomodoro/presentation/controllers/pomodoro_controller.dart';
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Button visibility invariant

*For all* TaskFormScreen instances where `_isEditMode == true` AND `widget.initialTask != null` AND `widget.initialTask!.id > 0`, the Start Pomodoro button is present in the widget tree. For all instances where `widget.initialTask == null` OR `widget.initialTask!.id <= 0`, the button is absent. Button visibility does NOT depend on `_statsController`.

**Validates: Requirements 1.1, 1.2, 1.3**

### Property 2: Task selection precondition

*For all* taps on the Start Pomodoro button, `selectTask` is called if and only if `PomodoroController.status ∈ {idle, completed}`.

**Validates: Requirements 3.1, 4.1**

### Property 3: Timer state preservation

*For all* taps on the Start Pomodoro button, `PomodoroController.status` after the tap equals `PomodoroController.status` before the tap. The button never mutates timer status.

**Validates: Requirements 3.3, 9.2**

### Property 4: Navigation guard for active sessions

*For all* taps on the Start Pomodoro button where `PomodoroController.status ∈ {running, paused}`, no navigation occurs and a SnackBar is shown. *For all* taps where `PomodoroController.status ∈ {idle, completed}`, the PomodoroScreen route is pushed.

**Validates: Requirements 3.2, 4.2, 4.3, 5.1, 5.4**

### Property 5: Persisted identity usage

*For all* calls to `selectTask` triggered by the Start Pomodoro button, the arguments are `(widget.initialTask!.id, widget.initialTask!.title)` — never values from form controllers.

**Validates: Requirements 6.1**

## Error Handling

| Scenario | Behavior |
|----------|----------|
| User taps Start Pomodoro while a session is running or paused | A localized SnackBar warning is shown via ScaffoldMessenger. `selectTask` is NOT called. No navigation occurs. `hideCurrentSnackBar()` prevents stacking. The timer state is not modified. |
| `widget.initialTask` is null or has id <= 0 at tap time | The button is only rendered when `_isEditMode && task != null && task.id > 0`, so this path is unreachable. No defensive null-check crash is needed beyond the existing conditional rendering guard. |
| PomodoroController is not available in the widget tree | Provider will throw at `context.read<PomodoroController>()`. This is an app-level misconfiguration, not a runtime user error — it is caught during development and integration tests. |
| Navigation fails (route not registered) | `Routes.pomodoro` is already registered in `app/router.dart`. If removed, Flutter's default route error handling surfaces a red error screen in debug mode. No feature-level handling is needed. |

## Testing Strategy

### Widget Tests

| Test case | Validates |
|-----------|-----------|
| Button is visible for persisted task with valid ID (id > 0) | Requirement 1.1, Property 1 |
| Button is absent in create mode (initialTask is null) | Requirement 1.2, Property 1 |
| Button is hidden for invalid/zero task ID | Requirement 1.3, Property 1 |
| Tapping button calls `selectTask(task.id, task.title)` when status is idle | Requirement 3.1, 6.1, Property 2, 5 |
| Tapping button calls `selectTask(task.id, task.title)` when status is completed | Requirement 3.1, Property 2 |
| Tapping button does NOT call `selectTask` when status is running | Requirement 4.1, Property 2 |
| Tapping button does NOT navigate when status is running, shows SnackBar | Requirement 4.2, 4.3, 4.4, Property 4 |
| Tapping button does NOT call `selectTask` when status is paused | Requirement 4.1, Property 2 |
| Tapping button does NOT navigate when status is paused, shows SnackBar | Requirement 4.2, 4.3, 4.4, Property 4 |
| Repeated taps hide previous SnackBar before showing new one | Requirement 4.5 |
| Timer status is unchanged after tap (idle stays idle, running stays running) | Requirement 3.3, Property 3 |
| Button uses persisted task values, not form controller values | Requirement 6.1, Property 5 |
| Button has correct Semantics label with task title | Requirement 8.1 |
| Button is disabled while form is submitting (`_isSubmitting`) | Defensive UX |
| Button visibility is independent of statistics controller loading | Property 1 |
| Timer never starts automatically after tap | Requirement 3.3 |

### Integration Tests (Manual / CI)

- Verify navigation stack: TaskFormScreen remains below PomodoroScreen after push.
- Verify `didPopNext` triggers stats refresh on return from PomodoroScreen.
- Verify localized strings render correctly in both EN and ES locales.

## Open Questions

None. The design uses existing infrastructure exclusively and introduces no new architectural patterns or abstractions.
