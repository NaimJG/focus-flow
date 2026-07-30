import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_theme_mode.dart';

/// Maps [AppThemeMode] domain enum to Flutter's [ThemeMode].
extension AppThemeModeMapper on AppThemeMode {
  /// Converts this [AppThemeMode] to the corresponding [ThemeMode].
  ThemeMode toFlutterThemeMode() => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
