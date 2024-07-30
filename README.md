# Shuffler

An auxiliary app that allows you to freely shuffle your Spotify playlists and add them to your Spotify Queue or into an automatically generated playlist.

> This app does not work on web at the moment.
---

## Getting Started

Spotify API app credentials are read from the enviroment variables `CLIENT_ID` and `CLIENT_SECRET`. When running or building the app make sure to include these variables with your own API keys by using `--dart-define` or `--dart-define-from-file`.

The committed VS Code launch and build configurations use `--dart-define-from-file APICredentials.json` where `APICredentials.json` is located in project root.

Example `APICredentials.json`:

```json
{
    "CLIENT_ID": "YOUR_CLIENT_ID",
    "CLIENT_SECRET": "YOUR_CLIENT_SECRET"
}
```

> Note: Some older versions use a similar json file in assets. Check the `Client.getClient()` method in [`APIUtils.dart`](lib/api_utils.dart) for more details.
---

## Documentation / API reference

You can generate the documentation by running `dart doc .`

You can then view the generated dartdoc by opening `/doc/api/index.html` in a browser or by running:

```bash
dart pub global activate dhttpd
dart pub global run dhttpd --path doc/api
```

before opening `localhost:8080` in a browser.
