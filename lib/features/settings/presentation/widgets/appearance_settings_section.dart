import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_palette_seeds.dart';
import '../../domain/entities/app_color_palette.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../controllers/settings_controller.dart';

/// Maps [AppThemeMode] enum values to user-facing labels.
String _themeModeLabel(AppThemeMode mode) => switch (mode) {
  AppThemeMode.system => 'System',
  AppThemeMode.light => 'Light',
  AppThemeMode.dark => 'Dark',
};

/// Maps [AppColorPalette] enum values to user-facing labels.
String _paletteLabel(AppColorPalette palette) => switch (palette) {
  AppColorPalette.salmon => 'Salmon',
  AppColorPalette.lightBlue => 'Light Blue',
  AppColorPalette.lightGreen => 'Light Green',
};

/// Displays the "Appearance" settings section with a theme mode
/// selector and a color palette picker.
///
/// The theme mode is presented via a [SegmentedButton] with three
/// options (System, Light, Dark). The palette selector renders
/// labeled color swatches with a check-mark indicator on the active
/// palette. Each palette option meets the 48×48dp touch target
/// requirement and includes [Semantics] annotations for
/// accessibility.
class AppearanceSettingsSection extends StatelessWidget {
  /// Creates an [AppearanceSettingsSection].
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    final theme = Theme.of(context);
    final enabled = !controller.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Appearance', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<AppThemeMode>(
            segments: [
              for (final mode in AppThemeMode.values)
                ButtonSegment<AppThemeMode>(
                  value: mode,
                  label: Text(_themeModeLabel(mode)),
                ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: enabled
                ? (selection) {
                    controller.updateThemeMode(selection.first);
                  }
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Color palette', style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 0,
            runSpacing: 8,
            children: [
              for (final palette in AppColorPalette.values)
                _PaletteOption(
                  palette: palette,
                  isSelected: settings.colorPalette == palette,
                  enabled: enabled,
                  onTap: () {
                    controller.updateColorPalette(palette);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single palette option displaying a circular color swatch with
/// an optional check-mark overlay and a text label below.
class _PaletteOption extends StatelessWidget {
  const _PaletteOption({
    required this.palette,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final AppColorPalette palette;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = _paletteLabel(palette);
    final color = AppPaletteSeeds.seedForPalette(palette);
    final theme = Theme.of(context);

    return Semantics(
      selected: isSelected,
      label: label,
      button: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.38,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(label, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
