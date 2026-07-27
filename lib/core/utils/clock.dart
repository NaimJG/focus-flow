/// Abstraction over system time for testability.
///
/// The [Clock] interface allows the timer controller to obtain the current
/// time through an injectable dependency. Tests can provide a fake
/// implementation that returns controlled timestamps, enabling deterministic
/// verification of drift-resistant timer behavior.
abstract interface class Clock {
  /// Returns the current time as a UTC [DateTime].
  DateTime now();
}

/// Production implementation of [Clock] that delegates to the system clock.
///
/// All timestamps are returned in UTC to ensure timezone-independent
/// persistence and consistent date-range queries across time zones.
class SystemClock implements Clock {
  /// Creates a [SystemClock] instance.
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
