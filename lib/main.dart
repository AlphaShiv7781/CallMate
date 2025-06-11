import 'package:callmate/screens/auth_screens/login_screen.dart';
import 'package:callmate/screens/home_screen/home_screen.dart';
import 'package:callmate/screens/splash_screen/splash_screen.dart';
import 'package:callmate/screens/call_screen/call_screen.dart'; // <-- Make sure this is the correct path
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔄 Background FCM Received: ${message.data}");

  if (message.data['type'] == 'incoming_call') {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'call_channel_id',
      'Incoming Calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Incoming Call',
      'Tap to answer',
      notificationDetails,
      payload: message.data['channelName'],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await Permission.notification.request();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await NotificationService.initializeGlobal();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null) {
        navigatorKey.currentState?.pushNamed('/call', arguments: payload);
      }
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground FCM: ${message.data}");
    if (message.data['type'] == 'incoming_call') {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'call_channel_id',
        'Incoming Calls',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
      );
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
      flutterLocalNotificationsPlugin.show(
        0,
        'Incoming Call',
        'Tap to answer',
        notificationDetails,
        payload: message.data['channelName'],
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🔔 Notification tapped: ${message.data}");
    final channelName = message.data['channelName'];
    if (channelName != null) {
      navigatorKey.currentState?.pushNamed('/call', arguments: channelName);
    }
  });

  final notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  final initialCallChannel = notificationAppLaunchDetails?.didNotificationLaunchApp == true
      ? notificationAppLaunchDetails?.notificationResponse?.payload
      : null;


  runApp(MyApp(initialCallChannel: initialCallChannel));

}

class MyApp extends StatelessWidget {
  final String? initialCallChannel;
  const MyApp({super.key, this.initialCallChannel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CallMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialCallChannel != null ? '/call' : '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/call') {
          final channelName = settings.arguments ?? initialCallChannel;
          return MaterialPageRoute(
            builder: (_) => CallScreen(channelName: channelName as String),
          );
        }
        return null;
      },
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
