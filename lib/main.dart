import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/isar_database.dart';
import 'features/todo/data/repositories/isar_category_repository.dart';
import 'features/todo/domain/use_cases/seed_default_categories_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await openIsar();

  await SeedDefaultCategoriesUseCase(
    categoryRepository: IsarCategoryRepository(isar: isar),
  ).call();

  runApp(FocusFlowApp(isar: isar));
}
