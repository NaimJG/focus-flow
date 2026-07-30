import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_language.dart';
import '../controllers/settings_controller.dart';

/// Displays the "Language" settings section with a segmented button
/// for choosing between Español and English.
///
/// Language option labels are always displayed in their own language
/// ("Español" and "English") regardless of the current locale. The
/// section header is localized via [AppLocalizations].
class LanguageSettingsSection extends StatelessWidget {
  /// Creates a [LanguageSettingsSection].
  const LanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    final theme = Theme.of(context);
    final enabled = !controller.isSaving;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.settingsLanguage,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<AppLanguage>(
            segments: [
              ButtonSegment<AppLanguage>(
                value: AppLanguage.spanish,
                label: Semantics(
                  label: 'Español',
                  selected: settings.language == AppLanguage.spanish,
                  child: const Text('Español'),
                ),
              ),
              ButtonSegment<AppLanguage>(
                value: AppLanguage.english,
                label: Semantics(
                  label: 'English',
                  selected: settings.language == AppLanguage.english,
                  child: const Text('English'),
                ),
              ),
            ],
            selected: {settings.language},
            onSelectionChanged: enabled
                ? (selection) {
                    controller.updateLanguage(selection.first);
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
