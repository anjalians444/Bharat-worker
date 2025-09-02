import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void addNotifications(List<NotificationItem> notifications) {
    _notifications.insertAll(0, notifications);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void loadDemoNotifications() {
    addNotifications([
      NotificationItem(
        iconPath: 'assets/icons/jobAcceptedIcon.svg',
        title: 'Job Accepted Successfully',
        subtitle: 'You\'ve accepted Job #1023 - AC Service.',
        time: '2 mins',
      ),
      NotificationItem(
        iconPath: 'assets/icons/paymentReceivedIcon.svg',
        title: 'Payment Received',
        subtitle: '\u20b9650 received for Job #1007 - AC Gas Filling.',
        time: '30 min',
      ),
      NotificationItem(
        iconPath: 'assets/icons/jobCancelledIcon.svg',
        title: 'Job Cancelled',
        subtitle: 'Job #1023 - AC Service has been cancelled by the customer.',
        time: '1 hour',
      ),
      NotificationItem(
        iconPath: 'assets/icons/newJobRequestIcon.svg',
        title: 'New Job Request',
        subtitle: 'New plumbing job request available near you.',
        time: '1 hour',
      ),
      NotificationItem(
        iconPath: 'assets/icons/skillBadgeUnlockedIcon.svg',
        title: 'Skill Badge Unlocked',
        subtitle: 'You\'ve earned the "Trusted Plumber" badge!',
        time: 'Yesterday',
      ),
      NotificationItem(
        iconPath: 'assets/icons/profileUpdateReminderIcon.svg',
        title: 'Profile Update Reminder',
        subtitle: 'Complete your profile to get more job offers.',
        time: '2 days',
      ),
    ]);
  }

  // Add this method to handle FCM messages
  void addNotificationFromFCM(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      addNotification(NotificationItem(
        iconPath: 'assets/icons/notification.svg', // You can customize icon
        title: notification.title ?? 'Notification',
        subtitle: notification.body ?? '',
        time: DateTime.now().toString(),
      ));
    }
  }

  // --- FCM and Local Notification Setup ---
  Future<void> initializeFCM(GlobalKey<NavigatorState> navigatorKey) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final fcmToken = await messaging.getToken();
    debugPrint('FCM Token: $fcmToken');
    // TODO: Save/send token to backend if needed

    // --- Android Notification Channel Setup ---
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel', // id
      'Default', // name
      description: 'Default channel for notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF00FF00), // Green LED, change as needed
      showBadge: true,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = this.flutterLocalNotificationsPlugin;
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

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
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              channelDescription: 'Default channel for notifications',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              enableLights: true,
              ledColor: Color(0xFF00FF00),
              ledOnMs: 1000,
              ledOffMs: 500,
              showWhen: true,
            ),
          ),
        );
      }
      addNotificationFromFCM(message);
    });

    // Background/terminated message handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification: ${message.notification?.title}');
      addNotificationFromFCM(message);
    });
  }
} 