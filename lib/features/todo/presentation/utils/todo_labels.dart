import '../../../../l10n/app_localizations.dart';

import '../../domain/entities/priority.dart';
import '../../domain/entities/sort_criterion.dart';
import '../../domain/entities/task_status.dart';

/// Returns the localized display label for a [Priority] value.
String priorityLabel(Priority priority, AppLocalizations l10n) =>
    switch (priority) {
      Priority.high => l10n.todoFilterHigh,
      Priority.medium => l10n.todoFilterMedium,
      Priority.low => l10n.todoFilterLow,
    };

/// Returns the localized display label for a [TaskStatus] value.
String taskStatusLabel(TaskStatus status, AppLocalizations l10n) =>
    switch (status) {
      TaskStatus.pending => l10n.todoFilterPending,
      TaskStatus.completed => l10n.todoFilterCompleted,
    };

/// Returns the localized display label for a [SortCriterion] value.
String sortCriterionLabel(SortCriterion criterion, AppLocalizations l10n) =>
    switch (criterion) {
      SortCriterion.creationDate => l10n.todoSortDate,
      SortCriterion.priority => l10n.todoSortPriority,
      SortCriterion.alphabetical => l10n.todoSortAlphabetical,
    };
