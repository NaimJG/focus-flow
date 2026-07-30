import '../../features/pomodoro/domain/entities/pomodoro_config.dart';
import '../../features/settings/domain/entities/app_settings.dart';

/// Maps [AppSettings] to [PomodoroConfig] at the composition layer.
///
/// This keeps the settings domain decoupled from the pomodoro domain —
/// neither feature needs to know about the other's entities.
PomodoroConfig mapSettingsToPomodoroConfig(AppSettings settings) {
  return PomodoroConfig(
    focusDuration: settings.focusDuration,
    shortBreakDuration: settings.shortBreakDuration,
    longBreakDuration: settings.longBreakDuration,
    sessionsBeforeLongBreak: settings.cyclesBeforeLongBreak,
  );
}
