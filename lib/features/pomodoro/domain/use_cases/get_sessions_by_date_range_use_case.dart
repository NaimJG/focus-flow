import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_session_repository.dart';

/// Retrieves completed Pomodoro sessions whose
/// [PomodoroSession.startedAt] falls within [start, end).
///
/// [start] is inclusive and [end] is exclusive.
class GetSessionsByDateRangeUseCase {
  const GetSessionsByDateRangeUseCase(this._repository);

  final PomodoroSessionRepository _repository;

  Future<List<PomodoroSession>> call({
    required DateTime start,
    required DateTime end,
  }) {
    return _repository.getByDateRange(start: start, end: end);
  }
}
