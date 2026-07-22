import 'package:flutter/material.dart';

import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';

/// A Material 3 card representing a single task in the task list.
///
/// Displays the task title, optional description, priority chip,
/// category label, a completion checkbox, and a delete button.
class TaskCard extends StatelessWidget {
  /// Creates a task card.
  const TaskCard({
    super.key,
    required this.task,
    required this.categoryName,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  /// The task to display.
  final Task task;

  /// The resolved category name, or `null` if the task has no category.
  final String? categoryName;

  /// Called when the user toggles the completion checkbox.
  final VoidCallback onToggleStatus;

  /// Called when the user taps the card body to edit the task.
  final VoidCallback onEdit;

  /// Called when the user taps the delete button.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Checkbox(value: isCompleted, onChanged: (_) => onToggleStatus()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: textTheme.titleMedium?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          task.description!,
                          style: textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _PriorityChip(
                          priority: task.priority,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        if (categoryName != null) ...[
                          const SizedBox(width: 8),
                          Text(categoryName!, style: textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Delete task',
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
    required this.colorScheme,
    required this.textTheme,
  });

  final Priority priority;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _priorityData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }

  (IconData, String, Color) _priorityData() {
    switch (priority) {
      case Priority.high:
        return (Icons.arrow_upward, 'High', colorScheme.error);
      case Priority.medium:
        return (Icons.remove, 'Medium', colorScheme.primary);
      case Priority.low:
        return (Icons.arrow_downward, 'Low', colorScheme.tertiary);
    }
  }
}
