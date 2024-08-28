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

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/playlist.dart';

class LikedSongsPlaylist extends Playlist {
  static const String likedSongsID = '<Liked Songs Playlist>';
  @override
  get playlistID => likedSongsID;

  LikedSongsPlaylist()
      : super(
          name: 'Liked Songs',
          image: const Image(image: AssetImage('assets/images/liked-songs-300.png')),
        );

  @override
  Future<void> loadTracks() async {
    tracks = await GetIt.I<APIUtils>().getLikedSongs();
    tracksLoaded = true;
  }

  @override
  String toString() {
    return "LikedSongsPlaylist<>";
  }

  @override
  bool operator ==(Object other) {
    return other is LikedSongsPlaylist;
  }

  @override
  int get hashCode {
    return likedSongsID.hashCode;
  }
}
