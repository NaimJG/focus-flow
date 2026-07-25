import 'package:flutter/material.dart';

import '../../domain/entities/timer_status.dart';

/// Displays the remaining time as MM:SS with a circular progress indicator
/// showing the proportion of elapsed time relative to the total duration.
class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.remainingDuration,
    required this.totalDuration,
    required this.status,
  });

  /// The time remaining on the current timer session.
  final Duration remainingDuration;

  /// The total configured duration for the current timer mode.
  final Duration totalDuration;

  /// The current timer status (used for potential styling variations).
  final TimerStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressValue = _calculateProgress();
    final timeText = _formatDuration(remainingDuration);
    final semanticsLabel = _buildSemanticsLabel();

    return Semantics(
      label: semanticsLabel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progressValue,
              strokeWidth: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
            ),
          ),
          ExcludeSemantics(
            child: Text(
              timeText,
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates the progress value for the circular indicator.
  ///
  /// Returns 0.0 when no time has elapsed (full remaining) and 1.0 when
  /// the timer has completed. Handles the edge case where totalDuration
  /// is zero to avoid division by zero.
  double _calculateProgress() {
    if (totalDuration.inMilliseconds == 0) {
      return 0.0;
    }
    final elapsed = totalDuration - remainingDuration;
    return (elapsed.inMilliseconds / totalDuration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  /// Formats a Duration as MM:SS with zero-padding.
  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Builds an accessibility label conveying minutes and seconds remaining.
  String _buildSemanticsLabel() {
    final totalSeconds = remainingDuration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes minutes $seconds seconds remaining';
  }
}
