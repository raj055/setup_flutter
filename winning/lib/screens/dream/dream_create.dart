import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';
import 'package:winning_team/services/size_config.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/theme.dart';

class DreamCreate extends StatefulWidget {
  @override
  _DreamCreateState createState() => _DreamCreateState();
}

class _DreamCreateState extends State<DreamCreate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _uploadingDetailsKey = GlobalKey<FormState>();
  final format = DateFormat("dd-MM-yyyy");
  String progressString = "";
  bool uploading = false;
  File? _imageFile;
  bool _autoValidation = false;
  DateTime? selectedDate;
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _categoryVal;
  String? _categorySubVal;

  Future? _dreamApi;
  late var dreams;
  var typeCategory;

  @override
  void initState() {
    _dreamApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.post('dream-index', data: {'category_id': '1'}).then(
      (res) {
        dreams = res.data;
        typeCategory = dreams["dreamCategories"];
        return res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: this._scaffoldKey,
      appBar: AppBar(title: Text(Translator.get('Add Dream')!)),
      body: FutureBuilder(
        future: _dreamApi,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }
          return SingleChildScrollView(
            child: Form(
              key: _uploadingDetailsKey,
              autovalidate: _autoValidation,
              onChanged: () {},
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: FadeAnimation(
                      0.8,
                      Column(
                        children: <Widget>[
                          _buildDreamNameField(context),
                          SizedBox(height: 15),
                          _buildDreamImageField(context),
                          SizedBox(height: 15),
                          _buildCategoryField(context),
                          SizedBox(height: 15),
                          _buildSubCategoryField(context),
                          SizedBox(height: 15),
                          _buildTargetCalenderField(context),
                          SizedBox(height: 15),
                          _submitButton(context)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return FadeAnimation(
      1.2,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _autoValidation = true;
                  });
                  if (_uploadingDetailsKey.currentState!.validate()) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    dynamic imageDoc;
                    if (_imageFile != null) {
                      imageDoc = await Vapor.upload(
                        _imageFile!,
                        progressCallback: (int? completed, int? total) {
                          showLoadingBottomSheet(context);
                          // setState(() {
                          //   uploading = true;
                          //   progressString = ((completed / total) * 100).toStringAsFixed(0) + "%";
                          //
                          //   print("progressString $progressString");
                          // });
                        },
                      );
                    }
                    if (mounted) {
                      setState(() {
                        uploading = false;
                      });
                    }

                    Map sendData = {
                      'category_id': _categoryVal,
                      'sub_category_id': _categorySubVal,
                      'name': _nameController.text,
                      'target_date': _dateController.text,
                      if (_imageFile != null) 'image': imageDoc,
                    };

                    Api.http.post('create-dream', data: sendData).then(
                      (response) {
                        GetBar(
                          backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                          duration: Duration(seconds: 5),
                          message: response.data['message'],
                        ).show();
                        if (Auth.currentPackage() == 1) {
                          Get.offAllNamed('guest-dashboard');
                          Get.toNamed("dream-list");
                        } else {
                          Get.offAllNamed('home');
                          Get.toNamed("dream-list");
                        }
                      },
                    ).catchError(
                      (error) {
                        if (error.response.statusCode == 422) {
                          GetBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                            message: error.response.data['errors'],
                          ).show();
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).accentColor,
                    ),
                    child: Center(
                      child: Text(
                        Translator.get("Submit")!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future showLoadingBottomSheet(context) async {
    showModalBottomSheet(
      backgroundColor: Colors.white70,
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value();
          },
          child: Container(
            color: Colors.white,
            width: w(100),
            height: h(10),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(colorPrimary),
                  ),
                  text('Uploading...', textColor: Colors.black, fontFamily: fontBold)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetCalenderField(BuildContext context) {
    return Column(
      children: <Widget>[
        DateTimeField(
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            hintText: Translator.get('Select Target Date'),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          format: format,
          onShowPicker: (context, currentValue) {
            return showDatePicker(
              context: context,
              firstDate: DateTime.now().subtract(Duration(days: 0)),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100),
            ) as Future<DateTime>;
          } as Future<DateTime> Function(BuildContext, DateTime),
          controller: _dateController,
        ),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return DropdownButtonFormField(
      isDense: true,
      isExpanded: true,
      validator: (dynamic value) {
        if (value == null) {
          return Translator.get('Category is required');
        }
        return null;
      },
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
      ),
      value: _categoryVal,
      hint: Text(Translator.get('Choose Category')!),
      onChanged: ((String? newValue) {
        setState(() {
          _categoryVal = newValue;
        });
      }),
      items: typeCategory["categories"].map<DropdownMenuItem<String>>(
        (value) {
          return DropdownMenuItem<String>(
            value: value['id'].toString(),
            child: Text(value['value']),
          );
        },
      ).toList(),
    );
  }

  Widget _buildSubCategoryField(BuildContext context) {
    return DropdownButtonFormField(
      isDense: true,
      isExpanded: true,
      validator: (dynamic value) {
        if (value == null) {
          return Translator.get('Sub Category is required');
        }
        return null;
      },
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
      ),
      value: _categorySubVal,
      hint: Text(Translator.get('Choose Sub Category')!),
      onChanged: ((String? newValue) {
        setState(() {
          _categorySubVal = newValue;
        });
      }),
      items: typeCategory["subCategories"].map<DropdownMenuItem<String>>(
        (value) {
          return DropdownMenuItem<String>(
            value: value['id'].toString(),
            child: Text(value['value']),
          );
        },
      ).toList(),
    );
  }

  Widget _buildDreamNameField(BuildContext context) {
    return TextFormField(
      inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
      controller: _nameController,
      validator: (value) => value!.isEmpty ? Translator.get("Name can not be empty") : null,
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        labelText: Translator.get('Dream Name'),
        suffixIcon: Icon(
          Icons.assignment,
        ),
      ),
      maxLines: 1,
    );
  }

  Widget _buildDreamImageField(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextFormField(
                inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                readOnly: true,
                controller: _imageController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: Translator.get('Add Dream Image'),
                  suffixIcon: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ButtonBar(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.photo_camera),
                            onPressed: () async => await pickImage(ImgSource.Both),
                            tooltip: Translator.get('Shoot picture'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
}
