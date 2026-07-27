import '../entities/focus_session.dart';
import '../entities/statistics_summary.dart';

/// Computes aggregate [StatisticsSummary] metrics from a list of
/// [FocusSession] instances.
///
/// This is a pure computation with no external dependencies.
class CalculateSummaryUseCase {
  /// Creates a [CalculateSummaryUseCase].
  const CalculateSummaryUseCase();

  /// Returns a [StatisticsSummary] derived from [sessions].
  ///
  /// - `totalFocusedSeconds` is the sum of all
  ///   [FocusSession.actualDurationSeconds].
  /// - `sessionCount` is the number of sessions.
  /// - `averageSessionSeconds` is the integer division of total by count,
  ///   or zero when [sessions] is empty.
  StatisticsSummary call(List<FocusSession> sessions) {
    final sessionCount = sessions.length;
    final totalFocusedSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.actualDurationSeconds,
    );
    final averageSessionSeconds = sessionCount > 0
        ? totalFocusedSeconds ~/ sessionCount
        : 0;

    return StatisticsSummary(
      totalFocusedSeconds: totalFocusedSeconds,
      sessionCount: sessionCount,
      averageSessionSeconds: averageSessionSeconds,
    );
  }
}
