import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_session_repository.dart';

/// Retrieves all persisted Pomodoro sessions.
class GetSessionsUseCase {
  const GetSessionsUseCase(this._repository);

  final PomodoroSessionRepository _repository;

  /// Returns every stored session by delegating to the repository.
  Future<List<PomodoroSession>> call() {
    return _repository.getAll();
  }
}
