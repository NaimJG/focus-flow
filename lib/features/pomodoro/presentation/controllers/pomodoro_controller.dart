import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/services/pomodoro_sound_service.dart';
import '../../domain/entities/clock.dart';
import '../../domain/entities/pomodoro_config.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/entities/pomodoro_task_option.dart';
import '../../domain/entities/timer_mode.dart';
import '../../domain/entities/timer_status.dart';
import '../../domain/use_cases/save_pomodoro_session_use_case.dart';

/// Manages all Pomodoro timer state. Provided at the app level so the timer
/// survives navigation away from the Pomodoro screen. Uses
/// WidgetsBindingObserver to handle background/foreground lifecycle
/// transitions.
class PomodoroController extends ChangeNotifier with WidgetsBindingObserver {
  PomodoroController({
    required SavePomodoroSessionUseCase saveSessionUseCase,
    required List<PomodoroTaskOption> Function() taskListProvider,
    PomodoroConfig config = const PomodoroConfig(),
    Clock clock = const SystemClock(),
    PomodoroSoundService? soundService,
    bool Function()? isSoundEnabled,
  }) : _saveSessionUseCase = saveSessionUseCase,
       _taskListProvider = taskListProvider,
       _clock = clock,
       _soundService = soundService,
       _isSoundEnabled = isSoundEnabled,
       _config = config,
       _remainingDuration = config.focusDuration;

  // --- Configuration ---
  PomodoroConfig _config;
  final Clock _clock;
  final SavePomodoroSessionUseCase _saveSessionUseCase;
  final List<PomodoroTaskOption> Function() _taskListProvider;
  final PomodoroSoundService? _soundService;
  final bool Function()? _isSoundEnabled;

  // --- Task list ---
  List<PomodoroTaskOption> _availableTasks = [];

  // --- Timer state ---
  TimerMode _currentMode = TimerMode.focus;
  TimerStatus _status = TimerStatus.idle;
  Duration _remainingDuration;
  DateTime? _targetEndTime;
  Duration? _preservedRemaining;
  Timer? _timer;

  // --- Completion tracking ---
  TimerMode? _completedMode;

  // --- Cycle state ---
  int _cycleCount = 0;

  // --- Session tracking ---
  DateTime? _sessionStartedAt;
  Duration? _activeSessionPlannedDuration;
  int? _selectedTaskId;
  String? _selectedTaskTitle;

  // --- Feedback ---
  bool _isLoading = true;
  String? _errorMessage;
  PomodoroSession? _pendingSession;

  // --- Public getters ---

  /// The current timer mode (Focus, Short Break, or Long Break).
  TimerMode get currentMode => _currentMode;

  /// The current lifecycle state of the timer.
  TimerStatus get status => _status;

  /// The remaining countdown duration, clamped to zero.
  Duration get remainingDuration => _remainingDuration;

  /// Number of focus sessions completed in the current cycle (0–4).
  int get cycleCount => _cycleCount;

  /// The currently selected task ID, or null if no task is associated.
  int? get selectedTaskId => _selectedTaskId;

  /// The title of the currently selected task, or null.
  String? get selectedTaskTitle => _selectedTaskTitle;

  /// Whether the controller is still loading initial data.
  bool get isLoading => _isLoading;

  /// A user-facing error message, or null if no error.
  String? get errorMessage => _errorMessage;

  /// Whether a session failed to persist and is awaiting retry.
  bool get hasPendingSession => _pendingSession != null;

  /// The duration configuration used by this controller.
  PomodoroConfig get config => _config;

  /// The current list of available tasks.
  List<PomodoroTaskOption> get availableTasks =>
      List.unmodifiable(_availableTasks);

  /// The mode that just finished. Non-null only when [status] is
  /// [TimerStatus.completed]. Used by the UI to display which mode
  /// just ended (e.g., "Focus session finished").
  TimerMode? get completedMode => _completedMode;

  /// Progress of the current Focus session as a value between 0.0 and 1.0.
  ///
  /// Returns 0.0 when the current mode is not [TimerMode.focus] or when
  /// no active session planned duration is available.
  double get focusSessionProgress {
    if (_currentMode != TimerMode.focus) return 0.0;
    final total = _activeSessionPlannedDuration ?? _config.focusDuration;
    if (total.inMilliseconds <= 0) return 0.0;
    final elapsed = total - _remainingDuration;
    return (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  // --- Public mutation methods (implemented in subsequent tasks) ---

  /// Starts the timer from Idle or Completed state.
  /// No-op if status is Running or Paused.
  void start() {
    if (_status != TimerStatus.idle && _status != TimerStatus.completed) {
      return;
    }
    _completedMode = null;
    _targetEndTime = _clock.now().add(_remainingDuration);
    _status = TimerStatus.running;
    if (_currentMode == TimerMode.focus) {
      _sessionStartedAt = _clock.now();
      _activeSessionPlannedDuration = _remainingDuration;
    }
    _startTimer();
    notifyListeners();
  }

  /// Pauses the timer from Running state.
  /// No-op if status is not Running.
  void pause() {
    if (_status != TimerStatus.running) {
      return;
    }
    final remaining = _targetEndTime!.difference(_clock.now());
    if (remaining <= Duration.zero) {
      _onCompletion();
      return;
    }
    _preservedRemaining = remaining;
    _remainingDuration = remaining;
    _status = TimerStatus.paused;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  /// Resumes the timer from Paused state.
  /// No-op if status is not Paused.
  void resume() {
    if (_status != TimerStatus.paused) return;
    _targetEndTime = _clock.now().add(_preservedRemaining!);
    _status = TimerStatus.running;
    _startTimer();
    notifyListeners();
  }

  /// Resets the timer from Running or Paused state.
  /// Restores remaining duration to full configured duration for the
  /// current mode. Transitions to Idle. No-op if Idle or Completed.
  void reset() {
    if (_status != TimerStatus.running && _status != TimerStatus.paused) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    _status = TimerStatus.idle;
    _remainingDuration = _config.durationFor(_currentMode);
    _completedMode = null;
    _activeSessionPlannedDuration = null;
    notifyListeners();
  }

  /// Skips the current session from Running or Paused state.
  /// Advances to next mode in the cycle without persisting.
  /// Transitions to Idle. No-op if Idle or Completed.
  void skip() {
    if (_status != TimerStatus.running && _status != TimerStatus.paused) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    final nextMode = _nextMode();
    if (_currentMode == TimerMode.longBreak) {
      _cycleCount = 0;
    }
    _currentMode = nextMode;
    _status = TimerStatus.idle;
    _remainingDuration = _config.durationFor(_currentMode);
    _completedMode = null;
    _activeSessionPlannedDuration = null;
    notifyListeners();
  }

  /// Sets the task association. Only effective when Idle or Completed.
  void selectTask(int? taskId, String? taskTitle) {
    if (_status != TimerStatus.idle && _status != TimerStatus.completed) {
      return;
    }
    _selectedTaskId = taskId;
    _selectedTaskTitle = taskTitle;
    notifyListeners();
  }

  /// Clears the visible error message. Does NOT discard the pending
  /// session.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Retries the last failed persistence operation.
  Future<void> retryPersistence() async {
    if (_pendingSession != null) {
      try {
        await _saveSessionUseCase.call(_pendingSession!);
        _pendingSession = null;
        _errorMessage = null;
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Unable to save session. Please try again.';
        notifyListeners();
      }
    }
  }

  /// Initializes the controller. Called once after construction.
  /// Registers the lifecycle observer.
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    _availableTasks = List.of(_taskListProvider());
    _isLoading = false;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _status == TimerStatus.running) {
      _recalculateOnResume();
    }
  }

  // --- Private timer methods ---

  void _recalculateOnResume() {
    final remaining = _targetEndTime!.difference(_clock.now());
    if (remaining <= Duration.zero) {
      _onCompletion();
    } else {
      _remainingDuration = remaining;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (_status != TimerStatus.running) return;
    final remaining = _targetEndTime!.difference(_clock.now());
    if (remaining <= Duration.zero) {
      _onCompletion();
    } else {
      _remainingDuration = remaining;
      notifyListeners();
    }
  }

  void _onCompletion() {
    if (_status != TimerStatus.running) return;
    _timer?.cancel();
    _timer = null;
    _completedMode = _currentMode;
    _status = TimerStatus.completed;
    _remainingDuration = Duration.zero;

    if (_currentMode == TimerMode.focus) {
      _cycleCount++;
      _persistSession();
    }

    _playCompletionSound();

    _advanceToNextMode();
    notifyListeners();
  }

  void _playCompletionSound() {
    if (_soundService == null) return;
    if (!(_isSoundEnabled?.call() ?? false)) return;

    final Future<void> playback = switch (_completedMode!) {
      TimerMode.focus => _soundService.playFocusCompleted(),
      TimerMode.shortBreak => _soundService.playBreakCompleted(),
      TimerMode.longBreak => _soundService.playBreakCompleted(),
    };
    unawaited(playback);
  }

  void _advanceToNextMode() {
    final nextMode = _nextMode();
    if (_currentMode == TimerMode.longBreak) {
      _cycleCount = 0;
    }
    _currentMode = nextMode;
    _remainingDuration = _config.durationFor(_currentMode);
  }

  Future<void> _persistSession() async {
    final session = _buildSession();
    _activeSessionPlannedDuration = null;
    try {
      await _saveSessionUseCase.call(session);
    } catch (e) {
      _pendingSession = session;
      _errorMessage = 'Unable to save session. Please try again.';
      notifyListeners();
    }
  }

  String? _resolveTaskTitleSnapshot() {
    if (_selectedTaskId == null) return null;
    final match = _availableTasks
        .where((t) => t.id == _selectedTaskId)
        .firstOrNull;
    if (match != null) return match.title;
    return _selectedTaskTitle;
  }

  PomodoroSession _buildSession() {
    return PomodoroSession(
      id: 0,
      timerMode: TimerMode.focus,
      startedAt: _sessionStartedAt!,
      completedAt: _clock.now(),
      plannedDurationSeconds:
          (_activeSessionPlannedDuration ?? _config.focusDuration).inSeconds,
      actualDurationSeconds:
          (_activeSessionPlannedDuration ?? _config.focusDuration).inSeconds,
      taskId: _selectedTaskId,
      taskTitleSnapshot: _resolveTaskTitleSnapshot(),
    );
  }

  TimerMode _nextMode() {
    switch (_currentMode) {
      case TimerMode.focus:
        if (_cycleCount >= _config.sessionsBeforeLongBreak) {
          return TimerMode.longBreak;
        }
        return TimerMode.shortBreak;
      case TimerMode.shortBreak:
        return TimerMode.focus;
      case TimerMode.longBreak:
        return TimerMode.focus;
    }
  }

  /// Replaces the Pomodoro duration configuration atomically.
  ///
  /// No-op if [newConfig] is equal to the current config.
  /// When the timer is idle or completed, updates [remainingDuration]
  /// immediately to reflect the new duration. When running or paused,
  /// the remaining duration is left unchanged (deferred until next
  /// session start, reset, or transition).
  void updateConfig(PomodoroConfig newConfig) {
    if (newConfig == _config) return;
    _config = newConfig;
    if (_status == TimerStatus.idle || _status == TimerStatus.completed) {
      _remainingDuration = _config.durationFor(_currentMode);
    }
    notifyListeners();
  }

  /// Replaces the available task options with [tasks].
  ///
  /// Notifies listeners only when the list contents actually changed.
  /// Preserves the currently selected task when it still exists in the
  /// new list. Keeps the selected task title as fallback if the task
  /// was deleted.
  void updateAvailableTasks(List<PomodoroTaskOption> tasks) {
    // Check if contents changed (shallow comparison by id, title,
    // isCompleted).
    if (_listsEqual(_availableTasks, tasks)) return;

    _availableTasks = List.of(tasks);

    // Preserve selection if task still exists.
    if (_selectedTaskId != null) {
      final stillExists = _availableTasks.any((t) => t.id == _selectedTaskId);
      if (stillExists) {
        // Update title in case it changed.
        final current = _availableTasks.firstWhere(
          (t) => t.id == _selectedTaskId,
        );
        _selectedTaskTitle = current.title;
      }
      // If deleted, keep _selectedTaskId and _selectedTaskTitle as
      // fallback. The title snapshot is preserved for session
      // persistence.
    }

    notifyListeners();
  }

  bool _listsEqual(List<PomodoroTaskOption> a, List<PomodoroTaskOption> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].title != b[i].title ||
          a[i].isCompleted != b[i].isCompleted) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
