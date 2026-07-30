import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/timer_mode.dart';

/// Returns the localized display label for a [TimerMode] value.
///
/// Maps each mode to its human-readable name (e.g., "Enfoque" / "Focus").
String timerModeLabel(TimerMode mode, AppLocalizations l10n) => switch (mode) {
  TimerMode.focus => l10n.pomodoroModeFocus,
  TimerMode.shortBreak => l10n.pomodoroModeShortBreak,
  TimerMode.longBreak => l10n.pomodoroModeLongBreak,
};

/// Returns the localized completion message for a [TimerMode].
///
/// If [mode] is null, returns a generic session-completed message.
/// Otherwise returns a mode-specific message (e.g.,
/// "Sesión de enfoque terminada" / "Focus session finished").
String timerModeCompletedLabel(TimerMode? mode, AppLocalizations l10n) =>
    switch (mode) {
      TimerMode.focus => l10n.pomodoroCompletedFocus,
      TimerMode.shortBreak => l10n.pomodoroCompletedShortBreak,
      TimerMode.longBreak => l10n.pomodoroCompletedLongBreak,
      null => l10n.pomodoroCompletedGeneric(l10n.pomodoroTitle),
    };

/// Returns the localized next-ready message for a [TimerMode].
///
/// Indicates the next session is ready to begin (e.g.,
/// "Enfoque listo" / "Focus ready").
String timerModeNextReadyLabel(TimerMode mode, AppLocalizations l10n) =>
    switch (mode) {
      TimerMode.focus => l10n.pomodoroNextFocus,
      TimerMode.shortBreak => l10n.pomodoroNextShortBreak,
      TimerMode.longBreak => l10n.pomodoroNextLongBreak,
    };
