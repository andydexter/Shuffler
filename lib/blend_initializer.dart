import 'package:flutter/material.dart';
import 'package:shuffler/components/playlist_cards.dart';
import 'package:shuffler/data_objects/blend_playlist.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/playlist_view.dart';

class BlendInitializer extends StatefulWidget {
  final List<dynamic> playlists;

  const BlendInitializer({super.key, required this.playlists});

  @override
  State<BlendInitializer> createState() => _BlendInitializerState();
}

class _BlendInitializerState extends State<BlendInitializer> {
  final Set<Playlist> selectedPlaylists = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select 2 or more playlists'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView.builder(
        itemCount: widget.playlists.length,
        itemBuilder: (context, index) {
          final playlist = widget.playlists[index];
          return PlaylistSelectCard(
            playlist: playlist,
            value: selectedPlaylists.contains(playlist),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected ?? false) {
                  selectedPlaylists.add(playlist);
                } else {
                  selectedPlaylists.remove(playlist);
                }
              });
            },
            textColor: Theme.of(context).colorScheme.onSecondary,
            bgColor: Theme.of(context).colorScheme.secondary,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            selectedPlaylists.length < 2
                ? null
                : () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PlaylistView(playlist: BlendPlaylist(playlists: selectedPlaylists.toList())),
                    ),
                  );
                },
        tooltip: selectedPlaylists.length < 2 ? 'Select 2 or more playlists' : 'Done',
        heroTag: '<FAB2>',
        backgroundColor: selectedPlaylists.length < 2 ? Colors.grey : Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Icon(Icons.check_outlined),
      ),
    );
  }
}
