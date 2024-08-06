// Mocks generated by Mockito 5.4.4 from annotations
// in shuffler/test/Widget%20Tests/theme_changer_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:flutter/material.dart' as _i5;
import 'package:logging/logging.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;
import 'package:oauth2/oauth2.dart' as _i2;
import 'package:shuffler/api_utils.dart' as _i6;
import 'package:shuffler/data_objects/playlist.dart' as _i4;
import 'package:shuffler/data_objects/track.dart' as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeClient_0 extends _i1.SmartFake implements _i2.Client {
  _FakeClient_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLogger_1 extends _i1.SmartFake implements _i3.Logger {
  _FakeLogger_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlaylist_2 extends _i1.SmartFake implements _i4.Playlist {
  _FakePlaylist_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWidget_3 extends _i1.SmartFake implements _i5.Widget {
  _FakeWidget_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info}) => super.toString();
}

/// A class which mocks [APIUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockAPIUtils extends _i1.Mock implements _i6.APIUtils {
  MockAPIUtils() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
      ) as _i2.Client);

  @override
  set userID(String? _userID) => super.noSuchMethod(
        Invocation.setter(
          #userID,
          _userID,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Logger get lg => (super.noSuchMethod(
        Invocation.getter(#lg),
        returnValue: _FakeLogger_1(
          this,
          Invocation.getter(#lg),
        ),
      ) as _i3.Logger);

  @override
  String get genDescription => (super.noSuchMethod(
        Invocation.getter(#genDescription),
        returnValue: _i7.dummyValue<String>(
          this,
          Invocation.getter(#genDescription),
        ),
      ) as String);

  @override
  _i8.Future<_i4.Playlist> getPlaylist(String? spotifyID) => (super.noSuchMethod(
        Invocation.method(
          #getPlaylist,
          [spotifyID],
        ),
        returnValue: _i8.Future<_i4.Playlist>.value(_FakePlaylist_2(
          this,
          Invocation.method(
            #getPlaylist,
            [spotifyID],
          ),
        )),
      ) as _i8.Future<_i4.Playlist>);

  @override
  _i8.Future<List<_i9.Track>> getTracksForPlaylist(_i4.Playlist? playlist) => (super.noSuchMethod(
        Invocation.method(
          #getTracksForPlaylist,
          [playlist],
        ),
        returnValue: _i8.Future<List<_i9.Track>>.value(<_i9.Track>[]),
      ) as _i8.Future<List<_i9.Track>>);

  @override
  _i8.Future<void> addTrackToQueue(_i9.Track? track) => (super.noSuchMethod(
        Invocation.method(
          #addTrackToQueue,
          [track],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  String generatedPlaylistName(String? originalPlaylistName) => (super.noSuchMethod(
        Invocation.method(
          #generatedPlaylistName,
          [originalPlaylistName],
        ),
        returnValue: _i7.dummyValue<String>(
          this,
          Invocation.method(
            #generatedPlaylistName,
            [originalPlaylistName],
          ),
        ),
      ) as String);

  @override
  _i8.Future<_i4.Playlist> generatePlaylistIfNotExists(String? title) => (super.noSuchMethod(
        Invocation.method(
          #generatePlaylistIfNotExists,
          [title],
        ),
        returnValue: _i8.Future<_i4.Playlist>.value(_FakePlaylist_2(
          this,
          Invocation.method(
            #generatePlaylistIfNotExists,
            [title],
          ),
        )),
      ) as _i8.Future<_i4.Playlist>);

  @override
  _i8.Future<_i4.Playlist?> getPlaylistByTitle(String? title) => (super.noSuchMethod(
        Invocation.method(
          #getPlaylistByTitle,
          [title],
        ),
        returnValue: _i8.Future<_i4.Playlist?>.value(),
      ) as _i8.Future<_i4.Playlist?>);

  @override
  _i8.Future<List<_i4.Playlist>> getUserPlaylists() => (super.noSuchMethod(
        Invocation.method(
          #getUserPlaylists,
          [],
        ),
        returnValue: _i8.Future<List<_i4.Playlist>>.value(<_i4.Playlist>[]),
      ) as _i8.Future<List<_i4.Playlist>>);

  @override
  _i8.Future<bool> isGeneratedPlaylist(String? spotifyID) => (super.noSuchMethod(
        Invocation.method(
          #isGeneratedPlaylist,
          [spotifyID],
        ),
        returnValue: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<void> addTracksToGeneratedPlaylist(
    String? spotifyID,
    List<_i9.Track>? tracks,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addTracksToGeneratedPlaylist,
          [
            spotifyID,
            tracks,
          ],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<void> playPlaylist(String? spotifyID) => (super.noSuchMethod(
        Invocation.method(
          #playPlaylist,
          [spotifyID],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);

  @override
  _i8.Future<List<_i9.Track>> getRecentlyPlayedTracks(int? amount) => (super.noSuchMethod(
        Invocation.method(
          #getRecentlyPlayedTracks,
          [amount],
        ),
        returnValue: _i8.Future<List<_i9.Track>>.value(<_i9.Track>[]),
      ) as _i8.Future<List<_i9.Track>>);

  @override
  _i5.Widget getImage(String? url) => (super.noSuchMethod(
        Invocation.method(
          #getImage,
          [url],
        ),
        returnValue: _FakeWidget_3(
          this,
          Invocation.method(
            #getImage,
            [url],
          ),
        ),
      ) as _i5.Widget);

  @override
  _i8.Future<void> waitForPlayerActivated() => (super.noSuchMethod(
        Invocation.method(
          #waitForPlayerActivated,
          [],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}
