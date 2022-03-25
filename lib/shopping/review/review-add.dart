import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../services/api.dart';
import '../../../services/validator_x.dart';
import '../../../utils/app_utils.dart';
import '../../../widget/theme.dart';

class ReviewAdd extends StatefulWidget {
  const ReviewAdd({Key? key}) : super(key: key);

  @override
  _ReviewAddState createState() => _ReviewAddState();
}

class _ReviewAddState extends State<ReviewAdd> {
  num rating = 5;
  final TextEditingController _commentController = TextEditingController();

  final _addReviewFormKey = GlobalKey<FormState>();
  Map? product;

  ValidatorX validator = ValidatorX();

  bool submit = false;

  @override
  void initState() {
    product = Get.arguments;
    print("product $product");
    if (product!['product']["review"] != null) {
      rating = product!['product']["review"]["rating"];
      _commentController.text = product!['product']["review"]["review"];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: text(
          product!['editType'] ? 'Edit Review' : 'Add Review',
          textColor: Colors.black,
        ),
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
                  rating: rating.toDouble(),
                  isReadOnly: false,
                  size: 45,
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
                      textContent: product!['editType'] ? 'Update' : 'Submit',
                      onPressed: () {
                        if (_addReviewFormKey.currentState!.validate()) {
                          submit = true;
                          FocusScope.of(context).requestFocus(FocusNode());
                          Map sendData = {
                            "product_id": product!['product']['id'],
                            'rating': rating,
                            'review': _commentController.text,
                          };

                          if (rating > 0) {
                            Api.http.post(product!['editType'] ? 'shopping/review/update' : 'shopping/review/store', data: sendData).then((response) {
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
                  : Center(),
            ],
          ),
        ),
      ),
    );
  }
}
