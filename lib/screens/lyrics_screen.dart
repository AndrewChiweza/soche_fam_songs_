import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import '../../providers/songs_provider.dart';
import '../../providers/favorites_provider.dart';

class LyricsScreen extends StatefulWidget {
  final String songId;
  const LyricsScreen({Key? key, required this.songId}) : super(key: key);

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final songsProv = Provider.of<SongsProvider>(context, listen: false);
    _currentIndex =
        songsProv.songs.indexWhere((song) => song.id == widget.songId);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songsProv = Provider.of<SongsProvider>(context);
    final favProv = Provider.of<FavoritesProvider>(context);

    final songs = songsProv.songs;

    if (_currentIndex < 0 || _currentIndex >= songs.length) {
      return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_left),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Lyrics'),
        ),
        body: const Center(child: Text('Song not found')),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // smooth bounce
        itemCount: songs.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final song = songs[index];
          final isFav = favProv.isFavorite(song.id);

          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(CupertinoIcons.chevron_left),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(song.title),
              actions: [
                IconButton(
                  icon: Icon(
                    isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    color: isFav
                        ? Colors.red
                        : Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: () => favProv.toggleFavorite(song.id),
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              elevation: 2,
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
        },
      ),
    );
  }
}
