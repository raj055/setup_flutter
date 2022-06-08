import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class RequestForBadge extends StatefulWidget {
  @override
  _RequestForBadgeState createState() => _RequestForBadgeState();
}

class _RequestForBadgeState extends State<RequestForBadge> {
  TextEditingController _imageController = TextEditingController();
  final _requestBadgeFormKey = GlobalKey<FormState>();
  String? badgeType;
  Translator? translator;
  bool _autoValidation = false;
  Map<String, dynamic>? _errors;
  File? _imageFile;
  var progressString = "";
  var badgeData;
  bool uploading = false;
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _badgeType = GlobalKey();
  GlobalKey _camera = GlobalKey();
  GlobalKey _gallery = GlobalKey();
  GlobalKey _submit = GlobalKey();

  @override
  void initState() {
    _futureBuild();
    displayShowcase();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.get('badges').then(
      (res) {
        setState(() {
          badgeData = res.data;
        });
        return badgeData;
      },
    );
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("badgeRequest");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("badgeRequest", false).then(
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
        title: Text(Translator.get('Request For Badge')!),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _requestBadgeFormKey,
          autovalidate: _autoValidation,
          onChanged: () {
            setState(() {
              _errors = {};
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                if (badgeData != null)
                  DropdownButtonFormField<String>(
                    key: _badgeType,
                    isDense: true,
                    isExpanded: true,
                    validator: (value) {
                      if (value == null) {
                        return '${Translator.get('Badge Type')}${Translator.get(' is required')}';
                      }
                      if (_errors != null && _errors!.containsKey('badge_id')) {
                        return _errors!['badge_id'][0];
                      }
                      return null;
                    },
                    value: badgeType,
                    decoration: InputDecoration(
                      labelText: Translator.get('Badge Type'),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        badgeType = newValue;
                      });
                    },
                    items: badgeData['badges'].map<DropdownMenuItem<String>>(
                      (value) {
                        return DropdownMenuItem<String>(
                          value: value['id'].toString(),
                          child: Text(value['name']),
                        );
                      },
                    ).toList(),
                  ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          await pickImage(ImgSource.Both);
                        },
                        child: CircleAvatar(
                          key: _camera,
                          child: Icon(
                            Feather.camera,
                            size: 25.0,
                          ),
                          minRadius: 25.0,
                        ),
                      ),
                      _buildProfileImage(),
                      // GestureDetector(
                      //   onTap: () async {
                      //     await _pickImageFromGallery();
                      //   },
                      //   child: CircleAvatar(
                      //     key: _gallery,
                      //     child: Icon(
                      //       Feather.image,
                      //       size: 25.0,
                      //     ),
                      //     minRadius: 25.0,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                if (_errors != null && _imageFile == null && _errors!.containsKey('image')) SizedBox(height: 5),
                if (_errors != null && _imageFile == null && _errors!.containsKey('image'))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _errors!['image'][0],
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 16),
                Text(
                  Translator.get('Upload your performance screenshot here!')!,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    key: _submit,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      Translator.get('Submit')!.toUpperCase(),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () async {
                      setState(() {
                        _autoValidation = true;
                      });

                      if (_requestBadgeFormKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        dynamic profileImage;
                        if (_imageFile != null) {
                          profileImage = await Vapor.upload(
                            _imageFile!,
                            progressCallback: (int? completed, int? total) {
                              setState(() {
                                uploading = true;
                                progressString = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                              });
                            },
                          );
                        }
                        setState(() {
                          uploading = false;
                        });
                        Map sendData = {
                          'badge_id': badgeType,
                          if (_imageFile != null) 'image': profileImage,
                        };
                        Api.http.post('request-badge', data: sendData).then(
                          (response) {
                            GetBar(
                              backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                              duration: Duration(seconds: 5),
                              message: response.data['message'],
                            ).show();
                            Timer(
                              Duration(seconds: 2),
                              () {
                                Get.offAllNamed('home');
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
                                duration: Duration(seconds: 5),
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

  Future pickImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(Feather.camera),
      galleryIcon: Icon(Feather.image),
      cameraText: text(Translator.get("From Camera")),
      galleryText: text(Translator.get("From Gallery")),
      barrierDismissible: true,
    );

    if (image != null) _imageController.text = image.path.split("/").last;

    setState(() {
      _imageFile = image;
    });
  }

  Widget _buildProfileImage() {
    if (!uploading) {
      if (_imageFile == null) {
        return CachedNetworkImage(
          height: 150,
          imageUrl: _imageController.text,
          placeholder: (context, url) => Text(
            Translator.get('Select an Image')!,
          ),
        );
      } else {
        return Image.file(
          _imageFile!,
          height: 150,
          width: 150,
          fit: BoxFit.fill,
        );
      }
    } else {
      return Container(
        height: 120.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 20.0),
            Text(
              Translator.get("Uploading Image")! + ":" + "$progressString",
            )
          ],
        ),
      );
    }
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: Translator.get("Badge type"),
        keyTarget: _badgeType,
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
                    Translator.get('Click here to select respective badge for which criteria has been achieved.')!,
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
        identify: Translator.get("Camera"),
        keyTarget: _camera,
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
                        'Click here to open your camera to take photo for evidence of completion for selected badge.')!,
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
        identify: Translator.get("Gallery"),
        keyTarget: _gallery,
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
                        'Click here to open your gallery if you have already taken an evidence of badge completion and upload it.')!,
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
        identify: Translator.get("Submit "),
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
                    Translator.get(
                        'Click here to submit your request for this badge – you will be updated once authority approves it.')!,
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
