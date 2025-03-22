import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/data_objects/playlist.dart';

class PlayPlaylistDialog extends StatelessWidget {
  const PlayPlaylistDialog({
    super.key,
    required this.playerActive,
    required this.playlist,
  });

  final bool playerActive;
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tracks added to playlist!'),
      content: playerActive
          ? const Text('Do you want to play the playlist now?')
          : const Text(
              'Make sure you\'re already playing something on spotify before clicking Play',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: playerActive
              ? () async {
                  Navigator.of(context).pop();
                  await GetIt.I<APIUtils>().playPlaylist(playlist.playlistID);
                }
              : null,
          child: const Text('Play'),
        ),
      ],
    );
  }
}


