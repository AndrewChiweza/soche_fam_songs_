import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import '../../providers/songs_provider.dart';
import '../../providers/favorites_provider.dart';

class LyricsScreen extends StatelessWidget {
  final String songId;
  const LyricsScreen({Key? key, required this.songId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final songsProv = Provider.of<SongsProvider>(context);
    final favProv = Provider.of<FavoritesProvider>(context);

    final song = songsProv.findById(songId);

    if (song == null) {
      return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            automaticallyImplyLeading: false,
            elevation: 2,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.chevron_left),
              onPressed: () {
                // This button navigates back to the previous screen
                Navigator.of(context).pop();
              },
            ),
            title: const Text('Lyrics')),
        body: const Center(child: Text('Song not found')),
      );
    }

    final isFav = favProv.isFavorite(song.id);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left),
          onPressed: () {
            // This button navigates back to the previous screen
            Navigator.of(context).pop();
          },
        ),
        title: Text(song.title),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: isFav ? Colors.red : const Color(0xFF0B3D2E),
            ),
            onPressed: () => favProv.toggleFavorite(song.id),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            song.lyrics,
            style: const TextStyle(fontSize: 20, height: 1.6),
          ),
        ),
      ),
    );
  }
}
