import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shuffler/components/playlist.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'entities.g.dart';

class PlaylistTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get imgUrl => text().nullable()();
  TextColumn get spotifyID => text()();
}

@DriftDatabase(tables: [PlaylistTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
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

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationSupportDirectory();
    print(dbFolder.path);
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
