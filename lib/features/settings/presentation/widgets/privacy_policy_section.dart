import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_urls.dart';
import '../../../../l10n/app_localizations.dart';

/// Displays the "Privacy" settings section with a list tile that
/// opens the privacy policy URL in an external browser.
class PrivacyPolicySection extends StatelessWidget {
  /// Creates a [PrivacyPolicySection].
  const PrivacyPolicySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            l10n.settingsSectionPrivacy,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListTile(
          title: Text(l10n.settingsPrivacyPolicy),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openPrivacyPolicy(context),
        ),
      ],
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppUrls.privacyPolicy);
    final l10n = AppLocalizations.of(context)!;

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.settingsPrivacyPolicyError),
            ),
          );
      }
    }
  }
}
