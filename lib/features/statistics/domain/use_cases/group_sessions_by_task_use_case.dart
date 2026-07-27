import '../entities/focus_session.dart';
import '../entities/task_focus_statistics.dart';

/// Groups focus sessions by [FocusSession.taskId] and computes
/// per-task statistics including total time, session count, and
/// percentage of the grand total.
///
/// Sessions with a null `taskId` are grouped into a single
/// "No task" entry. The display title for each group is taken from
/// the `taskTitleSnapshot` of the session with the latest `startedAt`.
///
/// Results are sorted by `totalFocusedSeconds` descending; ties are
/// broken by `displayTitle` alphabetically (case-insensitive).
class GroupSessionsByTaskUseCase {
  const GroupSessionsByTaskUseCase();

  /// Returns task groups derived from [sessions].
  ///
  /// Returns an empty list when [sessions] is empty.
  List<TaskFocusStatistics> call(List<FocusSession> sessions) {
    if (sessions.isEmpty) {
      return [];
    }

    final grandTotal = sessions.fold<int>(
      0,
      (sum, s) => sum + s.actualDurationSeconds,
    );

    // Group sessions by taskId (null key = "No task" group).
    final groups = <int?, List<FocusSession>>{};
    for (final session in sessions) {
      groups.putIfAbsent(session.taskId, () => []).add(session);
    }

    final results = groups.entries.map((entry) {
      final taskId = entry.key;
      final groupSessions = entry.value;

      final totalFocusedSeconds = groupSessions.fold<int>(
        0,
        (sum, s) => sum + s.actualDurationSeconds,
      );
      final sessionCount = groupSessions.length;
      final percentage = grandTotal > 0
          ? totalFocusedSeconds / grandTotal
          : 0.0;

      // Use the taskTitleSnapshot from the session with the latest
      // startedAt in the group. For null taskId, display "No task".
      final displayTitle = _resolveDisplayTitle(taskId, groupSessions);

      return TaskFocusStatistics(
        taskId: taskId,
        displayTitle: displayTitle,
        totalFocusedSeconds: totalFocusedSeconds,
        sessionCount: sessionCount,
        percentage: percentage,
      );
    }).toList();

    results.sort((a, b) {
      final cmp = b.totalFocusedSeconds.compareTo(a.totalFocusedSeconds);
      if (cmp != 0) return cmp;
      return a.displayTitle.toLowerCase().compareTo(
        b.displayTitle.toLowerCase(),
      );
    });

    return results;
  }

  String _resolveDisplayTitle(int? taskId, List<FocusSession> groupSessions) {
    if (taskId == null) {
      return 'No task';
    }

    // Find the session with the latest startedAt in the group.
    var latest = groupSessions.first;
    for (var i = 1; i < groupSessions.length; i++) {
      if (groupSessions[i].startedAt.isAfter(latest.startedAt)) {
        latest = groupSessions[i];
      }
    }

    return latest.taskTitleSnapshot ?? 'No task';
  }
}
