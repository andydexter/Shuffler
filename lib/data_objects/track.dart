///
///     Copyright (C) 2024  Andreas Nicolaou
///
///     This program is free software: you can redistribute it and/or modify
///     it under the terms of the GNU General Public License as published by
///     the Free Software Foundation, either version 3 of the License, or
///     (at your option) any later version.
///
///     This program is distributed in the hope that it will be useful,
///     but WITHOUT ANY WARRANTY; without even the implied warranty of
///     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
///     GNU General Public License for more details.
///
///     You should have received a copy of the GNU General Public License
///     along with this program. You can find it at project root.
///     If not, see <https://www.gnu.org/licenses/>.
///
///     Author E-mail address: andydexter123@gmail.com
///
library;

import 'package:flutter/material.dart';
import 'package:shuffler/data_objects/error_track.dart';
import 'package:shuffler/data_objects/spotify_track.dart';

abstract interface class Track {
  String get title;
  String get uri;
  Widget get image;

  static Track fromJson(Map? item) {
    if (item == null) return const ErrorTrack(error: "Invalid Track");
    if (item['episode'] != null) return const ErrorTrack(error: "Podcasts are not supported yet");
    if (item['track'] != null) return SpotifyTrack.fromJson(item);
    return const ErrorTrack(error: "Unsupported Item");
  }

  Widget getWidget();
}

mixin DefaultTrackWidget implements Track {
  @override
  Widget getWidget() {
    return Card(
      child: ListTile(
        leading: image,
        title: Text(title),
      ),
    );
  }
}
