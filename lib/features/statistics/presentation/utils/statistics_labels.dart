import '../../../../l10n/app_localizations.dart';

import '../../domain/entities/statistics_period.dart';

/// Returns the localized display label for a [StatisticsPeriod].
String statisticsPeriodLabel(
  StatisticsPeriod period,
  AppLocalizations l10n,
) =>
    switch (period) {
      StatisticsPeriod.today => l10n.statisticsPeriodToday,
      StatisticsPeriod.week => l10n.statisticsPeriodWeek,
      StatisticsPeriod.month => l10n.statisticsPeriodMonth,
    };
