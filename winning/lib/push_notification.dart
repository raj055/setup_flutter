import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' hide Response;

import 'main.dart';

class PushNotificationManager {
  static final FirebaseMessaging fcm = FirebaseMessaging();

  Future init() async {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data'].containsKey('page')) {
          routerName = message['data']['page'];
          routerData = message['data']['details'];
          print('routerName $routerName');
          // Get.toNamed(message['data']['page']);
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume $message');
        print('onResume ${message['data']['details']}');
        if (message['data'].containsKey('page')) {
          Get.toNamed(message['data']['page']);
          // Get.toNamed(message['data']['page'], arguments: {"type": 'PushNotification', "detail": message['data']['details']});
        }
      },
    );
  }
}
