# Requirements Document

## Introduction

Play a short bundled sound when a Pomodoro phase completes naturally (focus, short break, or long break). The sound is controlled by the existing `soundEnabled` preference in AppSettings, requires no network access, and must never block timer transitions regardless of audio playback outcome.

## Glossary

- **PomodoroController**: ChangeNotifier managing all Pomodoro timer state, provided at the app level via ChangeNotifierProxyProvider2.
- **Natural_Completion**: The timer countdown reaches zero without user intervention (pause, reset, skip).
- **Bundled_Asset**: An audio file included in the app package at build time under `assets/audio/`.
- **PomodoroSoundService**: Abstract interface for completion sound playback, residing in `core/services/`.
- **soundEnabled**: Boolean preference in AppSettings controlling whether completion sounds play. Defaults to true.
- **Focus_Phase**: A timed work session (default 25 minutes) that increments the cycle count upon natural completion.
- **Short_Break_Phase**: A short rest period between focus sessions (default 5 minutes).
- **Long_Break_Phase**: An extended rest period after a full cycle of focus sessions (default 15 minutes).
- **Phase_Transition**: The automatic advancement from the current timer mode to the next mode in the Pomodoro cycle.

## Requirements

### Requirement 1: Focus Phase Completion Sound

**User Story:** As a user, I want to hear a sound when my Focus session completes naturally, so that I am notified the session ended even if I am not looking at the screen.

#### Acceptance Criteria

1. WHEN a Focus_Phase countdown reaches zero through Natural_Completion AND soundEnabled is true, THE PomodoroSoundService SHALL play the Bundled_Asset `focus_complete.mp3` exactly once.
2. WHEN a Focus_Phase countdown reaches zero through Natural_Completion AND soundEnabled is false, THE PomodoroSoundService SHALL not be invoked for audio playback.
3. WHEN a Focus_Phase completes through Natural_Completion, THE PomodoroController SHALL preserve existing session persistence behavior regardless of sound playback outcome.
4. WHEN a Focus_Phase completes through Natural_Completion, THE PomodoroController SHALL transition to the corresponding break mode regardless of sound playback outcome.

### Requirement 2: Break Phase Completion Sound

**User Story:** As a user, I want to hear a sound when my break completes naturally, so that I know it is time to start another focus session.

#### Acceptance Criteria

1. WHEN a Short_Break_Phase countdown reaches zero through Natural_Completion AND soundEnabled is true, THE PomodoroSoundService SHALL play the Bundled_Asset `break_complete.mp3` exactly once.
2. WHEN a Long_Break_Phase countdown reaches zero through Natural_Completion AND soundEnabled is true, THE PomodoroSoundService SHALL play the Bundled_Asset `break_complete.mp3` exactly once.
3. WHEN a break phase countdown reaches zero through Natural_Completion AND soundEnabled is false, THE PomodoroSoundService SHALL not be invoked for audio playback.
4. WHEN a break phase completes through Natural_Completion, THE PomodoroController SHALL transition to Focus_Phase regardless of sound playback outcome.

### Requirement 3: Actions That Must Not Play Sound

**User Story:** As a user, I want sounds to play only on natural completion, so that manual actions do not trigger unexpected audio.

#### Acceptance Criteria

1. WHEN the user pauses the timer, THE PomodoroController SHALL not invoke PomodoroSoundService for any completion sound.
2. WHEN the user resumes the timer, THE PomodoroController SHALL not invoke PomodoroSoundService for any completion sound.
3. WHEN the user resets the timer, THE PomodoroController SHALL not invoke PomodoroSoundService for any completion sound.
4. WHEN the user skips a phase, THE PomodoroController SHALL not invoke PomodoroSoundService for any completion sound.
5. WHEN the user changes any setting, THE PomodoroController SHALL not invoke PomodoroSoundService for any completion sound.
6. WHEN the user exits the Pomodoro screen, THE PomodoroController SHALL not invoke PomodoroSoundService for any completion sound.
7. WHEN the user starts a timer manually, THE PomodoroController SHALL not invoke PomodoroSoundService for any completion sound.

### Requirement 4: Bundled Audio Assets

**User Story:** As a developer, I want licensed audio assets bundled with the app, so that sound playback works offline without network access.

#### Acceptance Criteria

1. THE application SHALL include `assets/audio/focus_complete.mp3` registered in pubspec.yaml — the file SHALL be a valid, playable MP3 provided by the developer.
2. THE application SHALL include `assets/audio/break_complete.mp3` registered in pubspec.yaml — the file SHALL be a valid, playable MP3 provided by the developer.
3. THE application SHALL document the audio source and license in `docs/licenses/audio-assets.md`.
4. THE committed audio assets SHALL be public-domain or appropriately licensed for commercial distribution through Google Play.
5. THE implementation SHALL NOT create empty, fake, or placeholder MP3 files. The developer MUST provide two valid playable audio files before committing.
6. THE asset task SHALL be paused until both valid audio files are available, playback is verified, and source/license are documented.

### Requirement 5: Audio Package Selection

**User Story:** As a developer, I want a single lightweight audio package that supports playing bundled assets on Android, so that no unnecessary permissions or network dependencies are added.

#### Acceptance Criteria

1. THE selected audio package SHALL support Android platform playback.
2. THE selected audio package SHALL support playing Bundled_Asset files from Flutter assets.
3. THE selected audio package SHALL not require network access for playing bundled audio.
4. THE selected audio package SHALL not add analytics or advertising SDKs.
5. THE selected audio package SHALL not require notification permissions.
6. THE selected audio package SHALL not require a foreground service for short asset playback.
7. IF an audio playback package already exists in pubspec.yaml, THEN THE application SHALL reuse that package; OTHERWISE THE application SHALL add exactly one audio package.

### Requirement 6: Sound Service Abstraction

**User Story:** As a developer, I want audio playback isolated behind an interface, so that PomodoroController is not coupled to a specific audio package.

#### Acceptance Criteria

1. THE application SHALL define an abstract interface named PomodoroSoundService with methods for playing focus-completed sound, playing break-completed sound, and disposing resources.
2. THE application SHALL create one concrete implementation of PomodoroSoundService backed by the chosen audio package.
3. THE PomodoroController SHALL not import or reference the audio package directly.
4. THE PomodoroSoundService SHALL be registered as a Provider in the existing Provider tree. The Provider SHALL create the service once and dispose it when the Provider is removed.
5. THE PomodoroSoundService SHALL reside in `core/services/` as an application-level infrastructure concern.

### Requirement 7: Settings Integration

**User Story:** As a user, I want the existing sound toggle to control completion sounds, so that I can enable or disable them without a separate setting.

#### Acceptance Criteria

1. WHEN soundEnabled is true at the moment of Natural_Completion, THE PomodoroController SHALL invoke PomodoroSoundService to play the appropriate completion sound.
2. WHEN soundEnabled is false at the moment of Natural_Completion, THE PomodoroController SHALL not invoke PomodoroSoundService for playback.
3. WHEN the user changes soundEnabled, THE application SHALL apply the new preference to subsequent completions without restarting or resetting the active timer.
4. THE application SHALL not add another sound toggle or sound preference beyond the existing soundEnabled field.
5. THE application SHALL preserve existing Settings persistence behavior without modification.

### Requirement 8: Playback Resilience

**User Story:** As a user, I want the timer to always transition correctly even if audio fails, so that a broken speaker or audio issue does not block my workflow.

#### Acceptance Criteria

1. IF audio playback fails, THEN THE PomodoroController SHALL still complete the Phase_Transition normally.
2. IF audio playback throws an exception, THEN THE PomodoroController SHALL catch the exception without rethrowing.
3. IF audio playback fails, THEN THE application SHALL not show a blocking dialog to the user.
4. IF audio playback fails, THEN THE PomodoroSoundService SHALL not repeatedly retry playback for the same completion event.
5. THE PomodoroSoundService SHALL not play the same completion sound more than once for a single Phase_Transition.
6. THE PomodoroSoundService SHALL safely release audio resources when the dispose method is called.
7. IF audio playback fails, THEN THE application MAY log the error in debug mode without exposing user data.

### Requirement 9: Lifecycle and Resource Management

**User Story:** As a developer, I want audio resources cleaned up properly, so that no memory leaks or disposal errors occur.

#### Acceptance Criteria

1. THE PomodoroSoundService SHALL be owned and disposed by the Provider tree, not by PomodoroController.
2. PomodoroController SHALL NOT call dispose on PomodoroSoundService — it did not create the service.
3. THE PomodoroSoundService SHALL NOT create a new audio playback object on every timer tick.
4. THE PomodoroSoundService SHALL NOT leak audio resources on rapid navigation.
5. THE PomodoroController SHALL maintain existing timer lifecycle behavior without modification.
6. WHEN the user rapidly navigates away from and back to the Pomodoro screen, THE PomodoroSoundService SHALL NOT throw exceptions related to audio.

### Requirement 10: Platform and Permissions

**User Story:** As a developer, I want no new Android permissions introduced, so that the app's permission profile remains minimal.

#### Acceptance Criteria

1. THE application SHALL not add INTERNET permission to AndroidManifest.xml.
2. THE application SHALL not add POST_NOTIFICATIONS permission to AndroidManifest.xml.
3. THE application SHALL not add a foreground service declaration to AndroidManifest.xml.
4. THE application SHALL not add exact alarm permission to AndroidManifest.xml.
5. THE application SHALL not add storage permission to AndroidManifest.xml.
6. THE application SHALL not add microphone permission to AndroidManifest.xml.
7. THE Bundled_Asset audio playback SHALL remain entirely local without network requests.
8. THE release dependency and Data Safety audit SHALL be updated to document the selected audio package and confirm the package transmits no user data.

### Requirement 11: Presentation Enhancement

**User Story:** As a user, I want clarity on what the sound toggle does, so that the setting is self-explanatory.

#### Acceptance Criteria

1. WHERE the current sound toggle lacks a descriptive subtitle explaining completion sounds, THE application MAY add a localized subtitle in Spanish ("Reproduce un sonido al finalizar cada sesión") and English ("Play a sound when each session ends").
2. THE application SHALL not add new screens for sound configuration.
3. WHEN a subtitle is added, THE application SHALL follow existing localization architecture using ARB files (app_es.arb and app_en.arb).

### Requirement 12: Testing

**User Story:** As a developer, I want automated tests proving sound behavior, so that regressions are caught.

#### Acceptance Criteria

1. THE test suite SHALL include a unit test verifying that a completed Focus_Phase invokes PomodoroSoundService focus-completed sound exactly once when soundEnabled is true.
2. THE test suite SHALL include a unit test verifying that a completed Focus_Phase invokes no sound when soundEnabled is false.
3. THE test suite SHALL include a unit test verifying that a completed Short_Break_Phase invokes PomodoroSoundService break-completed sound exactly once when soundEnabled is true.
4. THE test suite SHALL include a unit test verifying that a completed Long_Break_Phase invokes PomodoroSoundService break-completed sound exactly once when soundEnabled is true.
5. THE test suite SHALL include a unit test verifying that reset does not invoke PomodoroSoundService.
6. THE test suite SHALL include a unit test verifying that skip does not invoke PomodoroSoundService.
7. THE test suite SHALL include a unit test verifying that playback failure does not prevent Phase_Transition.
8. THE test suite SHALL include a unit test verifying that existing session persistence behavior remains unchanged.
9. THE test suite SHALL use a fake PomodoroSoundService implementation and SHALL not perform real audio playback.
10. THE test suite SHALL include a unit test verifying that changing soundEnabled during an active timer affects the sound behavior of the next natural completion.
