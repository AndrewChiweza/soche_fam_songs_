import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admins_provider.dart';
import '../../models/admin_user.dart';
import 'admin_admin_form_screen.dart';

class AdminManageAdminsScreen extends StatelessWidget {
  const AdminManageAdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminsProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Manage Admin Users"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAdminFormScreen()),
          );
        },
        backgroundColor: Theme.of(context).cardColor,
        child: const Icon(CupertinoIcons.person_add),
      ),
      body: StreamBuilder<List<AdminUser>>(
        stream: provider.streamAdmins(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final admins = snapshot.data!;
          final current = provider.currentAdmin;

          // If current admin is null, show loading
          if (current == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (admins.isEmpty) {
            return const Center(
              child: Text(
                "No admins yet",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: admins.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final admin = admins[i];

              final canEdit = current.isSuperAdmin || admin.id == current.id;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).cardColor,
                child: ListTile(
                  enabled: canEdit,
                  title: Text(
                    admin.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    admin.email,
                  ),
                  trailing: admin.isSuperAdmin
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Super Admin",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                  onTap: canEdit
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminAdminFormScreen(admin: admin),
                            ),
                          );
                        }
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
