import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shuffler/api_utils.dart';

class Track extends Card {
  final String title;
  final String imgURL;
  final String uri;

  const Track({super.key, required this.title, required this.uri, this.imgURL = ''});

  @override
  Widget build(BuildContext context) {
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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "<Track: $title, $uri, $imgURL>";
  }
}
