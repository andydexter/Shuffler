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
    return other is LikedSongsPlaylist && this as Playlist == other as Playlist;
  }

  @override
  int get hashCode {
    return likedSongsID.hashCode;
  }
}
