import 'package:flutter/material.dart';

import '../../domain/entities/category_focus_statistics.dart';
import '../utils/duration_formatter.dart';
import 'breakdown_item.dart';

/// Displays a vertical list of [BreakdownItem] widgets grouped by category.
///
/// Shows a "By Category" section header followed by one row per
/// [CategoryFocusStatistics] entry.
class CategoryBreakdownList extends StatelessWidget {
  /// Creates a [CategoryBreakdownList].
  const CategoryBreakdownList({super.key, required this.categoryData});

  /// Category-level focus statistics to display.
  final List<CategoryFocusStatistics> categoryData;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('By Category', style: textTheme.titleMedium),
        ),
        ...categoryData.map(
          (category) => BreakdownItem(
            title: category.displayName,
            formattedTime: formatDuration(category.totalFocusedSeconds),
            sessionCount: category.sessionCount,
            percentage: category.percentage,
          ),
        ),
      ],
    );
  }
}
