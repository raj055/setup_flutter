import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../services/auth.dart';
import '../services/translator.dart';

class NoInternet extends StatefulWidget {
  @override
  _NoInternetState createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  Future<bool> _onWillPop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
          Translator.get('Are you sure you want to exit an app?')!,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              Translator.get('No')!,
            ),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text(
              Translator.get('Yes')!,
            ),
          ),
        ],
      ),
    );

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Feather.wifi_off,
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  Translator.get("No Internet Connection")!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    (new Dio()).head('https://google.com').then(
                      (value) {
                        if (Auth.check()!) {
                          if (Auth.currentPackage() == 1) {
                            Get.offAllNamed('guest-dashboard');
                          } else {
                            Get.offAllNamed('home');
                          }
                        } else {
                          Get.offAllNamed('login');
                        }
                      },
                    ).catchError(
                      (error) {
                        GetBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                          message: Translator.get('Your internet is still not working. Please try again later.')!,
                        ).show();
                      },
                    );
                  },
                  child: Text(
                    Translator.get('Check Again')!,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
