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
      return this as Playlist == other as Playlist;
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
