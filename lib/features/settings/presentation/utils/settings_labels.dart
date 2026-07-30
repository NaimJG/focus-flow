import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_color_palette.dart';
import '../../domain/entities/app_theme_mode.dart';

/// Returns the localized display label for an [AppThemeMode] value.
///
/// Maps each theme mode to its human-readable name
/// (e.g., "Sistema" / "System").
String themeModeLabel(AppThemeMode mode, AppLocalizations l10n) =>
    switch (mode) {
      AppThemeMode.system => l10n.settingsThemeModeSystem,
      AppThemeMode.light => l10n.settingsThemeModeLight,
      AppThemeMode.dark => l10n.settingsThemeModeDark,
    };

/// Returns the localized display label for an [AppColorPalette] value.
///
/// Maps each color palette to its human-readable name
/// (e.g., "Salmón" / "Salmon").
String colorPaletteLabel(AppColorPalette palette, AppLocalizations l10n) =>
    switch (palette) {
      AppColorPalette.salmon => l10n.settingsPaletteSalmon,
      AppColorPalette.lightBlue => l10n.settingsPaletteLightBlue,
      AppColorPalette.lightGreen => l10n.settingsPaletteLightGreen,
    };
