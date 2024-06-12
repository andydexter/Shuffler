import 'package:flutter/material.dart';

class Track extends Card {
  final String title;
  final String imgURL;
  final String uri;

  const Track({super.key, required this.title, required this.uri, this.imgURL = ''});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          imgURL,
          errorBuilder: (context, error, stackTrace) => const FlutterLogo(),
        ),
        title: Text(title),
      ),
    );
  }

  static Track fromJson(Map item) {
    return Track(
        title: item['track']['name'], uri: item['track']['uri'], imgURL: item['track']['album']['images'][0]['url']);
  }
}
