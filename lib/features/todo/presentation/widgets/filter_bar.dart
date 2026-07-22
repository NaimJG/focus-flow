import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/task_status.dart';

/// A horizontally scrollable row of [FilterChip] widgets for filtering tasks
/// by status, priority, and category.
///
/// When [hasActiveFilters] is true, a "Clear all" chip is appended.
class FilterBar extends StatelessWidget {
  /// Creates a filter bar.
  const FilterBar({
    super.key,
    required this.activeStatus,
    required this.activePriority,
    required this.activeCategoryId,
    required this.categories,
    required this.hasActiveFilters,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onClearAll,
  });

  /// The currently active status filter, or `null` if no status filter.
  final TaskStatus? activeStatus;

  /// The currently active priority filter, or `null` if no priority filter.
  final Priority? activePriority;

  /// The currently active category filter, or `null` if showing all categories.
  /// A value of `-1` represents "Uncategorized".
  final int? activeCategoryId;

  /// All available categories for building category filter chips.
  final List<Category> categories;

  /// Whether any filter is currently active.
  final bool hasActiveFilters;

  /// Called when the status filter changes.
  final ValueChanged<TaskStatus?> onStatusChanged;

  /// Called when the priority filter changes.
  final ValueChanged<Priority?> onPriorityChanged;

  /// Called when the category filter changes.
  final ValueChanged<int?> onCategoryChanged;

  /// Called when the user taps "Clear all" to reset all filters.
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          // Status filters
          FilterChip(
            label: const Text('Pending'),
            selected: activeStatus == TaskStatus.pending,
            onSelected: (_) {
              onStatusChanged(
                activeStatus == TaskStatus.pending
                    ? null
                    : TaskStatus.pending,
              );
            },
          ),
          FilterChip(
            label: const Text('Completed'),
            selected: activeStatus == TaskStatus.completed,
            onSelected: (_) {
              onStatusChanged(
                activeStatus == TaskStatus.completed
                    ? null
                    : TaskStatus.completed,
              );
            },
          ),

          // Priority filters
          FilterChip(
            label: const Text('High'),
            selected: activePriority == Priority.high,
            onSelected: (_) {
              onPriorityChanged(
                activePriority == Priority.high ? null : Priority.high,
              );
            },
          ),
          FilterChip(
            label: const Text('Medium'),
            selected: activePriority == Priority.medium,
            onSelected: (_) {
              onPriorityChanged(
                activePriority == Priority.medium ? null : Priority.medium,
              );
            },
          ),
          FilterChip(
            label: const Text('Low'),
            selected: activePriority == Priority.low,
            onSelected: (_) {
              onPriorityChanged(
                activePriority == Priority.low ? null : Priority.low,
              );
            },
          ),

          // Category filters
          FilterChip(
            label: const Text('Uncategorized'),
            selected: activeCategoryId == -1,
            onSelected: (_) {
              onCategoryChanged(
                activeCategoryId == -1 ? null : -1,
              );
            },
          ),
          ...categories.map(
            (category) => FilterChip(
              label: Text(category.name),
              selected: activeCategoryId == category.id,
              onSelected: (_) {
                onCategoryChanged(
                  activeCategoryId == category.id ? null : category.id,
                );
              },
            ),
          ),

          // Clear all
          if (hasActiveFilters)
            ActionChip(
              label: const Text('Clear all'),
              onPressed: onClearAll,
            ),
        ],
      ),
    );
  }
}
