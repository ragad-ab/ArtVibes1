import 'package:art_vibes1/screens/tickets/notification.dart';
import 'package:art_vibes1/signup/login/welcome.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.playIntegrity);

  setupFirebaseMessaging();

  runApp(const ArtVibesApp());
}

class ArtVibesApp extends StatelessWidget {
  const ArtVibesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ArtVibes',
      navigatorKey: navigatorKey, // Set the navigator key
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF008080),
          secondary: const Color(0xFFFF7043),
        ),
      ),
      home: WelcomeScreen(), // Always start with WelcomeScreen
    );
  }
}

// Setup Firebase Messaging
void setupFirebaseMessaging() {
  // Request permissions on iOS (if applicable)
  _firebaseMessaging.requestPermission();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showLocalNotification(message.notification);
  });

  // Listen for background messages
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (_) => NotificationScreen()));
  });
}

// Display local notification for foreground messages
void _showLocalNotification(RemoteNotification? notification) async {
  if (notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', 'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFFF7043), // Badge color
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }
}
