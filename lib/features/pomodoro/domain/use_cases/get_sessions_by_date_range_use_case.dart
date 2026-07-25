import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_session_repository.dart';

/// Retrieves all completed Pomodoro sessions whose [PomodoroSession.completedAt]
/// falls within a given date range.
///
/// Delegates to [PomodoroSessionRepository.getByDateRange] for persistence
/// access.
class GetSessionsByDateRangeUseCase {
  const GetSessionsByDateRangeUseCase(this._repository);

  final PomodoroSessionRepository _repository;

  /// Returns sessions completed between [start] and [end] (inclusive).
  Future<List<PomodoroSession>> call({
    required DateTime start,
    required DateTime end,
  }) {
    return _repository.getByDateRange(start: start, end: end);
  }
}
