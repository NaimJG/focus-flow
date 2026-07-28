import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/clock.dart';
import '../../../pomodoro/domain/repositories/pomodoro_session_repository.dart';
import '../../../statistics/data/repositories/statistics_session_adapter.dart';
import '../../../statistics/domain/entities/statistics_task_category_option.dart';
import '../../../statistics/domain/use_cases/calculate_date_range_use_case.dart';
import '../../../statistics/domain/use_cases/calculate_summary_use_case.dart';
import '../../../statistics/domain/use_cases/get_sessions_by_date_range_use_case.dart';
import '../../../statistics/domain/use_cases/group_sessions_by_category_use_case.dart';
import '../../../statistics/domain/use_cases/group_sessions_by_day_use_case.dart';
import '../../../statistics/domain/use_cases/group_sessions_by_task_use_case.dart';
import '../../../statistics/presentation/controllers/statistics_controller.dart';
import '../../../statistics/presentation/screens/statistics_screen.dart';
import '../../../todo/presentation/controllers/todo_controller.dart';

/// Hosts the Statistics tab content with lazy [StatisticsController]
/// lifecycle management.
///
/// Defers controller creation until [TodoController] has finished its
/// initial load, ensuring the task-to-category mapping reflects the
/// actual todo state rather than a stale empty snapshot.
class StatisticsTabHost extends StatefulWidget {
  /// Creates a [StatisticsTabHost].
  const StatisticsTabHost({super.key});

  @override
  State<StatisticsTabHost> createState() => _StatisticsTabHostState();
}

class _StatisticsTabHostState extends State<StatisticsTabHost> {
  StatisticsController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  StatisticsController _createController() {
    final pomodoroRepo = context.read<PomodoroSessionRepository>();

    final adapter = StatisticsSessionAdapter(
      pomodoroSessionRepository: pomodoroRepo,
    );

    const clock = SystemClock();
    final calculateDateRange = CalculateDateRangeUseCase(clock);
    final getSessionsByDateRange = GetSessionsByDateRangeUseCase(
      source: adapter,
    );
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

  @override
  Widget build(BuildContext context) {
    final todoController = context.watch<TodoController>();

    if (_controller == null && todoController.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _controller ??= _createController();

    return ChangeNotifierProvider<StatisticsController>.value(
      value: _controller!,
      child: const StatisticsScreen(),
    );
  }
}
