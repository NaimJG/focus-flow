import '../../../pomodoro/domain/entities/pomodoro_session.dart';
import '../../../pomodoro/domain/entities/timer_mode.dart';
import '../../../pomodoro/domain/repositories/pomodoro_session_repository.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/statistics_session_source.dart';

/// Implements [StatisticsSessionSource] by delegating to the existing
/// [PomodoroSessionRepository] and mapping [PomodoroSession] →
/// [FocusSession].
///
/// Only sessions with [TimerMode.focus] are included.
class StatisticsSessionAdapter implements StatisticsSessionSource {
  /// Creates an adapter wrapping the given [pomodoroSessionRepository].
  const StatisticsSessionAdapter({
    required PomodoroSessionRepository pomodoroSessionRepository,
  }) : _repository = pomodoroSessionRepository;

  final PomodoroSessionRepository _repository;

  @override
  Future<List<FocusSession>> getSessionsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final sessions = await _repository.getByDateRange(start: start, end: end);
    return sessions
        .where((s) => s.timerMode == TimerMode.focus)
        .map(
          (s) => FocusSession(
            startedAt: s.startedAt,
            actualDurationSeconds: s.actualDurationSeconds,
            taskId: s.taskId,
            taskTitleSnapshot: s.taskTitleSnapshot,
          ),
        )
        .toList();
  }
}
