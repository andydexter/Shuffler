// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entities.dart';

// ignore_for_file: type=lint
class $PlaylistTableTable extends PlaylistTable
    with TableInfo<$PlaylistTableTable, PlaylistTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imgUrlMeta = const VerificationMeta('imgUrl');
  @override
  late final GeneratedColumn<String> imgUrl = GeneratedColumn<String>(
      'img_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _spotifyIDMeta =
      const VerificationMeta('spotifyID');
  @override
  late final GeneratedColumn<String> spotifyID = GeneratedColumn<String>(
      'spotify_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, imgUrl, spotifyID];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('img_url')) {
      context.handle(_imgUrlMeta,
          imgUrl.isAcceptableOrUnknown(data['img_url']!, _imgUrlMeta));
    }
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      imgUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}img_url']),
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
  final int id;
  final String name;
  final String? imgUrl;
  final String spotifyID;
  const PlaylistTableData(
      {required this.id,
      required this.name,
      this.imgUrl,
      required this.spotifyID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imgUrl != null) {
      map['img_url'] = Variable<String>(imgUrl);
    }
    map['spotify_i_d'] = Variable<String>(spotifyID);
    return map;
  }

  PlaylistTableCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTableCompanion(
      id: Value(id),
      name: Value(name),
      imgUrl:
          imgUrl == null && nullToAbsent ? const Value.absent() : Value(imgUrl),
      spotifyID: Value(spotifyID),
    );
  }

  factory PlaylistTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imgUrl: serializer.fromJson<String?>(json['imgUrl']),
      spotifyID: serializer.fromJson<String>(json['spotifyID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imgUrl': serializer.toJson<String?>(imgUrl),
      'spotifyID': serializer.toJson<String>(spotifyID),
    };
  }

  PlaylistTableData copyWith(
          {int? id,
          String? name,
          Value<String?> imgUrl = const Value.absent(),
          String? spotifyID}) =>
      PlaylistTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        imgUrl: imgUrl.present ? imgUrl.value : this.imgUrl,
        spotifyID: spotifyID ?? this.spotifyID,
      );
  @override
  String toString() {
    return (StringBuffer('PlaylistTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imgUrl: $imgUrl, ')
          ..write('spotifyID: $spotifyID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, imgUrl, spotifyID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.imgUrl == this.imgUrl &&
          other.spotifyID == this.spotifyID);
}

class PlaylistTableCompanion extends UpdateCompanion<PlaylistTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imgUrl;
  final Value<String> spotifyID;
  const PlaylistTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imgUrl = const Value.absent(),
    this.spotifyID = const Value.absent(),
  });
  PlaylistTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imgUrl = const Value.absent(),
    required String spotifyID,
  })  : name = Value(name),
        spotifyID = Value(spotifyID);
  static Insertable<PlaylistTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imgUrl,
    Expression<String>? spotifyID,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imgUrl != null) 'img_url': imgUrl,
      if (spotifyID != null) 'spotify_i_d': spotifyID,
    });
  }

  PlaylistTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? imgUrl,
      Value<String>? spotifyID}) {
    return PlaylistTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imgUrl: imgUrl ?? this.imgUrl,
      spotifyID: spotifyID ?? this.spotifyID,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imgUrl.present) {
      map['img_url'] = Variable<String>(imgUrl.value);
    }
    if (spotifyID.present) {
      map['spotify_i_d'] = Variable<String>(spotifyID.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imgUrl: $imgUrl, ')
          ..write('spotifyID: $spotifyID')
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
  Value<int> id,
  required String name,
  Value<String?> imgUrl,
  required String spotifyID,
});
typedef $$PlaylistTableTableUpdateCompanionBuilder = PlaylistTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> imgUrl,
  Value<String> spotifyID,
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
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> imgUrl = const Value.absent(),
            Value<String> spotifyID = const Value.absent(),
          }) =>
              PlaylistTableCompanion(
            id: id,
            name: name,
            imgUrl: imgUrl,
            spotifyID: spotifyID,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> imgUrl = const Value.absent(),
            required String spotifyID,
          }) =>
              PlaylistTableCompanion.insert(
            id: id,
            name: name,
            imgUrl: imgUrl,
            spotifyID: spotifyID,
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
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imgUrl => $state.composableBuilder(
      column: $state.table.imgUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get spotifyID => $state.composableBuilder(
      column: $state.table.spotifyID,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PlaylistTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PlaylistTableTable> {
  $$PlaylistTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imgUrl => $state.composableBuilder(
      column: $state.table.imgUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

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
