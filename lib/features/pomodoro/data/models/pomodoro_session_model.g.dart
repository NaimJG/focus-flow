// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPomodoroSessionModelCollection on Isar {
  IsarCollection<PomodoroSessionModel> get pomodoroSessionModels =>
      this.collection();
}

const PomodoroSessionModelSchema = CollectionSchema(
  name: r'PomodoroSessionModel',
  id: -4261804283330556400,
  properties: {
    r'actualDurationSeconds': PropertySchema(
      id: 0,
      name: r'actualDurationSeconds',
      type: IsarType.long,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'plannedDurationSeconds': PropertySchema(
      id: 2,
      name: r'plannedDurationSeconds',
      type: IsarType.long,
    ),
    r'startedAt': PropertySchema(
      id: 3,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'taskId': PropertySchema(
      id: 4,
      name: r'taskId',
      type: IsarType.long,
    ),
    r'taskTitleSnapshot': PropertySchema(
      id: 5,
      name: r'taskTitleSnapshot',
      type: IsarType.string,
    ),
    r'timerModeIndex': PropertySchema(
      id: 6,
      name: r'timerModeIndex',
      type: IsarType.long,
    )
  },
  estimateSize: _pomodoroSessionModelEstimateSize,
  serialize: _pomodoroSessionModelSerialize,
  deserialize: _pomodoroSessionModelDeserialize,
  deserializeProp: _pomodoroSessionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'startedAt': IndexSchema(
      id: 8114395319341636597,
      name: r'startedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'taskId': IndexSchema(
      id: -6391211041487498726,
      name: r'taskId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pomodoroSessionModelGetId,
  getLinks: _pomodoroSessionModelGetLinks,
  attach: _pomodoroSessionModelAttach,
  version: '3.1.0+1',
);

int _pomodoroSessionModelEstimateSize(
  PomodoroSessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.taskTitleSnapshot;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _pomodoroSessionModelSerialize(
  PomodoroSessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actualDurationSeconds);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeLong(offsets[2], object.plannedDurationSeconds);
  writer.writeDateTime(offsets[3], object.startedAt);
  writer.writeLong(offsets[4], object.taskId);
  writer.writeString(offsets[5], object.taskTitleSnapshot);
  writer.writeLong(offsets[6], object.timerModeIndex);
}

PomodoroSessionModel _pomodoroSessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PomodoroSessionModel();
  object.actualDurationSeconds = reader.readLong(offsets[0]);
  object.completedAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.plannedDurationSeconds = reader.readLong(offsets[2]);
  object.startedAt = reader.readDateTime(offsets[3]);
  object.taskId = reader.readLongOrNull(offsets[4]);
  object.taskTitleSnapshot = reader.readStringOrNull(offsets[5]);
  object.timerModeIndex = reader.readLong(offsets[6]);
  return object;
}

P _pomodoroSessionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pomodoroSessionModelGetId(PomodoroSessionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pomodoroSessionModelGetLinks(
    PomodoroSessionModel object) {
  return [];
}

void _pomodoroSessionModelAttach(
    IsarCollection<dynamic> col, Id id, PomodoroSessionModel object) {
  object.id = id;
}

extension PomodoroSessionModelQueryWhereSort
    on QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QWhere> {
  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhere>
      anyStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startedAt'),
      );
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhere>
      anyTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'taskId'),
      );
    });
  }
}

extension PomodoroSessionModelQueryWhere
    on QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QWhereClause> {
  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      startedAtEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startedAt',
        value: [startedAt],
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      startedAtNotEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [],
              upper: [startedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [startedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [startedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [],
              upper: [startedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      startedAtGreaterThan(
    DateTime startedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [startedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      startedAtLessThan(
    DateTime startedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [],
        upper: [startedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      startedAtBetween(
    DateTime lowerStartedAt,
    DateTime upperStartedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [lowerStartedAt],
        includeLower: includeLower,
        upper: [upperStartedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      taskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      taskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'taskId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      taskIdEqualTo(int? taskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskId',
        value: [taskId],
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      taskIdNotEqualTo(int? taskId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      taskIdGreaterThan(
    int? taskId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'taskId',
        lower: [taskId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      taskIdLessThan(
    int? taskId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'taskId',
        lower: [],
        upper: [taskId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterWhereClause>
      taskIdBetween(
    int? lowerTaskId,
    int? upperTaskId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'taskId',
        lower: [lowerTaskId],
        includeLower: includeLower,
        upper: [upperTaskId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PomodoroSessionModelQueryFilter on QueryBuilder<PomodoroSessionModel,
    PomodoroSessionModel, QFilterCondition> {
  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> actualDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> actualDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> actualDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> actualDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> completedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> completedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> completedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> completedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> plannedDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plannedDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> plannedDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plannedDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> plannedDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plannedDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> plannedDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plannedDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'taskId',
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'taskId',
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskId',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskId',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'taskTitleSnapshot',
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'taskTitleSnapshot',
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskTitleSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskTitleSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskTitleSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskTitleSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskTitleSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskTitleSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
          QAfterFilterCondition>
      taskTitleSnapshotContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskTitleSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
          QAfterFilterCondition>
      taskTitleSnapshotMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskTitleSnapshot',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskTitleSnapshot',
        value: '',
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> taskTitleSnapshotIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskTitleSnapshot',
        value: '',
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> timerModeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timerModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> timerModeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timerModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> timerModeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timerModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel,
      QAfterFilterCondition> timerModeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timerModeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PomodoroSessionModelQueryObject on QueryBuilder<PomodoroSessionModel,
    PomodoroSessionModel, QFilterCondition> {}

extension PomodoroSessionModelQueryLinks on QueryBuilder<PomodoroSessionModel,
    PomodoroSessionModel, QFilterCondition> {}

extension PomodoroSessionModelQuerySortBy
    on QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QSortBy> {
  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByActualDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByActualDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByPlannedDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByPlannedDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByTaskTitleSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskTitleSnapshot', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByTaskTitleSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskTitleSnapshot', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByTimerModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerModeIndex', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      sortByTimerModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerModeIndex', Sort.desc);
    });
  }
}

extension PomodoroSessionModelQuerySortThenBy
    on QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QSortThenBy> {
  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByActualDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByActualDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByPlannedDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByPlannedDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByTaskTitleSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskTitleSnapshot', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByTaskTitleSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskTitleSnapshot', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByTimerModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerModeIndex', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QAfterSortBy>
      thenByTimerModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timerModeIndex', Sort.desc);
    });
  }
}

extension PomodoroSessionModelQueryWhereDistinct
    on QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct> {
  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct>
      distinctByActualDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct>
      distinctByPlannedDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct>
      distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct>
      distinctByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId');
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct>
      distinctByTaskTitleSnapshot({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskTitleSnapshot',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PomodoroSessionModel, PomodoroSessionModel, QDistinct>
      distinctByTimerModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timerModeIndex');
    });
  }
}

extension PomodoroSessionModelQueryProperty on QueryBuilder<
    PomodoroSessionModel, PomodoroSessionModel, QQueryProperty> {
  QueryBuilder<PomodoroSessionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PomodoroSessionModel, int, QQueryOperations>
      actualDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionModel, DateTime, QQueryOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<PomodoroSessionModel, int, QQueryOperations>
      plannedDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedDurationSeconds');
    });
  }

  QueryBuilder<PomodoroSessionModel, DateTime, QQueryOperations>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<PomodoroSessionModel, int?, QQueryOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }

  QueryBuilder<PomodoroSessionModel, String?, QQueryOperations>
      taskTitleSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskTitleSnapshot');
    });
  }

  QueryBuilder<PomodoroSessionModel, int, QQueryOperations>
      timerModeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timerModeIndex');
    });
  }
}
