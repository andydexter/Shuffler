import 'dart:async';
import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/track.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class APIUtils {
  final oauth2.Client client = GetIt.instance<oauth2.Client>();
  APIUtils();

  Future<Playlist> getPlaylist(String playlistID) async {
    Map playlist = jsonDecode((await client.get(Uri.parse('https://api.spotify.com/v1/playlists/$playlistID'))).body);

    String imgUrl = playlist['images'][0]['url'];

    return Playlist(
      id: -1,
      name: playlist['name'],
      imgUrl: imgUrl,
      spotifyID: playlist['id'],
    );
  }

  Future<List<Track>> getTracksForPlaylist(Playlist playlist) async {
    List<Track> tracks = List.empty(growable: true);
    String? nextUrl = 'https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks';
    do {
      Map tracklist = jsonDecode((await client.get(Uri.parse(nextUrl!))).body);
      for (var item in tracklist['items']) {
        tracks.add(Track.fromJson(item));
      }
      nextUrl = tracklist['next'];
    } while (nextUrl != null);

    return tracks;
  }

  Future<void> addTrackToQueue(Track track) async {
    var response = await client.post(Uri.parse('https://api.spotify.com/v1/me/player/queue?uri=${track.uri}'));
    if (response.statusCode != 204) {
      return Future.error("Error adding track to queue: ${jsonDecode(response.body)['error']['message']}");
    }
    return Future.value();
  }
}

class APIClient {
  final clientId = 'a2af86983c3a441184ae445309aade2c';
  final clientSecret = '04bd450400f54dadaa64e7a2981c4458';
  final redirectUrl = Uri.parse('http://localhost:3069');
  final authorizationEndpoint = Uri.parse("https://accounts.spotify.com/authorize");
  final tokenEndpoint = Uri.parse("https://accounts.spotify.com/api/token");
  final scope = 'user-modify-playback-state';
  final storage = const FlutterSecureStorage();

  Future<oauth2.Client> getClient() async {
    if (await storage.containsKey(key: 'credentials')) {
      String? credentialsJson = await storage.read(key: 'credentials');
      var credentials = oauth2.Credentials.fromJson(credentialsJson!);
      // print(credentials.toJson());
      var wowClient = oauth2.Client(credentials, identifier: clientId, secret: clientSecret);
      if (wowClient.credentials.isExpired) {
        wowClient = await wowClient.refreshCredentials();
      }
      await storage.write(key: 'credentials', value: wowClient.credentials.toJson());
      try {
        await wowClient.get(Uri.parse('https://api.spotify.com/v1/artists/2uYWxilOVlUdk4oV9DvwqK'));
        return wowClient;
      } catch (e) {
        print(e);
      }
    }
    var grant = oauth2.AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecret,
    );

    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: ['user-modify-playback-state']);

    await launchURL(authorizationUrl);
    Uri reponseUrl = await listenForRedirect();

    var client = await grant.handleAuthorizationResponse(reponseUrl.queryParameters);
    await storage.write(key: 'credentials', value: client.credentials.toJson());
    return client;
  }

  Future<void> launchURL(Uri uri) async {
    GetIt.instance<Logger>().info('Launching URL: $uri');
    try {
      await launchUrl(uri);
    } catch (e) {
      GetIt.instance<Logger>().severe('Error launching URL: $e');
      return Future.error('Error launching URL: $e');
    }
  }

  Future<Uri> listenForRedirect() async {
    var completer = Completer<Uri>();
    HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3069);
    } on SocketException {
      print('Server already running');
      return Future.value(Uri());
    }
    server.listen((HttpRequest request) async {
      // Handle the request
      var redirectUri = request.uri;

      // Complete the completer with the redirect URI
      completer.complete(redirectUri);

      print('Received request for ${request.uri.toString()}');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        //..write('<h1>Received request</h1><p>You can now close this tab</p>')
        ..write('<html><body><script type="text/javascript">window.close();</script></body></html>')
        ..close();

      // Close the server
      await server.close();
    });

    return completer.future;
  }
}
