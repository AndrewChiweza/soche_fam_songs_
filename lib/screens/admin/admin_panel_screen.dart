import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/admins_provider.dart';
import 'admin_songs_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_members_screen.dart';
import 'admin_manage_admins_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminsProvider>();
    if (!provider.isLoggedIn) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/admin-sign-in');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminsProvider>().currentAdmin;

    String initials = '';
    if (admin != null && admin.name.isNotEmpty) {
      final parts = admin.name.split(' ');
      initials = parts.take(2).map((e) => e[0]).join().toUpperCase();
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🔰 SLIVER APP BAR
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            automaticallyImplyLeading: false,
            title: const Text("Admin Panel"),
            actions: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(initials, style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  final box = Hive.box("AppPrefs");
                  await box.put("admin_logged_in", false); // ✅ Clear login flag
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),

          /// 👋 HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back 👋",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    admin?.name ?? "Administrator",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),

          /// 📊 DASHBOARD
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _statsTile(
                    context,
                    stream: FirebaseFirestore.instance
                        .collection("songs")
                        .snapshots(),
                    icon: CupertinoIcons.music_note_list,
                    title: "Manage Songs",
                    page: AdminSongsScreen(),
                    suffix: "songs",
                  ),
                  _gap(),
                  _simpleTile(
                    context,
                    icon: CupertinoIcons.bell_fill,
                    title: "Announcements",
                    page: const AdminAnnouncementsScreen(),
                  ),
                  _gap(),
                  _statsTile(
                    context,
                    stream: FirebaseFirestore.instance
                        .collection("members")
                        .snapshots(),
                    icon: CupertinoIcons.group_solid,
                    title: "Registered Members",
                    page: const AdminMembersScreen(),
                    suffix: "members",
                  ),
                  _gap(),
                  _statsTile(
                    context,
                    stream: FirebaseFirestore.instance
                        .collection("admins")
                        .snapshots(),
                    icon: CupertinoIcons.settings_solid,
                    title: "Manage Admins",
                    page: const AdminManageAdminsScreen(),
                    suffix: "admins",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── WIDGETS ─────────────────────────

  Widget _gap() => const SizedBox(height: 14);

  Widget _statsTile(
    BuildContext context, {
    required Stream<QuerySnapshot> stream,
    required IconData icon,
    required String title,
    required Widget page,
    required String suffix,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (_, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _cardTile(
          context,
          icon: icon,
          title: title,
          subtitle: "$count $suffix",
          page: page,
        );
      },
    );
  }

  Widget _simpleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return _cardTile(
      context,
      icon: icon,
      title: title,
      subtitle: "View & manage",
      page: page,
    );
  }

  Widget _cardTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
