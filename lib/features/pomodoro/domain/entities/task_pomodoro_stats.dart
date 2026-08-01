/// Immutable value object holding aggregated Pomodoro metrics for a
/// single task.
///
/// Contains the total number of completed Focus-mode sessions and the
/// cumulative focused duration across all of them.
class TaskPomodoroStats {
  const TaskPomodoroStats({
    required this.completedPomodoros,
    required this.focusedDuration,
  });

  /// Number of completed Focus-mode sessions for the task.
  final int completedPomodoros;

  /// Total actual focused time across all completed sessions.
  final Duration focusedDuration;
}
