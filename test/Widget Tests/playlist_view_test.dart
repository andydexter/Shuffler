/***

    Copyright (C) 2024  Andreas Nicolaou

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. You can find it at project root.
    If not, see <https://www.gnu.org/licenses/>.

    Author E-mail address: andydexter123@gmail.com

***/
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/spotify_playlist.dart';
import 'package:shuffler/data_objects/track.dart';
import 'package:shuffler/playlist_view.dart';

import 'playlist_view_test.mocks.dart';

@GenerateMocks([APIUtils])
void main() {
  final MockAPIUtils mockAPIUtils = MockAPIUtils();
  late SpotifyPlaylist playlist;
  List<Track> tracks = [
    const Track(title: 'Track 1', uri: 'track_1'),
    const Track(title: 'Track 2', uri: 'track_2'),
    const Track(title: 'Track 3', uri: 'track_3'),
  ];

  setUp(() {
    reset(mockAPIUtils);
    GetIt.instance.registerSingleton<APIUtils>(mockAPIUtils);
    when(mockAPIUtils.getImage(any)).thenAnswer((_) => const FlutterLogo());
    playlist = SpotifyPlaylist(name: 'Test Playlist', spotifyID: 'test_id');
    when(mockAPIUtils.getTracksForPlaylist(playlist)).thenAnswer((_) async => tracks);
    playlist.tracks = List.empty(growable: true);
  });

  testWidgets('Should display playlist name and tracks', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlaylistView(playlist: playlist),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Playlist'), findsOneWidget);
    for (Track track in tracks) {
      expect(find.text(track.title), findsOneWidget);
    }
  });

  testWidgets('Should not reload tracks', (WidgetTester tester) async {
    playlist.tracks = tracks;
    await tester.pumpWidget(
      MaterialApp(
        home: PlaylistView(playlist: playlist),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);

    expect(find.text('Test Playlist'), findsOneWidget);
    for (Track track in tracks) {
      expect(find.text(track.title), findsOneWidget);
    }
  });

  tearDown(() {
    GetIt.instance.reset();
  });
}
