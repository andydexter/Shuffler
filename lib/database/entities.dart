import 'package:drift/drift.dart';
import 'package:shuffler/components/playlist.dart';
import 'connect_db.dart' as db_conn;
part 'entities.g.dart';

class PlaylistTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get imgUrl => text().nullable()();
  TextColumn get spotifyID => text()();
}

@DriftDatabase(tables: [PlaylistTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(db_conn.openConnection());
  AppDatabase.customExecutor(super.e);

  Playlist rowToPlaylist(PlaylistTableData playlist) {
    return Playlist(
        name: playlist.name,
        spotifyID: playlist.spotifyID,
        imgUrl: playlist.imgUrl ?? '',
        tracks: const [],
        id: playlist.id);
  }

  PlaylistTableCompanion playlistToRow(Playlist playlist) {
    return PlaylistTableCompanion.insert(
        name: playlist.name, imgUrl: Value(playlist.imgUrl), spotifyID: playlist.spotifyID);
  }

  Future<List<Playlist>> getAllPlaylists() async {
    return await select(playlistTable).map((row) => rowToPlaylist(row)).get();
  }

  Future<void> persistPlaylist(Playlist playlist) async {
    if ((await (select(playlistTable)..where((tbl) => tbl.spotifyID.equals(playlist.spotifyID))).get()).isNotEmpty) {
      await (update(playlistTable)..where((tbl) => tbl.spotifyID.equals(playlist.spotifyID)))
          .write(playlistToRow(playlist));
    } else {
      await into(playlistTable).insert(playlistToRow(playlist));
    }
  }

  @override
  int get schemaVersion => 2;
}
