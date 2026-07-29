# Implementation Plan: Home & Main Navigation

## Overview

Implement the HomeScreen application shell that unifies Todo, Pomodoro, and Statistics under a Material 3 NavigationBar. The shell uses IndexedStack for state preservation and a lazy StatisticsTabHost for deferred controller creation. Routing is updated so `/` maps to HomeScreen while `/statistics` remains a standalone route.

## Tasks

- [x] 1. Create feature directory structure and HomeScreen shell
  - [x] 1.1 Create HomeScreen with NavigationBar and IndexedStack
    - Create `lib/features/home/presentation/screens/home_screen.dart`
    - Implement `HomeScreen` as a `StatefulWidget` with `_selectedIndex` (default 0) and `_hasSelectedStatistics` flag
    - Build a `Scaffold` with no `appBar`, an `IndexedStack` body (3 children: TodoScreen, PomodoroScreen, placeholder/StatisticsTabHost), and a `NavigationBar` with 3 destinations (Todo, Pomodoro, Statistics)
    - Define destinations as a `static const` list with filled/outlined icon variants and labels
    - Implement `_onDestinationSelected` with same-tab no-op guard and lazy statistics flag
    - Use `const` constructors for TodoScreen and PomodoroScreen children
    - Render `SizedBox.shrink()` for slot 2 when `_hasSelectedStatistics` is false, `StatisticsTabHost()` when true
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 2.1, 2.2, 2.3, 2.4, 2.5, 3.4, 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.3, 10.5, 11.1, 14.1, 14.2, 14.3, 14.5_

- [x] 2. Implement StatisticsTabHost widget
  - [x] 2.1 Create StatisticsTabHost with lazy controller lifecycle
    - Create `lib/features/home/presentation/widgets/statistics_tab_host.dart`
    - Implement as a `StatefulWidget` with a nullable `StatisticsController? _controller` field
    - Watch `TodoController` via `context.watch<TodoController>()`
    - Show loading scaffold (AppBar "Statistics" + centered CircularProgressIndicator) while `todoController.isLoading` is true and `_controller` is null
    - Create controller once `isLoading` becomes false using `_createController(context)`
    - Provide controller via `ChangeNotifierProvider<StatisticsController>.value`
    - Render `StatisticsScreen` as child
    - Dispose controller in `dispose()` override
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 10.4, 12.4, 12.5_

- [x] 3. Extract shared Statistics controller factory
  - [x] 3.1 Extract `createStatisticsController` factory function
    - Create a factory function (e.g., in `lib/features/statistics/presentation/statistics_controller_factory.dart`) that encapsulates the controller creation logic shared between `_StatisticsRoute` and `StatisticsTabHost`
    - Accept `BuildContext` as parameter, read `PomodoroSessionRepository` from Provider tree
    - Instantiate all use cases (CalculateDateRange, GetSessionsByDateRange, CalculateSummary, GroupByDay, GroupByTask, GroupByCategory)
    - Build the `taskCategoryMappingProvider` callback reading `TodoController` at call time
    - Return a fully constructed `StatisticsController` with `..init()` called
    - _Requirements: 5.6, 10.2, 10.4_

  - [x] 3.2 Refactor `_StatisticsRoute` and `StatisticsTabHost` to use the shared factory
    - Replace inline controller creation in `_StatisticsRouteState._createController()` with a call to the new factory function
    - Replace inline controller creation in `StatisticsTabHost` with a call to the same factory
    - Verify both paths produce identical behavior
    - _Requirements: 5.1, 5.6, 10.2_

- [ ] 4. Update router.dart to separate `/` and `/statistics` routes
  - [ ] 4.1 Modify `onGenerateRoute` to route `/` to HomeScreen
    - Split the existing `case Routes.home: case Routes.statistics:` into two separate cases
    - `Routes.home` → `HomeScreen` (import from `lib/features/home/presentation/screens/home_screen.dart`)
    - `Routes.statistics` → `_StatisticsRoute` (unchanged standalone behavior)
    - All other routes remain unchanged
    - Verify `initialRoute: Routes.home` in `app.dart` still resolves to HomeScreen
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 7.1, 7.2, 7.3, 7.4, 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 5. Checkpoint — Compile and static analysis
  - Ensure all tests pass, ask the user if questions arise.
  - Run `flutter analyze` to confirm no lint errors
  - Run `flutter build apk --debug` (or `flutter build` for compilation check) to confirm no compile errors
  - Verify the app boots to HomeScreen with Todo tab visible

- [ ] 6. Widget tests for HomeScreen
  - [ ] 6.1 Write widget tests for HomeScreen behavior
    - Create `test/features/home/presentation/screens/home_screen_test.dart`
    - Test initial state: Todo tab selected (index 0), TodoScreen visible
    - Test tab switching: tapping Pomodoro shows PomodoroScreen, tapping Statistics shows StatisticsTabHost
    - Test same-tab no-op: tapping already-selected tab does not trigger rebuild
    - Test NavigationBar has exactly 3 destinations with correct icons and labels
    - Test `_hasSelectedStatistics` flag: Statistics slot renders SizedBox.shrink before first selection
    - Mock TodoController, PomodoroController, PomodoroSessionRepository via Provider for test tree
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 9.1, 9.2, 9.3, 9.4_

  - [ ]* 6.2 Write widget tests for HomeScreen accessibility
    - Test semantic labels on each NavigationBar destination
    - Test touch target minimum size (48×48dp)
    - Test focus order traversal (left to right)
    - _Requirements: 1.8, 2.6, 2.7, 13.1, 13.2, 13.4, 13.5, 13.6_

- [ ] 7. Widget tests for StatisticsTabHost
  - [ ] 7.1 Write widget tests for StatisticsTabHost lifecycle
    - Create `test/features/home/presentation/widgets/statistics_tab_host_test.dart`
    - Test loading state: shows CircularProgressIndicator when TodoController.isLoading is true
    - Test controller creation: creates StatisticsController once TodoController finishes loading
    - Test single instance: switching away and back does not create a new controller
    - Test disposal: controller is disposed when widget is unmounted
    - Mock TodoController (with isLoading toggle), PomodoroSessionRepository
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.7, 5.8, 12.4, 12.5_

- [ ] 8. Widget tests for routing
  - [ ] 8.1 Write widget tests for updated router
    - Create or update `test/app/router_test.dart`
    - Test `/` resolves to HomeScreen
    - Test `/statistics` resolves to `_StatisticsRoute` (standalone)
    - Test `/todo`, `/pomodoro` routes remain unchanged
    - Test `/todo/task/new`, `/todo/task/:id/edit`, `/todo/categories`, `/todo/categories/new` routes remain unchanged
    - Test unknown route shows "Page not found"
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [ ] 9. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Property-based tests for correctness properties
  - [ ]* 10.1 Write property test for tab selection displays corresponding screen
    - **Property 1: Tab selection displays corresponding screen**
    - **Validates: Requirements 1.3, 9.2**
    - Generate random sequences of destination indices (0–2)
    - After each simulated tap, assert `IndexedStack.index == tapped index` and `NavigationBar.selectedIndex == tapped index`
    - Minimum 100 iterations

  - [ ]* 10.2 Write property test for state preservation across tab switches
    - **Property 2: State preservation across tab switches**
    - **Validates: Requirements 1.4, 3.1, 3.2, 3.3, 3.4**
    - Generate random tab switch sequences, inject identifiable state markers into each tab
    - After returning to a previously visited tab, verify state marker is unchanged
    - Minimum 100 iterations

  - [ ]* 10.3 Write property test for PomodoroController identity preservation
    - **Property 3: PomodoroController identity preservation**
    - **Validates: Requirements 4.2, 4.3, 4.5**
    - Generate random tab switch sequences
    - Assert `identical(controller1, controller2)` across all reads from PomodoroScreen subtree
    - Minimum 100 iterations

  - [ ]* 10.4 Write property test for StatisticsController single creation
    - **Property 4: StatisticsController single creation**
    - **Validates: Requirements 5.1, 5.4, 5.7**
    - Generate random tab switch sequences (some including index 2, some not)
    - Count controller creations: must be 0 (never visited) or exactly 1
    - Minimum 100 iterations

  - [ ]* 10.5 Write property test for Navigator stack invariant
    - **Property 5: Navigator stack invariant**
    - **Validates: Requirements 7.1, 7.4**
    - Generate random tab switch sequences
    - After each switch, assert `Navigator.of(context).canPop() == false`
    - Minimum 100 iterations

- [ ] 11. Accessibility tests
  - [ ]* 11.1 Write accessibility widget tests for NavigationBar
    - Create `test/features/home/presentation/screens/home_screen_accessibility_test.dart`
    - Test all destinations have text labels (no icon-only destinations)
    - Test selected state exposed to accessibility framework
    - Test font scale 100%–200% renders labels without truncation or overflow
    - Test minimum touch target 48×48dp
    - Test logical focus order (left to right)
    - Test selection communicated through icon variant + indicator, not color alone
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

- [ ] 12. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit/widget tests validate specific examples and edge cases
- The implementation language is Dart/Flutter as specified in the design
- The shared factory extraction (task 3) eliminates duplication between `_StatisticsRoute` and `StatisticsTabHost` as recommended in the design's Open Questions section

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["3.1"] },
    { "id": 3, "tasks": ["3.2", "4.1"] },
    { "id": 4, "tasks": ["6.1", "6.2", "7.1", "8.1"] },
    { "id": 5, "tasks": ["10.1", "10.2", "10.3", "10.4", "10.5", "11.1"] }
  ]
}
```
