import 'package:flutter/material.dart';
import 'package:shuffler/data_objects/track.dart';

class ErrorTrack extends Track {
  final String error;
  final String spotifyID;

  const ErrorTrack({required this.error, this.spotifyID = ''}) : super(title: error, uri: spotifyID);

  @override
  Widget getWidget() {
    return Card(
      child: ListTile(
        leading: const Image(image: AssetImage('assets/images/error-icon.png')),
        title: Text(error),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is ErrorTrack) {
      return uri == other.uri && error == other.error;
    }
    return false;
  }

  @override
  int get hashCode {
    return error.hashCode ^ uri.hashCode;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "<Track: $error, $uri>";
  }
}
