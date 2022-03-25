import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../../services/auth.dart';
import '../../../../services/size_config.dart';
import '../../../../utils/app_utils.dart';
import '../../../services/api.dart';
import '../../../services/validator_x.dart';
import '../../../widget/theme.dart';

class QRView extends StatefulWidget {
  const QRView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  final _qrCodeFormKey = GlobalKey<FormState>();
  ValidatorX validator = ValidatorX();

  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _vendorCodeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? qrData;
  late Map mapData;

  @override
  void initState() {
    qrData = Get.arguments;
    mapData = json.decode(qrData!);

    _vendorNameController.text = mapData['name'].toString();
    _vendorCodeController.text = mapData['code'].toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Payment')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _qrCodeFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                floatingInput(
                  'Vendor Name',
                  controller: _vendorNameController,
                  readonly: true,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
                  validator: validator.add(
                    key: 'name',
                    rules: [
                      ValidatorX.mandatory(message: "Vendor name field is required"),
                    ],
                  ),
                  onChanged: (value) {
                    validator.clearErrorsAt('name');
                  },
                ),
                SizedBox(height: 10.0),
                floatingInput(
                  'Vendor ID',
                  controller: _vendorCodeController,
                  readonly: true,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
                  validator: validator.add(
                    key: 'code',
                    rules: [
                      ValidatorX.mandatory(message: "Vendor id field is required"),
                    ],
                  ),
                  onChanged: (value) {
                    validator.clearErrorsAt('code');
                  },
                ),
                SizedBox(height: 10.0),
                floatingInput(
                  'Amount',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[- ,]'))],
                  validator: validator.add(
                    key: 'amount',
                    rules: [
                      ValidatorX.mandatory(message: "Amount field is required"),
                    ],
                  ),
                  onChanged: (value) {
                    validator.clearErrorsAt('amount');
                  },
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton(
                    textContent: 'Pay',
                    onPressed: () async {
                      if (_qrCodeFormKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());

                        Map sendData = {
                          'vendor_id': mapData['id'],
                          'total': _amountController.text,
                        };

                        Api.http.post('shopping/offline-store/store', data: sendData).then((response) async {
                          GetBar(
                            backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                            duration: Duration(seconds: 3),
                            message: response.data['status'] ? response.data['message'] : response.data['message'],
                          ).show();
                          if (response.data['status']) {
                            Timer(Duration(seconds: 3), () {
                              double rating = 5;
                              showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                context: context,
                                isDismissible: false,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Container(
                                        height: h(30.0),
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              text(
                                                'Rate this vendor',
                                                fontSize: 17.0,
                                                fontweight: FontWeight.w600,
                                              ),
                                              SizedBox(height: 10.0),
                                              Container(
                                                child: SmoothStarRating(
                                                  rating: rating,
                                                  isReadOnly: false,
                                                  size: 40,
                                                  filledIconData: Icons.star,
                                                  defaultIconData: Icons.star_border,
                                                  allowHalfRating: false,
                                                  starCount: 5,
                                                  spacing: 2.0,
                                                  onRated: (value) {
                                                    setState(() {
                                                      rating = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              CustomButton(
                                                textContent: 'Submit',
                                                onPressed: () {
                                                  Map sendData = {
                                                    "vendor_id": mapData['id'],
                                                    'rating': rating,
                                                    'member_id': Auth.memberId(),
                                                  };

                                                  if (rating > 0) {
                                                    Api.http.post('shopping/vendor-review/store', data: sendData).then((response) {
                                                      GetBar(
                                                        backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                                        duration: Duration(seconds: 3),
                                                        message: response.data['message'],
                                                      ).show();

                                                      if (response.data['status']) {
                                                        Timer(Duration(seconds: 3), () {
                                                          Get.offAllNamed('/ecommerce');
                                                          Get.toNamed('/dashboard');
                                                        });
                                                      }
                                                    }).catchError(
                                                      (error) {
                                                        if (error.response.statusCode == 422) {
                                                          validator.setErrors(error.response.data['errors']);
                                                        }
                                                      },
                                                    );
                                                  } else {
                                                    AppUtils.showErrorSnackBar("Select Rating");
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            });
                          }
                        }).catchError((error) {
                          if (error.response.statusCode == 401 || error.response.statusCode == 403) {
                            GetBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 5),
                              message: error.response.data['message'],
                            ).show();
                          }
                          if (error.response.statusCode == 422) {
                            setState(() {
                              validator.setErrors(error.response.data['errors']);
                            });
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
