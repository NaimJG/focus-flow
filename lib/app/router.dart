import 'package:flutter/material.dart';

import '../features/todo/domain/entities/task.dart';
import '../features/todo/presentation/screens/category_manager_screen.dart';
import '../features/todo/presentation/screens/task_form_screen.dart';
import '../features/todo/presentation/screens/todo_screen.dart';

/// Centralized route name constants for the application.
abstract final class Routes {
  /// The main todo list screen.
  static const String todo = '/todo';

  /// The task creation screen.
  static const String taskNew = '/todo/task/new';

  /// The task edit screen template. Use [taskEditPath] for concrete paths.
  static const String taskEdit = '/todo/task/:id/edit';

  /// The category management screen.
  static const String categories = '/todo/categories';

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

    case Routes.categories:
      return MaterialPageRoute<void>(
        builder: (_) => const CategoryManagerScreen(),
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

        // Validation failed — route ID is not numeric or arguments
        // mismatch.
        return _notFoundRoute(settings);
      }

      return _notFoundRoute(settings);
  }
}

/// Returns `true` if [routeName] matches the task edit pattern.
bool _isTaskEditRoute(String? routeName) {
  if (routeName == null) {
    return false;
  }

  return RegExp(
    r'^/todo/task/\d+/edit$',
  ).hasMatch(routeName);
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
