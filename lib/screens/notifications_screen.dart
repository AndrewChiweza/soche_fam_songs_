import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soche_fam_songs/providers/push_notify_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final announcementsProv = Provider.of<AnnouncementsProvider>(context);
    final pushProv = Provider.of<PushNotificationProvider>(context);

    // Merge Firestore announcements and FCM messages
    final List<Map<String, dynamic>> allNotifications = [
      ...announcementsProv.items.map((a) => {
            'title': a.title,
            'message': a.message,
            'createdAt': a.createdAt,
          }),
      ...pushProv.messages.map((m) => {
            'title': m.notification?.title ?? '',
            'message': m.notification?.body ?? '',
            'createdAt': DateTime.now(),
          }),
    ];

    allNotifications.sort(
        (a, b) => b['createdAt'].compareTo(a['createdAt'])); // newest first

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24)),
        ),
        title: Row(
          children: [
            const Text('Reminders'),
            const SizedBox(width: 8),
            if (allNotifications.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  allNotifications.length.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          if (allNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Clear All Notifications"),
                    content: const Text(
                        "Are you sure you want to delete all notifications?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            announcementsProv.clearAll();
                            pushProv.messages.clear();
                            pushProv.notifyListeners();
                            Navigator.pop(context);
                          },
                          child: const Text("Clear",
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: allNotifications.isEmpty
          ? const Center(
              child: Text(
                "📢\n Notifications will Appear here!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            )
          : ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allNotifications.length,
                itemBuilder: (_, i) {
                  final n = allNotifications[i];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n['message'],
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${n['createdAt'].year}-${n['createdAt'].month.toString().padLeft(2, '0')}-${n['createdAt'].day.toString().padLeft(2, '0')} '
                            '• '
                            '${n['createdAt'].hour.toString().padLeft(2, '0')}:${n['createdAt'].minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
