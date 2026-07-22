import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import 'empty_state_widget.dart';
import 'task_card.dart';

/// Displays a scrollable list of [TaskCard] widgets, or an [EmptyStateWidget]
/// when the task list is empty.
class TaskListWidget extends StatelessWidget {
  /// Creates a task list widget.
  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.categories,
    required this.onComplete,
    required this.onReopen,
    required this.onEdit,
    required this.onDelete,
    required this.emptyVariant,
    this.onEmptyAction,
  });

  /// The tasks to display.
  final List<Task> tasks;

  /// All available categories, used to resolve category names.
  final List<Category> categories;

  /// Called when the user marks a task as completed.
  final ValueChanged<int> onComplete;

  /// Called when the user reopens a completed task.
  final ValueChanged<int> onReopen;

  /// Called when the user taps a task to edit it.
  final ValueChanged<Task> onEdit;

  /// Called when the user deletes a task.
  final ValueChanged<int> onDelete;

  /// The empty state variant to show when [tasks] is empty.
  final EmptyStateVariant emptyVariant;

  /// Optional callback for the empty state CTA button.
  final VoidCallback? onEmptyAction;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyStateWidget(
        variant: emptyVariant,
        onAction: onEmptyAction,
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final categoryName = _resolveCategoryName(task.categoryId);

        return TaskCard(
          task: task,
          categoryName: categoryName,
          onToggleStatus: () {
            if (task.status == TaskStatus.completed) {
              onReopen(task.id);
            } else {
              onComplete(task.id);
            }
          },
          onEdit: () => onEdit(task),
          onDelete: () => onDelete(task.id),
        );
      },
    );
  }

  String? _resolveCategoryName(int? categoryId) {
    if (categoryId == null) {
      return null;
    }
    for (final category in categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return null;
  }
}
