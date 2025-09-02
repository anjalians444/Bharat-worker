import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notification_provider.dart';

class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationProvider notificationProvider;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService({required this.navigatorKey, required this.notificationProvider});

  Future<void> initialize() async {
    // Request permissions
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final fcmToken = await messaging.getToken();
    debugPrint('FCM Token: $fcmToken');
    // TODO: Save/send token to backend if needed

    // Local notification setup
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received a foreground message: ${message.notification?.title}');
      // Show local notification
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('default_channel', 'Default', importance: Importance.max, priority: Priority.high),
          ),
        );
      }
      // Update provider
      final context = navigatorKey.currentContext;
      if (context != null) {
        notificationProvider.addNotificationFromFCM(message);
      }
    });

    // Background/terminated message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification: ${message.notification?.title}');
      final context = navigatorKey.currentContext;
      if (context != null) {
        notificationProvider.addNotificationFromFCM(message);
      }
    });
  }
} 