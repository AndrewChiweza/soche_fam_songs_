import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:soche_fam_songs/components/main_tabs.dart';
import 'package:soche_fam_songs/providers/admins_provider.dart';
import 'package:soche_fam_songs/providers/push_notify_provider.dart';
import 'package:soche_fam_songs/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soche_fam_songs/theme/theme_provider.dart';
import 'firebase_options.dart';

import 'providers/songs_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/notifications_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/admin/admin_panel_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox("Favorites");
  await Hive.openBox("AppPrefs"); // Box for firstLaunch & adminLogin flags

  runApp(const SongLyricsApp());
}

class SongLyricsApp extends StatelessWidget {
  const SongLyricsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementsProvider()),
        ChangeNotifierProvider(create: (_) => AdminsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PushNotificationProvider())
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SOCHE FAM',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const StartupScreen(),
          );
        },
      ),
    );
  }
}

/// Decides initial screen based on Hive flags
class StartupScreen extends StatefulWidget {
  const StartupScreen({Key? key}) : super(key: key);

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _checkStartup();
  }

  Future<void> _checkStartup() async {
    final box = Hive.box("AppPrefs");
    final isFirstLaunch = box.get("first_launch", defaultValue: true);
    final isAdminLoggedIn = box.get("admin_logged_in", defaultValue: false);

    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 300));

    if (isFirstLaunch) {
      box.put("first_launch", false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    } else if (isAdminLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabs()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Call this when admin logs in successfully
Future<void> markAdminLoggedIn() async {
  final box = Hive.box("AppPrefs");
  box.put("admin_logged_in", true);
}

/// Call this when admin logs out
Future<void> markAdminLoggedOut() async {
  final box = Hive.box("AppPrefs");
  box.put("admin_logged_in", false);
}
