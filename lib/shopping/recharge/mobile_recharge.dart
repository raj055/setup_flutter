import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../services/api.dart';
import '../../../services/validator_x.dart';
import '../../../widget/theme.dart';

class MobileRecharge extends StatefulWidget {
  @override
  _MobileRechargeState createState() => _MobileRechargeState();
}

class _MobileRechargeState extends State<MobileRecharge> {
  final _prepaidFormKey = GlobalKey<FormState>();

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _transactionPasswordController = TextEditingController();

  String? circleSelection;

  ValidatorX validator = ValidatorX();

  Map? mobileOperator;
  String? operatorSelection;

  bool passwordVisible = false;

  @override
  void initState() {
    mobileOperator = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mobile Recharge'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _prepaidFormKey,
            child: Column(
              children: <Widget>[
                _buildMobileField(context),
                SizedBox(height: 20),
                if (mobileOperator != null) ...[
                  _buildOperatorField(context),
                  SizedBox(height: 20),
                  _buildCircleField(),
                  // SizedBox(height: 20),
                  // _buildPlanField(context),
                  SizedBox(height: 20),
                ],
                _buildAmountField(context),
                SizedBox(height: 20),
                _buildTransactionPasswordField(context),
                SizedBox(height: 20),
                _buildButtonField(context),
                SizedBox(height: 10),
                text(
                  "Only Prepaid Mobile Recharge Accept.",
                  fontFamily: fontMedium,
                  textColor: grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleField() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'circle_id',
          rules: [
            ValidatorX.mandatory(message: "Select Circle"),
          ],
        ),
        hint: text('Select Circle', fontFamily: fontMedium, textColor: grey),
        decoration: InputDecoration(border: OutlineInputBorder()),
        value: circleSelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          validator.clearErrorsAt('circle_id');
          setState(() {
            circleSelection = newValue!;
          });
        },
        items: mobileOperator!['circles'].map<DropdownMenuItem<String>>((category) {
          return DropdownMenuItem<String>(
            value: category['id'].toString(),
            child: text(
              category['circle'].toString(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOperatorField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
          isDense: true,
          isExpanded: true,
          validator: validator.add(
            key: 'operator_id',
            rules: [
              ValidatorX.mandatory(message: "Select Operators"),
            ],
          ),
          hint: text('Select Operators', fontFamily: fontMedium, textColor: grey),
          decoration: InputDecoration(border: OutlineInputBorder()),
          value: operatorSelection,
          iconSize: 20,
          elevation: 16,
          onChanged: (String? newValue) {
            validator.clearErrorsAt('operator_id');
            setState(() {
              operatorSelection = newValue!;
            });
          },
          items: mobileOperator!['prepaid'].map<DropdownMenuItem<String>>((category) {
            return DropdownMenuItem<String>(
              value: category['id'].toString(),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: text(
                  category['name'].toString(),
                ),
              ),
            );
          }).toList()),
    );
  }

  Widget _buildMobileField(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
      maxLength: 10,
      validator: validator.add(
        key: 'mobile',
        rules: [
          ValidatorX.custom((value, {key}) {
            String pattern = r'[6789][0-9]{9}$';
            RegExp regExp = new RegExp(pattern);
            if (value!.length == 0) {
              return "Mobile is Required";
            } else if (value.length != 10) {
              return "Mobile number must 10 digits";
            } else if (!regExp.hasMatch(value)) {
              return "Mobile Number invalid";
            }
          })
        ],
      ),
      controller: _numberController,
      decoration: const InputDecoration(
        counterText: "",
        border: OutlineInputBorder(),
        labelText: 'Mobile Number',
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ ,-]'))],
      validator: validator.add(
        key: 'amount',
        rules: [
          ValidatorX.mandatory(message: "Amount is required"),
        ],
      ),
      maxLength: 4,
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Amount',
        prefixText: ' ₹ ',
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildTransactionPasswordField(BuildContext context) {
    return TextFormField(
      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r'[ ,.-]'))],
      validator: validator.add(
        key: 'password',
        rules: [
          ValidatorX.mandatory(message: "Transaction Password is required"),
        ],
      ),
      controller: _transactionPasswordController,
      obscureText: passwordVisible,
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
        labelText: 'Transaction Password',
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              passwordVisible = !passwordVisible;
            });
          },
          child: passwordVisible ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
        ),
      ),
      style: primaryTextStyle(
        fontFamily: fontMedium,
      ),
    );
  }

  Widget _buildButtonField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          textContent: "Proceed".toUpperCase(),
          onPressed: () {
            if (_prepaidFormKey.currentState!.validate()) {
              FocusScope.of(context).requestFocus(FocusNode());
              Map sendData = {
                'phone': _numberController.text,
                'operator_id': operatorSelection,
                'amount': _priceController.text,
                'financial_password': _transactionPasswordController.text,
                'circle_id': circleSelection,
              };

              Api.http.post('member/recharge/mobile-recharge', data: sendData).then((response) {
                GetBar(
                  backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                  duration: Duration(seconds: 3),
                  message: response.data['message'],
                ).show();

                if (response.data['status']) {
                  Timer(Duration(seconds: 3), () {
                    Get.back();
                  });
                } else {}
              }).catchError(
                (error) {
                  if (error.response.statusCode == 422) {
                    validator.setErrors(error.response.data['errors']);
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
