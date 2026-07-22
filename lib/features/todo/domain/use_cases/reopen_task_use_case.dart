import '../entities/task.dart';
import '../entities/task_status.dart';
import '../exceptions/not_found_exception.dart';
import '../repositories/task_repository.dart';

/// Reopens a completed task, clearing its completion timestamp.
class ReopenTaskUseCase {
  const ReopenTaskUseCase({required this.taskRepository});

  final TaskRepository taskRepository;

  /// Sets [status] to [TaskStatus.pending] and [completedAt] to null.
  ///
  /// Throws [NotFoundException] if no task with [id] exists.
  Future<Task> call(int id) async {
    final existing = await taskRepository.findById(id);
    if (existing == null) {
      throw NotFoundException(message: 'Task not found.', id: id);
    }
    final reopened = Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      priority: existing.priority,
      status: TaskStatus.pending,
      categoryId: existing.categoryId,
      createdAt: existing.createdAt,
      completedAt: null,
    );
    return taskRepository.update(reopened);
  }
}
