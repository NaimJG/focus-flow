import '../entities/task_pomodoro_stats.dart';
import '../repositories/pomodoro_session_repository.dart';

/// Aggregates Pomodoro session data for a specific task into a
/// [TaskPomodoroStats] summary.
///
/// Fetches all completed Focus-mode sessions associated with [taskId]
/// and computes the total count and cumulative focused duration.
class GetTaskPomodoroStatsUseCase {
  const GetTaskPomodoroStatsUseCase(this._repository);

  final PomodoroSessionRepository _repository;

  /// Returns aggregated Pomodoro statistics for the given [taskId].
  ///
  /// When no sessions exist for the task, returns zero values.
  Future<TaskPomodoroStats> call(int taskId) async {
    final sessions = await _repository.getByTaskId(taskId);

    final completedPomodoros = sessions.length;
    final totalSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.actualDurationSeconds,
    );

    return TaskPomodoroStats(
      completedPomodoros: completedPomodoros,
      focusedDuration: Duration(seconds: totalSeconds),
    );
  }
}
