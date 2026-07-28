import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/clock.dart';
import '../features/pomodoro/domain/repositories/pomodoro_session_repository.dart';
import '../features/pomodoro/presentation/screens/pomodoro_screen.dart';
import '../features/statistics/data/repositories/statistics_session_adapter.dart';
import '../features/statistics/domain/entities/statistics_task_category_option.dart';
import '../features/statistics/domain/use_cases/calculate_date_range_use_case.dart';
import '../features/statistics/domain/use_cases/calculate_summary_use_case.dart';
import '../features/statistics/domain/use_cases/get_sessions_by_date_range_use_case.dart';
import '../features/statistics/domain/use_cases/group_sessions_by_category_use_case.dart';
import '../features/statistics/domain/use_cases/group_sessions_by_day_use_case.dart';
import '../features/statistics/domain/use_cases/group_sessions_by_task_use_case.dart';
import '../features/statistics/presentation/controllers/statistics_controller.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/todo/domain/entities/task.dart';
import '../features/todo/presentation/controllers/todo_controller.dart';
import '../features/todo/presentation/screens/category_manager_screen.dart';
import '../features/todo/presentation/screens/task_form_screen.dart';
import '../features/todo/presentation/screens/todo_screen.dart';

/// Centralized route name constants for the application.
abstract final class Routes {
  /// Application root and main todo screen.
  static const String home = '/';

  /// The main todo list screen.
  static const String todo = '/todo';

  /// The task creation screen.
  static const String taskNew = '/todo/task/new';

  /// The task edit screen template. Use [taskEditPath] for concrete paths.
  static const String taskEdit = '/todo/task/:id/edit';

  /// The category management screen.
  static const String categories = '/todo/categories';

  /// The category creation screen (opens with input visible).
  static const String categoriesNew = '/todo/categories/new';

  /// The Pomodoro timer screen.
  static const String pomodoro = '/pomodoro';

  /// The Statistics screen.
  static const String statistics = '/statistics';

  /// Returns the concrete edit route path for the given [id].
  ///
  /// Example: `Routes.taskEditPath(42)` → `'/todo/task/42/edit'`.
  static String taskEditPath(int id) => '/todo/task/$id/edit';
}

/// Builds a [Route] for the given [RouteSettings].
///
/// Used as the `onGenerateRoute` callback in [MaterialApp].
///
/// The todo controller must be provided above the application navigator so
/// every todo route can access the same controller instance.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
    case Routes.todo:
      return MaterialPageRoute<void>(
        builder: (_) => const TodoScreen(),
        settings: settings,
      );

    case Routes.taskNew:
      return MaterialPageRoute<void>(
        builder: (_) => const TaskFormScreen(),
        settings: settings,
      );

    case Routes.categoriesNew:
      return MaterialPageRoute<void>(
        builder: (_) => const CategoryManagerScreen(startCreating: true),
        settings: settings,
      );

    case Routes.categories:
      return MaterialPageRoute<void>(
        builder: (_) => const CategoryManagerScreen(),
        settings: settings,
      );

    case Routes.pomodoro:
      return MaterialPageRoute<void>(
        builder: (_) => const PomodoroScreen(),
        settings: settings,
      );

    case Routes.statistics:
      return MaterialPageRoute<void>(
        builder: (context) {
          final pomodoroRepo = Provider.of<PomodoroSessionRepository>(
            context,
            listen: false,
          );
          final todoController = Provider.of<TodoController>(
            context,
            listen: false,
          );

          final adapter = StatisticsSessionAdapter(
            pomodoroSessionRepository: pomodoroRepo,
          );

          final clock = const SystemClock();
          final calculateDateRange = CalculateDateRangeUseCase(clock);
          final getSessionsByDateRange = GetSessionsByDateRangeUseCase(
            source: adapter,
          );
          final calculateSummary = const CalculateSummaryUseCase();
          final groupByDay = const GroupSessionsByDayUseCase();
          final groupByTask = const GroupSessionsByTaskUseCase();
          final groupByCategory = const GroupSessionsByCategoryUseCase();

          final categories = todoController.categories;
          final categoryMap = <int, String>{
            for (final cat in categories) cat.id: cat.name,
          };

          final taskCategoryMapping = todoController.allTasks
              .map(
                (task) => StatisticsTaskCategoryOption(
                  taskId: task.id,
                  categoryId: task.categoryId,
                  categoryName: task.categoryId != null
                      ? categoryMap[task.categoryId]
                      : null,
                ),
              )
              .toList();

          return ChangeNotifierProvider<StatisticsController>(
            create: (_) => StatisticsController(
              calculateDateRangeUseCase: calculateDateRange,
              getSessionsByDateRangeUseCase: getSessionsByDateRange,
              calculateSummaryUseCase: calculateSummary,
              groupSessionsByDayUseCase: groupByDay,
              groupSessionsByTaskUseCase: groupByTask,
              groupSessionsByCategoryUseCase: groupByCategory,
              taskCategoryMapping: taskCategoryMapping,
            )..init(),
            child: const StatisticsScreen(),
          );
        },
        settings: settings,
      );

    default:
      if (_isTaskEditRoute(settings.name)) {
        final routeId = _extractTaskId(settings.name!);
        final arguments = settings.arguments;

        if (routeId != null && arguments is Task && arguments.id == routeId) {
          return MaterialPageRoute<void>(
            builder: (_) => TaskFormScreen(initialTask: arguments),
            settings: settings,
          );
        }
      }
      return _notFoundRoute(settings);
  }
}

/// Returns `true` if [routeName] matches the task edit pattern.
bool _isTaskEditRoute(String? routeName) {
  if (routeName == null) {
    return false;
  }

  return RegExp(r'^/todo/task/\d+/edit$').hasMatch(routeName);
}

/// Extracts the numeric task ID from a route matching
/// `/todo/task/<id>/edit`, or returns `null` if the segment is not numeric.
int? _extractTaskId(String routeName) {
  final segments = routeName.split('/');
  // Expected: ['', 'todo', 'task', '<id>', 'edit']
  if (segments.length != 5) return null;
  return int.tryParse(segments[3]);
}

/// Returns a route to a simple "Page not found" screen.
Route<dynamic> _notFoundRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    builder: (_) => const _NotFoundScreen(),
    settings: settings,
  );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
