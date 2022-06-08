import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class RenewPackage extends StatefulWidget {
  @override
  _RenewPackageState createState() => _RenewPackageState();
}

class _RenewPackageState extends State<RenewPackage> {
  final _upgradePackageFormKey = GlobalKey<FormState>();
  String? promoCodeName;
  TextEditingController _promoCodeController = TextEditingController();
  bool _autoValidation = false;
  SharedPreferences? preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  String? code;

  @override
  void initState() {
    code = Get.arguments;
    if (code != null) {
      _promoCodeController.text = code!;
    }
    super.initState();
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
              Api.http.post('renew-package', data: requestData).then(
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
}
