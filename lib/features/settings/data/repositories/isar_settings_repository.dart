import 'package:isar/isar.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/app_settings_model.dart';

/// Concrete [SettingsRepository] implementation backed by Isar.
///
/// Reads and writes a single settings record identified by a fixed id of 1.
class IsarSettingsRepository implements SettingsRepository {
  /// Creates an [IsarSettingsRepository] with the given [Isar] instance.
  const IsarSettingsRepository({required this.isar});

  /// The Isar database instance used for persistence.
  final Isar isar;

  @override
  Future<AppSettings?> getSettings() async {
    final model = await isar.appSettingsModels.get(1);
    return model?.toEntity();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await isar.writeTxn(() async {
      await isar.appSettingsModels.put(AppSettingsModel.fromEntity(settings));
    });
  }
}
