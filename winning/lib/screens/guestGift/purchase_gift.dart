import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class PurchaseGift extends StatefulWidget {
  @override
  _PurchaseGiftState createState() => _PurchaseGiftState();
}

class _PurchaseGiftState extends State<PurchaseGift> {
  late Razorpay razorpay;
  String? orderId;

  Map? learningData;

  List learningIds = [];
  List userIds = [];
  num? amount;

  @override
  void initState() {
    learningData = Get.arguments;

    learningIds.add({"id": learningData!['learning']['id']});
    userIds.add({"id": learningData!['learning']['id']});

    amount = double.parse(learningData!['learning']['gift_price']) * learningData!['members'].length;

    _initializeRazorpay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Gift'),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: boxDecoration(radius: 10, showShadow: true),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: learningData!['learning']['image'] ?? "",
                width: width / 3,
                height: width / 4.0,
                imageBuilder: (context, imageProvider) => Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: width - (width / 3) - 35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: text(
                                  learningData!['learning']['name'],
                                  maxLine: 2,
                                  textColor: colorPrimaryDark,
                                  fontFamily: fontSemibold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              text(
                                '\₹ ' + learningData!['learning']['gift_price'].toString(),
                                textColor: red,
                                fontFamily: fontSemibold,
                                fontSize: textSizeLargeMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.all(0),
        ),
      ),
      bottomNavigationBar: _checkoutSection(context),
    );
  }

  Widget _checkoutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text(Translator.get('Payment Summary'), fontFamily: fontBold, textAllCaps: true),
          SizedBox(
            height: spacing_control,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(Translator.get('Total')),
              text("\₹ " + amount.toString()),
            ],
          ),
          SizedBox(
            height: spacing_middle,
          ),
          RaisedButton(
            onPressed: () {
              _confirmOrder();
            },
            child: Container(
              width: double.infinity,
              child: text(
                'Process to Pay',
                textColor: white,
                textAllCaps: true,
                fontFamily: fontSemibold,
                isCentered: true,
              ),
            ),
            color: colorPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
          )
        ],
      ),
    );
  }

  void _confirmOrder() {
    Api.http.post('buy-learning', data: {
      "learning_type": 1,
      'learning': learningIds,
      "users": learningData!['members'],
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
        Get.toNamed('thanks-page-gift', arguments: {
          "orderID": orderId,
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
