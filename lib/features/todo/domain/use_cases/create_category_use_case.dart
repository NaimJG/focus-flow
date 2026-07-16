import '../entities/category.dart';
import '../exceptions/validation_exception.dart';
import '../repositories/category_repository.dart';

/// Creates a new category after validating the name.
class CreateCategoryUseCase {
  const CreateCategoryUseCase({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  /// Validates [name], builds a [Category] with id=0 (Isar auto-assigns),
  /// delegates to [categoryRepository.create], and returns the persisted entity.
  ///
  /// Throws [ValidationException] if [name] is blank.
  Future<Category> call(String name) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Category name must not be empty.');
    }
    final category = Category(id: 0, name: name.trim());
    return categoryRepository.create(category);
  }
}
