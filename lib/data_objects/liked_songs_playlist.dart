import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/playlist.dart';

class LikedSongsPlaylist extends Playlist {
  LikedSongsPlaylist() : super(name: 'Liked Songs', imgUrl: 'assets/images/liked_songs.jpg', spotifyID: 'Liked Songs');

  @override
  Future<void> loadTracks() async {
    tracks = await GetIt.I<APIUtils>().getLikedSongs();
    tracksLoaded = true;
  }
}
