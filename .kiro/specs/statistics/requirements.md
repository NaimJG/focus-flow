# Requirements Document

## Introduction

The Statistics feature provides users with insights into their focused work habits by deriving productivity metrics from completed Pomodoro sessions. It presents summary metrics, daily activity visualizations, and breakdowns by task and category — all computed on-device from existing persisted session data without introducing new persistent collections.

## Glossary

- **Statistics_Screen**: The presentation screen at route `/statistics` that displays all statistics data.
- **Statistics_Controller**: A `ChangeNotifier` managing state for the Statistics feature, exposing computed metrics, loading state, and error state.
- **Period_Selector**: A segmented control allowing the user to choose between Today, This Week, and This Month summary periods.
- **Statistics_Period**: An enumeration representing the selectable time periods: Today, This Week, This Month.
- **Date_Range_Calculator**: A use case that computes UTC-based query boundaries from a selected Statistics_Period and the current local time.
- **Clock**: An injectable abstraction over system time, returning UTC timestamps, enabling deterministic testing.
- **Summary_Calculator**: A use case that computes aggregate metrics (total focused time, session count, average session duration) from a list of Pomodoro sessions.
- **Daily_Grouper**: A use case that groups sessions by local calendar day and produces daily activity data with zero-fill for days without sessions.
- **Task_Grouper**: A use case that groups sessions by task, producing per-task totals, counts, and percentages.
- **Category_Grouper**: A use case that resolves each session's category via a task-to-category mapping and produces per-category totals.
- **Focus_Session**: A completed Pomodoro Focus session as persisted in the existing PomodoroSessionRepository (uses `actualDurationSeconds` for focused time).
- **Task_Category_Mapping**: A read-only data structure provided at the application level (app.dart) that maps taskId to categoryId and categoryName for cross-feature resolution.
- **Daily_Activity_Bar**: A vertical bar in the daily visualization representing total focused seconds for one calendar day.

## Requirements

### Requirement 1: Period Selection

**User Story:** As a user, I want to select a summary period (Today, This Week, This Month) so that I can view statistics scoped to a meaningful time range.

#### Acceptance Criteria

1. WHEN the Statistics_Screen is first displayed, THE Period_Selector SHALL default to the Today period.
2. WHEN the user selects a different Statistics_Period, THE Statistics_Controller SHALL update the displayed data to reflect the newly selected period.
3. THE Period_Selector SHALL display exactly three options: Today, This Week, and This Month.
4. WHEN the user selects a period, THE Statistics_Controller SHALL set the loading state to true before fetching data.
5. WHEN data loading completes successfully after a period change, THE Statistics_Controller SHALL set the loading state to false and notify listeners.

### Requirement 2: Date Range Calculation

**User Story:** As a developer, I want date ranges calculated deterministically from a period and a clock so that queries are correct across time zones and testable without real time.

#### Acceptance Criteria

1. WHEN the Today period is selected, THE Date_Range_Calculator SHALL compute a start equal to the start of the current local calendar day converted to UTC and an end equal to the start of the next local calendar day converted to UTC.
2. WHEN the This Week period is selected, THE Date_Range_Calculator SHALL compute a start equal to the most recent Monday at 00:00 local time converted to UTC and an end equal to the following Monday at 00:00 local time converted to UTC.
3. WHEN the This Month period is selected, THE Date_Range_Calculator SHALL compute a start equal to the first day of the current month at 00:00 local time converted to UTC and an end equal to the first day of the next month at 00:00 local time converted to UTC.
4. THE Date_Range_Calculator SHALL accept a Clock dependency for obtaining the current time.
5. WHEN December is the current month, THE Date_Range_Calculator SHALL compute the end date as January 1 of the following year at 00:00 local time converted to UTC.

### Requirement 3: Summary Metrics

**User Story:** As a user, I want to see total focused time, session count, and average session duration so that I understand my overall productivity for the selected period.

#### Acceptance Criteria

1. THE Summary_Calculator SHALL compute total focused time as the sum of `actualDurationSeconds` across all Focus_Sessions in the date range.
2. THE Summary_Calculator SHALL compute session count as the number of Focus_Sessions in the date range.
3. WHEN the session count is greater than zero, THE Summary_Calculator SHALL compute average session duration as total focused time divided by session count using integer arithmetic.
4. WHEN the session count is zero, THE Summary_Calculator SHALL report average session duration as zero.
5. WHEN total focused time is less than 60 minutes, THE Statistics_Screen SHALL format the duration as "{minutes} min" (e.g., "45 min").
6. WHEN total focused time is 60 minutes or more, THE Statistics_Screen SHALL format the duration as "{hours} h {minutes} min" (e.g., "2 h 15 min").
7. WHEN total focused time is zero, THE Statistics_Screen SHALL display "0 min".

### Requirement 4: Daily Activity Grouping

**User Story:** As a user, I want to see my focused activity grouped by day so that I can identify patterns in my daily work habits.

#### Acceptance Criteria

1. THE Daily_Grouper SHALL group Focus_Sessions by local calendar day using each session's `startedAt` timestamp converted from UTC to local time.
2. THE Daily_Grouper SHALL produce a list containing one entry per calendar day in the period, including days with zero sessions.
3. WHEN the Today period is selected, THE Daily_Grouper SHALL produce exactly one entry for the current local calendar day.
4. WHEN the This Week period is selected, THE Daily_Grouper SHALL produce exactly seven entries from Monday through Sunday, zero-filled for days without sessions.
5. WHEN the This Month period is selected, THE Daily_Grouper SHALL produce one entry for each calendar day of the current month, zero-filled for days without sessions.
6. THE Daily_Grouper SHALL compute total focused seconds and completed session count for each calendar day.

### Requirement 5: Daily Activity Visualization

**User Story:** As a user, I want to see a bar chart of daily activity so that I can visually compare my focus across days.

#### Acceptance Criteria

1. THE Statistics_Screen SHALL display daily activity as a horizontal row of vertical bars using only Flutter SDK widgets.
2. THE Statistics_Screen SHALL scale each Daily_Activity_Bar height proportionally to the maximum focused seconds value in the dataset.
3. WHEN all days in the dataset have zero focused seconds, THE Statistics_Screen SHALL display all bars at a minimal visible height without performing division by zero.
4. THE Statistics_Screen SHALL display a day or date label below each Daily_Activity_Bar.
5. THE Statistics_Screen SHALL provide a Semantics label or tooltip on each Daily_Activity_Bar indicating the day and total focused time.
6. WHEN a day has zero focused seconds, THE Statistics_Screen SHALL render the corresponding Daily_Activity_Bar at a distinguishable minimal height.

### Requirement 6: Task Breakdown

**User Story:** As a user, I want to see focused time grouped by task so that I know which tasks consume the most focus time.

#### Acceptance Criteria

1. THE Task_Grouper SHALL group Focus_Sessions by `taskId`, using `taskTitleSnapshot` as the display title.
2. THE Task_Grouper SHALL aggregate sessions with a null `taskId` into a single group displayed as "No task".
3. THE Task_Grouper SHALL compute total focused seconds, session count, and percentage of total focused time for each group.
4. THE Task_Grouper SHALL sort groups by total focused seconds descending; groups with equal focused seconds SHALL be sorted by display title alphabetically.
5. THE Statistics_Screen SHALL display each task breakdown item with title, formatted time, session count, and a LinearProgressIndicator representing the percentage.
6. WHEN a task title exceeds available horizontal space, THE Statistics_Screen SHALL truncate the title with ellipsis using TextOverflow.ellipsis.

### Requirement 7: Category Breakdown

**User Story:** As a user, I want to see focused time grouped by category so that I understand how my work distributes across different areas.

#### Acceptance Criteria

1. THE Category_Grouper SHALL resolve each session's category by looking up the session's `taskId` in the Task_Category_Mapping provided at the application level.
2. WHEN a session has no `taskId` or the `taskId` is not found in the Task_Category_Mapping, THE Category_Grouper SHALL assign the session to the "Uncategorized" group.
3. THE Category_Grouper SHALL compute total focused seconds, session count, and percentage of total focused time for each category group.
4. THE Category_Grouper SHALL sort groups by total focused seconds descending.
5. THE Statistics_Screen SHALL display each category breakdown item with category name, formatted time, session count, and a LinearProgressIndicator representing the percentage.
6. THE Statistics_Screen SHALL provide the Task_Category_Mapping as a read-only structure defined in app.dart, containing taskId, categoryId, and categoryName fields.

### Requirement 8: State Management and Refresh

**User Story:** As a user, I want statistics to load automatically and refresh on demand so that I always see current data without restarting the app.

#### Acceptance Criteria

1. WHEN the Statistics_Controller is initialized, THE Statistics_Controller SHALL load data for the default period (Today).
2. WHEN the user triggers a manual refresh, THE Statistics_Controller SHALL reload data for the currently selected period.
3. WHEN a refresh completes, THE Statistics_Controller SHALL preserve the currently selected Statistics_Period.
4. THE Statistics_Controller SHALL expose a loading state, an error message, and an empty-state indicator to the presentation layer.
5. WHILE the Statistics_Controller is loading, THE Statistics_Screen SHALL display a loading indicator.
6. WHEN the data loaded contains zero sessions for the selected period, THE Statistics_Controller SHALL set the empty-state indicator to true.

### Requirement 9: Error Handling

**User Story:** As a user, I want to see a clear error message and retry option when data loading fails so that I can recover without leaving the screen.

#### Acceptance Criteria

1. IF data loading fails, THEN THE Statistics_Controller SHALL stop loading, set the error message, and notify listeners.
2. IF data loading fails, THEN THE Statistics_Screen SHALL display a user-friendly error message and a retry action.
3. IF data loading fails, THEN THE Statistics_Controller SHALL preserve the currently selected Statistics_Period.
4. IF data loading fails, THEN THE Statistics_Screen SHALL NOT display stale data from a previous successful load.
5. WHEN the user triggers retry and the retry succeeds, THE Statistics_Controller SHALL clear the error message and display the loaded data.

### Requirement 10: Empty State

**User Story:** As a user, I want to see a helpful message when there is no data for the selected period so that I understand why the screen appears blank.

#### Acceptance Criteria

1. WHEN the empty-state indicator is true, THE Statistics_Screen SHALL display a message explaining that no focus sessions exist for the selected period.
2. WHEN the empty-state indicator is true, THE Statistics_Screen SHALL guide the user toward completing a focus session (informational text, not a navigation action).
3. WHEN the empty-state indicator is true, THE Statistics_Screen SHALL NOT display summary cards, daily visualization, task breakdown, or category breakdown.

### Requirement 11: Navigation and Routing

**User Story:** As a developer, I want the statistics screen registered as a named route so that navigation is consistent with the rest of the application.

#### Acceptance Criteria

1. THE application router SHALL register the route `/statistics` mapping to the Statistics_Screen.
2. WHEN the `/statistics` route is navigated to, THE application SHALL display the Statistics_Screen with its controller properly initialized.
3. THE Statistics_Controller SHALL be scoped to the Statistics_Screen route lifecycle (created on route entry, disposed on route exit) unless provided at the application level.

### Requirement 12: Architecture Constraints

**User Story:** As a developer, I want the Statistics feature to follow feature-first clean architecture so that it remains maintainable and testable.

#### Acceptance Criteria

1. THE Statistics feature SHALL be structured under `lib/features/statistics/` following the established data/domain/presentation layer pattern.
2. THE Statistics domain layer SHALL NOT import from Flutter, Provider, Isar, or other feature data/domain layers.
3. THE Statistics feature SHALL consume the existing PomodoroSessionRepository through domain-level use cases without creating a new Isar collection.
4. THE Statistics feature SHALL define its own domain entities: StatisticsPeriod, StatisticsDateRange, StatisticsSummary, DailyFocusStatistics, TaskFocusStatistics, CategoryFocusStatistics, and StatisticsTaskCategoryOption.
5. THE Statistics feature SHALL store focused time values as integer seconds in domain entities.
6. THE Statistics feature SHALL reuse the existing Clock abstraction from the Pomodoro feature for time injection.

### Requirement 13: Accessibility

**User Story:** As a user with accessibility needs, I want all statistics information to be accessible through screen readers and large text so that I can use the feature effectively.

#### Acceptance Criteria

1. THE Statistics_Screen SHALL provide Semantics labels for all summary cards, including the metric name and formatted value.
2. THE Statistics_Screen SHALL provide Semantics labels or tooltips for each Daily_Activity_Bar, including the day and focused time.
3. THE Statistics_Screen SHALL provide Semantics labels for all percentage values in task and category breakdowns.
4. THE Statistics_Screen SHALL support readable text scaling without layout overflow.
5. THE Statistics_Screen SHALL ensure all interactive touch targets are at least 48×48dp.
6. THE Statistics_Screen SHALL NOT rely solely on color to convey information; all visual indicators SHALL be paired with text or labels.

### Requirement 14: Presentation Layout

**User Story:** As a user, I want the statistics screen to present information in a clear, scannable layout so that I can quickly understand my productivity.

#### Acceptance Criteria

1. THE Statistics_Screen SHALL display an AppBar with the title "Statistics".
2. THE Statistics_Screen SHALL display the Period_Selector below the AppBar as a segmented button control.
3. THE Statistics_Screen SHALL display summary cards showing total focused time, session count, and average session duration.
4. THE Statistics_Screen SHALL display the daily activity visualization below the summary cards.
5. THE Statistics_Screen SHALL display the task breakdown below the daily visualization.
6. THE Statistics_Screen SHALL display the category breakdown below the task breakdown.
7. THE Statistics_Screen SHALL provide a manual refresh mechanism accessible from the screen.
8. THE Statistics_Screen SHALL follow Material 3 design guidelines and consume theme colors exclusively through `Theme.of(context)`.
9. THE Statistics_Screen SHALL use responsive layout constructs and avoid hardcoded widths for content containers.
