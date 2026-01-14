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
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final top = constraints.biggest.height;
                // How collapsed the app bar is (0 = fully collapsed, 1 = fully expanded)
                final collapseFactor =
                    ((top - kToolbarHeight) / (140 - kToolbarHeight))
                        .clamp(0.0, 1.0);

                return Stack(
                  children: [
                    FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                      title: const Text(
                        "Favorites",
                        style: TextStyle(letterSpacing: 1.2),
                      ),
                      centerTitle: false,
                    ),
                    // 🔹 Line under title with space and fade-out on collapse
                    Positioned(
                      left: 16,
                      bottom: 12, // space between title and line
                      child: Opacity(
                        opacity: collapseFactor, // fades out as we scroll
                        child: Container(
                          width: 80, // width under the text
                          height: 2,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ],
                );
              },
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

          // If no favorites
          if (favSongs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Favorite Songs will appear here!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            // Favorite Songs List
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final song = favSongs[i];
                    song.isFavorite = favProv.isFavorite(song.id);

                    return Column(
                      children: [
                        if (i != 0)
                          const Divider(
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LyricsScreen(songId: song.id),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    song.title,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
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
                        ),
                        if (i != favSongs.length - 1)
                          const Divider(
                            height: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                      ],
                    );
                  },
                  childCount: favSongs.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
