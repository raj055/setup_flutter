import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';

import '../../../services/Vapor.dart';
import '../../../services/api.dart';
import '../../../services/translator.dart';
import '../../../widget/theme.dart';

class PersonalProfile extends StatefulWidget {
  final Function? switchTabCallback;

  const PersonalProfile({Key? key, this.switchTabCallback}) : super(key: key);

  @override
  _PersonalProfileState createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  File? _imageFile;
  late Translator translator;
  var progressString = "";
  bool uploading = false;
  final _profileFormKey = GlobalKey<FormState>();
  final format = DateFormat("dd-MM-yyyy");
  String? genderType;
  String? educationType;
  List? _educationType = [];
  late DateTime selectedDate;
  List? _genderType = [];
  String? maritalType;
  List? _maritalType = [];
  bool _autoValidation = false;
  Map<String, dynamic>? _errors;
  late Future _profileApi;
  late var profileData;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _anniversaryDateController = TextEditingController();
  TextEditingController _imageController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _profileApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.get('profile').then(
      (res) {
        setState(
          () {
            profileData = res.data;
            _genderType = profileData['genders'];
            _maritalType = profileData['maritalStatuses'];
            _educationType = profileData['qualificationTypes'];
            _anniversaryDateController.text = profileData['data']['anniversary_date'];

            _nameController.text = profileData['data']['name'];
            _dobController.text = profileData['data']['dob'];
            _cityController.text = profileData['data']['city'];
            _emailController.text = profileData['data']['email'];
            genderType = profileData['data']['gender'] != null ? profileData['data']['gender'].toString() : null;
            maritalType =
                profileData['data']['marital_status'] != null ? profileData['data']['marital_status'].toString() : null;
            educationType = profileData['data']['qualification_type'] != null
                ? profileData['data']['qualification_type'].toString()
                : null;
            _imageController.text = profileData['data']['profile_image_url'];
          },
        );

        return profileData = res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: FutureBuilder(
        future: _profileApi,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _profileFormKey,
              autovalidate: _autoValidation,
              onChanged: () {
                setState(
                  () {
                    _errors = {};
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        text(
                          Translator.get('Profile Picture'),
                          textColor: colorPrimaryDark,
                          fontFamily: fontSemibold,
                        ),
                        if (profileData != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              text(
                                Translator.get('WT App Code :'),
                              ),
                              SizedBox(width: 5),
                              text(
                                profileData['data']['code'],
                                textColor: colorPrimary,
                                fontFamily: fontBold,
                              )
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _buildProfileImage(),
                          ],
                        ),
                        if (_errors != null && _imageFile == null && _errors!.containsKey('profile_image_url'))
                          SizedBox(height: 5),
                        if (_errors != null && _imageFile == null && _errors!.containsKey('profile_image_url'))
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              _errors!['profile_image_url'][0],
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                    TextFormField(
                      inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '${Translator.get('Name')}${Translator.get(' is required')}';
                        }
                        if (_errors != null && _errors!.containsKey('name')) {
                          return _errors!['name'][0];
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: Translator.get('Enter Name'),
                        labelText: Translator.get("Name"),
                      ),
                      controller: _nameController,
                      maxLines: 1,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (value) {
                        if (_errors != null && _errors!.containsKey('email')) {
                          return _errors!['email'][0];
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: Translator.get('test@gmail.com'),
                        labelText: Translator.get('Enter Email ID'),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    SizedBox(height: 20),
                    DateTimeField(
                      controller: _dobController,
                      validator: (date) {
                        if (date == null && _dobController.text.isEmpty) {
                          return '${Translator.get('DOB')}${Translator.get(' is required')}';
                        } else {
                          return null;
                        }
                      },
                      decoration:
                          InputDecoration(border: OutlineInputBorder(), labelText: Translator.get('Date of Birth')),
                      format: format,
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                          context: context,
                          initialDate: currentValue != null ? currentValue : DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        ).then(
                          (res) {
                            if (res != null) {
                              _dobController.text = res.toLocal().toString().split(' ')[0];
                            }
                            return res!;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    if (profileData != null)
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        validator: (value) {
                          if (value == null) {
                            return '${Translator.get('Gender')}${Translator.get(' is required')}';
                          }
                          if (_errors != null && _errors!.containsKey('gender')) {
                            return _errors!['gender'][0];
                          }
                          return null;
                        },
                        value: genderType,
                        decoration: InputDecoration(
                          labelText: Translator.get('Gender'),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            genderType = newValue;
                          });
                        },
                        items: profileData['genders'].map<DropdownMenuItem<String>>(
                          (value) {
                            return DropdownMenuItem<String>(
                              value: value['id'].toString(),
                              child: Text(value['value']),
                            );
                          },
                        ).toList(),
                      ),
                    SizedBox(height: 20),
                    if (profileData != null)
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        validator: (String? value) {
                          if (value == null) {
                            return '${Translator.get('The Marital Status')}${Translator.get(' is required')}';
                          }
                          if (_errors != null && _errors!.containsKey('marital_status')) {
                            return _errors!['marital_status'][0];
                          }
                          return null;
                        },
                        value: maritalType,
                        decoration: InputDecoration(
                          labelText: Translator.get('Marital Status'),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            maritalType = newValue;
                            if (maritalType == '1') {
                              _anniversaryDateController.clear();
                            }
                          });
                        },
                        items: profileData['maritalStatuses'].map<DropdownMenuItem<String>>(
                          (value) {
                            return DropdownMenuItem<String>(
                              value: value['id'].toString(),
                              child: Text(value['value']),
                            );
                          },
                        ).toList(),
                      ),
                    if (maritalType == '1') SizedBox(height: 20),
                    if (maritalType == '1')
                      DateTimeField(
                        // validator: (date) {
                        //   if (date == null && _anniversaryDateController.text.isEmpty) {
                        //     return '${Translator.get('Anniversary date')}${Translator.get(' is required')}';
                        //   } else {
                        //     return null;
                        //   }
                        // },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: Translator.get('Anniversary date'),
                        ),
                        controller: _anniversaryDateController,
                        format: format,
                        onShowPicker: (context, currentValue) {
                          return showDatePicker(
                            context: context,
                            initialDate: currentValue != null ? currentValue : DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ).then(
                            (res) {
                              if (res != null) {
                                _anniversaryDateController.text = res.toLocal().toString().split(' ')[0];
                              }
                              return res!;
                            },
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    if (profileData != null)
                      DropdownButtonFormField<String>(
                        isDense: true,
                        isExpanded: true,
                        validator: (String? value) {
                          if (value == null) {
                            return Translator.get('Select your qualification type');
                          }
                          if (_errors != null && _errors!.containsKey('qualification_type')) {
                            return _errors!['qualification_type'][0];
                          }
                          return null;
                        },
                        value: educationType,
                        decoration: InputDecoration(
                          labelText: Translator.get('Education Qualification'),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            educationType = newValue;
                          });
                        },
                        items: profileData['qualificationTypes'].map<DropdownMenuItem<String>>(
                          (value) {
                            return DropdownMenuItem<String>(
                              value: value['id'].toString(),
                              child: Text(value['value']),
                            );
                          },
                        ).toList(),
                      ),
                    SizedBox(height: 20),
                    TextFormField(
                      inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '${Translator.get('City name')}${Translator.get(' is required')}';
                        }
                        if (_errors != null && _errors!.containsKey('city')) {
                          return _errors!['city'][0];
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: Translator.get('Enter City Name'),
                        labelText: Translator.get('City'),
                      ),
                      controller: _cityController,
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        color: colorPrimary,
                        textColor: white,
                        child: Text(
                          Translator.get('save')!.toUpperCase(),
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () async {
                          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                          setState(() {
                            _autoValidation = true;
                          });

                          if (_profileFormKey.currentState!.validate()) {
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
                            setState(
                              () {
                                uploading = false;
                              },
                            );
                            Map sendData = {
                              'name': _nameController.text,
                              'email': _emailController.text,
                              'city': _cityController.text,
                              'gender': genderType,
                              'dob': _dobController.text,
                              'marital_status': maritalType,
                              'qualification_type': educationType,
                              if (maritalType == '1') 'anniversary_date': _anniversaryDateController.text,
                              if (_imageFile != null) 'profile_image_url': profileImage,
                            };

                            Api.http.post('profile', data: sendData).then(
                              (response) {
                                if (response.data['status']) {
                                  widget.switchTabCallback!();
                                } else if (response.data['status'] && response.data['profile']) {}
                                GetBar(
                                  backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                  duration: Duration(seconds: 5),
                                  message: response.data['message'],
                                ).show();
                              },
                            ).catchError(
                              (error) {
                                if (error.response.statusCode == 422) {
                                  String? message;

                                  if (error.response.data['errors'].containsKey('occupation')) {
                                    message = error.response.data['errors']['occupation'][0];
                                  } else if (error.response.data['errors'].containsKey('work_experience_count')) {
                                    message = error.response.data['errors']['work_experience_count'][0];
                                  } else if (error.response.data['errors'].containsKey('income')) {
                                    message = error.response.data['errors']['income'][0];
                                  } else if (error.response.data['errors'].containsKey('direct_selling_experience')) {
                                    message = error.response.data['errors']['direct_selling_experience'][0];
                                  }
                                  if (message != null)
                                    GetBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                      message: message,
                                    ).show();
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
        },
      ),
    );
  }

  Future getImage(ImgSource source) async {
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

  Widget profileImage(BuildContext context, Widget image) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(spacing_standard_new),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: spacing_standard,
              margin: EdgeInsets.all(spacing_control),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: image,
            ),
          ),
          Container(
            padding: EdgeInsets.all(spacing_control),
            margin: EdgeInsets.only(bottom: 30, right: 15),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: white, border: Border.all(color: colorPrimary, width: 1)),
            child: GestureDetector(
              onTap: () {
                getImage(ImgSource.Both);
              },
              child: Icon(
                Icons.camera_alt,
                color: colorPrimary,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    Widget imageWidget;
    if (!uploading) {
      if (_imageFile == null) {
        imageWidget = CachedNetworkImage(
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
        );
        return profileImage(context, imageWidget);
      } else {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(
            _imageFile!,
            height: 120,
            width: 120,
            fit: BoxFit.fill,
          ),
        );
        return profileImage(context, imageWidget);
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
}
