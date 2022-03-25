import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../services/auth.dart';
import '../widget/theme.dart';

class AppUtils {
  static String getKeyValueFromJsonObject(dynamic jsonObj, String valueToCompare) {
    String valueOfKey = '';
    final data = jsonObj as Map;

    for (var key in data.keys) {
      var value = data[key];
      if (valueToCompare == key) {
        valueOfKey = value;
        break;
      }
    }
    return valueOfKey;
  }

  static List<Map> getListFromJsonObject(Map jsonObj) {
    List<Map> list = [];
    jsonObj.forEach((key, value) {
      list.add({'id': key, 'type': value});
    });
    return list;
  }

  static void showErrorSnackBar(String message) {
    GetBar(
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
      message: message,
    ).show();
  }

  static void showSuccessSnackBar(String message) {
    GetBar(
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
      message: message,
    ).show();
  }

  static void showInfoSnackBar(String message, {Color? color}) {
    GetBar(
      backgroundColor: color == null ? primary : color,
      duration: Duration(seconds: 3),
      message: message,
    ).show();
  }

  static redirect(routeName, {dynamic arguments, String? pageToRedirectAfterLogin, Function? callWhileBack}) {
    if (routeName == 'login-mlm') {
      Get.toNamed(routeName, arguments: 'justBack')!.then((value) {
        if (Auth.check()! && pageToRedirectAfterLogin != null) {
          Get.toNamed(pageToRedirectAfterLogin);
        }
        if (callWhileBack != null) {
          callWhileBack();
        }
      });
    } else {
      Get.toNamed(routeName, arguments: arguments)!.then((value) {
        if (callWhileBack != null) {
          callWhileBack();
        }
      });
    }
  }
}
