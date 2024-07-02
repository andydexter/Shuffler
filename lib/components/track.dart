import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';

class Track {
  final String title;
  final String imgURL;
  final String uri;

  const Track({required this.title, required this.uri, this.imgURL = ''});

  Widget getWidget() {
    return Card(
      child: ListTile(
        leading: GetIt.I<APIUtils>().getImage(imgURL),
        title: Text(title),
      ),
    );
  }

  static Track fromJson(Map item) {
    return Track(
        title: item['track']['name'], uri: item['track']['uri'], imgURL: item['track']['album']['images'][0]['url']);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Track) {
      return uri == other.uri && title == other.title && imgURL == other.imgURL;
    }
    return false;
  }

  @override
  int get hashCode {
    return title.hashCode ^ uri.hashCode ^ imgURL.hashCode;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "<Track: $title, $uri, $imgURL>";
  }
}
