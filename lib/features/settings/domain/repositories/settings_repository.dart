import '../entities/app_settings.dart';

/// Abstract interface for persisting and retrieving user settings.
///
/// Returns `null` from [getSettings] when no record exists (first launch),
/// allowing the caller to fall back to default values.
abstract interface class SettingsRepository {
  /// Retrieves the stored settings, or `null` if none have been saved yet.
  Future<AppSettings?> getSettings();

  /// Persists the given [settings], overwriting any previously stored values.
  Future<void> saveSettings(AppSettings settings);
}
