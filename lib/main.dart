import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:sjq/constant/constant.dart';
import 'package:sjq/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'firebase_options.dart';
import 'call.notifier.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('🔔 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        debugPrint('🔗 Notification payload: ${response.payload}');
        navigatorKey.currentState?.pushNamed('/notifications');
      }
    },
  );


  runApp(const MainApp());

  setupFCM();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('✅ Notification permission granted.');

    // Do NOT generate or log the token here.
    // Token will be fetched and sent after successful login only.

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground message: ${message.notification?.title}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel_id',
              'General Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: 'notification',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📦 App opened from notification: ${message.notification?.title}');
      navigatorKey.currentState?.pushNamed('/notifications');
    });

    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🧊 App started by tapping notification: ${initialMessage.notification?.title}');
      navigatorKey.currentState?.pushNamed('/notifications');
    }

  } else {
    debugPrint('❌ Notification permission denied.');
  }
}


Future<void> sendTokenToBackend(String token) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      debugPrint('❌ No userId found in SharedPreferences.');
      return;
    }

    final response = await http.post(
      Uri.parse('$BASE_URL/tokens/save-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ FCM Token saved to server.');
    } else {
      debugPrint('❌ Failed to save FCM Token: ${response.body}');
    }
  } catch (e) {
    debugPrint('❌ Error sending FCM Token: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CallNotifier()),
      ],
      child: MaterialApp(
        title: 'Nutrivision',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // <<< Important for navigation outside BuildContext
        theme: ThemeData(
          textTheme: GoogleFonts.lexendDecaTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        routes: Routes.routes,
        initialRoute: '/', 
      ),
    );
  }
}
