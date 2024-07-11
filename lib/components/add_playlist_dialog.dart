import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/components/playlist.dart';
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
  late TextEditingController _controller;
  List<Playlist> selectedPlaylists = List.empty(growable: true);
  List<Playlist> userPlaylists = List.empty(growable: true);
  bool loadingPlaylists = true;
  bool loadingDatabase = true;
  APIUtils apiUtils = GetIt.I<APIUtils>();
  AppDatabase appDB = GetIt.I<AppDatabase>();
  final Logger lg = Logger("Shuffler/AddPlaylistDialog");

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _controller = TextEditingController();
    apiUtils.getUserPlaylists().then((playlists) {
      setState(() {
        userPlaylists = playlists;
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
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void submit() async {
    if (_tabController.index == 0) {
      await appDB.addPlaylist(_controller.text);
    } else {
      List<Playlist> currentPlaylists = await appDB.getAllPlaylists();
      //Delete unselected playlists
      for (Playlist toDelete in currentPlaylists.where((playlist) => !selectedPlaylists.contains(playlist))) {
        lg.info("Deleting playlist ${toDelete.name} <${toDelete.spotifyID}>");
        await appDB.deletePlaylist(toDelete.spotifyID);
      }
      //Add selected playlists
      for (Playlist toAdd in selectedPlaylists.where((playlist) => !currentPlaylists.contains(playlist))) {
        lg.info("Adding playlist ${toAdd.name} <${toAdd.spotifyID}>");
        await appDB.addPlaylist(toAdd.spotifyID);
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
                  _AddManually(_controller),
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
                child: TextButton(onPressed: submit, child: const Text("Submit")),
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
  const _AddManually(this._controller);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Manually Add Playlist',
            hintText: 'Enter the playlist URL or ID',
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
      itemBuilder: (context, index) => widget.userPlaylists[index].getSelectCard(
          widget.selectedPlaylists.contains(widget.userPlaylists[index]),
          (v) => (v ?? false)
              ? setState(() => widget.selectedPlaylists.add(widget.userPlaylists[index]))
              : setState(() => widget.selectedPlaylists.remove(widget.userPlaylists[index])),
          textColor: Theme.of(context).colorScheme.onSecondary,
          bgColor: Theme.of(context).colorScheme.secondary),
    );
  }
}
