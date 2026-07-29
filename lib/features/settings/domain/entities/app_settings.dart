import 'app_color_palette.dart';
import 'app_theme_mode.dart';

/// Immutable value object representing all user-configurable preferences.
///
/// Default values match the standard Pomodoro Technique defaults:
/// 25 min focus, 5 min short break, 15 min long break, 4 cycles.
class AppSettings {
  const AppSettings({
    this.focusDuration = const Duration(minutes: 25),
    this.shortBreakDuration = const Duration(minutes: 5),
    this.longBreakDuration = const Duration(minutes: 15),
    this.cyclesBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.themeMode = AppThemeMode.system,
    this.colorPalette = AppColorPalette.salmon,
  });

  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int cyclesBeforeLongBreak;
  final bool soundEnabled;
  final AppThemeMode themeMode;
  final AppColorPalette colorPalette;

  AppSettings copyWith({
    Duration? focusDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
    int? cyclesBeforeLongBreak,
    bool? soundEnabled,
    AppThemeMode? themeMode,
    AppColorPalette? colorPalette,
  }) {
    return AppSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      cyclesBeforeLongBreak:
          cyclesBeforeLongBreak ?? this.cyclesBeforeLongBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      themeMode: themeMode ?? this.themeMode,
      colorPalette: colorPalette ?? this.colorPalette,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          focusDuration == other.focusDuration &&
          shortBreakDuration == other.shortBreakDuration &&
          longBreakDuration == other.longBreakDuration &&
          cyclesBeforeLongBreak == other.cyclesBeforeLongBreak &&
          soundEnabled == other.soundEnabled &&
          themeMode == other.themeMode &&
          colorPalette == other.colorPalette;

  @override
  int get hashCode => Object.hash(
    focusDuration,
    shortBreakDuration,
    longBreakDuration,
    cyclesBeforeLongBreak,
    soundEnabled,
    themeMode,
    colorPalette,
  );
}
