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
