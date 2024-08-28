/***

    Copyright (C) 2024  Andreas Nicolaou

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. You can find it at project root.
    If not, see <https://www.gnu.org/licenses/>.

    Author E-mail address: andydexter123@gmail.com

***/
import 'package:flutter/material.dart';
import 'package:shuffler/data_objects/track.dart';
import 'dart:math';

/// Represents an abstract playlist.
/// This abstract class consists of all the properties needed to *Display* and *Identify* a playlist.
abstract class Playlist {
  final String name;
  List<Track> tracks;
  bool tracksLoaded = false;
  Widget image;

  /// The unique identifier for the playlist.
  /// This can be the spotify ID, or a custom ID depending on the implementation of the playlist.
  /// This property MUST be overridden by subclasses.
  /// This property MUST be used to compare playlists.
  String get playlistID;

  /// Constructs a Playlist object with the given [name], [tracks], and [image].
  Playlist({required this.name, this.tracks = const [], required this.image});

  /// Returns a list of shuffled tracks.
  List<Track> getShuffledTracks() {
    List<Track> shuffledTracks = [...tracks];
    shuffledTracks.shuffle(Random());

    return shuffledTracks;
  }

  /// Loads the tracks for the playlist.
  /// This method should be overridden by subclasses to load the tracks from the API or similar.
  /// This method MUST store the fetched tracks in the [tracks] property.
  /// This method MUST set the [tracksLoaded] property to `true` after the tracks have been loaded.
  /// This method MUST load the tracks in the same way irrespective of the status of [tracksLoaded].
  Future<void> loadTracks();

  /// Compares this playlist to another object.
  /// 2 playlists are considered equal if their [playlistID]s are equal.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Playlist) {
      return playlistID == other.playlistID;
    }
    return false;
  }

  @override
  int get hashCode {
    return playlistID.hashCode;
  }

  @override
  String toString() {
    return "<Playlist: $name, $playlistID, $tracks>";
  }
}
