import 'package:isar/isar.dart';

import '../../domain/entities/pomodoro_session.dart';
import '../../domain/exceptions/persistence_exception.dart';
import '../../domain/repositories/pomodoro_session_repository.dart';
import '../models/pomodoro_session_model.dart';

/// Concrete [PomodoroSessionRepository] implementation backed by Isar.
class IsarPomodoroSessionRepository implements PomodoroSessionRepository {
  /// Creates an [IsarPomodoroSessionRepository] with the given [Isar]
  /// instance.
  const IsarPomodoroSessionRepository({required this.isar});

  /// The Isar database instance used for persistence.
  final Isar isar;

  @override
  Future<PomodoroSession> create(PomodoroSession session) async {
    try {
      final model = PomodoroSessionModel.fromEntity(session)
        ..id = Isar.autoIncrement;

      final generatedId = await isar.writeTxn(
        () => isar.pomodoroSessionModels.put(model),
      );

      model.id = generatedId;
      return model.toEntity();
    } on IsarError catch (e) {
      throw PersistenceException(e.message);
    }
  }

  @override
  Future<List<PomodoroSession>> getAll() async {
    try {
      final models = await isar.pomodoroSessionModels.where().findAll();

      return models.map((model) => model.toEntity()).toList();
    } on IsarError catch (e) {
      throw PersistenceException(e.message);
    }
  }

  @override
  Future<List<PomodoroSession>> getByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final models = await isar.pomodoroSessionModels
          .where()
          .startedAtBetween(start, end, includeUpper: false)
          .findAll();

      return models.map((model) => model.toEntity()).toList();
    } on IsarError catch (e) {
      throw PersistenceException(e.message);
    }
  }

  @override
  Future<List<PomodoroSession>> getByTaskId(int taskId) async {
    try {
      final models = await isar.pomodoroSessionModels
          .where()
          .taskIdEqualTo(taskId)
          .findAll();

      return models.map((model) => model.toEntity()).toList();
    } on IsarError catch (e) {
      throw PersistenceException(e.message);
    }
  }

  @override
  Future<List<PomodoroSession>> getByNullTask() async {
    try {
      final models = await isar.pomodoroSessionModels
          .where()
          .taskIdIsNull()
          .findAll();

      return models.map((model) => model.toEntity()).toList();
    } on IsarError catch (e) {
      throw PersistenceException(e.message);
    }
  }
}
