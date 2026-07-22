import '../entities/priority.dart';
import '../entities/task.dart';
import '../exceptions/not_found_exception.dart';
import '../exceptions/validation_exception.dart';
import '../repositories/task_repository.dart';

/// Edits an existing task, preserving immutable fields.
class EditTaskUseCase {
  const EditTaskUseCase({required this.taskRepository});

  final TaskRepository taskRepository;

  /// Validates [title], fetches the existing task, applies the new values,
  /// and delegates to [taskRepository.update].
  ///
  /// Throws [ValidationException] if [title] is blank.
  /// Throws [NotFoundException] if no task with [id] exists.
  Future<Task> call({
    required int id,
    required String title,
    required Priority priority,
    String? description,
    int? categoryId,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw const ValidationException('Title must not be empty.');
    }
    final existing = await taskRepository.findById(id);
    final normalizedDescription = description?.trim();
    final descriptionValue =
        normalizedDescription == null || normalizedDescription.isEmpty
        ? null
        : normalizedDescription;
    if (existing == null) {
      throw NotFoundException(message: 'Task not found.', id: id);
    }
    final updated = Task(
      id: existing.id,
      title: normalizedTitle,
      description: descriptionValue,
      priority: priority,
      status: existing.status, // preserved
      categoryId: categoryId,
      createdAt: existing.createdAt, // preserved
      completedAt: existing.completedAt, // preserved
    );
    return taskRepository.update(updated);
  }
}
