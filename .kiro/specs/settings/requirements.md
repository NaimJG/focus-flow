# Requirements Document

## Introduction

The Settings feature provides a centralized screen where users configure application-wide preferences: Pomodoro timer durations, sound toggle, theme mode, and color palette. All settings persist locally via Isar and are restored on app restart. Changes to timer preferences apply only to future sessions — active timers are never interrupted.

## Glossary

- **Settings_Controller**: The ChangeNotifier responsible for loading, holding, and saving application settings state. Provided at application scope.
- **Settings_Repository**: The abstract interface for reading and writing the persisted settings record.
- **App_Settings**: The domain entity representing the full set of user-configurable preferences.
- **Settings_Screen**: The full-page widget displaying grouped preference controls.
- **Pomodoro_Controller**: The existing ChangeNotifier managing Pomodoro timer state and cycles.
- **Theme_Mode**: An enumeration representing the application brightness mode (System, Light, Dark).
- **Color_Palette**: An enumeration representing the selectable color palette (Salmon, Light_Blue, Light_Green).
- **Navigation_Bar**: The Material 3 bottom navigation component in HomeScreen.
- **Isar**: The embedded NoSQL database used for local persistence.

## Requirements

### Requirement 1: Persist and Restore Settings

**User Story:** As a user, I want my preferences to be saved locally, so that they are preserved after I close and reopen the application.

#### Acceptance Criteria

1. WHEN the application starts for the first time, THE Settings_Controller SHALL provide default values: focus duration 25 minutes, short break 5 minutes, long break 15 minutes, cycles before long break 4, sound enabled true, theme mode System, and color palette Salmon.
2. WHEN the user modifies any setting, THE Settings_Repository SHALL persist the complete updated App_Settings record to Isar before the Settings_Controller reports the change as saved.
3. WHEN the application starts and a persisted settings record exists, THE Settings_Controller SHALL restore all values from the persisted record.
4. IF the Settings_Repository fails to read the persisted record, THEN THE Settings_Controller SHALL expose an error state that includes a human-readable description and a retry action, allowing the presentation layer to display the error.
5. IF no persisted record exists, THEN THE Settings_Controller SHALL use default values without exposing an error state.
6. THE Settings_Repository SHALL store settings as a single Isar record identified by a fixed integer ID of 1.

### Requirement 2: Configure Pomodoro Durations

**User Story:** As a user, I want to adjust focus, short break, and long break durations, so that the Pomodoro timer matches my personal productivity rhythm.

#### Acceptance Criteria

1. THE Settings_Screen SHALL display a numeric input control for each of focus duration, short break duration, and long break duration within a "Pomodoro" section, each showing its current persisted value and a "min" unit label.
2. WHEN the user sets the focus duration, THE Settings_Controller SHALL accept whole-minute integer values between 1 and 120 inclusive and persist the change immediately.
3. WHEN the user sets the short break duration, THE Settings_Controller SHALL accept whole-minute integer values between 1 and 60 inclusive and persist the change immediately.
4. WHEN the user sets the long break duration, THE Settings_Controller SHALL accept whole-minute integer values between 1 and 120 inclusive and persist the change immediately.
5. IF the user attempts to set a value outside the valid range for a duration field, THEN THE Settings_Controller SHALL reject the value, retain the previous valid value, revert the input control to display the previous valid value, and display a brief inline message indicating the allowed range for that field.
6. WHEN the Settings_Screen is first displayed, THE Settings_Screen SHALL populate each duration input control with the value currently held by the Settings_Controller.

### Requirement 3: Configure Cycles Before Long Break

**User Story:** As a user, I want to set how many focus sessions occur before a long break, so that I can customize my work cycle length.

#### Acceptance Criteria

1. THE Settings_Screen SHALL display a numeric input control for cycles before long break within the "Pomodoro" section, showing the current value and allowing selection of whole integers from 1 to 6 inclusive.
2. WHEN the user sets cycles before long break to a value between 1 and 6 inclusive, THE Settings_Controller SHALL persist the selected value locally within 1 second and apply it to subsequent Pomodoro cycles without requiring an app restart.
3. IF the user attempts to set a value outside the range of 1 to 6, THEN THE Settings_Controller SHALL reject the input, retain the previous valid value, and display a transient error message indicating the allowed range.
4. WHEN the app is opened and no user-configured value for cycles before long break exists, THE Settings_Controller SHALL default the value to 4.
5. WHEN the user reopens the app after previously setting cycles before long break, THE Settings_Screen SHALL display the persisted value.

### Requirement 4: Configure Sound Preference

**User Story:** As a user, I want to enable or disable sound, so that I can control whether the app plays audio notifications.

#### Acceptance Criteria

1. THE Settings_Screen SHALL display a Material 3 SwitchListTile for sound enabled or disabled within a "Sound" section, with a text label reading "Sound" and a secondary text indicating the current state ("Enabled" or "Disabled").
2. WHEN the user toggles the sound switch, THE Settings_Controller SHALL persist the new boolean value to local storage within 500 milliseconds.
3. IF no persisted sound preference record exists, THEN THE Settings_Controller SHALL default sound enabled to true.
4. WHEN the app is reopened after the user previously changed the sound preference, THE Settings_Screen SHALL display the switch in the last persisted position.
5. IF persistence of the sound preference fails, THEN THE Settings_Screen SHALL display a snackbar with an error message indicating the preference was not saved and SHALL revert the toggle to its previous position.

### Requirement 5: Configure Theme Mode

**User Story:** As a user, I want to choose between system, light, and dark appearance, so that the app matches my visual preference or follows my device setting.

#### Acceptance Criteria

1. THE Settings_Screen SHALL display a selector for theme mode with exactly three options — System, Light, and Dark — within an "Appearance" section, with the currently active mode visually indicated.
2. WHEN the user selects System, THE Settings_Controller SHALL update the App_Settings.themeMode to AppThemeMode.system.
3. WHEN the user selects Light, THE Settings_Controller SHALL update the App_Settings.themeMode to AppThemeMode.light.
4. WHEN the user selects Dark, THE Settings_Controller SHALL update the App_Settings.themeMode to AppThemeMode.dark.
5. WHEN the user changes theme mode, THE application SHALL apply the new mode to the entire widget tree within the same frame, without requiring navigation or restart.
6. WHEN the user changes theme mode, THE Settings_Controller SHALL persist the selection locally so that it is restored on the next app launch.
7. IF no persisted theme mode record exists, THEN THE Settings_Controller SHALL default theme mode to System.
8. IF persisting the theme mode selection fails, THEN THE Settings_Controller SHALL revert to the last successfully persisted theme mode, notify listeners so the application and UI revert to the previously persisted appearance, and display a SnackBar for at least 4 seconds indicating the preference was not saved.
9. WHEN the application launches with a previously persisted theme mode, THE Settings_Screen SHALL display the persisted selection as the active option in the selector.

### Requirement 6: Configure Color Palette

**User Story:** As a user, I want to choose a color palette, so that the application appearance reflects my personal taste.

#### Acceptance Criteria

1. THE Settings_Screen SHALL display a selector for color palette with options Salmon, Light_Blue, and Light_Green within the "Appearance" section.
2. WHEN the user selects a color palette, THE application SHALL apply the new palette to all screens within the current interaction cycle, without requiring a restart or navigation.
3. THE Settings_Controller SHALL persist the selected palette locally. WHEN the application starts, THE Settings_Controller SHALL restore the previously persisted palette. IF no persisted palette exists, THEN THE Settings_Controller SHALL apply the default palette Salmon.
4. THE Settings_Screen SHALL identify each palette option with both a text label and a color preview swatch, so that color is not the sole indicator of the selection.
5. THE Settings_Screen SHALL visually distinguish the currently active palette from the unselected options using a selection indicator (e.g., check mark or border) in addition to any color difference.
6. WHILE the palette selector is displayed, each selectable palette option SHALL meet a minimum touch target size of 48×48dp.
7. IF persisting the palette selection fails, THEN THE Settings_Controller SHALL revert to the last successfully persisted palette, notify listeners so the application and UI revert to the previously persisted appearance, and display a SnackBar for at least 4 seconds indicating the preference was not saved.

### Requirement 7: Pomodoro Integration

**User Story:** As a user, I want updated Pomodoro preferences to take effect on my next session, so that changing settings does not disrupt a session in progress.

#### Acceptance Criteria

1. WHEN a new focus session starts from idle or completed state, THE Pomodoro_Controller SHALL use the currently configured focus duration from Settings_Controller as the countdown duration for that session.
2. WHEN a new short break starts from idle or completed state, THE Pomodoro_Controller SHALL use the currently configured short break duration from Settings_Controller as the countdown duration for that break.
3. WHEN a new long break starts from idle or completed state, THE Pomodoro_Controller SHALL use the currently configured long break duration from Settings_Controller as the countdown duration for that break.
4. THE Pomodoro_Controller SHALL compare the current Cycle_Count against the currently configured cycles-before-long-break value from Settings_Controller at the moment a Focus_Session completes, so that a mid-cycle change to this setting takes effect on the very next mode transition.
5. WHILE the Pomodoro timer is in running or paused state, THE Pomodoro_Controller SHALL retain its current remaining duration, Target_End_Time, Timer_Mode, Cycle_Count, and selected task association unchanged regardless of settings changes arriving via the update mechanism.
6. WHEN the user resets the timer, THE Pomodoro_Controller SHALL set the remaining duration to the currently configured duration for the active Timer_Mode from Settings_Controller.
7. WHEN the Settings_Controller updates Pomodoro duration values and the Timer_Status is Idle or Completed, THE Pomodoro_Controller SHALL update the displayed remaining duration to the currently configured duration for the current Timer_Mode, so the user sees the new value reflected immediately.
8. WHEN the Pomodoro_Controller receives an updated configuration, THE Pomodoro_Controller SHALL replace the entire PomodoroConfig atomically as a single unit and SHALL NOT reset the Cycle_Count, Timer_Status, or selected task association.
9. IF the Settings_Controller provides a duration value that differs from the previous configuration while the Timer_Status is Running or Paused, THEN THE Pomodoro_Controller SHALL defer applying that duration until the next session start, reset, or transition to Idle or Completed state.

### Requirement 8: Navigation Integration

**User Story:** As a user, I want to access Settings from the bottom navigation bar, so that I can find preferences easily without extra navigation steps.

#### Acceptance Criteria

1. THE Navigation_Bar SHALL display exactly four destinations in this fixed order: Todo (index 0), Pomodoro (index 1), Statistics (index 2), Settings (index 3).
2. THE Settings destination SHALL use Icons.settings_outlined when unselected and Icons.settings when selected, and SHALL display the label "Settings" beneath the icon.
3. WHEN the user taps the Settings destination, THE HomeScreen SHALL display the Settings_Screen at index 3 in the IndexedStack, preserving the widget state of all other tabs (Todo, Pomodoro, Statistics).
4. WHEN the route /settings is navigated to directly, THE application SHALL render the Settings_Screen as a standalone page without the Home Navigation_Bar.
5. WHILE the Settings tab is displayed in the IndexedStack, THE system SHALL keep the Settings destination visually indicated as selected via both the filled icon (Icons.settings) and the Material 3 NavigationBar selection indicator.
6. IF the user taps the already-selected Settings destination, THEN THE system SHALL remain on the Settings tab without rebuilding the Settings_Screen widget or resetting its scroll position.

### Requirement 9: Settings Screen Layout and Feedback

**User Story:** As a user, I want the settings screen to be organized and responsive, so that I can find and modify preferences quickly.

#### Acceptance Criteria

1. THE Settings_Screen SHALL display a Material 3 AppBar with the title "Settings".
2. THE Settings_Screen SHALL organize controls into visually grouped sections displayed in the following order from top to bottom: Pomodoro, Appearance, Sound, where each section is preceded by a visible text header identifying the section name.
3. THE Settings_Screen SHALL use Theme.of(context) for all colors and text styles with no hardcoded color values.
4. THE Settings_Screen SHALL support text scaling up to 200 percent without content overflow or clipping on screens with a width of 360dp or greater.
5. WHEN a value is changed, THE Settings_Screen SHALL reflect the new value in the corresponding control within the same frame rebuild (before the next user interaction is possible).
6. IF the Settings_Repository fails to save a change, THEN THE Settings_Screen SHALL revert the affected control to its previous persisted value and display a SnackBar lasting at least 4 seconds informing the user in plain language that the change was not saved.
7. THE Settings_Screen SHALL render its content within a vertically scrollable container so that all sections and controls remain reachable without overflow on screens with a height of 592dp or greater at 200 percent text scaling.

### Requirement 10: Accessibility

**User Story:** As a user relying on assistive technology, I want all settings controls to be properly labeled and sized, so that I can configure preferences without difficulty.

#### Acceptance Criteria

1. THE Settings_Screen SHALL provide a visible text label and a programmatic Semantics label on every interactive control, including custom widgets that lack built-in Material semantics.
2. THE Settings_Screen SHALL ensure all interactive touch targets are at least 48 by 48 density-independent pixels.
3. THE Settings_Screen SHALL maintain a top-to-bottom focus traversal order that matches the visual layout order of controls within each section.
4. THE Settings_Screen SHALL distinguish each palette option using both a color swatch and a paired text name, and SHALL convey the selected state to assistive technology via a Semantics annotation indicating whether the option is selected or unselected.
5. THE Settings_Screen SHALL maintain a minimum contrast ratio of 4.5:1 for body text and 3:1 for large text (WCAG 2.1 AA), and SHALL not use font sizes below 12sp for any visible text.
6. WHEN a control changes state (enabled, disabled, selected, or unselected), THE Settings_Screen SHALL announce the updated state to assistive technology so that the change is perceivable without visual confirmation.

### Requirement 11: Error Handling

**User Story:** As a user, I want clear feedback when something goes wrong loading or saving settings, so that I am never left confused about the state of my preferences.

#### Acceptance Criteria

1. WHILE settings are being loaded AND the load operation exceeds 300 milliseconds, THE Settings_Screen SHALL display a CircularProgressIndicator centered on the screen.
2. IF loading settings fails due to a read error, THEN THE Settings_Screen SHALL display a plain-language error message (without technical details such as exception names or stack traces) and a Retry button that re-initiates the load operation when tapped.
3. IF the settings record is absent (never previously saved), THEN THE Settings_Screen SHALL apply default values silently without displaying an error.
4. IF saving a setting fails, THEN THE Settings_Screen SHALL revert the affected control to its last successfully persisted value and display a SnackBar for at least 4 seconds indicating which setting could not be saved.
5. IF a save or load operation fails, THEN THE Settings_Controller SHALL preserve the last successfully persisted state and SHALL NOT overwrite valid persisted settings with default values.

### Requirement 12: Provider Scope and Lifecycle

**User Story:** As a developer, I want the settings controller to live at application scope, so that theme and preference changes propagate globally and survive navigation.

#### Acceptance Criteria

1. THE Settings_Controller SHALL be provided above the MaterialApp widget in the provider tree so that MaterialApp can consume the current theme from it.
2. THE Settings_Controller SHALL share a single instance (object identity) between the HomeScreen Settings tab and the direct /settings route.
3. WHILE the user navigates between tabs or pushes and pops routes, THE Settings_Controller SHALL remain alive and not be disposed for the entire application lifecycle.
4. WHEN the application starts, THE Settings_Controller SHALL complete loading persisted settings before MaterialApp builds its first frame, ensuring no visible theme transition occurs.
5. WHEN the Settings_Controller notifies a change, THE PomodoroController SHALL receive the updated settings values via ChangeNotifierProxyProvider so that active timer configuration reflects current preferences.

## Open Questions

1. ~~**Default color palette**~~: **RESOLVED** — The default palette is Salmon (maps to "Warm", listed first in ui-philosophy.md).
2. ~~**Palette naming reconciliation**~~: **RESOLVED** — The mapping is: Warm → Salmon, Ocean → Light Blue, Nature → Light Green. The enum uses the product names (salmon, lightBlue, lightGreen) since those are user-facing labels.
3. ~~**Exact color seed values**~~: **RESOLVED** — Salmon: 0xFFE57373 (Material red-300), Light Blue: 0xFF4FC3F7 (Material lightBlue-300), Light Green: 0xFF81C784 (Material green-300).
