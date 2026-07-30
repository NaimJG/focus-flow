import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

import '../../domain/entities/statistics_summary.dart';
import '../utils/duration_formatter.dart';

/// Displays three summary metric cards in a row: Total Time,
/// Sessions, and Average session duration.
///
/// Each card uses Material 3 styling with colors from the current
/// theme and provides a [Semantics] label for accessibility.
class SummaryCardsRow extends StatelessWidget {
  /// Creates a summary cards row.
  const SummaryCardsRow({super.key, required this.summary});

  /// The aggregate metrics to display.
  final StatisticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalTime = formatDuration(summary.totalFocusedSeconds, l10n);
    final sessions = summary.sessionCount.toString();
    final average = formatDuration(summary.averageSessionSeconds, l10n);

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: l10n.statisticsTotalTime,
            value: totalTime,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: l10n.statisticsSessions,
            value: sessions,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: l10n.statisticsAverage,
            value: average,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Card(
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
