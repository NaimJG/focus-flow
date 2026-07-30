// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationTodo => 'Todo';

  @override
  String get navigationPomodoro => 'Pomodoro';

  @override
  String get navigationStatistics => 'Statistics';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get sharedCancel => 'Cancel';

  @override
  String get sharedDelete => 'Delete';

  @override
  String get sharedRetry => 'Retry';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get todoTitle => 'Tasks';

  @override
  String get todoCreateTask => 'Create Task';

  @override
  String get todoDeleteTitle => 'Delete Task';

  @override
  String get todoDeleteMessage =>
      'Are you sure you want to delete this task? This action cannot be undone.';

  @override
  String get todoSearchHint => 'Search tasks...';

  @override
  String get todoSearchClear => 'Clear search';

  @override
  String get todoCategoriesTooltip => 'Categories';

  @override
  String get todoCategoriesSemantics => 'Manage categories';

  @override
  String get todoFilterPending => 'Pending';

  @override
  String get todoFilterCompleted => 'Completed';

  @override
  String get todoFilterHigh => 'High';

  @override
  String get todoFilterMedium => 'Medium';

  @override
  String get todoFilterLow => 'Low';

  @override
  String get todoFilterUncategorized => 'Uncategorized';

  @override
  String get todoFilterClearAll => 'Clear all';

  @override
  String get todoSortDate => 'Date';

  @override
  String get todoSortPriority => 'Priority';

  @override
  String get todoSortAlphabetical => 'A–Z';

  @override
  String get todoEmptyNoTasksHeadline => 'No tasks yet';

  @override
  String get todoEmptyNoTasksMessage => 'Create your first task to get started';

  @override
  String get todoEmptyNoSearchResultsHeadline => 'No results';

  @override
  String get todoEmptyNoSearchResultsMessage => 'Try a different search term';

  @override
  String get todoEmptyNoFilterResultsHeadline => 'No matching tasks';

  @override
  String get todoEmptyNoFilterResultsMessage =>
      'Adjust your filters to see more tasks';

  @override
  String get todoEmptyNoCategoryTasksHeadline => 'No tasks in this category';

  @override
  String get todoEmptyNoCategoryTasksMessage =>
      'Tasks assigned to this category will appear here';

  @override
  String get pomodoroTitle => 'Pomodoro';

  @override
  String get pomodoroModeFocus => 'Focus';

  @override
  String get pomodoroModeShortBreak => 'Short Break';

  @override
  String get pomodoroModeLongBreak => 'Long Break';

  @override
  String get pomodoroStatusReady => 'Ready';

  @override
  String get pomodoroStatusRunning => 'Running';

  @override
  String get pomodoroStatusPaused => 'Paused';

  @override
  String get pomodoroControlStart => 'Start';

  @override
  String get pomodoroControlPause => 'Pause';

  @override
  String get pomodoroControlResume => 'Resume';

  @override
  String get pomodoroControlReset => 'Reset';

  @override
  String get pomodoroControlSkip => 'Skip';

  @override
  String get pomodoroCompletedFocus => 'Focus session finished';

  @override
  String get pomodoroCompletedShortBreak => 'Short break finished';

  @override
  String get pomodoroCompletedLongBreak => 'Long break finished';

  @override
  String pomodoroCompletedGeneric(String mode) {
    return '$mode finished';
  }

  @override
  String get pomodoroNextFocus => 'Focus ready';

  @override
  String get pomodoroNextShortBreak => 'Short break ready';

  @override
  String get pomodoroNextLongBreak => 'Long break ready';

  @override
  String get pomodoroSessionNotSaved => 'Session not saved — tap to retry';

  @override
  String get pomodoroAnnounceReady => 'Timer ready';

  @override
  String get pomodoroAnnounceRunning => 'Timer running';

  @override
  String get pomodoroAnnouncePaused => 'Timer paused';

  @override
  String pomodoroAnnounceCompleted(String mode) {
    return '$mode finished';
  }
}
