import 'priority.dart';
import 'task_status.dart';

/// Immutable domain entity representing a user task.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.categoryId,
    required this.createdAt,
    this.completedAt,
  });

  final int id;
  final String title;
  final String? description;
  final Priority priority;
  final TaskStatus status;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime? completedAt;
}
