import 'package:flutter_test/flutter_test.dart';

import 'package:focus_flow/core/utils/clock.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_config.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_task_option.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/timer_mode.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/timer_status.dart';
import 'package:focus_flow/features/pomodoro/domain/repositories/pomodoro_session_repository.dart';
import 'package:focus_flow/features/pomodoro/domain/use_cases/save_pomodoro_session_use_case.dart';
import 'package:focus_flow/features/pomodoro/presentation/controllers/pomodoro_controller.dart';

// --- Manual fakes ---

class FakeClock implements Clock {
  DateTime _now = DateTime.utc(2024, 1, 1, 12, 0, 0);

  @override
  DateTime now() => _now;

  void advance(Duration duration) {
    _now = _now.add(duration);
  }
}

class FakePomodoroSessionRepository implements PomodoroSessionRepository {
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

// --- Helpers ---

PomodoroController createController({
  PomodoroConfig config = const PomodoroConfig(),
  FakeClock? clock,
  List<PomodoroTaskOption>? tasks,
}) {
  final fakeClock = clock ?? FakeClock();
  final repository = FakePomodoroSessionRepository();
  final saveUseCase = SavePomodoroSessionUseCase(repository);
  final taskList = tasks ?? const <PomodoroTaskOption>[];

  return PomodoroController(
    saveSessionUseCase: saveUseCase,
    taskListProvider: () => taskList,
    config: config,
    clock: fakeClock,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PomodoroController.updateConfig', () {
    group('applies config when idle', () {
      test('remainingDuration updates to new focus duration when idle', () {
        final controller = createController();
        controller.init();

        expect(controller.status, TimerStatus.idle);
        expect(controller.remainingDuration, const Duration(minutes: 25));

        final newConfig = const PomodoroConfig(
          focusDuration: Duration(minutes: 30),
          shortBreakDuration: Duration(minutes: 10),
          longBreakDuration: Duration(minutes: 20),
          sessionsBeforeLongBreak: 3,
        );

        controller.updateConfig(newConfig);

        expect(controller.remainingDuration, const Duration(minutes: 30));
      });

      test('notifies listeners when config changes while idle', () {
        final controller = createController();
        controller.init();

        var notified = false;
        controller.addListener(() => notified = true);

        controller.updateConfig(
          const PomodoroConfig(focusDuration: Duration(minutes: 45)),
        );

        expect(notified, isTrue);
      });
    });

    group('applies config when completed', () {
      test('remainingDuration updates to new duration for current mode '
          'when completed', () async {
        final clock = FakeClock();
        final controller = createController(
          config: const PomodoroConfig(focusDuration: Duration(minutes: 1)),
          clock: clock,
        );
        controller.init();

        // Start and let the timer complete by advancing clock past
        // the focus duration.
        controller.start();
        expect(controller.status, TimerStatus.running);

        // Advance clock past the 1-minute focus duration.
        clock.advance(const Duration(minutes: 1, seconds: 1));

        // Trigger pause which detects completion when remaining <= 0.
        controller.pause();

        // After completion, the controller advances to the next mode
        // (shortBreak) and status becomes completed then advances.
        // Actually, _onCompletion sets status to completed.
        // But pause() calls _onCompletion when remaining <= 0.
        expect(controller.status, TimerStatus.completed);

        // Now update config while completed.
        final newConfig = const PomodoroConfig(
          focusDuration: Duration(minutes: 50),
          shortBreakDuration: Duration(minutes: 12),
          longBreakDuration: Duration(minutes: 25),
          sessionsBeforeLongBreak: 4,
        );

        controller.updateConfig(newConfig);

        // After completion of focus, mode advances to shortBreak.
        // So remainingDuration should reflect new shortBreak duration.
        expect(controller.currentMode, TimerMode.shortBreak);
        expect(controller.remainingDuration, const Duration(minutes: 12));
      });
    });

    group('config ignored when running', () {
      test('remainingDuration unchanged when timer is running', () {
        final clock = FakeClock();
        final controller = createController(
          config: const PomodoroConfig(focusDuration: Duration(minutes: 25)),
          clock: clock,
        );
        controller.init();

        controller.start();
        expect(controller.status, TimerStatus.running);

        // Advance clock a bit so remaining is less than full duration.
        clock.advance(const Duration(minutes: 5));

        // Capture remaining before config change.
        // Note: remaining is computed from targetEndTime - now in
        // the next tick, but _remainingDuration was set at start.
        // The controller only updates _remainingDuration on ticks.
        // Since we're not ticking, it's still the initial value.
        final remainingBefore = controller.remainingDuration;

        final newConfig = const PomodoroConfig(
          focusDuration: Duration(minutes: 50),
          shortBreakDuration: Duration(minutes: 15),
          longBreakDuration: Duration(minutes: 30),
          sessionsBeforeLongBreak: 6,
        );

        controller.updateConfig(newConfig);

        // remainingDuration should NOT have changed.
        expect(controller.remainingDuration, remainingBefore);
      });

      test('notifies listeners even when running (config stored)', () {
        final clock = FakeClock();
        final controller = createController(clock: clock);
        controller.init();

        controller.start();

        var notified = false;
        controller.addListener(() => notified = true);

        controller.updateConfig(
          const PomodoroConfig(focusDuration: Duration(minutes: 40)),
        );

        expect(notified, isTrue);
      });
    });

    group('config ignored when paused', () {
      test('remainingDuration unchanged when timer is paused', () {
        final clock = FakeClock();
        final controller = createController(
          config: const PomodoroConfig(focusDuration: Duration(minutes: 25)),
          clock: clock,
        );
        controller.init();

        controller.start();
        clock.advance(const Duration(minutes: 10));
        controller.pause();

        expect(controller.status, TimerStatus.paused);

        final remainingBefore = controller.remainingDuration;

        final newConfig = const PomodoroConfig(
          focusDuration: Duration(minutes: 50),
          shortBreakDuration: Duration(minutes: 15),
          longBreakDuration: Duration(minutes: 30),
          sessionsBeforeLongBreak: 6,
        );

        controller.updateConfig(newConfig);

        expect(controller.remainingDuration, remainingBefore);
      });
    });

    group('atomic replacement of all config fields', () {
      test('all config fields are replaced atomically', () {
        final controller = createController();
        controller.init();

        final newConfig = const PomodoroConfig(
          focusDuration: Duration(minutes: 40),
          shortBreakDuration: Duration(minutes: 8),
          longBreakDuration: Duration(minutes: 20),
          sessionsBeforeLongBreak: 6,
        );

        controller.updateConfig(newConfig);

        expect(controller.config.focusDuration, const Duration(minutes: 40));
        expect(
          controller.config.shortBreakDuration,
          const Duration(minutes: 8),
        );
        expect(
          controller.config.longBreakDuration,
          const Duration(minutes: 20),
        );
        expect(controller.config.sessionsBeforeLongBreak, 6);
      });

      test('equal config is a no-op (no notification)', () {
        final controller = createController();
        controller.init();

        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // Pass the same default config.
        controller.updateConfig(const PomodoroConfig());

        expect(notifyCount, 0);
      });
    });

    group('cycleCount, status, selectedTask preserved across updateConfig', () {
      test('cycleCount is preserved when config changes while idle', () {
        final clock = FakeClock();
        final config = const PomodoroConfig(
          focusDuration: Duration(minutes: 1),
        );
        final controller = createController(config: config, clock: clock);
        controller.init();

        // Complete a focus session to increment cycleCount.
        controller.start();
        clock.advance(const Duration(minutes: 1, seconds: 1));
        controller.pause(); // triggers _onCompletion

        expect(controller.cycleCount, 1);
        expect(controller.status, TimerStatus.completed);

        final newConfig = const PomodoroConfig(
          focusDuration: Duration(minutes: 30),
          shortBreakDuration: Duration(minutes: 10),
          longBreakDuration: Duration(minutes: 20),
          sessionsBeforeLongBreak: 4,
        );

        controller.updateConfig(newConfig);

        expect(controller.cycleCount, 1);
      });

      test('status is preserved when config changes', () {
        final controller = createController();
        controller.init();

        expect(controller.status, TimerStatus.idle);

        controller.updateConfig(
          const PomodoroConfig(focusDuration: Duration(minutes: 45)),
        );

        expect(controller.status, TimerStatus.idle);
      });

      test('selectedTask is preserved when config changes', () {
        final tasks = [
          const PomodoroTaskOption(
            id: 42,
            title: 'Write tests',
            isCompleted: false,
          ),
        ];
        final controller = createController(tasks: tasks);
        controller.init();

        controller.selectTask(42, 'Write tests');
        expect(controller.selectedTaskId, 42);
        expect(controller.selectedTaskTitle, 'Write tests');

        controller.updateConfig(
          const PomodoroConfig(focusDuration: Duration(minutes: 50)),
        );

        expect(controller.selectedTaskId, 42);
        expect(controller.selectedTaskTitle, 'Write tests');
      });

      test('status preserved as running when config changes while running', () {
        final clock = FakeClock();
        final controller = createController(clock: clock);
        controller.init();

        controller.start();
        expect(controller.status, TimerStatus.running);

        controller.updateConfig(
          const PomodoroConfig(focusDuration: Duration(minutes: 50)),
        );

        expect(controller.status, TimerStatus.running);
      });

      test('status preserved as paused when config changes while paused', () {
        final clock = FakeClock();
        final controller = createController(clock: clock);
        controller.init();

        controller.start();
        clock.advance(const Duration(minutes: 5));
        controller.pause();
        expect(controller.status, TimerStatus.paused);

        controller.updateConfig(
          const PomodoroConfig(focusDuration: Duration(minutes: 50)),
        );

        expect(controller.status, TimerStatus.paused);
      });
    });
  });
}
