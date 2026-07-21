import 'package:isar/isar.dart';

import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';

part 'task_model.g.dart';

/// Isar collection representing a persisted task.
///
/// Maps between the domain [Task] entity and the Isar database schema.
@collection
class TaskModel {
  /// Isar auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Task title. Non-empty, validated before persistence.
  @Index(type: IndexType.hash)
  late String title;

  /// Optional task description.
  late String? description;

  /// Stored index of [Priority] enum.
  @Index(type: IndexType.value)
  late int priorityIndex;

  /// Stored index of [TaskStatus] enum.
  @Index(type: IndexType.value)
  late int statusIndex;

  /// Foreign key to CategoryModel; nullable when uncategorized.
  @Index(type: IndexType.value)
  late int? categoryId;

  /// Timestamp when the task was created. Never mutated after creation.
  @Index(type: IndexType.value)
  late DateTime createdAt;

  /// Timestamp when the task was completed; null if still pending.
  late DateTime? completedAt;

  /// Converts this Isar model to a domain [Task] entity.
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: Priority.values[priorityIndex],
      status: TaskStatus.values[statusIndex],
      categoryId: categoryId,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  /// Creates a [TaskModel] from a domain [Task] entity.
  static TaskModel fromEntity(Task task) {
    return TaskModel()
      ..id = task.id
      ..title = task.title
      ..description = task.description
      ..priorityIndex = task.priority.index
      ..statusIndex = task.status.index
      ..categoryId = task.categoryId
      ..createdAt = task.createdAt
      ..completedAt = task.completedAt;
  }
}
