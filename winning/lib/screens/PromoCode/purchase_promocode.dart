import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart' hide Response;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/debouncer.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class PurchasePromoCode extends StatefulWidget {
  @override
  _PurchasePromoCodeState createState() => _PurchasePromoCodeState();
}

class _PurchasePromoCodeState extends State<PurchasePromoCode> {
  final _purchaseCodeFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  String? paymentLink;
  String? _statusValues;
  String? _changeValues;
  String? _selectValues;
  var level;
  late var _promoCodeData;
  bool _viewCouponCod = false;
  num _discount = 0;
  List? typePromoCode = [];
  List upgradeTypePromoCode = [];
  Future? _futurePromoCode;
  String? copyLink;
  num totalAmt = 0;
  num _amount = 0;
  TextEditingController _promoCodeController = TextEditingController();
  TextEditingController _couponCodeController = TextEditingController();
  final Debouncer onSearchDebouncer = Debouncer(delay: Duration(milliseconds: 500));
  Map? selectedPromoCodePackage;
  Map? promoCodePackageFromTo;
  Map? promoCodePackageAmount;
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _package = GlobalKey();
  GlobalKey _qty = GlobalKey();
  GlobalKey _price = GlobalKey();
  GlobalKey _purchase = GlobalKey();
  int? _radioValue = 1;
  List _selectedPackageList = [];

  String? expiry;

  late Razorpay razorpay;
  String? orderId;

  Future _futureBuild() {
    return Api.http.get('promo-code-types').then(
      (res) {
        _promoCodeData = res.data;
        typePromoCode = res.data["promoCodeTypes"];
        for (int i = 0; i < typePromoCode!.length - 1; i++) {
          upgradeTypePromoCode.add(typePromoCode![i]);
        }
        displayShowcase();
        return res.data;
      },
    );
  }

  @override
  void initState() {
    _futurePromoCode = _futureBuild();
    expiry = Get.arguments;
    _initializeRazorpay();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("purchasePromoCode");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("purchasePromoCode", false).then(
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

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 1:
          totalAmt = 0;
          _amount = 0;
          _changeValues = null;
          _selectValues = null;
          _statusValues = null;
          _selectedPackageList.clear();
          _promoCodeController.clear();
          break;
        case 2:
          totalAmt = 0;
          _amount = 0;
          _changeValues = null;
          _selectValues = null;
          _statusValues = null;
          _promoCodeController.clear();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Translator.get("Purchase ActivationCode")!)),
      body: FutureBuilder(
        future: _futurePromoCode,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      text(
                        Translator.get('Pricing'),
                        textColor: colorPrimary,
                        fontFamily: fontBold,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _promoCodeData['packages'].length,
                    itemBuilder: (context, index) {
                      Map packages = _promoCodeData['packages'][index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: boxDecoration(
                                radius: 10,
                                showShadow: true,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  ExpansionTile(
                                    title: text(
                                      packages['name'],
                                      textColor: colorPrimary,
                                      fontFamily: fontSemibold,
                                    ),
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Align(
                                          child: text(
                                            "${Translator.get("Activation code pricing is")} ₹ ${packages['amount']}",
                                            fontSize: textSizeMedium,
                                          ),
                                          alignment: Alignment.centerLeft,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      ListView.builder(
                                        itemCount: packages['details'].length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          var details = packages['details'][index];
                                          return Container(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: text(
                                                details['key_point'],
                                                fontSize: textSizeMedium,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                    initiallyExpanded: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  Form(
                    key: _purchaseCodeFormKey,
                    autovalidate: _autoValidation,
                    onChanged: () {},
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: boxDecoration(
                        radius: 10,
                        showShadow: true,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: text(
                                Translator.get('Select Package to Buy ActivationCode.'),
                                textColor: colorPrimary,
                                fontFamily: fontBold,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                text('Buy'),
                                Radio(
                                  value: 1,
                                  groupValue: _radioValue,
                                  onChanged: _handleRadioValueChange,
                                ),
                                text('Upgrade Package'),
                                Radio(
                                  value: 2,
                                  groupValue: _radioValue,
                                  onChanged: _handleRadioValueChange,
                                ),
                              ],
                            ),
                            if (_radioValue == 2) ...[
                              SizedBox(height: 20.0),
                              _changePackageType(),
                              if (_selectedPackageList.isNotEmpty) ...[
                                SizedBox(height: 20.0),
                                _selectUpgradePackage(),
                              ]
                            ],
                            if (_radioValue == 1) ...[
                              SizedBox(height: 20.0),
                              _changeType(),
                            ],
                            SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                key: _qty,
                                inputFormatters: [
                                  BlacklistingTextInputFormatter(RegExp(r'^[0]|[ ,.-]')),
                                ],
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return Translator.get('Please Enter Quantity ActivationCode.');
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  hintText: Translator.get('Enter code qty'),
                                  labelText: Translator.get("ActivationCode qty"),
                                ),
                                controller: _promoCodeController,
                                maxLines: 1,
                                onChanged: (text) {
                                  _viewCouponCod = false;
                                  _discount = 0;
                                  if (text.isEmpty) {
                                    setState(() {
                                      totalAmt = 0;
                                    });
                                  } else {
                                    _radioValue == 1 ? _calculatePrice() : _calculatePriceUpgrade();
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            if (_radioValue == 1)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _viewCouponCod = true;
                                  });
                                },
                                child: text(
                                  'Click to Enter CouponCode',
                                  textColor: green,
                                  fontFamily: fontSemibold,
                                ),
                              ),
                            if (_viewCouponCod == true)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextFormField(
                                        textCapitalization: TextCapitalization.characters,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffixIcon: Container(
                                            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.horizontal(
                                                right: Radius.circular(5),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context).unfocus();

                                                  Map sendData = {
                                                    'package_id': _statusValues,
                                                    'qty': _promoCodeController.text,
                                                    'coupon_code': _couponCodeController.text,
                                                  };

                                                  Api.http.post('apply-coupon-code', data: sendData).then(
                                                    (response) {
                                                      setState(
                                                        () {
                                                          if (response.data['status']) {
                                                            _discount =
                                                                double.parse(response.data['discount'].toString());

                                                            totalAmt = double.parse(response.data['total'].toString());

                                                            GetBar(
                                                              backgroundColor:
                                                                  response.data['status'] ? Colors.green : Colors.red,
                                                              duration: Duration(seconds: 3),
                                                              message: response.data['message'],
                                                            ).show();
                                                          } else {
                                                            GetBar(
                                                              backgroundColor:
                                                                  response.data['status'] ? Colors.green : Colors.red,
                                                              duration: Duration(seconds: 3),
                                                              message: response.data['message'],
                                                            ).show();
                                                          }
                                                        },
                                                      );
                                                    },
                                                  ).catchError(
                                                    (error) {
                                                      GetBar(
                                                        backgroundColor: Colors.red,
                                                        duration: Duration(seconds: 3),
                                                        message: error.response.data['errors']['coupon_code'][0],
                                                      ).show();
                                                      if (error.response.statusCode == 422) {
                                                        GetBar(
                                                          backgroundColor: Colors.red,
                                                          duration: Duration(seconds: 3),
                                                          message: error.response.data['errors']['coupon_code'][0],
                                                        ).show();
                                                      } else if (error.response.statusCode == 401) {
                                                        GetBar(
                                                          backgroundColor: Colors.red,
                                                          duration: Duration(seconds: 3),
                                                          message: error.response.data['errors'],
                                                        ).show();
                                                      }
                                                    },
                                                  );
                                                },
                                                child: text(
                                                  Translator.get('Apply'.toUpperCase()),
                                                  textColor: white,
                                                  fontFamily: fontBold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          border: OutlineInputBorder(),
                                          hintText: 'Enter Coupon Code',
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        controller: _couponCodeController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 20),
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    text(
                                      Translator.get("Price"),
                                      fontFamily: fontSemibold,
                                      fontSize: textSizeLargeMedium,
                                    ),
                                    text(
                                      "₹ " + _amount.toString(),
                                      fontFamily: fontSemibold,
                                      fontSize: textSizeLargeMedium,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                if (_viewCouponCod == true)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      text(
                                        Translator.get('Discount'),
                                        fontFamily: fontSemibold,
                                        textColor: green,
                                        fontSize: textSizeLargeMedium,
                                      ),
                                      text(
                                        " ₹ " + _discount.toString(),
                                        fontFamily: fontSemibold,
                                        textColor: green,
                                        fontSize: textSizeLargeMedium,
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 5.0),
                                Row(
                                  key: _price,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    text(
                                      Translator.get("Total"),
                                      fontFamily: fontSemibold,
                                      textColor: red,
                                      fontSize: textSizeLargeMedium,
                                    ),
                                    text(
                                      "₹ " + totalAmt.toString(),
                                      fontFamily: fontSemibold,
                                      textColor: red,
                                      fontSize: textSizeNormal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            RaisedButton(
                              key: _purchase,
                              onPressed: () {
                                FocusScope.of(context).unfocus();

                                setState(() {
                                  _autoValidation = true;
                                });

                                if (_purchaseCodeFormKey.currentState!.validate()) {
                                  _confirmOrder();
                                }
                              },
                              child: text(
                                Translator.get('Purchase Code')!.toUpperCase(),
                                textColor: white,
                                fontFamily: fontBold,
                              ),
                              color: colorPrimary,
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0),
                                side: BorderSide(
                                  color: colorPrimary,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _selectUpgradePackage() {
    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: DropdownButtonFormField(
        validator: (dynamic value) {
          if (value == null) {
            return Translator.get('Please Select Package Category.');
          }
          return null;
        },
        isDense: true,
        isExpanded: true,
        value: _changeValues,
        onChanged: (String? newValue) {
          setState(() {
            _changeValues = newValue;
          });

          typePromoCode!.map(
            (detail) {
              if (detail['id'].toString() == newValue) {
                _promoCodeData['packages'].map(
                  (package) {
                    if (package['level'] == detail['level']) {
                      promoCodePackageAmount = package;
                      _calculatePriceUpgrade();
                    }
                  },
                ).toList();
              }
            },
          ).toList();
        },
        hint: Text(Translator.get('Select Package')!),
        items: _selectedPackageList.map<DropdownMenuItem<String>>(
          (value) {
            level = value['level'];
            return DropdownMenuItem<String>(
              value: value['id'].toString(),
              child: Text(value['value']),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _changeType() {
    return Container(
      key: _package,
      padding: EdgeInsets.only(left: 10.0),
      child: DropdownButtonFormField(
        validator: (dynamic value) {
          if (value == null) {
            return Translator.get('Please Select Package Category.');
          }
          return null;
        },
        isDense: true,
        isExpanded: true,
        value: _statusValues,
        onChanged: (String? newValue) {
          setState(() {
            _statusValues = newValue;
          });

          typePromoCode!.map((detail) {
            if (detail['id'].toString() == newValue) {
              _promoCodeData['packages'].map(
                (package) {
                  if (package['level'] == detail['level']) {
                    selectedPromoCodePackage = package;
                    _calculatePrice();
                  }
                },
              ).toList();
            }
          }).toList();
        },
        hint: Text(Translator.get('Select Package')!),
        items: typePromoCode!.map<DropdownMenuItem<String>>(
          (value) {
            level = value['level'];
            return DropdownMenuItem<String>(
              value: value['id'].toString(),
              child: Text(value['value']),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _changePackageType() {
    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: DropdownButtonFormField(
        validator: (dynamic value) {
          if (value == null) {
            return Translator.get('Please Select Package Category.');
          }
          return null;
        },
        isDense: true,
        isExpanded: true,
        value: _selectValues,
        onChanged: (String? newValue) {
          setState(() {
            _selectValues = newValue;
            _selectedPackageList = [];
          });

          typePromoCode!.map(
            (detail) {
              if (detail['id'].toString() == newValue) {
                _promoCodeData['packages'].map(
                  (package) {
                    if (package['level'] == detail['level']) {
                      promoCodePackageFromTo = package;
                    }
                  },
                ).toList();
              }

              if (detail['id'] > int.parse(newValue!)) {
                setState(() {
                  _selectedPackageList.add(detail);
                });
              }
            },
          ).toList();
        },
        hint: Text(Translator.get("Select Package From")!),
        items: upgradeTypePromoCode.map<DropdownMenuItem<String>>(
          (value) {
            level = value['level'];
            return DropdownMenuItem<String>(
              value: value['id'].toString(),
              child: Text(value['value']),
            );
          },
        ).toList(),
      ),
    );
  }

  _calculatePrice() {
    setState(() {
      if (_promoCodeController.text.isNotEmpty && selectedPromoCodePackage != null) {
        totalAmt = double.parse(_promoCodeController.text) * double.parse(selectedPromoCodePackage!['amount']);

        _amount = double.parse(_promoCodeController.text) * double.parse(selectedPromoCodePackage!['amount']);
      }
    });
  }

  _calculatePriceUpgrade() {
    setState(() {
      if (_promoCodeController.text.isNotEmpty && promoCodePackageAmount != null && promoCodePackageFromTo != null) {
        double amount = double.parse(promoCodePackageFromTo!['amount']) - double.parse(promoCodePackageAmount!['amount']);
        totalAmt = double.parse(_promoCodeController.text) * amount.abs();

        _amount = double.parse(_promoCodeController.text) * amount.abs();
      }
    });
  }

  void handlePaymentGateway(String paymentLink) async {
    flutterWebViewPlugin.onBack.listen(
      (data) {
        flutterWebViewPlugin.close();
      } as void Function(Null)?,
    );

    flutterWebViewPlugin.onUrlChanged.listen(
      (String url) async {
        if (url.contains('loader')) {
          flutterWebViewPlugin.close();
          Get.back();

          Uri uri = Uri.parse(url);

          Map sendData = {
            'payment_request_id': uri.queryParameters['payment_request_id'],
          };

          await Api.http.post('pay-success', data: sendData).then(
            (res) {
              Get.toNamed('promocode_thanks', arguments: {
                "orderID": uri.queryParameters['payment_request_id'],
                "expire": expiry,
              });
              // showDialogSingleButton(
              //   context,
              //   {
              //     'status': res.data['success'] == true ? "success" : res.data['pending'] ? "pending" : "fail",
              //     'msg': res.data['message'],
              //   },
              // );
            },
          );
        }
      },
    );

    Get.dialog(
      WillPopScope(
        child: WebviewScaffold(
          url: paymentLink,
          withJavascript: true,
          appCacheEnabled: true,
          initialChild: Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          appBar: AppBar(
            title: Text(Translator.get('Payment')!),
          ),
        ),
        onWillPop: () async {
          await flutterWebViewPlugin.close();
          return Future.value(true);
        },
      ),
    );
    //     .then((value) {
    // Get.offAndToNamed('purchase_promocode');
    // });
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "package ",
        keyTarget: _package,
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
                    Translator.get("Click here for selection of package.")!,
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
        identify: "qty ",
        keyTarget: _qty,
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
                    Translator.get("Click here to enter number of units of selected package.")!,
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
        identify: "Price  ",
        keyTarget: _price,
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
                    Translator.get("You will see total payable amount here.")!,
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
        identify: "Purchase ",
        keyTarget: _purchase,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("Click here to complete your purchase.")!,
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

  void _confirmOrder() {
    Api.http.post('buy-promo-code', data: {
      'promocode_type': _radioValue,
      "from_package_id": _selectValues,
      'package_id': _radioValue == 1 ? _statusValues : _changeValues,
      'qty': _promoCodeController.text,
      'coupon_code': _couponCodeController.text
    }).then((response) {
      if (response.data['status']) {
        orderId = response.data['order_id'];
        _proceedForRazorPay(response.data);
      } else {
        GetBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          message: response.data['message'],
        ).show();
      }
    });
  }

  void _proceedForRazorPay(Map data) {
    var options = {
      "key": data['key'],
      "amount": data['amount'],
      "name": data['user_name'],
      "description": data['description'],
      "prefill": {"contact": data['mobile_no'], "email": data['email']},
      "external": {
        "wallets": ["paytm"]
      },
      'notes': {'order_id': data['order_id']},
    };

    if (options['key'] == null) {
      Get.offAllNamed('home');
    }

    try {
      razorpay.open(options);
    } catch (e) {
      print("errroe ${e.toString()}");
    }
  }

  void _initializeRazorpay() {
    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void onPaymentSuccess(PaymentSuccessResponse response) {
    _razorPayResponse(response.paymentId);
  }

  void onErrorFailure(PaymentFailureResponse response) {
    // Get.toNamed('shopping-thanks', arguments: orderId);
  }

  void onExternalWallet(ExternalWalletResponse response) {}

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void _razorPayResponse(String? paymentId) {
    Api.http.post('razorpay-response', data: {
      "order_id": orderId,
      "transaction_id": paymentId,
    }).then((response) {
      if (response.data['status']) {
        Get.toNamed('promocode_thanks', arguments: {
          "orderID": orderId,
          "expire": expiry,
        });
      } else {
        GetBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          message: response.data['message'],
        ).show();
      }
    });
  }
}
