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
