import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Seeds the four default categories on first launch.
///
/// The guard `count() == 0` ensures seeding only runs when the category
/// store is completely empty — i.e., on a fresh install or after the user
/// has deleted every category.
class SeedDefaultCategoriesUseCase {
  const SeedDefaultCategoriesUseCase({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  /// Creates the four default categories if none exist yet.
  /// No-op when at least one category is already present.
  Future<void> call() async {
    final count = await categoryRepository.count();
    if (count == 0) {
      for (final name in ['Trabajo', 'Estudio', 'Hogar', 'Personal']) {
        await categoryRepository.create(Category(id: 0, name: name));
      }
    }
  }
}
