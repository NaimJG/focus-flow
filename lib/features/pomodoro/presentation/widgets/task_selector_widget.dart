import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/pomodoro_task_option.dart';

/// A dropdown selector for associating a task with the current Pomodoro
/// session.
///
/// Displays all available [PomodoroTaskOption] instances sorted with
/// incomplete tasks first. Includes an explicit "No task" option that maps
/// to a null task association.
class TaskSelectorWidget extends StatelessWidget {
  /// Creates a task selector widget.
  const TaskSelectorWidget({
    super.key,
    required this.tasks,
    required this.selectedTaskId,
    required this.enabled,
    required this.onChanged,
  });

  /// The list of available tasks to display.
  final List<PomodoroTaskOption> tasks;

  /// The currently selected task id, or null for "No task".
  final int? selectedTaskId;

  /// Whether the selector is interactive.
  final bool enabled;

  /// Called when the user selects a different task option.
  ///
  /// The record contains `(taskId, taskTitle)` — both null for "No task".
  final ValueChanged<(int?, String?)> onChanged;

  List<PomodoroTaskOption> _sortedTasks() {
    final sorted = List<PomodoroTaskOption>.of(tasks);
    sorted.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (tasks.isEmpty) {
      return DropdownButtonFormField<int?>(
        initialValue: null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.pomodoroTaskLabel,
          hintText: l10n.pomodoroNoTasksAvailable,
        ),
        items: const [],
        onChanged: null,
      );
    }

    final sorted = _sortedTasks();

    // Build the list of dropdown items: "No task" + sorted tasks.
    final items = <DropdownMenuItem<int?>>[
      DropdownMenuItem<int?>(value: null, child: Text(l10n.pomodoroNoTask)),
      ...sorted.map((task) {
        return DropdownMenuItem<int?>(
          value: task.id,
          child: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      }),
    ];

    // selectedItemBuilder ensures the selected value in the closed
    // dropdown also respects available width with ellipsis.
    final selectedItemBuilders = <Widget>[
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          l10n.pomodoroNoTask,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      ...sorted.map((task) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      }),
    ];

    return DropdownButtonFormField<int?>(
      initialValue: selectedTaskId,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.pomodoroTaskLabel),
      items: items,
      selectedItemBuilder: (context) => selectedItemBuilders,
      onChanged: enabled
          ? (value) {
              if (value == null) {
                onChanged((null, null));
              } else {
                final task = sorted.firstWhere((t) => t.id == value);
                onChanged((task.id, task.title));
              }
            }
          : null,
    );
  }
}
