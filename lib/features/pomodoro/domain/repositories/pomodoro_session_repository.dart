import '../entities/pomodoro_session.dart';

/// Defines persistence operations for Pomodoro sessions.
abstract interface class PomodoroSessionRepository {
  /// Persists a new session and returns it with an assigned ID.
  Future<PomodoroSession> create(PomodoroSession session);

  /// Returns all persisted sessions.
  Future<List<PomodoroSession>> getAll();

  /// Returns sessions whose [PomodoroSession.startedAt] falls within
  /// the range [start, end).
  ///
  /// [start] is inclusive and [end] is exclusive.
  Future<List<PomodoroSession>> getByDateRange({
    required DateTime start,
    required DateTime end,
  });
  
  /// Returns sessions associated with the given [taskId].
  Future<List<PomodoroSession>> getByTaskId(int taskId);

  /// Returns sessions that have no associated task.
  Future<List<PomodoroSession>> getByNullTask();
}
