/// Read-only mapping entry from a task to its category.
///
/// Provided by the app composition root from TodoController data.
/// Used by [GroupSessionsByCategoryUseCase] to resolve which category
/// a session's task belongs to.
class StatisticsTaskCategoryOption {
  const StatisticsTaskCategoryOption({
    required this.taskId,
    this.categoryId,
    this.categoryName,
  });

  /// The task identifier.
  final int taskId;

  /// The category this task belongs to, or null if uncategorized.
  final int? categoryId;

  /// Category display name, or null if uncategorized.
  final String? categoryName;
}
