import '../entities/task.dart';
import '../entities/task_status.dart';
import '../exceptions/not_found_exception.dart';
import '../repositories/task_repository.dart';

/// Marks a task as completed and records the completion timestamp.
class CompleteTaskUseCase {
  const CompleteTaskUseCase({required this.taskRepository});

  final TaskRepository taskRepository;

  /// Sets [status] to [TaskStatus.completed] and [completedAt] to now.
  ///
  /// Throws [NotFoundException] if no task with [id] exists.
  Future<Task> call(int id) async {
    final existing = await taskRepository.findById(id);
    if (existing == null) {
      throw NotFoundException(message: 'Task not found.', id: id);
    }
    final completed = Task(
      id: existing.id,
      title: existing.title,
      description: existing.description,
      priority: existing.priority,
      status: TaskStatus.completed,
      categoryId: existing.categoryId,
      createdAt: existing.createdAt,
      completedAt: DateTime.now(),
    );
    return taskRepository.update(completed);
  }
}
