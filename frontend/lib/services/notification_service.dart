import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // FIX: Argument positionnel pour la version stable 18.0.1
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification cliquée');
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'jonetsu_channel',
      'JŌNETSU Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    if (message.notification != null) {
      // FIX: Arguments positionnels (id, title, body, details)
      await _localNotifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    }
  }

  Future<void> updateTokenOnBackend(String userId) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await ApiService.dio.put('/users/$userId/fcm-token', data: {'token': token});
      }
    } catch (e) {
      print('Erreur FCM: $e');
    }
  }
}
