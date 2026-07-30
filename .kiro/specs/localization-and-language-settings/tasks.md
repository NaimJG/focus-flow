# Implementation Plan: Localization and Language Settings

## Overview

Add complete Spanish/English localization to Focus Flow using Flutter's `gen_l10n` system. The implementation proceeds incrementally: localization infrastructure first, then domain/persistence changes, then MaterialApp integration, then UI migration feature-by-feature, and finally tests. Each task is small and focused on a single file or closely related set of changes.

## Tasks

- [x] 1. Localization configuration and ARB foundation
  - [x] 1.1 Add `flutter_localizations` and `intl` dependencies to pubspec.yaml, set `generate: true` under flutter section
    - Add `flutter_localizations: sdk: flutter` to dependencies
    - Add `intl: any` to dependencies
    - Add `generate: true` under the `flutter:` section
    - _Requirements: 1.1, 1.3_

  - [x] 1.2 Create `l10n.yaml` at project root
    - Set `arb-dir: lib/l10n`
    - Set `template-arb-file: app_es.arb`
    - Set `output-localization-file: app_localizations.dart`
    - Set `output-class: AppLocalizations`
    - _Requirements: 1.2_

  - [x] 1.3 Create `lib/l10n/app_es.arb` with navigation and shared keys
    - Add keys: `navigationTodo`, `navigationPomodoro`, `navigationStatistics`, `navigationSettings`
    - Add shared keys: `sharedCancel`, `sharedDelete`, `sharedRetry`
    - Add `@` metadata descriptions for all keys
    - _Requirements: 1.4, 9.1, 14.3, 14.4, 18.1, 18.4, 19.1, 19.2_

  - [x] 1.4 Create `lib/l10n/app_en.arb` with navigation and shared keys
    - Mirror all keys from `app_es.arb` with English translations
    - _Requirements: 1.4, 9.2, 14.2, 14.3, 14.4, 20.1, 20.2_

- [x] 2. Checkpoint — Localization generation setup
  - Run `flutter gen-l10n` (or `flutter pub get`) and verify `AppLocalizations` class is generated without errors
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. AppLanguage domain enum and AppSettings changes
  - [x] 3.1 Create `AppLanguage` enum at `lib/features/settings/domain/entities/app_language.dart`
    - Values: `spanish` (index 0), `english` (index 1)
    - Pure Dart — no Flutter imports
    - _Requirements: 2.1, 2.2_

  - [x] 3.2 Add `language` field to `AppSettings` entity
    - Add `AppLanguage language` with default `AppLanguage.spanish`
    - Update `copyWith` to include optional `language` parameter
    - Update `==` and `hashCode` to include `language`
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 4. Isar model persistence update
  - [x] 4.1 Add `language` field to `AppSettingsModel` and update converters
    - Add `@enumerated AppLanguage language = AppLanguage.spanish`
    - Update `toEntity()` to include language
    - Update `fromEntity()` to include language
    - Run `dart run build_runner build` to regenerate `app_settings_model.g.dart`
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 5. Checkpoint — Persistence integration
  - Verify `build_runner` completes without errors, schema is regenerated
  - Run `flutter analyze` and `flutter test` to ensure no regressions
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. SettingsController updateLanguage behavior
  - [x] 6.1 Add `updateLanguage(AppLanguage)` method to `SettingsController`
    - Follow existing `_applyChange` optimistic-update-with-rollback pattern
    - Add `String? get failedSettingName` getter for presentation-layer error localization
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 7. Core locale mapper and MaterialApp integration
  - [x] 7.1 Create `AppLanguageMapper` at `lib/core/localization/app_language_mapper.dart`
    - Static `toLocale(AppLanguage)` method returning `Locale('es')` or `Locale('en')`
    - Uses `dart:ui` Locale only
    - _Requirements: 2.3_

  - [x] 7.2 Integrate locale, delegates, and supportedLocales into MaterialApp in `app.dart`
    - Add `locale: AppLanguageMapper.toLocale(settings.settings.language)`
    - Add `localizationsDelegates: AppLocalizations.localizationsDelegates`
    - Add `supportedLocales: AppLocalizations.supportedLocales`
    - Import generated `AppLocalizations` and `AppLanguageMapper`
    - _Requirements: 1.5, 1.6, 7.1, 7.4, 8.1, 8.2, 8.3, 8.4, 23.1, 24.1, 24.2, 24.3_

- [x] 8. Checkpoint — MaterialApp locale integration
  - Run `flutter analyze` and `flutter test`
  - Verify app builds and renders in Spanish by default
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Language Settings UI
  - [x] 9.1 Create `LanguageSettingsSection` widget at `lib/features/settings/presentation/widgets/language_settings_section.dart`
    - Display "Español" and "English" options with selection indicator
    - Use Material 3 controls consistent with existing sections
    - Ensure 48×48dp touch targets
    - Provide Semantics labels on each option
    - Disable controls when `isSaving` is true
    - Localize section header via `AppLocalizations`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

  - [x] 9.2 Add `LanguageSettingsSection` to `SettingsScreen` between Appearance and Sound
    - Modify `_LoadedBody` in `settings_screen.dart` to insert `LanguageSettingsSection()` after `AppearanceSettingsSection()` and before `SoundSettingsSection()`
    - _Requirements: 6.1_

- [x] 10. Home navigation localization
  - [x] 10.1 Replace `static const _destinations` in `HomeScreen` with runtime localized list
    - Remove `static const _destinations`
    - Build `destinations` list inside `build()` using `AppLocalizations.of(context)!`
    - Use keys: `navigationTodo`, `navigationPomodoro`, `navigationStatistics`, `navigationSettings`
    - Preserve `_selectedIndex` and `IndexedStack` state
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 7.2, 7.5_

- [x] 11. Checkpoint — Navigation localization
  - Verify nav labels render in Spanish by default and switch to English on language change
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Todo localization
  - [ ] 12.1 Add Todo ARB keys to `app_es.arb` and `app_en.arb`
    - Keys for: title, create task, delete task, delete confirmation dialog, search hint, filter labels, sort labels, empty states (all 4 variants)
    - Include `@` metadata for all new keys in Spanish template
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 18.1, 18.4_

  - [ ] 12.2 Create `lib/features/todo/presentation/utils/todo_labels.dart`
    - Helper functions mapping Priority, TaskStatus, SortCriterion to localized labels via `AppLocalizations`
    - _Requirements: 17.1, 17.2, 17.3, 17.5_

  - [ ] 12.3 Localize `TodoScreen` (`todo_screen.dart`)
    - Replace AppBar title "Tasks" with `l10n.todoTitle`
    - Replace "Delete Task" dialog strings with localized equivalents
    - Replace "Categories" tooltip with localized string
    - _Requirements: 10.1, 10.2, 10.4, 21.1, 21.2, 21.3_

  - [ ] 12.4 Localize `EmptyStateWidget` (`empty_state_widget.dart`)
    - Replace `_headlineForVariant` and `_messageForVariant` with `AppLocalizations.of(context)!` calls
    - Replace "Create Task" button label
    - _Requirements: 10.3_

  - [ ] 12.5 Localize `FilterBar` (`filter_bar.dart`)
    - Replace filter chip labels with localized strings
    - _Requirements: 10.1_

  - [ ] 12.6 Localize `SortControl` (`sort_control.dart`)
    - Replace sort criterion labels with localized strings using `todo_labels.dart` helpers
    - _Requirements: 10.1_

- [ ] 13. Checkpoint — Todo localization
  - Verify all Todo strings render in Spanish by default
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 14. Pomodoro localization
  - [ ] 14.1 Add Pomodoro ARB keys to `app_es.arb` and `app_en.arb`
    - Keys for: title, mode labels (focus, short break, long break), status labels (ready, running, paused), control labels (start, pause, resume, reset, skip), completion messages, next-ready messages, session not saved, accessibility announcements
    - Include `@` metadata for all new keys in Spanish template
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 18.1, 18.4_

  - [ ] 14.2 Create `lib/features/pomodoro/presentation/utils/timer_mode_labels.dart`
    - `String timerModeLabel(TimerMode, AppLocalizations)` helper
    - `String timerModeCompletedLabel(TimerMode?, AppLocalizations)` helper
    - `String timerModeNextReadyLabel(TimerMode, AppLocalizations)` helper
    - _Requirements: 17.4, 17.5_

  - [ ] 14.3 Localize `PomodoroScreen` (`pomodoro_screen.dart`)
    - Replace AppBar title "Pomodoro" with `l10n.pomodoroTitle`
    - Replace `_modeLabel` and `_modeLabelForCompleted` with `timer_mode_labels.dart` helpers
    - Replace `_StatusText` hardcoded strings (Ready, Running, Paused, completion/next-ready messages)
    - Replace `_announceStatusChange` strings with localized versions
    - Replace "Session not saved — tap to retry" with localized string
    - Use `Localizations.localeOf(context)` for text direction in announcements
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 22.1, 22.2_

  - [ ] 14.4 Localize `TimerControls` (`timer_controls.dart`)
    - Replace button labels (Start, Pause, Resume, Reset, Skip) with `l10n.*` calls
    - Pass `AppLocalizations` or access via `context`
    - _Requirements: 11.1, 11.2_

  - [ ] 14.5 Localize Pomodoro error SnackBar
    - Replace "Retry" label with `l10n.sharedRetry`
    - _Requirements: 11.5, 14.4_

- [ ] 15. Checkpoint — Pomodoro localization
  - Verify all Pomodoro strings render in Spanish by default
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 16. Statistics localization
  - [ ] 16.1 Add Statistics ARB keys to `app_es.arb` and `app_en.arb`
    - Keys for: title, period labels (today, this week, this month), metric labels (total time, sessions, average), section headers (by task, by category), empty state, retry, duration format templates (`durationMinutes`, `durationHoursMinutes`)
    - Include `@` metadata and placeholder definitions
    - _Requirements: 12.1, 12.2, 12.3, 16.2, 16.3, 18.1, 18.2, 18.4_

  - [ ] 16.2 Create `lib/features/statistics/presentation/utils/statistics_labels.dart`
    - Helper function mapping `StatisticsPeriod` to localized label via `AppLocalizations`
    - _Requirements: 12.1, 12.2_

  - [ ] 16.3 Localize `PeriodSelector` (`period_selector.dart`)
    - Replace hardcoded "Today", "This Week", "This Month" with `l10n.*` calls
    - Remove `const` from segments list (now runtime)
    - _Requirements: 12.1, 12.2_

  - [ ] 16.4 Localize `SummaryCardsRow` (`summary_cards_row.dart`)
    - Replace "Total Time", "Sessions", "Average" labels with `l10n.*`
    - Update `formatDuration` calls to pass `AppLocalizations`
    - _Requirements: 12.1, 12.2, 16.1, 16.4_

  - [ ] 16.5 Localize `DailyActivityChart` (`daily_activity_chart.dart`)
    - Replace hardcoded `weekdays` array with `DateFormat.E(locale)` using `intl`
    - Derive locale from `Localizations.localeOf(context).languageCode`
    - Update tooltip to use localized duration format
    - _Requirements: 15.1, 15.2, 15.3_

  - [ ] 16.6 Update `formatDuration` in `duration_formatter.dart`
    - Add `AppLocalizations l10n` parameter
    - Use `l10n.durationMinutes(minutes)` and `l10n.durationHoursMinutes(hours, minutes)`
    - Update all callers
    - _Requirements: 16.1, 16.2, 16.3, 16.4_

- [ ] 17. Checkpoint — Statistics localization
  - Verify all Statistics strings render in Spanish by default, weekday labels are locale-aware
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 18. Settings localization
  - [ ] 18.1 Add Settings ARB keys to `app_es.arb` and `app_en.arb`
    - Keys for: title, section headers (Pomodoro, Appearance, Language, Sound), theme mode labels (System, Light, Dark), palette names (Salmon, Light Blue, Light Green), sound states (Enabled, Disabled), duration unit ("min"), save error template with placeholder, retry, validation messages
    - Include `@` metadata and placeholder definitions
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 18.1, 18.2, 18.4_

  - [ ] 18.2 Create `lib/features/settings/presentation/utils/settings_labels.dart`
    - Helper functions mapping `AppThemeMode` and `AppColorPalette` to localized labels via `AppLocalizations`
    - _Requirements: 17.5_

  - [ ] 18.3 Localize `AppearanceSettingsSection` (`appearance_settings_section.dart`)
    - Replace "Appearance" header, theme mode labels (System, Light, Dark), palette names (Salmon, Light Blue, Light Green) with `l10n.*`
    - _Requirements: 13.1, 13.2_

  - [ ] 18.4 Localize `PomodoroSettingsSection` (`pomodoro_settings_section.dart`)
    - Replace "Pomodoro" header, "min" unit label, field labels with `l10n.*`
    - _Requirements: 13.1, 13.3_

  - [ ] 18.5 Localize `SoundSettingsSection` (`sound_settings_section.dart`)
    - Replace "Sound" header, "Enabled"/"Disabled" labels with `l10n.*`
    - _Requirements: 13.1, 13.2_

  - [ ] 18.6 Localize `SettingsScreen` (`settings_screen.dart`)
    - Replace AppBar title "Settings" with `l10n.settingsTitle`
    - Replace error body message and "Retry" button label with localized versions
    - Localize save error SnackBar using `failedSettingName` + `l10n.settingsSaveError`
    - _Requirements: 13.1, 13.4_

- [ ] 19. Checkpoint — Settings localization
  - Verify all Settings strings render in Spanish by default
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 20. Generic routes, dialogs, SnackBars, semantics, and formatters
  - [ ] 20.1 Localize `_NotFoundScreen` in `router.dart`
    - Replace "Not Found" title and "Page not found" body with `l10n.*` calls
    - _Requirements: 14.1, 14.2_

  - [ ] 20.2 Localize shared `ConfirmationDialog` labels
    - Ensure callers pass localized labels (already accepts params — update call sites in `todo_screen.dart`)
    - Replace hardcoded "Delete Task", "Cancel", "Delete" at call sites with `l10n.*`
    - _Requirements: 14.3, 10.4_

  - [ ] 20.3 Verify Semantics text direction and localized labels
    - Ensure `Semantics` `textDirection` is set based on locale (LTR for both es/en)
    - Verify all `Semantics` labels use `l10n.*` in screens already migrated
    - Confirm accessibility announcements in Pomodoro use `Localizations.localeOf(context)` text direction
    - _Requirements: 22.1, 22.2, 22.3_

- [ ] 21. Checkpoint — Full feature localization complete
  - Run `dart format .` and `flutter analyze`
  - Verify no hardcoded user-facing strings remain (spot-check all screens)
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 22. Essential tests
  - [ ] 22.1 Unit tests for `AppLanguage` enum and `AppSettings` language field
    - Test `AppLanguage.values` has correct order (spanish=0, english=1)
    - Test `AppSettings` default language is `AppLanguage.spanish`
    - Test `copyWith(language:)` produces correct result with other fields unchanged
    - Test equality includes `language` field
    - _Requirements: 2.1, 3.1, 3.2, 3.3_

  - [ ] 22.2 Unit tests for `AppSettingsModel` language round-trip
    - Test `toEntity()` converts language field correctly
    - Test `fromEntity()` stores language field correctly
    - Test round-trip: `fromEntity(entity).toEntity() == entity` including language
    - _Requirements: 4.1, 4.4_

  - [ ] 22.3 Unit tests for `SettingsController.updateLanguage`
    - Test successful persist updates `settings.language` and returns `true`
    - Test failed persist reverts to previous language and returns `false`
    - Test rejected while `isSaving` returns `false` without state change
    - Test language change does not alter other settings fields
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ] 22.4 Unit tests for `AppLanguageMapper`
    - Test `spanish` maps to `Locale('es')`
    - Test `english` maps to `Locale('en')`
    - Test all values produce distinct locales
    - _Requirements: 2.3_

  - [ ] 22.5 Unit tests for `formatDuration` with localization
    - Test produces correct output for 0 seconds (both locales)
    - Test produces correct output for values below 3600
    - Test produces correct output for values at/above 3600
    - _Requirements: 16.1, 16.2, 16.3, 16.4_

  - [ ]* 22.6 Widget test for `LanguageSettingsSection`
    - Test renders two options with correct labels ("Español", "English")
    - Test selection change calls `updateLanguage` on controller
    - Test disabled state when `isSaving` is true
    - Test Semantics labels present on both options
    - _Requirements: 6.2, 6.3, 6.5, 6.6_

  - [ ]* 22.7 Widget test for `HomeScreen` localized navigation
    - Test destinations render localized labels from `AppLocalizations`
    - Test labels update when locale changes (mock controller)
    - Test selected tab index preserved across locale change
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

  - [ ]* 22.8 Integration test for language switching and persistence
    - Test full startup defaults to Spanish
    - Test language switch to English updates all visible strings
    - Test timer state preserved across language change
    - Test language persisted across simulated restart
    - _Requirements: 7.1, 7.2, 7.3, 8.1, 8.3_

  - [ ]* 22.9 Property test: Language setting round-trip persistence (P1)
    - **Property 1: Language setting round-trip persistence**
    - Generate random valid `AppSettings` (all fields randomized including language), persist, load, compare
    - **Validates: Requirements 3.1, 3.2, 3.3, 4.1, 4.4**

  - [ ]* 22.10 Property test: Language change preserves all other settings (P2)
    - **Property 2: Language change preserves all other settings**
    - Generate random `AppSettings` + random `AppLanguage`, apply `copyWith(language:)`, verify other fields unchanged
    - **Validates: Requirements 5.4, 7.3, 7.5, 21.1, 21.2, 21.3, 21.4**

  - [ ]* 22.11 Property test: AppLanguageMapper bijectivity (P3)
    - **Property 3: AppLanguageMapper bijectivity**
    - Exhaustive: verify distinct locales with valid BCP 47 language codes for all AppLanguage values
    - **Validates: Requirements 1.6, 2.3**

  - [ ]* 22.12 Property test: Duration formatter locale consistency (P4)
    - **Property 4: Duration formatter locale consistency**
    - Generate random non-negative int (0 to 100000), call formatter with each locale variant, verify non-empty, no raw placeholder tokens, correct numeric content
    - **Validates: Requirements 16.1, 16.2, 16.3, 16.4**

  - [ ]* 22.13 Property test: updateLanguage rollback on failure (P5)
    - **Property 5: updateLanguage rollback on failure**
    - Generate random initial language + random target language, mock save to throw, verify revert
    - **Validates: Requirements 5.3**

  - [ ]* 22.14 Property test: isSaving guard rejects concurrent language change (P6)
    - **Property 6: Language change does not reset isSaving guard**
    - Generate random language, set `isSaving=true`, call `updateLanguage`, verify returns `false` and settings unchanged
    - **Validates: Requirements 5.5**

  - [ ]* 22.15 Golden/screenshot tests for localized screens (extensive)
    - Capture golden images for key screens in both Spanish and English
    - Compare against baseline images for regression detection
    - _Requirements: 19.1, 20.1_

  - [ ]* 22.16 Exhaustive ARB key coverage test
    - Verify every key in `app_es.arb` has a corresponding key in `app_en.arb`
    - Verify no unused keys exist
    - _Requirements: 18.1_

  - [ ]* 22.17 Full accessibility suite test
    - Verify Semantics tree includes localized labels for all interactive elements
    - Verify text scaling does not cause overflow in both locales
    - _Requirements: 22.1, 22.2, 22.3_

- [ ] 23. Final verification
  - [ ] 23.1 Run `dart format .`, `flutter analyze`, and `flutter test`
    - Fix any formatting issues, lint warnings, or test failures
    - Verify zero analyzer issues
    - Ensure all non-optional tests pass
    - _Requirements: all_

- [ ] 24. Final checkpoint — App-wide verification
  - Confirm all screens show localized strings in both languages
  - Confirm language switch is immediate, no restart needed
  - Confirm user-generated content (task titles, notes, categories) is never modified
  - Confirm timer state preserved during language switch
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The design uses Dart/Flutter directly — no language selection was needed
- `fast_check` is the property-based testing library for Dart
- ARB files are built incrementally: navigation/shared keys first, then feature-specific keys added per localization group
- The `AppLanguage` enum is pure Dart; Flutter `Locale` mapping lives in `core/localization/`
- Spanish (Latin American, neutral) is the template and default language
- Golden tests, screenshot tests, exhaustive ARB coverage tests, and full accessibility suite are marked optional — they must NOT block feature completion

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["1.3", "1.4"] },
    { "id": 2, "tasks": ["3.1"] },
    { "id": 3, "tasks": ["3.2"] },
    { "id": 4, "tasks": ["4.1"] },
    { "id": 5, "tasks": ["6.1"] },
    { "id": 6, "tasks": ["7.1"] },
    { "id": 7, "tasks": ["7.2"] },
    { "id": 8, "tasks": ["9.1", "10.1"] },
    { "id": 9, "tasks": ["9.2"] },
    { "id": 10, "tasks": ["12.1", "14.1", "16.1", "18.1"] },
    { "id": 11, "tasks": ["12.2", "14.2", "16.2", "18.2"] },
    { "id": 12, "tasks": ["12.3", "12.4", "12.5", "12.6"] },
    { "id": 13, "tasks": ["14.3", "14.4", "14.5"] },
    { "id": 14, "tasks": ["16.3", "16.4", "16.5", "16.6"] },
    { "id": 15, "tasks": ["18.3", "18.4", "18.5", "18.6"] },
    { "id": 16, "tasks": ["20.1", "20.2", "20.3"] },
    { "id": 17, "tasks": ["22.1", "22.2", "22.3", "22.4", "22.5"] },
    { "id": 18, "tasks": ["22.6", "22.7", "22.8"] },
    { "id": 19, "tasks": ["22.9", "22.10", "22.11", "22.12", "22.13", "22.14"] },
    { "id": 20, "tasks": ["22.15", "22.16", "22.17"] },
    { "id": 21, "tasks": ["23.1"] }
  ]
}
```
