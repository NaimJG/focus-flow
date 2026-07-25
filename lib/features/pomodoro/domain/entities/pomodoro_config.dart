import 'timer_mode.dart';

/// Immutable value object holding Pomodoro duration configuration.
///
/// Separates duration configuration from timer logic so durations
/// can be changed in one place without touching state transition
/// or countdown code.
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
  Duration durationFor(TimerMode mode) => switch (mode) {
    TimerMode.focus => focusDuration,
    TimerMode.shortBreak => shortBreakDuration,
    TimerMode.longBreak => longBreakDuration,
  };
}
