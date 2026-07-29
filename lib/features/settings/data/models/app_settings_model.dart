import 'package:isar/isar.dart';

import '../../domain/entities/app_color_palette.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_mode.dart';

part 'app_settings_model.g.dart';

/// Isar collection representing the single persisted settings record.
///
/// Uses a fixed [id] of 1 so there is only ever one settings record.
@collection
class AppSettingsModel {
  /// Fixed primary key — only one settings record exists.
  Id id = 1;

  /// Focus session duration in whole minutes.
  int focusDurationMinutes = 25;

  /// Short break duration in whole minutes.
  int shortBreakDurationMinutes = 5;

  /// Long break duration in whole minutes.
  int longBreakDurationMinutes = 15;

  /// Number of focus cycles before a long break.
  int cyclesBeforeLongBreak = 4;

  /// Whether sound notifications are enabled.
  bool soundEnabled = true;

  /// Application brightness mode stored as ordinal index.
  @enumerated
  AppThemeMode themeMode = AppThemeMode.system;

  /// Selected color palette stored as ordinal index.
  @enumerated
  AppColorPalette colorPalette = AppColorPalette.salmon;

  /// Converts this Isar model to a domain [AppSettings] entity.
  AppSettings toEntity() {
    return AppSettings(
      focusDuration: Duration(minutes: focusDurationMinutes),
      shortBreakDuration: Duration(minutes: shortBreakDurationMinutes),
      longBreakDuration: Duration(minutes: longBreakDurationMinutes),
      cyclesBeforeLongBreak: cyclesBeforeLongBreak,
      soundEnabled: soundEnabled,
      themeMode: themeMode,
      colorPalette: colorPalette,
    );
  }

  /// Creates an [AppSettingsModel] from a domain [AppSettings] entity.
  static AppSettingsModel fromEntity(AppSettings entity) {
    return AppSettingsModel()
      ..focusDurationMinutes = entity.focusDuration.inMinutes
      ..shortBreakDurationMinutes = entity.shortBreakDuration.inMinutes
      ..longBreakDurationMinutes = entity.longBreakDuration.inMinutes
      ..cyclesBeforeLongBreak = entity.cyclesBeforeLongBreak
      ..soundEnabled = entity.soundEnabled
      ..themeMode = entity.themeMode
      ..colorPalette = entity.colorPalette;
  }
}
