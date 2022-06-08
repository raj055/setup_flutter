import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import '../../push_notification.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/theme.dart';

class Otp extends StatefulWidget {
  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final _otpFormKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  Map<String, dynamic>? _errors = {};
  Translator? translator;
  String? mobileNumber;
  String? emailId;
  String? countryId;
  String? systemKey;
  String? pCode;
  String? fcmToken;

  Future<String>? signCode;
  int reSendCount = 0;

  late Timer _timer;
  int? _start;
  // int _startEmail = 300;

  int _otpCodeLength = 6;
  String _otpCode = "";

  Map? otpDetails;

  String? appSignature;

  String? validateOTP(String value) {
    if (value.length != 6)
      return 'OTP must be of 6 digit';
    else if (_errors != null && _errors!.containsKey('otp'))
      return _errors!['otp'][0];
    else
      return null;
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  String? deviceId;

  @override
  void initState() {
    otpDetails = Get.arguments;
    setState(() {
      otpDetails!['type'] == "Number" ? _start = 120 : _start = 300;
      mobileNumber = otpDetails!["otpDetails"]["mobile"].toString();
      emailId = otpDetails!["otpDetails"]["email"].toString();
      countryId = otpDetails!["otpDetails"]["country_id"].toString();
      systemKey = otpDetails!["otpDetails"]["system_key"].toString();
      pCode = otpDetails!["promoCode"];
      appSignature = otpDetails!["appSignature"];
    });
    PushNotificationManager.fcm.getToken().then((value) {
      setState(() {
        fcmToken = value;
      });
    });
    _listenOtp();
    startTimer();

    super.initState();
  }

  void _listenOtp() async {
    deviceId = await _getId();
    await SmsAutoFill().listenForCode;
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        if (_start! < 1) {
          timer.cancel();
        } else {
          _start = _start! - 1;
        }
      }),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: FadeAnimation(
          0.8,
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: 50.0),
                text(
                  Translator.get('We have sent you an OTP'),
                  fontSize: textSizeNormal,
                  textColor: white,
                  fontFamily: fontSemibold,
                ),
                SizedBox(height: 5.0),
                text(
                  mobileNumber != ""
                      ? "${Translator.get('enter the 6 digit OTP sent on')}  $mobileNumber  ${Translator.get('to proceed')}"
                      : "${Translator.get('enter the 6 digit OTP sent on')}  $emailId  ${Translator.get('to proceed')}",
                  textColor: white,
                  isLongText: true,
                  fontSize: textSizeSMedium,
                ),
                SizedBox(height: 25.0),
                // _otpField(context),
                _otpAutoFetch(context),
                SizedBox(height: 15.0),
                FadeAnimation(
                  1.2,
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _start == 0
                            ? GestureDetector(
                                child: Text(
                                  'Resend',
                                  style: TextStyle(color: white, fontSize: textSizeMedium),
                                ),
                                onTap: () {
                                  if (reSendCount < 3) {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    Api.http.post(
                                      'resend-otp',
                                      data: {
                                        "mobile": mobileNumber,
                                        "email": emailId,
                                        'appSignature': appSignature,
                                      },
                                    ).then(
                                      (response) async {
                                        GetBar(
                                          backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                          duration: Duration(seconds: 5),
                                          message: response.data['message'],
                                        ).show();
                                        if (response.data['status']) {
                                          if (mounted) {
                                            setState(() {
                                              reSendCount++;
                                              otpDetails!['type'] == "Number" ? _start = 120 : _start = 300;
                                            });
                                          }
                                          startTimer();
                                        }
                                      },
                                    ).catchError(
                                      (error) {
                                        if (error.response.statusCode == 422) {
                                          GetBar(
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 3),
                                            message: error.response.data.containsKey('message')
                                                ? error.response.data['message']
                                                : error.response.data['errors'],
                                          ).show();
                                          setState(() {
                                            _errors = error.response.data['errors'];
                                          });
                                        } else if (error.response.statusCode == 401) {
                                          GetBar(
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 5),
                                            message: error.response.data['errors'],
                                          ).show();
                                        }
                                      },
                                    );
                                  } else {
                                    GetBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                      message: "Maximum limit reach",
                                    ).show();
                                  }
                                },
                              )
                            : Text(
                                "$_start Seconds",
                                style: TextStyle(
                                  color: white,
                                  fontSize: textSizeMedium,
                                ),
                              ),
                        GestureDetector(
                          onTap: () {
                            otpFetchApi(context);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: <Widget>[
                              text(
                                'Verify',
                                textColor: white,
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: colorPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: white,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onOtpCallBack(String otpCode, bool isAutofill) {
    // if (mounted) {
    setState(() {
      this._otpCode = otpCode;
      if (otpCode.length == _otpCodeLength && isAutofill) {
        _verifyOtpCode();
      }
    });
    // }
  }

  _verifyOtpCode() {
    otpFetchApi(context);
  }

  Widget _otpAutoFetch(BuildContext context) {
    return Form(
      key: _otpFormKey,
      autovalidate: _autoValidate,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFieldPin(
                borderStyeAfterTextChange: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                filledColor: white,
                codeLength: _otpCodeLength,
                boxSize: 40,
                filledAfterTextChange: true,
                borderStyle: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                onOtpCallback: (code, isAutofill) => _onOtpCallBack(code, isAutofill),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void otpFetchApi(BuildContext context) {
    setState(() {
      _autoValidate = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    if (_otpFormKey.currentState!.validate() && _otpCode != null && _otpCode.length == 6) {
      Map sendData = {
        "country_id": countryId,
        "email": emailId,
        "mobile": mobileNumber,
        "otp": _otpCode,
        "promo_code": pCode,
        "fcm_token": fcmToken,
        "device_id": deviceId,
      };

      Api.http.post('user-authenticate', data: sendData).then(
        (response) async {
          if (response.data['status']) {
            SharedPreferences? prefs = await SharedPreferences.getInstance();
            prefs.setBool("isLoggedIn", true);

            await Auth.login(
              user: response.data['user'],
              token: response.data['token'],
              currentPackage: response.data['current_package'],
              packages: response.data['packages'],
              cep: response.data['cep'],
              profile: response.data['profile'],
            );

            await Auth.setCurrentPackage(
              package: response.data["current_package"],
            );

            if (response.data['profile']) {
              if (Auth.user()!['member']['package_id'] == 1) {
                Get.offAllNamed('guest-dashboard');
              } else {
                Get.offAllNamed('home');
              }
            } else {
              Get.offAllNamed('profile-update');
            }
          } else {
            GetBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              message: response.data['message'],
            ).show();
          }
        },
      ).catchError(
        (error) {
          if (error.response.statusCode == 422) {
            setState(() {
              _errors = error.response.data['errors'];
              GetBar(
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
                message: error.response.data['errors']['otp'][0],
              ).show();
            });
          } else if (error.response.statusCode == 401) {
            GetBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              message: error.response.data['errors'],
            ).show();
          }
        },
      );
    } else {
      GetBar(
        message: "Numbers only allowed",
        duration: Duration(seconds: 3),
      ).show();
    }
  }
}
