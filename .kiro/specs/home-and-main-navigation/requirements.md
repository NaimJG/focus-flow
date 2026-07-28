# Requirements Document

## Introduction

Focus Flow needs a main application shell that unifies its three core features — Todo, Pomodoro, and Statistics — under a single navigation structure. The HomeScreen provides a Material 3 bottom NavigationBar allowing users to switch between tabs while preserving each feature's state. This replaces the current routing where `/` directly loads the Statistics screen.

## Glossary

- **HomeScreen**: The root application shell widget that hosts the NavigationBar and renders feature tabs.
- **NavigationBar**: The Material 3 `NavigationBar` widget providing bottom tab navigation.
- **IndexedStack**: A Flutter widget that renders all children but only displays one, preserving the state of hidden children.
- **Tab**: One of the three navigable destinations in the NavigationBar (Todo, Pomodoro, Statistics).
- **StatisticsTabHost**: A StatefulWidget responsible for lazily creating, providing, and disposing the StatisticsController within the HomeScreen lifecycle.
- **TodoController**: The app-scoped ChangeNotifier managing all todo state (tasks, categories, filters, search, sort).
- **PomodoroController**: The app-scoped ChangeNotifier managing Pomodoro timer state and session persistence.
- **StatisticsController**: A route-scoped ChangeNotifier managing statistics data loading and display state.
- **Direct_Route**: A named route (e.g., `/todo`, `/pomodoro`, `/statistics`) that renders a feature screen without the NavigationBar shell.
- **Root_Navigator**: The single application-level Navigator provided by MaterialApp.

## Requirements

### Requirement 1: HomeScreen Shell

**User Story:** As a user, I want a single home screen with bottom navigation, so that I can quickly switch between Todo, Pomodoro, and Statistics without losing my place.

#### Acceptance Criteria

1. WHEN the application launches, THE HomeScreen SHALL display with the Todo tab selected as the default destination and the Todo feature screen visible.
2. THE HomeScreen SHALL render a Material 3 NavigationBar with exactly three destinations in the following order: Todo (checklist icon, label "Todo"), Pomodoro (timer icon, label "Pomodoro"), and Statistics (bar-chart icon, label "Statistics").
3. WHEN the user taps a NavigationBar destination, THE HomeScreen SHALL display the corresponding feature screen and visually indicate the selected destination as active using the NavigationBar's built-in selection state.
4. THE HomeScreen SHALL preserve the widget state of each feature screen (including scroll position, form input, and timer progress) when the user switches to a different tab, so that returning to a previously visited tab restores it to its last state without reloading.
5. THE HomeScreen SHALL use `Theme.of(context)` for all visual styling and SHALL NOT hardcode any colors.
6. THE HomeScreen SHALL respect SafeArea boundaries on all device configurations.
7. THE HomeScreen SHALL default to the Todo tab on every fresh application start without persisting the previously selected tab across app restarts.
8. THE HomeScreen NavigationBar SHALL provide a Semantics label on each destination icon describing its purpose, and each destination touch target SHALL be at least 48×48dp.
9. IF any feature screen fails to load or throws an error during tab display, THEN THE HomeScreen SHALL continue to display the NavigationBar and show an error message within the content area indicating the feature could not be loaded, without crashing the entire application.

### Requirement 2: Navigation Destinations

**User Story:** As a user, I want clearly labeled navigation destinations with recognizable icons, so that I can identify each section at a glance.

#### Acceptance Criteria

1. THE NavigationBar SHALL display exactly three destinations in the following fixed order from left to right: Todo, Pomodoro, Statistics.
2. THE NavigationBar SHALL display the Todo destination with a checklist icon (`Icons.checklist` for selected, `Icons.checklist_outlined` for unselected) and the label "Todo".
3. THE NavigationBar SHALL display the Pomodoro destination with a timer icon (`Icons.timer` for selected, `Icons.timer_outlined` for unselected) and the label "Pomodoro".
4. THE NavigationBar SHALL display the Statistics destination with a bar chart icon (`Icons.bar_chart` for selected, `Icons.bar_chart_outlined` for unselected) and the label "Statistics".
5. THE NavigationBar SHALL differentiate the selected destination from unselected destinations using both a filled icon variant (selected) versus an outlined icon variant (unselected) and the Material 3 `ColorScheme` selection indicator, so that the distinction does not rely on color alone.
6. THE NavigationBar SHALL provide a semantic label for each destination that includes the destination name so that screen readers can announce identity and context.
7. THE NavigationBar SHALL provide touch targets of at least 48×48dp for each destination.

### Requirement 3: Tab State Preservation

**User Story:** As a user, I want my progress in each tab preserved when I switch tabs, so that I do not lose my scroll position, active filters, or timer state.

#### Acceptance Criteria

1. WHEN the user switches from the Todo tab to another tab and back, THE HomeScreen SHALL preserve the Todo screen's scroll position, search query text, active category filter selection, and sort field and direction settings.
2. WHEN the user switches from the Pomodoro tab to another tab and back, THE HomeScreen SHALL preserve the Pomodoro timer's current state (running, paused, or idle), remaining time, and selected task association.
3. WHEN the user switches from the Statistics tab to another tab and back, THE HomeScreen SHALL preserve the Statistics screen's selected period (Today, This Week, or This Month) and most recently loaded summary, chart, and breakdown data without triggering a re-fetch.
4. THE HomeScreen SHALL use an IndexedStack (or equivalent offstage-preserving mechanism) so that feature screen widget subtrees are built once and kept alive across tab switches, rather than being recreated on each tab selection.
5. WHILE the Pomodoro timer is in the running state, THE HomeScreen SHALL allow the timer countdown to continue uninterrupted regardless of which tab is currently visible to the user.

### Requirement 4: Pomodoro Timer Lifecycle

**User Story:** As a user, I want my Pomodoro timer to keep running when I switch to another tab, so that I can check my tasks or statistics without interrupting a focus session.

#### Acceptance Criteria

1. WHILE the Pomodoro timer is in Running status, THE PomodoroController SHALL continue decrementing the remaining duration at 1-second intervals regardless of which tab is currently visible.
2. WHEN the user navigates away from the Pomodoro tab, THE HomeScreen SHALL NOT pause, reset, skip, or dispose the PomodoroController.
3. THE HomeScreen SHALL NOT create a second instance of PomodoroController; it SHALL use the existing app-scoped instance provided at initialization.
4. WHEN the user returns to the Pomodoro tab, THE PomodoroScreen SHALL display the current remaining duration, timer status, current mode, and cycle count matching the live PomodoroController state.
5. WHILE the Pomodoro timer is in Running status and the user switches tabs, THE system SHALL NOT reset the cycle count, selected task association, or session start timestamp.

### Requirement 5: Statistics Tab Host

**User Story:** As a user, I want the Statistics tab to load efficiently, so that it does not slow down application startup or consume resources until I actually view it.

#### Acceptance Criteria

1. WHEN the Statistics tab is displayed for the first time during the HomeScreen lifecycle, THE StatisticsTabHost SHALL create exactly one StatisticsController instance and call its `init()` method.
2. WHILE TodoController.isLoading is true at the time the Statistics tab is first selected, THE StatisticsTabHost SHALL display a centered CircularProgressIndicator and SHALL NOT create the StatisticsController until TodoController.isLoading becomes false.
3. WHEN the StatisticsController is created, THE StatisticsTabHost SHALL provide it to the StatisticsScreen widget tree via ChangeNotifierProvider.
4. WHILE the HomeScreen remains mounted after the StatisticsController has been created, THE StatisticsTabHost SHALL preserve the same StatisticsController instance across all subsequent tab switches away from and back to the Statistics tab, creating no additional instances.
5. WHEN the HomeScreen is disposed, THE StatisticsTabHost SHALL call dispose() on the StatisticsController exactly once.
6. WHEN the StatisticsController invokes the taskCategoryMappingProvider callback, THE StatisticsTabHost SHALL read TodoController.allTasks and TodoController.categories at call time and return a List<StatisticsTaskCategoryOption> mapping each task's id and categoryId to its category name.
7. IF the user has never navigated to the Statistics tab during the current HomeScreen lifecycle, THEN THE StatisticsTabHost SHALL NOT instantiate a StatisticsController or any of its use-case dependencies.
8. IF TodoController transitions from isLoading true to false while the Statistics tab is actively displayed and waiting, THEN THE StatisticsTabHost SHALL immediately create the StatisticsController and render the StatisticsScreen without requiring additional user interaction.

### Requirement 6: Routing

**User Story:** As a user, I want the app's URL structure to remain consistent, so that direct routes and deep links work correctly alongside tab navigation.

#### Acceptance Criteria

1. WHEN the route `/` is requested, THE Router SHALL display the HomeScreen.
2. WHEN the route `/todo` is requested as a standalone navigation, THE Router SHALL display the TodoScreen as a full-page route without a NavigationBar.
3. WHEN the route `/pomodoro` is requested as a standalone navigation, THE Router SHALL display the PomodoroScreen as a full-page route without a NavigationBar.
4. WHEN the route `/statistics` is requested as a standalone navigation, THE Router SHALL display the StatisticsScreen wrapped in the statistics loading guard that defers controller creation until TodoController has completed its initial load.
5. WHEN an unknown route is requested (any path not matching defined routes), THE Router SHALL display a screen with the text "Page not found".
6. THE Router SHALL preserve existing task and category routes (`/todo/task/new`, `/todo/task/:id/edit`, `/todo/categories`, `/todo/categories/new`) with identical behavior and argument handling as before the HomeScreen introduction.

### Requirement 7: Back Button Behavior

**User Story:** As a user, I want predictable back button behavior, so that I am not confused by unexpected navigation when pressing back.

#### Acceptance Criteria

1. WHEN the user switches between tabs on the HomeScreen, THE HomeScreen SHALL NOT add entries to the Navigator history stack.
2. WHEN the user presses the Android system back button or performs the system back gesture while on the HomeScreen with any tab selected, THE system SHALL exit the application.
3. WHEN the user presses the system back button or the AppBar back button on a task form or category management screen, THE Root_Navigator SHALL pop back to the HomeScreen with the Todo tab still selected and visible.
4. THE HomeScreen SHALL NOT implement custom tab history or tab back-stack navigation.

### Requirement 8: Todo Navigation from Home

**User Story:** As a user, I want to create and edit tasks from the Home screen and return smoothly, so that task management flows naturally from the Todo tab.

#### Acceptance Criteria

1. WHEN the user initiates task creation from the Todo tab, THE TodoScreen SHALL navigate to the task creation route (`/todo/task/new`) using the application's root navigator.
2. WHEN the user initiates task editing from the Todo tab, THE TodoScreen SHALL navigate to the task edit route (`/todo/task/:id/edit`) using the application's root navigator, passing the selected task as route arguments.
3. WHEN the user navigates to category management from the Todo tab, THE TodoScreen SHALL navigate to the categories route (`/todo/categories`) using the application's root navigator.
4. WHEN the user completes or cancels a task form or category screen, THE root navigator SHALL pop back to the HomeScreen with the Todo tab visible, and the Todo tab SHALL preserve its current filter selections, sort criterion, sort direction, search query, and scroll position.
5. THE HomeScreen SHALL NOT use nested Navigators for tab content.
6. WHEN the user returns to the Todo tab after completing task creation or editing, THE TodoScreen SHALL reflect the created or modified task in the displayed task list without requiring manual refresh.

### Requirement 9: Home State Management

**User Story:** As a user, I want the tab selection to be simple and immediate, so that switching tabs feels instantaneous with no loading delays.

#### Acceptance Criteria

1. THE HomeScreen SHALL be a StatefulWidget that manages the selected tab index as a single private integer field with a valid range of 0 to 2.
2. WHEN the user taps a navigation destination, THE HomeScreen SHALL update the selected index via setState and display the corresponding screen widget within the same frame.
3. IF the user taps the navigation destination that is already selected, THEN THE HomeScreen SHALL remain on the current screen without triggering a rebuild of the displayed content.
4. THE HomeScreen SHALL define destination configuration (icons, labels) as an immutable const list, with each destination specifying both a filled icon (selected state) and an outlined icon (unselected state).
5. THE HomeScreen SHALL NOT persist the selected tab index across application restarts; on every app launch the selected index SHALL default to 0 (the Todo destination).

### Requirement 10: Architecture Constraints

**User Story:** As a developer, I want the Home feature to follow the project's feature-first architecture, so that it integrates cleanly without violating dependency rules.

#### Acceptance Criteria

1. THE Home feature SHALL be located at `lib/features/home/` with only a `presentation/` layer containing `screens/` and `widgets/` subdirectories and SHALL NOT contain `domain/` or `data/` directories.
2. THE Home feature's Dart files SHALL only import from `lib/shared/`, `lib/core/`, `lib/app/`, and other features' `presentation/` layers — never from another feature's `data/` or `domain/` layers.
3. THE HomeScreen SHALL instantiate other feature screens (TodoScreen, PomodoroScreen, StatisticsScreen) in its widget tree for rendering within the tab layout, importing only from those features' `presentation/screens/` directories.
4. WHEN the HomeScreen builds its statistics tab content, THE system SHALL obtain TodoController and PomodoroSessionRepository from the existing app-level Provider tree via `context.read` or `context.watch` without creating new instances.
5. THE HomeScreen widget SHALL be placed as a child of the existing MultiProvider defined in `app.dart` (via the router) so that all app-scoped providers (TodoController, PomodoroController, PomodoroSessionRepository) are accessible to the Home feature without additional provider setup.

### Requirement 11: AppBar and Nested Scaffolds

**User Story:** As a user, I want each tab to display its own toolbar without a redundant second toolbar from the Home shell, so that the interface remains clean and functional.

#### Acceptance Criteria

1. THE HomeScreen Scaffold SHALL NOT set an `appBar` property, ensuring no toolbar is rendered above the feature tab content.
2. EACH tab screen (TodoScreen, PomodoroScreen, StatisticsScreen) SHALL render its own Scaffold with its own AppBar, resulting in exactly one AppBar visible per tab at any time.
3. WHILE nested Scaffolds are used, THE HomeScreen SHALL ensure that SnackBars appear above the bottom NavigationBar within the active tab's Scaffold bounds, FloatingActionButtons render within the tab area without being occluded by the NavigationBar, and RefreshIndicators trigger and display within the tab's scrollable content area.
4. IF a SnackBar or FloatingActionButton is triggered within a tab screen, THEN THE system SHALL scope it to that tab's Scaffold so that it does not appear on other tabs or overlap the HomeScreen's NavigationBar.

### Requirement 12: Loading and Error Handling

**User Story:** As a user, I want each tab to manage its own loading and error states independently, so that an issue in one tab does not affect the others.

#### Acceptance Criteria

1. THE HomeScreen SHALL NOT display a global loading indicator for feature data.
2. WHILE TodoController is loading AND the task list is empty, THE TodoScreen SHALL display a centered CircularProgressIndicator within its own Scaffold.
3. WHILE PomodoroController is loading, THE PomodoroScreen SHALL display a centered CircularProgressIndicator with a "Pomodoro" AppBar within its own Scaffold.
4. WHILE TodoController is loading AND StatisticsController has not yet been created, THE StatisticsTabHost SHALL display a centered CircularProgressIndicator with a "Statistics" AppBar within its own Scaffold.
5. WHEN TodoController finishes loading, THE StatisticsTabHost SHALL create the StatisticsController and display the StatisticsScreen.
6. WHILE StatisticsController is loading, THE StatisticsScreen SHALL display a centered CircularProgressIndicator below the period selector.
7. IF StatisticsController encounters a data retrieval error, THEN THE StatisticsScreen SHALL display an error message in plain language and a "Retry" FilledButton that re-invokes the data load.
8. IF StatisticsController completes loading with no sessions for the selected period, THEN THE StatisticsScreen SHALL display an empty state message explaining that no focus sessions exist and guiding the user to complete a Pomodoro session.
9. IF TodoController encounters a data retrieval error while tasks are already displayed, THEN THE TodoScreen SHALL display a transient SnackBar with an error message and a "Reload" action.
10. IF PomodoroController encounters a persistence error, THEN THE PomodoroScreen SHALL display a transient SnackBar with an error message and a "Retry" action.

### Requirement 13: Accessibility

**User Story:** As a user with accessibility needs, I want the navigation to be fully accessible, so that I can use the app effectively with assistive technologies.

#### Acceptance Criteria

1. THE NavigationBar SHALL provide text labels on all destinations (no icon-only destinations).
2. THE NavigationBar SHALL expose the selected state of each destination to the accessibility framework via a semantic property that screen readers can announce.
3. WHILE the system font scale is set between 100% and 200% inclusive, THE NavigationBar SHALL render all destination labels without text truncation, overflow, or overlapping of adjacent elements.
4. THE NavigationBar destinations SHALL maintain a minimum touch target size of 48×48dp.
5. THE HomeScreen SHALL maintain a logical focus order traversing the NavigationBar destinations from left to right.
6. THE NavigationBar SHALL indicate the selected destination through both a visual indicator (e.g., filled icon or background shape) and a text label distinction, such that selection is never communicated by color alone.

### Requirement 14: Presentation Constraints

**User Story:** As a developer, I want the NavigationBar implementation to follow Material 3 standards strictly, so that the app looks consistent and adapts to theme changes automatically.

#### Acceptance Criteria

1. THE HomeScreen SHALL use the Material 3 `NavigationBar` widget, not the legacy `BottomNavigationBar`.
2. THE NavigationBar SHALL use the `selectedIndex` property to reflect the currently active tab, where the index value corresponds to the zero-based position of the active destination.
3. THE NavigationBar SHALL derive all colors (indicator color, icon color, label color, surface color) exclusively from the current theme's `ColorScheme` via `Theme.of(context)`, with no hardcoded color values in widget code.
4. THE HomeScreen SHALL render all NavigationBar destinations and content without overflow on portrait phone layouts with a minimum width of 360dp.
5. THE HomeScreen SHALL NOT introduce custom entrance, exit, or transition animations for tab switches; tab content SHALL appear immediately upon selection.
6. WHEN the application theme changes at runtime, THEN THE NavigationBar SHALL update all its colors to match the new theme's `ColorScheme` without requiring a screen rebuild or navigation event.

### Requirement 15: Out of Scope

**User Story:** As a developer, I want clear boundaries on what this feature excludes, so that scope creep does not delay delivery.

#### Acceptance Criteria

1. THE HomeScreen SHALL NOT include a settings tab, theme picker, or any navigation destination beyond Todo, Pomodoro, and Statistics (exactly 3 destinations).
2. THE HomeScreen SHALL NOT implement a tablet navigation rail, desktop navigation drawer, or any layout adaptation beyond mobile portrait orientation.
3. THE HomeScreen SHALL NOT implement persisted tab selection across app restarts, nested Navigators per tab, or user-configurable tab ordering.
4. THE HomeScreen SHALL NOT implement onboarding flows, authentication gates, notification prompts, achievement displays, subscription paywalls, ad placements, or cloud synchronization UI.
5. THE HomeScreen SHALL NOT implement deep-link state restoration beyond the existing named routes defined in `app/router.dart`.
