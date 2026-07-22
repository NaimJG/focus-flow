import 'package:isar/isar.dart';

import '../../domain/entities/category.dart';

part 'category_model.g.dart';

/// Isar collection representing a task category in persistent storage.
@collection
class CategoryModel {
  /// Isar auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Category display name. Must be non-empty after trimming.
  @Index(unique: true, type: IndexType.hash)
  late String name;

  /// Converts this Isar model to a domain [Category] entity.
  Category toEntity() {
    return Category(id: id, name: name);
  }

  /// Creates a [CategoryModel] from a domain [Category] entity.
  static CategoryModel fromEntity(Category category) {
    return CategoryModel()
      ..id = category.id
      ..name = category.name;
  }
}
