import '../repositories/category_repository.dart';

/// Deletes a category and atomically nullifies [categoryId] on all tasks
/// that referenced it.
///
/// Atomicity is guaranteed by [CategoryRepository.deleteWithTaskUnassign],
/// which executes both writes inside a single Isar write transaction in its
/// concrete implementation. The use case has no knowledge of Isar or
/// transaction internals.
class DeleteCategoryUseCase {
  const DeleteCategoryUseCase({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  /// Unassigns all tasks referencing [id] and deletes the category atomically.
  /// No-op if the category does not exist.
  Future<void> call(int id) => categoryRepository.deleteWithTaskUnassign(id);
}
