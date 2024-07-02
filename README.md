# Shuffler

An auxiliary app that allows you to freely shuffle your Spotify playlists and add them to your Spotify Queue.

---

## Getting Started

> This app is not working on web at the moment.

API app credentials are read from `assets/APICredentials.json`. Before running the app make sure to create this file in the following format;

```json
{
    "clientId": "YOUR_CLIENT_ID",
    "clientSecret": "YOUR_CLIENT_SECRET"
}
```

You can then run the app just like any other flutter app

---

## Documentation / API reference

You can generate the documentation by running `dart doc .`

You can then view the generated dartdoc by opening `/doc/api/index.html` in a browser or by running:

```bash
$ dart pub global activate dhttpd
$ dart pub global run dhttpd --path doc/api
```

before opening `localhost:8080` in a browser.