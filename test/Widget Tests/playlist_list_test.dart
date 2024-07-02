import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/database/entities.dart';
import 'package:shuffler/home_page.dart';
import 'package:shuffler/main.dart';
import 'playlist_list_test.mocks.dart';

@GenerateMocks([APIUtils])
void main() {
  final MockAPIUtils mockAPIUtils = MockAPIUtils();
  late AppDatabase appDB;

  setUp(() async {
    appDB = AppDatabase.customExecutor(NativeDatabase.memory());
    GetIt.instance.registerSingleton<AppDatabase>(appDB);
    GetIt.instance.registerSingleton<APIUtils>(mockAPIUtils);
    when(mockAPIUtils.getImage(any)).thenAnswer((_) => const FlutterLogo());
  });

  testWidgets('Adding a playlist from the home page using ID or URL should update the playlist list',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyHomePage(),
    ));

    Playlist toAdd1 = Playlist(id: -1, name: "Test Playlist", tracks: [], spotifyID: 'Test ID');
    Playlist toAdd2 = Playlist(id: -1, name: "Test Playlist 2", tracks: [], spotifyID: 'Test ID 2');

    await tester.pumpAndSettle();

    final MyHomePage homePage = tester.firstWidget(find.byType(MyHomePage)) as MyHomePage;

    expect(homePage.playlists, isEmpty);

    when(mockAPIUtils.getPlaylist("Test ID")).thenAnswer((_) async => toAdd1);

    when(mockAPIUtils.getPlaylist("Test ID 2")).thenAnswer((_) async => toAdd2);

    await HelperMethods.addPlaylist(tester, "Test ID");
    await HelperMethods.addPlaylist(tester, "xxx.Test UR.cum/some path/Test ID 2?some query");

    verify(mockAPIUtils.getPlaylist("Test ID")).called(1);
    verify(mockAPIUtils.getPlaylist("Test ID 2")).called(1);

    List<Playlist> expected = [toAdd1, toAdd2];

    expect(homePage.playlists, equals(expected));
    List<Playlist> playlists = await appDB.getAllPlaylists();
    expect(playlists, equals(expected));

    expect(find.text("Test Playlist"), findsOneWidget);
    expect(find.text("Test Playlist 2"), findsOneWidget);
  });

  testWidgets('Existing Playlists should be loaded from the database, and adding new playlists should work',
      (WidgetTester tester) async {
    Playlist existent = Playlist(id: -1, name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    Playlist existent2 = Playlist(id: -1, name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.persistPlaylist(existent);
    appDB.persistPlaylist(existent2);

    await tester.pumpWidget(MyApp(ColorScheme.fromSeed(seedColor: Colors.deepPurple)));

    Playlist toAdd = Playlist(id: -1, name: "Test Playlist", tracks: [], spotifyID: 'Test ID');

    await tester.pumpAndSettle();

    final MyHomePage homePage = tester.firstWidget(find.byType(MyHomePage)) as MyHomePage;

    expect(homePage.playlists, equals([existent, existent2]));

    when(mockAPIUtils.getPlaylist("Test ID")).thenAnswer((_) async => toAdd);

    await HelperMethods.addPlaylist(tester, "Test ID");

    verify(mockAPIUtils.getPlaylist("Test ID")).called(1);

    List<Playlist> expected = [existent, existent2, toAdd];

    expect(homePage.playlists, equals(expected));
    List<Playlist> playlists = await appDB.getAllPlaylists();
    expect(playlists, equals(expected));

    expect(find.text("Test Playlist"), findsOneWidget);
    expect(find.text("Existent Playlist 1"), findsOneWidget);
    expect(find.text("Existent Playlist 2"), findsOneWidget);
  });

  tearDown(() async {
    GetIt.instance.reset();
    appDB.close();
  });
}

class HelperMethods {
  static Future<void> addPlaylist(WidgetTester tester, String toAdd) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text("Enter Playlist URL or ID"), findsOneWidget);
    await tester.enterText(find.byType(TextField), toAdd);
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text("Playlist Added!"), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  }
}
