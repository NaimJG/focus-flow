import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/home/presentation/screens/home_screen.dart';
import '../features/pomodoro/presentation/screens/pomodoro_screen.dart';
import '../features/statistics/presentation/controllers/statistics_controller.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/statistics/presentation/statistics_controller_factory.dart';
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

    case Routes.home:
      return MaterialPageRoute<void>(
        builder: (_) => const HomeScreen(),
        settings: settings,
      );

    case Routes.statistics:
      return MaterialPageRoute<void>(
        builder: (_) => const _StatisticsRoute(),
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

/// A route wrapper that defers [StatisticsController] creation until
/// [TodoController] has finished its initial load. This ensures the
/// task-to-category mapping reflects the actual todo state rather than
/// a stale empty snapshot captured at route-build time.
class _StatisticsRoute extends StatefulWidget {
  const _StatisticsRoute();

  @override
  State<_StatisticsRoute> createState() => _StatisticsRouteState();
}

class _StatisticsRouteState extends State<_StatisticsRoute> {
  StatisticsController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

    _controller ??= createStatisticsController(context);

    return ChangeNotifierProvider<StatisticsController>.value(
      value: _controller!,
      child: const StatisticsScreen(),
    );
  }
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
