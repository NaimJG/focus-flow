import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Returns all tasks from storage, unordered.
class GetAllTasksUseCase {
  const GetAllTasksUseCase({required this.taskRepository});

  final TaskRepository taskRepository;

  /// Delegates directly to [taskRepository.getAll].
  Future<List<Task>> call() => taskRepository.getAll();
}
