import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// Retrieves the user's persisted settings.
///
/// Returns `null` when no settings have been saved yet (first launch),
/// allowing the caller to fall back to [AppSettings] defaults.
class GetSettingsUseCase {
  const GetSettingsUseCase({required this.repository});

  final SettingsRepository repository;

  /// Delegates to [SettingsRepository.getSettings].
  Future<AppSettings?> call() => repository.getSettings();
}
