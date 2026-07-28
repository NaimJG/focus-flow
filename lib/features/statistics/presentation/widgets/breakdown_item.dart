import 'package:flutter/material.dart';

/// A single row in a task or category breakdown list.
///
/// Displays the group title (with ellipsis overflow), formatted duration,
/// session count, and a [LinearProgressIndicator] representing the
/// percentage of total focused time.
class BreakdownItem extends StatelessWidget {
  /// Creates a breakdown item.
  const BreakdownItem({
    super.key,
    required this.title,
    required this.formattedTime,
    required this.sessionCount,
    required this.percentage,
  });

  /// Display title for the group (task name or category name).
  final String title;

  /// Pre-formatted duration string (e.g., "45 min" or "2 h 15 min").
  final String formattedTime;

  /// Number of completed sessions in this group.
  final int sessionCount;

  /// Fraction of total focused time (0.0–1.0).
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final sessionLabel = sessionCount == 1
        ? '1 session'
        : '$sessionCount sessions';

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formattedTime,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  sessionLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Semantics(
              label: '${(percentage * 100).round()}%',
              child: LinearProgressIndicator(
                value: percentage,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
