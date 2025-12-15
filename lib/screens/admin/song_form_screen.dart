import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../services/firestore_service.dart';

class SongFormScreen extends StatefulWidget {
  final Song? existingSong;

  const SongFormScreen({super.key, this.existingSong});

  @override
  State<SongFormScreen> createState() => _SongFormScreenState();
}

class _SongFormScreenState extends State<SongFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestore = FirestoreService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();

  bool isEditing = false;
  String? songId;

  @override
  void initState() {
    super.initState();

    if (widget.existingSong != null) {
      isEditing = true;
      final s = widget.existingSong!;
      songId = s.id;

      _titleController.text = s.title;
      _lyricsController.text = s.lyrics;
    }
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) return;

    final song = Song(
      id: songId ?? "",
      title: _titleController.text.trim(),
      lyrics: _lyricsController.text.trim(),
      createdAt: widget.existingSong?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      await _firestore.updateSong(songId!, song);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Song updated")),
      );
    } else {
      await _firestore.addSong(song);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Song added")),
      );
    }

    Navigator.pop(context);
  }

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
        title: Text(isEditing ? "Edit Song" : "Add Song"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Song Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lyricsController,
                decoration: const InputDecoration(labelText: "Lyrics"),
                maxLines: 15,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSong,
                child: Text(isEditing ? "Update Song" : "Add Song"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
