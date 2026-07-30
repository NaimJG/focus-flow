import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/isar_database.dart';
import 'features/settings/data/repositories/isar_settings_repository.dart';
import 'features/settings/domain/use_cases/get_settings_use_case.dart';
import 'features/settings/domain/use_cases/save_settings_use_case.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'features/todo/data/repositories/isar_category_repository.dart';
import 'features/todo/domain/use_cases/seed_default_categories_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await openIsar();

  final settingsRepository = IsarSettingsRepository(isar: isar);
  final getSettingsUseCase = GetSettingsUseCase(repository: settingsRepository);
  final saveSettingsUseCase = SaveSettingsUseCase(
    repository: settingsRepository,
  );
  final settingsController = SettingsController(
    getSettingsUseCase: getSettingsUseCase,
    saveSettingsUseCase: saveSettingsUseCase,
  );
  await settingsController.init();

  await SeedDefaultCategoriesUseCase(
    categoryRepository: IsarCategoryRepository(isar: isar),
  ).call();

  runApp(FocusFlowApp(isar: isar, settingsController: settingsController));
}
