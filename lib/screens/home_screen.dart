import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:soche_fam_songs/providers/favorites_provider.dart';
import 'package:soche_fam_songs/providers/notifications_provider.dart';

import 'package:soche_fam_songs/providers/songs_provider.dart';

import 'package:soche_fam_songs/screens/admin/admin_sign_in_screen.dart';
import 'package:soche_fam_songs/screens/registration_form_screen.dart';
import '../screens/lyrics_screen.dart';
import '../screens/notifications_screen.dart';
import '../components/song_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _q = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final songsProv = context.read<SongsProvider>();
      final favProv = context.read<FavoritesProvider>();
      final notProv = context.read<AnnouncementsProvider>();

      await songsProv.loadSongs();
      favProv.syncFavoritesWithSongs(songsProv.songs);
      await notProv.loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final songsProv = context.watch<SongsProvider>();
    final songs = _q.isEmpty ? songsProv.songs : songsProv.search(_q);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🔰 SLIVER APP BAR
          SliverAppBar(
            scrolledUnderElevation: 0.0,
            pinned: true,
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
              title: GestureDetector(
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSignInScreen(),
                    ),
                  );
                },
                child: const Text(
                  "SOCHE FAM",
                  style: TextStyle(
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              /// 🔍 SEARCH
              IconButton(
                icon: const Icon(CupertinoIcons.search),
                onPressed: () async {
                  final res = await showSearch(
                    context: context,
                    delegate: _SongSearchDelegate(songsProv),
                  );
                  if (res != null) setState(() => _q = res);
                },
              ),

              /// 🔔 NOTIFICATIONS
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.bell),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Consumer<AnnouncementsProvider>(
                      builder: (_, notProv, __) {
                        final count = notProv.items.length;
                        if (count == 0) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              /// ⋮ MENU
              PopupMenuButton<String>(
                color: Theme.of(context).cardColor,
                icon: const Icon(CupertinoIcons.ellipsis_vertical),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'register') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MemberRegistrationScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'register',
                    child: Row(
                      children: [
                        Icon(Icons.person_add_outlined),
                        SizedBox(width: 8),
                        Text("Register"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
            ],
          ),

          /// 📜 SONG LIST
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            sliver:
                // songs.isEmpty
                //     ? SliverFillRemaining(
                //         child: Center(
                //           child: Text(
                //             '🎵\nNo Songs Found!',
                //             textAlign: TextAlign.center,
                //             style: Theme.of(context).textTheme.titleMedium,
                //           ),
                //         ),
                //       )
                SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final song = songs[i];

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SongTile(
                      song: song,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LyricsScreen(songId: song.id),
                        ),
                      ),
                    ),
                  );
                },
                childCount: songs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- SEARCH DELEGATE ----------------

class _SongSearchDelegate extends SearchDelegate<String> {
  final SongsProvider provider;
  _SongSearchDelegate(this.provider);

  @override
  String? get searchFieldLabel => "Type song title or number...";

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontSize: 16,
      );

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(CupertinoIcons.chevron_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(CupertinoIcons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = provider.search(query);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.music_note),
        title: Text(results[i].title),
        onTap: () => close(context, query),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = provider.search(query);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.music_note_outlined),
        title: Text(suggestions[i].title),
        onTap: () {
          query = suggestions[i].title;
          showResults(context);
        },
      ),
    );
  }
}
