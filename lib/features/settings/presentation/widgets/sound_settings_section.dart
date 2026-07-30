import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/settings_controller.dart';

/// Displays the "Sound" settings section with a toggle switch for
/// enabling or disabling sound notifications.
class SoundSettingsSection extends StatelessWidget {
  /// Creates a [SoundSettingsSection].
  const SoundSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    final enabled = !controller.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.settingsSectionSound,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SwitchListTile(
          title: Text(l10n.settingsSectionSound),
          subtitle: Text(
            settings.soundEnabled
                ? l10n.settingsSoundEnabled
                : l10n.settingsSoundDisabled,
          ),
          value: settings.soundEnabled,
          onChanged: enabled
              ? (value) {
                  controller.updateSoundEnabled(enabled: value);
                }
              : null,
        ),
      ],
    );
  }
}
