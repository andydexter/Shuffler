[![LinkedIn](https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555)](https://www.linkedin.com/in/andreas-n-nicolaou)

# Shuffler

An auxiliary app built with [Flutter](https://flutter.dev) that allows you to freely shuffle your Spotify playlists.

## About

Shuffler uses the Spotify API with OAuth2 to connect to your account. You can then import your Playlists, and truely shuffle them either directly into your Spotify Queue, or into an automatically generated Playlist which you can play with shuffle off.

Why?
As many have noticed, Spotify's shuffling algorithm isn't truly random. Disabling automix and even downloading all my playlists doesn't seem to have a big impact, as I end up listening to the same 50 songs in a 200 song playlist. To take matters into our own hands, I decided to make my own shuffler, and have full control over the randomness of my music queue.

## Features

### Importing a playlist
You may import a Spotify Playlist in the home page by *one* of *two* methods after accessing the relevant dialog by pressing the `Add Playlist` FAB and then the relevant Tab:

1. Adding manually using the playlist url (Obtained from spotify by clicking Share->URL) or ID (Not URI)

2. Importing playlists saved in Your Library by activating them in the second tab of the dialog (Recommended).

### Shuffling a playlist
Clicking a playlist listed on the home page will navigate you to the playlist view, where all tracks will be loaded and displayed. You may then open the Shuffle Dialog using the `Shuffle Playlist` FAB, presenting you with the following settings:

![image](https://github.com/user-attachments/assets/4099c6d2-df87-4132-83b5-07c053669493)

1. ***Omit Recent Tracks***: You may choose to search up to 50 of your most recent **listening history**, and **omit tracks** also contained in this playlist from the shuffled output. `Found Tracks` shows how many recent tracks are to be omitted.

2. ***Shuffle Into Queue***: If this mode is chosen, the shuffled output will be **added** directly to your Spotify **Queue**. Note that this is a very **slow** procedure as 1 track can be added per request. Note that Spotify must be playing something for this endpoint to work, so just press play on a random track or playlist and the warning should disappear in 2 seconds.

3. ***Shufle Into Playlist***: If this mode is chosen, a new playlist will be **generated**, or if it has been used before, the same playlist will be re-used, and the shuffled output will be added to it. After it has been generated, the option to play it is given. This will start playback on your Spotify, on the first track of the generated playlist, with **shuffle** and **repeat** *off*.

4. ***Number of Tracks***: This is the number of tracks that will be selected from the playlist and form the shuffled output. This number accounts for track omissions.

### Changing the theme
The dropdown menu accessible from the Home Page App Bar contains a `Change Theme` option. The resulting dialog will prompt for a "Color Seed" on which the new theme will use as well as the choice between light and dark mode.

## Getting Started

> This app does not work on web at the moment.

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

If the application starts and freezes on a blank screen, this indicates an error with client authentication, internet access, or potentially database access/initialisation. Run in debug mode and check logs to identify the problem. Don't hesitate to create an issue with the `bug` tag if the problem persists. If you believe that this is a very irresponsible way of handling these "start-up" errors, you are correct and you should create an issue harassing me about it so I'm motivated to fix it. If possible some hints on relevant best practises would be very helpful.

---

## Documentation / API reference

You can generate the documentation by running `dart doc .`

You can then view the generated dartdoc by opening `/doc/api/index.html` in a browser or by running:

```bash
dart pub global activate dhttpd
dart pub global run dhttpd --path doc/api
```

before opening `localhost:8080` in a browser.

## Contributing

Contributions are greatly appreciated! Feel free to share any questions or ideas in the **Discussions** tab, create an **Issue** for any bugs or feature requests, or:
1. Fork the repository.
2. Create a new branch: `git checkout -b feature/your-feature`
3. Make your changes and commit them: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request.

## License

This project is licensed under the GPL-3.0 License. See the [LICENSE](LICENSE) file for more information.
