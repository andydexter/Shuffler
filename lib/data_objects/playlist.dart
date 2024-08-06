import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/track.dart';
import 'dart:math';

class Playlist {
  final String name;
  final int id;
  List<Track> tracks;
  final String imgUrl;
  final String spotifyID;
  bool tracksLoaded = false;

  Playlist({required this.name, required this.id, required this.spotifyID, this.imgUrl = '', this.tracks = const []});

  List<Track> getShuffledTracks() {
    List<Track> shuffledTracks = [...tracks];
    shuffledTracks.shuffle(Random());

    return shuffledTracks;
  }

  @override
  String toString() {
    return "<Playlist: $name, $id, $spotifyID, $imgUrl, $tracks>";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Playlist) {
      return spotifyID == other.spotifyID;
    }
    return false;
  }

  @override
  int get hashCode {
    return name.hashCode ^ spotifyID.hashCode ^ imgUrl.hashCode ^ tracks.hashCode;
  }

  static Playlist fromJson(Map playlist) {
    String imgUrl = ((playlist['images']?.length ?? 0) == 0) ? '' : playlist['images'][0]['url'];
    return Playlist(
      id: -1,
      name: playlist['name'],
      imgUrl: imgUrl,
      spotifyID: playlist['id'],
    );
  }

  Future<void> loadTracks() async {
    tracks = await GetIt.I<APIUtils>().getTracksForPlaylist(this);
    tracksLoaded = true;
  }
}
