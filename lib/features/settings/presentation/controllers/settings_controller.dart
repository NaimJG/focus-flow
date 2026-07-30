import 'package:flutter/foundation.dart';

import '../../domain/entities/app_color_palette.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/use_cases/get_settings_use_case.dart';
import '../../domain/use_cases/save_settings_use_case.dart';

/// Represents the loading state of the settings feature.
enum SettingsStatus { loading, loaded, error }

/// Application-scoped controller managing user preferences.
///
/// Exposes [AppSettings] and [SettingsStatus] only — it does NOT
/// construct ThemeData or ColorScheme. The Flutter-specific theme
/// construction is handled by the `core/theme` layer.
class SettingsController extends ChangeNotifier {
  SettingsController({
    required this._getSettingsUseCase,
    required this._saveSettingsUseCase,
  });

  final GetSettingsUseCase _getSettingsUseCase;
  final SaveSettingsUseCase _saveSettingsUseCase;

  SettingsStatus _status = SettingsStatus.loading;
  AppSettings _settings = const AppSettings();
  AppSettings _lastPersistedSettings = const AppSettings();
  String? _errorMessage;
  String? _saveErrorMessage;
  bool _isSaving = false;

  /// Current loading status of the settings feature.
  SettingsStatus get status => _status;

  /// Current in-memory settings (defaults until [init] completes).
  AppSettings get settings => _settings;

  /// Human-readable error message when [status] is [SettingsStatus.error].
  String? get errorMessage => _errorMessage;

  /// Human-readable error message from the most recent failed save.
  String? get saveErrorMessage => _saveErrorMessage;

  /// Whether a save operation is currently in progress.
  bool get isSaving => _isSaving;

  /// Clears the current [saveErrorMessage] and notifies listeners.
  void clearSaveError() {
    if (_saveErrorMessage == null) return;
    _saveErrorMessage = null;
    notifyListeners();
  }

  /// Loads persisted settings. If none exist, uses defaults without
  /// entering an error state. Must be awaited before `runApp`.
  Future<void> init() async {
    _status = SettingsStatus.loading;
    notifyListeners();

    try {
      final loaded = await _getSettingsUseCase.call();
      _settings = loaded ?? const AppSettings();
      _lastPersistedSettings = _settings;
      _errorMessage = null;
      _status = SettingsStatus.loaded;
    } on Exception {
      _errorMessage = 'Could not load settings. Please try again.';
      _status = SettingsStatus.error;
    }

    notifyListeners();
  }

  /// Re-attempts a failed load.
  Future<void> retry() => init();

  // -- Mutation methods ------------------------------------------------

  /// Updates the focus duration if [minutes] is within 1–120.
  ///
  /// Returns `true` on successful persist, `false` on invalid input
  /// or persistence failure.
  Future<bool> updateFocusDuration(int minutes) async {
    if (minutes < 1 || minutes > 120) return false;
    return _applyChange(
      _settings.copyWith(focusDuration: Duration(minutes: minutes)),
      settingName: 'focus duration',
    );
  }

  /// Updates the short break duration if [minutes] is within 1–60.
  ///
  /// Returns `true` on successful persist, `false` on invalid input
  /// or persistence failure.
  Future<bool> updateShortBreakDuration(int minutes) async {
    if (minutes < 1 || minutes > 60) return false;
    return _applyChange(
      _settings.copyWith(shortBreakDuration: Duration(minutes: minutes)),
      settingName: 'short break duration',
    );
  }

  /// Updates the long break duration if [minutes] is within 1–120.
  ///
  /// Returns `true` on successful persist, `false` on invalid input
  /// or persistence failure.
  Future<bool> updateLongBreakDuration(int minutes) async {
    if (minutes < 1 || minutes > 120) return false;
    return _applyChange(
      _settings.copyWith(longBreakDuration: Duration(minutes: minutes)),
      settingName: 'long break duration',
    );
  }

  /// Updates cycles before long break if [cycles] is within 1–12.
  ///
  /// Returns `true` on successful persist, `false` on invalid input
  /// or persistence failure.
  Future<bool> updateCyclesBeforeLongBreak(int cycles) async {
    if (cycles < 1 || cycles > 12) return false;
    return _applyChange(
      _settings.copyWith(cyclesBeforeLongBreak: cycles),
      settingName: 'cycles before long break',
    );
  }

  /// Updates the sound enabled preference.
  ///
  /// Returns `true` on successful persist, `false` on persistence
  /// failure.
  Future<bool> updateSoundEnabled({required bool enabled}) async {
    return _applyChange(
      _settings.copyWith(soundEnabled: enabled),
      settingName: 'sound',
    );
  }

  /// Updates the theme mode preference.
  ///
  /// Returns `true` on successful persist, `false` on persistence
  /// failure.
  Future<bool> updateThemeMode(AppThemeMode mode) async {
    return _applyChange(
      _settings.copyWith(themeMode: mode),
      settingName: 'theme mode',
    );
  }

  /// Updates the color palette preference.
  ///
  /// Returns `true` on successful persist, `false` on persistence
  /// failure.
  Future<bool> updateColorPalette(AppColorPalette palette) async {
    return _applyChange(
      _settings.copyWith(colorPalette: palette),
      settingName: 'color palette',
    );
  }

  // -- Private helpers -------------------------------------------------

  /// Applies an optimistic update: sets the new state, notifies,
  /// persists asynchronously, and reverts on failure.
  ///
  /// Returns `true` when the save succeeds, `false` if skipped
  /// (no-op or already saving) or if persistence fails.
  Future<bool> _applyChange(
    AppSettings newSettings, {
    required String settingName,
  }) async {
    // No-op: nothing changed.
    if (newSettings == _settings) return true;

    // Guard against overlapping saves.
    if (_isSaving) return false;

    _isSaving = true;
    _settings = newSettings;
    notifyListeners();

    try {
      await _saveSettingsUseCase.call(newSettings);
      _lastPersistedSettings = newSettings;
      _saveErrorMessage = null;
      _isSaving = false;
      notifyListeners();
      return true;
    } on Exception {
      // Roll back to last known good state.
      _settings = _lastPersistedSettings;
      _saveErrorMessage = 'Could not save $settingName. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
