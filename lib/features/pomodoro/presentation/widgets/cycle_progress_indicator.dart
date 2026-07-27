import 'package:flutter/material.dart';

/// Displays the current Pomodoro cycle progress as four circular indicators.
///
/// Filled circles represent completed focus sessions. Empty circles with a
/// primary outline represent incomplete sessions.
class CycleProgressIndicator extends StatelessWidget {
  /// Creates a [CycleProgressIndicator].
  const CycleProgressIndicator({super.key, required this.cycleCount});

  /// Number of Focus sessions completed in the current cycle (0–4).
  final int cycleCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = cycleCount.clamp(0, 4);

    return Semantics(
      label: '$clamped of 4 focus sessions completed',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (index) {
          final isCompleted = index < clamped;
          return Semantics(
            label:
                'Session ${index + 1} '
                '${isCompleted ? "completed" : "incomplete"}',
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
