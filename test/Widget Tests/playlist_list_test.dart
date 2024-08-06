import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/add_playlist_dialog.dart';
import 'package:shuffler/data_objects/playlist.dart';
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
    Playlist existent = Playlist(id: -1, name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    Playlist existent2 = Playlist(id: -1, name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.addPlaylist(existent.spotifyID);
    appDB.addPlaylist(existent2.spotifyID);
    when(mockAPIUtils.getPlaylist("Existent ID")).thenAnswer((_) async => existent);
    when(mockAPIUtils.getPlaylist("Existent ID 2")).thenAnswer((_) async => existent2);

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

    List<Playlist> expected = [existent, existent2];

    expect(homePage.playlists, equals(expected));
    List<Playlist> playlists = await appDB.getAllPlaylists();
    expect(playlists, equals(expected));
    expect(find.text("Existent Playlist 1"), findsOneWidget);
    expect(find.text("Existent Playlist 2"), findsOneWidget);
  });

  testWidgets('Delete 1 playlist', (WidgetTester tester) async {
    Playlist existent = Playlist(id: -1, name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    Playlist existent2 = Playlist(id: -1, name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.addPlaylist(existent.spotifyID);
    appDB.addPlaylist(existent2.spotifyID);
    when(mockAPIUtils.getPlaylist("Existent ID")).thenAnswer((_) async => existent);
    when(mockAPIUtils.getPlaylist("Existent ID 2")).thenAnswer((_) async => existent2);

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

  testWidgets('Summons add playlist dialog and reloads playlists afterwards', (WidgetTester tester) async {
    Playlist existent = Playlist(id: -1, name: "Existent Playlist 1", tracks: [], spotifyID: 'Existent ID');
    appDB.addPlaylist(existent.spotifyID);
    when(mockAPIUtils.getPlaylist("Existent ID")).thenAnswer((_) async => existent);
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
    Playlist existent2 = Playlist(id: -1, name: "Existent Playlist 2", tracks: [], spotifyID: 'Existent ID 2');
    appDB.addPlaylist(existent2.spotifyID);
    appDB.deletePlaylist(existent.spotifyID);
    when(mockAPIUtils.getPlaylist("Existent ID 2")).thenAnswer((_) async => existent2);

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
