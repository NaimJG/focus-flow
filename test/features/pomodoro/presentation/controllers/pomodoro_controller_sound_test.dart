import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:focus_flow/core/services/pomodoro_sound_service.dart';
import 'package:focus_flow/core/utils/clock.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_config.dart';
import 'package:focus_flow/features/pomodoro/domain/entities/pomodoro_session.dart';
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

class FakePomodoroSoundService implements PomodoroSoundService {
  final List<String> calls = [];
  bool shouldThrow = false;

  @override
  Future<void> playFocusCompleted() async {
    calls.add('playFocusCompleted');
    if (shouldThrow) throw Exception('fake audio error');
  }

  @override
  Future<void> playBreakCompleted() async {
    calls.add('playBreakCompleted');
    if (shouldThrow) throw Exception('fake audio error');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

class RecordingPomodoroSessionRepository
    implements PomodoroSessionRepository {
  final List<PomodoroSession> createdSessions = [];

  @override
  Future<PomodoroSession> create(PomodoroSession session) async {
    createdSessions.add(session);
    return session;
  }

  @override
  Future<List<PomodoroSession>> getAll() async => const [];

  @override
  Future<List<PomodoroSession>> getByDateRange({
    required DateTime start,
    required DateTime end,
  }) async => const [];

  @override
  Future<List<PomodoroSession>> getByTaskId(int taskId) async =>
      const [];

  @override
  Future<List<PomodoroSession>> getByNullTask() async => const [];
}

class FakePomodoroSessionRepository implements PomodoroSessionRepository {
  @override
  Future<PomodoroSession> create(PomodoroSession session) async =>
      session;

  @override
  Future<List<PomodoroSession>> getAll() async => const [];

  @override
  Future<List<PomodoroSession>> getByDateRange({
    required DateTime start,
    required DateTime end,
  }) async => const [];

  @override
  Future<List<PomodoroSession>> getByTaskId(int taskId) async =>
      const [];

  @override
  Future<List<PomodoroSession>> getByNullTask() async => const [];
}

// --- Helpers ---

PomodoroController createController({
  PomodoroConfig config = const PomodoroConfig(
    focusDuration: Duration(minutes: 1),
    shortBreakDuration: Duration(minutes: 1),
    longBreakDuration: Duration(minutes: 1),
  ),
  FakeClock? clock,
  FakePomodoroSoundService? soundService,
  bool Function()? isSoundEnabled,
  PomodoroSessionRepository? repository,
}) {
  final fakeClock = clock ?? FakeClock();
  final repo = repository ?? FakePomodoroSessionRepository();
  final saveUseCase = SavePomodoroSessionUseCase(repo);

  return PomodoroController(
    saveSessionUseCase: saveUseCase,
    taskListProvider: () => const [],
    config: config,
    clock: fakeClock,
    soundService: soundService,
    isSoundEnabled: isSoundEnabled,
  );
}

/// Triggers natural completion by advancing the clock past the timer
/// duration and calling pause(), which detects remaining <= 0 and
/// calls _onCompletion().
Future<void> triggerNaturalCompletion(
  PomodoroController controller,
  FakeClock clock, {
  Duration advance = const Duration(minutes: 1, seconds: 1),
}) async {
  controller.start();
  clock.advance(advance);
  controller.pause();
  // Allow unawaited futures to execute.
  await Future<void>.delayed(Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PomodoroController sound playback', () {
    // --- Property 1: Correct sound on natural completion when enabled ---
    // Validates: Requirements 12.1
    group(
      'focus completion plays focus sound once when enabled',
      () {
        test(
          'plays playFocusCompleted exactly once on focus completion',
          () async {
            final clock = FakeClock();
            final soundService = FakePomodoroSoundService();
            final controller = createController(
              clock: clock,
              soundService: soundService,
              isSoundEnabled: () => true,
            );
            controller.init();

            await triggerNaturalCompletion(controller, clock);

            expect(soundService.calls, ['playFocusCompleted']);
          },
        );
      },
    );

    // --- Property 2: No sound on natural completion when disabled ---
    // Validates: Requirements 12.2
    group('no sound when disabled', () {
      test(
        'no sound service calls on focus completion when disabled',
        () async {
          final clock = FakeClock();
          final soundService = FakePomodoroSoundService();
          final controller = createController(
            clock: clock,
            soundService: soundService,
            isSoundEnabled: () => false,
          );
          controller.init();

          await triggerNaturalCompletion(controller, clock);

          expect(soundService.calls, isEmpty);
        },
      );
    });

    // --- Property 1: Correct sound on natural completion when enabled ---
    // Validates: Requirements 12.3
    group('short-break plays break sound once', () {
      test(
        'plays playBreakCompleted exactly once on short break completion',
        () async {
          final clock = FakeClock();
          final soundService = FakePomodoroSoundService();
          final controller = createController(
            clock: clock,
            soundService: soundService,
            isSoundEnabled: () => true,
          );
          controller.init();

          // Complete a focus phase to advance to short break.
          await triggerNaturalCompletion(controller, clock);

          expect(controller.currentMode, TimerMode.shortBreak);
          soundService.calls.clear();

          // Now complete the short break.
          await triggerNaturalCompletion(controller, clock);

          expect(soundService.calls, ['playBreakCompleted']);
        },
      );
    });

    // --- Property 1: Correct sound on natural completion when enabled ---
    // Validates: Requirements 12.4
    group('long-break plays break sound once', () {
      test(
        'plays playBreakCompleted exactly once on long break completion',
        () async {
          final clock = FakeClock();
          final soundService = FakePomodoroSoundService();
          final controller = createController(
            clock: clock,
            soundService: soundService,
            isSoundEnabled: () => true,
            config: const PomodoroConfig(
              focusDuration: Duration(minutes: 1),
              shortBreakDuration: Duration(minutes: 1),
              longBreakDuration: Duration(minutes: 1),
              sessionsBeforeLongBreak: 1,
            ),
          );
          controller.init();

          // Complete a focus phase — with sessionsBeforeLongBreak=1,
          // it advances to long break.
          await triggerNaturalCompletion(controller, clock);

          expect(controller.currentMode, TimerMode.longBreak);
          soundService.calls.clear();

          // Now complete the long break.
          await triggerNaturalCompletion(controller, clock);

          expect(soundService.calls, ['playBreakCompleted']);
        },
      );
    });

    // --- Property 3: Manual actions never trigger sound ---
    // Validates: Requirements 12.5
    group('reset does not trigger sound', () {
      test('no sound service calls when timer is reset', () async {
        final clock = FakeClock();
        final soundService = FakePomodoroSoundService();
        final controller = createController(
          clock: clock,
          soundService: soundService,
          isSoundEnabled: () => true,
        );
        controller.init();

        controller.start();
        clock.advance(const Duration(seconds: 30));
        controller.reset();

        await Future<void>.delayed(Duration.zero);

        expect(soundService.calls, isEmpty);
      });
    });

    // --- Property 3: Manual actions never trigger sound ---
    // Validates: Requirements 12.6
    group('skip does not trigger sound', () {
      test('no sound service calls when timer is skipped', () async {
        final clock = FakeClock();
        final soundService = FakePomodoroSoundService();
        final controller = createController(
          clock: clock,
          soundService: soundService,
          isSoundEnabled: () => true,
        );
        controller.init();

        controller.start();
        clock.advance(const Duration(seconds: 30));
        controller.skip();

        await Future<void>.delayed(Duration.zero);

        expect(soundService.calls, isEmpty);
      });
    });

    // --- Property 4: Phase transition resilience ---
    // Validates: Requirements 12.7
    group('playback failure does not prevent phase transition', () {
      test(
        'transitions to next mode even when sound service throws',
        () async {
          final clock = FakeClock();
          final soundService = FakePomodoroSoundService();
          soundService.shouldThrow = true;
          final controller = createController(
            clock: clock,
            soundService: soundService,
            isSoundEnabled: () => true,
          );
          controller.init();

          // Run in a guarded zone so the unawaited exception from
          // the sound service does not escape into the test zone.
          final errors = <Object>[];
          await runZonedGuarded(() async {
            controller.start();
            clock.advance(const Duration(minutes: 1, seconds: 1));
            controller.pause();
            await Future<void>.delayed(Duration.zero);
          }, (error, stack) {
            errors.add(error);
          });

          // Phase transition still happened despite audio error.
          expect(controller.status, TimerStatus.completed);
          expect(controller.currentMode, TimerMode.shortBreak);
          expect(controller.cycleCount, 1);
          // The error was produced but caught in the zone.
          expect(errors, hasLength(1));
        },
      );
    });

    // Validates: Requirements 12.8
    group('session persistence remains unchanged', () {
      test(
        'session is persisted when sound is enabled',
        () async {
          final clock = FakeClock();
          final soundService = FakePomodoroSoundService();
          final repository = RecordingPomodoroSessionRepository();
          final controller = createController(
            clock: clock,
            soundService: soundService,
            isSoundEnabled: () => true,
            repository: repository,
          );
          controller.init();

          await triggerNaturalCompletion(controller, clock);

          // Session was persisted.
          expect(repository.createdSessions, hasLength(1));
          // Sound was also played.
          expect(soundService.calls, ['playFocusCompleted']);
        },
      );
    });

    // Validates: Requirements 12.10
    group(
      'changing soundEnabled during active timer affects next completion',
      () {
        test(
          'starts enabled, switches to disabled mid-timer — no sound',
          () async {
            final clock = FakeClock();
            final soundService = FakePomodoroSoundService();
            var soundEnabled = true;
            final controller = createController(
              clock: clock,
              soundService: soundService,
              isSoundEnabled: () => soundEnabled,
            );
            controller.init();

            controller.start();
            clock.advance(const Duration(seconds: 30));

            // Mid-timer: disable sound.
            soundEnabled = false;

            // Let the timer complete.
            clock.advance(const Duration(seconds: 31));
            controller.pause();
            await Future<void>.delayed(Duration.zero);

            expect(soundService.calls, isEmpty);
          },
        );

        test(
          'starts disabled, switches to enabled mid-timer — sound plays',
          () async {
            final clock = FakeClock();
            final soundService = FakePomodoroSoundService();
            var soundEnabled = false;
            final controller = createController(
              clock: clock,
              soundService: soundService,
              isSoundEnabled: () => soundEnabled,
            );
            controller.init();

            controller.start();
            clock.advance(const Duration(seconds: 30));

            // Mid-timer: enable sound.
            soundEnabled = true;

            // Let the timer complete.
            clock.advance(const Duration(seconds: 31));
            controller.pause();
            await Future<void>.delayed(Duration.zero);

            expect(soundService.calls, ['playFocusCompleted']);
          },
        );
      },
    );
  });
}
