// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entities.dart';

// ignore_for_file: type=lint
class $PlaylistTableTable extends PlaylistTable
    with TableInfo<$PlaylistTableTable, PlaylistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _spotifyIDMeta =
      const VerificationMeta('spotifyID');
  @override
  late final GeneratedColumn<String> spotifyID = GeneratedColumn<String>(
      'spotify_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [spotifyID];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_table';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('spotify_i_d')) {
      context.handle(
          _spotifyIDMeta,
          spotifyID.isAcceptableOrUnknown(
              data['spotify_i_d']!, _spotifyIDMeta));
    } else if (isInserting) {
      context.missing(_spotifyIDMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {spotifyID};
  @override
  PlaylistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTableData(
      spotifyID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}spotify_i_d'])!,
    );
  }

  @override
  $PlaylistTableTable createAlias(String alias) {
    return $PlaylistTableTable(attachedDatabase, alias);
  }
}

class PlaylistTableData extends DataClass
    implements Insertable<PlaylistTableData> {
  final String spotifyID;
  const PlaylistTableData({required this.spotifyID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['spotify_i_d'] = Variable<String>(spotifyID);
    return map;
  }

  PlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTableCompanion(
      spotifyID: Value(spotifyID),
    );
  }

  factory PlaylistTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTableData(
      spotifyID: serializer.fromJson<String>(json['spotifyID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'spotifyID': serializer.toJson<String>(spotifyID),
    };
  }

  PlaylistTableData copyWith({String? spotifyID}) => PlaylistTableData(
        spotifyID: spotifyID ?? this.spotifyID,
      );
  PlaylistTableData copyWithCompanion(PlaylistTableCompanion data) {
    return PlaylistTableData(
      spotifyID: data.spotifyID.present ? data.spotifyID.value : this.spotifyID,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableData(')
          ..write('spotifyID: $spotifyID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => spotifyID.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTableData && other.spotifyID == this.spotifyID);
}

class PlaylistTableCompanion extends UpdateCompanion<PlaylistTableData> {
  final Value<String> spotifyID;
  final Value<int> rowid;
  const PlaylistTableCompanion({
    this.spotifyID = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTableCompanion.insert({
    required String spotifyID,
    this.rowid = const Value.absent(),
  }) : spotifyID = Value(spotifyID);
  static Insertable<PlaylistTableData> custom({
    Expression<String>? spotifyID,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (spotifyID != null) 'spotify_i_d': spotifyID,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTableCompanion copyWith(
      {Value<String>? spotifyID, Value<int>? rowid}) {
    return PlaylistTableCompanion(
      spotifyID: spotifyID ?? this.spotifyID,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (spotifyID.present) {
      map['spotify_i_d'] = Variable<String>(spotifyID.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableCompanion(')
          ..write('spotifyID: $spotifyID, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [playlistTable];
}

typedef $$PlaylistTableTableCreateCompanionBuilder = PlaylistTableCompanion
    Function({
  required String spotifyID,
  Value<int> rowid,
});
typedef $$PlaylistTableTableUpdateCompanionBuilder = PlaylistTableCompanion
    Function({
  Value<String> spotifyID,
  Value<int> rowid,
});

class $$PlaylistTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get spotifyID => $composableBuilder(
      column: $table.spotifyID, builder: (column) => ColumnFilters(column));
}

class $$PlaylistTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get spotifyID => $composableBuilder(
      column: $table.spotifyID, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get spotifyID =>
      $composableBuilder(column: $table.spotifyID, builder: (column) => column);
}

class $$PlaylistTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistTableTable,
    PlaylistTableData,
    $$PlaylistTableTableFilterComposer,
    $$PlaylistTableTableOrderingComposer,
    $$PlaylistTableTableAnnotationComposer,
    $$PlaylistTableTableCreateCompanionBuilder,
    $$PlaylistTableTableUpdateCompanionBuilder,
    (
      PlaylistTableData,
      BaseReferences<_$AppDatabase, $PlaylistTableTable, PlaylistTableData>
    ),
    PlaylistTableData,
    PrefetchHooks Function()> {
  $$PlaylistTableTableTableManager(_$AppDatabase db, $PlaylistTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> spotifyID = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTableCompanion(
            spotifyID: spotifyID,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String spotifyID,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTableCompanion.insert(
            spotifyID: spotifyID,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaylistTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistTableTable,
    PlaylistTableData,
    $$PlaylistTableTableFilterComposer,
    $$PlaylistTableTableOrderingComposer,
    $$PlaylistTableTableAnnotationComposer,
    $$PlaylistTableTableCreateCompanionBuilder,
    $$PlaylistTableTableUpdateCompanionBuilder,
    (
      PlaylistTableData,
      BaseReferences<_$AppDatabase, $PlaylistTableTable, PlaylistTableData>
    ),
    PlaylistTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
}
