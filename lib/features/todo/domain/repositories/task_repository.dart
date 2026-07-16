import '../entities/task.dart';
import '../exceptions/not_found_exception.dart';

/// Abstract interface for task persistence operations.
abstract interface class TaskRepository {
  /// Returns all tasks, unordered.
  Future<List<Task>> getAll();

  /// Returns a single task by its Isar ID, or null if not found.
  Future<Task?> findById(int id);

  /// Persists a new task and returns the saved entity with its assigned ID.
  Future<Task> create(Task task);

  /// Persists updates to an existing task. Throws [NotFoundException] if the
  /// task does not exist.
  Future<Task> update(Task task);

  /// Permanently removes the task with the given ID. No-op if not found.
  Future<void> delete(int id);
}
