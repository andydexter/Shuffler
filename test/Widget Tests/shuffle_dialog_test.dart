import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/shuffle_dialog.dart';
import 'package:shuffler/components/track.dart';

import 'shuffle_dialog_test.mocks.dart';

@GenerateMocks([APIUtils])
void main() {
  final MockAPIUtils mockAPIUtils = MockAPIUtils();
  Playlist playlist = Playlist(name: 'Test Playlist', id: 1, spotifyID: 'test_id', tracks: [
    const Track(title: 'Track 1', uri: 'track_1'),
    const Track(title: 'Track 2', uri: 'track_2'),
    const Track(title: 'Track 3', uri: 'track_3'),
  ]);

  setUp(() {
    reset(mockAPIUtils);
    GetIt.instance.registerSingleton<APIUtils>(mockAPIUtils);
    when(mockAPIUtils.getImage(any)).thenAnswer((_) => const FlutterLogo());
  });

  testWidgets('Should have correct max tracks', (WidgetTester tester) async {
    when(mockAPIUtils.waitForPlayerActivated()).thenAnswer((_) async => Future.any);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuffleDialog(playlist: playlist),
        ),
      ),
    );

    expect((find.byKey(const Key("NumTracksSlider")).evaluate().first.widget as Slider).max, 3.0);
  });

  testWidgets('Add 2 tracks to queue', (WidgetTester tester) async {
    when(mockAPIUtils.waitForPlayerActivated()).thenAnswer((_) async => Future.any);
    when(mockAPIUtils.addTrackToQueue(any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuffleDialog(playlist: playlist),
        ),
      ),
    );

    await tester.pumpAndSettle();

    (find.byKey(const Key("NumTracksSlider")).evaluate().first.widget as Slider).onChanged!(2.0);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    verify(mockAPIUtils.addTrackToQueue(argThat(isIn(playlist.tracks)))).called(2);
  });

  testWidgets('Add 3 tracks to queue', (WidgetTester tester) async {
    when(mockAPIUtils.waitForPlayerActivated()).thenAnswer((_) async => Future.any);
    when(mockAPIUtils.addTrackToQueue(any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuffleDialog(playlist: playlist),
        ),
      ),
    );
    await tester.pumpAndSettle();

    (find.byKey(const Key("NumTracksSlider")).evaluate().first.widget as Slider).onChanged!(3.0);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    for (Track track in playlist.tracks) {
      verify(mockAPIUtils.addTrackToQueue(track)).called(1);
    }
  });

  testWidgets('Add 3 tracks to playlist', (WidgetTester tester) async {
    Playlist generatedPlaylist = Playlist(name: 'Generated Playlist', id: 2, spotifyID: 'generated_id');
    when(mockAPIUtils.waitForPlayerActivated()).thenAnswer((_) async => Future.any);
    when(mockAPIUtils.generatePlaylistIfNotExists(playlist.name)).thenAnswer((_) async => generatedPlaylist);
    when(mockAPIUtils.addTracksToGeneratedPlaylist('generated_id', playlist.tracks))
        .thenAnswer((_) async => Future.any);
    when(mockAPIUtils.playPlaylist(generatedPlaylist.spotifyID)).thenAnswer((_) async => Future.any);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuffleDialog(playlist: playlist),
        ),
      ),
    );
    await tester.pumpAndSettle();

    (find.byType(Switch).evaluate().first.widget as Switch).onChanged!(true);
    (find.byKey(const Key("NumTracksSlider")).evaluate().first.widget as Slider).onChanged!(3.0);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    verify(mockAPIUtils.generatePlaylistIfNotExists(playlist.name)).called(1);
    verify(mockAPIUtils.addTracksToGeneratedPlaylist(
            generatedPlaylist.spotifyID, argThat(containsAll(playlist.tracks))))
        .called(1);

    await tester.pumpAndSettle();

    expect(find.text("Tracks added to playlist!"), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    verify(mockAPIUtils.playPlaylist(generatedPlaylist.spotifyID)).called(1);
    verify(mockAPIUtils.waitForPlayerActivated()).called(1);
    verifyNoMoreInteractions(mockAPIUtils);
  });

  testWidgets('Should not shuffle recently listened tracks', (WidgetTester tester) async {
    List<Track> recentTracks = [
      const Track(title: 'recent 1', uri: 'recent1'),
      const Track(title: 'recent 2', uri: 'recent2'),
      playlist.tracks.last,
      const Track(title: 'recent 3', uri: 'recent3'),
    ];
    when(mockAPIUtils.getRecentlyPlayedTracks(20)).thenAnswer((_) async => recentTracks);
    when(mockAPIUtils.waitForPlayerActivated()).thenAnswer((_) async => Future.any);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuffleDialog(playlist: playlist),
        ),
      ),
    );

    Slider numTracks = find.byKey(const Key("NumTracksSlider")).evaluate().first.widget as Slider;
    Slider recentTracksSlider = find.byKey(const Key("recentTracksSlider")).evaluate().first.widget as Slider;
    expect(find.text("0"), findsExactly(2));
    numTracks.onChanged!(3.0);
    recentTracksSlider.onChanged!(20);

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text("1"), findsOneWidget);
    numTracks = find.byKey(const Key("NumTracksSlider")).evaluate().first.widget as Slider;
    expect(numTracks.max, equals(2.0));
    expect(numTracks.value, equals(2.0));

    when(mockAPIUtils.addTrackToQueue(argThat(isIn([playlist.tracks[0], playlist.tracks[1]]))))
        .thenAnswer((_) async => Future.value());

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    verify(mockAPIUtils.addTrackToQueue(playlist.tracks[0])).called(1);
    verify(mockAPIUtils.addTrackToQueue(playlist.tracks[1])).called(1);
    verifyNever(mockAPIUtils.addTrackToQueue(any));
  });

  testWidgets('Should disable submit button when player is inactive', (WidgetTester tester) async {
    when(mockAPIUtils.waitForPlayerActivated())
        .thenAnswer((_) async => await Future.delayed(const Duration(seconds: 1)));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShuffleDialog(playlist: playlist),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Make sure you\'re already playing something on spotify before clicking Submit'), findsOneWidget);
    expect(
        (find.ancestor(of: find.text('Submit'), matching: find.byType(TextButton)).evaluate().single.widget
                as TextButton)
            .onPressed,
        isNull);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Make sure you\'re already playing something on spotify before clicking Submit'), findsNothing);
    expect(
        (find.ancestor(of: find.text('Submit'), matching: find.byType(TextButton)).evaluate().single.widget
                as TextButton)
            .onPressed,
        isNotNull);
    await tester.pumpAndSettle();
  });

  tearDown(() {
    GetIt.instance.reset();
  });
}
