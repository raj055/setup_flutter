import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart' hide Response;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../services/CountCtl.dart';
import '../../services/api.dart';
import '../../services/storage.dart';
import '../../services/translator.dart';
import '../../utils/dotted_border.dart';
import '../../widget/theme.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic> _errors = {};
  Translator? translator;
  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  TextEditingController _couponCodeController = TextEditingController();
  List? cartData = [];
  int cartTotal = 0;
  int _amount = 0;
  int _totalCouponDiscount = 0;
  Future? _future;
  String? paymentLink;
  List _localCartData = [];
  List cartDetail = [];
  List cartIds = [];
  bool _autoValidate = false;
  GlobalKey<FormState> _couponFormKey = GlobalKey<FormState>();
  bool _viewDiscount = false;

  late Razorpay razorpay;
  String? orderId;

  String? couponCode;

  @override
  void initState() {
    _future = getData();
    _initializeRazorpay();
    super.initState();
  }

  Future getData() {
    return Storage.get('cart').then(
      (res) {
        if (res != null) {
          _localCartData = res;
          Map sendData = {"cart": res};
          return Api.http.post('cart', data: sendData).then(
            (response) {
              if (response != null) {
                setState(() {
                  cartData = response.data['cartDetails'];
                  cartTotal = response.data['total'];
                  _amount = response.data['total'];

                  cartIds = cartData!.map((item) {
                    return {
                      "id": item['id'],
                    };
                  }).toList();
                });
              }
              return response.data;
            },
          ).catchError(
            (error) {},
          );
        } else {
          cartData = [];
          return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasError && _localCartData.length == 0 && cartData!.length <= 0) {
          return buildNoProductWidget(context);
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: colorPrimary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${Translator.get('My')}${Translator.get('Cart')}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(
                  '${cartData!.length} ${cartData!.length == 1 ? "Item" : "Items"}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ListView.builder(
                    itemCount: cartData!.length,
                    itemBuilder: (context, index) {
                      // cartIds.add(
                      //   {"id": cartData[index]['id']},
                      // );
                      return cartItems(index, context, cartData);
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: boxDecoration(
                  radius: 10,
                  showShadow: true,
                ),
                child: DottedBorder(
                  color: green,
                  strokeWidth: 1,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  radius: Radius.circular(spacing_standard_new),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(
                              Feather.percent,
                              size: 16,
                              color: red,
                            ),
                            SizedBox(width: 10),
                            text(
                              Translator.get('Apply a Coupon code'),
                              fontFamily: fontSemibold,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _couponCodeDialog(context);
                              },
                            );
                          },
                          child: text(
                            Translator.get('View Offers'),
                            textColor: green,
                            fontFamily: fontBold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _checkoutSection(context),
        );
      },
    );
  }

  Widget buildNoProductWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${Translator.get('My')}${Translator.get('Cart')}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      body: _localCartData.length == 0 && cartData != null && cartData!.length <= 0
          ? Center(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Feather.shopping_cart,
                        color: colorPrimary,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${Translator.get("Cart")}${Translator.get(' is Empty..!!')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget cartItems(int index, BuildContext context, cartData) {
    var width = MediaQuery.of(context).size.width;
    return Container(
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
              imageUrl: cartData[index]['image'] ?? "",
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
                                cartData[index]['name'],
                                maxLine: 2,
                                textColor: colorPrimaryDark,
                                fontFamily: fontSemibold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Feather.trash),
                              color: Colors.red,
                              onPressed: () {
                                deleteAlert(context, cartData, index);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            text(
                              '\₹ ' + cartData[index]['price'].toString(),
                              textColor: red,
                              fontFamily: fontSemibold,
                              fontSize: textSizeLargeMedium,
                            ),
                          ],
                        ),
                        if (_viewDiscount == true)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    "Discount : ",
                                    style: TextStyle(
                                      color: colorPrimary,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    '\₹ ' + cartData[index]['discount'].toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: colorPrimary,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
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
    );
  }

  void deleteAlert(BuildContext context, List cartData, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          content: Text(
            Translator.get("Are You Sure Want To Delete This Product?")!,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                Translator.get("YES")!,
              ),
              onPressed: () {
                setState(() {
                  cartTotal -= double.parse(cartData[index]['price'].toString()).toInt();
                  _amount -= double.parse(cartData[index]['price'].toString()).toInt();
                  CountCtl.to.decrement();
                  if (cartData.length > 1) {
                    cartData.removeAt(index);
                    _localCartData.removeAt(index);
                    Storage.set('cart', _localCartData);
                  } else {
                    cartData.removeAt(index);
                    _localCartData.removeAt(index);
                    Storage.delete('cart');
                  }
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                Translator.get("No")!,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
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
              text(Translator.get('Sub Total')),
              text("\₹ " + _amount.toString()),
            ],
          ),
          SizedBox(
            height: spacing_control,
          ),
          if (_viewDiscount == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                text(Translator.get('Coupon Discount')),
                text("\₹ " + _totalCouponDiscount.toString(), textColor: green),
              ],
            ),
          SizedBox(
            height: spacing_control,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(Translator.get('Total')),
              text(
                "\₹ " + cartTotal.toString(),
                textColor: red,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
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

  Widget _couponCodeDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0)),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image(
                    width: MediaQuery.of(context).size.width,
                    image: AssetImage('assets/images/coupon.png'),
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  decoration: boxDecoration(color: colorPrimary, showShadow: true, radius: 50),
                  child: Form(
                    key: _couponFormKey,
                    autovalidate: _autoValidate,
                    onChanged: () {
                      setState(() {
                        _errors = {};
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ]'))],
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'CouponCode is required';
                              }
                              if (_errors != null && _errors.containsKey('coupon_code')) {
                                return _errors['coupon_code'][0];
                              }
                              return null;
                            },
                            controller: _couponCodeController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(14.0),
                              isDense: true,
                              hintText: Translator.get('Enter Coupon Code'),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _autoValidate = true;
                                });

                                if (_couponFormKey.currentState!.validate()) {
                                  FocusScope.of(context).requestFocus(FocusNode());

                                  Storage.get('cart').then(
                                    (res) {
                                      if (res != null) {
                                        _localCartData = res;

                                        Map sendData = {"cart": res, "coupon_code": _couponCodeController.text};

                                        Api.http.post('cart', data: sendData).then(
                                          (response) {
                                            if (response != null) {
                                              if (response.data['couponCodeStatus'] == true) {
                                                _viewDiscount = true;
                                                setState(() {
                                                  cartData = response.data['cartDetails'];
                                                  _totalCouponDiscount = response.data['totalDiscount'];

                                                  cartTotal = response.data['total'];
                                                  couponCode = _couponCodeController.text;
                                                  _couponCodeController.clear();

                                                  Get.back();
                                                });
                                              }
                                              GetBar(
                                                backgroundColor:
                                                    response.data['couponCodeStatus'] ? Colors.green : Colors.red,
                                                duration: Duration(seconds: 3),
                                                message: response.data['message'],
                                              ).show();
                                            }

                                            return response.data;
                                          },
                                        ).catchError(
                                          (error) {
                                            GetBar(
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 3),
                                              message: error.response.data['errors']['coupon_code'][0],
                                            ).show();
                                          },
                                        );
                                      } else {
                                        cartData = [];
                                        return null;
                                      }
                                    },
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: gradientBoxDecoration(
                                  radius: 50,
                                  gradientColor1: colorPrimary,
                                  gradientColor2: colorAccent,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: white,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _couponCodeController.clear();
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Feather.x,
                  color: colorPrimaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder() {
    Api.http.post('buy-learning', data: {"learning_type": 2, 'learning': cartIds, 'coupon_code': couponCode}).then(
        (response) {
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
    cartIds.clear();
  }

  void _razorPayResponse(String? paymentId) {
    Api.http.post('razorpay-response', data: {
      "order_id": orderId,
      "transaction_id": paymentId,
    }).then((response) {
      if (response.data['status']) {
        CountCtl.to.resetCount();
        cartData!.clear();
        _localCartData.clear();
        Storage.delete('cart');
        Get.toNamed('thanks', arguments: {
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
