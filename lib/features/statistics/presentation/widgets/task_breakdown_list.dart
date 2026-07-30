import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task_focus_statistics.dart';
import '../utils/duration_formatter.dart';
import 'breakdown_item.dart';

/// Displays a list of [BreakdownItem] widgets grouped by task.
class TaskBreakdownList extends StatelessWidget {
  /// Creates a [TaskBreakdownList].
  const TaskBreakdownList({super.key, required this.taskData});

  /// The list of per-task focus statistics to display.
  final List<TaskFocusStatistics> taskData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statisticsByTask,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...taskData.map(
          (task) => BreakdownItem(
            title: task.displayTitle,
            formattedTime: formatDuration(task.totalFocusedSeconds, l10n),
            sessionCount: task.sessionCount,
            percentage: task.percentage,
          ),
        ),
      ],
    );
  }
}
