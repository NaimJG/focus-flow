import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Returns all categories from storage, unordered.
class GetAllCategoriesUseCase {
  const GetAllCategoriesUseCase({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  /// Delegates directly to [categoryRepository.getAll].
  Future<List<Category>> call() => categoryRepository.getAll();
}
