import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class UpgradePackage extends StatefulWidget {
  @override
  _UpgradePackageState createState() => _UpgradePackageState();
}

class _UpgradePackageState extends State<UpgradePackage> {
  final _upgradePackageFormKey = GlobalKey<FormState>();
  String? promoCodeName;
  TextEditingController _promoCodeController = TextEditingController();
  bool _autoValidation = false;
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _promo = GlobalKey();
  GlobalKey _submit = GlobalKey();
  GlobalKey _click = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("upgrade");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("upgrade", false).then((bool success) {
        initTargets();
        Future.delayed(
          Duration(milliseconds: 500),
          () {
            showTutorial();
          },
        );
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('Upgrade Package')!),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: text(
                    Translator.get('Upgrade Package Request'),
                    textColor: colorPrimaryDark,
                    fontFamily: fontBold,
                    fontSize: textSizeLargeMedium,
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _upgradePackageFormKey,
                  autovalidate: _autoValidation,
                  onChanged: () {},
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                        validator: (value) => value!.isEmpty ? Translator.get("Activation Code can't be empty") : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: Translator.get('Enter Activation Code'),
                          labelText: Translator.get("Activation Code"),
                        ),
                        controller: _promoCodeController,
                        maxLines: 1,
                      ),
                      SizedBox(height: 15),
                      _sendButton(context),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('purchase_promocode');
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: Translator.get("Don't have any Activation code ? "),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: Translator.get('Click Here'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _sendButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RaisedButton(
          color: colorPrimary,
          textColor: Colors.white,
          child: text(
            Translator.get("Submit"),
            textColor: white,
            textAllCaps: true,
            fontFamily: fontBold,
          ),
          onPressed: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _autoValidation = true;
            });

            Map requestData = {
              'promo_code': _promoCodeController.text,
            };

            if (_upgradePackageFormKey.currentState!.validate())
              Api.http.post('upgrade', data: requestData).then(
                (response) async {
                  GetBar(
                    backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                    duration: Duration(seconds: 3),
                    message: response.data['message'],
                  ).show();

                  Timer(
                    Duration(seconds: 3),
                    () {
                      if (response.data['status']) {
                        Get.offAndToNamed('home');
                      }
                    },
                  );
                },
              ).catchError(
                (error) {
                  if (error.response.statusCode == 422) {
                    setState(() {});
                    GetBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      message: error.response.data['errors']['promo_code'][0],
                    ).show();
                  } else if (error.response.statusCode == 401) {
                    GetBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
                      message: error.response.data['errors'],
                    ).show();
                  }
                },
              );
          },
        ),
      ],
    );
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "Promo",
        keyTarget: _promo,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("Click here to enter your Activation code.")!,
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
        identify: "Submit",
        keyTarget: _submit,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("Click here to submit your Activation code.")!,
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
        identify: "click ",
        keyTarget: _click,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("click here to purchase Activation code.")!,
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
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 5,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      onClickTarget: (target) {},
      onClickOverlay: (target) {},
      onFinish: () {},
      onSkip: () {},
    )..show();
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
