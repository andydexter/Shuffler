import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/track.dart';
import 'dart:math';

class Playlist {
  final String name;
  final int id;
  List<Track> tracks;
  final String imgUrl;
  final String spotifyID;

  Playlist({required this.name, required this.id, required this.spotifyID, this.imgUrl = '', this.tracks = const []});

  Widget getCard(Function() onClick, Function() onDelete,
      {Color bgColor = Colors.white, Color textColor = Colors.black}) {
    return Card(
        color: bgColor,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListTile(
                onTap: onClick,
                leading: GetIt.I<APIUtils>().getImage(imgUrl),
                title: Text(
                  name,
                  style: TextStyle(color: textColor),
                ),
                trailing: IconButton(
                  key: Key('deletePlaylist<$spotifyID>'),
                  color: textColor,
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(),
                ))));
  }

  List<Track> getShuffledTracks() {
    List<Track> shuffledTracks = [...tracks];
    shuffledTracks.shuffle(Random());

    return shuffledTracks;
  }

  @override
  String toString() {
    return "<Playlist: $name, $id, $spotifyID, $imgUrl, $tracks>";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Playlist) {
      return spotifyID == other.spotifyID;
    }
    return false;
  }

  @override
  int get hashCode {
    return name.hashCode ^ spotifyID.hashCode ^ imgUrl.hashCode ^ tracks.hashCode;
  }

  static Playlist fromJson(Map playlist) {
    return Playlist(
      id: -1,
      name: playlist['name'],
      imgUrl: playlist['images'][0]['url'],
      spotifyID: playlist['id'],
    );
  }
}
