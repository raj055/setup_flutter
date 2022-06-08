import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'push_notification.dart';
import 'screens/test.dart';
import 'services/auth.dart';
import 'services/router.dart';
import 'widget/theme.dart';

String? routerName;
Map? routerData;
Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // await Permission.camera.request();
    // await Permission.microphone.request();

    String initialRouterName = "/";

    await dotenv.load(fileName: '.env');

    await Auth.initialize();

    print(" SENTRY ${dotenv.env['SENTRY']}");

    // if (defaultTargetPlatform == TargetPlatform.android) {
    //   InAppPurchaseConnection.enablePendingPurchase;
    // }
    InAppPurchaseConnection.enablePendingPurchases();

    await PushNotificationManager().init();

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    //     // statusBarColor: Colors.white, // Color for Android
    //     statusBarBrightness: Brightness.dark // Dark == white status bar -- for IOS.
    //     ));

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.dark,
    //   ),
    // );

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   // systemNavigationBarColor: Colors.blue, // navigation bar color
    //   // statusBarColor: Colors.pink,
    //   statusBarIconBrightness: Brightness.light,
    //   // statusBarBrightness:
    //   // systemNavigationBarIconBrightness: Brightness.light, // status bar color
    // ));

    // return MultiProvider(
    //     providers: [ChangeNotifierProvider(create: (_)=>prove())],
    //
    //     //From here is where you make the change
    //
    //     builder: (context, child) {
    //       var u = Provider.of<prov>(context);
    //
    //       return GetMaterialApp(
    //         theme: ThemeData(primarySwatch: u.col),
    //         title: 'Material App',
    //         home: f(),
    //       ),
    //       );

    await SentryFlutter.init(
      (options) {
        // options.dsn = 'https://d5ce319ea83a46c0b70656d84188d9a9@o529932.ingest.sentry.io/5648930';
        // options.dsn = 'https://282a90a202714c1984128bb2f90ecce0@o382931.ingest.sentry.io/5648503';
        options.dsn = dotenv.env['SENTRY'] == "true"
            ? "https://282a90a202714c1984128bb2f90ecce0@o382931.ingest.sentry.io/5648503"
            : 'https://d5ce319ea83a46c0b70656d84188d9a9@o529932.ingest.sentry.io/test';
      },
      appRunner: () => runApp(
        MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => ProviderModel())],

          //From here is where you make the change

          builder: (context, child) {
            var u = Provider.of<ProviderModel>(context);
            return GetMaterialApp(
              defaultTransition: Transition.fade,
              initialRoute: initialRouterName,
              title: dotenv.env['APP_NAME']!,
              theme: ThemeData(
                scaffoldBackgroundColor: Color(0xffe9e9e9),
                primaryColor: colorPrimary,
                accentColor: colorAccent,
                textTheme: TextTheme(
                  bodyText2: TextStyle(fontFamily: fontRegular),
                  bodyText1: TextStyle(fontFamily: fontRegular),
                ),
                appBarTheme: appBarTheme(),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              debugShowCheckedModeBanner: false,
              getPages: AppRouter.pages,
              navigatorObservers: [
                SentryNavigatorObserver(),
              ],
            );
          },
        ),
      ),
    );
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
