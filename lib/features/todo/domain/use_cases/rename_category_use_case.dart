import '../entities/category.dart';
import '../exceptions/not_found_exception.dart';
import '../exceptions/validation_exception.dart';
import '../repositories/category_repository.dart';

/// Renames an existing category, preserving its ID.
class RenameCategoryUseCase {
  const RenameCategoryUseCase({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  /// Validates [name], fetches all categories to find the one with [id],
  /// applies the new name, and delegates to [categoryRepository.update].
  ///
  /// Throws [ValidationException] if [name] is blank.
  /// Throws [NotFoundException] if no category with [id] exists.
  Future<Category> call({required int id, required String name}) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Category name must not be empty.');
    }
    final all = await categoryRepository.getAll();
    final existing = all.where((c) => c.id == id).firstOrNull;
    if (existing == null) {
      throw NotFoundException(
        message: 'Category not found.',
        id: id,
      );
    }
    final renamed = Category(id: existing.id, name: name.trim());
    return categoryRepository.update(renamed);
  }
}
