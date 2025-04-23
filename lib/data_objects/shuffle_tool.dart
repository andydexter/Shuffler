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

import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/data_objects/track.dart';

class ShuffleTool {
  Playlist playlist;
  int _numTracks = 0;
  int _numRecentTracksToSearch = 0;
  Set<Track> _recentTracks = <Track>{};
  Future<Set<Track>> _recentTracksFuture = Future.value(<Track>{});
  RecentTrackAction _recentTrackAction = RecentTrackAction.none;
  ShuffleAction shuffleAction;
  final Logger lg = Logger("Shuffler/ShuffleTool");

  ShuffleTool(this.playlist, int numTracks, int numRecentTracksToSearch,
      RecentTrackAction recentTrackAction, this.shuffleAction) {
    _recentTracks = <Track>{};
    _recentTracksFuture = Future.value(_recentTracks);
    this.numRecentTracksToSearch = numRecentTracksToSearch;
    this.numTracks = numTracks;
    this.recentTrackAction = recentTrackAction;
  }

  factory ShuffleTool.defaultConfig(Playlist playlist) {
    SharedPreferences sp = GetIt.I<SharedPreferences>();
    return ShuffleTool(
        playlist,
        ((sp.getDouble("ShuffleTool_def_numTracksFraction") ?? 0.5) *
                playlist.tracks.length)
            .toInt(),
        sp.getInt("ShuffleTool_def_numRecentTracksToSearch") ?? 0,
        RecentTrackAction.values[sp.getInt("ShuffleTool_def_recentTrackAction") ?? 1],
        ShuffleAction.values[sp.getInt("ShuffleTool_def_shuffleAction") ?? 0]);
  }

  void saveDefaultSettings(){
    SharedPreferences sp = GetIt.I<SharedPreferences>();
    sp.setDouble("ShuffleTool_def_numTracksFraction", numTracks/playlist.tracks.length);
    sp.setInt("ShuffleTool_def_numRecentTracksToSearch", numRecentTracksToSearch);
    sp.setInt("ShuffleTool_def_recentTrackAction", recentTrackAction.index);
    sp.setInt("ShuffleTool_def_shuffleAction", shuffleAction.index);
  }

  void clearDefaultSettings(){
    SharedPreferences sp = GetIt.I<SharedPreferences>();
    sp.remove("ShuffleTool_def_numTracksFraction");
    sp.remove("ShuffleTool_def_numRecentTracksToSearch");
    sp.remove("ShuffleTool_def_recentTrackAction");
    sp.remove("ShuffleTool_def_shuffleAction");
  }

  set numRecentTracksToSearch(int numRecentTracks) {
    lg.info("Searching recent tracks");
    if(_numRecentTracksToSearch == numRecentTracks) return;
    _numRecentTracksToSearch = numRecentTracks;
    if (numRecentTracks == 0) {
      _recentTracksFuture.then((v) => v.clear());
      _recentTracks.clear();
    } else {
      _recentTracksFuture = GetIt.I<APIUtils>()
          .getRecentlyPlayedTracks(numRecentTracks)
          .then((out) =>
              out.toSet()..retainWhere((t) => playlist.tracks.contains(t))) // Get set of recent & relevant tracks 
          .then((fin) => _recentTracks = fin) // Set the private attribute
          .whenComplete(() => numTracks = _numTracks); // Refresh the numTracks attribute as maxTracksToShuffle will change
    }
  }

  set numTracks(int numTracks) {
    _numTracks = min(maxTracksToShuffle, numTracks);
  }

  int get numTracks => _numTracks;

  set recentTrackAction(RecentTrackAction rta){
    _recentTrackAction = rta;
    numTracks = numTracks; // Refresh the numTracks attribute as maxTracksToShuffle will change
  }

  RecentTrackAction get recentTrackAction => _recentTrackAction;

  int get numRecentTracksToSearch => _numRecentTracksToSearch;

  int get maxTracksToShuffle => playlist.tracks.length - (recentTrackAction == RecentTrackAction.none ? 0 : _recentTracks.length);

  int get numRecentTracksFound => _recentTracks.length;

  Future<Set<Track>> get recentTracksFuture => _recentTracksFuture;

  Set<Track> get recentTracks => _recentTracks;

  /// Returns a list of shuffled tracks.
  Future<List<Track>> shuffle() async {
    List<Track> shuffledTracks = [...playlist.tracks];
    Set<Track>? recentTracks;
    if (recentTrackAction != RecentTrackAction.none) {
      recentTracks = await _recentTracksFuture;
      shuffledTracks.removeWhere((t) => recentTracks!.contains(t));
    }
    shuffledTracks.shuffle(Random());
    shuffledTracks = shuffledTracks.take(_numTracks).toList();
    if (recentTrackAction == RecentTrackAction.moveToEnd) {
      shuffledTracks.addAll(recentTracks!);
    }
    return shuffledTracks;
  }
}

enum RecentTrackAction {
  none,
  exclude,
  moveToEnd,
}

enum ShuffleAction {
  addToQueue,
  addToPlaylist,
}
