import 'package:flutter/material.dart';

/// Describes which empty state scenario to display.
enum EmptyStateVariant {
  /// No tasks created yet — shows a CTA button.
  noTasks,

  /// Search query returned nothing.
  noSearchResults,

  /// Active filters returned nothing.
  noFilterResults,

  /// Selected category has no tasks.
  noCategoryTasks,
}

/// Displays a centered empty state with an icon, headline, supporting text,
/// and an optional call-to-action button.
///
/// The content varies based on [variant].
class EmptyStateWidget extends StatelessWidget {
  /// Creates an empty state widget for the given [variant].
  const EmptyStateWidget({
    super.key,
    required this.variant,
    this.onAction,
  });

  /// The type of empty state to display.
  final EmptyStateVariant variant;

  /// Optional callback for the CTA button (only shown for [EmptyStateVariant.noTasks]).
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final icon = _iconForVariant(variant);
    final headline = _headlineForVariant(variant);
    final message = _messageForVariant(variant);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              headline,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (variant == EmptyStateVariant.noTasks &&
                onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: const Text('Create Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconForVariant(EmptyStateVariant variant) {
    switch (variant) {
      case EmptyStateVariant.noTasks:
        return Icons.task_alt;
      case EmptyStateVariant.noSearchResults:
        return Icons.search_off;
      case EmptyStateVariant.noFilterResults:
        return Icons.filter_list_off;
      case EmptyStateVariant.noCategoryTasks:
        return Icons.folder_off;
    }
  }

  String _headlineForVariant(EmptyStateVariant variant) {
    switch (variant) {
      case EmptyStateVariant.noTasks:
        return 'No tasks yet';
      case EmptyStateVariant.noSearchResults:
        return 'No results';
      case EmptyStateVariant.noFilterResults:
        return 'No matching tasks';
      case EmptyStateVariant.noCategoryTasks:
        return 'No tasks in this category';
    }
  }

  String _messageForVariant(EmptyStateVariant variant) {
    switch (variant) {
      case EmptyStateVariant.noTasks:
        return 'Create your first task to get started';
      case EmptyStateVariant.noSearchResults:
        return 'Try a different search term';
      case EmptyStateVariant.noFilterResults:
        return 'Adjust your filters to see more tasks';
      case EmptyStateVariant.noCategoryTasks:
        return 'Tasks assigned to this category will appear here';
    }
  }
}
