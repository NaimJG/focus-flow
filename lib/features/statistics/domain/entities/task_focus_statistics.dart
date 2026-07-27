/// Focus data grouped by task.
class TaskFocusStatistics {
  /// Creates a [TaskFocusStatistics] instance.
  const TaskFocusStatistics({
    required this.taskId,
    required this.displayTitle,
    required this.totalFocusedSeconds,
    required this.sessionCount,
    required this.percentage,
  });

  /// Null for the "No task" group.
  final int? taskId;

  /// Display title: taskTitleSnapshot or "No task".
  final String displayTitle;

  /// Total focused seconds for this task group.
  final int totalFocusedSeconds;

  /// Number of completed sessions for this task group.
  final int sessionCount;

  /// Percentage of total focused time (0.0–1.0).
  final double percentage;
}
