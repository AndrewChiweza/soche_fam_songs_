import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soche_fam_songs/components/app_snack_bar.dart';
import 'package:hive/hive.dart';
import 'package:soche_fam_songs/theme/app_theme.dart';
import '../../providers/admins_provider.dart';
import 'admin_panel_screen.dart';

class AdminSignInScreen extends StatefulWidget {
  const AdminSignInScreen({Key? key}) : super(key: key);

  @override
  State<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminsProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(""),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// LOGO or ICON
                Icon(Icons.admin_panel_settings,
                    size: 90, color: Theme.of(context).iconTheme.color),
                const SizedBox(height: 25),

                /// Title
                Text(
                  "Welcome Admin",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                /// EMAIL FIELD
                _inputField(
                  controller: emailCtrl,
                  label: "Email",
                  prefixIcon: Icons.email_outlined,
                  validatorMsg: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                /// PASSWORD FIELD
                _inputField(
                  controller: passwordCtrl,
                  label: "Password",
                  prefixIcon: Icons.lock_outline,
                  validatorMsg: "Enter your password",
                  obscureText: !showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                    ),
                    onPressed: () {
                      setState(() => showPassword = !showPassword);
                    },
                  ),
                ),

                const SizedBox(height: 30),

                /// SIGN IN BUTTON
                loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => loading = true);

                            final error = await provider.signIn(
                              emailCtrl.text.trim(),
                              passwordCtrl.text.trim(),
                            );

                            setState(() => loading = false);

                            if (error != null) {
                              AppSnackBar.showError(context, error);
                              return;
                            }

                            // ✅ Save admin login state
                            final box = Hive.box("AppPrefs");
                            await box.put("admin_logged_in", true);

                            // Navigate to admin panel
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminPanelScreen()),
                            );
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method for input fields
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String validatorMsg,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
        validator: (v) => v!.isEmpty ? validatorMsg : null,
      ),
    );
  }
}
