/***

    Copyright (C) 2024  Andreas Nicolaou

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. You can find it at project root.
    If not, see <https://www.gnu.org/licenses/>.

    Author E-mail address: andydexter123@gmail.com

***/
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
