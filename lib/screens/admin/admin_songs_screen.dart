import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../services/firestore_service.dart';
import 'song_form_screen.dart';

class AdminSongsScreen extends StatelessWidget {
  final FirestoreService _firestore = FirestoreService();

  AdminSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_left),
            onPressed: () {
              // This button navigates back to the previous screen
              Navigator.of(context).pop();
            },
            // Optional: customize the color
          ),
          title: const Text("Manage Songs")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(CupertinoIcons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SongFormScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<Song>>(
        stream: _firestore.getSongs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data!;

          if (songs.isEmpty) {
            return const Center(child: Text("No songs added yet"));
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(
                  song.lyrics.length > 40
                      ? song.lyrics.substring(0, 40) + "..."
                      : song.lyrics,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon:
                          const Icon(CupertinoIcons.pencil, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SongFormScreen(existingSong: song),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(CupertinoIcons.delete, color: Colors.red),
                      onPressed: () async {
                        await _firestore.deleteSong(song.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
