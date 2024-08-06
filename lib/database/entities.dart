import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'connect_db.dart' as db_conn;
part 'entities.g.dart';

class PlaylistTable extends Table {
  TextColumn get spotifyID => text()();

  @override
  Set<Column> get primaryKey => {spotifyID};
}

@DriftDatabase(tables: [PlaylistTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(db_conn.openConnection());
  AppDatabase.customExecutor(super.e);

  Future<Playlist> rowToPlaylist(PlaylistTableData playlist) async {
    return await GetIt.I<APIUtils>().getPlaylist(playlist.spotifyID);
  }

  Future<List<Playlist>> getAllPlaylists() async {
    List<PlaylistTableData> playlists = await select(playlistTable).get();
    return Future.wait(playlists.map((playlist) => rowToPlaylist(playlist)));
  }

  Future<List<String>> getAllPlaylistIDs() async {
    return (await select(playlistTable).get()).map((playlist) => playlist.spotifyID).toList();
  }

  Future<void> addPlaylist(String spotifyID) async {
    if ((await (select(playlistTable)..where((tbl) => tbl.spotifyID.equals(spotifyID))).get()).isEmpty) {
      await into(playlistTable).insert(PlaylistTableData(spotifyID: spotifyID));
    }
  }

  Future<void> deletePlaylist(String spotifyID) async {
    await (delete(playlistTable)..where((tbl) => tbl.spotifyID.equals(spotifyID))).go();
  }

  Future<void> deleteAllPlaylists() async {
    await delete(playlistTable).go();
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async => await m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          m.database.customStatement('DROP TABLE track_table');
        }
        if (from < 3) {
          m.database.customStatement('ALTER TABLE playlist_table ADD PRIMARY KEY (spotifyID)');
          m.database.customStatement('ALTER TABLE playlist_table DROP COLUMN imgUrl, name, id');
        }
      },
    );
  }
}
