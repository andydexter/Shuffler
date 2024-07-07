import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/track.dart';
import 'package:shuffler/playlist_view.dart';

import 'playlist_view_test.mocks.dart';

@GenerateMocks([APIUtils])
void main() {
  final MockAPIUtils mockAPIUtils = MockAPIUtils();
  Playlist playlist = Playlist(name: 'Test Playlist', id: 1, spotifyID: 'test_id');
  List<Track> tracks = [
    const Track(title: 'Track 1', uri: 'track_1'),
    const Track(title: 'Track 2', uri: 'track_2'),
    const Track(title: 'Track 3', uri: 'track_3'),
  ];

  setUp(() {
    reset(mockAPIUtils);
    GetIt.instance.registerSingleton<APIUtils>(mockAPIUtils);
    playlist.tracks = List.empty(growable: true);
    when(mockAPIUtils.getImage(any)).thenAnswer((_) => const FlutterLogo());
    when(mockAPIUtils.getTracksForPlaylist(playlist)).thenAnswer((_) async => tracks);
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
