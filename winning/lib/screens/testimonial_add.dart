import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/Vapor.dart';
import '../services/api.dart';
import '../services/auth.dart';
import '../services/translator.dart';
import '../widget/theme.dart';

class TestimonialAdd extends StatefulWidget {
  @override
  _TestimonialAddState createState() => _TestimonialAddState();
}

class _TestimonialAddState extends State<TestimonialAdd> {
  final _addTestimonialFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  Map<String, dynamic>? _errors = {};
  File? _imageFile;
  var progressString = "";
  TextEditingController _imageController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool uploading = false;
  late SharedPreferences? preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _camera = GlobalKey();
  GlobalKey _gallery = GlobalKey();
  GlobalKey _message = GlobalKey();
  GlobalKey _submit = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences!.getBool("addTestimonials");

    if (showcaseVisibilityStatus == null) {
      preferences!.setBool("addTestimonials", false).then(
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
        title: Text(Translator.get('Add Testimonial')!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _addTestimonialFormKey,
          autovalidate: _autoValidation,
          onChanged: () {
            setState(() {
              _errors = {};
            });
          },
          child: Column(
            children: <Widget>[
              Row(
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
                ],
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
              SizedBox(height: 10),
              TextFormField(
                key: _message,
                inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                controller: _descriptionController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return Translator.get('Description is required');
                  }
                  return null;
                },
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  counterText: "",
                  border: OutlineInputBorder(),
                  hintText: Translator.get("Enter your Text"),
                ),
              ),
              SizedBox(height: 10),
              Container(
                key: _submit,
                width: double.infinity,
                height: 50,
                child: RaisedButton(
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

                    if (_addTestimonialFormKey.currentState!.validate()) {
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
                        'message': _descriptionController.text,
                        if (_imageFile != null) 'image': profileImage,
                      };
                      Api.http.post('add-testimonial', data: sendData).then(
                        (response) {
                          GetBar(
                            backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                            duration: Duration(seconds: 5),
                            message: response.data['message'],
                          ).show();
                          Timer(
                            Duration(seconds: 3),
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
    );
  }

  Future pickImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(Feather.camera),
      galleryIcon: Icon(Feather.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
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
            'assets/images/users.png',
            fit: BoxFit.fill,
          ),
          // placeholder: (context, url) => Image.asset(
          //   'assets/images/users.png',
          //   fit: BoxFit.fill,
          // ),
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
              Translator.get("Uploading Image:")! + "$progressString ",
            )
          ],
        ),
      );
    }
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "Camera",
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
                    "Click here to start your camera.",
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
        identify: "Gallery",
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
                    "Click here to open your gallery to choose image.",
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
                    "Click here to write your testimonial.",
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
                    "Click here to submit your testimonial.",
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
