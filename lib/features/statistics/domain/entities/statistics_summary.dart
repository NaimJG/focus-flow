/// Aggregate metrics for a date range.
class StatisticsSummary {
  /// Creates a [StatisticsSummary] with the given metrics.
  const StatisticsSummary({
    required this.totalFocusedSeconds,
    required this.sessionCount,
    required this.averageSessionSeconds,
  });

  /// Total focused time in seconds across all sessions in the range.
  final int totalFocusedSeconds;

  /// Number of completed focus sessions in the range.
  final int sessionCount;

  /// Average session duration in seconds (integer division).
  final int averageSessionSeconds;
}
