# Implementation Plan: Statistics Feature

## Overview

Implementation follows Feature-First Clean Architecture from the inside out: shared infrastructure
refactor first, then domain entities, repository interface, use cases, data layer adapter, state
management (StatisticsController), presentation utilities and widgets, screen, navigation wiring,
and finally all test layers. Each task produces a compilable, self-contained increment. The
`StatisticsController` is route-scoped (created on route entry, disposed on route exit). Cross-feature
category resolution uses a read-only `StatisticsTaskCategoryOption` mapping built at the composition
root from TodoController data. The implementation language is **Dart / Flutter**.

---

## Tasks

### Group 1 — Shared Infrastructure Refactor

- [x] 1. Move Clock to shared location
  - [x] 1.1 Move `Clock` and `SystemClock` from `lib/features/pomodoro/domain/entities/clock.dart` to `lib/core/utils/clock.dart`
    - Copy the file to the new location preserving the same API.
    - Update the original file to re-export from `core/utils/clock.dart` OR update all Pomodoro imports to point to the new location.
    - Verify `flutter analyze` passes with no broken imports.
    - _Requirements: 12.6 / Design: Architecture — Clock Sharing Strategy_

---

### Group 2 — Domain Entities

- [x] 2. Define Statistics domain entities
  - [x] 2.1 Create `lib/features/statistics/domain/entities/statistics_period.dart`
    - Define `enum StatisticsPeriod { today, week, month }`.
    - _Requirements: 1.3, 12.4 / Design: Domain Entities — StatisticsPeriod_

  - [x] 2.2 Create `lib/features/statistics/domain/entities/statistics_date_range.dart`
    - Immutable value object with `const` constructor: `start` (DateTime, UTC inclusive), `end` (DateTime, UTC exclusive).
    - All fields `final`.
    - _Requirements: 2.1, 2.2, 2.3, 12.4 / Design: Domain Entities — StatisticsDateRange_

  - [x] 2.3 Create `lib/features/statistics/domain/entities/focus_session.dart`
    - Statistics-owned DTO with `const` constructor: `startedAt` (DateTime UTC), `actualDurationSeconds` (int), `taskId` (int?), `taskTitleSnapshot` (String?).
    - All fields `final`.
    - _Requirements: 12.4, 12.5 / Design: Domain Entities — FocusSession_

  - [x] 2.4 Create `lib/features/statistics/domain/entities/statistics_summary.dart`
    - Immutable class with `const` constructor: `totalFocusedSeconds` (int), `sessionCount` (int), `averageSessionSeconds` (int).
    - All fields `final`.
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 12.4 / Design: Domain Entities — StatisticsSummary_

  - [x] 2.5 Create `lib/features/statistics/domain/entities/daily_focus_statistics.dart`
    - Immutable class with `const` constructor: `date` (DateTime, local day with time zeroed), `totalFocusedSeconds` (int), `sessionCount` (int).
    - All fields `final`.
    - _Requirements: 4.1, 4.2, 4.6, 12.4 / Design: Domain Entities — DailyFocusStatistics_

  - [x] 2.6 Create `lib/features/statistics/domain/entities/task_focus_statistics.dart`
    - Immutable class with `const` constructor: `taskId` (int?), `displayTitle` (String), `totalFocusedSeconds` (int), `sessionCount` (int), `percentage` (double, 0.0–1.0).
    - All fields `final`.
    - _Requirements: 6.1, 6.2, 6.3, 12.4 / Design: Domain Entities — TaskFocusStatistics_

  - [x] 2.7 Create `lib/features/statistics/domain/entities/category_focus_statistics.dart`
    - Immutable class with `const` constructor: `categoryId` (int?), `displayName` (String), `totalFocusedSeconds` (int), `sessionCount` (int), `percentage` (double, 0.0–1.0).
    - All fields `final`.
    - _Requirements: 7.1, 7.2, 7.3, 12.4 / Design: Domain Entities — CategoryFocusStatistics_

  - [x] 2.8 Create `lib/features/statistics/domain/entities/statistics_task_category_option.dart`
    - Immutable class with `const` constructor: `taskId` (int), `categoryId` (int?), `categoryName` (String?).
    - All fields `final`.
    - _Requirements: 7.1, 7.6, 12.4 / Design: Domain Entities — StatisticsTaskCategoryOption_

---

### Group 3 — Repository Interface

- [ ] 3. Define repository interface
  - [ ] 3.1 Create `lib/features/statistics/domain/repositories/statistics_session_source.dart`
    - Abstract interface class `StatisticsSessionSource` with single method: `Future<List<FocusSession>> getSessionsByDateRange({required DateTime start, required DateTime end})`.
    - Import `FocusSession` from the domain entities.
    - _Requirements: 12.3, 12.4 / Design: Repository Interface — StatisticsSessionSource_

---

### Group 4 — Use Cases

- [ ] 4. Implement use cases
  - [ ] 4.1 Create `lib/features/statistics/domain/use_cases/calculate_date_range_use_case.dart`
    - Constructor-injected `Clock` from `core/utils/clock.dart`.
    - `StatisticsDateRange call(StatisticsPeriod period)` — computes UTC boundaries.
    - Today: start = local today 00:00 → UTC; end = local tomorrow 00:00 → UTC.
    - Week: start = most recent Monday 00:00 local → UTC; end = following Monday 00:00 local → UTC.
    - Month: start = 1st of current month 00:00 local → UTC; end = 1st of next month 00:00 local → UTC.
    - Handle December → January year rollover.
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5 / Design: Use Cases — CalculateDateRangeUseCase_

  - [ ] 4.2 Create `lib/features/statistics/domain/use_cases/get_sessions_by_date_range_use_case.dart`
    - Constructor-injected `StatisticsSessionSource`.
    - `Future<List<FocusSession>> call(StatisticsDateRange range)` — delegates to source with `range.start` and `range.end`.
    - _Requirements: 12.3 / Design: Use Cases — GetSessionsByDateRangeUseCase_

  - [ ] 4.3 Create `lib/features/statistics/domain/use_cases/calculate_summary_use_case.dart`
    - No dependencies (pure computation).
    - `StatisticsSummary call(List<FocusSession> sessions)`.
    - `totalFocusedSeconds` = sum of `actualDurationSeconds`.
    - `sessionCount` = `sessions.length`.
    - `averageSessionSeconds` = `sessionCount > 0 ? totalFocusedSeconds ~/ sessionCount : 0`.
    - _Requirements: 3.1, 3.2, 3.3, 3.4 / Design: Use Cases — CalculateSummaryUseCase_

  - [ ] 4.4 Create `lib/features/statistics/domain/use_cases/group_sessions_by_day_use_case.dart`
    - No dependencies (pure computation).
    - `List<DailyFocusStatistics> call(List<FocusSession> sessions, StatisticsDateRange range)`.
    - Convert range boundaries from UTC to local to determine calendar days.
    - Generate one entry per calendar day (inclusive start, exclusive end).
    - Assign each session to the day matching `startedAt` converted to local.
    - Zero-fill days with no sessions.
    - Return chronologically ordered list.
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6 / Design: Use Cases — GroupSessionsByDayUseCase_

  - [ ] 4.5 Create `lib/features/statistics/domain/use_cases/group_sessions_by_task_use_case.dart`
    - No dependencies (pure computation).
    - `List<TaskFocusStatistics> call(List<FocusSession> sessions)`.
    - Group by `taskId`. Null taskId → single "No task" group.
    - Use `taskTitleSnapshot` from the session with the latest `startedAt` in each group as display title.
    - Compute `totalFocusedSeconds`, `sessionCount`, `percentage` (group / grand total).
    - Sort by `totalFocusedSeconds` descending; ties broken by `displayTitle` alphabetically (case-insensitive).
    - _Requirements: 6.1, 6.2, 6.3, 6.4 / Design: Use Cases — GroupSessionsByTaskUseCase_

  - [ ] 4.6 Create `lib/features/statistics/domain/use_cases/group_sessions_by_category_use_case.dart`
    - No dependencies (pure computation).
    - `List<CategoryFocusStatistics> call(List<FocusSession> sessions, List<StatisticsTaskCategoryOption> taskCategoryMapping)`.
    - Build lookup map from mapping list.
    - Assign sessions: if `taskId` found in map and `categoryId` non-null → that category. Otherwise → "Uncategorized".
    - Compute `totalFocusedSeconds`, `sessionCount`, `percentage` per group.
    - Sort by `totalFocusedSeconds` descending.
    - _Requirements: 7.1, 7.2, 7.3, 7.4 / Design: Use Cases — GroupSessionsByCategoryUseCase_

---

### Group 5 — Data Layer Adapter

- [ ] 5. Implement data layer adapter
  - [ ] 5.1 Create `lib/features/statistics/data/repositories/statistics_session_adapter.dart`
    - Implements `StatisticsSessionSource`.
    - Constructor-injected `PomodoroSessionRepository` (from Pomodoro feature's domain layer).
    - `getSessionsByDateRange`: delegates to `PomodoroSessionRepository.getByDateRange`, filters to focus-mode sessions only (`timerMode == TimerMode.focus`), maps `PomodoroSession` → `FocusSession`.
    - _Requirements: 12.3 / Design: Data Layer — StatisticsSessionAdapter_

---

### Group 6 — State Management

- [ ] 6. Implement StatisticsController
  - [ ] 6.1 Create `lib/features/statistics/presentation/controllers/statistics_controller.dart`
    - `extends ChangeNotifier`. Constructor parameters: all six use cases + `List<StatisticsTaskCategoryOption> taskCategoryMapping`.
    - State: `_selectedPeriod` (default: today), `_dateRange`, `_summary`, `_dailyActivity`, `_taskBreakdown`, `_categoryBreakdown`, `_isLoading`, `_errorMessage`, `_isEmpty`.
    - Public getters for all state fields.
    - `init()`: loads data for default period (Today).
    - `changePeriod(StatisticsPeriod)`: updates selected period, reloads data.
    - `refresh()`: reloads data for current period.
    - `retry()`: alias for refresh — retry after error.
    - `_loadData()`: set loading true → compute date range → fetch sessions → if empty set isEmpty true → else compute summary, daily, task, category breakdowns → set loading false → notify. On exception: set error message, clear computed data (no stale data), set loading false, notify.
    - Period is preserved through errors and refreshes.
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3 / Design: StatisticsController_

---

### Group 7 — Presentation Utility

- [ ] 7. Implement duration formatter
  - [ ] 7.1 Create `lib/features/statistics/presentation/utils/duration_formatter.dart`
    - Pure function `String formatDuration(int totalSeconds)`.
    - 0 seconds → "0 min".
    - 1–3599 seconds → "{minutes} min" (e.g., "45 min").
    - 3600+ seconds → "{hours} h {minutes} min" (e.g., "2 h 15 min").
    - _Requirements: 3.5, 3.6, 3.7 / Design: Presentation — DurationFormatter_

---

### Group 8 — Presentation Widgets

- [ ] 8. Implement presentation widgets
  - [ ] 8.1 Create `lib/features/statistics/presentation/widgets/period_selector.dart`
    - Stateless widget. Parameters: `selectedPeriod` (StatisticsPeriod), `onPeriodChanged` (ValueChanged<StatisticsPeriod>).
    - Renders `SegmentedButton<StatisticsPeriod>` with three segments: Today, This Week, This Month.
    - Accessible: each segment has a label readable by screen readers.
    - _Requirements: 1.1, 1.2, 1.3, 14.2 / Design: Presentation Widgets — PeriodSelector_

  - [ ] 8.2 Create `lib/features/statistics/presentation/widgets/summary_cards_row.dart`
    - Stateless widget. Parameters: `summary` (StatisticsSummary).
    - Three Material 3 `Card` widgets in a `Row` (using `Expanded`): Total Time, Sessions, Average.
    - Uses `formatDuration` for time values.
    - Provides `Semantics` labels for each card with metric name and formatted value.
    - Colors via `Theme.of(context)`.
    - _Requirements: 3.5, 3.6, 3.7, 13.1, 14.3 / Design: Presentation Widgets — SummaryCardsRow_

  - [ ] 8.3 Create `lib/features/statistics/presentation/widgets/daily_activity_chart.dart`
    - Stateless widget. Parameters: `dailyData` (List<DailyFocusStatistics>).
    - Horizontal `Row` of vertical bars with proportional heights.
    - Bar height formula: `minBarHeight + (fraction * (maxBarHeight - minBarHeight))`. Max bar height fixed (e.g., 120dp).
    - When all values are zero: bars at minimal height (e.g., 4dp), no division by zero.
    - Day/date label below each bar.
    - `Tooltip`/`Semantics` label on each bar with day and formatted time.
    - Uses `Expanded` per bar for responsive width distribution.
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 13.2, 14.4 / Design: Presentation Widgets — DailyActivityChart_

  - [ ] 8.4 Create `lib/features/statistics/presentation/widgets/breakdown_item.dart`
    - Stateless widget. Parameters: `title` (String), `formattedTime` (String), `sessionCount` (int), `percentage` (double).
    - Displays: title (with `TextOverflow.ellipsis`), formatted duration, session count label, `LinearProgressIndicator` with `value = percentage`.
    - Provides `Semantics` label for the percentage value.
    - Touch target >= 48×48dp for accessibility.
    - _Requirements: 6.5, 6.6, 7.5, 13.3 / Design: Presentation Widgets — BreakdownItem_

  - [ ] 8.5 Create `lib/features/statistics/presentation/widgets/task_breakdown_list.dart`
    - Stateless widget. Parameters: `taskData` (List<TaskFocusStatistics>).
    - Renders a `Column` of `BreakdownItem` widgets — one per task group.
    - Uses `formatDuration` for formatted time.
    - Section header: "By Task".
    - _Requirements: 6.5, 14.5 / Design: Presentation Widgets — TaskBreakdownList_

  - [ ] 8.6 Create `lib/features/statistics/presentation/widgets/category_breakdown_list.dart`
    - Stateless widget. Parameters: `categoryData` (List<CategoryFocusStatistics>).
    - Renders a `Column` of `BreakdownItem` widgets — one per category group.
    - Uses `formatDuration` for formatted time.
    - Section header: "By Category".
    - _Requirements: 7.5, 14.6 / Design: Presentation Widgets — CategoryBreakdownList_

---

### Group 9 — Statistics Screen

- [ ] 9. Implement Statistics screen
  - [ ] 9.1 Create `lib/features/statistics/presentation/screens/statistics_screen.dart`
    - `Scaffold` with `AppBar(title: "Statistics")`.
    - Body: `RefreshIndicator` wrapping `SingleChildScrollView`.
    - Content flow: `PeriodSelector` always visible at top, then conditional content:
      - Loading → `CircularProgressIndicator` centered.
      - Error → error message text + "Retry" `FilledButton`.
      - Empty → empty-state message guiding user toward completing a focus session.
      - Data → `SummaryCardsRow`, `DailyActivityChart`, `TaskBreakdownList`, `CategoryBreakdownList`.
    - Uses `context.watch<StatisticsController>()` to rebuild on state changes.
    - Manual refresh via `RefreshIndicator` pull-to-refresh.
    - Material 3 components, colors via `Theme.of(context)`.
    - No hardcoded widths for content containers.
    - Error state does NOT display stale data from previous load.
    - Empty state does NOT display summary/chart/breakdown widgets.
    - _Requirements: 1.1, 5.1, 8.5, 9.2, 9.4, 10.1, 10.2, 10.3, 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8, 14.9 / Design: Presentation — StatisticsScreen_

---

### Group 10 — Navigation Wiring

- [ ] 10. Wire Statistics into app navigation
  - [ ] 10.1 Update `lib/app/router.dart` — register `/statistics` route
    - Add `static const String statistics = '/statistics';` to `Routes` class.
    - Add case in `onGenerateRoute` that returns `MaterialPageRoute` building the `StatisticsScreen` wrapped in a route-scoped `ChangeNotifierProvider<StatisticsController>`.
    - Inside the route builder: instantiate `StatisticsSessionAdapter` (using `PomodoroSessionRepository`), all use cases, build task-category mapping from `TodoController`, create `StatisticsController`, call `init()`.
    - Import required classes.
    - _Requirements: 11.1, 11.2, 11.3 / Design: Architecture — Provider Scope Decision_

  - [ ] 10.2 Update `lib/app/app.dart` — expose dependencies for statistics route
    - Ensure `PomodoroSessionRepository` instance is accessible to the `/statistics` route builder (either passed via Provider or accessed directly in the route builder closure).
    - Build `StatisticsTaskCategoryOption` mapping from `TodoController.allTasks` and `TodoController.categories` as described in design.
    - _Requirements: 7.6, 11.2, 11.3 / Design: Cross-Feature Integration — app.dart_

---

### Group 11 — Checkpoint

- [ ] 11. Checkpoint — all code compiles and analyzes clean
  - Run `dart format .` and `flutter analyze`. Ensure no errors or warnings.
  - Verify `StatisticsScreen` renders on device/emulator with Today period showing empty state.
  - Ensure all tests pass, ask the user if questions arise.

---

### Group 12 — Unit Tests (Use Cases)

- [ ] 12. Unit tests for use cases
  - [ ]* 12.1 Write unit tests for `CalculateDateRangeUseCase`
    - Fake `Clock` providing controlled UTC timestamps.
    - Test Today period: verify start = local today 00:00 UTC, end = local tomorrow 00:00 UTC.
    - Test Week period: verify start = Monday 00:00 local → UTC, end = following Monday → UTC.
    - Test Month period: verify start = 1st 00:00 local → UTC, end = 1st of next month → UTC.
    - Test December → January year boundary (Requirement 2.5).
    - Test midnight edge case.
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5 / Design: Testing Strategy_

  - [ ]* 12.2 Write unit tests for `CalculateSummaryUseCase`
    - Empty list → totalFocusedSeconds = 0, sessionCount = 0, averageSessionSeconds = 0.
    - Single session → all fields computed correctly.
    - Multiple sessions → sum and integer division verified.
    - Large values → no overflow.
    - _Requirements: 3.1, 3.2, 3.3, 3.4 / Design: Testing Strategy_

  - [ ]* 12.3 Write unit tests for `GroupSessionsByDayUseCase`
    - Today range (1 day) → exactly 1 entry.
    - Week range → exactly 7 entries, zero-filled.
    - Sessions at day boundaries (23:59 local) assigned to correct day.
    - All zero days → all entries have totalFocusedSeconds = 0.
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6 / Design: Testing Strategy_

  - [ ]* 12.4 Write unit tests for `GroupSessionsByTaskUseCase`
    - Null taskId sessions grouped as "No task".
    - Multiple tasks sorted by totalFocusedSeconds descending.
    - Tie-breaking: equal seconds sorted by displayTitle alphabetically.
    - Percentage sums close to 1.0.
    - Uses latest `startedAt` session's `taskTitleSnapshot` as display title.
    - _Requirements: 6.1, 6.2, 6.3, 6.4 / Design: Testing Strategy_

  - [ ]* 12.5 Write unit tests for `GroupSessionsByCategoryUseCase`
    - Sessions with no taskId → "Uncategorized".
    - Sessions with taskId not in mapping → "Uncategorized".
    - Valid mapping resolution → correct category group.
    - Sorted by totalFocusedSeconds descending.
    - _Requirements: 7.1, 7.2, 7.3, 7.4 / Design: Testing Strategy_

---

### Group 13 — Property-Based Tests

All property tests use `dart_fast_check`. Each runs a minimum of 100 iterations. Fake `Clock` —
no Isar or Flutter dependencies required.

- [ ] 13. Property-based tests for correctness properties 1–5
  - [ ]* 13.1 Property 1: Date range validity and span
    - // Feature: statistics, Property 1: Date range validity and span
    - Arbitrary: random `StatisticsPeriod`, random UTC `DateTime` for Clock.
    - Assert: `start < end` for all generated inputs.
    - Assert: local calendar days between start and end equals 1 (today), 7 (week), or days-in-month (month).
    - **Property 1: Date range validity and span**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.5**

  - [ ]* 13.2 Property 2: Summary aggregation consistency
    - // Feature: statistics, Property 2: Summary aggregation consistency
    - Arbitrary: non-empty `List<FocusSession>` with random `actualDurationSeconds` (1–7200).
    - Assert: `totalFocusedSeconds == sum(actualDurationSeconds)`.
    - Assert: `sessionCount == list.length`.
    - Assert: `averageSessionSeconds == totalFocusedSeconds ~/ sessionCount`.
    - **Property 2: Summary aggregation consistency**
    - **Validates: Requirements 3.1, 3.2, 3.3**

  - [ ]* 13.3 Property 3: Duration formatting round-trip pattern
    - // Feature: statistics, Property 3: Duration formatting round-trip pattern
    - Arbitrary: non-negative int `totalSeconds` (0–100000).
    - Assert: 0 → "0 min"; 1–3599 → "{m} min"; 3600+ → "{h} h {m} min" with correct values.
    - **Property 3: Duration formatting round-trip pattern**
    - **Validates: Requirements 3.5, 3.6, 3.7**

  - [ ]* 13.4 Property 4: Daily grouper produces correct day count
    - // Feature: statistics, Property 4: Daily grouper produces correct day count
    - Arbitrary: random `StatisticsDateRange` (1–31 day span) + random `List<FocusSession>`.
    - Assert: result length equals the number of local calendar days spanned by the range.
    - **Property 4: Daily grouper produces correct day count**
    - **Validates: Requirements 4.2, 4.4, 4.5**

  - [ ]* 13.5 Property 5: Daily grouper assigns sessions correctly and sums match
    - // Feature: statistics, Property 5: Daily grouper assigns sessions correctly and sums match
    - Arbitrary: random `List<FocusSession>` within a random `StatisticsDateRange`.
    - Assert: sum of `totalFocusedSeconds` across all daily entries equals sum of `actualDurationSeconds` across all sessions within range.
    - Assert: each session contributes to exactly one day (matching its local calendar day).
    - **Property 5: Daily grouper assigns sessions to correct day and sums correctly**
    - **Validates: Requirements 4.1, 4.6**

- [ ] 14. Property-based tests for correctness properties 6–10
  - [ ]* 14.1 Property 6: Task grouper partition — focused seconds sum equals total
    - // Feature: statistics, Property 6: Task grouper partition — focused seconds sum equals total
    - Arbitrary: non-empty `List<FocusSession>` with random taskId (some null).
    - Assert: sum of `totalFocusedSeconds` across all groups equals sum of `actualDurationSeconds` across all sessions.
    - Assert: sessions with null taskId all assigned to "No task" group.
    - **Property 6: Task grouper partition — focused seconds sum equals total**
    - **Validates: Requirements 6.1, 6.2, 6.3**

  - [ ]* 14.2 Property 7: Task grouper sort order
    - // Feature: statistics, Property 7: Task grouper sort order
    - Arbitrary: non-empty `List<FocusSession>` with varied taskIds and durations.
    - Assert: result is sorted by `totalFocusedSeconds` descending.
    - Assert: ties broken by `displayTitle` alphabetically (case-insensitive ascending).
    - **Property 7: Task grouper sort order**
    - **Validates: Requirements 6.4**

  - [ ]* 14.3 Property 8: Category grouper partition — focused seconds sum equals total
    - // Feature: statistics, Property 8: Category grouper partition — focused seconds sum equals total
    - Arbitrary: non-empty `List<FocusSession>` + random `List<StatisticsTaskCategoryOption>` mapping.
    - Assert: sum of `totalFocusedSeconds` across all category groups equals sum of `actualDurationSeconds` across all sessions.
    - Assert: sessions with null taskId or taskId not in mapping assigned to "Uncategorized".
    - **Property 8: Category grouper partition — focused seconds sum equals total**
    - **Validates: Requirements 7.1, 7.2, 7.3**

  - [ ]* 14.4 Property 9: Category grouper sort order
    - // Feature: statistics, Property 9: Category grouper sort order
    - Arbitrary: non-empty `List<FocusSession>` + random mapping.
    - Assert: result is sorted by `totalFocusedSeconds` descending.
    - **Property 9: Category grouper sort order**
    - **Validates: Requirements 7.4**

  - [ ]* 14.5 Property 10: Bar height proportional scaling
    - // Feature: statistics, Property 10: Bar height proportional scaling
    - Arbitrary: non-empty `List<DailyFocusStatistics>` with at least one entry having `totalFocusedSeconds > 0`.
    - Assert: all computed fractions satisfy `0.0 <= fraction <= 1.0`.
    - Assert: the entry with maximum `totalFocusedSeconds` has `fraction == 1.0`.
    - **Property 10: Bar height proportional scaling**
    - **Validates: Requirements 5.2**

---

### Group 14 — Controller Tests

- [ ] 15. Unit tests for StatisticsController
  - [ ]* 15.1 Write unit tests for StatisticsController state management
    - Fake `StatisticsSessionSource` (in-memory), fake `Clock`.
    - `init()`: loads Today data, sets loading true then false, notifies.
    - `changePeriod(week)`: updates selectedPeriod, reloads with new period.
    - `refresh()`: reloads with current period preserved.
    - Empty state: source returns empty list → `isEmpty == true`, computed data is null/empty.
    - Error flow: source throws → `errorMessage` set, computed data cleared, period preserved.
    - `retry()` after error succeeds → error cleared, data loaded.
    - `retry()` after error fails again → error message updated.
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3 / Design: Testing Strategy — Controller Tests_

---

### Group 15 — Widget Tests

- [ ] 16. Widget tests for Statistics screen
  - [ ]* 16.1 Widget test: PeriodSelector displays three segments and emits correct value
    - Pump `PeriodSelector` with selectedPeriod = today.
    - Assert three segments visible: "Today", "This Week", "This Month".
    - Tap "This Week": assert `onPeriodChanged` called with `StatisticsPeriod.week`.
    - _Requirements: 1.1, 1.2, 1.3 / Design: Testing Strategy — Widget Tests_

  - [ ]* 16.2 Widget test: SummaryCardsRow shows formatted values and semantics
    - Pump `SummaryCardsRow` with known `StatisticsSummary`.
    - Assert formatted total time, session count, and average are displayed.
    - Assert semantics labels are present for each card.
    - _Requirements: 3.5, 3.6, 13.1 / Design: Testing Strategy — Widget Tests_

  - [ ]* 16.3 Widget test: DailyActivityChart renders correct number of bars
    - Pump with 7-entry list (week): assert 7 bars rendered.
    - Pump with 1-entry list (today): assert 1 bar rendered.
    - Pump with all-zero data: assert bars at minimal height, no crash.
    - Assert tooltip/semantics labels present on each bar.
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 13.2 / Design: Testing Strategy — Widget Tests_

  - [ ]* 16.4 Widget test: StatisticsScreen loading state
    - Mock controller with `isLoading = true`.
    - Assert `CircularProgressIndicator` visible.
    - Assert no data widgets (SummaryCardsRow, Chart, Breakdowns) present.
    - _Requirements: 8.5 / Design: Testing Strategy — Widget Tests_

  - [ ]* 16.5 Widget test: StatisticsScreen error state
    - Mock controller with `errorMessage = "Could not load statistics."`.
    - Assert error message text visible.
    - Assert "Retry" button visible. Tap it: assert `controller.retry()` invoked.
    - Assert no data widgets present (no stale data).
    - _Requirements: 9.1, 9.2, 9.4 / Design: Testing Strategy — Widget Tests_

  - [ ]* 16.6 Widget test: StatisticsScreen empty state
    - Mock controller with `isEmpty = true`.
    - Assert empty-state message visible.
    - Assert no data widgets (summary, chart, breakdowns) present.
    - _Requirements: 10.1, 10.2, 10.3 / Design: Testing Strategy — Widget Tests_

  - [ ]* 16.7 Widget test: BreakdownItem truncates long title
    - Pump `BreakdownItem` with very long title string in constrained width.
    - Assert `TextOverflow.ellipsis` behavior (title does not overflow).
    - Assert `LinearProgressIndicator` visible with correct percentage.
    - _Requirements: 6.6, 13.3 / Design: Testing Strategy — Widget Tests_

  - [ ]* 16.8 Widget test: Touch targets meet 48×48dp minimum
    - Pump interactive widgets (PeriodSelector segments, Retry button).
    - Assert minimum size constraints met.
    - _Requirements: 13.5 / Design: Testing Strategy — Widget Tests_

---

### Group 16 — Final Checkpoint

- [ ] 17. Final checkpoint — all tests pass and code is clean
  - Run `dart format .` to ensure consistent formatting.
  - Run `flutter analyze` to confirm no lint errors or warnings.
  - Run `flutter test` to verify all unit, property-based, widget tests pass.
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP build; all test sub-tasks
  fall in this category.
- Each task references specific requirements and design sections for full traceability.
- The implementation language is **Dart / Flutter** throughout.
- Property tests use `dart_fast_check` (confirm latest pub.dev version before implementing).
- Widget tests use a mock or fake `StatisticsController` — no Isar required in widget test scope.
- Fake clocks in tests must produce controlled UTC DateTime values to match production `SystemClock` behavior.
- The `StatisticsController` is route-scoped — created inside the `/statistics` route builder and
  disposed when the user navigates away. Unlike PomodoroController, it does not need to survive navigation.
- Cross-feature category resolution uses `StatisticsTaskCategoryOption` — a Statistics-owned type.
  The mapping from Todo tasks/categories to `StatisticsTaskCategoryOption` happens only in the
  route builder (composition root).
- The `Clock` is moved to `core/utils/clock.dart` so both Pomodoro and Statistics can import it
  without cross-feature domain dependencies.
- The `StatisticsSessionAdapter` wraps the existing `PomodoroSessionRepository` — no new Isar collection is created.
- Only Focus-mode sessions are included in statistics (breaks are filtered out by the adapter).
- Open Question 4 from design: use the `taskTitleSnapshot` from the session with the latest `startedAt` in each task group.
- Checkpoints at tasks 11 and 17 are natural review gates.


## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8"] },
    { "id": 2, "tasks": ["3.1"] },
    { "id": 3, "tasks": ["4.1", "4.2", "4.3", "4.4", "4.5", "4.6"] },
    { "id": 4, "tasks": ["5.1"] },
    { "id": 5, "tasks": ["6.1"] },
    { "id": 6, "tasks": ["7.1"] },
    { "id": 7, "tasks": ["8.1", "8.2", "8.3", "8.4", "8.5", "8.6"] },
    { "id": 8, "tasks": ["9.1"] },
    { "id": 9, "tasks": ["10.1", "10.2"] },
    { "id": 10, "tasks": ["12.1", "12.2", "12.3", "12.4", "12.5"] },
    { "id": 11, "tasks": ["13.1", "13.2", "13.3", "13.4", "13.5"] },
    { "id": 12, "tasks": ["14.1", "14.2", "14.3", "14.4", "14.5"] },
    { "id": 13, "tasks": ["15.1"] },
    { "id": 14, "tasks": ["16.1", "16.2", "16.3", "16.4", "16.5", "16.6", "16.7", "16.8"] }
  ]
}
```
