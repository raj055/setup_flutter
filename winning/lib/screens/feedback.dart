import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/api.dart';
import '../services/auth.dart';
import '../services/translator.dart';

class FeedBack extends StatefulWidget {
  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  static double rating = 5;
  final TextEditingController _commentController = TextEditingController();
  final _feedbackFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  Map<String, dynamic>? _errors = {};
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _starRating = GlobalKey();
  GlobalKey _message = GlobalKey();
  GlobalKey _submit = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("feedback");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("feedback", false).then(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Translator.get('FeedBack')!,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _feedbackFormKey,
          autovalidate: _autoValidation,
          onChanged: () {
            setState(() {
              _errors = {};
            });
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  key: _starRating,
                  child: SmoothStarRating(
                    rating: rating,
                    isReadOnly: false,
                    size: 50,
                    filledIconData: Icons.star,
                    halfFilledIconData: Icons.star_half,
                    defaultIconData: Icons.star_border,
                    starCount: 5,
                    allowHalfRating: false,
                    spacing: 2.0,
                    onRated: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        Translator.get('What would you like to share with us ?')!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  key: _message,
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return Translator.get('The comment field is required');
                    }
                    if (_errors != null && _errors!.containsKey('comment')) {
                      return _errors!['comment'][0];
                    }
                    return null;
                  },
                  controller: _commentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: Translator.get('Your thoughts'),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    key: _submit,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      Translator.get("Submit")!.toUpperCase(),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        _autoValidation = true;
                      });
                      if (_feedbackFormKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Map sendData = {
                          'star': rating.toInt(),
                          'comment': _commentController.text,
                        };
                        Api.http.post('feedback-create', data: sendData).then(
                          (response) {
                            GetBar(
                              backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                              duration: Duration(seconds: 3),
                              message: response.data['message'],
                            ).show();
                            Timer(
                              Duration(seconds: 2),
                              () {
                                if (Auth.currentPackage() == 1) {
                                  Get.offAllNamed('guest-dashboard');
                                } else {
                                  Get.offAllNamed('home');
                                }
                              },
                            );
                          },
                        ).catchError(
                          (error) {
                            if (error.response.statusCode == 422) {
                              setState(() {
                                _errors = error.response.data['errors'];
                              });
                            } else if (error.response.statusCode == 401) {
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: error.response.data['errors'],
                              ).show();
                            }
                          },
                        );
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

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "StarRating ",
        keyTarget: _starRating,
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
                    Translator.get(
                        "Select your satisfaction level of services offered by this application by clicking on start.")!,
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
        identify: "Message",
        keyTarget: _message,
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
                    "If you have anything to say precisely than you can enter your thoughts here.",
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
        identify: "Submit",
        keyTarget: _submit,
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
                    Translator.get("Click here to submit your feedback.")!,
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
}
