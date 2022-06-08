import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:get/get.dart' hide Response;
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/theme.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int? _countryVal;
  Translator? translator;
  final _registerMobileFormKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TextEditingController _numberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _promoCodeController = TextEditingController();
  bool? checkBoxValue = false;
  bool _visibilityPromoCode = false;
  Future? _termsApi;
  var termsCondition;

  List? countriesList = [];

  late List selectedCountries;
  String? countryCode;
  late Map selectedCountry;

  Future _futureBuildCountries() {
    return Api.http.post('countries').then(
      (res) {
        countriesList = res.data['list'];
        if (mounted) {
          setState(() {
            _countryVal = 1;
          });
        }
        return res.data;
      },
    );
  }

  String? signCode;

  String? validateMobile(String? value) {
    if (value!.length != 10)
      return Translator.get('Mobile Number must be of 10 digit');
    else
      return null;
  }

  String? validateEmail(String? value) {
    Pattern pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern as String);
    if (!regex.hasMatch(value!) || value == null)
      return 'Enter a valid email address';
    else
      return null;
  }

  @override
  void initState() {
    _termsApi = _futureBuild();
    _futureBuildCountries();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.get('terms-conditions').then(
      (res) {
        termsCondition = res.data;
        return res.data;
      },
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(Translator.get('Are you sure?')!),
            content: Text(
              Translator.get('Do you want to exit an App')!,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(Translator.get('No')!),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: Text(Translator.get('Yes')!),
              ),
            ],
          ),
        ) as Future<bool>? ??
        false as Future<bool>;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder(
        future: _termsApi,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return FocusWatcher(
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: FadeAnimation(
                  0.8,
                  Form(
                    autovalidate: _autoValidate,
                    key: _registerMobileFormKey,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(height: 50.0),
                          text(
                            _countryVal == 1
                                ? Translator.get('Give us your mobile number')
                                : Translator.get('Give us your email id'),
                            fontSize: textSizeNormal,
                            textColor: white,
                            fontFamily: fontSemibold,
                          ),
                          text(
                            _countryVal == 1
                                ? Translator.get('we need your mobile number linked to our account')
                                : Translator.get('we need your email id linked to our account'),
                            textColor: white,
                            isLongText: true,
                          ),
                          SizedBox(height: 25.0),
                          _countryField(context),
                          SizedBox(height: 15.0),
                          _countryVal == 1 ? _mobileField(context) : _emailField(context),
                          SizedBox(height: 15.0),
                          Visibility(
                            visible: _visibilityPromoCode,
                            child: _promoCodeField(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: _submitButton(context, snapshot),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mobileField(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 51,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.0),
              bottomLeft: Radius.circular(5.0),
            ),
          ),
          child: Center(
            child: Text(
              countryCode != null ? countryCode! : "+91",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            textInputAction: TextInputAction.done,
            inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9]"))],
            maxLength: 10,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.white),
            controller: _numberController,
            validator: validateMobile,
            decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.all(16.0),
              hintText: Translator.get("eg.9999999999"),
              hintStyle: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emailField(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white),
      controller: _emailController,
      validator: validateEmail,
      decoration: InputDecoration(
        counterText: "",
        contentPadding: const EdgeInsets.all(16.0),
        hintText: Translator.get("eg.test@gmail.com"),
        hintStyle: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _promoCodeField(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.white70),
      controller: _promoCodeController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16.0),
        hintText: Translator.get("Enter Activation Code"),
        hintStyle: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _countryField(BuildContext context) {
    return DropdownButtonFormField(
      iconEnabledColor: Colors.white,
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16.0),
        hintText: Translator.get("Select Country"),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      value: _countryVal,
      onChanged: ((dynamic newValue) {
        setState(
          () {
            _countryVal = newValue;
            _emailController.clear();
            _numberController.clear();
            selectedCountries = countriesList!.where((country) => country['id'] == newValue).toList();
            selectedCountry = selectedCountries[0];
            countryCode = selectedCountry['code'];
          },
        );
      }),
      items: countriesList!.map<DropdownMenuItem<int>>(
        (value) {
          return DropdownMenuItem<int>(
            value: value['id'],
            child: text(
              value['name'],
              fontFamily: fontSemibold,
            ),
          );
        },
      ).toList(),
      selectedItemBuilder: (BuildContext context) {
        String? text = Translator.get("Select Country");

        if (_countryVal != null) {
          Map selectedCountry = countriesList!.firstWhere((element) => element['id'] == _countryVal);
          text = selectedCountry['name'];
        }

        return countriesList!.map((dynamic value) {
          return Text(
            text!,
            style: TextStyle(color: white),
          );
        }).toList();
      },
    );
  }

  Widget _submitButton(BuildContext context, snapshot) {
    return FadeAnimation(
      1.2,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Checkbox(
                            value: checkBoxValue,
                            onChanged: (bool? value) {
                              setState(
                                () {
                                  checkBoxValue = value;
                                },
                              );
                            },
                          ),
                        ),
                        text(Translator.get('I agree to the'), textColor: white),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        checkBoxValue = !checkBoxValue!;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        SizedBox(width: w(1)),
                        text(
                          "${Translator.get('Terms')} & ${Translator.get('Condition')}",
                          textColor: white,
                        ),
                      ],
                    ),
                    onTap: () {
                      _buildTerms(context, snapshot);
                    },
                  ),
                ],
              )
            ],
          ),
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _autoValidate = true;
                  });

                  if (!checkBoxValue!) {
                    GetBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 5),
                      message: Translator.get('You need to accept terms & condition')!,
                    ).show();
                  } else {
                    signCode = await SmsRetrieved.getAppSignature();
                    if (_registerMobileFormKey.currentState!.validate()) {
                      FocusScope.of(context).requestFocus(FocusNode());

                      Api.http.post(
                        'check-account',
                        data: {
                          "country_id": _countryVal,
                          "email": _emailController.text,
                          'mobile': _numberController.text,
                          'promo_code': _promoCodeController.text,
                          'appSignature': signCode,
                        },
                      ).then(
                        (response) {
                          if (response.data['status']) {
                            Get.toNamed('otp', arguments: {
                              "promoCode": _promoCodeController.text,
                              "otpDetails": response.data["otp_temp_details"],
                              "appSignature": signCode,
                              "type": _numberController.text.isNotEmpty ? "Number" : "Email",
                            });
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
                            String? message;

                            if (_countryVal != null && _countryVal == 1) {
                              if (error.response.data['errors'].containsKey('mobile')) {
                                message = error.response.data['errors']['mobile'][0];
                              } else if (error.response.data['errors'].containsKey('promo_code')) {
                                message = error.response.data['errors']['promo_code'][0];
                              }
                            } else if (error.response.data['errors'].containsKey('country_id')) {
                              message = error.response.data['errors']['country_id'][0];
                            } else {
                              if (error.response.data['errors'].containsKey('promo_code'))
                                message = error.response.data['errors']['promo_code'][0];
                            }

                            GetBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              message: message!,
                            ).show();
                            setState(
                              () {
                                _visibilityPromoCode = true;
                              },
                            );
                          } else if (error.response.statusCode == 401) {
                            GetBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 5),
                              message: error.response.data['errors'],
                            ).show();
                          }
                        },
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).accentColor,
                    ),
                    child: Center(
                      child: Text(
                        "${Translator.get('Agree')} & ${Translator.get('Continue')}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  _buildTerms(BuildContext context, snapshot) {
    Get.bottomSheet(
      Container(
        height: double.infinity,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    "${Translator.get('Terms')} & ${Translator.get('Condition')}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            snapshot.data["terms_conditions"],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
