import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_user.dart';
import '../../providers/admins_provider.dart';

class AdminAdminFormScreen extends StatefulWidget {
  final AdminUser? admin;
  const AdminAdminFormScreen({super.key, this.admin});

  @override
  State<AdminAdminFormScreen> createState() => _AdminAdminFormScreenState();
}

class _AdminAdminFormScreenState extends State<AdminAdminFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isSuperAdmin = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    if (widget.admin != null) {
      isEditing = true;
      nameCtrl.text = widget.admin!.name;
      emailCtrl.text = widget.admin!.email;
      isSuperAdmin = widget.admin!.isSuperAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminsProvider>();
    final current = provider.currentAdmin;

// Determine if this admin can be edited by the current user
    final canEdit = current!.isSuperAdmin || widget.admin?.id == current.id;

// Wrap delete button
    if (isEditing && current.isSuperAdmin)
      TextButton(
        onPressed: () async {/* delete logic */},
        child: const Text("Delete Admin", style: TextStyle(color: Colors.red)),
      );

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
        title: Text(isEditing ? "Edit Admin" : "Add Admin"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(CupertinoIcons.lock_circle),
              onPressed: () async {
                await provider.resetPassword(emailCtrl.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password reset email sent")),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              if (!isEditing)
                TextFormField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (v) {
                    if (!isEditing && (v == null || v.isEmpty)) {
                      return "Password is required for new admin";
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 12),
              if (current.isSuperAdmin)
                SwitchListTile(
                  title: const Text("Super Admin"),
                  value: isSuperAdmin,
                  onChanged: (v) => setState(() => isSuperAdmin = v),
                ),
              if (isEditing)
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Admin"),
                        content: const Text(
                            "Are you sure you want to delete this admin?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel")),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete")),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await provider.deleteAdmin(widget.admin!.id);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Delete Admin",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: canEdit
                    ? () async {
                        if (!_formKey.currentState!.validate()) return;

                        final admin = AdminUser(
                          id: widget.admin?.id ?? "",
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          isSuperAdmin: isSuperAdmin,
                          createdAt: widget.admin?.createdAt ?? DateTime.now(),
                        );

                        if (isEditing) {
                          await provider.updateAdmin(admin);
                        } else {
                          await provider.createAdmin(
                              admin, passwordCtrl.text.trim());
                        }

                        if (mounted) Navigator.pop(context);
                      }
                    : null, // button disabled if user cannot edit
                child: Text(isEditing ? "Update" : "Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
