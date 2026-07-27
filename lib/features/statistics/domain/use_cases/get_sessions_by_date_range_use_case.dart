import '../entities/focus_session.dart';
import '../entities/statistics_date_range.dart';
import '../repositories/statistics_session_source.dart';

/// Retrieves focus sessions that fall within a given date range.
///
/// Delegates to [StatisticsSessionSource] using the boundaries
/// defined by [StatisticsDateRange].
class GetSessionsByDateRangeUseCase {
  /// Creates the use case with its required [source] dependency.
  const GetSessionsByDateRangeUseCase({required this.source});

  /// The data source used to fetch sessions.
  final StatisticsSessionSource source;

  /// Returns all [FocusSession]s whose start time falls within [range].
  Future<List<FocusSession>> call(StatisticsDateRange range) {
    return source.getSessionsByDateRange(start: range.start, end: range.end);
  }
}
