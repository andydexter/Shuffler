import 'package:flutter/material.dart';
import 'package:shuffler/data_objects/track.dart';

class ErrorTrack with DefaultTrackWidget implements Track {
  final String error;
  final String spotifyID;
  @override
  Widget get image => const Image(image: AssetImage('assets/images/error-icon.png'));
  @override
  String get title => error;
  @override
  String get uri => spotifyID;

  const ErrorTrack({required this.error, this.spotifyID = ''});

  @override
  Widget getWidget() {
    return getDefaultTrackWidget(this);
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
    return "<ErrorTrack: $error, $uri>";
  }
}
