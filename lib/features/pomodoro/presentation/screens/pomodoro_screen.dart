import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timer_mode.dart';
import '../../domain/entities/timer_status.dart';
import '../controllers/pomodoro_controller.dart';
import '../utils/timer_mode_labels.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final textDirection = Directionality.of(context);

    final String announcement;
    switch (controller.status) {
      case TimerStatus.idle:
        announcement = l10n.pomodoroAnnounceReady;
      case TimerStatus.running:
        announcement = l10n.pomodoroAnnounceRunning;
      case TimerStatus.paused:
        announcement = l10n.pomodoroAnnouncePaused;
      case TimerStatus.completed:
        final modeLabel = timerModeLabel(
          controller.completedMode ?? TimerMode.focus,
          l10n,
        );
        announcement = l10n.pomodoroAnnounceCompleted(modeLabel);
    }
    SemanticsService.sendAnnouncement(
      View.of(context),
      announcement,
      textDirection,
    );
  }

  void _showErrorSnackBar(String message) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: l10n.sharedRetry,
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
    final l10n = AppLocalizations.of(context)!;

    if (controller.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pomodoroTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final status = controller.status;
    final currentMode = controller.currentMode;
    final totalDuration = controller.config.durationFor(currentMode);
    final taskSelectorEnabled =
        status == TimerStatus.idle || status == TimerStatus.completed;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pomodoroTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode label
                Text(
                  timerModeLabel(currentMode, l10n),
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
                  focusSessionProgress: controller.focusSessionProgress,
                  showProgress:
                      controller.currentMode == TimerMode.focus &&
                      (controller.status == TimerStatus.running ||
                          controller.status == TimerStatus.paused),
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
                        l10n.pomodoroSessionNotSaved,
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
}

/// Displays a contextual status label depending on the current timer state.
class _StatusText extends StatelessWidget {
  const _StatusText({required this.controller});

  final PomodoroController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final status = controller.status;

    switch (status) {
      case TimerStatus.idle:
        return Text(
          l10n.pomodoroStatusReady,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case TimerStatus.running:
        return Text(
          l10n.pomodoroStatusRunning,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        );
      case TimerStatus.paused:
        return Text(
          l10n.pomodoroStatusPaused,
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
              timerModeCompletedLabel(completedMode, l10n),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timerModeNextReadyLabel(currentMode, l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
    }
  }
}
