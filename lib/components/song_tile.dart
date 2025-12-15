import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongTile({Key? key, required this.song, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        song.title,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      trailing: Icon(CupertinoIcons.arrowtriangle_right_fill,
          size: 16, color: Theme.of(context).primaryColor),
    );
  }
}
