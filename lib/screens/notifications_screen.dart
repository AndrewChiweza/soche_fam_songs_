import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soche_fam_songs/providers/push_notify_provider.dart';
import 'package:soche_fam_songs/screens/notification_details.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  String formatDate(DateTime date) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    const days = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];

    return "${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final announcementsProv = Provider.of<AnnouncementsProvider>(context);
    final pushProv = Provider.of<PushNotificationProvider>(context);

    final List<Map<String, dynamic>> allNotifications = [
      ...announcementsProv.items.map((a) => {
            'id': a.id,
            'title': a.title,
            'message': a.message,
            'createdAt': a.createdAt,
            'type': 'announcement',
          }),
      ...pushProv.messages.map((m) => {
            'id': m.hashCode.toString(),
            'title': m.notification?.title ?? '',
            'message': m.notification?.body ?? '',
            'createdAt': DateTime.now(),
            'type': 'push',
          }),
    ];

    allNotifications.sort(
      (a, b) => b['createdAt'].compareTo(a['createdAt']),
    );

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text("Notifications"),
            const SizedBox(width: 8),
            if (allNotifications.isNotEmpty)
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.green,
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
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          announcementsProv.clearAll();
                          pushProv.messages.clear();
                          pushProv.notifyListeners();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                "All notifications cleared successfully",
                                style: TextStyle(color: Colors.white),
                              ),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          "Clear",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: allNotifications.isEmpty
          ? const Center(
              child: Text(
                "📢\nNotifications will appear here",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allNotifications.length,
              itemBuilder: (_, i) {
                final n = allNotifications[i];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailsScreen(
                          notification: n,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['title'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n['message'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatDate(n['createdAt']),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
