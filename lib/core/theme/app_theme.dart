import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_color_palette.dart';
import 'app_palette_seeds.dart';

/// Centralized Material 3 [ThemeData] factory for the application.
///
/// Generates light and dark themes from [AppPaletteSeeds] using
/// `ColorScheme.fromSeed`.
abstract final class AppTheme {
  /// Creates a light [ThemeData] seeded by the given [palette].
  static ThemeData light(AppColorPalette palette) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPaletteSeeds.seedForPalette(palette),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  /// Creates a dark [ThemeData] seeded by the given [palette].
  static ThemeData dark(AppColorPalette palette) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPaletteSeeds.seedForPalette(palette),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
