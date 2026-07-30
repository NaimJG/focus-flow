# Requirements Document

## Introduction

The Localization and Language Settings feature adds complete Spanish and English localization to Focus Flow. Spanish is the default language (primary audience: Argentina). The user selects their preferred language in Settings, and the entire application switches immediately without restart. The feature uses Flutter's official localization system with ARB resource files and generated `AppLocalizations`.

## Glossary

- **Settings_Controller**: The existing application-scoped ChangeNotifier managing user preferences, extended with a language field.
- **App_Settings**: The immutable domain entity representing all user-configurable preferences, extended with an AppLanguage field.
- **AppLanguage**: A pure Dart enum (`spanish`, `english`) representing the supported application languages. No Flutter imports.
- **AppLanguage_Mapper**: A Flutter-layer utility that maps AppLanguage values to Flutter Locale objects.
- **AppLocalizations**: The Flutter-generated class providing access to localized strings, produced from ARB resource files.
- **ARB_File**: Application Resource Bundle file containing key-value pairs for localized strings.
- **Settings_Screen**: The full-page widget displaying grouped preference controls, extended with a Language section.
- **Isar**: The embedded NoSQL database used for local persistence.
- **Navigation_Bar**: The Material 3 bottom navigation component in HomeScreen.
- **Pomodoro_Controller**: The existing ChangeNotifier managing Pomodoro timer state and cycles.
- **Statistics_Screen**: The screen displaying productivity metrics for the selected time period.
- **Duration_Formatter**: The utility function that formats seconds into human-readable duration strings.
- **Daily_Activity_Chart**: The widget displaying daily focus session bars with weekday labels.

## Requirements

### Requirement 1: Localization Framework Configuration

**User Story:** As a developer, I want the application to use Flutter's official localization system, so that translations are type-safe, generated, and maintainable.

#### Acceptance Criteria

1. THE application SHALL include `flutter_localizations` and `intl` as dependencies in pubspec.yaml.
2. THE application SHALL define a `l10n.yaml` configuration file at the project root specifying the ARB directory as `lib/l10n`, the template ARB file as `app_es.arb`, and the output localization file class name as `AppLocalizations`.
3. THE application SHALL set `generate: true` in the flutter section of pubspec.yaml to enable code generation for localized strings.
4. THE application SHALL provide two ARB resource files: `lib/l10n/app_es.arb` for Spanish and `lib/l10n/app_en.arb` for English.
5. THE MaterialApp SHALL declare `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales` so that the generated localization class is available throughout the widget tree.
6. THE application SHALL set the MaterialApp `locale` property based on the current AppLanguage value from Settings_Controller, mapped to a Flutter Locale via AppLanguage_Mapper.

### Requirement 2: Language Domain Enum

**User Story:** As a developer, I want a pure Dart enum representing supported languages, so that the domain layer remains free of Flutter dependencies.

#### Acceptance Criteria

1. THE application SHALL define a `AppLanguage` enum at `lib/features/settings/domain/entities/app_language.dart` with values `spanish` (index 0) and `english` (index 1), in that order.
2. THE AppLanguage enum SHALL contain no Flutter imports and no references to `Locale` or `MaterialLocalizations`.
3. THE application SHALL define an AppLanguage_Mapper at `lib/core/localization/app_language_mapper.dart` that maps each AppLanguage value to the corresponding Flutter Locale (`es` for spanish, `en` for english).

### Requirement 3: Extend AppSettings with Language

**User Story:** As a user, I want my language preference to be part of my application settings, so that it is persisted and restored automatically.

#### Acceptance Criteria

1. THE App_Settings entity SHALL include an `AppLanguage language` field with a default value of `AppLanguage.spanish`.
2. THE App_Settings `copyWith` method SHALL support an optional `language` parameter.
3. THE App_Settings `==` operator and `hashCode` SHALL include the `language` field.
4. THE App_Settings entity SHALL NOT import Flutter's Locale class.

### Requirement 4: Extend Isar Persistence for Language

**User Story:** As a user, I want my language preference persisted locally, so that it is restored when I reopen the application.

#### Acceptance Criteria

1. THE AppSettingsModel Isar collection SHALL include an `@enumerated AppLanguage language` field with a default value of `AppLanguage.spanish`.
2. WHEN an existing Isar record lacks a language field (migration from earlier schema), THE AppSettingsModel SHALL resolve the value to `AppLanguage.spanish`.
3. IF the persisted enum index does not map to a known AppLanguage value, THEN THE AppSettingsModel SHALL fall back to `AppLanguage.spanish`.
4. THE AppSettingsModel `toEntity` and `fromEntity` methods SHALL correctly convert the language field between model and domain entity.

### Requirement 5: Language Mutation in SettingsController

**User Story:** As a user, I want to change the application language from Settings, so that all text updates to my chosen language.

#### Acceptance Criteria

1. THE Settings_Controller SHALL expose a `Future<bool> updateLanguage(AppLanguage language)` method following the existing optimistic-update-with-rollback pattern.
2. WHEN the user changes the language, THE Settings_Controller SHALL persist the new value and notify listeners.
3. IF persisting the language change fails, THEN THE Settings_Controller SHALL revert to the last successfully persisted language and notify listeners so the UI reverts.
4. WHEN the language changes, THE Settings_Controller SHALL NOT reset or modify the state of Todo, Pomodoro, Statistics, active timer, cycle count, or any other feature state.
5. WHILE a save operation is in progress (`isSaving` is true), THE Settings_Controller SHALL reject additional language change requests.

### Requirement 6: Language Settings UI

**User Story:** As a user, I want a Language section in Settings where I can choose between Español and English, so that I can switch the app language easily.

#### Acceptance Criteria

1. THE Settings_Screen SHALL display sections in the following order from top to bottom: Pomodoro, Appearance, Language, Sound.
2. THE Language section SHALL present exactly two options: "Español" and "English" with a clear visual indicator showing which option is currently active.
3. THE Language section SHALL use Material 3 controls consistent with the rest of the Settings_Screen.
4. THE Language section SHALL ensure all interactive touch targets are at least 48 by 48 density-independent pixels.
5. THE Language section SHALL provide accessible Semantics labels on each language option indicating both the language name and whether it is selected.
6. WHILE the Settings_Controller `isSaving` is true, THE Language section SHALL disable all language option controls.
7. THE Language section header text SHALL be localized (displayed in the current language).

### Requirement 7: Immediate Language Switching

**User Story:** As a user, I want the entire application to switch language immediately when I change the setting, so that I do not need to restart or navigate.

#### Acceptance Criteria

1. WHEN the user selects a different language, THE MaterialApp SHALL rebuild with the new locale in the same frame cycle, causing all visible localized strings to update immediately.
2. WHEN the language changes, THE Navigation_Bar tab labels SHALL update to the new language without losing the current tab selection or IndexedStack state.
3. WHEN the language changes while the Pomodoro timer is running, THE Pomodoro_Controller SHALL NOT pause, reset, or alter the timer state.
4. WHEN the language changes, THE application SHALL NOT perform a full navigation reset or push a new route.
5. WHEN the language changes, THE application SHALL preserve the current scroll position and widget state across all tabs in the IndexedStack.

### Requirement 8: Default Language Behavior

**User Story:** As a user in Argentina, I want the application to start in Spanish by default regardless of my device locale, so that I see my native language on first launch.

#### Acceptance Criteria

1. WHEN the application starts for the first time and no persisted language preference exists, THE Settings_Controller SHALL default to `AppLanguage.spanish`.
2. THE application SHALL NOT use the device system locale to determine the default language.
3. WHEN the application starts and a previously persisted language preference exists, THE Settings_Controller SHALL restore the persisted language.
4. THE Settings_Controller SHALL complete loading the persisted language before MaterialApp builds its first frame, ensuring no visible language transition occurs after launch.

### Requirement 9: Localize Navigation Labels

**User Story:** As a user, I want the bottom navigation labels to display in my chosen language, so that navigation is consistent with the rest of the interface.

#### Acceptance Criteria

1. WHEN the locale is Spanish, THE Navigation_Bar SHALL display labels: "Tareas", "Pomodoro", "Estadísticas", "Configuración".
2. WHEN the locale is English, THE Navigation_Bar SHALL display labels: "Todo", "Pomodoro", "Statistics", "Settings".
3. THE HomeScreen SHALL build the NavigationDestination list at runtime using AppLocalizations, replacing the current static `const` list.
4. WHEN the language changes, THE Navigation_Bar labels SHALL update without losing the current selected tab index.

### Requirement 10: Localize Todo Feature Strings

**User Story:** As a user, I want all Todo screen text in my chosen language, so that task management is fully accessible in Spanish or English.

#### Acceptance Criteria

1. WHEN the locale is Spanish, THE Todo feature SHALL display localized strings for: title ("Tareas"), "Crear tarea", "Eliminar tarea", delete confirmation dialog text, search hint, filter labels, sort labels, and all empty state messages.
2. WHEN the locale is English, THE Todo feature SHALL display: "Tasks", "Create Task", "Delete Task", and all related English strings matching the current hardcoded values.
3. THE empty state messages SHALL be localized for all variants: no tasks, no search results, no filter results, no category tasks.
4. THE confirmation dialog for task deletion SHALL display localized title, message, confirm label, and cancel label.
5. THE Todo feature SHALL NOT translate user-created task titles, notes, or category names.

### Requirement 11: Localize Pomodoro Feature Strings

**User Story:** As a user, I want all Pomodoro screen text in my chosen language, so that timer usage is fully accessible in Spanish or English.

#### Acceptance Criteria

1. WHEN the locale is Spanish, THE Pomodoro feature SHALL display localized strings for: title ("Pomodoro"), mode labels ("Enfoque", "Descanso corto", "Descanso largo"), status labels ("Listo", "En curso", "Pausado"), and control labels ("Iniciar", "Pausar", "Reanudar", "Reiniciar", "Saltar").
2. WHEN the locale is English, THE Pomodoro feature SHALL display: "Pomodoro", "Focus", "Short Break", "Long Break", "Ready", "Running", "Paused", "Start", "Pause", "Resume", "Reset", "Skip" matching current hardcoded values.
3. THE completion messages SHALL be localized for each timer mode (e.g., "Sesión de enfoque terminada" / "Focus session finished").
4. THE accessibility announcements for timer status changes SHALL be localized using the current locale's text direction.
5. THE error messages (session not saved, retry) SHALL be localized.
6. THE Pomodoro feature SHALL NOT translate user-created task titles displayed in the task selector.

### Requirement 12: Localize Statistics Feature Strings

**User Story:** As a user, I want all Statistics screen text in my chosen language, so that productivity insights are fully accessible in Spanish or English.

#### Acceptance Criteria

1. WHEN the locale is Spanish, THE Statistics feature SHALL display localized strings for: title ("Estadísticas"), period labels ("Hoy", "Esta semana", "Este mes"), metric labels ("Tiempo total", "Sesiones", "Promedio"), section headers ("Por tarea", "Por categoría"), and empty state ("Aún no hay sesiones de enfoque").
2. WHEN the locale is English, THE Statistics feature SHALL display: "Statistics", "Today", "This Week", "This Month", "Total Time", "Sessions", "Average", "By Task", "By Category", "No focus sessions yet" matching current hardcoded values.
3. THE error state retry button SHALL display the localized label ("Reintentar" / "Retry").

### Requirement 13: Localize Settings Feature Strings

**User Story:** As a user, I want all Settings screen text in my chosen language, so that preference configuration is fully accessible in Spanish or English.

#### Acceptance Criteria

1. WHEN the locale is Spanish, THE Settings feature SHALL display localized strings for: title ("Configuración"), section headers ("Pomodoro", "Apariencia", "Idioma", "Sonido"), theme mode labels ("Sistema", "Claro", "Oscuro"), palette names ("Salmón", "Azul claro", "Verde claro"), sound state ("Activado" / "Desactivado"), and all validation messages.
2. WHEN the locale is English, THE Settings feature SHALL display: "Settings", "Pomodoro", "Appearance", "Language", "Sound", "System", "Light", "Dark", "Salmon", "Light Blue", "Light Green", "Enabled", "Disabled" matching current hardcoded values.
3. THE duration unit labels SHALL be localized ("min" in both languages, as the abbreviation is shared).
4. THE save error SnackBar messages SHALL be localized (e.g., "No se pudo guardar {setting}. Intente de nuevo." / "Could not save {setting}. Please try again.").

### Requirement 14: Localize Router and Shared Strings

**User Story:** As a user, I want error pages and shared UI elements in my chosen language, so that no part of the application shows untranslated text.

#### Acceptance Criteria

1. WHEN the locale is Spanish, THE not-found screen SHALL display "No encontrado" as title and "Página no encontrada" as body.
2. WHEN the locale is English, THE not-found screen SHALL display "Not Found" as title and "Page not found" as body.
3. THE shared confirmation dialog labels SHALL be localized: "Cancelar"/"Cancel", "Eliminar"/"Delete".
4. THE shared "Reintentar"/"Retry" label SHALL be localized wherever retry actions appear.

### Requirement 15: Locale-Aware Date and Time Formatting

**User Story:** As a user, I want dates and weekday labels in my chosen language, so that temporal information is culturally appropriate.

#### Acceptance Criteria

1. WHEN the locale is Spanish, THE Daily_Activity_Chart SHALL display weekday abbreviations in Spanish (e.g., "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom").
2. WHEN the locale is English, THE Daily_Activity_Chart SHALL display weekday abbreviations in English (e.g., "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun").
3. THE Daily_Activity_Chart SHALL derive weekday labels from the current locale rather than a hardcoded English array.

### Requirement 16: Locale-Aware Duration Formatting

**User Story:** As a user, I want duration units displayed in my chosen language, so that numeric information is readable.

#### Acceptance Criteria

1. THE Duration_Formatter SHALL accept a locale parameter or use the current application locale to determine unit labels.
2. WHEN the locale is Spanish, THE Duration_Formatter SHALL display duration units "min" and "h" (shared abbreviations in both languages).
3. WHEN the locale is English, THE Duration_Formatter SHALL display duration units "min" and "h".
4. THE Duration_Formatter SHALL use the localized unit labels consistently in Statistics summary cards, chart tooltips, and any other location where formatted durations appear.

### Requirement 17: Enum Label Localization

**User Story:** As a developer, I want domain enum labels mapped to localized strings in the presentation layer, so that domain enums remain pure Dart without Flutter dependencies.

#### Acceptance Criteria

1. THE presentation layer SHALL map user-facing labels for Priority enum values to localized strings via AppLocalizations.
2. THE presentation layer SHALL map user-facing labels for TaskStatus enum values to localized strings via AppLocalizations.
3. THE presentation layer SHALL map user-facing labels for SortCriterion enum values to localized strings via AppLocalizations.
4. THE presentation layer SHALL map user-facing labels for TimerMode enum values to localized strings via AppLocalizations.
5. THE domain enum definitions SHALL NOT contain Flutter imports or localized string constants.

### Requirement 18: ARB Key Standards

**User Story:** As a developer, I want stable, descriptive ARB keys with proper placeholder and pluralization support, so that translations are maintainable and grammatically correct.

#### Acceptance Criteria

1. THE ARB files SHALL use descriptive camelCase keys prefixed by feature area (e.g., `navigationTodo`, `settingsTitle`, `pomodoroStart`, `statisticsTotalTime`).
2. THE ARB files SHALL use ICU message syntax placeholders for dynamic values (e.g., `{minutes}`, `{settingName}`).
3. THE ARB files SHALL use ICU plural syntax where grammatical number varies between languages.
4. THE Spanish template ARB file (`app_es.arb`) SHALL include `@` metadata entries with `description` fields for all keys to support translator context.

### Requirement 19: Spanish Language Quality

**User Story:** As a user in Argentina, I want neutral Latin American Spanish throughout the application, so that the text feels natural and familiar.

#### Acceptance Criteria

1. THE Spanish translations SHALL use neutral Latin American Spanish suitable for Argentina (e.g., "Configuración" not "Ajustes", "Estadísticas", "Descanso corto", "Descanso largo").
2. THE Spanish translations SHALL use "Reintentar" for retry, "Cancelar" for cancel, "Eliminar" for delete, and "Sin categoría" for uncategorized.
3. THE Spanish translations SHALL avoid regional slang, voseo verb forms in UI labels, and Spain-specific terminology.

### Requirement 20: English Language Quality

**User Story:** As an English-speaking user, I want concise English terminology preserved from the current application, so that there is no regression in the English experience.

#### Acceptance Criteria

1. THE English translations SHALL preserve the exact wording currently hardcoded in the application for all existing strings.
2. THE English translations SHALL maintain consistent terminology across all screens (e.g., "Tasks" not sometimes "To-Do").

### Requirement 21: User-Generated Content Isolation

**User Story:** As a user, I want my task titles, notes, and category names to remain exactly as I typed them regardless of language changes, so that my personal content is never altered.

#### Acceptance Criteria

1. WHEN the language changes, THE application SHALL NOT modify, translate, or re-render user-created task titles.
2. WHEN the language changes, THE application SHALL NOT modify user-created notes or descriptions.
3. WHEN the language changes, THE application SHALL NOT modify or rename persisted category names (including default seeded categories).
4. WHEN the language changes, THE application SHALL NOT modify task title snapshots stored in Pomodoro session records.

### Requirement 22: Accessibility for Localized Content

**User Story:** As a user relying on assistive technology, I want all localized text to have proper Semantics labels and text direction, so that screen readers work correctly in both languages.

#### Acceptance Criteria

1. THE application SHALL set the Semantics text direction based on the current locale (LTR for both Spanish and English).
2. THE application SHALL localize all Semantics labels, tooltips, and screen-reader announcements using AppLocalizations.
3. THE application SHALL continue meeting 48dp touch targets, proper focus order, text scaling support, and no color-only information communication in both languages.

### Requirement 23: App Title Preservation

**User Story:** As a user, I want the app name "Focus Flow" to remain unchanged in both languages, so that the brand identity is consistent.

#### Acceptance Criteria

1. THE MaterialApp `title` property SHALL remain "Focus Flow" regardless of the selected language.
2. THE application SHALL NOT translate or localize the app name "Focus Flow" in any visible location.

### Requirement 24: Provider and Lifecycle Integration

**User Story:** As a developer, I want language to live in the existing SettingsController without new controllers, so that the architecture remains simple and the MaterialApp rebuilds via the existing Consumer pattern.

#### Acceptance Criteria

1. THE language preference SHALL be managed by the existing Settings_Controller without introducing a new controller or provider.
2. THE MaterialApp SHALL rebuild with the new locale via the existing `Consumer<SettingsController>` pattern when the language changes.
3. WHEN the language changes, THE Consumer rebuild SHALL propagate the new locale to `AppLocalizations` without requiring manual context lookups or additional InheritedWidgets beyond what Flutter's localization system provides.

## Out of Scope

- Additional languages beyond Spanish and English
- Automatic or system-language detection as default
- Remote translation delivery or over-the-air updates
- Right-to-left (RTL) layout support
- Per-screen language selection
- Date/time format user preferences (beyond locale-driven weekday labels)
- Translating user-created content
- Renaming persisted default categories on language change
- Cloud synchronization
- Achievement or gamification
- Premium flows
