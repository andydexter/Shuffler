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
  _$AppDatabaseManager get managers => _$AppDatabaseManager(this);
  late final $PlaylistTableTable playlistTable = $PlaylistTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [playlistTable];
}

typedef $$PlaylistTableTableInsertCompanionBuilder = PlaylistTableCompanion
    Function({
  required String spotifyID,
  Value<int> rowid,
});
typedef $$PlaylistTableTableUpdateCompanionBuilder = PlaylistTableCompanion
    Function({
  Value<String> spotifyID,
  Value<int> rowid,
});

class $$PlaylistTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistTableTable,
    PlaylistTableData,
    $$PlaylistTableTableFilterComposer,
    $$PlaylistTableTableOrderingComposer,
    $$PlaylistTableTableProcessedTableManager,
    $$PlaylistTableTableInsertCompanionBuilder,
    $$PlaylistTableTableUpdateCompanionBuilder> {
  $$PlaylistTableTableTableManager(_$AppDatabase db, $PlaylistTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PlaylistTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PlaylistTableTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$PlaylistTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> spotifyID = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTableCompanion(
            spotifyID: spotifyID,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String spotifyID,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistTableCompanion.insert(
            spotifyID: spotifyID,
            rowid: rowid,
          ),
        ));
}

class $$PlaylistTableTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $PlaylistTableTable,
    PlaylistTableData,
    $$PlaylistTableTableFilterComposer,
    $$PlaylistTableTableOrderingComposer,
    $$PlaylistTableTableProcessedTableManager,
    $$PlaylistTableTableInsertCompanionBuilder,
    $$PlaylistTableTableUpdateCompanionBuilder> {
  $$PlaylistTableTableProcessedTableManager(super.$state);
}

class $$PlaylistTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableFilterComposer(super.$state);
  ColumnFilters<String> get spotifyID => $state.composableBuilder(
      column: $state.table.spotifyID,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PlaylistTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableOrderingComposer(super.$state);
  ColumnOrderings<String> get spotifyID => $state.composableBuilder(
      column: $state.table.spotifyID,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $$PlaylistTableTableTableManager get playlistTable =>
      $$PlaylistTableTableTableManager(_db, _db.playlistTable);
}
