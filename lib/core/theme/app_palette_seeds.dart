import 'package:flutter/material.dart';

import '../../features/settings/domain/entities/app_color_palette.dart';

/// Seed [Color] constants for each [AppColorPalette] option.
///
/// Used by [AppTheme] to generate Material 3 [ColorScheme]s via
/// `ColorScheme.fromSeed`.
abstract final class AppPaletteSeeds {
  /// Warm coral red — Material red-300.
  static const Color salmon = Color(0xFFE57373);

  /// Clear sky blue — Material lightBlue-300.
  static const Color lightBlue = Color(0xFF4FC3F7);

  /// Natural green — Material green-300.
  static const Color lightGreen = Color(0xFF81C784);

  /// Returns the seed [Color] for the given [palette].
  static Color seedForPalette(AppColorPalette palette) => switch (palette) {
    AppColorPalette.salmon => salmon,
    AppColorPalette.lightBlue => lightBlue,
    AppColorPalette.lightGreen => lightGreen,
  };
}
