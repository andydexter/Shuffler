import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/theme_dialog.dart';
import 'package:shuffler/database/entities.dart';
import 'package:shuffler/main.dart';
import 'package:shuffler/playlist_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  APIUtils apiUtils = APIUtils();
  List<Playlist> playlists = List.empty(growable: true);
  final appDB = GetIt.instance<AppDatabase>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ColorScheme? colorScheme;

  @override
  void initState() {
    super.initState();
    appDB.getAllPlaylists().then((value) => setState(() {
          playlists = value;
        }));
  }

  void _addPlaylist() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Playlist URL or ID'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "URL or ID"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                controller.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) => {
          if (controller.text.isNotEmpty)
            {
              apiUtils.getPlaylist(controller.text.split('/').last.split('?').first).then((playlist) => {
                    appDB.persistPlaylist(playlist),
                    setState(() {
                      playlists.add(playlist);
                    })
                  }),
              showGeneralDialog(
                  context: context,
                  pageBuilder: (context, anim1, anim2) =>
                      AlertDialog(title: const Text('Playlist added'), actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ]))
            }
        });
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
              "Shuffler is an auxiliary app that allows you to freely shuffle your Spotify playlists and add them to your Spotify queue."),
          const Text('This app is not affiliated with Spotify.'),
        ]);
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
              }
            },
          ),
        ],
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) => playlists[index].getCard(
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Theme(
                                data: Theme.of(context).copyWith(colorScheme: colorScheme),
                                child: PlaylistView(playlist: playlists[index])))),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
