import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';

class AddReview extends StatefulWidget {
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  double rating = 5;
  final TextEditingController _commentController = TextEditingController();

  final _addReviewFormKey = GlobalKey<FormState>();
  int productId = 0;

  ValidatorX validator = ValidatorX();

  bool submit = false;

  @override
  void initState() {
    productId = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(('Add Review')),
      ),
      body: review(),
    );
  }

  Widget review() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _addReviewFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: SmoothStarRating(
                  rating: rating,
                  isReadOnly: false,
                  size: 50,
                  filledIconData: Icons.star,
                  // halfFilledIconData: Icons.star_half,
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
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ,-]'))],
                controller: _commentController,
                maxLines: 6,
                validator: validator.add(
                  key: 'review',
                  rules: [
                    ValidatorX.mandatory(),
                  ],
                ),
                onChanged: (value) {
                  validator.clearErrorsAt('review');
                },
                decoration: InputDecoration(
                  hintText: ('Your thoughts'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              submit != true
                  ? CustomButton(
                      textContent: 'Submit',
                      onPressed: () {
                        if (_addReviewFormKey.currentState!.validate()) {
                          submit = true;
                          FocusScope.of(context).requestFocus(FocusNode());
                          Map sendData = {
                            "product_id": productId,
                            'rating': rating,
                            'review': _commentController.text,
                          };

                          if (rating > 0) {
                            Api.http.post('shopping/review/store', data: sendData).then((response) {
                              GetBar(
                                backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                duration: Duration(seconds: 3),
                                message: response.data['message'],
                              ).show();

                              if (response.data['status']) {
                                Timer(Duration(seconds: 3), () {
                                  Get.back();
                                });
                              } else {
                                setState(() {
                                  submit = false;
                                });
                              }
                            }).catchError(
                              (error) {
                                setState(() {
                                  submit = false;
                                });
                                if (error.response.statusCode == 422) {
                                  validator.setErrors(error.response.data['errors']);
                                }
                              },
                            );
                          } else {
                            AppUtils.showErrorSnackBar("Select Rating");
                          }
                        }
                      },
                    )
                  : Center(child: CircularProgressIndicator())
            ],
          ),
        ),
      ),
    );
  }
}
