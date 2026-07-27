/// Immutable value object representing a UTC date range [start, end).
class StatisticsDateRange {
  /// Creates a date range with an inclusive [start] and exclusive [end].
  const StatisticsDateRange({required this.start, required this.end});

  /// Inclusive start boundary (UTC).
  final DateTime start;

  /// Exclusive end boundary (UTC).
  final DateTime end;
}
