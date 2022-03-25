import 'dart:io';

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:url_launcher/url_launcher.dart';

import '../../services/size_config.dart';
import '../../widget/theme.dart';

class AppUpdate extends StatefulWidget {
  @override
  _AppUpdateState createState() => _AppUpdateState();
}

class _AppUpdateState extends State<AppUpdate> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(
          "App Update Available",
        ),
        centerTitle: true,
      ),
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
          content: Text(
            'Tap back again to exit app',
          ),
          backgroundColor: red,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: text(
                'Please update app to enjoy full featured app with more benefits for you.',
                fontSize: textSizeLargeMedium,
                fontFamily: fontBold,
                isLongText: true,
              ),
            ),
            const SizedBox(height: 30.0),
            Expanded(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/rocket.gif',
                    alignment: Alignment.center,
                    height: h(50),
                    width: width,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      MaterialButton(
                        padding: const EdgeInsets.all(12.0),
                        highlightElevation: 0,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                        child: Text(
                          "UPDATE APP",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        textColor: Colors.white,
                        color: colorPrimary,
                        onPressed: () {
                          launch(Platform.isAndroid ? DotEnv.env['PLAYSTORE_URL']! : DotEnv.env['APPSTORE_URL']!);
                        },
                      ),
                      OutlineButton(
                        padding: const EdgeInsets.all(12.0),
                        highlightElevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(color: red),
                        ),
                        borderSide: BorderSide(color: red),
                        child: Text(
                          "EXIT APP",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        textColor: red,
                        onPressed: () => SystemNavigator.pop(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
