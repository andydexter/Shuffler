import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/error_dialog.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/progress_dialog.dart';
import 'package:shuffler/components/track.dart';

class ShuffleDialog extends StatefulWidget {
  final Playlist playlist;

  const ShuffleDialog({super.key, required this.playlist});

  @override
  State<ShuffleDialog> createState() => _ShuffleDialogState();
}

class _ShuffleDialogState extends State<ShuffleDialog> with TickerProviderStateMixin {
  double sliderValue = 0.0;
  ShuffleType shuffleType = ShuffleType.shuffleIntoQueue;
  Logger lg = Logger('Shuffler/ShuffleDialog');
  APIUtils apiUtils = GetIt.I<APIUtils>();

  Future<void> addTracksToQueue(List<Track> tracks) async {
    final AnimationController controller = AnimationController(vsync: this);
    controller.value = 0.0;
    controller.stop();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ProgressDialog(
            message: 'Adding tracks to queue...', controller: controller, context: context, upperBound: tracks.length));
    lg.info('ProgressDialog shown');
    for (int i = 0; i < tracks.length; i++) {
      String error = '';
      await apiUtils.addTrackToQueue(tracks[i]).catchError((errorMsg) {
        controller.dispose();
        error = errorMsg;
      });
      if (error.isNotEmpty) {
        controller.dispose();
        lg.severe("Add Track to queue error: $error");
        return Future.error(error);
      }
      // Delay to avoid rate limiting
      if (tracks.length > 80) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
      await controller.animateTo((i + 1) / tracks.length, duration: const Duration(milliseconds: 100));
    }
    controller.dispose();
    lg.info('${tracks.length} Tracks added to queue');
  }

  Future<Playlist> generateAndAddToPlaylist(List<Track> tracks) async {
    final Playlist generatedPlaylist = await apiUtils.generatePlaylistIfNotExists(widget.playlist.name);
    await apiUtils.addTracksToGeneratedPlaylist(generatedPlaylist.spotifyID, tracks);
    await Future.delayed(const Duration(seconds: 2));
    return generatedPlaylist;
  }

  Future<void> addTracksToPlaylist(List<Track> tracks) async {
    if (context.mounted) {
      await showDialog(
          barrierDismissible: false,
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => FutureBuilder(
              future: generateAndAddToPlaylist(tracks),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorDialog(errorMessage: snapshot.error.toString());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return AlertDialog(
                    title: const Text('Tracks added to playlist!'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Play'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await apiUtils.playPlaylist((snapshot.data as Playlist).spotifyID);
                        },
                      ),
                    ],
                  );
                }
                return const PopScope(
                  canPop: false,
                  child: AlertDialog(
                    title: Text('Adding tracks to playlist...'),
                    content: CircularProgressIndicator(),
                  ),
                );
              }));
    }
  }

  Future<void> submit(BuildContext context) async {
    if (sliderValue > 0 && shuffleType == ShuffleType.shuffleIntoQueue) {
      await addTracksToQueue(widget.playlist.getShuffledTracks().sublist(0, sliderValue.toInt()))
          .then((_) => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Tracks added to queue!'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )))
          .catchError((error) =>
              showDialog(context: context, builder: (context) => ErrorDialog(errorMessage: error.toString())));
    }
    if (sliderValue > 0 && shuffleType == ShuffleType.shuffleIntoPlaylist) {
      await addTracksToPlaylist(widget.playlist.getShuffledTracks().sublist(0, sliderValue.toInt()));
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  void initState() {
    sliderValue = 0.5 * widget.playlist.tracks.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select number of tracks to add to queue'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Shuffle into queue'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Switch(
                    value: shuffleType == ShuffleType.shuffleIntoPlaylist,
                    onChanged: (value) => setState(
                        () => shuffleType = value ? ShuffleType.shuffleIntoPlaylist : ShuffleType.shuffleIntoQueue)),
              ),
              const Text('Shuffle into playlist'),
            ],
          ),
          const SizedBox(height: 20),
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
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Submit'),
          onPressed: () async {
            await submit(context);
          },
        ),
      ],
    );
  }
}

enum ShuffleType { shuffleIntoQueue, shuffleIntoPlaylist }
