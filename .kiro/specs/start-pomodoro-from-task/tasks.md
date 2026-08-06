# Implementation Plan: Start Pomodoro from Task

## Overview

Add a localized "Start Pomodoro" button to the TaskFormScreen in edit mode. The button uses the existing app-scoped PomodoroController to select the current task and pushes the PomodoroScreen route. No new controllers, services, or routes are introduced — the implementation modifies only the ARB localization files and `task_form_screen.dart`.

## Tasks

- [x] 1. Audit PomodoroController completed-state behavior
  - [x] 1.1 Confirm selectTask works correctly in completed state (sets `_selectedTaskId` and `_selectedTaskTitle`, notifies listeners)
    - _Requirements: 3.1_
  - [x] 1.2 Confirm no preparatory operation is needed before calling selectTask when status is completed
    - _Requirements: 3.1_

- [x] 2. Add localization keys (2 keys: taskStartPomodoro, taskStartPomodoroSemantic)
  - [x] 2.1 Add `taskStartPomodoro` and `taskStartPomodoroSemantic` (with `{taskTitle}` placeholder) keys with descriptions to `lib/l10n/app_en.arb`
    - _Requirements: 7.1, 7.2_
  - [x] 2.2 Add the same two keys with Spanish translations to `lib/l10n/app_es.arb`
    - _Requirements: 7.1, 7.2_
  - [x] 2.3 Run `flutter gen-l10n` to regenerate localization delegates and verify no errors
    - _Requirements: 7.1, 7.2_

- [x] 3. Add Start Pomodoro button independent of statsController
  - [x] 3.1 Add imports for `PomodoroController` and `TimerStatus` to `task_form_screen.dart`
    - _Requirements: 3.1, 4.1_
  - [x] 3.2 Insert the button widget in the build method Column using the guard: `final task = widget.initialTask; if (_isEditMode && task != null && task.id > 0)`. Use `Semantics` with `taskStartPomodoroSemantic(task.title)`, `FilledButton.tonalIcon` with `Icons.timer` and `taskStartPomodoro` label, style with `minimumSize: const Size(double.infinity, 48)`, disable when `_isSubmitting`
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 2.5, 8.1, 8.2, 8.3_
  - [x] 3.3 Verify the button does NOT appear in create mode and does NOT appear for task.id <= 0
    - _Requirements: 1.2, 1.3_

- [x] 4. Integrate idle/completed selection behavior
  - [x] 4.1 Add `_onStartPomodoro()` method that reads PomodoroController, calls `selectTask(widget.initialTask!.id, widget.initialTask!.title)` when status is idle or completed, and always pushes `Routes.pomodoro`
    - _Requirements: 3.1, 3.2, 3.3, 4.1, 4.2, 5.1, 6.1, 6.2_

- [x] 5. Protect running/paused sessions
  - [x] 5.1 Verify that `_onStartPomodoro` does NOT call selectTask when status is running or paused — it only navigates to Routes.pomodoro where the PomodoroScreen shows the active session
    - _Requirements: 4.1, 4.2_

- [ ] 6. Run localization generation, format, analyze, and existing tests
  - [ ] 6.1 Run `flutter gen-l10n` and confirm no errors
    - _Requirements: 7.1, 7.2_
  - [ ] 6.2 Run `dart format .` on modified files
    - _Requirements: 9.1_
  - [ ] 6.3 Run `flutter analyze` and confirm zero warnings
    - _Requirements: 9.1, 9.2, 9.3_
  - [ ] 6.4 Run `flutter test` and confirm all existing tests pass
    - _Requirements: 9.1, 9.2, 9.3_

- [ ] 7. Write essential widget tests (optional for MVP)
  - [ ]* 7.1 Write a widget test verifying the button is visible for a persisted task with valid ID (id > 0)
    - **Property 1: Button visibility invariant**
    - **Validates: Requirements 1.1**
  - [ ]* 7.2 Write a widget test verifying the button is NOT visible in create mode (initialTask is null)
    - **Property 1: Button visibility invariant**
    - **Validates: Requirements 1.2**
  - [ ]* 7.3 Write a widget test verifying the button is hidden for invalid/zero task ID
    - **Property 1: Button visibility invariant**
    - **Validates: Requirements 1.3**
  - [ ]* 7.4 Write a widget test verifying that tapping the button when status is idle calls `selectTask` with the correct persisted task ID and title, and pushes Routes.pomodoro
    - **Property 2: Task selection precondition**
    - **Property 5: Persisted identity usage**
    - **Validates: Requirements 3.1, 3.2, 6.1**
  - [ ]* 7.5 Write a widget test verifying that tapping the button when status is completed calls `selectTask` with the correct task and navigates (timer stays completed)
    - **Property 2: Task selection precondition**
    - **Validates: Requirements 3.1, 3.3**
  - [ ]* 7.6 Write a widget test verifying that tapping the button when status is running does NOT call `selectTask` and pushes Routes.pomodoro
    - **Property 2: Task selection precondition**
    - **Property 4: Navigation consistency**
    - **Validates: Requirements 4.1, 4.2**
  - [ ]* 7.7 Write a widget test verifying that tapping the button when status is paused does NOT call `selectTask` and pushes Routes.pomodoro
    - **Property 2: Task selection precondition**
    - **Property 4: Navigation consistency**
    - **Validates: Requirements 4.1, 4.2**
  - [ ]* 7.8 Write a widget test verifying that timer never starts automatically after button tap
    - **Property 3: Timer state preservation**
    - **Validates: Requirements 3.3, 9.2**
  - [ ]* 7.9 Write a widget test verifying that persisted values are used (not form controller values)
    - **Property 5: Persisted identity usage**
    - **Validates: Requirements 6.1**
  - [ ]* 7.10 Write a widget test verifying button visibility is independent of statistics controller loading
    - **Property 1: Button visibility invariant**
    - **Validates: Requirements 1.1, 1.3**

- [ ] 8. Manual verification
  - [ ] 8.1 Create and save Task A → open details → tap Start Pomodoro → confirm PomodoroScreen opens with Task A → timer idle → complete a Pomodoro → confirm session linked to Task A
  - [ ] 8.2 Verify running session protection: start a Pomodoro for Task A → open Task B details → tap Start Pomodoro → confirm navigation to PomodoroScreen showing Task A active session (no replacement)
  - [ ] 8.3 Verify Spanish and English localization
  - [ ] 8.4 Verify light and dark themes

- [ ] 9. Final checkpoint
  - Ensure all tests pass, `flutter analyze` is clean, and ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- No new files are created — only `app_en.arb`, `app_es.arb`, and `task_form_screen.dart` are modified
- The button uses persisted task values (`widget.initialTask`) not form controller values
- The button visibility guard (`_isEditMode && task != null && task.id > 0`) is independent of `_statsController` initialization
- No `fast_check` or property-based testing dependency is needed — tests are focused deterministic widget tests
- No SnackBar is shown for active sessions — PomodoroScreen already displays the active session state

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["2.1", "2.2"] },
    { "id": 2, "tasks": ["2.3"] },
    { "id": 3, "tasks": ["3.1", "3.2"] },
    { "id": 4, "tasks": ["3.3", "4.1"] },
    { "id": 5, "tasks": ["5.1"] },
    { "id": 6, "tasks": ["6.1", "6.2", "6.3", "6.4"] },
    { "id": 7, "tasks": ["7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "7.10"] },
    { "id": 8, "tasks": ["8.1", "8.2", "8.3", "8.4"] },
    { "id": 9, "tasks": ["9"] }
  ]
}
```
