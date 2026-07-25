import 'package:isar/isar.dart';

import '../../domain/entities/pomodoro_session.dart';
import '../../domain/entities/timer_mode.dart';

part 'pomodoro_session_model.g.dart';

/// Isar collection representing a persisted Pomodoro session.
///
/// Maps between the domain [PomodoroSession] entity and the Isar
/// database schema. Only completed Focus sessions are persisted in
/// the MVP.
@collection
class PomodoroSessionModel {
  /// Isar auto-increment primary key.
  Id id = Isar.autoIncrement;

  /// Stored index of [TimerMode] enum.
  late int timerModeIndex;

  /// UTC timestamp when the user first pressed Start for this session.
  @Index(type: IndexType.value)
  late DateTime startedAt;

  /// UTC timestamp when the session completed naturally.
  late DateTime completedAt;

  /// Configured focus duration in seconds at the time of the session.
  late int plannedDurationSeconds;

  /// Active countdown time in seconds (equals planned for natural
  /// completion).
  late int actualDurationSeconds;

  /// Optional reference to the associated Todo task ID.
  @Index(type: IndexType.value)
  late int? taskId;

  /// Snapshot of the task title at persistence time, for historical
  /// reference even if the task is later renamed or deleted.
  late String? taskTitleSnapshot;

  /// Converts this Isar model to a domain [PomodoroSession] entity.
  PomodoroSession toEntity() {
    return PomodoroSession(
      id: id,
      timerMode: TimerMode.values[timerModeIndex],
      startedAt: startedAt,
      completedAt: completedAt,
      plannedDurationSeconds: plannedDurationSeconds,
      actualDurationSeconds: actualDurationSeconds,
      taskId: taskId,
      taskTitleSnapshot: taskTitleSnapshot,
    );
  }

  /// Creates a [PomodoroSessionModel] from a domain [PomodoroSession]
  /// entity.
  static PomodoroSessionModel fromEntity(PomodoroSession session) {
    return PomodoroSessionModel()
      ..id = session.id
      ..timerModeIndex = session.timerMode.index
      ..startedAt = session.startedAt
      ..completedAt = session.completedAt
      ..plannedDurationSeconds = session.plannedDurationSeconds
      ..actualDurationSeconds = session.actualDurationSeconds
      ..taskId = session.taskId
      ..taskTitleSnapshot = session.taskTitleSnapshot;
  }
}
