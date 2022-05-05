import 'package:dsgo/home.dart';
import 'package:dsgo/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  channel = const AndroidNotificationChannel(
    'duckchat_high_importance_channel', '채팅', 
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance
    .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=>MainState()),
    ],
    child: const App(),
  ));
}

int _messageCount = 0;

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return const MaterialApp(
      title: "dsgo",
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}