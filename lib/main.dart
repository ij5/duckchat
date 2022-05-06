import 'package:dsgo/chat.dart';
import 'package:dsgo/home.dart';
import 'package:dsgo/login.dart';
import 'package:dsgo/message.dart';
import 'package:dsgo/provider.dart';
import 'package:dsgo/register.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:page_transition/page_transition.dart';

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
    'duckchat_high_importance_channel', 'chat', 
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

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState(){
    super.initState();
    FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message){
        if(message != null) {
          Navigator.pushNamed(context, '/chat', arguments: MessageArguments(message, true));
        }
      });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification != null && android != null){
        flutterLocalNotificationsPlugin.show(
          notification.hashCode, 
          notification.title, 
          notification.body, 
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'launch_background'
            )
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      Navigator.pushNamed(context, '/chat', arguments: MessageArguments(message, true));
    });
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "dsgo",
      // home: Home(),
      debugShowCheckedModeBanner: false,
      // routes: {
      //   '/': (context)=> const Home(),
      //   '/chat': (context)=> const Chat(),
      //   '/login': (context) => const Login(),
      //   '/register': (context) => const Register(),
      // },
      onGenerateRoute: (settings){
        switch(settings.name){
          case '/':
            return PageTransition(child: const Home(), type: PageTransitionType.bottomToTop);
          case '/chat':
            return PageTransition(child: const Chat(), type: PageTransitionType.bottomToTop);
          case '/login':
            return PageTransition(
              child: const Login(), type: PageTransitionType.bottomToTop, 
              curve: Curves.easeOutQuart, duration: const Duration(milliseconds: 500)
            );
          case '/register':
            return PageTransition(
              child: const Register(), type: PageTransitionType.bottomToTop,
              curve: Curves.easeOutQuart, duration: const Duration(milliseconds: 500),
            );
          default:
            return null;
        }
      },
    );
  }
}