import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;

import '../services/quotes_loader.dart';
import 'auth.dart';
import 'translator.dart';

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

    if (isBaseUrl) dio.options.baseUrl = dotenv.env['API_BASE_URL']!;
    String? token = Auth.token();
    dio.options.headers['Authorization'] = 'Bearer $token';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          if (showLoader) showLoading();

          return options;
        },
        onResponse: (Response response) async {
          if (showLoader) hideLoading();

          showLoader = true;
          isBaseUrl = true;

          return response;
        },
        onError: (DioError error) async {
          if (showLoader) hideLoading();

          showLoader = true;
          isBaseUrl = true;

          if (error.error.runtimeType == SocketException) {
            Get.offAllNamed('no-internet');
          } else if (token != null && error.response.statusCode == 401) {
            await Auth.logout();
            Get.offAllNamed("login");
          } else if (error.response.statusCode == 503) {
            Get.offNamed("app-maintenance");
          } else if (error.response.statusCode >= 500) {
            Get.offAllNamed("something-went-wrong");
          }

          return error;
        },
      ),
    );

    // dio.interceptors.add(LogInterceptor(
    //   responseBody: true,
    //   requestHeader: true,
    //   requestBody: true,
    // ));

    return dio;
  }

  static void hideLoading() {
    if (Get.isDialogOpen) {
      Get.back();
    }
  }

  static void showLoading() {
    String element = QuotesLoader.listQuotes[random.nextInt(QuotesLoader.listQuotes.length)];

    if (!Get.isDialogOpen && showLoader) {
      Get.dialog(
        WillPopScope(
          onWillPop: () => Future.value(false),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/loader.gif',
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '“',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text: Translator.get(element),
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text: '”',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
}
