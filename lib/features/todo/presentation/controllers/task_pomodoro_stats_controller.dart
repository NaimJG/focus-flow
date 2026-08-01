import 'package:flutter/foundation.dart';

import '../../../pomodoro/domain/entities/task_pomodoro_stats.dart';
import '../../../pomodoro/domain/use_cases/get_task_pomodoro_stats_use_case.dart';

/// Async state for the Pomodoro statistics fetch lifecycle.
enum TaskPomodoroStatsStatus { loading, loaded, error }

/// Manages the async lifecycle of fetching Pomodoro statistics for a
/// single task.
///
/// Created per task-edit instance. On construction, immediately begins
/// loading stats. The form remains fully functional regardless of this
/// controller's state.
class TaskPomodoroStatsController extends ChangeNotifier {
  /// Creates a [TaskPomodoroStatsController] and immediately triggers
  /// [load] to fetch statistics for the given [taskId].
  TaskPomodoroStatsController({
    required this._getTaskPomodoroStatsUseCase,
    required this._taskId,
  }) {
    load();
  }

  final GetTaskPomodoroStatsUseCase _getTaskPomodoroStatsUseCase;
  final int _taskId;

  TaskPomodoroStatsStatus _status = TaskPomodoroStatsStatus.loading;
  TaskPomodoroStats? _stats;

  /// The current loading status of the statistics fetch.
  TaskPomodoroStatsStatus get status => _status;

  /// The fetched statistics, or `null` if loading or in error state.
  TaskPomodoroStats? get stats => _stats;

  /// Fetches or refreshes the Pomodoro statistics for this task.
  ///
  /// Transitions to [TaskPomodoroStatsStatus.loading] before the fetch,
  /// then to [TaskPomodoroStatsStatus.loaded] on success or
  /// [TaskPomodoroStatsStatus.error] on failure.
  Future<void> load() async {
    _status = TaskPomodoroStatsStatus.loading;
    notifyListeners();

    try {
      _stats = await _getTaskPomodoroStatsUseCase.call(_taskId);
      _status = TaskPomodoroStatsStatus.loaded;
    } on Exception {
      _status = TaskPomodoroStatsStatus.error;
    }

    notifyListeners();
  }
}
