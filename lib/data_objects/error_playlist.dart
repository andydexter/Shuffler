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
import 'package:shuffler/data_objects/playlist.dart';

class ErrorPlaylist extends Playlist {
  final String error;
  final String spotifyID;
  ErrorPlaylist({
    required this.error,
    this.spotifyID = '',
  }) : super(name: error, image: const Image(image: AssetImage('assets/images/error-icon.png')));

  @override
  String get playlistID => spotifyID;

  @override
  Future<void> loadTracks() async {
    tracks = [];
    tracksLoaded = true;
  }

  @override
  String toString() {
    return "<ErrorPlaylist: $error>";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ErrorPlaylist) {
      return error == other.error && playlistID == other.playlistID;
    }
    return false;
  }

  @override
  int get hashCode {
    return playlistID.hashCode;
  }
}
