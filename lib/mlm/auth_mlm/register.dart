import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';

import '../../../services/Vapor.dart';
import '../../../services/size_config.dart';
import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../widget/theme.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _registerFormKey = GlobalKey<FormState>();

  ValidatorX validator = ValidatorX();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _sponsorIdController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nomineeController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _gstController = TextEditingController();
  TextEditingController _shopNameController = TextEditingController();
  TextEditingController _pinCodeController = TextEditingController();

  bool isRemember = false;
  bool isVendor = false;
  List? citiesData;
  Map? stateData;
  String? cityId;
  String? myStateSelection;
  String? categorySelection;
  String? subCategorySelection;
  String? countryCode;
  String? myCitySelection;
  int _sideVal = 1;

  List categoryList = [];
  List subCategoryList = [];

  String sponsorName = '';
  bool isSponsorName = false;
  final format = DateFormat("dd-MM-yyyy");
  String? termCondition;
  String? sponsorId;

  Future getRegister() async {
    return await Api.http.get('member/terms-conditions').then((response) async {
      setState(() {
        termCondition = response.data['termsCondition'];
        sponsorId = response.data['sponsorCode'];
        _sponsorIdController.text = sponsorId!;
      });
      return response.data;
    });
  }

  @override
  void initState() {
    getRegister();
    getSubCategory();
    super.initState();
    getState();
  }

  void getSubCategory() {
    Api.http.get("shopping/category").then((response) {
      setState(() {
        categoryList = response.data['list'];
      });

      return response.data;
    });
  }

  Widget _stateDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'state_id',
          rules: [
            ValidatorX.mandatory(message: "Select Your State"),
          ],
        ),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: text('Select State'),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          // hintText: 'Select State',
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: myStateSelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          myCitySelection = null;
          citiesData = [];
          getCity(newValue!);
          validator.clearErrorsAt('state_id');
          setState(() {
            myStateSelection = newValue;
          });
        },
        items: stateData!['states'].map<DropdownMenuItem<String>>((state) {
          return DropdownMenuItem<String>(
            value: state['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                state['name'].toString(),
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _cityDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'city_id',
          rules: [
            ValidatorX.mandatory(message: "Select Your City"),
          ],
        ),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: text('Select City'),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: myCitySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          validator.clearErrorsAt('city_id');
          setState(() {
            myCitySelection = newValue!;
          });
        },
        items: citiesData!.map<DropdownMenuItem<String>>((city) {
          return DropdownMenuItem<String>(
            value: city['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                city['name'].toString(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void getCity(String newValue, {bool isLoad = false}) {
    Api.http.get('shopping/cities/$newValue').then((value) {
      setState(() {
        citiesData = value.data['cities'];
        if (isLoad) myCitySelection = cityId.toString();
      });
    });
  }

  void getState() {
    Api.http.get('shopping/states').then((response) {
      setState(() {
        stateData = response.data;
      });
    });
  }

  bool uploadingImage1 = false;
  bool uploadingImage2 = false;
  bool uploadingImage3 = false;
  bool uploadingImage4 = false;

  String progressStringImage1 = "";
  String progressStringImage2 = "";
  String progressStringImage3 = "";
  String progressStringImage4 = "";

  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;

  Future getImage1(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image1 = File(image.path);
    });
  }

  Future getImage2(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image2 = File(image.path);
    });
  }

  Future getImage3(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image3 = File(image.path);
    });
  }

  Future getImage4(ImgSource source) async {
    PickedFile image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
      barrierDismissible: true,
    );
    setState(() {
      _image4 = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0XFFF6F7F9),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFFF2F5F9), Color(0xFFB4C5D1)],
                ),
              ),
              alignment: Alignment.bottomLeft,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Form(
                    key: _registerFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            logo,
                            width: width / 1.3,
                          ),
                        ),
                        // SizedBox(height: 30),
                        SizedBox(height: 20),
                        formField(
                          context,
                          'Name',
                          prefixIcon: UniconsLine.user,
                          controller: _nameController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                          validator: validator.add(
                            key: 'name',
                            rules: [
                              ValidatorX.mandatory(message: "Name field is required"),
                            ],
                          ),
                          onChanged: (value) {
                            validator.clearErrorsAt('name');
                          },
                        ),
                        SizedBox(height: 10),
                        formField(
                          context,
                          'Mobile Number',
                          prefixIcon: UniconsLine.phone,
                          controller: _mobileController,
                          maxLength: 10,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
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
                          onChanged: (value) {
                            validator.clearErrorsAt('mobile');
                          },
                        ),
                        SizedBox(height: 10),
                        formField(
                          context,
                          'Email ID',
                          prefixIcon: UniconsLine.mailbox,
                          controller: _emailController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          validator: validator.add(
                            key: 'email',
                            rules: [],
                          ),
                          onChanged: (value) {
                            validator.clearErrorsAt('email');
                          },
                        ),
                        SizedBox(height: 10),
                        formField(
                          context,
                          'Sponsor ID',
                          prefixIcon: UniconsLine.arrow,
                          controller: _sponsorIdController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          validator: validator.add(
                            key: 'code',
                            rules: [
                              ValidatorX.mandatory(message: "Sponsor id is required"),
                            ],
                          ),
                          onChanged: (value) {
                            validator.clearErrorsAt('code');
                          },
                        ),

                        SizedBox(height: 10),
                        DateTimeField(
                          controller: _dobController,
                          validator: (date) {
                            if (date == null && _dobController.text.isEmpty) {
                              return 'Date of Birth is required';
                            } else if (date != null && DateTime.now().difference(date) < Duration(days: 6570)) {
                              return 'Only 18+ can join';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(spacing_standard),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(spacing_standard),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                            counterText: "",
                            filled: true,
                            fillColor: Color(0xFFf7f7f7),
                            hintText: 'Date of birth',
                            hintStyle: TextStyle(fontSize: textSizeMedium, color: textColorSecondary),
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: textColorSecondary,
                              size: 20,
                            ),
                          ),
                          format: format,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                              context: context,
                              initialDate: currentValue ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((res) {
                              if (res != null) {
                                _dobController.text = res.toLocal().toString().split(' ')[0];
                              }
                              return res;
                            });
                          },
                        ),
                        SizedBox(height: 10),
                        formField(
                          context,
                          'Address',
                          prefixIcon: UniconsLine.home,
                          controller: _addressController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                          validator: validator.add(
                            key: 'address',
                            rules: [
                              ValidatorX.mandatory(message: "Address is required"),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        if (stateData != null) _stateDropdown(),
                        if (citiesData != null) SizedBox(height: 10),
                        if (citiesData != null) _cityDropdown(),
                        SizedBox(height: 10),
                        formField(
                          context,
                          'Nominee Name',
                          prefixIcon: UniconsLine.user,
                          controller: _nomineeController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))],
                          validator: validator.add(
                            key: 'nominee_name',
                            rules: [
                              ValidatorX.mandatory(message: "Nominee name is required"),
                            ],
                          ),
                          onChanged: (String? value) {
                            validator.clearErrorsAt('nominee_name');
                          },
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          margin: EdgeInsets.only(left: 0),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                focusColor: colorPrimary,
                                activeColor: colorPrimary,
                                value: isVendor,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isVendor = value!;
                                  });
                                },
                              ),
                              text('Are you a vendor?'),
                            ],
                          ),
                        ),
                        if (isVendor) ...[
                          formField(
                            context,
                            'Shop Name',
                            prefixIcon: UniconsLine.shop,
                            controller: _shopNameController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))],
                            validator: validator.add(
                              key: 'shop_name',
                              rules: [
                                ValidatorX.mandatory(message: "Shop name is required"),
                              ],
                            ),
                            onChanged: (String? value) {
                              validator.clearErrorsAt('shop_name');
                            },
                          ),
                          SizedBox(height: 10),
                          formField(
                            context,
                            'Pin Code',
                            prefixIcon: UniconsLine.location_pin_alt,
                            controller: _pinCodeController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))],
                            validator: validator.add(
                              key: 'pincode',
                              rules: [
                                ValidatorX.mandatory(message: "Pin Code is required"),
                              ],
                            ),
                            onChanged: (String? value) {
                              validator.clearErrorsAt('pincode');
                            },
                          ),
                          SizedBox(height: 10),
                          if (categoryList.length > 0) _categoryDropdown(),
                          if (subCategoryList.length > 0) SizedBox(height: 10),
                          if (subCategoryList.length > 0) _subCategoryDropdown(),
                          SizedBox(height: 10),
                          formField(
                            context,
                            'GST Number',
                            prefixIcon: UniconsLine.user,
                            controller: _gstController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[- ,.]'))],
                            validator: validator.add(
                              key: 'gst_number',
                              rules: [],
                            ),
                            onChanged: (String? value) {
                              validator.clearErrorsAt('gst_number');
                            },
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    margin: EdgeInsets.all(spacing_control),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        if (!uploadingImage1)
                                          _image1 != null
                                              ? Image.file(
                                                  _image1!,
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                        if (uploadingImage1)
                                          Container(
                                            height: 100,
                                            width: w(40.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                CircularProgressIndicator(),
                                                SizedBox(height: 20.0),
                                                Text(
                                                  "Uploading Image: $progressStringImage1 ",
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(spacing_control),
                                    margin: EdgeInsets.only(top: 15, right: 10),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
                                    child: GestureDetector(
                                      onTap: () {
                                        getImage1(ImgSource.Both);
                                      },
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: colorPrimary,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    margin: EdgeInsets.all(spacing_control),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        if (!uploadingImage2)
                                          _image2 != null
                                              ? Image.file(
                                                  _image2!,
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                        if (uploadingImage2)
                                          Container(
                                            height: 100,
                                            width: w(40.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                CircularProgressIndicator(),
                                                SizedBox(height: 20.0),
                                                Text(
                                                  "Uploading Image: $progressStringImage2 ",
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(spacing_control),
                                    margin: EdgeInsets.only(top: 15, right: 10),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
                                    child: GestureDetector(
                                      onTap: () {
                                        getImage2(ImgSource.Both);
                                      },
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: colorPrimary,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    margin: EdgeInsets.all(spacing_control),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        if (!uploadingImage3)
                                          _image3 != null
                                              ? Image.file(
                                                  _image3!,
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                        if (uploadingImage3)
                                          Container(
                                            height: 100,
                                            width: w(40.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                CircularProgressIndicator(),
                                                SizedBox(height: 20.0),
                                                Text(
                                                  "Uploading Image: $progressStringImage3 ",
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(spacing_control),
                                    margin: EdgeInsets.only(top: 15, right: 10),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
                                    child: GestureDetector(
                                      onTap: () {
                                        getImage3(ImgSource.Both);
                                      },
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: colorPrimary,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    margin: EdgeInsets.all(spacing_control),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        if (!uploadingImage4)
                                          _image4 != null
                                              ? Image.file(
                                                  _image4!,
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: w(40.0),
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                        if (uploadingImage4)
                                          Container(
                                            height: 100,
                                            width: w(40.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                CircularProgressIndicator(),
                                                SizedBox(height: 20.0),
                                                Text(
                                                  "Uploading Image: $progressStringImage4 ",
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(spacing_control),
                                    margin: EdgeInsets.only(top: 15, right: 10),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
                                    child: GestureDetector(
                                      onTap: () {
                                        getImage4(ImgSource.Both);
                                      },
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: colorPrimary,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                        Container(
                          margin: EdgeInsets.only(left: 0),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                focusColor: colorPrimary,
                                activeColor: colorPrimary,
                                value: isRemember,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isRemember = value!;
                                  });
                                },
                              ),
                              text('I agree to the'),
                              SizedBox(width: 4),
                              GestureDetector(
                                child: text(
                                  'Terms & Condition.',
                                  textColor: colorAccent,
                                  fontFamily: fontBold,
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => Terms(term: termCondition),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        CustomButton(
                          textContent: 'Register',
                          onPressed: () async {
                            if (!isRemember) {
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: 'You need to accept terms & condition',
                              ).show();
                            } else if (_registerFormKey.currentState!.validate()) {
                              FocusScope.of(context).requestFocus(FocusNode());

                              List subImagesList = [];

                              dynamic image1;
                              dynamic image2;
                              dynamic image3;
                              dynamic image4;

                              if (_image1 != null) {
                                image1 = await Vapor.uploadRegister(
                                  _image1,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingImage1 = true;
                                        progressStringImage1 = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingImage1 = false;
                                      }
                                    });
                                  },
                                );
                              }

                              if (_image2 != null) {
                                image2 = await Vapor.uploadRegister(
                                  _image2,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingImage2 = true;
                                        progressStringImage2 = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingImage2 = false;
                                      }
                                    });
                                  },
                                );
                              }

                              if (_image3 != null) {
                                image3 = await Vapor.uploadRegister(
                                  _image3,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingImage3 = true;
                                        progressStringImage3 = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingImage3 = false;
                                      }
                                    });
                                  },
                                );
                              }

                              if (_image4 != null) {
                                image4 = await Vapor.uploadRegister(
                                  _image4,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingImage4 = true;
                                        progressStringImage4 = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingImage4 = false;
                                      }
                                    });
                                  },
                                );
                              }

                              if (image1 != null) subImagesList.add(image1);
                              if (image2 != null) subImagesList.add(image2);
                              if (image3 != null) subImagesList.add(image3);
                              if (image4 != null) subImagesList.add(image4);

                              Map sendData = {
                                'name': _nameController.text,
                                'mobile': _mobileController.text,
                                'address': _addressController.text,
                                'code': _sponsorIdController.text,
                                'email': _emailController.text,
                                'dob': _dobController.text,
                                'nominee_name': _nomineeController.text,
                                "is_vendor": isVendor,
                                "shop_name": _shopNameController.text,
                                "state_id": myStateSelection,
                                "city_id": myCitySelection,
                                "pincode": _pinCodeController.text,
                                "category_id": categorySelection,
                                "sub_category_id": subCategorySelection,
                                "gst_number": _gstController.text,
                                "sub_images": subImagesList,
                              };

                              Api.http.post('member/register', data: sendData).then((res) async {
                                if (res.data['status']) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => SuccessBox(
                                      res.data['member_id'].toString(),
                                      res.data['password'].toString(),
                                      res.data['transactionPassword'].toString(),
                                    ),
                                  );

                                  setState(() {
                                    _nameController.clear();
                                    _mobileController.clear();
                                    _addressController.clear();
                                    _sponsorIdController.clear();
                                    _emailController.clear();
                                    _dobController.clear();
                                    _nomineeController.clear();
                                  });
                                } else {
                                  GetBar(
                                    duration: Duration(seconds: 5),
                                    message: res.data['error'],
                                    backgroundColor: Colors.red,
                                  ).show();
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
                                    // _errors = error.response.data['errors'];
                                  });
                                }
                              });
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            text('Already have an account ?'),
                            SizedBox(width: 4),
                            GestureDetector(
                              child: text(
                                'Login',
                                textColor: colorAccent,
                                fontFamily: fontBold,
                              ),
                              onTap: () {
                                Get.back();
                              },
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sideVal(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          children: <Widget>[
            Radio<int>(
              value: 1,
              groupValue: _sideVal,
              onChanged: (int? value) {
                setState(() => _sideVal = value!);
              },
            ),
            text('Left'),
          ],
        ),
        Row(
          children: <Widget>[
            Radio<int>(
                value: 2,
                groupValue: _sideVal,
                onChanged: (int? value) {
                  setState(
                    () => _sideVal = value!,
                  );
                }),
            text('Right'),
          ],
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'category_id',
          rules: [
            ValidatorX.mandatory(message: "Select Category"),
          ],
        ),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: text('Select Category'),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: categorySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          validator.clearErrorsAt('category_id');
          setState(() {
            categorySelection = newValue!;
          });
        },
        items: categoryList.map<DropdownMenuItem<String>>((category) {
          return DropdownMenuItem<String>(
            onTap: () {
              setState(() {
                subCategoryList = category['subCategory'];
              });
            },
            value: category['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                category['name'].toString(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _subCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
        isExpanded: true,
        validator: validator.add(
          key: 'sub_category_id',
          rules: [],
        ),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: text('Select Sub Category'),
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: white, width: 0.0),
          ),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          filled: true,
          fillColor: Color(0xFFf7f7f7),
          // hintText: 'Select City',
          hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.black),
        ),
        value: subCategorySelection,
        iconSize: 20,
        elevation: 16,
        onChanged: (String? newValue) {
          validator.clearErrorsAt('sub_category_id');
          setState(() {
            subCategorySelection = newValue!;
          });
        },
        items: subCategoryList.map<DropdownMenuItem<String>>((subCategory) {
          return DropdownMenuItem<String>(
            value: subCategory['id'].toString(),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                subCategory['name'].toString(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Terms extends StatelessWidget {
  final String? term;

  Terms({Key? key, @required this.term}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: termsCondition(context, term),
    );
  }
}

Widget termsCondition(BuildContext context, term) {
  return Container(
    decoration: new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10.0,
          offset: const Offset(0.0, 10.0),
        ),
      ],
    ),
    width: MediaQuery.of(context).size.width,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: text(
                  'Terms & Conditions',
                  textColor: colorAccent,
                  fontFamily: fontBold,
                  fontSize: textSizeNormal,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.close,
                    color: colorAccent,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Html(
              data: term,
            ),
          ),
        ],
      ),
    ),
  );
}

class SuccessBox extends StatefulWidget {
  final String member;
  final String password;
  final String transactionPassword;

  SuccessBox(this.member, this.password, this.transactionPassword);

  @override
  _SuccessBoxState createState() => _SuccessBoxState();
}

class _SuccessBoxState extends State<SuccessBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: successBox(context, widget.member, widget.password, widget.transactionPassword),
    );
  }
}

Widget successBox(BuildContext context, String memberId, String password, String transactionPassword) {
  return Container(
    decoration: new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10.0,
          offset: const Offset(0.0, 10.0),
        ),
      ],
    ),
    width: MediaQuery.of(context).size.width,
    child: Column(
      mainAxisSize: MainAxisSize.min, // To make the card compact
      children: <Widget>[
        SizedBox(height: 20),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(shape: BoxShape.circle, color: green),
          child: Icon(
            Icons.done,
            color: white,
          ),
        ),
        SizedBox(height: 24),
        text(
          'Register Successfully',
          textColor: textColorPrimary,
          fontFamily: fontBold,
          fontSize: textSizeNormal,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 16, top: 10),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              text(
                'Member ID : $memberId',
                textColor: textColorSecondary,
                fontFamily: fontMedium,
                fontSize: textSizeMedium,
                isLongText: true,
              ),
              text(
                'Password : $password',
                textColor: textColorSecondary,
                fontFamily: fontMedium,
                fontSize: textSizeMedium,
                isLongText: true,
              ),
              text(
                'Transaction Password : $transactionPassword',
                textColor: textColorSecondary,
                fontFamily: fontMedium,
                fontSize: textSizeMedium,
                isLongText: true,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    Get.offAllNamed("/login-mlm");
                  },
                  child: Text("Ok"),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
