import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../screens/call_screen/call_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static late BuildContext globalContext;

  static Future<void> initializeGlobal() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && globalContext.mounted) {
          Navigator.push(
            globalContext,
            MaterialPageRoute(
              builder: (_) => CallScreen(channelName: payload),
            ),
          );
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground FCM Received: ${message.data}");
      if (message.data['type'] == 'incoming_call') {
        showIncomingCallNotification(message.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🚀 App opened from FCM: ${message.data}");
      if (message.data['type'] == 'incoming_call') {
        final channelName = message.data['channelName'];
        Navigator.push(
          globalContext,
          MaterialPageRoute(
            builder: (_) => CallScreen(channelName: channelName),
          ),
        );
      }
    });
  }

  static void showIncomingCallNotification(Map<String, dynamic> data) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'call_channel_id',
      'Incoming Calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);
    _flutterLocalNotificationsPlugin.show(
      0,
      'Incoming Call',
      'Tap to answer',
      notificationDetails,
      payload: data['channelName'],
    );
  }
}
