import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Displays the current Pomodoro cycle progress as circular indicators.
///
/// The number of indicators is determined by [totalCycles]. Filled circles
/// represent completed focus sessions. The currently active session shows
/// a circular progress ring. Pending (incomplete, non-active) sessions use
/// a lighter visual style that recedes behind completed and active cycles.
class CycleProgressIndicator extends StatelessWidget {
  /// Creates a [CycleProgressIndicator].
  const CycleProgressIndicator({
    super.key,
    required this.cycleCount,
    required this.totalCycles,
    this.focusSessionProgress = 0.0,
    this.showProgress = false,
  });

  /// Number of Focus sessions completed in the current cycle.
  final int cycleCount;

  /// Total number of cycles before a long break (from config).
  final int totalCycles;

  /// Progress of the current focus session (0.0 to 1.0).
  final double focusSessionProgress;

  /// Whether to show the progress ring on the current active indicator.
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final completedCycles = cycleCount.clamp(0, totalCycles);
    final activeIndex = completedCycles < totalCycles ? completedCycles : -1;

    return Semantics(
      label: l10n.pomodoroCycleSemantics(completedCycles, totalCycles),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalCycles, (index) {
          final isCompleted = index < completedCycles;
          final isActive = showProgress && index == activeIndex;
          final percent = (focusSessionProgress * 100).round();

          final String semanticsLabel;
          if (isCompleted) {
            semanticsLabel = l10n.pomodoroCycleSessionCompleted(index + 1);
          } else if (isActive) {
            semanticsLabel = l10n.pomodoroCycleSessionInProgress(
              index + 1,
              totalCycles,
              percent,
            );
          } else {
            semanticsLabel = l10n.pomodoroCycleSessionIncomplete(index + 1);
          }

          return Semantics(
            label: semanticsLabel,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildIndicator(
                theme: theme,
                isCompleted: isCompleted,
                isActive: isActive,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIndicator({
    required ThemeData theme,
    required bool isCompleted,
    required bool isActive,
  }) {
    if (isActive) {
      return _ActiveCycleIndicator(
        progress: focusSessionProgress,
        primaryColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primaryContainer,
      );
    }

    if (isCompleted) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
      );
    }

    // Pending (incomplete, non-active) cycle — lighter style.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 2),
      ),
    );
  }
}

/// Displays a single cycle indicator with an animated circular progress ring.
class _ActiveCycleIndicator extends StatelessWidget {
  const _ActiveCycleIndicator({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: progress, end: progress),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, animatedProgress, child) {
        return CustomPaint(
          size: const Size(16, 16),
          painter: _ProgressRingPainter(
            progress: animatedProgress,
            color: primaryColor,
            trackColor: primaryColor.withValues(alpha: 0.2),
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}

/// Custom painter that draws a circular progress arc starting from the top,
/// with a light inner fill so the ring remains visually prominent.
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 3) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw inner background fill.
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1, bgPaint);

    // Draw background track.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);

    // Draw progress arc.
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      final startAngle = -pi / 2;
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
