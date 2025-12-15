import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soche_fam_songs/screens/admin/admin_announcement_form_screen.dart';
import '../../models/notification.dart';
import '../../providers/notifications_provider.dart';

class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

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
          title: const Text("Manage Announcements")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AnnouncementFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: context.read<AnnouncementsProvider>().announcementsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(child: Text("No announcements yet."));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final ann = data[i];
              return ListTile(
                title: Text(ann.title),
                subtitle: Text(
                  ann.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(CupertinoIcons.pencil),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AnnouncementFormScreen(announcement: ann),
                      ),
                    );
                  },
                ),
                onLongPress: () {
                  context
                      .read<AnnouncementsProvider>()
                      .removeAnnouncement(ann.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
