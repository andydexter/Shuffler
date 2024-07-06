import 'dart:async';
import 'dart:math';

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
  double tracksToShuffle = 0.0;
  double maxTracksToShuffle = 0.0;
  ShuffleType shuffleType = ShuffleType.shuffleIntoQueue;
  Logger lg = Logger('Shuffler/ShuffleDialog');
  APIUtils apiUtils = GetIt.I<APIUtils>();

  Timer? _debounceRecentTracks;
  bool loadingRecentTracks = false;
  double numOfRecentTracksToRemove = 0.0;
  int recentTracksFound = 0;
  Set<Track> recentTracksToRemove = Set.of(List.empty());

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
    List<Track> toShuffle = widget.playlist.getShuffledTracks().sublist(0, tracksToShuffle.toInt())
      ..removeWhere(
        (element) => recentTracksToRemove.contains(element),
      );
    if (tracksToShuffle > 0 && shuffleType == ShuffleType.shuffleIntoQueue) {
      await addTracksToQueue(toShuffle)
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
    if (tracksToShuffle > 0 && shuffleType == ShuffleType.shuffleIntoPlaylist) {
      await addTracksToPlaylist(toShuffle);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  void getRecentTracksToRemove(double value) async {
    _debounceRecentTracks?.cancel();
    setState(() => (numOfRecentTracksToRemove = value, loadingRecentTracks = true));
    _debounceRecentTracks = Timer(const Duration(milliseconds: 800), () async {
      if (value.toInt() == 0) {
        recentTracksToRemove.clear();
      } else {
        recentTracksToRemove = (await apiUtils.getRecentlyPlayedTracks(numOfRecentTracksToRemove.toInt())).toSet()
          ..retainWhere((t) => widget.playlist.tracks.contains(t));
      }
      setState(() => (
            recentTracksFound = recentTracksToRemove.length,
            maxTracksToShuffle = widget.playlist.tracks.length.toDouble() - recentTracksFound,
            tracksToShuffle = min(tracksToShuffle, maxTracksToShuffle),
            loadingRecentTracks = false,
          ));
    });
  }

  @override
  void initState() {
    tracksToShuffle = 0.5 * widget.playlist.tracks.length;
    maxTracksToShuffle = widget.playlist.tracks.length.toDouble();
    super.initState();
  }

  @override
  void dispose() {
    _debounceRecentTracks?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select number of tracks to add to queue'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text("Number of recent tracks to search:"),
                  Row(
                    children: [
                      Slider(
                          key: const Key("recentTracksSlider"),
                          divisions: 5,
                          value: numOfRecentTracksToRemove,
                          onChanged: getRecentTracksToRemove,
                          min: 0,
                          max: 50),
                      Text(numOfRecentTracksToRemove.toString()),
                    ],
                  ),
                ],
              ),
              Stack(alignment: AlignmentDirectional.center, children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [const Text("Found Tracks:"), Text(recentTracksFound.toString())],
                ),
                if (loadingRecentTracks) const CircularProgressIndicator(),
              ])
            ],
          ),
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
          Text('Number of tracks: ${tracksToShuffle.toInt()}'),
          Slider(
            key: const Key("NumTracksSlider"),
            divisions: maxTracksToShuffle.toInt() - 1,
            value: tracksToShuffle,
            onChanged: (newValue) {
              setState(() {
                tracksToShuffle = newValue;
              });
            },
            min: 0.0,
            max: maxTracksToShuffle,
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
