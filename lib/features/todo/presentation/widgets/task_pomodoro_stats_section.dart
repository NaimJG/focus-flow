import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../pomodoro/domain/entities/task_pomodoro_stats.dart';
import '../../../statistics/presentation/utils/duration_formatter.dart';
import '../controllers/task_pomodoro_stats_controller.dart';

/// A read-only section displaying Pomodoro activity metrics for a task.
///
/// Renders a Material 3 Card with three metrics (completed pomodoros,
/// equivalent cycles, focused time) using a responsive [Wrap] layout.
/// Handles loading, error, empty, and loaded states gracefully.
class TaskPomodoroStatsSection extends StatelessWidget {
  const TaskPomodoroStatsSection({
    super.key,
    required this.status,
    required this.stats,
    required this.cyclesBeforeLongBreak,
    required this.l10n,
  });

  /// The current loading state from the controller.
  final TaskPomodoroStatsStatus status;

  /// The loaded stats, or null when loading/error.
  final TaskPomodoroStats? stats;

  /// From SettingsController, used for equivalent cycles calculation.
  final int cyclesBeforeLongBreak;

  /// Localization instance.
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.taskPomodoroActivity,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (status) {
      case TaskPomodoroStatsStatus.loading:
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case TaskPomodoroStatsStatus.error:
        return Text(
          l10n.todoFormGenericError,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      case TaskPomodoroStatsStatus.loaded:
        final currentStats = stats;
        if (currentStats == null || currentStats.completedPomodoros == 0) {
          return Text(
            l10n.taskNoPomodoroActivity,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        return _buildMetrics(context, currentStats);
    }
  }

  Widget _buildMetrics(BuildContext context, TaskPomodoroStats stats) {
    final equivalentCycles = stats.completedPomodoros ~/ cyclesBeforeLongBreak;

    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        _MetricItem(
          icon: Icons.local_fire_department,
          value: l10n.taskPomodoroCount(stats.completedPomodoros),
          label: l10n.taskCompletedPomodoros,
          semanticsLabel: l10n.taskPomodoroCount(stats.completedPomodoros),
        ),
        _MetricItem(
          icon: Icons.loop,
          value: l10n.taskEquivalentCycleCount(equivalentCycles),
          label: l10n.taskEquivalentCycles,
          semanticsLabel: l10n.taskEquivalentCycleCount(equivalentCycles),
        ),
        _MetricItem(
          icon: Icons.timer,
          value: formatDuration(stats.focusedDuration.inSeconds, l10n),
          label: l10n.taskFocusedTime,
          semanticsLabel: formatDuration(stats.focusedDuration.inSeconds, l10n),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.semanticsLabel,
  });

  final IconData icon;
  final String value;
  final String label;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: '$label: $semanticsLabel',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
