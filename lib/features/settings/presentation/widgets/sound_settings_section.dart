import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';

/// Displays the "Sound" settings section with a toggle switch for
/// enabling or disabling sound notifications.
class SoundSettingsSection extends StatelessWidget {
  /// Creates a [SoundSettingsSection].
  const SoundSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    final enabled = !controller.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Sound', style: Theme.of(context).textTheme.titleMedium),
        ),
        SwitchListTile(
          title: const Text('Sound'),
          subtitle: Text(settings.soundEnabled ? 'Enabled' : 'Disabled'),
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
