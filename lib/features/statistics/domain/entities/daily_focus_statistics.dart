/// Focus data for a single calendar day.
class DailyFocusStatistics {
  /// Creates a [DailyFocusStatistics] instance.
  const DailyFocusStatistics({
    required this.date,
    required this.totalFocusedSeconds,
    required this.sessionCount,
  });

  /// The local calendar day (time component zeroed).
  final DateTime date;

  /// Total focused seconds for this day.
  final int totalFocusedSeconds;

  /// Number of completed sessions on this day.
  final int sessionCount;
}
