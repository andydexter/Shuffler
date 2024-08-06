import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/add_playlist_dialog.dart';
import 'package:shuffler/data_objects/liked_songs_playlist.dart';
import 'package:shuffler/data_objects/spotify_playlist.dart';
import 'package:shuffler/database/entities.dart';

import 'add_playlist_test.mocks.dart';

@GenerateMocks([APIUtils])
void main() {
  late MockAPIUtils mockAPIUtils;
  late AppDatabase appDB;
  List<SpotifyPlaylist> userPlaylists = List.empty(growable: true);

  setUp(() async {
    mockAPIUtils = MockAPIUtils();
    appDB = AppDatabase.customExecutor(NativeDatabase.memory());
    GetIt.instance.registerSingleton<AppDatabase>(appDB);
    GetIt.instance.registerSingleton<APIUtils>(mockAPIUtils);
    when(mockAPIUtils.getImage(any)).thenAnswer((_) => const FlutterLogo());
    when(mockAPIUtils.getUserPlaylists()).thenAnswer((_) async => userPlaylists);
  });
  group('Add Manually', () {
    testWidgets('Add playlist by ID', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist =
          SpotifyPlaylist(name: 'My Playlist', tracks: [], spotifyID: '5CYHemD2Q7C02vWSbMuOcM');
      when(mockAPIUtils.isGeneratedPlaylist(testPlaylist.playlistID)).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), testPlaylist.playlistID);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.byType(AddPlaylistDialog), findsNothing);
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist.playlistID]));
    });

    testWidgets('Add playlist by URL', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist =
          SpotifyPlaylist(name: 'My Playlist', tracks: [], spotifyID: '5CYHemD2Q7C02vWSbMuOcM');
      when(mockAPIUtils.isGeneratedPlaylist(testPlaylist.playlistID)).thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), 'eee.cum.com/somepath/5CYHemD2Q7C02vWSbMuOcM?somewuerues');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist.playlistID]));
    });

    testWidgets('Blank Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a playlist URL/ID'), findsOneWidget);
    });

    testWidgets('Invalid URL wrong length', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), 'notaurl');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid Playlist URL/ID'), findsOneWidget);
    });

    testWidgets('Invalid URL wrong character set', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), '5CYHemD2Q7C02vWSbMuO.M');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid Playlist URL/ID'), findsOneWidget);
    });

    testWidgets('Already Added', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist =
          SpotifyPlaylist(name: 'My Playlist', tracks: [], spotifyID: '5CYHemD2Q7C02vWSbMuOcM');
      when(mockAPIUtils.getPlaylistBySpotifyID(testPlaylist.playlistID)).thenAnswer((_) async => testPlaylist);
      appDB.addPlaylist(testPlaylist);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), testPlaylist.playlistID);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Playlist already added'), findsOneWidget);
    });

    testWidgets('Shuffler Playlist', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist =
          SpotifyPlaylist(name: 'My Playlist', tracks: [], spotifyID: '5CYHemD2Q7C02vWSbMuOcM');
      when(mockAPIUtils.isGeneratedPlaylist(testPlaylist.playlistID)).thenAnswer((_) async => true);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), testPlaylist.playlistID);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Cannot add Shuffler generated playlists'), findsOneWidget);
    });

    testWidgets('Playlist not found', (WidgetTester tester) async {
      when(mockAPIUtils.isGeneratedPlaylist('5CYHemD2Q7C02vWSbMuOcM')).thenThrow(Exception());

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), '5CYHemD2Q7C02vWSbMuOcM');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Playlist Not Found'), findsOneWidget);
    });
  });

  group('Import from Account', () {
    testWidgets('Displays all user playlists and Liked Songs', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist1 = SpotifyPlaylist(name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      SpotifyPlaylist testPlaylist2 = SpotifyPlaylist(name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      SpotifyPlaylist testPlaylist3 = SpotifyPlaylist(name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID2')).thenAnswer((_) async => testPlaylist2);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID3')).thenAnswer((_) async => testPlaylist3);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      for (SpotifyPlaylist playlist in userPlaylists) {
        expect(find.text(playlist.name), findsOneWidget);
      }
      expect(find.text('Liked Songs'), findsOneWidget);
    });

    testWidgets('Add 2', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist1 = SpotifyPlaylist(name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      SpotifyPlaylist testPlaylist2 = SpotifyPlaylist(name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      SpotifyPlaylist testPlaylist3 = SpotifyPlaylist(name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID2')).thenAnswer((_) async => testPlaylist2);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      for (SpotifyPlaylist playlist in userPlaylists) {
        expect(find.text(playlist.name), findsOneWidget);
      }

      await tester.tap(find.text('Test 1'));
      await tester.tap(find.text('Test 2'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist1.playlistID, testPlaylist2.playlistID]));
    });

    testWidgets('Add 1 and Liked Songs', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist1 = SpotifyPlaylist(name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      SpotifyPlaylist testPlaylist2 = SpotifyPlaylist(name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      SpotifyPlaylist testPlaylist3 = SpotifyPlaylist(name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID2')).thenAnswer((_) async => testPlaylist2);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test 1'));
      await tester.tap(find.text('Liked Songs'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist1.playlistID, LikedSongsPlaylist.likedSongsID]));
    });

    testWidgets('Delete 1', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist1 = SpotifyPlaylist(name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      SpotifyPlaylist testPlaylist2 = SpotifyPlaylist(name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      SpotifyPlaylist testPlaylist3 = SpotifyPlaylist(name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID2')).thenAnswer((_) async => testPlaylist2);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID3')).thenAnswer((_) async => testPlaylist2);
      appDB.addPlaylist(testPlaylist1);
      appDB.addPlaylist(testPlaylist3);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      for (SpotifyPlaylist playlist in userPlaylists) {
        expect(find.text(playlist.name), findsOneWidget);
      }

      await tester.tap(find.text('Test 1'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist3.playlistID]));
    });

    testWidgets('Delete Liked Songs', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist1 = SpotifyPlaylist(name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      SpotifyPlaylist testPlaylist2 = SpotifyPlaylist(name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      SpotifyPlaylist testPlaylist3 = SpotifyPlaylist(name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID2')).thenAnswer((_) async => testPlaylist2);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID3')).thenAnswer((_) async => testPlaylist2);
      appDB.addPlaylist(testPlaylist1);
      appDB.addPlaylist(testPlaylist3);
      appDB.addPlaylist(LikedSongsPlaylist());

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Liked Songs'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist1.playlistID, testPlaylist3.playlistID]));
    });

    testWidgets('2 Existing, Add 1, Delete 1', (WidgetTester tester) async {
      SpotifyPlaylist testPlaylist1 = SpotifyPlaylist(name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      SpotifyPlaylist testPlaylist2 = SpotifyPlaylist(name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      SpotifyPlaylist testPlaylist3 = SpotifyPlaylist(name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID2')).thenAnswer((_) async => testPlaylist2);
      when(mockAPIUtils.getPlaylistBySpotifyID('Test ID3')).thenAnswer((_) async => testPlaylist3);
      appDB.addPlaylist(testPlaylist1);
      appDB.addPlaylist(testPlaylist3);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      for (SpotifyPlaylist playlist in userPlaylists) {
        expect(find.text(playlist.name), findsOneWidget);
        CheckboxListTile check = find
            .ancestor(of: find.text(playlist.name), matching: find.byType(CheckboxListTile))
            .evaluate()
            .single
            .widget as CheckboxListTile;
        expect(check.value, equals(playlist == testPlaylist1 || playlist == testPlaylist3));
      }

      //delete Test 1
      await tester.tap(find.text('Test 1'));
      //add Test 2
      await tester.tap(find.text('Test 2'));

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist3.playlistID, testPlaylist2.playlistID]));
    });
  });

  tearDown(() async {
    appDB.close();
    GetIt.instance.unregister<AppDatabase>();
    GetIt.instance.unregister<APIUtils>();
  });
}
