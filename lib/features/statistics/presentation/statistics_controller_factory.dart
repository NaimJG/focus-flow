import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/clock.dart';
import '../../pomodoro/domain/repositories/pomodoro_session_repository.dart';
import '../../todo/presentation/controllers/todo_controller.dart';
import '../data/repositories/statistics_session_adapter.dart';
import '../domain/entities/statistics_task_category_option.dart';
import '../domain/use_cases/calculate_date_range_use_case.dart';
import '../domain/use_cases/calculate_summary_use_case.dart';
import '../domain/use_cases/get_sessions_by_date_range_use_case.dart';
import '../domain/use_cases/group_sessions_by_category_use_case.dart';
import '../domain/use_cases/group_sessions_by_day_use_case.dart';
import '../domain/use_cases/group_sessions_by_task_use_case.dart';
import 'controllers/statistics_controller.dart';

/// Creates a fully initialized [StatisticsController] by reading
/// dependencies from the [context] Provider tree.
///
/// This factory encapsulates the controller creation logic shared
/// between `_StatisticsRoute` (standalone `/statistics` route) and
/// `StatisticsTabHost` (embedded in the HomeScreen shell).
///
/// The returned controller has already called [StatisticsController.init],
/// so it begins loading data immediately.
StatisticsController createStatisticsController(BuildContext context) {
  final pomodoroRepo = context.read<PomodoroSessionRepository>();

  final adapter = StatisticsSessionAdapter(
    pomodoroSessionRepository: pomodoroRepo,
  );

  const clock = SystemClock();
  final calculateDateRange = CalculateDateRangeUseCase(clock);
  final getSessionsByDateRange = GetSessionsByDateRangeUseCase(source: adapter);
  const calculateSummary = CalculateSummaryUseCase();
  const groupByDay = GroupSessionsByDayUseCase();
  const groupByTask = GroupSessionsByTaskUseCase();
  const groupByCategory = GroupSessionsByCategoryUseCase();

  return StatisticsController(
    calculateDateRangeUseCase: calculateDateRange,
    getSessionsByDateRangeUseCase: getSessionsByDateRange,
    calculateSummaryUseCase: calculateSummary,
    groupSessionsByDayUseCase: groupByDay,
    groupSessionsByTaskUseCase: groupByTask,
    groupSessionsByCategoryUseCase: groupByCategory,
    taskCategoryMappingProvider: () {
      final todoCtrl = context.read<TodoController>();
      final categories = todoCtrl.categories;
      final categoryMap = <int, String>{
        for (final cat in categories) cat.id: cat.name,
      };
      return List<StatisticsTaskCategoryOption>.unmodifiable(
        todoCtrl.allTasks.map(
          (task) => StatisticsTaskCategoryOption(
            taskId: task.id,
            categoryId: task.categoryId,
            categoryName: task.categoryId != null
                ? categoryMap[task.categoryId]
                : null,
          ),
        ),
      );
    },
  )..init();
}
