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
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/playlist.dart';

class SpotifyPlaylist extends Playlist {
  final String imgUrl;
  final String spotifyID;
  @override
  String get playlistID => spotifyID;

  SpotifyPlaylist({required super.name, this.imgUrl = '', required this.spotifyID, super.tracks})
      : super(image: GetIt.I<APIUtils>().getImage(imgUrl));

  @override
  String toString() {
    return "<SpotifyPlaylist: $name, $spotifyID, $imgUrl, $tracks>";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is SpotifyPlaylist) {
      return playlistID == other.playlistID;
    }
    return false;
  }

  @override
  int get hashCode {
    return playlistID.hashCode;
  }

  factory SpotifyPlaylist.fromJson(Map playlist) {
    String imgUrl = ((playlist['images']?.length ?? 0) == 0) ? '' : playlist['images'][0]['url'];
    return SpotifyPlaylist(
      name: playlist['name'],
      imgUrl: imgUrl,
      spotifyID: playlist['id'],
    );
  }

  @override
  Future<void> loadTracks() async {
    tracks = await GetIt.I<APIUtils>().getTracksForPlaylist(this);
    tracksLoaded = true;
  }
}
