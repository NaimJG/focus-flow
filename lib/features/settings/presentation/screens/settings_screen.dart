import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../widgets/appearance_settings_section.dart';
import '../widgets/language_settings_section.dart';
import '../widgets/pomodoro_settings_section.dart';
import '../widgets/sound_settings_section.dart';

/// The primary screen for the Settings feature.
///
/// Displays grouped preference controls (Pomodoro, Appearance, Sound)
/// and handles loading, error, and loaded states. Uses
/// [SettingsController] provided at application scope.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _lastSaveError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSaveError();
  }

  void _checkSaveError() {
    final controller = context.read<SettingsController>();
    final currentError = controller.saveErrorMessage;

    if (currentError != null && currentError != _lastSaveError) {
      _lastSaveError = currentError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(currentError),
              duration: const Duration(seconds: 4),
            ),
          );
        controller.clearSaveError();
      });
    } else if (currentError == null) {
      _lastSaveError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();

    // Check for save errors on every rebuild.
    _checkSaveError();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: switch (controller.status) {
        SettingsStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        SettingsStatus.error => _ErrorBody(
          message:
              controller.errorMessage ??
              'Could not load settings. Please try again.',
          onRetry: controller.retry,
        ),
        SettingsStatus.loaded => const _LoadedBody(),
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        PomodoroSettingsSection(),
        AppearanceSettingsSection(),
        LanguageSettingsSection(),
        SoundSettingsSection(),
      ],
    );
  }
}
