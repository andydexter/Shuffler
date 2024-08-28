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

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/add_playlist_dialog.dart';
import 'package:shuffler/data_objects/liked_songs_playlist.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/data_objects/spotify_playlist.dart';
import 'package:shuffler/database/entities.dart';
import 'package:shuffler/home_page.dart';
import 'playlist_list_test.mocks.dart';

@GenerateMocks([APIUtils])
void main() {
  late MockAPIUtils mockAPIUtils;
  late AppDatabase appDB;

  setUp(() async {
    mockAPIUtils = MockAPIUtils();
    appDB = AppDatabase.customExecutor(NativeDatabase.memory());
    GetIt.instance.registerSingleton<AppDatabase>(appDB);
    GetIt.instance.registerSingleton<APIUtils>(mockAPIUtils);
    when(mockAPIUtils.getImage(any)).thenAnswer((_) => const FlutterLogo());
  });

  testWidgets('Existing Playlists should be loaded from the database', (WidgetTester tester) async {
    SpotifyPlaylist existent = SpotifyPlaylist(name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    SpotifyPlaylist existent2 = SpotifyPlaylist(name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.addPlaylist(existent);
    appDB.addPlaylist(existent2);
    appDB.addPlaylist(LikedSongsPlaylist());
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID")).thenAnswer((_) async => existent);
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID 2")).thenAnswer((_) async => existent2);

    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("Playlists loaded!"), findsOneWidget);
    await tester.pump((find.byType(SnackBar).evaluate().first.widget as SnackBar).duration);
    await tester.pumpAndSettle();

    final MyHomePage homePage = tester.firstWidget(find.byType(MyHomePage)) as MyHomePage;

    List<Playlist> expected = [existent, existent2, LikedSongsPlaylist()];

    expect(homePage.playlists, equals(expected));

    expect(homePage.playlists, equals(expected));
    List<Playlist> playlists = await appDB.getAllPlaylists();
    expect(playlists, equals(expected));
    expect(find.text("Existent Playlist 1"), findsOneWidget);
    expect(find.text("Existent Playlist 2"), findsOneWidget);
    expect(find.text('Liked Songs'), findsOneWidget);
  });

  testWidgets('Delete 1 playlist', (WidgetTester tester) async {
    SpotifyPlaylist existent = SpotifyPlaylist(name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    SpotifyPlaylist existent2 = SpotifyPlaylist(name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.addPlaylist(existent);
    appDB.addPlaylist(existent2);
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID")).thenAnswer((_) async => existent);
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID 2")).thenAnswer((_) async => existent2);

    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("Playlists loaded!"), findsOneWidget);
    await tester.pump((find.byType(SnackBar).evaluate().first.widget as SnackBar).duration);
    await tester.pumpAndSettle();

    final MyHomePage homePage = tester.firstWidget(find.byType(MyHomePage)) as MyHomePage;

    expect(homePage.playlists, equals([existent, existent2]));

    await HelperMethods.deletePlaylist(tester, "Existent ID");

    expect(await appDB.getAllPlaylists(), equals([existent2]));
    expect(homePage.playlists, equals([existent2]));

    expect(find.text("Existent Playlist 1"), findsNothing);
    expect(find.text("Existent Playlist 2"), findsOneWidget);
  });

  testWidgets('Delete Liked Songs playlist', (WidgetTester tester) async {
    SpotifyPlaylist existent = SpotifyPlaylist(name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    SpotifyPlaylist existent2 = SpotifyPlaylist(name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.addPlaylist(existent);
    appDB.addPlaylist(existent2);
    appDB.addPlaylist(LikedSongsPlaylist());
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID")).thenAnswer((_) async => existent);
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID 2")).thenAnswer((_) async => existent2);

    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("Playlists loaded!"), findsOneWidget);
    await tester.pump((find.byType(SnackBar).evaluate().first.widget as SnackBar).duration);
    await tester.pumpAndSettle();

    final MyHomePage homePage = tester.firstWidget(find.byType(MyHomePage)) as MyHomePage;

    expect(homePage.playlists, equals([existent, existent2, LikedSongsPlaylist()]));

    await HelperMethods.deletePlaylist(tester, LikedSongsPlaylist.likedSongsID);

    expect(await appDB.getAllPlaylists(), equals([existent, existent2]));
    expect(homePage.playlists, equals([existent, existent2]));

    expect(find.text("Existent Playlist 1"), findsOneWidget);
    expect(find.text("Existent Playlist 2"), findsOneWidget);
  });

  testWidgets('Summons add playlist dialog and reloads playlists afterwards', (WidgetTester tester) async {
    SpotifyPlaylist existent = SpotifyPlaylist(name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    appDB.addPlaylist(existent);
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID")).thenAnswer((_) async => existent);
    when(mockAPIUtils.getUserPlaylists()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(AddPlaylistDialog), findsOneWidget);
    SpotifyPlaylist existent2 = SpotifyPlaylist(name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.addPlaylist(existent2);
    appDB.deletePlaylistByID(existent.playlistID);
    when(mockAPIUtils.getPlaylistBySpotifyID("Existent ID 2")).thenAnswer((_) async => existent2);

    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();
    expect(find.text("Existent Playlist 1"), findsNothing);
    expect(find.text("Existent Playlist 2"), findsOneWidget);
  });

  tearDown(() async {
    GetIt.instance.reset();
    appDB.close();
  });
}

class HelperMethods {
  static Future<void> deletePlaylist(WidgetTester tester, String id) async {
    await tester.tap(find.byKey(Key("deletePlaylist<$id>")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Delete"));
    await tester.pumpAndSettle();
  }
}
