import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:focus_flow/features/home/presentation/screens/home_screen.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_config.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_task_option.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/timer_mode.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/timer_status.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_session_repository.dart';
import 'package:focus_flow/features/pomodoro/presentation/controllers/pomodoro_controller.dart';
import 'package:focus_flow/features/todo/domain/entities/category.dart';
import 'package:focus_flow/features/todo/domain/entities/priority.dart';
import 'package:focus_flow/features/todo/domain/entities/sort_criterion.dart';
import 'package:focus_flow/features/todo/domain/entities/sort_direction.dart';
import 'package:focus_flow/features/todo/domain/entities/task.dart';
import 'package:focus_flow/features/todo/domain/entities/task_status.dart';
import 'package:focus_flow/features/todo/presentation/controllers/todo_controller.dart';

// --- Manual mock classes ---

class MockTodoController extends ChangeNotifier implements TodoController {
  @override
  bool get isLoading => false;

  @override
  UnmodifiableListView<Task> get allTasks => UnmodifiableListView([
        Task(
          id: 1,
          title: 'Test Task',
          priority: Priority.medium,
          status: TaskStatus.pending,
          createdAt: DateTime(2024, 1, 1),
        ),
      ]);

  @override
  UnmodifiableListView<Task> get displayedTasks => allTasks;

  @override
  UnmodifiableListView<Category> get categories =>
      UnmodifiableListView(const []);

  @override
  String get searchQuery => '';

  @override
  TaskStatus? get statusFilter => null;

  @override
  Priority? get priorityFilter => null;

  @override
  int? get categoryFilter => null;

  @override
  SortCriterion get sortCriterion => SortCriterion.creationDate;

  @override
  SortDirection get sortDirection => SortDirection.descending;

  @override
  bool get hasActiveFilters => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> init() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockPomodoroController extends ChangeNotifier
    implements PomodoroController {
  @override
  bool get isLoading => false;

  @override
  TimerStatus get status => TimerStatus.idle;

  @override
  TimerMode get currentMode => TimerMode.focus;

  @override
  Duration get remainingDuration => const Duration(minutes: 25);

  @override
  PomodoroConfig get config => const PomodoroConfig();

  @override
  int get cycleCount => 0;

  @override
  int? get selectedTaskId => null;

  @override
  String? get selectedTaskTitle => null;

  @override
  bool get hasPendingSession => false;

  @override
  TimerMode? get completedMode => null;

  @override
  List<PomodoroTaskOption> get availableTasks => const [];

  @override
  String? get errorMessage => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockPomodoroSessionRepository implements PomodoroSessionRepository {
  @override
  Future<PomodoroSession> create(PomodoroSession session) async => session;

  @override
  Future<List<PomodoroSession>> getAll() async => const [];

  @override
  Future<List<PomodoroSession>> getByDateRange({
    required DateTime start,
    required DateTime end,
  }) async => const [];

  @override
  Future<List<PomodoroSession>> getByTaskId(int taskId) async => const [];

  @override
  Future<List<PomodoroSession>> getByNullTask() async => const [];
}

// --- Helper to build the test widget tree ---

Widget buildTestApp({
  MockTodoController? todoController,
  MockPomodoroController? pomodoroController,
  MockPomodoroSessionRepository? sessionRepository,
}) {
  final todoCtrl = todoController ?? MockTodoController();
  final pomodoroCtrl = pomodoroController ?? MockPomodoroController();
  final sessionRepo = sessionRepository ?? MockPomodoroSessionRepository();

  return MultiProvider(
    providers: [
      Provider<PomodoroSessionRepository>.value(value: sessionRepo),
      ChangeNotifierProvider<TodoController>.value(value: todoCtrl),
      ChangeNotifierProvider<PomodoroController>.value(value: pomodoroCtrl),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets(
      'initial state shows Todo tab selected and TodoScreen visible',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // NavigationBar should show Todo as selected (index 0).
        final navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 0);

        // TodoScreen's AppBar title should be visible.
        expect(find.text('Tasks'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Pomodoro destination shows PomodoroScreen',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Tap Pomodoro destination.
        await tester.tap(find.text('Pomodoro'));
        await tester.pumpAndSettle();

        // The NavigationBar selectedIndex should be 1.
        final navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 1);
      },
    );

    testWidgets(
      'tapping Statistics destination shows StatisticsTabHost',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Tap Statistics destination.
        await tester.tap(find.text('Statistics'));
        await tester.pumpAndSettle();

        // The NavigationBar selectedIndex should be 2.
        final navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 2);
      },
    );

    testWidgets(
      'tapping already-selected tab does not trigger rebuild',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Find the HomeScreen's IndexedStack (first one).
        final indexedStackFinder = find.byType(IndexedStack).first;
        final indexedStackBefore =
            tester.widget<IndexedStack>(indexedStackFinder);
        expect(indexedStackBefore.index, 0);

        // Tap the Todo tab again (same tab).
        await tester.tap(find.text('Todo'));
        await tester.pump();

        // IndexedStack index should remain 0.
        final indexedStackAfter =
            tester.widget<IndexedStack>(indexedStackFinder);
        expect(indexedStackAfter.index, 0);
      },
    );

    testWidgets(
      'NavigationBar has exactly 3 destinations',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        final navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.destinations.length, 3);
      },
    );

    testWidgets(
      'NavigationBar destinations have correct labels and icon types',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        final navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        final destinations =
            navBar.destinations.cast<NavigationDestination>();

        // Todo destination.
        expect(destinations[0].label, 'Todo');
        final todoIcon = (destinations[0].icon as Icon).icon;
        final todoSelectedIcon =
            (destinations[0].selectedIcon! as Icon).icon;
        expect(todoIcon, Icons.checklist_outlined);
        expect(todoSelectedIcon, Icons.checklist);

        // Pomodoro destination.
        expect(destinations[1].label, 'Pomodoro');
        final pomodoroIcon = (destinations[1].icon as Icon).icon;
        final pomodoroSelectedIcon =
            (destinations[1].selectedIcon! as Icon).icon;
        expect(pomodoroIcon, Icons.timer_outlined);
        expect(pomodoroSelectedIcon, Icons.timer);

        // Statistics destination.
        expect(destinations[2].label, 'Statistics');
        final statsIcon = (destinations[2].icon as Icon).icon;
        final statsSelectedIcon =
            (destinations[2].selectedIcon! as Icon).icon;
        expect(statsIcon, Icons.bar_chart_outlined);
        expect(statsSelectedIcon, Icons.bar_chart);
      },
    );

    testWidgets(
      'Statistics slot renders SizedBox.shrink before first selection',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Before selecting Statistics, the IndexedStack child at
        // index 2 should be a SizedBox.shrink() (0x0 dimensions).
        final indexedStack = tester
            .widget<IndexedStack>(find.byType(IndexedStack).first);
        final thirdChild = indexedStack.children[2];

        expect(thirdChild, isA<SizedBox>());
        final sizedBox = thirdChild as SizedBox;
        expect(sizedBox.width, 0.0);
        expect(sizedBox.height, 0.0);
      },
    );

    testWidgets(
      'after selecting Statistics, slot is no longer SizedBox.shrink',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Navigate to Statistics.
        await tester.tap(find.text('Statistics'));
        await tester.pumpAndSettle();

        // The IndexedStack child at index 2 should no longer be a
        // zero-dimension SizedBox.
        final indexedStack = tester
            .widget<IndexedStack>(find.byType(IndexedStack).first);
        final thirdChild = indexedStack.children[2];

        if (thirdChild is SizedBox) {
          expect(
            thirdChild.width == 0.0 && thirdChild.height == 0.0,
            isFalse,
          );
        }
      },
    );

    testWidgets(
      'tab switching preserves IndexedStack children',
      (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Go to Pomodoro.
        await tester.tap(find.text('Pomodoro'));
        await tester.pumpAndSettle();

        final indexedStack1 = tester
            .widget<IndexedStack>(find.byType(IndexedStack).first);
        expect(indexedStack1.index, 1);

        // Go back to Todo.
        await tester.tap(find.text('Todo'));
        await tester.pumpAndSettle();

        final indexedStack2 = tester
            .widget<IndexedStack>(find.byType(IndexedStack).first);
        expect(indexedStack2.index, 0);

        // TodoScreen should still be visible.
        expect(find.text('Tasks'), findsOneWidget);
      },
    );
  });
}
