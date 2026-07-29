import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Persists user settings by delegating to [SettingsRepository].
///
/// This use case is the single entry point for saving preferences,
/// ensuring that the presentation layer never accesses the repository
/// directly.
class SaveSettingsUseCase {
  const SaveSettingsUseCase({required this.repository});

  final SettingsRepository repository;

  /// Saves the given [settings], overwriting any previously stored values.
  Future<void> call(AppSettings settings) =>
      repository.saveSettings(settings);
}
