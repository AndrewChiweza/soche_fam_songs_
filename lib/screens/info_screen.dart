import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soche_fam_songs/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void shareApp() {
    Share.share(
      '🎶 *SOCHE FAM Songs App* 🎶\n\n'
      'Download the latest APK here:\n'
      '👉 https://drive.google.com/file/d/1c9Gdyg89mZDeuHomY68gnqszRe5IT9Z1/view?usp=sharing\n\n'
      'Be blessed! 🙏',
      subject: 'SOCHE FAM App',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 🔰 SLIVER APP BAR
          SliverAppBar(
            scrolledUnderElevation: 0.0,
            pinned: true,
            expandedHeight: 100,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: const Text(
                "About this App",
              ),
              centerTitle: true,
            ),
          ),

          /// 📜 CONTENT
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ---------------- LOGO ----------------
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 100,
                        offset: const Offset(0, 3),
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset('images/ic_launcher.png'),
                  ),
                ),

                const SizedBox(height: 17),

                const Text(
                  'SOCHE FAM SONGS APP',
                  style: TextStyle(
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 5),

                Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // ---------------- CARD ----------------
                Card(
                  color: Theme.of(context).cardColor,
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _infoTile(
                        icon: FontAwesomeIcons.github,
                        title: "View source code",
                        onTap: () =>
                            _launch("https://github.com/AndrewChiweza"),
                      ),
                      _divider(),
                      _infoTile(
                        icon: FontAwesomeIcons.linkedin,
                        iconColor: Colors.blue,
                        title: "LinkedIn",
                        onTap: () => _launch(
                            "https://www.linkedin.com/in/andrewchiweza/"),
                      ),
                      _divider(),
                      _infoTile(
                        icon: FontAwesomeIcons.facebook,
                        iconColor: Colors.blue,
                        title: "Facebook profile",
                        onTap: () =>
                            _launch("https://facebook.com/andrew.chiweza"),
                      ),
                      _divider(),
                      _infoTile(
                        icon: FontAwesomeIcons.shareNodes,
                        title: "Share this app...",
                        onTap: shareApp,
                      ),
                      _divider(),
                      _infoTile(
                        icon: Icons.help_outline,
                        title: "Help or feedback",
                        onTap: () async {
                          final email =
                              Uri.encodeComponent("css-020-22@must.ac.mw");
                          final subject = Uri.encodeComponent(
                              "SOCHE FAM songs App feedback");
                          final body = Uri.encodeComponent(
                              "Hi Andrew, I would like to say...");
                          final Uri mail = Uri.parse(
                              "mailto:$email?subject=$subject&body=$body");

                          if (await canLaunchUrl(mail)) {
                            await launchUrl(mail,
                                mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Could not open email app')),
                            );
                          }
                        },
                      ),
                      _divider(),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return SwitchListTile(
                            title: const Text("Dark Mode"),
                            value: themeProvider.isDark,
                            onChanged: (value) =>
                                themeProvider.toggleTheme(value),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ---------------- FOOTER ----------------
                Text(
                  "This app was made with 🩷 by Andrew Chiweza, "
                  "software developer and a member of Soche Future Adventist Men.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CUSTOM WIDGETS ---------------- //

  Widget _divider() => const Divider(height: 1, thickness: 0.4);

  Widget _infoTile({
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(CupertinoIcons.chevron_forward, size: 18),
      onTap: onTap,
    );
  }
}
