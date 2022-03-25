import 'dart:async';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';

import '../../../../services/auth.dart';
import '../../../services/size_config.dart';
import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/validator_x.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _gender = 0;
  Map? userResponse;
  bool uploading = false;
  File? _image;
  String progressString = "";
  final format = DateFormat("dd-MM-yyyy");
  final _profileFormKey = GlobalKey<FormState>();
  ValidatorX validator = ValidatorX();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nomineeController = TextEditingController();
  TextEditingController _imageController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _gstController = TextEditingController();
  TextEditingController _shopNameController = TextEditingController();

  late DateTime selectedDate;

  late String pinImageB64;

  late Future _profileApi;

  late int defaultTeam;

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

  @override
  void initState() {
    _profileApi = getData();
    getState();
    super.initState();
  }

  void getSubCategory() {
    Api.http.get("shopping/category").then((response) {
      setState(() {
        categoryList = response.data['list'];
      });

      if (categoryList.length > 0) {
        categoryList.map((category) {
          if (category['id'].toString() == categorySelection) {
            setState(() {
              subCategoryList = category['subCategory'];
            });
          }
        }).toList();
      }
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

  Future getImage(ImgSource source) async {
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
      _image = File(image.path);
    });
  }

  Future getData() async {
    Api.http.get('member/profile').then((response) async {
      setState(() {
        userResponse = response.data;
        defaultTeam = userResponse!['default_team'];
        _nameController.text = userResponse!['name'];
        _numberController.text = userResponse!['phone'];
        _addressController.text = userResponse!['address'];
        _nomineeController.text = userResponse!['nomineeName'];
        _pinCodeController.text = userResponse!['pincode'] != null ? userResponse!['pincode'].toString() : "";
        if (userResponse!['dob'] != null && userResponse!['dob'] != "") {
          _dobController.text = formatDate(
            DateTime.parse(userResponse!['dob']).toLocal(),
            [dd, '-', mm, '-', yyyy],
          );
        }

        if (userResponse!['gender'] != null) {
          _gender = userResponse!['gender'];
        }

        if (response.data['state'] != null) myStateSelection = response.data['state']['id'].toString();
        if (response.data['city'] != null) {
          cityId = response.data['city']['id'].toString();
          getCity(myStateSelection!, isLoad: true);
        }

        _shopNameController.text = userResponse!['shopName'];
        _gstController.text = userResponse!['gstNumber'];

        if (response.data['category'] != null && response.data['category'] != "") {
          categorySelection = response.data['category']['id'].toString();
          subCategorySelection = response.data['subCategory']['id'].toString();
        }
        getSubCategory();
      });
    });
  }

  String validateEmail(String? value) {
    String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value!))
      return 'Enter a valid email address';
    else
      return "";
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text('Profile Section'),
      ),
      body: FutureBuilder(
        future: _profileApi,
        builder: (context, snapshot) {
          if (userResponse == null) {
            return Center();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _profileFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildProfileImage(context),
                      ],
                    ),
                    // SizedBox(height: 40.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(padding: const EdgeInsets.all(10.0)),
                        Row(
                          children: <Widget>[
                            Radio<int>(
                              value: 1,
                              groupValue: _gender,
                              onChanged: (int? value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                            Text('Male'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio<int>(
                              value: 2,
                              groupValue: _gender,
                              onChanged: (int? value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                            Text('Female'),
                          ],
                        ),
                      ],
                    ),
                    formField(
                      context,
                      'Name',
                      prefixIcon: UniconsLine.user,
                      controller: _nameController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
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
                    SizedBox(height: 10.0),
                    formField(
                      context,
                      'Mobile Number',
                      prefixIcon: UniconsLine.phone,
                      controller: _numberController,
                      maxLength: 10,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
                      validator: validator.add(
                        key: 'phone',
                        rules: [
                          ValidatorX.mandatory(message: "Mobile Number field is required"),
                          ValidatorX.minLength(length: 10, message: "Mobile Number must be of 10 digit"),
                        ],
                      ),
                      onChanged: (value) {
                        validator.clearErrorsAt('phone');
                      },
                    ),
                    SizedBox(height: 10.0),
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
                    SizedBox(height: 10.0),
                    formField(
                      context,
                      'address',
                      prefixIcon: UniconsLine.home,
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                      validator: validator.add(
                        key: 'address',
                        rules: [
                          ValidatorX.mandatory(message: "Address field is required"),
                        ],
                      ),
                      onChanged: (value) {
                        validator.clearErrorsAt('address');
                      },
                    ),
                    SizedBox(height: 10),
                    if (stateData != null) _stateDropdown(),
                    if (citiesData != null) SizedBox(height: 10),
                    if (citiesData != null) _cityDropdown(),
                    SizedBox(height: 10.0),
                    formField(
                      context,
                      'PinCode',
                      prefixIcon: Icons.pin_drop,
                      controller: _pinCodeController,
                      textInputAction: TextInputAction.next,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
                      validator: validator.add(
                        key: 'pincode',
                        rules: [
                          ValidatorX.mandatory(message: "PinCode field is required"),
                        ],
                      ),
                      onChanged: (value) {
                        validator.clearErrorsAt('pincode');
                      },
                    ),
                    SizedBox(height: 10.0),
                    formField(
                      context,
                      'Nominee Name',
                      prefixIcon: UniconsLine.user,
                      controller: _nomineeController,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                      validator: validator.add(
                        key: 'nomineeName',
                        rules: [
                          ValidatorX.mandatory(message: "Nominee Name field is required"),
                        ],
                      ),
                      onChanged: (value) {
                        validator.clearErrorsAt('nomineeName');
                      },
                    ),
                    SizedBox(height: 10.0),
                    if (Auth.isVendor()!) ...[
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
                      if (categoryList.length > 0) _categoryDropdown(),
                      if (subCategoryList.length > 0) SizedBox(height: 10),
                      if (subCategoryList.length > 0) _subCategoryDropdown(),
                      SizedBox(height: 10),
                      formField(
                        context,
                        'GST Number',
                        prefixIcon: UniconsLine.file_landscape_alt,
                        controller: _gstController,
                        textCapitalization: TextCapitalization.characters,
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
                                              width: 150,
                                              height: 100,
                                              fit: BoxFit.contain,
                                            )
                                          : userResponse!['vendorImages'] != null
                                              ? PNetworkImage(
                                                  userResponse!['vendorImages'][0]['fileName'],
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                    if (uploadingImage1)
                                      Container(
                                        height: 150,
                                        width: 100,
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
                                              width: 150,
                                              height: 100,
                                              fit: BoxFit.contain,
                                            )
                                          : userResponse!['vendorImages'] != null && userResponse!['vendorImages'].length > 1
                                              ? PNetworkImage(
                                                  userResponse!['vendorImages'][1]['fileName'],
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                    if (uploadingImage2)
                                      Container(
                                        height: 150,
                                        width: 100,
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
                                              width: 150,
                                              height: 100,
                                              fit: BoxFit.contain,
                                            )
                                          : userResponse!['vendorImages'] != null && userResponse!['vendorImages'].length > 2
                                              ? PNetworkImage(
                                                  userResponse!['vendorImages'][2]['fileName'],
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                    if (uploadingImage3)
                                      Container(
                                        height: 150,
                                        width: 100,
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
                                              width: 150,
                                              height: 100,
                                              fit: BoxFit.contain,
                                            )
                                          : userResponse!['vendorImages'] != null && userResponse!['vendorImages'].length > 3
                                              ? PNetworkImage(
                                                  userResponse!['vendorImages'][3]['fileName'],
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.asset(
                                                  'assets/images/no_image.png',
                                                  width: 150,
                                                  height: 100,
                                                  fit: BoxFit.contain,
                                                ),
                                    if (uploadingImage4)
                                      Container(
                                        height: 150,
                                        width: 100,
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
                    SizedBox(height: 25.0),
                    Container(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: () async {
                          if (_profileFormKey.currentState!.validate()) {
                            FocusScope.of(context).requestFocus(FocusNode());

                            dynamic profileImage;
                            if (_image != null) {
                              profileImage = await Vapor.upload(
                                _image,
                                progressCallback: (int? completed, int? total) {
                                  setState(() {
                                    uploading = true;
                                    progressString = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                  });
                                },
                              );

                              setState(() {
                                uploading = false;
                              });
                            }

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
                              "name": _nameController.text,
                              "mobile": _numberController.text,
                              "address": _addressController.text,
                              "gender": _gender,
                              "pincode": _pinCodeController.text,
                              "dob": _dobController.text,
                              "profile": profileImage,
                              "nomineeName": _nomineeController.text,
                              "shop_name": _shopNameController.text,
                              "state_id": myStateSelection,
                              "city_id": myCitySelection,
                              "pincode": _pinCodeController.text,
                              "is_vendor": Auth.isVendor()! ? 1 : 0,
                              "category_id": categorySelection,
                              "sub_category_id": subCategorySelection,
                              "gst_number": _gstController.text,
                              "sub_images": subImagesList,
                            };

                            Api.http.post('member/profile/update', data: sendData).then((response) async {
                              if (response.data['status'])
                                GetBar(
                                  message: response.data['message'],
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.green,
                                ).show();

                              if (response.data['status']) {
                                Map? exitingUser = Auth.user();
                                exitingUser!['profileImage'] = response.data['member']['profileImage'];
                                Auth.updateUser(exitingUser);
                              }
                              Timer(Duration(seconds: 3), () {
                                Get.back();
                              });
                            }).catchError((error) {
                              GetBar(
                                message: error.response.data['message'],
                                duration: Duration(seconds: 5),
                                backgroundColor: Colors.red,
                              ).show();
                              // if(error.response.)
                              validator.setErrors(error.response.data['errors']);
                            });
                          }
                        },
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.all(15.0),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
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
              child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Column(
                    children: <Widget>[
                      if (!uploading)
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : userResponse!['profileImage'] != null
                                ? PNetworkImage(
                                    userResponse!['profileImage'],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    fit: BoxFit.contain,
                                    // width: 100,
                                    // height: 100,
                                  ),
                      if (uploading)
                        Container(
                          height: 85.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(progressString),
                              CircularProgressIndicator(),
                            ],
                          ),
                        )
                    ],
                  )),
            ),
          ),
          Container(
            padding: EdgeInsets.all(spacing_control),
            margin: EdgeInsets.only(bottom: 30, right: 15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: white,
              border: Border.all(
                color: colorPrimary,
                width: 1,
              ),
            ),
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
          ),
        ],
      ),
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
              subCategorySelection = null;
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
