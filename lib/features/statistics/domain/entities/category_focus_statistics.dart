/// Focus data grouped by category.
class CategoryFocusStatistics {
  /// Creates a [CategoryFocusStatistics] instance.
  const CategoryFocusStatistics({
    required this.categoryId,
    required this.displayName,
    required this.totalFocusedSeconds,
    required this.sessionCount,
    required this.percentage,
  });

  /// Null for the "Uncategorized" group.
  final int? categoryId;

  /// Category name or "Uncategorized".
  final String displayName;

  /// Total focused seconds for this category.
  final int totalFocusedSeconds;

  /// Number of completed sessions in this category.
  final int sessionCount;

  /// Percentage of total focused time (0.0–1.0).
  final double percentage;
}
