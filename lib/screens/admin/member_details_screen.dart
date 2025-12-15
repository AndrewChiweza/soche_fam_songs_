import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soche_fam_songs/models/member.dart';
import 'package:soche_fam_songs/services/firestore_service.dart';
import 'package:soche_fam_songs/screens/registration_form_screen.dart';

class MemberDetailsScreen extends StatelessWidget {
  final Member member;

  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

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
        title: Text(member.name),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemberRegistrationScreen(
                    existingMember: member,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.delete),
            onPressed: () {
              _confirmDelete(context, firestore);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Icon(CupertinoIcons.person, size: 50),
                ),
              ),
              const SizedBox(height: 25),
              _infoTile("Name", member.name),
              _infoTile("Email", member.email),
              _infoTile("Baptised", member.baptised ? "Yes" : "No"),
              _infoTile("Local Church", member.localChurch),
              _infoTile("Purpose", member.purpose),
              _infoTile("Voice Type", member.voiceType),
              _infoTile(
                "Joined",
                "${member.joinedAt.year}-${member.joinedAt.month}-${member.joinedAt.day}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FirestoreService firestore) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete ${member.name}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await firestore.deleteMember(member.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
