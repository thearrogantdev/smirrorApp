// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'binary_database.dart';

// ignore_for_file: type=lint
class $BinariesTable extends Binaries
    with TableInfo<$BinariesTable, BinaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BinariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'binaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BinaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BinaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BinaryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
    );
  }

  @override
  $BinariesTable createAlias(String alias) {
    return $BinariesTable(attachedDatabase, alias);
  }
}

class BinaryRow extends DataClass implements Insertable<BinaryRow> {
  final int id;
  final String path;
  const BinaryRow({required this.id, required this.path});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    return map;
  }

  BinariesCompanion toCompanion(bool nullToAbsent) {
    return BinariesCompanion(id: Value(id), path: Value(path));
  }

  factory BinaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BinaryRow(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
    };
  }

  BinaryRow copyWith({int? id, String? path}) =>
      BinaryRow(id: id ?? this.id, path: path ?? this.path);
  BinaryRow copyWithCompanion(BinariesCompanion data) {
    return BinaryRow(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BinaryRow(')
          ..write('id: $id, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BinaryRow && other.id == this.id && other.path == this.path);
}

class BinariesCompanion extends UpdateCompanion<BinaryRow> {
  final Value<int> id;
  final Value<String> path;
  const BinariesCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
  });
  BinariesCompanion.insert({
    this.id = const Value.absent(),
    required String path,
  }) : path = Value(path);
  static Insertable<BinaryRow> custom({
    Expression<int>? id,
    Expression<String>? path,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
    });
  }

  BinariesCompanion copyWith({Value<int>? id, Value<String>? path}) {
    return BinariesCompanion(id: id ?? this.id, path: path ?? this.path);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BinariesCompanion(')
          ..write('id: $id, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }
}

abstract class _$BinaryDatabase extends GeneratedDatabase {
  _$BinaryDatabase(QueryExecutor e) : super(e);
  $BinaryDatabaseManager get managers => $BinaryDatabaseManager(this);
  late final $BinariesTable binaries = $BinariesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [binaries];
}

typedef $$BinariesTableCreateCompanionBuilder =
    BinariesCompanion Function({Value<int> id, required String path});
typedef $$BinariesTableUpdateCompanionBuilder =
    BinariesCompanion Function({Value<int> id, Value<String> path});

class $$BinariesTableFilterComposer
    extends Composer<_$BinaryDatabase, $BinariesTable> {
  $$BinariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BinariesTableOrderingComposer
    extends Composer<_$BinaryDatabase, $BinariesTable> {
  $$BinariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BinariesTableAnnotationComposer
    extends Composer<_$BinaryDatabase, $BinariesTable> {
  $$BinariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);
}

class $$BinariesTableTableManager
    extends
        RootTableManager<
          _$BinaryDatabase,
          $BinariesTable,
          BinaryRow,
          $$BinariesTableFilterComposer,
          $$BinariesTableOrderingComposer,
          $$BinariesTableAnnotationComposer,
          $$BinariesTableCreateCompanionBuilder,
          $$BinariesTableUpdateCompanionBuilder,
          (
            BinaryRow,
            BaseReferences<_$BinaryDatabase, $BinariesTable, BinaryRow>,
          ),
          BinaryRow,
          PrefetchHooks Function()
        > {
  $$BinariesTableTableManager(_$BinaryDatabase db, $BinariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BinariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BinariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BinariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
              }) => BinariesCompanion(id: id, path: path),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String path}) =>
                  BinariesCompanion.insert(id: id, path: path),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BinariesTableProcessedTableManager =
    ProcessedTableManager<
      _$BinaryDatabase,
      $BinariesTable,
      BinaryRow,
      $$BinariesTableFilterComposer,
      $$BinariesTableOrderingComposer,
      $$BinariesTableAnnotationComposer,
      $$BinariesTableCreateCompanionBuilder,
      $$BinariesTableUpdateCompanionBuilder,
      (BinaryRow, BaseReferences<_$BinaryDatabase, $BinariesTable, BinaryRow>),
      BinaryRow,
      PrefetchHooks Function()
    >;

class $BinaryDatabaseManager {
  final _$BinaryDatabase _db;
  $BinaryDatabaseManager(this._db);
  $$BinariesTableTableManager get binaries =>
      $$BinariesTableTableManager(_db, _db.binaries);
}
