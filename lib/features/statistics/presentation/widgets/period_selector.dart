import 'package:flutter/material.dart';

import '../../domain/entities/statistics_period.dart';

/// A segmented button control for selecting the statistics time period.
///
/// Displays three segments — Today, This Week, This Month — and notifies
/// the parent when the user selects a different period.
class PeriodSelector extends StatelessWidget {
  /// Creates a period selector widget.
  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  /// The currently selected statistics period.
  final StatisticsPeriod selectedPeriod;

  /// Called when the user selects a different period.
  final ValueChanged<StatisticsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StatisticsPeriod>(
      segments: const [
        ButtonSegment<StatisticsPeriod>(
          value: StatisticsPeriod.today,
          label: Text('Today'),
        ),
        ButtonSegment<StatisticsPeriod>(
          value: StatisticsPeriod.week,
          label: Text('This Week'),
        ),
        ButtonSegment<StatisticsPeriod>(
          value: StatisticsPeriod.month,
          label: Text('This Month'),
        ),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (selection) {
        onPeriodChanged(selection.first);
      },
    );
  }
}
