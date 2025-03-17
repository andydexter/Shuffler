///
///     Copyright (C) 2024  Andreas Nicolaou
///
///     This program is free software: you can redistribute it and/or modify
///     it under the terms of the GNU General Public License as published by
///     the Free Software Foundation, either version 3 of the License, or
///     (at your option) any later version.
///
///     This program is distributed in the hope that it will be useful,
///     but WITHOUT ANY WARRANTY; without even the implied warranty of
///     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
///     GNU General Public License for more details.
///
///     You should have received a copy of the GNU General Public License
///     along with this program. You can find it at project root.
///     If not, see <https://www.gnu.org/licenses/>.
///
///     Author E-mail address: andydexter123@gmail.com
///

library;

import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/error_dialog.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/components/progress_dialog.dart';
import 'package:shuffler/data_objects/shuffle_tool.dart';
import 'package:shuffler/data_objects/track.dart';

class ShuffleDialog extends StatefulWidget {
  final Playlist playlist;

  const ShuffleDialog({super.key, required this.playlist});

  @override
  State<ShuffleDialog> createState() => _ShuffleDialogState();
}

class _ShuffleDialogState extends State<ShuffleDialog>
    with TickerProviderStateMixin {
  Logger lg = Logger('Shuffler/ShuffleDialog');
  APIUtils apiUtils = GetIt.I<APIUtils>();

  late final ShuffleTool shuffleTool;

  Timer? _debounceRecentTracks;
  bool loadingRecentTracks = false;
  bool playerActive = false;
  late CancelableOperation playerActivationFuture;

  @override
  void initState() {
    shuffleTool = ShuffleTool.defaultConfig(widget.playlist);
    playerActivationFuture =
        CancelableOperation.fromFuture(apiUtils.waitForPlayerActivated())
            .then((_) {
      //waiting for player will have a minimum delay of 2 seconds. This should be enough for the build process to finish
      if (mounted) {
        setState(() {
          playerActive = true;
        });
      } else {
        //If the building process is still going on, we need to make sure the status updates after it is finished.
        WidgetsBinding.instance
            .addPostFrameCallback((_) => setState(() => playerActive = true));
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
    bool cancel = false;
    controller.value = 0.0;
    controller.stop();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => PopScope(
              canPop: false,
              child: ProgressDialog(
                  message: 'Adding tracks to queue...',
                  controller: controller,
                  context: context,
                  upperBound: tracks.length,
                  onCancel: () => cancel = true),
            ));
    lg.info('ProgressDialog shown');
    for (int i = 0; i < tracks.length; i++) {
      //If aborted by user, dismiss controller and stop.
      if (cancel) {
        if (!controller.isDismissed) controller.dispose();
        lg.info('Cancelled adding tracks to queue');
        return;
      }
      //Add track to queue. If error, dismiss controller and return error.
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
      await controller.animateTo((i + 1) / tracks.length,
          duration: const Duration(milliseconds: 50));
    }
    if (!controller.isDismissed) controller.dispose();
    lg.info('${tracks.length} Tracks added to queue');
  }

  Future<void> addTracksToPlaylist(List<Track> tracks) async {
    if (mounted) {
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => FutureBuilder(
              future:
                  apiUtils.generateAndAddToPlaylist(widget.playlist, tracks),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorDialog(errorMessage: snapshot.error.toString());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                      future: playerActivationFuture.value,
                      builder: (context, _) {
                        return PlayPlaylistDialog(
                            playerActive: playerActive,
                            playlist: snapshot.data as Playlist);
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
    List<Track> toShuffle = await shuffleTool.shuffle();
    if (toShuffle.isNotEmpty &&
        shuffleTool.shuffleAction == ShuffleAction.addToQueue) {
      await addTracksToQueue(toShuffle).then((_) {
        if (context.mounted) {
          showDialog(
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
                  ));
        }
      }).catchError((error) {
        if (context.mounted) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorDialog(errorMessage: error.toString()));
        }
      });
    }
    if (toShuffle.isNotEmpty &&
        shuffleTool.shuffleAction == ShuffleAction.addToPlaylist) {
      await addTracksToPlaylist(toShuffle);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  void getRecentTracksToRemove(double value) async {
    _debounceRecentTracks?.cancel();
    shuffleTool.numRecentTracksToSearch = value.toInt();
    shuffleTool.recentTracksFuture
        .then((_) => setState(() => (loadingRecentTracks = true)));
    _debounceRecentTracks = Timer(const Duration(milliseconds: 800), () async {
      await shuffleTool.recentTracksFuture;
      if (mounted) {
        setState(() => (loadingRecentTracks = false,));
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
                              value: shuffleTool.numRecentTracksToSearch
                                  .toDouble(),
                              onChanged: getRecentTracksToRemove,
                              min: 0,
                              max: 50),
                        ),
                        Text(shuffleTool.numRecentTracksToSearch.toString()),
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
                  children: [
                    const Text("Found Tracks:"),
                    Text(shuffleTool.numRecentTracksFound.toString())
                  ],
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
                      value: shuffleTool.shuffleAction ==
                          ShuffleAction.addToPlaylist,
                      onChanged: (value) => setState(() =>
                          shuffleTool.shuffleAction = value
                              ? ShuffleAction.addToPlaylist
                              : ShuffleAction.addToQueue)),
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
          Text('Number of tracks: ${shuffleTool.numTracks.toInt()}'),
          Slider(
            key: const Key("NumTracksSlider"),
            divisions: shuffleTool.maxTracksToShuffle - 1,
            value: shuffleTool.numTracks.toDouble(),
            onChanged: (newValue) {
              setState(() {
                shuffleTool.numTracks = newValue.toInt();
              });
            },
            min: 0.0,
            max: shuffleTool.maxTracksToShuffle.toDouble(),
          ),
          const SizedBox(
            height: 10,
          ),
          if (!playerActive &&
              shuffleTool.shuffleAction == ShuffleAction.addToQueue)
            const Flexible(
              child: Text(
                'Make sure you\'re already playing something on spotify before clicking Submit',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
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
          onPressed: (shuffleTool.shuffleAction == ShuffleAction.addToQueue &&
                  !playerActive)
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
              'Make sure you\'re already playing something on spotify before clicking Play',
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
                  await GetIt.I<APIUtils>().playPlaylist(playlist.playlistID);
                }
              : null,
          child: const Text('Play'),
        ),
      ],
    );
  }
}

enum ShuffleType { shuffleIntoQueue, shuffleIntoPlaylist }
