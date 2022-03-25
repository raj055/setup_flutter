import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../widget/theme.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  ValidatorX validator = ValidatorX();

  var userResponse;
  FocusNode memberIDFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _forgotPasswordFormKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 60.0),
                Image.asset(
                  logo,
                  width: width / 1.3,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: formField(
                          context,
                          "Member ID",
                          prefixIcon: UniconsLine.tag,
                          focusNode: memberIDFocus,
                          textInputAction: TextInputAction.next,
                          nextFocus: mobileFocus,
                          controller: _codeController,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                          onChanged: (String? value) {
                            validator.clearErrorsAt('code');
                          },
                          validator: validator.add(
                            key: 'code',
                            rules: [
                              ValidatorX.mandatory(message: 'Member id field is required'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            textContent: 'Reset Password'.toUpperCase(),
                            onPressed: () {
                              if (_forgotPasswordFormKey.currentState!.validate()) {
                                FocusScope.of(context).requestFocus(FocusNode());

                                Map sendData = {'code': _codeController.text};

                                Api.http.put('member/forgot-password', data: sendData).then((response) {
                                  GetBar(
                                    backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                    duration: Duration(seconds: 5),
                                    message: response.data['status'] ? response.data['message'] : response.data['error'],
                                  ).show();
                                  if (response.data['status']) {
                                    Timer(Duration(seconds: 5), () {
                                      Get.back();
                                    });
                                  }
                                }).catchError((error) {
                                  if (error.response.statusCode == 422) {
                                    validator.setErrors(error.response.data['error']);
                                    setState(() {
                                      validator.setErrors(error.response.data['errors']);
                                    });
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      InkWell(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Already have an account ? "),
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: colorAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Get.back();
                        },
                      ),
                    ],
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
