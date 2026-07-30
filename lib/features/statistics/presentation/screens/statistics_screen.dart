import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/statistics_controller.dart';
import '../widgets/category_breakdown_list.dart';
import '../widgets/daily_activity_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/summary_cards_row.dart';
import '../widgets/task_breakdown_list.dart';

/// The primary screen for the Statistics feature.
///
/// Displays productivity metrics for the selected time period including
/// summary cards, a daily activity chart, and breakdowns by task and
/// category. Handles loading, error, and empty states explicitly.
class StatisticsScreen extends StatelessWidget {
  /// Creates a [StatisticsScreen].
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StatisticsController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: PeriodSelector(
                  selectedPeriod: controller.selectedPeriod,
                  onPeriodChanged: controller.changePeriod,
                ),
              ),
              const SizedBox(height: 24),
              _buildContent(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StatisticsController controller) {
    if (controller.isLoading) {
      return const _LoadingState();
    }

    if (controller.errorMessage != null) {
      return _ErrorState(
        message: controller.errorMessage!,
        onRetry: controller.retry,
      );
    }

    if (controller.isEmpty) {
      return const _EmptyState();
    }

    return _DataState(controller: controller);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 64),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.statisticsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.statisticsEmptyTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.statisticsEmptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DataState extends StatelessWidget {
  const _DataState({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.summary != null)
          SummaryCardsRow(summary: controller.summary!),
        const SizedBox(height: 24),
        if (controller.dailyActivity.isNotEmpty)
          DailyActivityChart(dailyData: controller.dailyActivity),
        const SizedBox(height: 24),
        if (controller.taskBreakdown.isNotEmpty)
          TaskBreakdownList(taskData: controller.taskBreakdown),
        const SizedBox(height: 16),
        if (controller.categoryBreakdown.isNotEmpty)
          CategoryBreakdownList(categoryData: controller.categoryBreakdown),
      ],
    );
  }
}
