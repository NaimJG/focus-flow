# Implementation Plan: Settings

## Overview

Implement the Settings feature following clean architecture: domain entities and enums first, then repository and use cases, data layer with Isar, controller with validation and optimistic persist, centralized theme layer, Pomodoro integration, startup wiring, UI screens, navigation, and finally tests. Each step builds incrementally on the previous, ensuring no orphaned code.

## Tasks

- [x] 1. Domain entities and enums
  - [x] 1.1 Create `AppThemeMode` as a pure Dart enum
    - Create `lib/features/settings/domain/entities/app_theme_mode.dart`
    - Enum values: `system`, `light`, `dark`
    - No Flutter imports — the mapping to Flutter ThemeMode lives in core/theme
    - _Requirements: 5.2, 5.3, 5.4, 5.7_

  - [x] 1.2 Create `AppColorPalette` as a pure Dart enum
    - Create `lib/features/settings/domain/entities/app_color_palette.dart`
    - Enum values: `salmon`, `lightBlue`, `lightGreen`
    - No Flutter imports — seed colors and labels live in core/theme and presentation layer respectively
    - _Requirements: 6.1, 6.3, 6.4_

  - [x] 1.3 Create `AppSettings` entity with `copyWith` and equality
    - Create `lib/features/settings/domain/entities/app_settings.dart`
    - Immutable value object with all preference fields, defaults, copyWith, and equality
    - No Flutter imports, no toPomodoroConfig — cross-domain mapping lives in app/mappers
    - _Requirements: 1.1, 1.5, 2.6, 3.4, 7.1, 7.2, 7.3_

- [x] 2. Repository interface and use cases
  - [x] 2.1 Create `SettingsRepository` abstract interface
    - Create `lib/features/settings/domain/repositories/settings_repository.dart`
    - Methods: `Future<AppSettings?> getSettings()` and `Future<void> saveSettings(AppSettings)`
    - Returns `null` when no record exists (first launch)
    - _Requirements: 1.2, 1.3, 1.5, 1.6_

  - [x] 2.2 Create `GetSettingsUseCase`
    - Create `lib/features/settings/domain/use_cases/get_settings_use_case.dart`
    - Delegates to `SettingsRepository.getSettings()`
    - _Requirements: 1.3, 1.4, 1.5_

  - [x] 2.3 Create `SaveSettingsUseCase`
    - Create `lib/features/settings/domain/use_cases/save_settings_use_case.dart`
    - Delegates to `SettingsRepository.saveSettings(AppSettings)`
    - _Requirements: 1.2, 2.2, 2.3, 2.4, 3.2, 4.2, 5.6, 6.3_

- [x] 3. Isar data model and concrete repository
  - [x] 3.1 Create `AppSettingsModel` Isar collection
    - Create `lib/features/settings/data/models/app_settings_model.dart`
    - `@collection` with fixed `Id id = 1`
    - Fields: `focusDurationMinutes`, `shortBreakDurationMinutes`, `longBreakDurationMinutes`, `cyclesBeforeLongBreak`, `soundEnabled`, `themeMode` (@enumerated), `colorPalette` (@enumerated)
    - `toEntity()` and `static fromEntity(AppSettings)` converters
    - _Requirements: 1.2, 1.3, 1.6_

  - [x] 3.2 Create `IsarSettingsRepository` concrete implementation
    - Create `lib/features/settings/data/repositories/isar_settings_repository.dart`
    - Implements `SettingsRepository`
    - `getSettings()` reads record with id=1, returns null if absent
    - `saveSettings()` writes via `isar.writeTxn`
    - _Requirements: 1.2, 1.3, 1.5, 1.6_

- [x] 4. Database registration
  - [x] 4.1 Register `AppSettingsModelSchema` in `isar_database.dart`
    - Modify `lib/core/database/isar_database.dart`
    - Add import for `AppSettingsModel`
    - Add `AppSettingsModelSchema` to the schema list in `openIsar()`
    - _Requirements: 1.2, 1.6_

- [x] 5. Checkpoint — Persistence layer complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. SettingsController
  - [x] 6.1 Create `SettingsController` with status, validation, load, save, and error handling
    - Create `lib/features/settings/presentation/controllers/settings_controller.dart`
    - `SettingsStatus` enum: `loading`, `loaded`, `error`
    - Constructor receives `GetSettingsUseCase` and `SaveSettingsUseCase`
    - `init()`: loads settings, null → defaults (no error), exception → error state with message
    - `retry()`: re-attempts load
    - Exposes: `SettingsStatus get status`, `AppSettings get settings`, `String? get errorMessage`, validated update methods, init/retry
    - SettingsController does not construct ThemeData or ColorScheme. It exposes AppSettings and status only.
    - Mutation methods: `updateFocusDuration`, `updateShortBreakDuration`, `updateLongBreakDuration`, `updateCyclesBeforeLongBreak`, `updateSoundEnabled`, `updateThemeMode`, `updateColorPalette`
    - Validation: reject out-of-range values (focus 1–120, short 1–60, long 1–120, cycles 1–6)
    - Optimistic persist with revert on failure
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.2, 2.3, 2.4, 2.5, 3.2, 3.3, 4.2, 4.3, 4.5, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 6.2, 6.3, 6.7, 9.5, 9.6, 11.4, 11.5, 12.1, 12.4_

- [x] 7. Checkpoint — Controller integration complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Theme integration
  - [x] 8.1 Create centralized theme layer in `lib/core/theme/`
    - Create `lib/core/theme/app_theme_mode_mapper.dart` — extension on AppThemeMode mapping to Flutter ThemeMode (`toFlutterThemeMode()`)
    - Create `lib/core/theme/app_palette_seeds.dart` — `abstract final class AppPaletteSeeds` with static Color constants for salmon (0xFFE57373), lightBlue (0xFF4FC3F7), lightGreen (0xFF81C784) + `static Color seedForPalette(AppColorPalette palette)` function
    - Create `lib/core/theme/app_theme.dart` — `abstract final class AppTheme` with `static ThemeData light(AppColorPalette palette)` and `static ThemeData dark(AppColorPalette palette)` methods returning ThemeData via ColorScheme.fromSeed
    - These are the centralized Flutter-specific theme mappings consumed by MaterialApp
    - Remove or replace existing empty `lib/app/theme/app_theme.dart` and `lib/app/theme/app_colors.dart` (superseded by core/theme)
    - _Requirements: 5.5, 6.2, 9.3_

- [x] 9. Pomodoro integration
  - [x] 9.1 Add equality support to `PomodoroConfig`
    - Modify `lib/features/pomodoro/domain/entities/pomodoro_config.dart`
    - Override `==` and `hashCode` so `updateConfig` can short-circuit on identical config
    - _Requirements: 7.8_

  - [x] 9.2 Make `_config` non-final and add `updateConfig(PomodoroConfig)` to `PomodoroController`
    - Modify `lib/features/pomodoro/presentation/controllers/pomodoro_controller.dart`
    - Remove `final` from `_config`
    - Add `updateConfig(PomodoroConfig newConfig)` method: no-op if equal, update `_config`, update `_remainingDuration` only when idle/completed
    - _Requirements: 7.1, 7.2, 7.3, 7.5, 7.6, 7.7, 7.8, 7.9_

- [x] 10. Startup sequence and app wiring
  - [x] 10.1 Modify `main.dart` to initialize `SettingsController` before `runApp`
    - Create `IsarSettingsRepository`, `GetSettingsUseCase`, `SaveSettingsUseCase`, `SettingsController`
    - `await settingsController.init()`
    - Pass `settingsController` to `FocusFlowApp`
    - _Requirements: 12.1, 12.4_

  - [x] 10.2 Modify `app.dart` to accept `settingsController`, provide it, apply theme, and upgrade to `ProxyProvider2`
    - Add `settingsController` parameter to `FocusFlowApp`
    - Provide via `ChangeNotifierProvider.value`
    - Create `lib/app/mappers/pomodoro_settings_mapper.dart` with `mapSettingsToPomodoroConfig` function
    - `MaterialApp`: use `settings.themeMode.toFlutterThemeMode()` (from core/theme extension), `AppTheme.light(settings.colorPalette)`, `AppTheme.dark(settings.colorPalette)` (from core/theme)
    - Upgrade `ChangeNotifierProxyProvider` to `ChangeNotifierProxyProvider2<TodoController, SettingsController, PomodoroController>`
    - In update callback: call `updateAvailableTasks` and `updateConfig(mapSettingsToPomodoroConfig(settingsController.settings))`
    - _Requirements: 5.5, 5.6, 6.2, 6.7, 7.1, 7.7, 12.1, 12.2, 12.3, 12.4, 12.5_

- [x] 11. Checkpoint — Theme and Pomodoro integration complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 12. Settings UI
  - [x] 12.1 Create `SettingsScreen` with loading, error, and loaded states
    - Create `lib/features/settings/presentation/screens/settings_screen.dart`
    - Scaffold with AppBar title "Settings"
    - Loading: `CircularProgressIndicator` centered
    - Error: plain-language message + Retry button
    - Loaded: `ListView` with section widgets
    - All colors/styles from `Theme.of(context)`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.7, 11.1, 11.2, 11.3_

  - [x] 12.2 Create `PomodoroSettingsSection` widget
    - Create `lib/features/settings/presentation/widgets/pomodoro_settings_section.dart`
    - Section header "Pomodoro"
    - Numeric input controls for focus, short break, long break durations (with "min" label)
    - Numeric input for cycles before long break
    - Shows current values, calls controller update methods on change
    - Inline validation error messages for out-of-range values
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 3.5_

  - [x] 12.3 Create `AppearanceSettingsSection` widget
    - Create `lib/features/settings/presentation/widgets/appearance_settings_section.dart`
    - Section header "Appearance"
    - `SegmentedButton<AppThemeMode>` for theme mode (System, Light, Dark)
    - Palette selector row: labeled color swatches (text + swatch), check-mark indicator on selected, 48×48dp touch targets
    - Presentation widgets map enum values to user-facing labels in the widget layer (e.g., AppThemeMode.system → "System", AppColorPalette.salmon → "Salmon")
    - Semantics annotations for accessibility
    - _Requirements: 5.1, 5.5, 5.9, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 10.1, 10.4_

  - [x] 12.4 Create `SoundSettingsSection` widget
    - Create `lib/features/settings/presentation/widgets/sound_settings_section.dart`
    - Section header "Sound"
    - `SwitchListTile` with label "Sound", secondary text "Enabled"/"Disabled"
    - Calls controller on toggle, shows SnackBar and reverts on save failure
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 13. Navigation integration
  - [x] 13.1 Add 4th NavigationDestination and IndexedStack child to `HomeScreen`
    - Modify `lib/features/home/presentation/screens/home_screen.dart`
    - Add Settings destination (Icons.settings_outlined / Icons.settings, label "Settings")
    - Add `SettingsScreen()` as 4th child in IndexedStack
    - Update lazy-load logic for Statistics index (remains index 2)
    - _Requirements: 8.1, 8.2, 8.3, 8.5, 8.6_

  - [x] 13.2 Add `Routes.settings` and route case in `router.dart`
    - Modify `lib/app/router.dart`
    - Add `static const String settings = '/settings'` to `Routes`
    - Add `case Routes.settings:` returning `MaterialPageRoute` to `SettingsScreen`
    - _Requirements: 8.4_

- [x] 14. Checkpoint — UI integration complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Unit tests for controller and repository
  - [ ]* 15.1 Write unit tests for `SettingsController`
    - Test default values on first load (empty repository returns null)
    - Test load from existing record
    - Test load failure → error state with retry
    - Test each update method with valid values → persists and notifies
    - Test each update method with invalid values → rejects, retains previous
    - Test save failure → reverts to last persisted state
    - Test theme mode update triggers notifyListeners (3 enum values)
    - _Requirements: 1.1, 1.3, 1.4, 2.2, 2.3, 2.4, 2.5, 3.2, 3.3, 5.6, 5.8, 6.7, 9.6, 11.5_

  - [ ]* 15.2 Write unit tests for `PomodoroController.updateConfig`
    - Test config applies when idle → remainingDuration updates
    - Test config applies when completed → remainingDuration updates
    - Test config ignored when running → remainingDuration unchanged
    - Test config ignored when paused → remainingDuration unchanged
    - Test atomic replacement of all config fields
    - Test cycleCount, status, selectedTask preserved across updateConfig
    - _Requirements: 7.1, 7.2, 7.3, 7.5, 7.7, 7.8, 7.9_

  - [ ]* 15.3 Write unit tests for `AppSettings` entity and mapper
    - Test copyWith produces correct values
    - Test default construction matches expected defaults
    - Test mapSettingsToPomodoroConfig maps durations correctly (test lives alongside the mapper in app/mappers test)
    - _Requirements: 1.1_

  - [ ]* 15.4 Write unit tests for `AppSettingsModel` round-trip
    - Test toEntity/fromEntity round-trip for various valid settings
    - Test default field values match domain defaults
    - _Requirements: 1.2, 1.3_

  - [ ]* 15.5 Write property test for round-trip persistence (P1)
    - **Property 1: Settings round-trip persistence**
    - Generate random valid AppSettings (durations in range, random enum values, random bool)
    - Save via mock repository, load, assert equality
    - **Validates: Requirements 1.2, 1.3, 3.5, 4.2, 4.4, 5.6, 5.9, 6.3**

  - [ ]* 15.6 Write property test for duration/cycle validation (P2)
    - **Property 2: Duration and cycle validation accepts only in-range values**
    - Generate random (field, value) pairs — both in-range and out-of-range integers
    - Assert acceptance if and only if in valid range; out-of-range leaves state unchanged
    - **Validates: Requirements 2.2, 2.3, 2.4, 2.5, 3.2, 3.3**

  - [ ]* 15.7 Write property test for config applies when idle/completed (P3)
    - **Property 3: Config applies immediately when timer is idle or completed**
    - Generate random valid PomodoroConfig + random TimerMode, start from idle/completed
    - Assert remainingDuration equals new config's duration for current mode
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.6, 7.7**

  - [ ]* 15.8 Write property test for config deferred when running/paused (P4)
    - **Property 4: Config is deferred when timer is running or paused**
    - Generate random valid PomodoroConfig, set up running/paused state with random remaining
    - Assert remainingDuration, targetEndTime, mode, cycleCount, selectedTask unchanged
    - **Validates: Requirements 7.5, 7.9**

  - [ ]* 15.9 Write property test for atomic config replacement (P5)
    - **Property 5: Atomic config replacement**
    - Generate two random PomodoroConfigs, apply second, verify all fields match
    - **Validates: Requirements 7.8**

  - [ ]* 15.10 Write property test for save failure preserves state (P6)
    - **Property 6: Save failure preserves persisted state**
    - Generate random valid settings, mock save to throw, verify get returns previous
    - **Validates: Requirements 9.6, 11.5**

  - [ ]* 15.11 Write property test for palette generates valid ColorScheme (P7)
    - **Property 7: Palette generates valid ColorScheme for all variants**
    - Iterate all AppColorPalette values × 2 brightness values (exhaustive)
    - Assert ColorScheme.fromSeed produces non-null without throwing
    - Note: this verifies generation success, not WCAG contrast compliance
    - **Validates: Requirements 5.5, 6.2**

- [ ] 16. Widget tests
  - [ ]* 16.1 Write widget tests for SettingsScreen
    - Test renders all three sections in correct order (Pomodoro, Appearance, Sound)
    - Test loading state shows CircularProgressIndicator
    - Test error state shows message and Retry button
    - Test save failure shows SnackBar and reverts control
    - Test navigation: 4 tabs, Settings at index 3, IndexedStack preserves state
    - _Requirements: 9.1, 9.2, 9.5, 9.6, 11.1, 11.2, 8.1, 8.3_

  - [ ]* 16.2 Write widget tests for section interactions
    - Test duration controls show current values and respond to changes
    - Test theme SegmentedButton reflects current mode and triggers update
    - Test palette selector shows swatches with labels and selection indicator
    - Test SwitchListTile reflects sound state and toggles correctly
    - Test accessibility: Semantics labels present, 48dp touch targets
    - _Requirements: 2.1, 2.6, 3.1, 4.1, 4.4, 5.1, 5.9, 6.4, 6.5, 10.1, 10.2, 10.4_

- [ ] 17. Final checkpoint
  - Run `flutter analyze` and ensure zero issues
  - Run `flutter test` and ensure all non-optional tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The design uses Dart/Flutter directly — no language selection was needed
- `fast_check` is the property-based testing library for Dart
- Domain enums (AppThemeMode, AppColorPalette) are pure Dart with no Flutter imports
- Flutter-specific mappings (ThemeMode, Color, ThemeData) live exclusively in `lib/core/theme/`
- Cross-domain mapping (AppSettings → PomodoroConfig) lives in `lib/app/mappers/`

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["1.3"] },
    { "id": 2, "tasks": ["2.1"] },
    { "id": 3, "tasks": ["2.2", "2.3"] },
    { "id": 4, "tasks": ["3.1"] },
    { "id": 5, "tasks": ["3.2"] },
    { "id": 6, "tasks": ["4.1"] },
    { "id": 7, "tasks": ["6.1"] },
    { "id": 8, "tasks": ["8.1", "9.1"] },
    { "id": 9, "tasks": ["9.2"] },
    { "id": 10, "tasks": ["10.1"] },
    { "id": 11, "tasks": ["10.2"] },
    { "id": 12, "tasks": ["12.1", "12.4"] },
    { "id": 13, "tasks": ["12.2", "12.3"] },
    { "id": 14, "tasks": ["13.1", "13.2"] },
    { "id": 15, "tasks": ["15.1", "15.2", "15.3", "15.4"] },
    { "id": 16, "tasks": ["15.5", "15.6", "15.7", "15.8", "15.9", "15.10", "15.11"] },
    { "id": 17, "tasks": ["16.1", "16.2"] }
  ]
}
```
