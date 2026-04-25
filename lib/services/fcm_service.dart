import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'api_service.dart';

/// 🔹 This must be a top-level function (outside any class)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // print('📨 Background message: ${message.notification?.title}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// Initialize FCM
  static Future<void> initializeFCM() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const InitializationSettings initSettings =
    InitializationSettings(android: AndroidInitializationSettings('@mipmap/launcher_icon'));
    await _localNotifications.initialize(initSettings);

    // 🔹 Register the top-level background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//      print('📩 Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
//      print('📱 Notification opened: ${message.notification?.title}');
    });

    // Get FCM token
    // final token = await _messaging.getToken();
    // print('🔥 FCM Token: $token');

    // if (token != null) {
    //   await ApiService.sendFcmTokenToBackend(token);
    // }
    //
    // // Handle token refresh
    // _messaging.onTokenRefresh.listen((newToken) async {
    //   print('♻️ FCM Token refreshed: $newToken');
    //   await ApiService.sendFcmTokenToBackend(newToken);
    // });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'New Alert',
      message.notification?.body ?? '',
      platformDetails,
    );
  }
}
