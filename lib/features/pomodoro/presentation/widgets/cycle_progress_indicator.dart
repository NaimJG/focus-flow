import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Displays the current Pomodoro cycle progress as circular indicators.
///
/// The number of indicators is determined by [totalCycles]. Filled circles
/// represent completed focus sessions. Empty circles with a primary outline
/// represent incomplete sessions.
class CycleProgressIndicator extends StatelessWidget {
  /// Creates a [CycleProgressIndicator].
  const CycleProgressIndicator({
    super.key,
    required this.cycleCount,
    required this.totalCycles,
  });

  /// Number of Focus sessions completed in the current cycle.
  final int cycleCount;

  /// Total number of cycles before a long break (from config).
  final int totalCycles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final completedCycles = cycleCount.clamp(0, totalCycles);

    return Semantics(
      label: l10n.pomodoroCycleSemantics(completedCycles, totalCycles),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalCycles, (index) {
          final isCompleted = index < completedCycles;
          return Semantics(
            label: isCompleted
                ? l10n.pomodoroCycleSessionCompleted(index + 1)
                : l10n.pomodoroCycleSessionIncomplete(index + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
