import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart';
import '../../providers/notifications_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final Announcement? announcement;

  const AnnouncementFormScreen({super.key, this.announcement});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _messageCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.announcement?.title ?? '');
    _messageCtrl =
        TextEditingController(text: widget.announcement?.message ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcement != null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditing ? "Edit Announcement" : "New Announcement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _messageCtrl,
                decoration: const InputDecoration(labelText: "Message"),
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(isEditing ? "Save Changes" : "Create"),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final announcementsProv =
                      context.read<AnnouncementsProvider>();

                  if (isEditing) {
                    final updated = Announcement(
                      id: widget.announcement!.id,
                      title: _titleCtrl.text,
                      message: _messageCtrl.text,
                      createdAt: widget.announcement!.createdAt,
                    );
                    await announcementsProv.editAnnouncement(updated);
                  } else {
                    final newAnn = Announcement(
                      id: "",
                      title: _titleCtrl.text,
                      message: _messageCtrl.text,
                      createdAt: DateTime.now(),
                    );
                    await announcementsProv.addAnnouncement(newAnn);

                    // 🔔 SEND PUSH NOTIFICATION VIA FCM
                    await _sendPushNotification(
                        title: newAnn.title, body: newAnn.message);
                  }

                  if (context.mounted) Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ------------------ PUSH NOTIFICATION ------------------
  Future<void> _sendPushNotification(
      {required String title, required String body}) async {
    final fcmServerKey = 'YOUR_SERVER_KEY_HERE'; // from Firebase console
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Send notification to topic 'allUsers'
    await FirebaseFirestore.instance.collection('fcmNotifications').add({
      'title': title,
      'body': body,
      'createdAt': DateTime.now(),
    });

    // Optionally, you can also call your server or cloud function here
    // to send notifications to topic 'allUsers' for real-time push.
  }
}
