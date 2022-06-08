import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api.dart';
import '../services/auth.dart';
import '../services/size_config.dart';
import '../services/storage.dart';
import '../services/translator.dart';

class SplashLogo extends StatefulWidget {
  @override
  _SplashLogoState createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> with SingleTickerProviderStateMixin {
  static const platform = const MethodChannel("com.mobiknight.winningteam/security_channel");
  final int splashDuration = 2;
  bool _loader = false;
  var _visible = true;

  late AnimationController? animationController;
  late Animation<double>? animation;

  late AssetBundle? defaultAssetBundle;

  Future<void> _setSecurityMode() async {
    Map<String, dynamic> args = {
      'mode': dotenv.env['SECURITY_MODE'],
    };
    try {
      final bool? result = await platform.invokeMethod('setSecurityMode', args);
      // log('result $result');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  startTime() async {
    Timer(Duration(seconds: splashDuration), () async {
      if (Platform.isAndroid) await _setSecurityMode();

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String version = packageInfo.version;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var loginStatus = prefs.getBool('isLoggedIn') ?? false;

      final storage = new FlutterSecureStorage();
      // String status = await storage.read(key: 'isSplashScreenView');
      String? status;
      try {
        status = await storage.read(key: 'isSplashScreenView');
      } catch (e) {
        storage.deleteAll();
      }

      if (await Storage.get('app-lang') == null) {
        await Storage.set('app-lang', 'en');
      }

      await Translator.init();

      await Api.httpWithoutLoader.get('app-status?appVersion=$version').then((res) {
        setState(() {
          _loader = false;
        });

        String key = Platform.isAndroid ? 'android' : 'ios';

        if (res.data[key]['maintenance']) {
          Navigator.of(context).pushReplacementNamed('app-maintenance', arguments: {
            "title": res.data[key]['maintenanceTitle'],
            "message": res.data[key]['maintenanceMessage'],
          });
        } else if (res.data[key]['update']) {
          Navigator.of(context).pushReplacementNamed('app-update');
        } else {
          SystemChannels.textInput.invokeMethod('TextInput.hide');

          if (status == null) {
            Get.offAllNamed('splash');
          } else if (loginStatus && Auth.check()!) {
            if (Auth.profile() != null && Auth.profile()!) {
              if (Auth.currentPackage() == 1) {
                Get.offAllNamed('guest-dashboard');
              } else {
                Get.offAllNamed('home');
              }
            } else {
              Get.offAllNamed('profile-update');
            }
          } else {
            Get.offAllNamed('login');
          }
        }
      }, onError: (err) {
        print('errorData $err');
      });
    });
  }

  getLanguage() async {
    defaultAssetBundle = DefaultAssetBundle.of(context);
    Storage.set(
      'stored-lang',
      [
        json.decode(await defaultAssetBundle!.loadString('assets/language/hindi.json')),
        json.decode(await defaultAssetBundle!.loadString('assets/language/gujrati.json')),
        json.decode(await defaultAssetBundle!.loadString('assets/language/bangla.json')),
        json.decode(await defaultAssetBundle!.loadString('assets/language/kannada.json')),
        json.decode(await defaultAssetBundle!.loadString('assets/language/malayalam.json')),
        json.decode(await defaultAssetBundle!.loadString('assets/language/telugu.json')),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(vsync: this, duration: new Duration(seconds: 2));
    animation = new CurvedAnimation(parent: animationController!, curve: Curves.easeOut);

    animation!.addListener(() => this.setState(() {}));
    animationController!.forward();

    setState(
      () {
        _visible = !_visible;
      },
    );
    getLanguage();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      startTime();
    });
  }

  @override
  void dispose() {
    super.dispose();
    animationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/logo.png',
                width: animation!.value * 250,
                height: animation!.value * 250,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
