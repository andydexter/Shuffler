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
import 'package:shuffler/components/play_playlist_dialog.dart';
import 'package:shuffler/components/rectangular_slider_thumb_shape.dart';
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
    if (shuffleTool.numRecentTracksToSearch > 0) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => getRecentTracksToRemove(
          shuffleTool.numRecentTracksToSearch.toDouble(),
        ),
      );
    }
    playerActivationFuture = CancelableOperation.fromFuture(
      apiUtils.waitForPlayerActivated(),
    ).then((_) {
      //waiting for player will have a minimum delay of 2 seconds. This should be enough for the build process to finish
      if (mounted) {
        setState(() => playerActive = true);
      } else {
        //If the building process is still going on, we need to make sure the status updates after it is finished.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => playerActive = true),
        );
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
      builder:
          (context) => ProgressDialog(
            message: 'Adding tracks to queue...',
            controller: controller,
            context: context,
            upperBound: tracks.length,
            onCancel: () => cancel = true,
          ),
    );
    lg.info('ProgressDialog shown');
    String? error;
    int i = 0;
    for (i = 0; i < tracks.length; i++) {
      //If aborted by user, dismiss controller and stop.
      if (cancel) {
        lg.info('Cancelled adding tracks to queue');
        break;
      }
      //Add track to queue. If error, set error string.
      await apiUtils
          .addTrackToQueue(tracks[i])
          .catchError((errorMsg) => error = errorMsg);
      if (error != null) {
        break;
      }
      // Delay to avoid rate limiting
      if (tracks.length > 80) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
      await controller.animateTo(
        (i + 1) / tracks.length,
        duration: const Duration(milliseconds: 50),
      );
    }
    if (!controller.isDismissed) controller.dispose();
    if (mounted) Navigator.of(context).pop();
    if (error != null) {
      lg.severe("Error when adding tracks to queue: $error");
      return Future.error(error!);
    }
    lg.info('$i/${tracks.length} Tracks added to queue');
  }

  Future<void> addTracksToPlaylist(List<Track> tracks) async {
    if (mounted) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder:
            (context) => FutureBuilder(
              future: apiUtils.generateAndAddToPlaylist(
                widget.playlist,
                tracks,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorDialog(errorMessage: snapshot.error.toString());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                    future: playerActivationFuture.value,
                    builder: (context, _) {
                      return PlayPlaylistDialog(
                        playerActive: playerActive,
                        playlist: snapshot.data as Playlist,
                      );
                    },
                  );
                }
                return const PopScope(
                  canPop: false,
                  child: AlertDialog(
                    title: Text('Adding tracks to playlist...'),
                    content: CircularProgressIndicator(),
                  ),
                );
              },
            ),
      );
    }
  }

  Future<void> submit(BuildContext context) async {
    List<Track> toShuffle = await shuffleTool.shuffle();
    if (toShuffle.isNotEmpty &&
        shuffleTool.shuffleAction == ShuffleAction.addToQueue) {
      await addTracksToQueue(toShuffle)
          .then((_) {
            if (context.mounted) {
              showDialog(
                context: context,
                builder:
                    (BuildContext context) => AlertDialog(
                      title: const Text('Tracks added to queue!'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
              );
            }
          })
          .catchError((error) {
            if (context.mounted) {
              showDialog(
                context: context,
                builder:
                    (context) => ErrorDialog(errorMessage: error.toString()),
              );
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
    shuffleTool.recentTracksFuture.then(
      (_) => setState(() => (loadingRecentTracks = true)),
    );
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
      title: const Text('Shuffle Playlist', textAlign: TextAlign.center),
      titlePadding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 24.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 15.0,
      ),
      actionsPadding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        bottom: 24.0,
      ),
      content: SliderTheme(
        data: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
          trackHeight: 10,
          activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
          thumbColor: Theme.of(context).colorScheme.onPrimaryContainer,
          thumbShape: RectangularSliderThumbShape(
            borderColor: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 5.0,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 5,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        bottom: 5.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10.0,
                        children: [
                          Flexible(
                            child: Column(
                              children: [
                                const Text(
                                  "Number of recent tracks to search:",
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        key: const Key("recentTracksSlider"),
                                        divisions: 10,
                                        value:
                                            shuffleTool.numRecentTracksToSearch
                                                .toDouble(),
                                        onChanged:
                                            shuffleTool.recentTrackAction ==
                                                    RecentTrackAction.none
                                                ? null
                                                : getRecentTracksToRemove,
                                        min: 0,
                                        max: 50,
                                      ),
                                    ),
                                    Text(
                                      shuffleTool.numRecentTracksToSearch
                                          .toString(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Found Tracks:"),
                                  Text(
                                    shuffleTool.numRecentTracksFound.toString(),
                                  ),
                                ],
                              ),
                              if (loadingRecentTracks)
                                const CircularProgressIndicator(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SegmentedButton<RecentTrackAction>(
                        segments: const [
                          ButtonSegment<RecentTrackAction>(
                            value: RecentTrackAction.exclude,
                            label: Text("Ommit", textAlign: TextAlign.center),
                            icon: Icon(Icons.cancel),
                          ),
                          ButtonSegment<RecentTrackAction>(
                            value: RecentTrackAction.moveToEnd,
                            label: Text(
                              "Move to End",
                              textAlign: TextAlign.center,
                            ),
                            icon: Icon(Icons.last_page),
                          ),
                        ],
                        selected: <RecentTrackAction>{
                          shuffleTool.recentTrackAction,
                        },
                        onSelectionChanged:
                            shuffleTool.numRecentTracksToSearch == 0
                                ? null
                                : (newSelection) => setState(
                                  () =>
                                      shuffleTool.recentTrackAction =
                                          newSelection.first,
                                ),
                      ),
                    ),
                    Divider(),
                    Column(
                      children: [
                        Text(
                          'Number of tracks to shuffle: ${shuffleTool.numTracks}/${shuffleTool.maxTracksToShuffle}',
                        ),
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
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: SegmentedButton<ShuffleAction>(
                            segments: const <ButtonSegment<ShuffleAction>>[
                              ButtonSegment<ShuffleAction>(
                                value: ShuffleAction.addToQueue,
                                label: Text(
                                  "Shuffle Into Queue",
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                                icon: Icon(Icons.queue),
                              ),
                              ButtonSegment<ShuffleAction>(
                                value: ShuffleAction.addToPlaylist,
                                label: Text(
                                  "Shuffle Into Playlist",
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                                icon: Icon(Icons.featured_play_list),
                              ),
                            ],
                            selected: <ShuffleAction>{
                              shuffleTool.shuffleAction,
                            },
                            onSelectionChanged: (
                              Set<ShuffleAction> newSelection,
                            ) {
                              setState(
                                () =>
                                    shuffleTool.shuffleAction =
                                        newSelection.first,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!playerActive &&
                shuffleTool.shuffleAction == ShuffleAction.addToQueue)
              const Flexible(
                child: Text(
                  'Make sure you\'re already playing something on spotify',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: shuffleTool.clearDefaultSettings,
              child: const Text('Clear', softWrap: true),
            ),
            TextButton(
              onPressed: shuffleTool.saveDefaultSettings,
              child: const Text('Save', softWrap: true),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed:
                  (shuffleTool.shuffleAction == ShuffleAction.addToQueue &&
                          !playerActive)
                      ? null
                      : () async {
                        await submit(context);
                      },
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }
}
