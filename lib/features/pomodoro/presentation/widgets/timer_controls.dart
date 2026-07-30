import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timer_status.dart';

/// Controls for the Pomodoro timer, showing contextual buttons based on the
/// current [TimerStatus].
///
/// - Idle/Completed → Start button only.
/// - Running → Pause, Reset, Skip buttons.
/// - Paused → Resume, Reset, Skip buttons.
///
/// Primary actions use [FilledButton]; secondary actions use [OutlinedButton].
/// All buttons meet the 48×48dp minimum touch target requirement.
class TimerControls extends StatelessWidget {
  /// Creates a timer controls widget.
  const TimerControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
  });

  /// The current timer status that determines which buttons are visible.
  final TimerStatus status;

  /// Called when the user taps Start.
  final VoidCallback onStart;

  /// Called when the user taps Pause.
  final VoidCallback onPause;

  /// Called when the user taps Resume.
  final VoidCallback onResume;

  /// Called when the user taps Reset.
  final VoidCallback onReset;

  /// Called when the user taps Skip.
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _buildButtons(context),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case TimerStatus.idle:
      case TimerStatus.completed:
        return [
          _PrimaryButton(label: l10n.pomodoroControlStart, onPressed: onStart),
        ];
      case TimerStatus.running:
        return [
          _PrimaryButton(label: l10n.pomodoroControlPause, onPressed: onPause),
          _SecondaryButton(
            label: l10n.pomodoroControlReset,
            onPressed: onReset,
          ),
          _SecondaryButton(label: l10n.pomodoroControlSkip, onPressed: onSkip),
        ];
      case TimerStatus.paused:
        return [
          _PrimaryButton(
            label: l10n.pomodoroControlResume,
            onPressed: onResume,
          ),
          _SecondaryButton(
            label: l10n.pomodoroControlReset,
            onPressed: onReset,
          ),
          _SecondaryButton(label: l10n.pomodoroControlSkip, onPressed: onSkip),
        ];
    }
  }
}

/// A [FilledButton] used for the primary timer action (Start, Pause, Resume).
///
/// Ensures a minimum 48×48dp touch target via [minimumSize].
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      child: Text(label),
    );
  }
}

/// An [OutlinedButton] used for secondary timer actions (Reset, Skip).
///
/// Ensures a minimum 48×48dp touch target via [minimumSize].
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      child: Text(label),
    );
  }
}
