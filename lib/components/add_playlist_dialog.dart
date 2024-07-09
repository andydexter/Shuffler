import 'package:flutter/material.dart';

class AddPlaylistDialog extends StatefulWidget {
  const AddPlaylistDialog({
    super.key,
    required this.idList,
  });

  final List<String> idList;

  @override
  State<AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends State<AddPlaylistDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _controller;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void submit() {
    if (_tabController.index == 0) {
      widget.idList.add(_controller.text.split('/').last.split('?').first);
    } else {
      print('Imported playlist from account');
    }
    Navigator.of(context).pop();
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
                children: [_AddManually(_controller), _ImportFromAccount()],
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
  const _AddManually(this._controller, {super.key});

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

class _ImportFromAccount extends StatelessWidget {
  const _ImportFromAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Import from Account'));
  }
}
