import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/track.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

import 'api_utils_test.mocks.dart';

@GenerateMocks([oauth2.Client])
void main() {
  late APIUtils apiUtils;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiUtils = APIUtils(mockClient);
  });

  test('Should retrieve playlist from Spotify API', () async {
    const playlistID = 'test_playlist_id';
    final playlistJson = {
      'id': 'test_playlist_id',
      'name': 'Test Playlist',
      'images': [
        {'url': 'test_image_url'}
      ],
    };
    final expectedPlaylist = Playlist(
      id: -1,
      name: 'Test Playlist',
      imgUrl: 'test_image_url',
      spotifyID: 'test_playlist_id',
    );

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/playlists/$playlistID')))
        .thenAnswer((_) async => Response(jsonEncode(playlistJson), 200));

    final result = await apiUtils.getPlaylist(playlistID);

    expect(result, equals(expectedPlaylist));
  });

  test('Should handle error when retrieving playlist from Spotify API', () async {
    const playlistID = 'test_playlist_id';

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/playlists/$playlistID')))
        .thenThrow(const SocketException('No internet connection'));

    expect(() => apiUtils.getPlaylist(playlistID), throwsA(equals("Couldn't connect to the internet")));
  });

  test('Should retrieve tracks for a playlist', () async {
    final playlist = Playlist(name: 'Test Playlist', id: 1, spotifyID: 'test_id');
    final tracklistJson = HelperMethods.generateTracks(3);
    final expectedTracks = HelperMethods.generateExpectedTracks(3);

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks')))
        .thenAnswer((_) async => Response(jsonEncode(tracklistJson), 200));

    final result = await apiUtils.getTracksForPlaylist(playlist);

    expect(result, equals(expectedTracks));
  });

  test('Should handle error when retrieving tracks for a playlist', () async {
    final playlist = Playlist(name: 'Test Playlist', id: 1, spotifyID: 'test_id');

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks')))
        .thenThrow(const SocketException('No internet connection'));

    expect(apiUtils.getTracksForPlaylist(playlist), throwsA(equals("Couldn't connect to the internet")));
  });

  test('Should add track to user\'s queue', () async {
    const track = Track(title: 'Test Track', uri: 'test_uri');

    when(mockClient.post(Uri.parse('https://api.spotify.com/v1/me/player/queue?uri=${track.uri}')))
        .thenAnswer((_) async => Response('', 204));

    await apiUtils.addTrackToQueue(track);

    verify(mockClient.post(Uri.parse('https://api.spotify.com/v1/me/player/queue?uri=${track.uri}'))).called(1);
  });

  test('Should handle error when adding track to user\'s queue', () async {
    const track = Track(title: 'Test Track', uri: 'test_uri');

    when(mockClient.post(Uri.parse('https://api.spotify.com/v1/me/player/queue?uri=${track.uri}')))
        .thenAnswer((_) async => Response(
            jsonEncode({
              'error': {'message': 'Invalid track'}
            }),
            400));

    expect(apiUtils.addTrackToQueue(track), throwsA(equals('Error adding track to queue: Invalid track')));
  });
}

class HelperMethods {
  static Map generateTracks(int count) {
    Map tracklistJson = {'items': []};
    for (int i = 1; i <= count; i++) {
      tracklistJson['items'].add({
        'track': {
          'name': 'Track $i',
          'uri': 'track_$i',
          'album': {
            'images': [
              {'url': 'test_image_url_$i'}
            ]
          }
        }
      });
    }
    return tracklistJson;
  }

  static List<Track> generateExpectedTracks(int count) {
    List<Track> expectedTracks = [];
    for (int i = 1; i <= count; i++) {
      expectedTracks.add(Track(
        title: 'Track $i',
        uri: 'track_$i',
        imgURL: 'test_image_url_$i',
      ));
    }
    return expectedTracks;
  }
}
