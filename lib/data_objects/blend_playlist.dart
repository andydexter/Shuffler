import 'package:flutter/material.dart';
import 'package:shuffler/data_objects/playlist.dart';

class BlendPlaylist extends Playlist {
  final List<Playlist> playlists;

  BlendPlaylist({required this.playlists})
    : super(
        name: playlists.map((p) => p.name).join(", "),
        image:
            playlists.isNotEmpty
                ? playlists.first.image
                : const Image(image: AssetImage('assets/images/shuffler_icon_90_opacity.png')),
      );

  BlendPlaylist.withImage({required super.image, required this.playlists}) : super(name: playlists.join(", "));

  @override
  Future<void> loadTracks() async {
    // Load all playlists independently
    for (var playlist in playlists) {
      if (!playlist.tracksLoaded) {
        await playlist.loadTracks();
      }
    }
    // Combine tracks from all playlists
    tracks = playlists.expand((playlist) => playlist.tracks).toList();

    tracksLoaded = true;
  }

  @override
  String get playlistID => 'blend_${playlists.map((p) => p.playlistID).join("_")}';
}
