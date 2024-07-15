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

  test('Should retrieve tracks for a playlist with pagination', () async {
    final playlist = Playlist(name: 'Test Playlist', id: 1, spotifyID: 'test_id');
    final tracklistJsonPage1 = HelperMethods.generateTracks(5);
    tracklistJsonPage1['next'] = 'URL to next page of tracks';
    final tracklistJsonPage2 = HelperMethods.generateTracks(4, start: 6);
    final expectedTracks = HelperMethods.generateExpectedTracks(9);

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks')))
        .thenAnswer((_) async => Response(jsonEncode(tracklistJsonPage1), 200));
    when(mockClient.get(Uri.parse('URL to next page of tracks')))
        .thenAnswer((_) async => Response(jsonEncode(tracklistJsonPage2), 200));

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
        .thenAnswer((_) async => Response('', 200));

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

  test('Should find playlist by title', () async {
    final playlistsJson = {
      'items': [
        {'name': 'Test Playlist 1', 'id': 'test_id_1'},
        {'name': 'Test Playlist 2', 'id': 'test_id_2'},
        {'name': 'Test Playlist 3', 'id': 'test_id_3'},
      ],
      'next': 'Next Url',
    };
    final playlists2Json = {
      'items': [
        {'name': 'Test Playlist 4', 'id': 'test_id_4'},
        {'name': 'Test Playlist 5', 'id': 'test_id_5'},
      ],
    };

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/me/playlists')))
        .thenAnswer((_) async => Response(jsonEncode(playlistsJson), 200));
    when(mockClient.get(Uri.parse('Next Url'))).thenAnswer((_) async => Response(jsonEncode(playlists2Json), 200));

    Playlist result = (await apiUtils.getPlaylistByTitle('Test Playlist 4'))!;

    expect(result.spotifyID, equals('test_id_4'));
    expect(result.name, equals('Test Playlist 4'));
  });

  test('Should NOT find playlist by title', () async {
    final playlistsJson = {
      'items': [
        {'name': 'Test Playlist 1', 'id': 'test_id_1'},
        {'name': 'Test Playlist 2', 'id': 'test_id_2'},
        {'name': 'Test Playlist 3', 'id': 'test_id_3'},
      ],
      'next': 'Next Url',
    };
    final playlists2Json = {
      'items': [
        {'name': 'Test Playlist 4', 'id': 'test_id_4'},
        {'name': 'Test Playlist 5', 'id': 'test_id_5'},
      ],
    };

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/me/playlists')))
        .thenAnswer((_) async => Response(jsonEncode(playlistsJson), 200));
    when(mockClient.get(Uri.parse('Next Url'))).thenAnswer((_) async => Response(jsonEncode(playlists2Json), 200));

    Playlist? result = (await apiUtils.getPlaylistByTitle('Test Playlist 69'));

    expect(result, isNull);
  });

  test('Should NOT generate playlist', () async {
    final playlistsJson = {
      'items': [
        {'name': 'Test Playlist 1', 'id': 'test_id_1'},
        {'name': 'Test Playlist 2', 'id': 'test_id_2'},
        {'name': 'Test Playlist 3', 'id': 'test_id_3'},
      ],
      'next': 'Next Url',
    };
    final playlists2Json = {
      'items': [
        {'name': 'Test Playlist 4', 'id': 'test_id_4'},
        {'name': apiUtils.generatedPlaylistName("Test"), 'id': 'test_id_5'},
      ],
    };

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/me/playlists')))
        .thenAnswer((_) async => Response(jsonEncode(playlistsJson), 200));
    when(mockClient.get(Uri.parse('Next Url'))).thenAnswer((_) async => Response(jsonEncode(playlists2Json), 200));

    Playlist result = await apiUtils.generatePlaylistIfNotExists('Test');

    expect(result, equals(Playlist(name: apiUtils.generatedPlaylistName('Test'), id: -1, spotifyID: 'test_id_5')));
  });

  test('Should generate playlist', () async {
    final playlistsJson = {
      'items': [
        {'name': 'Test Playlist 1', 'id': 'test_id_1'},
      ],
    };

    final generatedJson = {
      'name': apiUtils.generatedPlaylistName('Test'),
      'id': 'Test_id',
    };
    final generatedPlaylist = Playlist.fromJson(generatedJson);

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/me/playlists')))
        .thenAnswer((_) async => Response(jsonEncode(playlistsJson), 200));
    when(mockClient.post(Uri.parse('https://api.spotify.com/v1/me/playlists'), body: anyNamed('body')))
        .thenAnswer((invocation) async {
      if (jsonDecode(invocation.namedArguments[const Symbol('body')])['description'] != apiUtils.genDescription ||
          jsonDecode(invocation.namedArguments[const Symbol('body')])['public'] != false) {
        return Response('', 400);
      }
      return Response(
          jsonEncode({
            'name': jsonDecode(invocation.namedArguments[const Symbol('body')])['name'],
            'id': 'Test_id',
          }),
          200);
    });

    Playlist result = await apiUtils.generatePlaylistIfNotExists('Test');

    expect(result, equals(generatedPlaylist));
  });

  test('Should generate playlist name with prefix', () {
    const originalPlaylistName = 'Test Playlist';
    const expectedGeneratedName = '[Shufflered] Test Playlist';

    final result = apiUtils.generatedPlaylistName(originalPlaylistName);
    expect(result, equals(expectedGeneratedName));
  });

  test('Should add tracks to playlist', () async {
    final playlist = Playlist(name: 'Test Playlist', id: 1, spotifyID: 'test_id');
    final tracksOG = HelperMethods.generateExpectedTracks(3);
    final tracksOGJson = HelperMethods.generateTracks(3);
    final trackOGURIs = {
      "tracks": tracksOG.map((e) => {"uri": e.uri}).toList()
    };
    final tracksNew = HelperMethods.generateExpectedTracks(4, start: 5);
    final tracksNewUris = {"uris": tracksNew.map((e) => e.uri).toList()};

    final playlistJson = {'name': 'Test Playlist', 'id': 'test_id', 'description': apiUtils.genDescription};
    //To check generatability
    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}')))
        .thenAnswer((_) async => Response(jsonEncode(playlistJson), 201));
    //To clear tracks
    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks')))
        .thenAnswer((_) async => Response(jsonEncode(tracksOGJson), 200));
    when(mockClient.delete(Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks'),
            body: anyNamed('body')))
        .thenAnswer((_) async => Response('', 200));
    //to add tracks
    when(mockClient.post(Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks'),
            body: anyNamed('body')))
        .thenAnswer((_) async => Response('', 201));

    await apiUtils.addTracksToGeneratedPlaylist(playlist.spotifyID, tracksNew);

    expect(
        jsonDecode(verify(mockClient.delete(
                Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks'),
                body: captureAnyNamed('body')))
            .captured
            .first),
        equals(trackOGURIs));
    expect(
        jsonDecode(verify(mockClient.post(
                Uri.parse('https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks'),
                body: captureAnyNamed('body')))
            .captured
            .first),
        equals(tracksNewUris));
  });

  test('Should play playlist', () async {
    const playlistID = 'test_playlist_id';
    const playBody = '{"context_uri": "spotify:playlist:$playlistID", "offset": {"position": 0}}';
    when(mockClient.put(Uri.parse('https://api.spotify.com/v1/me/player/play'), body: playBody))
        .thenAnswer((_) async => Response('', 200));
    when(mockClient.put(Uri.parse('https://api.spotify.com/v1/me/player/shuffle?state=false')))
        .thenAnswer((_) async => Response('', 200));
    when(mockClient.put(Uri.parse('https://api.spotify.com/v1/me/player/repeat?state=off')))
        .thenAnswer((_) async => Response('', 200));

    await apiUtils.playPlaylist(playlistID);
    verify(mockClient.put(Uri.parse('https://api.spotify.com/v1/me/player/play'), body: playBody)).called(1);
    verify(mockClient.put(Uri.parse('https://api.spotify.com/v1/me/player/shuffle?state=false'))).called(1);
    verify(mockClient.put(Uri.parse('https://api.spotify.com/v1/me/player/repeat?state=off'))).called(1);
    verifyNoMoreInteractions(mockClient);
  });

  test('Should handle error when playing playlist', () async {
    const playlistID = 'test_playlist_id';
    when(mockClient.put(Uri.parse('https://api.spotify.com/v1/me/player/play'), body: anyNamed('body')))
        .thenThrow(const SocketException('No internet connection'));

    expect(apiUtils.playPlaylist(playlistID), throwsA(equals("Couldn't connect to the internet")));
  });

  test('Should get recently played tracks (less than limit)', () async {
    final tracklistJson = HelperMethods.generateTracks(3);
    final expectedTracks = HelperMethods.generateExpectedTracks(3);

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/me/player/recently-played?limit=50')))
        .thenAnswer((_) async => Response(jsonEncode(tracklistJson), 200));

    final result = await apiUtils.getRecentlyPlayedTracks(50);

    expect(result, equals(expectedTracks));
  });

  test('Should get recently played tracks (equal to limit)', () async {
    final tracklistJson = HelperMethods.generateTracks(30);
    final expectedTracks = HelperMethods.generateExpectedTracks(30);

    when(mockClient.get(Uri.parse('https://api.spotify.com/v1/me/player/recently-played?limit=30')))
        .thenAnswer((_) async => Response(jsonEncode(tracklistJson), 200));

    final result = await apiUtils.getRecentlyPlayedTracks(30);

    expect(result, equals(expectedTracks));
  });
}

class HelperMethods {
  static Map generateTracks(int count, {int start = 1}) {
    Map tracklistJson = {'items': [], 'next': null};
    for (int i = start; i < count + start; i++) {
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

  static List<Track> generateExpectedTracks(int count, {int start = 1}) {
    List<Track> expectedTracks = [];
    for (int i = start; i < count + start; i++) {
      expectedTracks.add(Track(
        title: 'Track $i',
        uri: 'track_$i',
        imgURL: 'test_image_url_$i',
      ));
    }
    return expectedTracks;
  }
}
