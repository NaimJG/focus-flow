import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_focus_statistics.dart';
import '../utils/duration_formatter.dart';

const double _maxBarHeight = 120;
const double _minBarHeight = 4;
const double _barWidth = 36;

class DailyActivityChart extends StatelessWidget {
  const DailyActivityChart({super.key, required this.dailyData});

  final List<DailyFocusStatistics> dailyData;

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxSeconds = dailyData
        .map((entry) => entry.totalFocusedSeconds)
        .reduce(max);

    return SizedBox(
      height: _maxBarHeight + 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final entry in dailyData)
              SizedBox(
                width: _barWidth,
                child: _DailyBar(entry: entry, maxSeconds: maxSeconds),
              ),
          ],
        ),
      ),
    );
  }
}

class _DailyBar extends StatelessWidget {
  const _DailyBar({required this.entry, required this.maxSeconds});

  final DailyFocusStatistics entry;
  final int maxSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fraction = maxSeconds > 0
        ? entry.totalFocusedSeconds / maxSeconds
        : 0.0;

    final barHeight =
        _minBarHeight + fraction * (_maxBarHeight - _minBarHeight);

    final dayLabel = _shortDayLabel(
      entry.date,
      Localizations.localeOf(context).languageCode,
    );
    final l10n = AppLocalizations.of(context)!;
    final tooltipMessage =
        '$dayLabel: ${formatDuration(entry.totalFocusedSeconds, l10n)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Tooltip(
                message: tooltipMessage,
                child: Semantics(
                  label: tooltipMessage,
                  child: Container(
                    width: 20,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  String _shortDayLabel(DateTime date, String locale) {
    return DateFormat.E(locale).format(date);
  }
}
