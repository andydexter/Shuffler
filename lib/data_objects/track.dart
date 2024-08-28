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
    return Track(title: item['name'], uri: item['uri'], imgURL: item['album']?['images']?[0]?['url'] ?? '');
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
