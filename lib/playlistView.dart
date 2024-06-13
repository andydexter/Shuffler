import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/apiUtils.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/progressDialog.dart';
import 'package:shuffler/components/track.dart';
import 'package:shuffler/database/entities.dart';

class PlaylistView extends StatefulWidget {
  final Playlist playlist;

  const PlaylistView({super.key, required this.playlist});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> with TickerProviderStateMixin {
  final APIUtils apiUtils = APIUtils();
  final AppDatabase appDB = GetIt.instance<AppDatabase>();

  @override
  void initState() {
    super.initState();
    if (widget.playlist.tracks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => loadTracks());
    }
  }

  Future<void> loadTracks() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder(
          future: apiUtils.getTracksForPlaylist(widget.playlist),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => setState(() => widget.playlist.tracks = snapshot.data!));
              return AlertDialog(
                title: const Text('Tracks loaded'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else if (snapshot.hasError ||
                (snapshot.connectionState == ConnectionState.done && snapshot.data == null)) {
              return AlertDialog(
                title: Text(snapshot.error.toString()),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              return const AlertDialog(
                title: Text('Loading tracks...'),
                content: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  void _addPlaylistToQueue() {
    double sliderValue = widget.playlist.tracks.length / 2.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select number of tracks to add to queue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Number of tracks: ${sliderValue.toInt()}'),
                Slider(
                  divisions: widget.playlist.tracks.length - 1,
                  value: sliderValue,
                  onChanged: (newValue) {
                    setState(() {
                      sliderValue = newValue;
                    });
                  },
                  min: 0.0,
                  max: widget.playlist.tracks.length.toDouble(),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    sliderValue = 0.0;
                  });
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
        });
      },
    ).then((_) => {
          if (sliderValue > 0)
            addTracksToQueue(widget.playlist.getShuffledTracks().sublist(0, sliderValue.toInt()))
                .then((_) => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: const Text('Tracks added to queue'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )))
                .catchError((error, stack) => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text(error.toString()),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )))
        });
  }

  Future<void> addTracksToQueue(List<Track> tracks) async {
    final AnimationController controller = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {});
      });
    controller.value = 0.0;
    controller.stop();
    ProgressDialog progressDialog = ProgressDialog(
        message: 'Adding tracks to queue...', controller: controller, context: context, upperBound: tracks.length);
    controller.addListener(() {
      if (controller.value == 1.0) {
        progressDialog.pop();
      }
    });
    showDialog(barrierDismissible: false, context: context, builder: (context) => progressDialog);
    for (int i = 0; i < tracks.length; i++) {
      bool success = true;
      await apiUtils.addTrackToQueue(tracks[i]).catchError((onError) {
        progressDialog.pop();
        success = false;
      });
      if (!success) {
        return;
      }
      if (tracks.length > 80) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
      await progressDialog.increment();
    }
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
              return widget.playlist.tracks[index];
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: _addPlaylistToQueue,
          tooltip: 'Add to queue',
          child: const Icon(Icons.playlist_add_check),
        ));
  }
}
