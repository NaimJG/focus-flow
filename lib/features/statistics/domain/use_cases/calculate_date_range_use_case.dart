import '../../../../core/utils/clock.dart';
import '../entities/statistics_date_range.dart';
import '../entities/statistics_period.dart';

/// Computes UTC query boundaries from a [StatisticsPeriod] and the
/// current time provided by a [Clock].
///
/// All conversions respect the device's local timezone. The [Clock]
/// provides current UTC time; this use case converts to local to
/// determine the calendar boundaries, then converts boundaries back
/// to UTC for querying.
class CalculateDateRangeUseCase {
  /// Creates a [CalculateDateRangeUseCase] with the given [clock].
  const CalculateDateRangeUseCase(this._clock);

  final Clock _clock;

  /// Returns a [StatisticsDateRange] with inclusive [start] and
  /// exclusive [end] in UTC for the given [period].
  StatisticsDateRange call(StatisticsPeriod period) {
    final now = _clock.now().toLocal();

    switch (period) {
      case StatisticsPeriod.today:
        return _computeToday(now);
      case StatisticsPeriod.week:
        return _computeWeek(now);
      case StatisticsPeriod.month:
        return _computeMonth(now);
    }
  }

  StatisticsDateRange _computeToday(DateTime localNow) {
    final start = DateTime(localNow.year, localNow.month, localNow.day);

    final end = DateTime(localNow.year, localNow.month, localNow.day + 1);

    return StatisticsDateRange(start: start.toUtc(), end: end.toUtc());
  }

  StatisticsDateRange _computeWeek(DateTime localNow) {
    final daysFromMonday = localNow.weekday - DateTime.monday;

    final monday = DateTime(
      localNow.year,
      localNow.month,
      localNow.day - daysFromMonday,
    );

    final nextMonday = DateTime(monday.year, monday.month, monday.day + 7);

    return StatisticsDateRange(start: monday.toUtc(), end: nextMonday.toUtc());
  }

  StatisticsDateRange _computeMonth(DateTime localNow) {
    final start = DateTime(localNow.year, localNow.month);
    final int nextMonth;
    final int nextYear;
    if (localNow.month == DateTime.december) {
      nextMonth = DateTime.january;
      nextYear = localNow.year + 1;
    } else {
      nextMonth = localNow.month + 1;
      nextYear = localNow.year;
    }
    final end = DateTime(nextYear, nextMonth);
    return StatisticsDateRange(start: start.toUtc(), end: end.toUtc());
  }
}
