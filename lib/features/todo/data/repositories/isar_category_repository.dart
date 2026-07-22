import 'package:isar/isar.dart';

import '../../domain/entities/category.dart';
import '../../domain/exceptions/not_found_exception.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import '../models/task_model.dart';

/// Concrete [CategoryRepository] implementation backed by Isar.
class IsarCategoryRepository implements CategoryRepository {
  /// Creates an [IsarCategoryRepository] with the given [Isar] instance.
  const IsarCategoryRepository({required this.isar});

  /// The Isar database instance used for persistence.
  final Isar isar;

  @override
  Future<List<Category>> getAll() async {
    final models = await isar.categoryModels.where().findAll();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> count() async {
    return isar.categoryModels.count();
  }

  @override
  Future<Category> create(Category category) async {
    final model = CategoryModel.fromEntity(category)
      ..id = Isar.autoIncrement;

    final generatedId = await isar.writeTxn(
      () => isar.categoryModels.put(model),
    );

    model.id = generatedId;

    return model.toEntity();
  }

  @override
  Future<Category> update(Category category) async {
    final model = CategoryModel.fromEntity(category);

    await isar.writeTxn(() async {
      final existing = await isar.categoryModels.get(category.id);

      if (existing == null) {
        throw NotFoundException(
          message: 'Category not found',
          id: category.id,
        );
      }

      await isar.categoryModels.put(model);
    });

    return model.toEntity();
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(
      () => isar.categoryModels.delete(id),
    );
  }

  @override
  Future<void> deleteWithTaskUnassign(int categoryId) async {
    await isar.writeTxn(() async {
      final existing = await isar.categoryModels.get(categoryId);

      if (existing == null) {
        return;
      }

      final tasks = await isar.taskModels
          .filter()
          .categoryIdEqualTo(categoryId)
          .findAll();

      for (final task in tasks) {
        task.categoryId = null;
      }

      await isar.taskModels.putAll(tasks);
      await isar.categoryModels.delete(categoryId);
    });
  }
}
