import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'main.dart';

class PushNotificationManager {
  Future init() async {
    var initialzationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initialzationSettingsAndroid);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.data.containsKey('page')) {
        routerName = message.data['page'];
        Get.toNamed(message.data['page']);
      }
    });

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: android.smallIcon,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.containsKey('page')) {
        routerName = message.data['page'];
        Get.toNamed(message.data['page']);
      }
    });
  }
}
