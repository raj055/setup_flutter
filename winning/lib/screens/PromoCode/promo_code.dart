import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class PromoCode extends StatefulWidget {
  @override
  _PromoCodeState createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  String? copyLink;
  Response? response;
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _add = GlobalKey();
  GlobalKey _redeem = GlobalKey();
  Translator? translator;

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("promoCode");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("promoCode", false).then(
        (bool success) {
          initTargets();
          Future.delayed(
            Duration(milliseconds: 500),
            () {
              showTutorial();
            },
          );
        },
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Activation Code'),
      apiFuture: (int page) async {
        return Api.httpWithoutLoader.get("promo-codes?page=$page");
      },
      showLoader: true,
      listItemBuilder: _promoCodeBuilder,
      // loadingWidgetBuilder: _buildLoadingWidget,
      appBarAction: <Widget>[
        Center(
          key: _redeem,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Get.toNamed('upgrade_package');
              },
              child: text(
                Translator.get('Redeem Code'),
                textColor: white,
              ),
            ),
          ),
        )
      ],
      floatingActionButton: FloatingActionButton(
        key: _add,
        child: const Icon(Icons.add),
        onPressed: () {
          Get.toNamed('purchase_promocode');
        },
      ),
    );
  }

  Widget _promoCodeBuilder(dynamic promoCode, int index) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FadeAnimation(
            0.9,
            Container(
              decoration: boxDecoration(
                showShadow: true,
                bgColor: white,
                radius: 10.0,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 7.5,
                vertical: 7.5,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              text(
                                promoCode["date"],
                                textColor: colorPrimaryDark,
                              ),
                            ],
                          ),
                          Divider(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Icon(
                                        Feather.slack,
                                        color: colorPrimary,
                                        size: textSizeXLarge,
                                      ),
                                    ),
                                    SizedBox(width: w(4)),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            text(
                                              promoCode['promocodeType'] == "Normal"
                                                  ? promoCode["type"] ?? ""
                                                  : promoCode["fromPackageType"],
                                              fontFamily: fontSemibold,
                                              textColor: colorPrimary,
                                            ),
                                            if (promoCode['promocodeType'] == "Upgrade")
                                              text(
                                                " - " + promoCode["type"],
                                                fontFamily: fontSemibold,
                                                textColor: colorPrimary,
                                              ),
                                          ],
                                        ),
                                        Builder(
                                          builder: (context) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    text(
                                                      promoCode["code"],
                                                      textColor: red,
                                                      fontFamily: fontSemibold,
                                                    ),
                                                    SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () {
                                                        copyLink = promoCode["code"];
                                                        Clipboard.setData(
                                                          ClipboardData(text: copyLink),
                                                        );
                                                        GetBar(
                                                          backgroundColor: Colors.green,
                                                          duration: Duration(seconds: 2),
                                                          message: Translator.get('Activation code copied')!,
                                                        ).show();
                                                      },
                                                      child: Icon(
                                                        Feather.copy,
                                                        size: 16,
                                                        color: colorPrimaryDark,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: w(2)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: promoCode['status'] == 'Un-Used'
                                      ? green
                                      : promoCode['status'] == 'Blocked'
                                          ? red
                                          : red,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: text(
                                  Translator.get(promoCode['status'] == 'Un-Used'
                                          ? 'Unused'
                                          : promoCode['status'] == 'Blocked'
                                              ? 'Blocked'
                                              : 'Used')!
                                      .toUpperCase(),
                                  // 'Blocked'
                                  textColor: white,
                                  textAllCaps: true,
                                  fontFamily: fontSemibold,
                                  fontSize: textSizeSMedium,
                                ),
                              )
                            ],
                          ),
                          Divider(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  text(
                                    "Owner",
                                    fontFamily: fontBold,
                                  ),
                                  SizedBox(height: 4),
                                  text(
                                    promoCode["ownedBy"],
                                    textColor: textColorSecondary,
                                  ),
                                ],
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Align(
                                    child: text(
                                      "Used By",
                                      fontFamily: fontBold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  text(
                                    (promoCode['status'] == 'Used') ? promoCode["usedBy"] ?? "" : "--",
                                    textColor: green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(height: 25),
                          if (promoCode['status'] == 'Used')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    text(
                                      "Used At",
                                      fontFamily: fontBold,
                                    ),
                                    SizedBox(height: 4),
                                    text(
                                      promoCode['usedAt'],
                                      textColor: colorPrimary,
                                    ),
                                  ],
                                ),
                                // SizedBox(width: 10),
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.end,
                                //   children: <Widget>[
                                //     Align(
                                //       child: text(
                                //         "Expiry Date",
                                //         fontFamily: fontBold,
                                //       ),
                                //     ),
                                //     SizedBox(height: 4),
                                //     text(
                                //       promoCode['expiryAt'] ?? "",
                                //       textColor: textColorSecondary,
                                //     ),
                                //   ],
                                // ),
                              ],
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "Redeem",
        enableOverlayTab: true,
        keyTarget: _redeem,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("Click here to redeem your code.")!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15.0,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Add",
        enableOverlayTab: true,
        keyTarget: _add,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get('Click here to purchase Activation code.')!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15.0,
      ),
    );
  }

  void showTutorial() {
    TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.black,
        paddingFocus: 5,
        opacityShadow: 0.8,
        textSkip: "SKIP",
        onClickTarget: (target) {},
        onClickOverlay: (target) {},
        onFinish: () {},
        onSkip: () {})
      ..show();
  }

  void _afterLayout(_) {
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        showTutorial();
      },
    );
  }
}
