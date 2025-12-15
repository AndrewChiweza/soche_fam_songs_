import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/firestore_service.dart';

class MemberRegistrationScreen extends StatefulWidget {
  final Member? existingMember;

  const MemberRegistrationScreen({super.key, this.existingMember});

  @override
  State<MemberRegistrationScreen> createState() =>
      _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestore = FirestoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _voiceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _churchController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  bool _baptised = false;
  bool isEditing = false;
  String? memberId;

  @override
  void initState() {
    super.initState();
    if (widget.existingMember != null) {
      isEditing = true;
      final m = widget.existingMember!;
      memberId = m.id;

      _nameController.text = m.name;
      _emailController.text = m.email;
      _voiceController.text = m.voiceType;
      _phoneController.text = m.phone;
      _churchController.text = m.localChurch;
      _purposeController.text = m.purpose;
      _baptised = m.baptised;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _voiceController.dispose();
    _phoneController.dispose();
    _churchController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    final member = Member(
      id: memberId ?? "",
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      baptised: _baptised,
      localChurch: _churchController.text.trim(),
      purpose: _purposeController.text.trim(),
      voiceType: _voiceController.text.trim(),
      phone: _phoneController.text.trim(),
      joinedAt: widget.existingMember?.joinedAt ?? DateTime.now(),
    );

    if (isEditing) {
      await _firestore.updateMember(memberId!, member);
    } else {
      await _firestore.addMember(member);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🔷 SLIVER APP BAR
          SliverAppBar(
            pinned: true,
            elevation: 2,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.chevron_left),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isEditing ? "Edit Member" : "Register Member",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
          ),

          /// 🧾 FORM CONTENT
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _FormCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration:
                                _input("Full Name", CupertinoIcons.person),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _input("Email", CupertinoIcons.mail),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration:
                                _input("Phone Number", CupertinoIcons.phone),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _voiceController,
                            decoration:
                                _input("Voice Type", CupertinoIcons.music_note),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _churchController,
                            decoration:
                                _input("Local Church", CupertinoIcons.house),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _purposeController,
                            maxLines: 2,
                            decoration: _input(
                                "Purpose of Joining", CupertinoIcons.flag),
                            validator: (v) => v!.isEmpty ? "Required" : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormCard(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Baptised"),
                        value: _baptised,
                        onChanged: (v) => setState(() => _baptised = v),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMember,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEditing ? "Update Member" : "Add Member",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🧩 REUSABLE CARD
class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 3,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
