import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:html_unescape/html_unescape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shuffler/components/playlist.dart';
import 'package:shuffler/components/track.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The [APIUtils] class provides utility methods for interacting with the Spotify API.
/// It includes methods for retrieving playlists, retrieving tracks for a playlist, and adding a track to the user's queue.
/// When instantiating an [APIUtils] object, there must be a valid [oauth2.Client] client available on [GetIt].

class APIUtils {
  final oauth2.Client client;
  final Logger lg = Logger("Shuffler/APIUtils");

  APIUtils(this.client);

  /// Retrieves a playlist from Spotify API based on the provided playlist ID.
  ///
  /// Returns a [Future] that completes with a [Playlist] object representing the retrieved playlist, with an `id` of -1.
  /// Throws a (Future) error if there is a problem connecting to the internet.
  Future<Playlist> getPlaylist(String playlistID) async {
    Map playlist;
    try {
      playlist = jsonDecode((await client.get(Uri.parse('https://api.spotify.com/v1/playlists/$playlistID'))).body);
    } on SocketException catch (_, e) {
      lg.severe(e.toString());
      return Future.error("Couldn't connect to the internet");
    }

    String imgUrl = playlist['images'][0]['url'];

    return Playlist(
      id: -1,
      name: playlist['name'],
      imgUrl: imgUrl,
      spotifyID: playlist['id'],
    );
  }

  /// Retrieves a list of tracks for a given playlist.
  ///
  /// The [playlist] parameter specifies the playlist from which to retrieve the tracks.
  /// Returns a [Future] that completes with a list of [Track] objects.
  /// Throws an error if there is a problem connecting to the internet.
  Future<List<Track>> getTracksForPlaylist(Playlist playlist) async {
    List<Track> tracks = List.empty(growable: true);
    String? nextUrl = 'https://api.spotify.com/v1/playlists/${playlist.spotifyID}/tracks';
    do {
      Map tracklist;
      try {
        tracklist = jsonDecode((await client.get(Uri.parse(nextUrl!))).body);
      } on SocketException catch (_, e) {
        lg.severe(e.toString());
        return Future.error("Couldn't connect to the internet");
      }
      for (var item in tracklist['items']) {
        tracks.add(Track.fromJson(item));
      }
      nextUrl = tracklist['next'];
    } while (nextUrl != null);

    return tracks;
  }

  /// Adds a track to the user's Spotify queue.
  ///
  /// The [track] parameter represents the track to be added to the queue.
  /// This method sends a POST request to the Spotify API to add the track to the queue.
  /// If the request is successful (status code 204), the method returns a completed Future.
  /// If there is an error, the method returns a Future with an error message.
  Future<void> addTrackToQueue(Track track) async {
    Response response;
    try {
      response = await client.post(Uri.parse('https://api.spotify.com/v1/me/player/queue?uri=${track.uri}'));
    } on SocketException catch (_, e) {
      lg.severe(e.toString());
      return Future.error("Couldn't connect to the internet");
    }
    if (response.statusCode != 204) {
      return Future.error("Error adding track to queue: ${jsonDecode(response.body)['error']['message']}");
    }
    return Future.value();
  }

  String generatedPlaylistName(String originalPlaylistName) => '[Shufflered] $originalPlaylistName';

  Future<Playlist> generatePlaylist(String title) async {
    Map response;
    String playlist = '{"name": "$title","description": "$genDescription", "public": false}';
    try {
      Response raw = await client.post(Uri.parse('https://api.spotify.com/v1/me/playlists'), body: playlist);
      response = jsonDecode(raw.body);
    } on SocketException catch (_, e) {
      lg.severe(e.toString());
      return Future.error("Couldn't connect to the internet");
    } catch (e) {
      lg.severe(e.toString());
      return Future.error("Error generating playlist: $e");
    }
    lg.info("Generated Playlist $title with ID <${response['id']}>");
    return Playlist.fromJson(response);
  }

  Future<Playlist> generatePlaylistIfNotExists(String title) async {
    title = generatedPlaylistName(title);
    return (await getPlaylistByTitle(title)) ?? (await generatePlaylist(title));
  }

  Future<Playlist?> getPlaylistByTitle(String title) async {
    Map response;
    String? nextUrl = 'https://api.spotify.com/v1/me/playlists';
    do {
      try {
        response = jsonDecode((await client.get(Uri.parse(nextUrl!))).body);
      } on SocketException catch (_, e) {
        lg.severe(e.toString());
        return Future.error("Couldn't connect to the internet");
      }
      if (response['items'].any((item) => item['name'] == title)) {
        Playlist found = Playlist.fromJson(response['items'].where((item) => item['name'] == title).first);
        lg.info("Playlist $title found with ID <${found.spotifyID}>");
        return found;
      }
      nextUrl = response['next'];
    } while (nextUrl != null);
    lg.info("Playlist $title not found");
    return null;
  }

  Future<bool> isGeneratedPlaylist(String spotifyID) async {
    Map playlist;
    try {
      playlist = jsonDecode((await client.get(Uri.parse('https://api.spotify.com/v1/playlists/$spotifyID'))).body);
    } on SocketException catch (_, e) {
      lg.severe(e.toString());
      return Future.error("Couldn't connect to the internet");
    }
    String description = HtmlUnescape().convert(playlist['description']);
    if (description != genDescription && (playlist['name'] as String).startsWith("[Shufflered]")) {
      lg.warning(
          "Tried to access <${playlist['name']}> with spotify ID <${playlist['id']}> and description <$description> which has not been shuffler generated");
      return false;
    }
    return true;
  }

  Future<void> clearPlaylist(String spotifyID) async {
    if (!await isGeneratedPlaylist(spotifyID)) return Future.error("Playlist is not a Shuffler-generated playlist");
    List<Track> tracks = await getTracksForPlaylist(await getPlaylist(spotifyID));
    List<String> uris = tracks.map((e) => e.uri).toList();
    for (int i = 0; i < uris.length; i += 100) {
      try {
        String body =
            '{"tracks": [${uris.sublist(i, min(i + 100, uris.length)).map((e) => '{"uri": "$e"}').join(",")}]}';
        //lg.info("Using body $body");
        Response response =
            await client.delete(Uri.parse('https://api.spotify.com/v1/playlists/$spotifyID/tracks'), body: body);
        if (response.statusCode != 200) {
          lg.severe("Error clearing playlist: ${jsonDecode(response.body)['error']['message']}");
          return Future.error("Error clearing playlist: ${jsonDecode(response.body)['error']['message']}");
        }
      } on SocketException catch (_, e) {
        lg.severe(e.toString());
        return Future.error("Couldn't connect to the internet");
      }
    }
    lg.info("Cleared playlist with ID $spotifyID");
  }

  Future<void> addTracksToGeneratedPlaylist(String spotifyID, List<Track> tracks) async {
    if (!await isGeneratedPlaylist(spotifyID)) return Future.error("Playlist is not a Shuffler-generated playlist");
    await clearPlaylist(spotifyID);
    lg.info("Adding ${tracks.length} tracks to playlist with ID $spotifyID");
    for (int i = 0; i < tracks.length; i += 100) {
      try {
        String body =
            '{"uris": [${tracks.sublist(i, min(i + 100, tracks.length)).map((e) => '"${e.uri}"').join(",")}]}';
        Response response =
            await client.post(Uri.parse('https://api.spotify.com/v1/playlists/$spotifyID/tracks'), body: body);
        if (response.statusCode != 201) {
          return Future.error("Error adding tracks to playlist: ${jsonDecode(response.body)['error']['message']}");
        }
      } on SocketException catch (_, e) {
        lg.severe(e.toString());
        return Future.error("Couldn't connect to the internet");
      } catch (e) {
        lg.severe(e.toString());
        return Future.error("Error adding tracks to playlist: $e");
      }
    }
    lg.info("Added ${tracks.length} tracks to playlist with ID $spotifyID");
  }

  Future<void> playPlaylist(String spotifyID) async {
    try {
      await client.put(Uri.parse('https://api.spotify.com/v1/me/player/play'),
          body: '{"context_uri": "spotify:playlist:$spotifyID", "offset": {"position": 0}}');
      await client.put(Uri.parse('https://api.spotify.com/v1/me/player/shuffle?state=false'));
    } on SocketException catch (_, e) {
      lg.severe(e.toString());
      return Future.error("Couldn't connect to the internet");
    } catch (e) {
      lg.severe(e.toString());
      return Future.error("Error playing playlist: $e");
    }
  }

  Widget getImage(String url) {
    if (url == '') return const FlutterLogo();
    return Image.network(
      url,
      errorBuilder: (context, error, stackTrace) => const FlutterLogo(),
    );
  }
}

/// The [APIClient] class is responsible for handling the authentication process with the Spotify API.
/// It includes methods for obtaining an OAuth2 client, launching the authorization URL, and listening for the redirect URL.
/// Use the `getClient` method to obtain an authenticated OAuth2 client.
///
/// This class makes use of the [oauth2] package for handling OAuth2 authentication,
/// the [flutter_secure_storage] package for storing and retrieving credentials securely,
/// and the [url_launcher] package for launching URLs.
///
/// Note: This Class assumes the presence of an `APICredentials.json` file in the `assets` directory,
/// which contains the client ID and client secret for the Spotify API.
/// The [APIClient] class uses this file to obtain the necessary credentials for authentication.
///
class APIClient {
  final redirectUrl = Uri.parse('http://localhost:3069');
  final authorizationEndpoint = Uri.parse("https://accounts.spotify.com/authorize");
  final tokenEndpoint = Uri.parse("https://accounts.spotify.com/api/token");
  final scope = 'user-modify-playback-state';
  final storage = const FlutterSecureStorage();
  Logger lg = Logger("Shuffler/APIClient");

  /// Retrieves an [oauth2.Client] client for making API requests.
  ///
  /// This method uses the [flutter_secure_storage] package to store and retrieve the user's credentials securely, and
  /// the [rootBundle] class to load the API credentials from the `APICredentials.json` file.
  /// It also uses the [launchURL] and [listenForRedirect] methods to handle the OAuth2 authorization process.
  ///
  /// This method loads the API credentials from the `APICredentials.json` file
  /// located in the assets directory. It then uses the credentials to authenticate
  /// and obtain an OAuth2 client. If a refresh token is already stored, it checks
  /// if the credentials are expired and refreshes them if necessary.
  ///
  /// **MAKE SURE THE `APICredentials.json` FILE IS PRESENT IN THE `assets` DIRECTORY WITH THE CORRECT CREDENTIALS.**
  ///
  /// If the credentials are successfully obtained and authenticated, the method
  /// returns the OAuth2 client. Otherwise, it logs an error and returns a Future
  /// with the error.
  ///
  /// **MAKE SURE YOU HAVE `http://localhost:3069` AS A REDIRECT URI IN YOUR SPOTIFY APP SETTINGS.**
  ///
  /// Throws  if the `APICredentials.json` file is missing.
  /// Asserts that it contains the required `clientId` and `clientSecret` fields.

  Future<oauth2.Client> getClient({bool allowRefresh = true}) async {
    //Get API credentials from assets
    String credentialsJson;
    try {
      credentialsJson = await rootBundle.loadString('assets/APICredentials.json');
    } catch (e) {
      lg.severe('Error loading credentials from assets. Make sure assets/APICredentials.json exists: $e');
      return Future.error(e);
    }
    lg.info('Successfully loaded credentials from assets');
    final credentials = jsonDecode(credentialsJson);
    assert(credentials.containsKey('clientId') && credentials.containsKey('clientSecret'),
        'APICredentials.json must contain clientId and clientSecret fields');
    final clientId = credentials['clientId'];
    final clientSecret = credentials['clientSecret'];

    //Check if refresh token is stored
    if (allowRefresh && await storage.containsKey(key: 'credentials')) {
      lg.info('Found stored refresh token');
      String? credentialsJson = await storage.read(key: 'credentials');
      var credentials = oauth2.Credentials.fromJson(credentialsJson!);
      var wowClient = oauth2.Client(credentials, identifier: clientId, secret: clientSecret);

      //Refresh credentials if expired
      if (wowClient.credentials.isExpired) {
        lg.info('Refreshing credentials');
        wowClient = await wowClient.refreshCredentials();
      }
      await storage.write(key: 'credentials', value: wowClient.credentials.toJson());

      //Check if client is valid
      try {
        await wowClient.get(Uri.parse('https://api.spotify.com/v1/artists/2uYWxilOVlUdk4oV9DvwqK'));
        lg.info('Successfully authenticated with client');
        return wowClient;
      } catch (e) {
        lg.severe('Error with client: $e');
      }
    }

    //Get Authorization URL
    var grant = oauth2.AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecret,
    );

    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes: ['user-modify-playback-state']);

    //Launch URL and listen for redirect after user's authorization
    await launchURL(authorizationUrl);
    Uri reponseUrl = await listenForRedirect();
    lg.info("Received response URL: $reponseUrl");

    //Handle authorization response and finalize client
    var client = await grant.handleAuthorizationResponse(reponseUrl.queryParameters);
    await storage.write(key: 'credentials', value: client.credentials.toJson());
    return client;
  }

  /// Launches the specified [uri] by calling the [launchUrl] function.
  ///
  /// This function logs the URL being launched and catches any errors that occur during the launch process.
  /// If an error occurs, it logs the error and returns a [Future] that completes with an error message.

  Future<void> launchURL(Uri uri) async {
    lg.info('Launching URL: $uri');
    try {
      await launchUrl(uri);
    } catch (e) {
      lg.severe('Error launching URL: $e');
      return Future.error('Error launching URL: $e');
    }
  }

  /// Listens for a redirect request and returns the redirect URI.
  ///
  /// This method starts an HTTP server on the loopback IPv4 address and the specified port.
  /// It listens for incoming HTTP requests and completes a [Completer] with the redirect URI
  /// when a request is received. The server responds to the request with an HTML page containing
  /// a JavaScript code that closes the window.
  ///
  /// If the server is already running ([SocketException]), it returns an empty [Uri].
  /// If any other error occurs while starting the server, it throws an error.
  ///
  /// After completing the [Completer] and responding to the request, the server is closed.
  ///
  /// Returns a [Future] that completes with the redirect [Uri].
  Future<Uri> listenForRedirect() async {
    var completer = Completer<Uri>();
    HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3069);
      lg.info('Server started on ${server.address}:${server.port}');
    } on SocketException {
      lg.info('Server already running');
      return Future.value(Uri());
    } catch (e) {
      lg.severe('Error starting server: $e');
      return Future.error('Error starting server: $e');
    }
    server.listen((HttpRequest request) async {
      // Handle the request
      var redirectUri = request.uri;

      // Complete the completer with the redirect URI
      completer.complete(redirectUri);

      lg.info('Received request for ${request.uri.toString()}');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write('<html><body><script type="text/javascript">window.close();</script></body></html>')
        ..close();

      // Close the server
      await server.close();
    });

    return completer.future;
  }

  /// Resets the authentication by deleting the stored credentials.
  void resetAuthentication() {
    storage.delete(key: 'credentials');
  }
}
