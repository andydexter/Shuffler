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
        home: Scaffold(
          body: PlaylistView(playlist: playlist),
        ),
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
        home: Scaffold(
          body: PlaylistView(playlist: playlist),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);

    expect(find.text('Test Playlist'), findsOneWidget);
    for (Track track in tracks) {
      expect(find.text(track.title), findsOneWidget);
    }
  });

  testWidgets('Add 2 tracks to queue', (WidgetTester tester) async {
    when(mockAPIUtils.addTrackToQueue(any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaylistView(playlist: playlist),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("Tracks loaded!"), findsOneWidget);
    await tester.pump((find.byType(SnackBar).evaluate().first.widget as SnackBar).duration);

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    (find.byType(Slider).evaluate().first.widget as Slider).onChanged!(2.0);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    verify(mockAPIUtils.addTrackToQueue(argThat(isIn(tracks)))).called(2);
  });

  testWidgets('Add 3 tracks to queue', (WidgetTester tester) async {
    when(mockAPIUtils.addTrackToQueue(any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaylistView(playlist: playlist),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("Tracks loaded!"), findsOneWidget);
    await tester.pump((find.byType(SnackBar).evaluate().first.widget as SnackBar).duration);

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    (find.byType(Slider).evaluate().first.widget as Slider).onChanged!(3.0);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    for (Track track in tracks) {
      verify(mockAPIUtils.addTrackToQueue(track)).called(1);
    }
  });

  testWidgets('Add 3 tracks to playlist', (WidgetTester tester) async {
    Playlist generatedPlaylist = Playlist(name: 'Generated Playlist', id: 2, spotifyID: 'generated_id');
    when(mockAPIUtils.generatePlaylistIfNotExists(playlist.name)).thenAnswer((_) async => generatedPlaylist);
    when(mockAPIUtils.addTracksToGeneratedPlaylist('generated_id', tracks)).thenAnswer((_) async => Future.any);
    when(mockAPIUtils.playPlaylist(generatedPlaylist.spotifyID)).thenAnswer((_) async => Future.any);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaylistView(playlist: playlist),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("Tracks loaded!"), findsOneWidget);
    await tester.pump((find.byType(SnackBar).evaluate().first.widget as SnackBar).duration);

    verify(mockAPIUtils.getTracksForPlaylist(playlist)).called(1);
    verify(mockAPIUtils.getImage(any)).called(3);

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    (find.byType(Switch).evaluate().first.widget as Switch).onChanged!(true);
    (find.byType(Slider).evaluate().first.widget as Slider).onChanged!(3.0);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    verify(mockAPIUtils.generatePlaylistIfNotExists(playlist.name)).called(1);
    verify(mockAPIUtils.addTracksToGeneratedPlaylist(generatedPlaylist.spotifyID, argThat(containsAll(tracks))))
        .called(1);

    await tester.pumpAndSettle();

    expect(find.text("Tracks added to playlist!"), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    verify(mockAPIUtils.playPlaylist(generatedPlaylist.spotifyID)).called(1);
    verifyNoMoreInteractions(mockAPIUtils);
  });

  tearDown(() {
    GetIt.instance.reset();
  });
}
