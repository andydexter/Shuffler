///
///     Copyright (C) 2024  Andreas Nicolaou
///
///     This program is free software: you can redistribute it and/or modify
///     it under the terms of the GNU General Public License as published by
///     the Free Software Foundation, either version 3 of the License, or
///     (at your option) any later version.
///
///     This program is distributed in the hope that it will be useful,
///     but WITHOUT ANY WARRANTY; without even the implied warranty of
///     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
///     GNU General Public License for more details.
///
///     You should have received a copy of the GNU General Public License
///     along with this program. You can find it at project root.
///     If not, see <https://www.gnu.org/licenses/>.
///
///     Author E-mail address: andydexter123@gmail.com
///

library;

import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/error_playlist.dart';
import 'package:shuffler/data_objects/liked_songs_playlist.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/data_objects/spotify_playlist.dart';
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
    if (playlist.spotifyID == LikedSongsPlaylist.likedSongsID) {
      return LikedSongsPlaylist();
    } else {
      return await GetIt.I<APIUtils>()
          .getPlaylistBySpotifyID(playlist.spotifyID)
          .onError((error, stackTrace) => ErrorPlaylist(error: error as String, spotifyID: playlist.spotifyID));
    }
  }

  Future<List<Playlist>> getAllPlaylists() async {
    List<PlaylistTableData> playlists = await select(playlistTable).get();
    return Future.wait(playlists.map((playlist) => rowToPlaylist(playlist)));
  }

  Future<List<String>> getAllPlaylistIDs() async {
    return (await select(playlistTable).get()).map((playlist) => playlist.spotifyID).toList();
  }

  Future<void> addPlaylist(Playlist playlist) async {
    String id;
    if (playlist is LikedSongsPlaylist) {
      id = LikedSongsPlaylist.likedSongsID;
    } else {
      id = (playlist as SpotifyPlaylist).playlistID;
    }
    addPlaylistByID(id);
  }

  Future<void> addPlaylistByID(String id) async {
    if ((await (select(playlistTable)..where((tbl) => tbl.spotifyID.equals(id))).get()).isEmpty) {
      await into(playlistTable).insert(PlaylistTableData(spotifyID: id));
    }
  }

  Future<void> deletePlaylistByID(String spotifyID) async {
    await (delete(playlistTable)..where((tbl) => tbl.spotifyID.equals(spotifyID))).go();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await deletePlaylistByID(playlist.playlistID);
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
