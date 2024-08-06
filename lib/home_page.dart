import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/error_dialog.dart';
import 'package:shuffler/components/playlist_cards.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/components/theme_dialog.dart';
import 'package:shuffler/components/add_playlist_dialog.dart';
import 'package:shuffler/database/entities.dart';
import 'package:shuffler/main.dart';
import 'package:shuffler/playlist_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final List<Playlist> playlists = List.empty(growable: true);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  APIUtils apiUtils = GetIt.I<APIUtils>();
  late final List<Playlist> playlists;
  final appDB = GetIt.instance<AppDatabase>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger lg = Logger("Shuffler/MyHomePage");
  ColorScheme? colorScheme;

  @override
  void initState() {
    super.initState();
    playlists = widget.playlists;
    SchedulerBinding.instance.addPostFrameCallback((_) => loadPlaylists());
  }

  Future<bool> setPlaylistState() async {
    List<String> ids = await appDB.getAllPlaylistIDs();
    List<String> currentIDs = playlists.map((e) => e.playlistID).toList();
    if (!listEquals(ids, currentIDs)) {
      //Fetch all playlist information and set state
      await appDB.getAllPlaylists().then((value) => WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            playlists.clear();
            playlists.addAll(value);
          })));
      return true;
    }
    return false;
  }

  Future<void> loadPlaylists() {
    showDialog(
        context: context,
        builder: (context) => FutureBuilder(
            //Get Playlist IDs from database
            future: setPlaylistState(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (snapshot.data as bool) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Center(child: Text('Playlists loaded!')),
                      duration: Duration(seconds: 1),
                    ));
                  }
                  if (mounted) Navigator.of(context).pop();
                });
              } else if (snapshot.hasError ||
                  (snapshot.connectionState == ConnectionState.done && snapshot.data == null)) {
                return ErrorDialog(errorMessage: snapshot.error.toString());
              }
              return const AlertDialog(
                title: Text('Loading playlists...'),
                content: CircularProgressIndicator(),
              );
            }));
    return Future.value();
  }

  void _addPlaylist() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const AddPlaylistDialog();
      },
    ).then((_) => SchedulerBinding.instance.addPostFrameCallback((_) => loadPlaylists()));
  }

  void changeTheme() async {
    Color seedColor = await getPreferenceColor();
    Brightness brightness = await getPreferenceBrightness();
    if (scaffoldKey.currentContext?.mounted ?? false) {
      await showDialog(
          barrierDismissible: false,
          context: scaffoldKey.currentContext!,
          builder: (context) => ThemeDialog(
              seedColor: seedColor, brightness: brightness, setColorScheme: (c) => setState(() => colorScheme = c)));
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(const SnackBar(
          duration: Duration(seconds: 6),
          content: Text('You may need to restart the app for the changes to take full effect.')));
    }
  }

  void showAbout() {
    showAboutDialog(
        context: context,
        applicationName: GetIt.instance<PackageInfo>().appName,
        applicationVersion: GetIt.instance<PackageInfo>().version,
        applicationIcon: const Icon(Icons.shuffle),
        //applicationLegalese: '© 2021 Shuffler',
        children: <Widget>[
          const Text(
              "Shuffler is an auxiliary app that allows you to freely shuffle your Spotify playlists and add them to your Spotify queue or into an automatically generated playlist."),
          const Text('This app is not affiliated with Spotify.'),
        ]);
  }

  void resetAuthentication() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Reset Authentication?'),
              content: const Text(
                  'Are you sure you want to reset your Spotify authentication? You will need to re-authenticate. If you are planning to log in to a different user make sure to delete any private playlists first. If you want a full reset, nuke the database first.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    APIClient().resetAuthentication();
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => const PopScope(
                              canPop: false,
                              child: AlertDialog(
                                title: Text('Authentication Reset!'),
                                content: Text('Close and Restart the app for the changes to take effect.'),
                              ),
                            ));
                  },
                ),
              ],
            ));
  }

  void nukeDatabase() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Nuke Database?'),
              content: const Text('Are you sure you want to delete all playlists? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Nuke'),
                  onPressed: () {
                    appDB.deleteAllPlaylists();
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => const PopScope(
                              canPop: false,
                              child: AlertDialog(
                                title: Text('Database Nuked!'),
                                content: Text('Close and Restart the app for the changes to take effect.'),
                              ),
                            ));
                  },
                ),
              ],
            ));
  }

  void deletePlaylist(Playlist playlist) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Delete ${playlist.name}?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    appDB
                        .deletePlaylistByID(playlist.playlistID)
                        .then((_) => setState(() => playlists.remove(playlist)));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  void navigateToPlaylistView(Playlist playlist) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Theme(
                data: Theme.of(context).copyWith(colorScheme: colorScheme), child: PlaylistView(playlist: playlist))));
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = colorScheme ?? Theme.of(context).colorScheme;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: colorScheme?.surface,
      key: scaffoldKey,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: colorScheme?.primary,
        foregroundColor: colorScheme?.onPrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          "Select or Add a Playlist",
          style: TextStyle(color: colorScheme?.onPrimary),
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Change Theme',
                child: Text('Change Theme'),
              ),
              const PopupMenuItem<String>(
                value: 'Nuke Database',
                child: Text('Nuke Database'),
              ),
              const PopupMenuItem<String>(
                value: 'Reset Authentication',
                child: Text('Reset Authentication'),
              ),
              const PopupMenuItem<String>(
                value: 'About',
                child: Text('About'),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'Change Theme':
                  changeTheme();
                  break;
                case 'About':
                  showAbout();
                  break;
                case 'Reset Authentication':
                  resetAuthentication();
                  break;
                case 'Nuke Database':
                  nukeDatabase();
                  break;
              }
            },
          ),
        ],
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Expanded(
              child: ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) => PlaylistDisplayCard(
                playlist: playlists[index],
                //On click, navigate to the playlist view
                onClick: () => navigateToPlaylistView(playlists[index]),
                onDelete: () => deletePlaylist(playlists[index]),
                bgColor: colorScheme!.secondary,
                textColor: colorScheme!.onSecondary),
          ))
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlaylist,
        tooltip: 'Add Playlist',
        backgroundColor: colorScheme?.primary,
        foregroundColor: colorScheme?.onPrimary,
        child: const Icon(Icons.playlist_add),
      ),
    );
  }
}
