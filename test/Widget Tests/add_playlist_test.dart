import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/add_playlist_dialog.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/database/entities.dart';

import 'add_playlist_test.mocks.dart';

@GenerateMocks([APIUtils])
void main() {
  late MockAPIUtils mockAPIUtils;
  late AppDatabase appDB;
  List<Playlist> userPlaylists = List.empty(growable: true);

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
      Playlist testPlaylist = Playlist(id: -1, name: 'My Playlist', tracks: [], spotifyID: 'Test ID');
      when(mockAPIUtils.getPlaylist('Test ID')).thenAnswer((_) async => testPlaylist);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), 'Test ID');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist.spotifyID]));
    });

    testWidgets('Add playlist by URL', (WidgetTester tester) async {
      Playlist testPlaylist = Playlist(id: -1, name: 'My Playlist', tracks: [], spotifyID: 'Test ID');
      when(mockAPIUtils.getPlaylist('Test ID')).thenAnswer((_) async => testPlaylist);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), 'eee.cum.com/somepath/Test ID?somewuerues');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist.spotifyID]));
    });

    testWidgets('Blank Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a playlist URL/ID'), findsOneWidget);
    });

    testWidgets('Invalid URL', (WidgetTester tester) async {
      when(mockAPIUtils.getPlaylist('not a url')).thenAnswer((_) => Future.error('Invalid URL/ID'));

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.enterText(find.byType(TextField), 'not a url');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid Playlist ID'), findsOneWidget);
    });
  });

  group('Import from Account', () {
    testWidgets('Add 2', (WidgetTester tester) async {
      Playlist testPlaylist1 = Playlist(id: -1, name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      Playlist testPlaylist2 = Playlist(id: -1, name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      Playlist testPlaylist3 = Playlist(id: -1, name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylist('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylist('Test ID2')).thenAnswer((_) async => testPlaylist2);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      for (Playlist playlist in userPlaylists) {
        expect(find.text(playlist.name), findsOneWidget);
      }

      await tester.tap(find.text('Test 1'));
      await tester.tap(find.text('Test 2'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist1.spotifyID, testPlaylist2.spotifyID]));
    });

    testWidgets('Delete 1', (WidgetTester tester) async {
      Playlist testPlaylist1 = Playlist(id: -1, name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      Playlist testPlaylist2 = Playlist(id: -1, name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      Playlist testPlaylist3 = Playlist(id: -1, name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylist('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylist('Test ID2')).thenAnswer((_) async => testPlaylist2);
      when(mockAPIUtils.getPlaylist('Test ID3')).thenAnswer((_) async => testPlaylist2);
      appDB.addPlaylist(testPlaylist1.spotifyID);
      appDB.addPlaylist(testPlaylist3.spotifyID);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      for (Playlist playlist in userPlaylists) {
        expect(find.text(playlist.name), findsOneWidget);
      }

      await tester.tap(find.text('Test 1'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist3.spotifyID]));
    });

    testWidgets('2 Existing, Add 1, Delete 1', (WidgetTester tester) async {
      Playlist testPlaylist1 = Playlist(id: -1, name: 'Test 1', tracks: [], spotifyID: 'Test ID1');
      Playlist testPlaylist2 = Playlist(id: -1, name: 'Test 2', tracks: [], spotifyID: 'Test ID2');
      Playlist testPlaylist3 = Playlist(id: -1, name: 'Test 3', tracks: [], spotifyID: 'Test ID3');
      userPlaylists = [testPlaylist1, testPlaylist2, testPlaylist3];
      when(mockAPIUtils.getPlaylist('Test ID1')).thenAnswer((_) async => testPlaylist1);
      when(mockAPIUtils.getPlaylist('Test ID2')).thenAnswer((_) async => testPlaylist2);
      when(mockAPIUtils.getPlaylist('Test ID3')).thenAnswer((_) async => testPlaylist3);
      appDB.addPlaylist(testPlaylist1.spotifyID);
      appDB.addPlaylist(testPlaylist3.spotifyID);

      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AddPlaylistDialog())));
      await tester.tap(find.text('Import from Account'));
      await tester.pumpAndSettle();

      for (Playlist playlist in userPlaylists) {
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
      expect(await appDB.getAllPlaylistIDs(), equals([testPlaylist3.spotifyID, testPlaylist2.spotifyID]));
    });
  });

  tearDown(() async {
    appDB.close();
    GetIt.instance.unregister<AppDatabase>();
    GetIt.instance.unregister<APIUtils>();
  });
}
