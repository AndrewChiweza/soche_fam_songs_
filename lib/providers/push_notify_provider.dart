import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationProvider with ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  List<RemoteMessage> messages = [];

  Future<void> init() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // Get FCM token
    String? token = await _messaging.getToken();
    print("FCM Token: $token"); // send this token to your server if needed

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      messages.insert(0, message);
      notifyListeners();
    });

    // Background & terminated message handling is done via onMessageOpenedApp
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      messages.insert(0, message);
      notifyListeners();
    });
  }
}
