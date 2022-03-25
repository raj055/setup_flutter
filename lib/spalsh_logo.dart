import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import 'package:package_info/package_info.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/theme.dart';

class SplashLogo extends StatefulWidget {
  @override
  _SplashLogoState createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> with SingleTickerProviderStateMixin {
  final int splashDuration = 3;
  var _visible = true;

  AnimationController? animationController;
  Animation<double>? animation;

  AssetBundle? defaultAssetBundle;

  startTime() async {
    Timer(Duration(seconds: splashDuration), () async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String version = packageInfo.version;

      final storage = new FlutterSecureStorage();

      String? status;
      try {
        status = (await storage.read(key: 'isWellCome'))!;
      } catch (e) {
        storage.deleteAll();
      }

      await Api.http.get('member/app-status?appVersion=$version').then((res) {
        if (res.data['maintenance']) {
          Get.offAllNamed('/app-maintenance', arguments: {
            "title": res.data['maintenanceTitle'],
            "message": res.data['maintenanceMessage'],
          });
        } else if (res.data['update']) {
          Get.offAllNamed('/app-update');
        } else {
          if (status == null) {
            Get.offAllNamed('/language-video');
          } else {
            Get.offAllNamed('/ecommerce');
          }
        }
      }, onError: (err) {});
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    animation = CurvedAnimation(parent: animationController!, curve: Curves.easeOut);

    animation!.addListener(() => this.setState(() {}));
    animationController!.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                logo1,
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
