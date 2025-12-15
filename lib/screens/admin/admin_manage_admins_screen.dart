import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admins_provider.dart';
import '../../models/admin_user.dart';
import 'admin_admin_form_screen.dart';
import 'package:provider/provider.dart';

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
            onPressed: () {
              // This button navigates back to the previous screen
              Navigator.of(context).pop();
            },
            // Optional: customize the color
          ),
          title: const Text("Manage Admin Users")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAdminFormScreen()),
          );
        },
        child: const Icon(CupertinoIcons.person_add),
      ),
      body: StreamBuilder<List<AdminUser>>(
        stream: provider.streamAdmins(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final admins = snapshot.data!;

          if (admins.isEmpty) {
            return const Center(child: Text("No admins yet"));
          }

          final current = provider.currentAdmin;

          return ListView.builder(
            itemCount: admins.length,
            itemBuilder: (_, i) {
              final admin = admins[i];

              final canEdit = current!.isSuperAdmin || admin.id == current.id;

              return ListTile(
                enabled: canEdit,
                title: Text(admin.name),
                subtitle: Text(admin.email),
                onTap: canEdit
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminAdminFormScreen(admin: admin),
                          ),
                        );
                      }
                    : null, // disable tap if not allowed
                // trailing: admin.isSuperAdmin
                //     ? const Text(
                //         "Super Admin",
                //         style: TextStyle(color: Colors.grey),
                //       )
                //     : null,
              );
            },
          );
        },
      ),
    );
  }
}
