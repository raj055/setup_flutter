import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';

import '../../../services/CountCtl.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/validator_x.dart';
import '../../widget/theme.dart';

class LoginMLM extends StatefulWidget {
  LoginMLM({
    Key? key,
  }) : super(key: key);

  @override
  _LoginMLMState createState() => _LoginMLMState();
}

class _LoginMLMState extends State<LoginMLM> {
  final _loginFormKey = GlobalKey<FormState>();
  FocusNode memberIDFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  ValidatorX validator = ValidatorX();

  TextEditingController _codeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool passwordVisible = false;

  var arg;
  late String deviceId;

  String? fcmToken;

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  void _deviceInfo() async {
    deviceId = await _getId();
  }

  getToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    setState(() {
      fcmToken = fcmToken;
    });
    print("customerFcmToken $fcmToken");
  }

  @override
  void initState() {
    arg = Get.arguments;
    _deviceInfo();
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: whiteColor,
      body: Form(
        key: _loginFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.all(spacing_standard_new),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            logo,
                            width: width / 1.3,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: formField(
                                context,
                                "Member ID",
                                prefixIcon: UniconsLine.tag,
                                focusNode: memberIDFocus,
                                textCapitalization: TextCapitalization.characters,
                                textInputAction: TextInputAction.next,
                                nextFocus: passwordFocus,
                                controller: _codeController,
                                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
                                onChanged: (String? value) {
                                  validator.clearErrorsAt('code');
                                },
                                validator: validator.add(
                                  key: 'code',
                                  rules: [ValidatorX.mandatory(message: 'Member ID field is required')],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: formField(
                                context,
                                "Password",
                                prefixIcon: UniconsLine.lock,
                                isPassword: true,
                                isPasswordVisible: passwordVisible,
                                focusNode: passwordFocus,
                                textInputAction: TextInputAction.done,
                                controller: _passwordController,
                                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                                onChanged: (String? value) {
                                  validator.clearErrorsAt('password');
                                },
                                validator: validator.add(
                                  key: 'password',
                                  rules: [
                                    ValidatorX.mandatory(),
                                  ],
                                ),
                                suffixIconSelector: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                                suffixIcon: passwordVisible ? Icons.visibility_off : Icons.visibility,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Get.toNamed('/forget-password-mlm');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, bottom: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                text(
                                  "Forgot password ?",
                                  fontSize: textSizeMedium,
                                  textColor: colorAccent,
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              textContent: 'Login',
                              onPressed: () {
                                if (_loginFormKey.currentState!.validate()) {
                                  FocusScope.of(context).requestFocus(FocusNode());

                                  Api.http.post('member/login', data: {
                                    'code': _codeController.text,
                                    'password': _passwordController.text,
                                    'deviceId': deviceId,
                                    'fcmToken': fcmToken,
                                  }).then((response) async {
                                    if (response.data['status']) {
                                      await Auth.login(
                                        token: response.data['token'],
                                        user: response.data['member'],
                                      );

                                      if (arg != null && arg == 'justBack') {
                                        Obx(() => MLMCountCtl.to.changeCount(response.data['member']['cartCount'] ?? 0));
                                        MLMCountCtl.to.changeCount(response.data['member']['cartCount'] ?? 0);
                                        Get.back();
                                      } else {
                                        Get.offAllNamed('/ecommerce');
                                      }
                                    } else {
                                      GetBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                        message: response.data['message'],
                                      ).show();
                                    }
                                  }).catchError((error) {
                                    if (error.response.statusCode == 422) {
                                      GetBar(
                                        message: error.response.data['errors']['code'][0],
                                        duration: Duration(seconds: 3),
                                        backgroundColor: Colors.red,
                                      ).show();
                                      // setState(() {
                                      //   validator.setErrors(
                                      //       error.response.data['errors']);
                                      // });
                                    } else if (error.response.statusCode == 401) {
                                      GetBar(
                                        message: error.response.data['message'],
                                        duration: Duration(seconds: 3),
                                        backgroundColor: Colors.red,
                                      ).show();
                                    }
                                  });
                                }
                                // Get.offAllNamed("/home");
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            text("Don't have an account ?"),
                            SizedBox(width: 4),
                            GestureDetector(
                              child: text(
                                'Register',
                                textColor: colorAccent,
                                fontFamily: fontBold,
                              ),
                              onTap: () {
                                Get.toNamed('/register-mlm');
                              },
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
