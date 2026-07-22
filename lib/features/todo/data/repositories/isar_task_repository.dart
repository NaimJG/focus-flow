import 'package:isar/isar.dart';

import '../../domain/entities/task.dart';
import '../../domain/exceptions/not_found_exception.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Concrete [TaskRepository] implementation backed by Isar.
class IsarTaskRepository implements TaskRepository {
  /// Creates an [IsarTaskRepository] with the given [Isar] instance.
  const IsarTaskRepository({required this.isar});

  /// The Isar database instance used for persistence.
  final Isar isar;

  @override
  Future<List<Task>> getAll() async {
    final models = await isar.taskModels.where().findAll();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Task?> findById(int id) async {
    final model = await isar.taskModels.get(id);

    return model?.toEntity();
  }

  @override
  Future<Task> create(Task task) async {
    final model = TaskModel.fromEntity(task)
      ..id = Isar.autoIncrement;

    final generatedId = await isar.writeTxn(
      () => isar.taskModels.put(model),
    );

    model.id = generatedId;

    return model.toEntity();
  }

  @override
  Future<Task> update(Task task) async {
    final model = TaskModel.fromEntity(task);

    await isar.writeTxn(() async {
      final existing = await isar.taskModels.get(task.id);

      if (existing == null) {
        throw NotFoundException(
          message: 'Task not found',
          id: task.id,
        );
      }

      await isar.taskModels.put(model);
    });

    return model.toEntity();
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(
      () => isar.taskModels.delete(id),
    );
  }
}