/// Statistics-owned DTO containing only the fields needed for computation.
/// Mapped from PomodoroSession in the adapter layer.
class FocusSession {
  const FocusSession({
    required this.startedAt,
    required this.actualDurationSeconds,
    this.taskId,
    this.taskTitleSnapshot,
  });

  /// UTC timestamp when the session started.
  final DateTime startedAt;

  /// Active focused time in seconds.
  final int actualDurationSeconds;

  /// Optional reference to the associated task.
  final int? taskId;

  /// Snapshot of the task title at persistence time.
  final String? taskTitleSnapshot;
}
