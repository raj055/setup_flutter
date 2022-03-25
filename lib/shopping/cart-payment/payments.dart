import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:unicons/unicons.dart';

import '../../../services/validator_x.dart';
import '../../services/api.dart';
import '../../utils/app_utils.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class Payments extends StatefulWidget {
  @override
  _PaymentsState createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  final _addressFormKey = GlobalKey<FormState>();
  List? cartProducts = [];
  List? payByList = [];
  var totalBv, amount, total, shippingCharge;
  late Razorpay razorpay;
  int? orderId;
  String? uniqueId;

  ValidatorX validator = ValidatorX();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _financialPasswordController = TextEditingController();

  List? citiesData;
  Map? stateData;
  String? cityId;
  String? myStateSelection;
  String? myCitySelection;
  String? myPaymentSelection;

  Future getProfileData() async {
    Api.http.get('member/profile').then((response) async {
      setState(() {
        _nameController.text = response.data['name'] != null ? response.data['name'] : "";
        _phoneController.text = response.data['phone'] != null ? response.data['phone'] : "";
        _emailController.text = response.data['email'] != null ? response.data['email'] : "";
        _addressController.text = response.data['address'] != null ? response.data['address'] : "";
        _pinCodeController.text = response.data['pincode'] != null ? response.data['pincode'].toString() : "";

        if (response.data['state'] != null) myStateSelection = response.data['state']['id'].toString();
        if (response.data['city'] != null) {
          cityId = response.data['city']['id'].toString();
          getCity(myStateSelection!, isLoad: true);
        }
      });
    });
  }

  @override
  void initState() {
    getProfileData();
    _fetchShippingInformation();
    _initializeRazorpay();
    super.initState();
    getState();
  }

  Widget _stateDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'state_id',
          rules: [
            ValidatorX.mandatory(message: "Select Your State"),
          ],
        ),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: text('Select State'),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          // hintText: 'Select State',
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: myStateSelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          myCitySelection = null;
          citiesData = [];
          getCity(newValue!);
          validator.clearErrorsAt('state_id');
          setState(() {
            myStateSelection = newValue;
          });
        },
        items: stateData!['states'].map<DropdownMenuItem<String>>((state) {
          return DropdownMenuItem<String>(
            value: state['id'].toString(),
            child: Text(
              state['name'].toString(),
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _cityDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'city_id',
          rules: [
            ValidatorX.mandatory(message: "Select Your City"),
          ],
        ),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: text('Select City'),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: myCitySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          validator.clearErrorsAt('city_id');
          setState(() {
            myCitySelection = newValue!;
          });
        },
        items: citiesData!.map<DropdownMenuItem<String>>((city) {
          return DropdownMenuItem<String>(
            value: city['id'].toString(),
            child: Text(
              city['name'].toString(),
            ),
          );
        }).toList(),
      ),
    );
  }

  void getCity(String newValue, {bool isLoad = false}) {
    Api.http.get('shopping/cities/$newValue').then((value) {
      setState(() {
        citiesData = value.data['cities'];
        if (isLoad) myCitySelection = cityId.toString();
      });
    });
  }

  void getState() {
    Api.http.get('shopping/states').then((response) {
      setState(() {
        stateData = response.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: (cartProducts != null && cartProducts!.length > 0)
          ? ListView(
              children: <Widget>[
                _buildProductDetail(context),
                _buildPayment(context),
                _buildAddress(context),
              ],
            )
          : Container(),
      bottomNavigationBar: (cartProducts != null && cartProducts!.length > 0) ? _buildProceedCard(context) : Container(),
    );
  }

  Widget _buildProductDetail(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Container(
              child: Column(
            children: <Widget>[
              ExpansionTile(
                title: text(
                  "Shopping Items",
                  fontFamily: fontSemibold,
                  fontSize: textSizeLargeMedium,
                ),
                children: <Widget>[
                  for (Map cartItem in cartProducts!)
                    if (cartItem.isNotEmpty) _buildCartItem(cartItem),
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }

  Widget _buildCartItem(Map cartItem) {
    return Container(
      height: 110,
      child: Row(
        children: <Widget>[
          Container(
            width: 120,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PNetworkImage(
                  cartItem['imageUrl'],
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: text(
                          cartItem['product']['name'],
                          overflow: TextOverflow.ellipsis,
                          maxLine: 2,
                          fontFamily: fontRegular,
                          fontSize: textSizeMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      text(
                        '\₹ ${cartItem['dp']}',
                        fontSize: textSizeLargeMedium,
                        fontFamily: fontMedium,
                        textColor: colorPrimaryDark,
                      ),
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // if (!cartItem['product']['onMrp'])
                      //   text(
                      //     '\₹ ${(cartItem['product']['onMrp']) ? cartItem['product']['dp'] : cartItem['product']['mrp']}',
                      //     fontSize: textSizeMedium,
                      //     decoration: TextDecoration.lineThrough,
                      //   ),
                    ],
                  ),
                  text(
                    'Qty : ${cartItem['selected_qty']}',
                    fontSize: textSizeSMedium,
                    textColor: green,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayment(context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Sub Total",
              ),
              text(
                "\₹ $amount",
              ),
            ],
          ),
          Divider(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     text(
          //       "Shipping Charge",
          //       textColor: green,
          //     ),
          //     text(
          //       "\₹ $shippingCharge",
          //       textColor: green,
          //     ),
          //   ],
          // ),
          // Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Total Amount",
                textColor: red,
                fontSize: textSizeLargeMedium,
              ),
              text(
                "\₹ $total",
                textColor: red,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Form(
        key: _addressFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: text(
                'Address',
                textColor: Colors.black,
                fontSize: 18.0,
                fontweight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Name',
              prefixIcon: UniconsLine.user,
              controller: _nameController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
              validator: validator.add(
                key: 'name',
                rules: [
                  ValidatorX.mandatory(message: "Name field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('name');
              },
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Mobile',
              prefixIcon: UniconsLine.phone,
              controller: _phoneController,
              maxLength: 10,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
              validator: validator.add(
                key: 'phone',
                rules: [
                  ValidatorX.mandatory(message: "Mobile field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('phone');
              },
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Email',
              prefixIcon: UniconsLine.mailbox,
              controller: _emailController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -,]'))],
              validator: validator.add(
                key: 'email',
                rules: [],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('email');
              },
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Address',
              prefixIcon: UniconsLine.home,
              controller: _addressController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ]'))],
              validator: validator.add(
                key: 'address',
                rules: [
                  ValidatorX.mandatory(message: "Address field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('address');
              },
            ),
            SizedBox(height: 10.0),
            if (stateData != null) _stateDropdown(),
            SizedBox(height: 10),
            if (citiesData != null) _cityDropdown(),
            SizedBox(height: 10),
            formField(
              context,
              'Pin Code',
              prefixIcon: UniconsLine.location_pin_alt,
              controller: _pinCodeController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
              validator: validator.add(
                key: 'pincode',
                rules: [
                  ValidatorX.mandatory(message: "Pin Code field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('pincode');
              },
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: DropdownButtonFormField<String>(
                isDense: true,
                isExpanded: true,
                validator: validator.add(
                  key: 'payment_type',
                  rules: [
                    ValidatorX.mandatory(message: "Select Your Payment Method"),
                  ],
                ),
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: text(
                    'Select Payment Method',
                    fontSize: textSizeMedium,
                    textColor: textColorPrimary.withOpacity(0.7),
                    fontFamily: fontMedium,
                  ),
                ),
                value: myPaymentSelection,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: white, width: 0.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: white, width: 0.0),
                  ),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                  // hintText: 'Select State',
                  filled: true,
                  fillColor: Color(0xFFf7f7f7),
                  hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
                ),
                onChanged: (String? newValue) {
                  validator.clearErrorsAt('payment_type');
                  setState(() {
                    myPaymentSelection = newValue!;
                  });
                },
                items: payByList!.map<DropdownMenuItem<String>>((paymentMode) {
                  return DropdownMenuItem<String>(
                    value: paymentMode['id'].toString(),
                    child: Text(paymentMode['name']),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10.0),
            formField(
              context,
              'Transaction Password',
              prefixIcon: UniconsLine.lock,
              controller: _financialPasswordController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
              validator: validator.add(
                key: 'financial_password',
                rules: [
                  ValidatorX.mandatory(message: "Transaction Password field is required"),
                ],
              ),
              onChanged: (value) {
                validator.clearErrorsAt('financial_password');
              },
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedCard(context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        color: colorAccent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          text(
            "\₹ $total",
            fontSize: textSizeLargeMedium,
            textColor: white,
            fontFamily: fontBold,
          ),
          MaterialButton(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            onPressed: () {
              if (_addressFormKey.currentState!.validate()) {
                FocusScope.of(context).requestFocus(FocusNode());
                _confirmOrder();
              }
            },
            color: colorPrimary,
            textColor: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                text(
                  "Proceed to Payment".toUpperCase(),
                  textColor: white,
                  fontFamily: fontSemibold,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: white,
                    size: 16.0,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _fetchShippingInformation() {
    Api.http.get('shopping/shipping').then((response) {
      if (response.data['status']) {
        setState(() {
          cartProducts = response.data['data']['cartDetails']['products'];
          payByList = response.data['data']['payBy'];
          if (response.data['data']['cartDetails']['totalDp'] != null) {
            amount = num.parse(response.data['data']['cartDetails']['totalDp'].toString());
          } else {
            amount = num.parse('0');
          }

          // if (response.data['data']['cartDetails']['shippingCharge'] != null) {
          //   shippingCharge = num.parse(response.data['data']['cartDetails']['shippingCharge'].toString());
          // } else {
          //   shippingCharge = num.parse('0');
          // }

          if (response.data['data']['cartDetails']['totalDp'] != null) {
            total = num.parse(response.data['data']['cartDetails']['totalDp'].toString());
          } else {
            total = num.parse('0');
          }
        });
        int outOfStockCount = 0;
        cartProducts!.forEach((product) {
          if (product['outOfStock']) {
            outOfStockCount++;
          }
        });
        if (outOfStockCount > 0) {
          AppUtils.showErrorSnackBar('One or more iytem from your cart has been out of stock');
          Future.delayed(Duration(seconds: 3), () {
            Get.back();
            Get.back(result: false);
          });
        }
      }
    });
  }

  void _confirmOrder() {
    Map sendData = {
      "name": _nameController.text,
      "phone": _phoneController.text,
      "email": _emailController.text,
      "address": _addressController.text,
      "state_id": myStateSelection,
      "city_id": myCitySelection,
      "pincode": _pinCodeController.text,
      "payment_type": myPaymentSelection,
      "financial_password": _financialPasswordController.text,
    };

    Api.http.post('shopping/shipping/order-confirm', data: sendData).then((response) {
      if (response.data['status']) {
        orderId = response.data['order']['id'];
        uniqueId = response.data['order']['unique_id'];

        if (myPaymentSelection == "2") {
          _proceedForRazorPay(response.data);
        } else {
          Get.toNamed('/shopping-thanks', arguments: orderId);
        }
      } else {
        AppUtils.showErrorSnackBar(response.data['data']);
      }
    }).catchError((error) {
      if (error.response.statusCode == 422) {
        setState(() {
          validator.setErrors(error.response.data['errors']);
        });
      } else {
        GetBar(
          duration: Duration(seconds: 5),
          message: error.response.data['error'],
          backgroundColor: Colors.red,
        ).show();
      }
    });
  }

  void _proceedForRazorPay(Map data) {
    print("Razerpay data $data");
    var options = {
      "key": data['key'],
      "amount": data['cartTotal'],
      "name": data['name'],
      "description": data['description'],
      "prefill": {"contact": data['order']['phone'], "email": data['order']['email']},
      "external": {
        "wallets": ["paytm"]
      },
      'theme': {'color': data['colorCode']},
      'notes': {'order_id': data['order']['order_no']},
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _initializeRazorpay() {
    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void onPaymentSuccess(PaymentSuccessResponse response) {
    String? paymentId = response.paymentId;
    _razorPayResponse(paymentId!);
  }

  void onErrorFailure(PaymentFailureResponse response) {
    Get.toNamed('shopping-thanks', arguments: orderId);
  }

  void onExternalWallet(ExternalWalletResponse response) {}

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void _razorPayResponse(String paymentId) {
    Api.http.post('shopping/shipping/payment-process', data: {
      "order": uniqueId,
      "transaction_id": paymentId,
    }).then((response) {
      if (response.data['status']) {
        Get.toNamed('shopping-thanks', arguments: orderId);
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }
}