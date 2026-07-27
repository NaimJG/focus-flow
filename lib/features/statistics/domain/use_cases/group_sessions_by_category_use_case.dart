import '../entities/category_focus_statistics.dart';
import '../entities/focus_session.dart';
import '../entities/statistics_task_category_option.dart';

/// Groups focus sessions by category and computes per-category
/// statistics including total time, session count, and percentage
/// of the grand total.
///
/// Sessions whose `taskId` maps to a [StatisticsTaskCategoryOption]
/// with a non-null `categoryId` are assigned to that category.
/// All other sessions (no `taskId`, unmapped `taskId`, or null
/// `categoryId` in the mapping) are grouped under "Uncategorized"
/// with a null `categoryId`.
///
/// Results are sorted by `totalFocusedSeconds` descending.
class GroupSessionsByCategoryUseCase {
  const GroupSessionsByCategoryUseCase();

  /// Returns category groups derived from [sessions] using
  /// [taskCategoryMapping] to resolve each session's category.
  ///
  /// Returns an empty list when [sessions] is empty.
  List<CategoryFocusStatistics> call(
    List<FocusSession> sessions,
    List<StatisticsTaskCategoryOption> taskCategoryMapping,
  ) {
    if (sessions.isEmpty) {
      return [];
    }

    // Build O(1) lookup map from taskId → mapping entry.
    final mappingByTaskId = <int, StatisticsTaskCategoryOption>{};
    for (final mapping in taskCategoryMapping) {
      mappingByTaskId[mapping.taskId] = mapping;
    }

    final grandTotal = sessions.fold<int>(
      0,
      (sum, s) => sum + s.actualDurationSeconds,
    );

    // Group sessions by categoryId (null = "Uncategorized").
    final groups = <int?, _CategoryAccumulator>{};
    for (final session in sessions) {
      final mapping = session.taskId != null
          ? mappingByTaskId[session.taskId]
          : null;
      final categoryId = mapping?.categoryId;
      final categoryName = mapping?.categoryName;

      final accumulator = groups.putIfAbsent(
        categoryId,
        () => _CategoryAccumulator(
          categoryId: categoryId,
          displayName: categoryId != null
              ? (categoryName ?? 'Uncategorized')
              : 'Uncategorized',
        ),
      );
      accumulator.totalFocusedSeconds += session.actualDurationSeconds;
      accumulator.sessionCount++;
    }

    final results = groups.values.map((acc) {
      final percentage = grandTotal > 0
          ? acc.totalFocusedSeconds / grandTotal
          : 0.0;
      return CategoryFocusStatistics(
        categoryId: acc.categoryId,
        displayName: acc.displayName,
        totalFocusedSeconds: acc.totalFocusedSeconds,
        sessionCount: acc.sessionCount,
        percentage: percentage,
      );
    }).toList();

    results.sort(
      (a, b) => b.totalFocusedSeconds.compareTo(a.totalFocusedSeconds),
    );

    return results;
  }
}

/// Internal accumulator for building category groups.
class _CategoryAccumulator {
  _CategoryAccumulator({required this.categoryId, required this.displayName});

  final int? categoryId;
  final String displayName;
  int totalFocusedSeconds = 0;
  int sessionCount = 0;
}
