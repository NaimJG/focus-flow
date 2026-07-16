import '../repositories/task_repository.dart';

/// Permanently deletes a task by ID. Idempotent — no-op if not found.
class DeleteTaskUseCase {
  const DeleteTaskUseCase({required this.taskRepository});

  final TaskRepository taskRepository;

  /// Deletes the task with [id]. No-op if the task does not exist.
  Future<void> call(int id) => taskRepository.delete(id);
}
