import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:get/get.dart';

import 'auth.dart';

class Api {
  static final random = new Random();

  static bool showLoader = true;
  static bool isBaseUrl = true;

  static Dio get httpWithoutLoader {
    showLoader = false;
    return http;
  }

  static Dio get httpWithoutBaseUrl {
    isBaseUrl = false;

    return http;
  }

  static Dio get http {
    Dio dio = new Dio();

    if (isBaseUrl) dio.options.baseUrl = DotEnv.env['API_BASE_URL']!;

    String? token = isBaseUrl ? Auth.token() : Auth.tokenMLM();
    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['Accept'] = 'application/json';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, handler) async {
          if (showLoader) showLoading();

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          if (showLoader) hideLoading();

          showLoader = true;
          isBaseUrl = true;

          return handler.next(response);
        },
        onError: (DioError error, handler) async {
          if (showLoader) hideLoading();

          showLoader = true;

          if (error.error.runtimeType == SocketException) {
            Get.offAllNamed('/no-internet');
          } else if (token != null && error.response!.statusCode == 401) {
            if (isBaseUrl) {
              // await Auth.logout();
              // Get.offAllNamed("/login");
            }
          } else if (error.response!.statusCode == 503) {
            Get.offAllNamed("app-maintenance");
          } else if (error.response!.statusCode! >= 500) {
            if (isBaseUrl) Get.offAllNamed("/something-went-wrong");
          } else if (error.response!.statusCode == 302) {
            print("error.response ${error.response}");
          }
          isBaseUrl = true;

          return handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestHeader: true,
        requestBody: true,
      ),
    );

    return dio;
  }

  static void hideLoading() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }

  static void showLoading() {
    if (!Get.isDialogOpen! && showLoader) {
      Widget progressIndicator = CupertinoActivityIndicator(radius: 20);
      if (Platform.isAndroid) {
        progressIndicator = CircularProgressIndicator();
      }

      Get.dialog(
        WillPopScope(
          onWillPop: () => Future.value(false),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
}
