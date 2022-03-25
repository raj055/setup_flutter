import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'push_notification.dart';
import 'services/auth.dart';
import 'services/router.dart';
import 'widget/theme.dart';

String? routerName;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  flutterLocalNotificationsPlugin.show(
    message.data.hashCode,
    message.data['title'],
    message.data['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channel.description,
      ),
    ),
  );
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  String initialRouterName = "/";

  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await DotEnv.load(fileName: '.env');
  await Auth.initialize();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await PushNotificationManager().init();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    GetMaterialApp(
      defaultTransition: Transition.fade,
      initialRoute: initialRouterName,
      title: DotEnv.env['APP_NAME']!,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xffF5F8FA),
        primaryColor: colorPrimary,
        accentColor: colorAccent,
        textTheme: TextTheme(
          bodyText2: TextStyle(fontFamily: fontRegular),
          bodyText1: TextStyle(fontFamily: fontRegular),
        ),
        appBarTheme: appBarTheme(),
      ),
      debugShowCheckedModeBanner: false,
      getPages: CustomRouter.pages,
      routingCallback: (routing) async {},
    ),
  );
}
