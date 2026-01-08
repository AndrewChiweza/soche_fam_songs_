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

    if (current == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Can edit if super admin OR editing own profile
    final canEdit = current.isSuperAdmin || widget.admin?.id == current.id;

    // Show password field if:
    // 1. Creating a new admin (only super admin)
    // 2. Editing own profile (regular admin)
    // 3. Super admin editing any admin
    final showPasswordField = (!isEditing && current.isSuperAdmin) ||
        (isEditing && (current.isSuperAdmin || widget.admin?.id == current.id));

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditing ? "Edit Admin" : "Add Admin"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Full Name
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    enabled: canEdit,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    enabled: canEdit,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  if (showPasswordField)
                    TextFormField(
                      controller: passwordCtrl,
                      decoration: InputDecoration(
                        labelText: isEditing
                            ? "New Password (leave empty to keep current)"
                            : "Password",
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      style:
                          TextStyle(color: theme.textTheme.bodyMedium?.color),
                      validator: (v) {
                        if (!isEditing && (v == null || v.isEmpty)) {
                          return "Password is required for new admin";
                        }
                        return null;
                      },
                    ),
                  if (showPasswordField) const SizedBox(height: 16),

                  // Super Admin switch
                  if (current.isSuperAdmin)
                    SwitchListTile(
                      title: const Text("Super Admin"),
                      value: isSuperAdmin,
                      onChanged: (v) => setState(() => isSuperAdmin = v),
                    ),

                  // Delete button (for super admin)
                  if (isEditing && current.isSuperAdmin)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: TextButton(
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Admin"),
                              content: const Text(
                                  "Are you sure you want to delete this admin?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
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
                    ),

                  const SizedBox(height: 24),

                  // Create/Update button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: canEdit
                          ? () async {
                              if (!_formKey.currentState!.validate()) return;

                              final admin = AdminUser(
                                id: widget.admin?.id ?? "",
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                isSuperAdmin: isSuperAdmin,
                                createdAt:
                                    widget.admin?.createdAt ?? DateTime.now(),
                              );

                              // Only pass password if non-empty
                              final password = passwordCtrl.text.trim().isEmpty
                                  ? null
                                  : passwordCtrl.text.trim();

                              if (isEditing) {
                                await provider.updateAdmin(admin,
                                    newPassword: password);
                              } else {
                                await provider.createAdmin(
                                    admin, passwordCtrl.text.trim());
                              }

                              if (mounted) Navigator.pop(context);
                            }
                          : null,
                      child: Text(
                        isEditing ? "Update Admin" : "Create Admin",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
