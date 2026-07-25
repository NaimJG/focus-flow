import 'timer_mode.dart';

/// Immutable domain entity representing a completed Pomodoro focus session.
///
/// Contains all data captured at session completion: timing information,
/// the mode that was active, and an optional task association with a
/// title snapshot for historical reference.
class PomodoroSession {
  const PomodoroSession({
    required this.id,
    required this.timerMode,
    required this.startedAt,
    required this.completedAt,
    required this.plannedDurationSeconds,
    required this.actualDurationSeconds,
    this.taskId,
    this.taskTitleSnapshot,
  });

  /// Unique identifier assigned by the persistence layer.
  final int id;

  /// The timer mode for this session (always [TimerMode.focus] for
  /// persisted sessions in the MVP).
  final TimerMode timerMode;

  /// UTC timestamp when the user first pressed Start for this session.
  final DateTime startedAt;

  /// UTC timestamp when the session completed naturally.
  final DateTime completedAt;

  /// Configured focus duration in seconds at the time of the session.
  final int plannedDurationSeconds;

  /// Active countdown time in seconds (equals planned for natural
  /// completion).
  final int actualDurationSeconds;

  /// Optional reference to the associated Todo task ID.
  final int? taskId;

  /// Snapshot of the task title at persistence time, for historical
  /// reference even if the task is later renamed or deleted.
  final String? taskTitleSnapshot;
}
