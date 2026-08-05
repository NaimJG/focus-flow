# Design Document

## Overview

Add completion sound playback to the existing Pomodoro timer by introducing a lightweight `PomodoroSoundService` abstract interface in `core/services/`, a concrete implementation using the `audioplayers` package, and a single integration point in `PomodoroController._onCompletion()`. The feature plays one of two bundled `.mp3` assets depending on whether a focus or break phase completed naturally, respects the existing `soundEnabled` preference, and never blocks timer transitions regardless of audio outcome.

## Architecture

### Audio Package Choice: audioplayers

The `audioplayers` package (^6.1.0) is selected because:

- Mature, high pub.dev score, active maintenance
- Supports Android asset playback via `AssetSource` without INTERNET permission
- No analytics, ads, or foreground service requirements
- Minimal native dependency footprint for playing short sound effects
- No additional permissions beyond what Flutter already requires

Alternatives considered and rejected:
- `just_audio` — heavier native dependencies, overkill for two short .mp3 files
- `flutter_sound` — requires microphone permission, inappropriate scope

### Integration Architecture

```
lib/
├── core/
│   └── services/
│       ├── pomodoro_sound_service.dart      ← Abstract interface
│       └── asset_pomodoro_sound_service.dart ← Concrete implementation (audioplayers)
├── features/
│   └── pomodoro/
│       └── presentation/
│           └── controllers/
│               └── pomodoro_controller.dart  ← Modified: accepts PomodoroSoundService
└── app/
    └── app.dart                              ← Modified: wires service into provider
```

The sound service is an application-level infrastructure concern (`core/services/`) because audio playback is not specific to the Pomodoro domain model — it is an output side-effect triggered by domain events.

### Dependency Flow

```
PomodoroController → PomodoroSoundService (abstract)
                          ↑
Provider<PomodoroSoundService> → AssetPomodoroSoundService (concrete, uses audioplayers)
```

`PomodoroController` depends only on the abstract interface. It never imports `audioplayers`. The concrete implementation is injected at the app level via Provider, and PomodoroController reads it through `context.read<PomodoroSoundService>()`.

## Components and Interfaces

### Interface Design

```dart
/// Abstract interface for Pomodoro completion sound playback.
///
/// Implementations must swallow all audio errors internally.
/// Callers should fire-and-forget without awaiting results.
abstract interface class PomodoroSoundService {
  /// Plays the focus-completed sound once.
  /// Errors are swallowed internally — never throws.
  Future<void> playFocusCompleted();

  /// Plays the break-completed sound once.
  /// Errors are swallowed internally — never throws.
  Future<void> playBreakCompleted();

  /// Releases all audio resources. Safe to call multiple times.
  Future<void> dispose();
}
```

### Concrete Implementation: AssetPomodoroSoundService

```dart
/// Plays bundled completion sounds using a single [AudioPlayer] instance.
///
/// Stops any in-progress playback before starting a new sound.
/// All errors are swallowed internally — callers never see exceptions.
class AssetPomodoroSoundService implements PomodoroSoundService {
  AssetPomodoroSoundService();

  final AudioPlayer _player = AudioPlayer();
  bool _disposed = false;

  @override
  Future<void> playFocusCompleted() async {
    if (_disposed) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/focus_complete.mp3'));
    } catch (_) {
      // Swallow all audio errors
    }
  }

  @override
  Future<void> playBreakCompleted() async {
    if (_disposed) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/break_complete.mp3'));
    } catch (_) {
      // Swallow all audio errors
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      await _player.dispose();
    } catch (_) {
      // Safe disposal
    }
  }
}
```

Key design decisions:
- **Single AudioPlayer instance**: simpler, avoids resource duplication; stop-before-play prevents overlapping sounds
- **No constructor preloading**: avoids unawaited async in constructor; `play(AssetSource(...))` loads and plays in one call
- **Disposed flag**: makes dispose idempotent
- **No retry logic**: single attempt per completion event, failures are silent
- **stop() before play()**: prevents overlapping playback if two completions happen in rapid succession

### PomodoroController Integration

### Constructor Changes

```dart
class PomodoroController extends ChangeNotifier with WidgetsBindingObserver {
  PomodoroController({
    required SavePomodoroSessionUseCase saveSessionUseCase,
    required List<PomodoroTaskOption> Function() taskListProvider,
    PomodoroConfig config = const PomodoroConfig(),
    Clock clock = const SystemClock(),
    PomodoroSoundService? soundService,         // NEW — optional for backward compat
    bool Function()? isSoundEnabled,            // NEW — reads current preference
  });
}
```

Both parameters are optional. Existing tests that do not provide a sound service continue to work unchanged.

### _onCompletion() Modification

```dart
void _onCompletion() {
  if (_status != TimerStatus.running) return;
  _timer?.cancel();
  _timer = null;
  _completedMode = _currentMode;
  _status = TimerStatus.completed;
  _remainingDuration = Duration.zero;

  if (_currentMode == TimerMode.focus) {
    _cycleCount++;
    _persistSession();
  }

  // --- Sound playback (fire-and-forget via dart:async unawaited) ---
  _playCompletionSound();

  _advanceToNextMode();
  notifyListeners();
}

void _playCompletionSound() {
  if (_soundService == null) return;
  if (!(_isSoundEnabled?.call() ?? false)) return;

  final Future<void> playback = switch (_completedMode!) {
    TimerMode.focus => _soundService!.playFocusCompleted(),
    TimerMode.shortBreak => _soundService!.playBreakCompleted(),
    TimerMode.longBreak => _soundService!.playBreakCompleted(),
  };
  unawaited(playback);
}
```

Key decisions:
- **`dart:async` `unawaited()`** is used explicitly to mark fire-and-forget intent
- **Switch expression** with explicit returns per case for clarity
- Called AFTER persistence and state updates so errors cannot interrupt them
- `_completedMode` is set before the call, ensuring the correct sound is selected
- The service itself swallows errors, so no try-catch is needed in the controller

**Note:** PomodoroController does not own or dispose the sound service. Disposal is managed by the Provider tree.

### Provider Wiring (app.dart)

```dart
// In MultiProvider.providers list — add BEFORE the PomodoroController provider:
Provider<PomodoroSoundService>(
  create: (_) => AssetPomodoroSoundService(),
  dispose: (_, service) => service.dispose(),
),

// In ChangeNotifierProxyProvider2 create — read from context:
create: (context) => PomodoroController(
  saveSessionUseCase: saveSessionUseCase,
  taskListProvider: () => [],
  soundService: context.read<PomodoroSoundService>(),
  isSoundEnabled: () => settingsController.settings.soundEnabled,
)..init(),
```

Key decisions:
- Service is registered as `Provider<PomodoroSoundService>` — created once, disposed by Provider when the widget tree is removed.
- NOT instantiated inside `build()` — Provider handles lifecycle.
- PomodoroController receives the service via `context.read<>()` at creation time.
- The `isSoundEnabled` callback captures `settingsController` and reads the live value at the moment of completion.
- No new controller is created. The existing `ChangeNotifierProxyProvider2` signature is preserved.

## Assets

### pubspec.yaml Addition

```yaml
flutter:
  assets:
    - assets/branding/
    - assets/audio/       # NEW
```

### Required Files

- `assets/audio/focus_complete.mp3` — short notification sound for focus completion
- `assets/audio/break_complete.mp3` — short notification sound for break completion

These files must be provided by the developer. They must be public-domain or appropriately licensed for commercial distribution through Google Play.

**Important:** Do NOT create empty or placeholder MP3 files. The developer must provide valid playable audio files. The asset task is paused until both files are available and verified.

### License Documentation

`docs/licenses/audio-assets.md` documents the source, license, and commercial-use confirmation for each audio file.

## Data Models

No new Isar collections, domain entities, or data models. This feature is purely infrastructure/presentation — it adds an output side-effect (sound) triggered by an existing domain event (natural completion).

## Error Handling

| Scenario | Behavior |
|---|---|
| Audio file missing | `AssetPomodoroSoundService` catches exception, returns silently |
| AudioPlayer throws on play | Caught in service, no propagation |
| Service itself throws (edge case) | Service swallows errors internally; `unawaited()` in controller means unhandled futures do not propagate |
| Dispose called multiple times | No-op after first call (disposed flag) |
| Service null (not injected) | No-op, null-safe access throughout |

No blocking dialogs, no retry logic, no user-visible errors from audio failures.

## Presentation Enhancement

The existing sound toggle in settings may optionally receive a localized subtitle:

- Spanish: `"Reproduce un sonido al finalizar cada sesión"`
- English: `"Play a sound when each session ends"`

This uses the existing ARB localization architecture. No new screens or settings are added.

## Component Breakdown

### New Files to Create

| File | Purpose |
|---|---|
| `lib/core/services/pomodoro_sound_service.dart` | Abstract interface |
| `lib/core/services/asset_pomodoro_sound_service.dart` | Concrete implementation using audioplayers |
| `assets/audio/focus_complete.mp3` | Focus completion sound (developer-provided) |
| `assets/audio/break_complete.mp3` | Break completion sound (developer-provided) |
| `docs/licenses/audio-assets.md` | Audio asset license documentation |
| `test/features/pomodoro/presentation/controllers/pomodoro_controller_sound_test.dart` | Sound behavior tests |

### Files to Modify

| File | Change |
|---|---|
| `pubspec.yaml` | Add `audioplayers: ^6.1.0` dependency + `assets/audio/` entry |
| `lib/features/pomodoro/presentation/controllers/pomodoro_controller.dart` | Add optional `PomodoroSoundService?` param + `_playCompletionSound()` using `unawaited()`. No dispose call. |
| `lib/app/app.dart` | Register `Provider<PomodoroSoundService>`, inject into existing PomodoroController provider |
| `lib/l10n/app_es.arb` | Add optional subtitle string |
| `lib/l10n/app_en.arb` | Add optional subtitle string |

## Testing Strategy

All sound behavior is tested through a **fake `PomodoroSoundService` implementation** that records method invocations without performing real audio playback. This allows unit tests to run in CI without audio hardware or platform dependencies.

### Approach

- **Unit tests** exercise `PomodoroController` with a `FakePomodoroSoundService` injected, verifying:
  - Correct method is called for each phase type on natural completion
  - No method is called when `soundEnabled` is false
  - No method is called on manual actions (pause, resume, reset, skip, start)
  - Phase transitions succeed even when the fake service throws
  - Changing soundEnabled mid-timer affects the next completion's sound behavior
- **No real audio in tests** — the `audioplayers` package is never imported in test files. The abstract interface boundary ensures complete isolation.
- **Property-based tests** use generated combinations of timer modes, sound-enabled states, and user actions to validate correctness properties across many input scenarios.

### Test File

`test/features/pomodoro/presentation/controllers/pomodoro_controller_sound_test.dart`

### Fake Implementation

```dart
class FakePomodoroSoundService implements PomodoroSoundService {
  final List<String> calls = [];
  bool shouldThrow = false;

  @override
  Future<void> playFocusCompleted() async {
    calls.add('playFocusCompleted');
    if (shouldThrow) throw Exception('fake audio error');
  }

  @override
  Future<void> playBreakCompleted() async {
    calls.add('playBreakCompleted');
    if (shouldThrow) throw Exception('fake audio error');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Correct sound on natural completion when enabled

*For any* natural timer completion (focus, short break, or long break) where `soundEnabled` is `true` at the moment of completion, the PomodoroSoundService SHALL be invoked exactly once with the correct method: `playFocusCompleted()` for focus phases, `playBreakCompleted()` for break phases.

**Validates: Requirements 1.1, 2.1, 2.2, 7.1, 8.5**

### Property 2: No sound on natural completion when disabled

*For any* natural timer completion (focus, short break, or long break) where `soundEnabled` is `false` at the moment of completion, the PomodoroSoundService SHALL receive zero invocations for playback methods.

**Validates: Requirements 1.2, 2.3, 7.2**

### Property 3: Manual actions never trigger sound

*For any* manual user action (pause, resume, reset, skip, or start) performed in any valid timer state, the PomodoroSoundService SHALL receive zero invocations for playback methods.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.7**

### Property 4: Phase transition resilience

*For any* natural timer completion, the phase transition (mode advance + state update) and session persistence SHALL succeed regardless of the PomodoroSoundService outcome — including when the service throws an exception, returns slowly, or is null.

**Validates: Requirements 1.3, 1.4, 2.4, 8.1, 8.2**

## Open Questions

None — all design decisions are resolved. The developer must provide licensed audio assets before the feature is functional.
