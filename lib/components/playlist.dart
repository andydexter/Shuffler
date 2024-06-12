import 'package:flutter/material.dart';
import 'package:shuffler/components/track.dart';
import 'dart:math';

class Playlist {
  final String name;
  final int id;
  List<Track> tracks;
  final String imgUrl;
  final String spotifyID;

  Playlist({required this.name, required this.id, required this.spotifyID, this.imgUrl = '', this.tracks = const []});

  Widget getCard(Function() onClick, {Color bgColor = Colors.white, Color textColor = Colors.black}) {
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          onTap: onClick,
          leading: Image.network(
            imgUrl,
            errorBuilder: (context, error, stackTrace) => const FlutterLogo(),
          ),
          title: Text(
            name,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  List<Track> getShuffledTracks() {
    List<Track> shuffledTracks = [...tracks];
    shuffledTracks.shuffle(Random());

    return shuffledTracks;
  }
}
