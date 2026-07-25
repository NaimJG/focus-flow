import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_session_repository.dart';

/// Persists a completed Pomodoro session via the repository layer.
class SavePomodoroSessionUseCase {
  const SavePomodoroSessionUseCase(this._repository);

  final PomodoroSessionRepository _repository;

  /// Delegates persistence of [session] to the repository and returns
  /// the saved entity with an assigned ID.
  Future<PomodoroSession> call(PomodoroSession session) {
    return _repository.create(session);
  }
}
