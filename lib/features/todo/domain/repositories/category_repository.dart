import '../entities/category.dart';
import '../exceptions/not_found_exception.dart';

/// Abstract interface for category persistence operations.
abstract interface class CategoryRepository {
  /// Returns all categories, unordered.
  Future<List<Category>> getAll();

  /// Returns the count of categories in storage.
  Future<int> count();

  /// Persists a new category and returns the saved entity with its assigned ID.
  Future<Category> create(Category category);

  /// Persists a name change for an existing category. Throws [NotFoundException]
  /// if not found.
  Future<Category> update(Category category);

  /// Permanently removes the category with the given ID. No-op if not found.
  Future<void> delete(int id);
}
