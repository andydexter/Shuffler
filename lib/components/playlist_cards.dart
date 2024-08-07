import 'package:flutter/material.dart';
import 'package:shuffler/data_objects/playlist.dart';

abstract class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.playlist, this.bgColor = Colors.white, this.textColor = Colors.black});

  final Playlist playlist;
  final Color bgColor;
  final Color textColor;
}

class PlaylistDisplayCard extends PlaylistCard {
  const PlaylistDisplayCard(
      {super.key,
      required super.playlist,
      required this.onClick,
      required this.onDelete,
      super.bgColor,
      super.textColor});

  final Function() onClick;
  final Function() onDelete;
  @override
  Widget build(BuildContext context) {
    return Card(
        color: bgColor,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListTile(
                onTap: onClick,
                leading: playlist.image,
                title: Text(
                  playlist.name,
                  style: TextStyle(color: textColor),
                  overflow: TextOverflow.fade,
                ),
                trailing: IconButton(
                  key: Key('deletePlaylist<${playlist.playlistID}>'),
                  color: textColor,
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(),
                ))));
  }
}

class PlaylistSelectCard extends PlaylistCard {
  const PlaylistSelectCard(
      {super.key,
      required super.playlist,
      required this.value,
      required this.onChanged,
      super.bgColor,
      super.textColor});

  final bool value;
  final Function(bool? newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: bgColor,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CheckboxListTile(
              value: value,
              onChanged: onChanged,
              secondary: playlist.image,
              title: Text(
                playlist.name,
                style: TextStyle(color: textColor),
                overflow: TextOverflow.fade,
              ),
            )));
  }
}
