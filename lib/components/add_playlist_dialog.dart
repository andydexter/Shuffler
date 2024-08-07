import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/playlist_cards.dart';
import 'package:shuffler/data_objects/liked_songs_playlist.dart';
import 'package:shuffler/data_objects/playlist.dart';
import 'package:shuffler/database/entities.dart';

class AddPlaylistDialog extends StatefulWidget {
  const AddPlaylistDialog({
    super.key,
  });

  @override
  State<AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends State<AddPlaylistDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _manualTextController;
  List<Playlist> selectedPlaylists = List.empty(growable: true);
  List<Playlist> userPlaylists = List.empty(growable: true);
  bool loadingPlaylists = true;
  bool loadingDatabase = true;
  APIUtils apiUtils = GetIt.I<APIUtils>();
  AppDatabase appDB = GetIt.I<AppDatabase>();
  final Logger lg = Logger("Shuffler/AddPlaylistDialog");
  String? _manualTextFieldError;
  bool _disableSubmit = false;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _manualTextController = TextEditingController();
    apiUtils.getUserPlaylists().then((playlists) {
      setState(() {
        userPlaylists.add(LikedSongsPlaylist());
        userPlaylists.addAll(playlists);
        loadingPlaylists = false;
      });
    });
    appDB.getAllPlaylists().then((playlists) {
      setState(() {
        selectedPlaylists = playlists;
        loadingDatabase = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _manualTextController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void submit() async {
    if (_tabController.index == 0) {
      //Clear error and disable submit button
      setState(() {
        _manualTextFieldError = null;
        _disableSubmit = true;
      });
      //Re enabling submit button will take effect next time setState is called
      _disableSubmit = false;
      //Validate Text Field
      if (_manualTextController.text.isEmpty) {
        setState(() {
          _manualTextFieldError = 'Please enter a playlist URL/ID';
        });
        return;
      }
      String id = _manualTextController.text.split('/').last.split('?').first;
      //Validate Format
      if (!RegExp(r'^[a-zA-Z0-9]{22}$').hasMatch(id)) {
        setState(() {
          _manualTextFieldError = 'Invalid Playlist URL/ID';
        });
        return;
      }
      //Validate not already added
      if ((await appDB.getAllPlaylistIDs()).contains(id)) {
        setState(() {
          _manualTextFieldError = 'Playlist already added';
        });
        return;
      }
      //Validate playlist exists AND is not shuffler generated
      try {
        if (await apiUtils.isGeneratedPlaylist(id)) {
          setState(() {
            _manualTextFieldError = 'Cannot add Shuffler generated playlists';
          });
          return;
        }
      } catch (e) {
        setState(() {
          _manualTextFieldError = 'Playlist Not Found';
        });
        return;
      }
      //Add playlist
      await appDB.addPlaylistByID(id);
    } else {
      List<Playlist> currentPlaylists = await appDB.getAllPlaylists();
      //Delete unselected playlists
      for (Playlist toDelete in currentPlaylists.where((playlist) => !selectedPlaylists.contains(playlist))) {
        lg.info("Deleting playlist <${toDelete.toString()}>");
        await appDB.deletePlaylistByID(toDelete.playlistID);
      }
      //Add selected playlists
      for (Playlist toAdd in selectedPlaylists.where((playlist) => !currentPlaylists.contains(playlist))) {
        lg.info("Adding playlist <${toAdd.toString()}>");
        await appDB.addPlaylist(toAdd);
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    floating: false,
                    pinned: true,
                    title: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Add Manually'),
                        Tab(text: 'Import from Account'),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _AddManually(_manualTextController, _manualTextFieldError),
                  if (loadingPlaylists || loadingDatabase)
                    const Center(child: CircularProgressIndicator())
                  else
                    _ImportFromAccount(userPlaylists: userPlaylists, selectedPlaylists: selectedPlaylists)
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(onPressed: _disableSubmit ? null : submit, child: const Text("Submit")),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddManually extends StatelessWidget {
  final TextEditingController _controller;
  final String? errorText;
  const _AddManually(this._controller, this.errorText);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Manually Add Playlist',
            hintText: 'Enter the playlist URL or ID',
            errorText: errorText,
          ),
        ),
      ),
    );
  }
}

class _ImportFromAccount extends StatefulWidget {
  final List<Playlist> userPlaylists;
  final List<Playlist> selectedPlaylists;
  const _ImportFromAccount({required this.userPlaylists, required this.selectedPlaylists});

  @override
  State<_ImportFromAccount> createState() => _ImportFromAccountState();
}

class _ImportFromAccountState extends State<_ImportFromAccount> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.userPlaylists.length,
      itemBuilder: (context, index) => PlaylistSelectCard(
          playlist: widget.userPlaylists[index],
          value: widget.selectedPlaylists.contains(widget.userPlaylists[index]),
          onChanged: (v) => (v ?? false)
              ? setState(() => widget.selectedPlaylists.add(widget.userPlaylists[index]))
              : setState(() => widget.selectedPlaylists.remove(widget.userPlaylists[index])),
          textColor: Theme.of(context).colorScheme.onSecondary,
          bgColor: Theme.of(context).colorScheme.secondary),
    );
  }
}
