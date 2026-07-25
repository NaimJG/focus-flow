import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_session_repository.dart';

/// Retrieves Pomodoro sessions filtered by task association.
///
/// When [taskId] is non-null, returns sessions linked to that task.
/// When [taskId] is null, returns sessions that have no associated task.
class GetSessionsByTaskIdUseCase {
  const GetSessionsByTaskIdUseCase(this._repository);

  final PomodoroSessionRepository _repository;

  /// Returns sessions associated with [taskId], or unlinked sessions
  /// when [taskId] is null.
  Future<List<PomodoroSession>> call(int? taskId) {
    if (taskId != null) {
      return _repository.getByTaskId(taskId);
    }
    return _repository.getByNullTask();
  }
}
