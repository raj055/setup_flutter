import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/size_config.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  final int splashDuration = 2;

  SwiperController _controller = SwiperController();
  int _currentIndex = 0;

  final List<String> introIllus = [
    'assets/images/splash/1.png',
    'assets/images/splash/2.png',
    'assets/images/splash/3.png',
  ];

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Swiper(
            loop: false,
            index: _currentIndex,
            onIndexChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            controller: _controller,
            pagination: SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                activeColor: Colors.red,
                activeSize: 20.0,
              ),
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              return IntroItem(
                imageUrl: introIllus[index],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FlatButton(
              child: Text("Skip"),
              onPressed: () {
                setData('isSplashScreenView', 'true');
                _showChangeLanguagePage();
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(_currentIndex == 2 ? Icons.check : Icons.arrow_forward),
              onPressed: () {
                if (_currentIndex != 2)
                  _controller.next();
                else {
                  setData('isSplashScreenView', 'true');
                  _showChangeLanguagePage();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _showChangeLanguagePage() {
    Get.offAllNamed('app-language', arguments: {'firstTime': true});
  }
}

setData(String key, String value) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: key, value: value);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

class IntroItem extends StatelessWidget {
  final String? imageUrl;

  const IntroItem({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              child: Image.asset(
                imageUrl!,
                fit: BoxFit.cover,
                width: (MediaQuery.of(context).size.width),
                height: (MediaQuery.of(context).size.height),
              ),
            ),
          )
        ],
      ),
    );
  }
}
