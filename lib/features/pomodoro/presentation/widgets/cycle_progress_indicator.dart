import 'package:flutter/material.dart';

/// Displays the current Pomodoro cycle progress as "N / 4".
class CycleProgressIndicator extends StatelessWidget {
  const CycleProgressIndicator({super.key, required this.cycleCount});

  /// Number of Focus sessions completed in the current cycle (0–4).
  final int cycleCount;

  @override
  Widget build(BuildContext context) {
    final label = '$cycleCount / 4';

    return Semantics(
      label: '$cycleCount of 4 focus sessions completed',
      child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
