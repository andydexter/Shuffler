import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/error_dialog.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/components/shuffle_dialog.dart';

class PlaylistView extends StatefulWidget {
  final Playlist playlist;

  const PlaylistView({super.key, required this.playlist});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final APIUtils apiUtils = GetIt.I<APIUtils>();
  final Logger lg = Logger("Shuffler/PlaylistView");

  @override
  void initState() {
    super.initState();
    if (!widget.playlist.tracksLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => loadTracks());
    }
  }

  Future<void> loadTracks() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder(
          future: widget.playlist.loadTracks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorDialog(errorMessage: snapshot.error.toString());
            } else if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Center(child: Text('Tracks loaded!')),
                  duration: Duration(seconds: 2),
                ));
                setState(() {});
              });
              Navigator.of(context).pop();
            }
            return const AlertDialog(
              title: Text('Loading tracks...'),
              content: CircularProgressIndicator(),
            );
          }),
    );
  }

  void _addPlaylistToQueue() async {
    await showDialog(
      context: context,
      builder: (context) => ShuffleDialog(playlist: widget.playlist),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.playlist.name),
        ),
        body: ListView.builder(
            itemCount: widget.playlist.tracks.length,
            itemBuilder: (context, index) {
              return widget.playlist.tracks[index].getWidget();
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: _addPlaylistToQueue,
          tooltip: 'Add to queue',
          child: const Icon(Icons.playlist_add_check),
        ));
  }
}
