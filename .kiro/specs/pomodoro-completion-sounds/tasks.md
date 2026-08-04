# Implementation Plan: Pomodoro Completion Sounds

## Overview

Add audible completion sounds to the Pomodoro timer by introducing a `PomodoroSoundService` abstraction, a concrete `audioplayers`-backed implementation, and a single integration point in `PomodoroController._onCompletion()`. The feature plays bundled `.mp3` assets on natural phase completion, respects the existing `soundEnabled` preference, and never blocks timer transitions.

## Tasks

- [ ] 1. Audit current sound preference and Pomodoro completion flow
  - [ ] 1.1 Review `PomodoroController._onCompletion()`, `SettingsController.settings.soundEnabled`, and `app.dart` provider wiring to confirm integration points match the design
    - Verify that `_onCompletion()` is the single natural-completion trigger, confirm `soundEnabled` is accessible from the provider tree, and document the `ChangeNotifierProxyProvider2` signature that will be modified
    - _Requirements: 1.1, 1.4, 2.4, 7.1, 6.4_

- [ ] 2. Add licensed audio assets and license documentation
  - [ ] 2.1 Create `assets/audio/focus_complete.mp3` and `assets/audio/break_complete.mp3` placeholder files and register the `assets/audio/` directory in `pubspec.yaml`
    - Add `- assets/audio/` under the flutter assets section in `pubspec.yaml`; place developer-provided or placeholder `.mp3` files in `assets/audio/`
    - _Requirements: 4.1, 4.2, 4.4, 4.5_
  - [ ] 2.2 Create `docs/licenses/audio-assets.md` documenting audio source, license, and commercial-use confirmation
    - Document file names, source URL, license type, and confirmation of Google Play distribution eligibility
    - _Requirements: 4.3, 4.4_

- [ ] 3. Add audio dependency
  - [ ] 3.1 Add `audioplayers: ^6.1.0` to `pubspec.yaml` dependencies and run `flutter pub get`
    - Verify no new Android permissions are introduced by the package; confirm no INTERNET, POST_NOTIFICATIONS, or foreground service declarations are added
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_

- [ ] 4. Create sound service abstraction and implementation
  - [ ] 4.1 Create `lib/core/services/pomodoro_sound_service.dart` with the abstract interface defining `playFocusCompleted()`, `playBreakCompleted()`, and `dispose()`
    - Interface must specify that implementations swallow all audio errors internally and callers fire-and-forget
    - _Requirements: 6.1, 6.5, 8.3, 8.4_
  - [ ] 4.2 Create `lib/core/services/asset_pomodoro_sound_service.dart` implementing `PomodoroSoundService` using `audioplayers` with two `AudioPlayer` instances, pre-set sources, boolean guards, disposed flag, and full error swallowing
    - Two players initialized on construction; `playFocusCompleted`/`playBreakCompleted` seek-and-resume with try-catch; dispose is idempotent
    - _Requirements: 6.2, 8.1, 8.2, 8.4, 8.5, 9.2, 9.3, 9.5_

- [ ] 5. Register dependency
  - [ ] 5.1 Modify `lib/app/app.dart` to instantiate `AssetPomodoroSoundService` and pass it plus an `isSoundEnabled` callback into the `PomodoroController` constructor within the existing `ChangeNotifierProxyProvider2`
    - The `isSoundEnabled` callback reads `settingsController.settings.soundEnabled` at call time; service is created once in `build()`
    - _Requirements: 6.4, 7.1, 7.3, 7.4_

- [ ] 6. Integrate natural completion playback
  - [ ] 6.1 Modify `lib/features/pomodoro/presentation/controllers/pomodoro_controller.dart` to accept optional `PomodoroSoundService? soundService` and `bool Function()? isSoundEnabled` constructor parameters, add `_playCompletionSound()` method called from `_onCompletion()`, and call `_soundService?.dispose()` in `dispose()`
    - `_playCompletionSound()` checks null service, checks `isSoundEnabled`, selects correct method by `_completedMode`, wraps in try-catch; fire-and-forget (not awaited); called after persistence and state update
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1–3.7, 6.3, 7.1, 7.2, 8.1, 8.2, 9.1, 9.4_

- [ ] 7. Update dependency/Data Safety documentation
  - [ ] 7.1 Update release dependency and Data Safety audit documentation to record `audioplayers` package addition and confirm it transmits no user data
    - _Requirements: 10.7, 10.8_

- [ ] 8. Essential tests
  - [ ]* 8.1 Create `test/features/pomodoro/presentation/controllers/pomodoro_controller_sound_test.dart` with a fake `PomodoroSoundService` and tests covering: focus completion plays focus sound when enabled, no sound when disabled, short-break plays break sound, long-break plays break sound, reset does not trigger sound, skip does not trigger sound, playback failure does not prevent phase transition, session persistence remains unchanged
    - Use a fake implementation recording method calls; verify exact invocation counts; simulate throwing service for resilience test
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_
    - **Property 1: Correct sound on natural completion when enabled**
    - **Property 2: No sound on natural completion when disabled**
    - **Property 3: Manual actions never trigger sound**
    - **Property 4: Phase transition resilience**
    - **Property 5: Dispose on controller disposal**

- [ ] 9. Manual verification
  - [ ] 9.1 Run `flutter analyze` and `flutter test` to confirm zero analyzer warnings and all tests pass
    - _Requirements: all_

- [ ] 10. Final checkpoint
  - [ ] 10.1 Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- The optional subtitle enhancement (Requirement 11) may be addressed as a follow-up; the sound toggle subtitle in ARB files and `sound_settings_section.dart` is not blocking for core functionality
- Audio asset files must be provided by the developer — no copyrighted audio is generated or committed
- Property tests validate universal correctness properties defined in the design document
- The `audioplayers` package must not introduce new Android permissions — verify after `pub get`

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["2.1", "2.2", "3.1"] },
    { "id": 2, "tasks": ["4.1", "4.2"] },
    { "id": 3, "tasks": ["5.1", "6.1"] },
    { "id": 4, "tasks": ["7.1", "8.1"] },
    { "id": 5, "tasks": ["9.1"] },
    { "id": 6, "tasks": ["10.1"] }
  ]
}
```
