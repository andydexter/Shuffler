import 'dart:async';
import 'dart:math';
import 'package:async/async.dart';
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
  bool playerActive = false;
  late CancelableOperation playerActivationFuture;

  @override
  void initState() {
    tracksToShuffle = 0.5 * widget.playlist.tracks.length;
    maxTracksToShuffle = widget.playlist.tracks.length.toDouble();
    playerActivationFuture = CancelableOperation.fromFuture(apiUtils.waitForPlayerActivated()).then((_) {
      //waiting for player will have a minimum delay of 2 seconds. This should be enough for the build process to finish
      if (mounted) {
        setState(() {
          playerActive = true;
        });
      } else {
        //If the building process is still going on, we need to make sure the status updates after it is finished.
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => playerActive = true));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    playerActivationFuture.cancel();
    _debounceRecentTracks?.cancel();
    super.dispose();
  }

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
        if (!controller.isDismissed) controller.dispose();
        error = errorMsg;
      });
      if (error.isNotEmpty) {
        lg.severe("Add Track to queue error: $error");
        return Future.error(error);
      }
      // Delay to avoid rate limiting
      if (tracks.length > 80) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
      await controller.animateTo((i + 1) / tracks.length, duration: const Duration(milliseconds: 50));
    }
    if (!controller.isDismissed) controller.dispose();
    lg.info('${tracks.length} Tracks added to queue');
  }

  Future<Playlist> generateAndAddToPlaylist(List<Track> tracks) async {
    final Playlist generatedPlaylist = await apiUtils.generatePlaylistIfNotExists(widget.playlist.name);
    await apiUtils.addTracksToGeneratedPlaylist(generatedPlaylist.spotifyID, tracks);
    await Future.delayed(const Duration(seconds: 2));
    return generatedPlaylist;
  }

  Future<void> addTracksToPlaylist(List<Track> tracks) async {
    if (mounted) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => FutureBuilder(
              future: generateAndAddToPlaylist(tracks),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorDialog(errorMessage: snapshot.error.toString());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                      future: playerActivationFuture.value,
                      builder: (context, _) {
                        return PlayPlaylistDialog(playerActive: playerActive, playlist: snapshot.data as Playlist);
                      });
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
    List<Track> toShuffle = widget.playlist.getShuffledTracks()
      ..removeWhere(
        (element) => recentTracksToRemove.contains(element),
      );
    toShuffle = toShuffle.sublist(0, tracksToShuffle.toInt());
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
    if (mounted) Navigator.of(context).pop();
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
      if (mounted) {
        setState(() => (
              recentTracksFound = recentTracksToRemove.length,
              maxTracksToShuffle = widget.playlist.tracks.length.toDouble() - recentTracksFound,
              tracksToShuffle = min(tracksToShuffle, maxTracksToShuffle),
              loadingRecentTracks = false,
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Shuffle Playlist',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  children: [
                    const Text(
                      "Number of recent tracks to search:",
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Slider(
                              key: const Key("recentTracksSlider"),
                              divisions: 5,
                              value: numOfRecentTracksToRemove,
                              onChanged: getRecentTracksToRemove,
                              min: 0,
                              max: 50),
                        ),
                        Text(numOfRecentTracksToRemove.toInt().toString()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                    child: Text(
                  'Shuffle into queue',
                  textAlign: TextAlign.center,
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Switch(
                      value: shuffleType == ShuffleType.shuffleIntoPlaylist,
                      onChanged: (value) => setState(
                          () => shuffleType = value ? ShuffleType.shuffleIntoPlaylist : ShuffleType.shuffleIntoQueue)),
                ),
                const Expanded(
                    child: Text(
                  'Shuffle into playlist',
                  textAlign: TextAlign.center,
                )),
              ],
            ),
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
          const SizedBox(
            height: 10,
          ),
          if (!playerActive && shuffleType == ShuffleType.shuffleIntoQueue)
            const Flexible(
              child: Text(
                'Make sure you\'re already playing something on spotify before clicking Submit',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
              ),
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
          onPressed: shuffleType == ShuffleType.shuffleIntoQueue && !playerActive
              ? null
              : () async {
                  await submit(context);
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class PlayPlaylistDialog extends StatelessWidget {
  const PlayPlaylistDialog({
    super.key,
    required this.playerActive,
    required this.playlist,
  });

  final bool playerActive;
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tracks added to playlist!'),
      content: playerActive
          ? const Text('Do you want to play the playlist now?')
          : const Text(
              'Make sure you\'re already playing something on spotify before clicking Submit',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: playerActive
              ? () async {
                  Navigator.of(context).pop();
                  await GetIt.I<APIUtils>().playPlaylist(playlist.spotifyID);
                }
              : null,
          child: const Text('Play'),
        ),
      ],
    );
  }
}

enum ShuffleType { shuffleIntoQueue, shuffleIntoPlaylist }
