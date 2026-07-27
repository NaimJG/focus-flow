import '../entities/focus_session.dart';

/// Abstract interface for retrieving focus sessions.
/// Implemented by the adapter in data/ layer.
abstract interface class StatisticsSessionSource {
  /// Returns focus sessions whose startedAt falls within [start, end).
  Future<List<FocusSession>> getSessionsByDateRange({
    required DateTime start,
    required DateTime end,
  });
}
