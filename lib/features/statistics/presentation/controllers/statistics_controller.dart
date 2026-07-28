import 'package:flutter/foundation.dart';
import 'dart:collection';

import '../../domain/entities/category_focus_statistics.dart';
import '../../domain/entities/daily_focus_statistics.dart';
import '../../domain/entities/statistics_date_range.dart';
import '../../domain/entities/statistics_period.dart';
import '../../domain/entities/statistics_summary.dart';
import '../../domain/entities/statistics_task_category_option.dart';
import '../../domain/entities/task_focus_statistics.dart';
import '../../domain/use_cases/calculate_date_range_use_case.dart';
import '../../domain/use_cases/calculate_summary_use_case.dart';
import '../../domain/use_cases/get_sessions_by_date_range_use_case.dart';
import '../../domain/use_cases/group_sessions_by_category_use_case.dart';
import '../../domain/use_cases/group_sessions_by_day_use_case.dart';
import '../../domain/use_cases/group_sessions_by_task_use_case.dart';

/// Manages all Statistics screen state. Route-scoped via
/// ChangeNotifierProvider — created on route entry, disposed on
/// exit.
class StatisticsController extends ChangeNotifier {
  /// Creates a [StatisticsController] with all required use cases
  /// and a provider callback for the task-to-category mapping.
  ///
  /// The [_taskCategoryMappingProvider] is called each time data is
  /// loaded, ensuring the category breakdown reflects the latest
  /// todo state.
  StatisticsController({
    required this._calculateDateRangeUseCase,
    required this._getSessionsByDateRangeUseCase,
    required this._calculateSummaryUseCase,
    required this._groupSessionsByDayUseCase,
    required this._groupSessionsByTaskUseCase,
    required this._groupSessionsByCategoryUseCase,
    required this._taskCategoryMappingProvider,
  });

  final CalculateDateRangeUseCase _calculateDateRangeUseCase;
  final GetSessionsByDateRangeUseCase _getSessionsByDateRangeUseCase;
  final CalculateSummaryUseCase _calculateSummaryUseCase;
  final GroupSessionsByDayUseCase _groupSessionsByDayUseCase;
  final GroupSessionsByTaskUseCase _groupSessionsByTaskUseCase;
  final GroupSessionsByCategoryUseCase _groupSessionsByCategoryUseCase;
  final List<StatisticsTaskCategoryOption> Function()
  _taskCategoryMappingProvider;

  // --- State ---
  StatisticsPeriod _selectedPeriod = StatisticsPeriod.today;
  StatisticsDateRange? _dateRange;
  StatisticsSummary? _summary;
  List<DailyFocusStatistics> _dailyActivity = [];
  List<TaskFocusStatistics> _taskBreakdown = [];
  List<CategoryFocusStatistics> _categoryBreakdown = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmpty = false;

  // --- Getters ---

  /// The currently selected time period filter.
  StatisticsPeriod get selectedPeriod => _selectedPeriod;

  /// The computed date range for the selected period.
  StatisticsDateRange? get dateRange => _dateRange;

  /// Aggregate summary metrics for the current period.
  StatisticsSummary? get summary => _summary;

  /// Daily focus data for the bar chart.
  UnmodifiableListView<DailyFocusStatistics> get dailyActivity =>
      UnmodifiableListView(_dailyActivity);

  /// Focus time grouped by task.
  UnmodifiableListView<TaskFocusStatistics> get taskBreakdown =>
      UnmodifiableListView(_taskBreakdown);

  /// Focus time grouped by category.
  UnmodifiableListView<CategoryFocusStatistics> get categoryBreakdown =>
      UnmodifiableListView(_categoryBreakdown);

  /// Whether data is currently being loaded.
  bool get isLoading => _isLoading;

  /// User-facing error message, or null when no error.
  String? get errorMessage => _errorMessage;

  /// Whether the current period has no sessions.
  bool get isEmpty => _isEmpty;

  // --- Public Methods ---

  /// Loads data for the default period (Today).
  /// Called once after construction.
  Future<void> init() => _loadData();

  /// Changes the selected period and reloads data.
  Future<void> changePeriod(StatisticsPeriod period) {
    _selectedPeriod = period;
    return _loadData();
  }

  /// Reloads data for the currently selected period.
  Future<void> refresh() => _loadData();

  /// Alias for [refresh] — used as the retry action after errors.
  Future<void> retry() => _loadData();

  // --- Private ---

  Future<void> _loadData() async {
    _isLoading = true;
    _errorMessage = null;
    _clearComputedData();
    notifyListeners();

    try {
      final range = _calculateDateRangeUseCase.call(_selectedPeriod);
      _dateRange = range;
      final sessions = await _getSessionsByDateRangeUseCase.call(range);

      if (sessions.isEmpty) {
        _isEmpty = true;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _isEmpty = false;
      _summary = _calculateSummaryUseCase.call(sessions);
      _dailyActivity = _groupSessionsByDayUseCase.call(sessions, range);
      _taskBreakdown = _groupSessionsByTaskUseCase.call(sessions);
      _categoryBreakdown = _groupSessionsByCategoryUseCase.call(
        sessions,
        _taskCategoryMappingProvider(),
      );
      _isLoading = false;
      notifyListeners();
    } on Exception {
      _errorMessage = 'Could not load statistics. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearComputedData() {
    _summary = null;
    _dailyActivity = [];
    _taskBreakdown = [];
    _categoryBreakdown = [];
    _isEmpty = false;
  }
}
