import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/playlist.dart';

class LikedSongsPlaylist extends Playlist {
  static const String likedSongsID = '<Liked Songs Playlist>';
  LikedSongsPlaylist()
      : super(
            name: 'Liked Songs',
            imgUrl: 'https://misc.scdn.co/liked-songs/liked-songs-300.png',
            spotifyID: likedSongsID);

  @override
  Future<void> loadTracks() async {
    tracks = await GetIt.I<APIUtils>().getLikedSongs();
    tracksLoaded = true;
  }
}
