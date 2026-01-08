import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/songs_provider.dart';
import '../screens/lyrics_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final songsProv = Provider.of<SongsProvider>(context);
    final favProv = Provider.of<FavoritesProvider>(context);
    final favSongs = songsProv.favoriteSongs(favProv.ids);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            scrolledUnderElevation: 0.0,
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 140,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: const Text(
                'Favorites',
              ),
              centerTitle: false,
            ),
            actions: [
              if (favSongs.isNotEmpty)
                IconButton(
                  icon: const Icon(CupertinoIcons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Clear Favorites"),
                        content: const Text(
                            "Are you sure you want to remove all favorites?"),
                        backgroundColor: Theme.of(context).cardColor,
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text("Clear",
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              for (var s in favSongs) {
                                favProv.toggleFavorite(s.id);
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          favSongs.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Favorite Songs will appear here!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = favSongs[index];
                      song.isFavorite = favProv.isFavorite(song.id);

                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LyricsScreen(songId: song.id),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  song.title,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  song.isFavorite
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    favProv.toggleFavorite(song.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: favSongs.length,
                  ),
                ),
        ],
      ),
    );
  }
}
