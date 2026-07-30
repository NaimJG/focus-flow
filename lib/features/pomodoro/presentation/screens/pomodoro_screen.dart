import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/timer_mode.dart';
import '../../domain/entities/timer_status.dart';
import '../controllers/pomodoro_controller.dart';
import '../widgets/cycle_progress_indicator.dart';
import '../widgets/task_selector_widget.dart';
import '../widgets/timer_controls.dart';
import '../widgets/timer_display.dart';

/// The primary screen for the Pomodoro timer feature.
///
/// Orchestrates layout of the timer display, controls, cycle indicator,
/// and task selector. Watches the [PomodoroController] for reactive
/// rebuilds and announces status changes for accessibility.
class PomodoroScreen extends StatefulWidget {
  /// Creates a [PomodoroScreen].
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late final PomodoroController _controller;
  TimerStatus? _previousStatus;
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    _controller = context.read<PomodoroController>();
    _previousStatus = _controller.status;
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final controller = context.read<PomodoroController>();

    // Announce status changes for accessibility.
    final currentStatus = controller.status;
    if (currentStatus != _previousStatus) {
      _previousStatus = currentStatus;
      _announceStatusChange(controller);
    }

    // Show SnackBar on new error.
    final error = controller.errorMessage;
    if (error != null && error != _lastShownError) {
      _lastShownError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showErrorSnackBar(error);
      });
    } else if (error == null) {
      _lastShownError = null;
    }
  }

  void _announceStatusChange(PomodoroController controller) {
    final String announcement;
    switch (controller.status) {
      case TimerStatus.idle:
        announcement = 'Timer ready';
      case TimerStatus.running:
        announcement = 'Timer running';
      case TimerStatus.paused:
        announcement = 'Timer paused';
      case TimerStatus.completed:
        final completedLabel = _modeLabelForCompleted(controller.completedMode);
        announcement = '$completedLabel finished';
    }
    SemanticsService.sendAnnouncement(
      View.of(context),
      announcement,
      TextDirection.ltr,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              context.read<PomodoroController>().retryPersistence();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PomodoroController>();
    final theme = Theme.of(context);

    if (controller.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pomodoro')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final status = controller.status;
    final currentMode = controller.currentMode;
    final totalDuration = controller.config.durationFor(currentMode);
    final taskSelectorEnabled =
        status == TimerStatus.idle || status == TimerStatus.completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode label
                Text(
                  _modeLabel(currentMode),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Status text
                _StatusText(controller: controller),
                const SizedBox(height: 24),

                // Timer display
                TimerDisplay(
                  remainingDuration: controller.remainingDuration,
                  totalDuration: totalDuration,
                  status: status,
                ),
                const SizedBox(height: 16),

                // Cycle progress indicator
                CycleProgressIndicator(
                  cycleCount: controller.cycleCount,
                  totalCycles: controller.config.sessionsBeforeLongBreak,
                ),
                const SizedBox(height: 24),

                // Timer controls
                TimerControls(
                  status: status,
                  onStart: controller.start,
                  onPause: controller.pause,
                  onResume: controller.resume,
                  onReset: controller.reset,
                  onSkip: controller.skip,
                ),
                const SizedBox(height: 24),

                // Persistent retry affordance
                if (controller.hasPendingSession)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextButton.icon(
                      onPressed: controller.retryPersistence,
                      icon: Icon(
                        Icons.sync_problem,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Session not saved — tap to retry',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                  ),

                // Task selector
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: TaskSelectorWidget(
                    tasks: controller.availableTasks,
                    selectedTaskId: controller.selectedTaskId,
                    enabled: taskSelectorEnabled,
                    onChanged: (record) {
                      controller.selectTask(record.$1, record.$2);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _modeLabel(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'Focus';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  String _modeLabelForCompleted(TimerMode? mode) {
    if (mode == null) return 'Session';
    switch (mode) {
      case TimerMode.focus:
        return 'Focus session';
      case TimerMode.shortBreak:
        return 'Short break';
      case TimerMode.longBreak:
        return 'Long break';
    }
  }
}

/// Displays a contextual status label depending on the current timer state.
class _StatusText extends StatelessWidget {
  const _StatusText({required this.controller});

  final PomodoroController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = controller.status;

    switch (status) {
      case TimerStatus.idle:
        return Text(
          'Ready',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case TimerStatus.running:
        return Text(
          'Running',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        );
      case TimerStatus.paused:
        return Text(
          'Paused',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        );
      case TimerStatus.completed:
        final completedMode = controller.completedMode;
        final currentMode = controller.currentMode;
        return Column(
          children: [
            Text(
              _completedMessage(completedMode),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _nextReadyMessage(currentMode),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
    }
  }

  String _completedMessage(TimerMode? mode) {
    if (mode == null) return 'Session finished';
    switch (mode) {
      case TimerMode.focus:
        return 'Focus session finished';
      case TimerMode.shortBreak:
        return 'Short break finished';
      case TimerMode.longBreak:
        return 'Long break finished';
    }
  }

  String _nextReadyMessage(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'Focus ready';
      case TimerMode.shortBreak:
        return 'Short break ready';
      case TimerMode.longBreak:
        return 'Long break ready';
    }
  }
}
