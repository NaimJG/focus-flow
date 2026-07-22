import '../entities/priority.dart';
import '../entities/task.dart';
import '../entities/task_status.dart';
import '../exceptions/validation_exception.dart';
import '../repositories/task_repository.dart';

/// Creates a new task after validating the title.
class CreateTaskUseCase {
  const CreateTaskUseCase({required this.taskRepository});

  final TaskRepository taskRepository;

  /// Validates [title], builds a pending [Task] with [createdAt] = now,
  /// delegates to [taskRepository.create], and returns the persisted entity.
  ///
  /// Throws [ValidationException] if [title] is blank.
  Future<Task> call({
    required String title,
    required Priority priority,
    String? description,
    int? categoryId,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw const ValidationException('Title must not be empty.');
    }
    final normalizedDescription = description?.trim();
    final descriptionValue =
        normalizedDescription == null || normalizedDescription.isEmpty
        ? null
        : normalizedDescription;
    final task = Task(
      id: 0, // Isar auto-assigns on create
      title: normalizedTitle,
      description: descriptionValue,
      priority: priority,
      status: TaskStatus.pending,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      completedAt: null,
    );
    return taskRepository.create(task);
  }
}
