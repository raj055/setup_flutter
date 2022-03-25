import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/validator_x.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class KycDetails extends StatefulWidget {
  @override
  _KycDetailsState createState() => _KycDetailsState();
}

class _KycDetailsState extends State<KycDetails> {
  final _kycFormKey = GlobalKey<FormState>();

  String? accountType;

  List _accountTypes = [
    {"type": "Saving", "value": 1},
    {"type": "Current", "value": 2},
  ];

  ValidatorX validator = ValidatorX();

  TextEditingController _panCardController = TextEditingController();
  TextEditingController _aadhaarController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController _bankBranchController = TextEditingController();
  TextEditingController _ifscCodeController = TextEditingController();

  bool uploadingPanCard = false;
  bool uploadingAadhaar = false;
  bool uploadingAadhaarBack = false;
  bool uploadingCheque = false;
  String progressStringPanCard = "";
  String progressStringAadhaar = "";
  String progressStringAadhaarBack = "";
  String progressStringCheque = "";
  Map? kycData;

  Map<String, dynamic>? _errors;
  File? _panCardImage;
  File? _aadhaarCardImage;
  File? _aadhaarCardBackImage;
  File? _cancelChequeImage;

  @override
  void initState() {
    getKyc();
    super.initState();
  }

  getKyc() {
    Api.http.get("member/profile/kyc").then((response) {
      setState(() {
        kycData = response.data;
        if (kycData! != true) {
          _aadhaarController.text = kycData!['aadhaarCard'];
          _accountNameController.text = kycData!['accountName'];
          _accountNumberController.text = kycData!['accountNumber'];
          _ifscCodeController.text = kycData!['bankIfsc'];
          _bankNameController.text = kycData!['bankName'];
          _bankBranchController.text = kycData!['bankBranch'];
          _panCardController.text = kycData!['panCard'];
          accountType = kycData!['accountType'];
        }
      });
    });
  }

  Future getImage(ImgSource source) async {
    PickedFile panImage = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
    );
    setState(() {
      _panCardImage = File(panImage.path);
    });
  }

  Future getAadhaarImage(ImgSource source) async {
    PickedFile aadhaarImage = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
    );
    setState(() {
      _aadhaarCardImage = File(aadhaarImage.path);
    });
  }

  Future getAadhaarBackImage(ImgSource source) async {
    PickedFile aadhaarBackImage = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
    );
    setState(() {
      _aadhaarCardBackImage = File(aadhaarBackImage.path);
    });
  }

  Future getChequeImage(ImgSource source) async {
    PickedFile chequeImage = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(UniconsLine.camera),
      galleryIcon: Icon(UniconsLine.image),
      cameraText: text("From Camera"),
      galleryText: text("From Gallery"),
    );
    setState(() {
      _cancelChequeImage = File(chequeImage.path);
    });
  }

  Widget accountTypeDropdown() {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      validator: validator.add(
        key: 'accountType',
        rules: [
          ValidatorX.mandatory(message: "Select Your Account Type"),
        ],
      ),
      hint: Text('Select Account Type'),
      value: accountType,
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
        filled: true,
        fillColor: Color(0xFFf7f7f7),
        hintText: 'Select City',
        hintStyle: TextStyle(fontSize: textSizeMedium, color: Colors.grey[300]),
      ),
      onChanged: (String? newValue) {
        setState(() {
          accountType = newValue!;
        });
        validator.clearErrorsAt('accountType');
      },
      items: _accountTypes.map<DropdownMenuItem<String>>((type) {
        return DropdownMenuItem<String>(
          child: Text(type['type']),
          value: type['value'].toString(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KYC',
            ),
            if (kycData != null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: text(
                  kycData!['kycStatus']['name'],
                  textColor: kycData!['kycStatus']['id'] == 1
                      ? HexColor("##68BBE3")
                      : kycData!['kycStatus']['id'] == 2
                          ? Colors.amber
                          : kycData!['kycStatus']['id'] == 3
                              ? Colors.green
                              : Colors.red,
                  fontFamily: fontBold,
                ),
              )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _kycFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white_color,
                  radius: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      'Upgrade your Pan card / Aadhaar Card Details',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                      isLongText: true,
                    ),
                    SizedBox(height: 10),
                    floatingInput(
                      'Pan Card',
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
                      controller: _panCardController,
                      validator: validator.add(
                        key: 'panCard',
                        rules: [],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('panCard');
                      },
                      maxLength: 10,
                    ),
                    SizedBox(height: 10),
                    floatingInput(
                      'Aadhaar Card',
                      keyboardType: TextInputType.number,
                      validator: validator.add(
                        key: 'aadhaarCard',
                        rules: [
                          ValidatorX.mandatory(message: 'Aadhaar card field is required'),
                          ValidatorX.minLength(length: 12, message: 'Aadhaar card number must be 12 digits')
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('aadhaarCard');
                      },
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ -.,]'))],
                      maxLength: 12,
                      controller: _aadhaarController,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white_color,
                  radius: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      'Update your banking details',
                      fontSize: textSizeLargeMedium,
                      fontFamily: fontBold,
                      textColor: textColorPrimary,
                    ),
                    SizedBox(height: 10),
                    floatingInput(
                      'Account Holder Name',
                      controller: _accountNameController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ -.,]'))],
                      validator: validator.add(
                        key: 'accountName',
                        rules: [
                          ValidatorX.mandatory(message: 'Account holder name field is required'),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('accountName');
                      },
                    ),
                    SizedBox(height: 10),
                    floatingInput(
                      'Account Number',
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 18,
                      validator: validator.add(
                        key: 'accountNumber',
                        rules: [
                          ValidatorX.mandatory(message: 'Account number field is required'),
                          ValidatorX.minLength(length: 9, message: 'The account number must be between 9 and 18 digits')
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('accountNumber');
                      },
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      isDense: true,
                      isExpanded: true,
                      validator: validator.add(
                        key: 'accountType',
                        rules: [
                          ValidatorX.mandatory(message: "Select Your Account Type"),
                        ],
                      ),
                      hint: Text('Select Account Type'),
                      value: accountType,
                      decoration: InputDecoration(
                        isDense: true,
                        labelStyle: primaryTextStyle(
                          size: 16,
                          color: textColorPrimary.withOpacity(0.7),
                          fontFamily: fontMedium,
                        ),
                        // prefixIcon: prefixIcon,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
                      ),
                      onChanged: (String? newValue) {
                        validator.clearErrorsAt('accountType');
                        setState(() {
                          accountType = newValue!;
                        });
                      },
                      items: _accountTypes.map<DropdownMenuItem<String>>((type) {
                        return DropdownMenuItem<String>(
                          child: Text(type['type']),
                          value: type['value'].toString(),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    floatingInput(
                      'IFSC Code',
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ,-]'))],
                      controller: _ifscCodeController,
                      onChanged: (value) {
                        validator.clearErrorsAt('bankIfsc');
                        if (value.length == 11) {
                          Api.httpWithoutBaseUrl.get('https://ifsc.razorpay.com/' + _ifscCodeController.text).then((res) {
                            setState(() {
                              _bankNameController.text = res.data['BANK'];
                              _bankBranchController.text = res.data['BRANCH'];
                            });
                          }).catchError((err) {
                            setState(() {
                              _bankNameController.text = '';
                              _bankBranchController.text = '';
                            });
                          });
                        } else {
                          setState(() {
                            _bankNameController.text = '';
                            _bankBranchController.text = '';
                          });
                        }
                      },
                      validator: validator.add(
                        key: 'bankIfsc',
                        rules: [
                          ValidatorX.mandatory(message: 'Ifsc code is required'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    floatingInput(
                      'Bank Name',
                      controller: _bankNameController,
                      validator: validator.add(
                        key: 'bankName',
                        rules: [
                          ValidatorX.mandatory(message: 'Bank name field is required'),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('bankName');
                      },
                    ),
                    SizedBox(height: 10),
                    floatingInput(
                      'Bank Branch',
                      controller: _bankBranchController,
                      validator: validator.add(
                        key: 'bankBranch',
                        rules: [
                          ValidatorX.mandatory(message: 'Bank branch field is required'),
                        ],
                      ),
                      onChanged: (String value) {
                        validator.clearErrorsAt('bankBranch');
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white_color,
                  radius: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    if (kycData != null) panImage(context),
                    SizedBox(height: 10),
                    if (kycData != null) aadharImage(context),
                    SizedBox(height: 10),
                    if (kycData != null) aadharBackImage(context),
                    SizedBox(height: 10),
                    if (kycData != null) chequeImage(context),
                  ],
                ),
              ),
              if (kycData != null)
                kycData!['kycStatus']['id'] == 3
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          textContent: 'Submit',
                          onPressed: () async {
                            if (_kycFormKey.currentState!.validate()) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              dynamic panCardImageVapor;
                              dynamic aadhaarImageVapor;
                              dynamic aadhaarBackImageVapor;
                              dynamic chequeImageVapor;

                              if (_panCardImage != null) {
                                panCardImageVapor = await Vapor.upload(
                                  _panCardImage,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingPanCard = true;
                                        progressStringPanCard = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingPanCard = false;
                                      }
                                    });
                                  },
                                );
                              }

                              if (_aadhaarCardImage != null) {
                                aadhaarImageVapor = await Vapor.upload(
                                  _aadhaarCardImage,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingAadhaar = true;
                                        progressStringAadhaar = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingAadhaar = false;
                                      }
                                    });
                                  },
                                );
                              }
                              if (_aadhaarCardBackImage != null) {
                                aadhaarBackImageVapor = await Vapor.upload(
                                  _aadhaarCardBackImage,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingAadhaarBack = true;
                                        progressStringAadhaarBack = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingAadhaarBack = false;
                                      }
                                    });
                                  },
                                );
                              }
                              if (_cancelChequeImage != null) {
                                chequeImageVapor = await Vapor.upload(
                                  _cancelChequeImage,
                                  progressCallback: (int? completed, int? total) {
                                    setState(() {
                                      if (completed != total) {
                                        uploadingCheque = true;
                                        progressStringCheque = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                                      } else {
                                        uploadingCheque = false;
                                      }
                                    });
                                  },
                                );
                              }

                              Map sendData = {
                                'panCard': _panCardController.text,
                                'aadhaarCard': _aadhaarController.text,
                                'bankName': _bankNameController.text,
                                'bankBranch': _bankBranchController.text,
                                'bankIfsc': _ifscCodeController.text,
                                'accountType': accountType,
                                'accountName': _accountNameController.text,
                                'accountNumber': _accountNumberController.text,
                                if (_aadhaarCardImage != null) 'aadhaarCardImage': aadhaarImageVapor,
                                if (_aadhaarCardBackImage != null) 'aadhaarCardBackImage': aadhaarBackImageVapor,
                                if (_panCardImage != null) 'panCardImage': panCardImageVapor,
                                if (_cancelChequeImage != null) 'cancelChequeImage': chequeImageVapor,
                              };
                              Api.http.post('member/profile/kyc', data: sendData).then((response) async {
                                GetBar(
                                  backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                  duration: Duration(seconds: 3),
                                  message: response.data['status'] ? response.data['message'] : response.data['message'],
                                ).show();
                                if (response.data['status']) {
                                  Timer(Duration(seconds: 3), () {
                                    Get.back();
                                  });
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
                                    _errors = error.response.data['errors'];
                                  });
                                }
                              });
                            }
                          },
                        ),
                      ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget panImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Pan Card Image',
            fontSize: textSizeLargeMedium,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!uploadingPanCard)
                        _panCardImage != null
                            ? Image.file(
                                _panCardImage!,
                                width: w(100),
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : kycData!['panCardImage'] != null
                                ? PNetworkImage(
                                    kycData!['panCardImage'],
                                    width: w(100),
                                    fit: BoxFit.contain,
                                    height: 200,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    fit: BoxFit.contain,
                                    width: w(100),
                                    height: 200,
                                  ),
                      if (uploadingPanCard)
                        Container(
                          height: 200.0,
                          width: w(100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Text(
                                "Uploading Image: $progressStringPanCard ",
                              )
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
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
          // if (_errors != null &&
          //     _panCardImage == null &&
          //     _errors!.containsKey('pan_card_image'))
          //   SizedBox(height: 5),
          // if (_errors != null &&
          //     _panCardImage == null &&
          //     _errors!.containsKey('pan_card_image'))
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 20),
          //     child: Text(
          //       _errors!['pan_card_image'][0],
          //       style: TextStyle(color: Colors.red),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget aadharImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Aadhar Card Image',
            fontSize: textSizeLargeMedium,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!uploadingAadhaar)
                        _aadhaarCardImage != null
                            ? Image.file(
                                _aadhaarCardImage!,
                                width: w(100),
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : kycData!['aadhaarCardImage'] != null
                                ? PNetworkImage(
                                    kycData!['aadhaarCardImage'],
                                    width: w(100),
                                    fit: BoxFit.contain,
                                    height: 200,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    width: w(100),
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                      if (uploadingAadhaar)
                        Container(
                          height: 200.0,
                          width: w(100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              Text(
                                "Uploading Image: $progressStringAadhaar ",
                              )
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
                child: GestureDetector(
                  onTap: () {
                    getAadhaarImage(ImgSource.Both);
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
          if (_errors != null && _aadhaarCardImage == null && _errors!.containsKey('aadhaar_card_image')) SizedBox(height: 5),
          if (_errors != null && _aadhaarCardImage == null && _errors!.containsKey('aadhaar_card_image'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errors!['aadhaar_card_image'][0],
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget aadharBackImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Aadhar Card Back Image',
            fontSize: textSizeLargeMedium,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!uploadingAadhaarBack)
                        _aadhaarCardBackImage != null
                            ? Image.file(
                                _aadhaarCardBackImage!,
                                width: w(100),
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : kycData!['aadhaarCardBackImage'] != null
                                ? PNetworkImage(
                                    kycData!['aadhaarCardBackImage'],
                                    width: w(100),
                                    fit: BoxFit.contain,
                                    height: 200,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    width: w(100),
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                      if (uploadingAadhaarBack)
                        Container(
                          height: 200.0,
                          width: w(100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              Text(
                                "Uploading Image: $progressStringAadhaarBack ",
                              )
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
                child: GestureDetector(
                  onTap: () {
                    getAadhaarBackImage(ImgSource.Both);
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
          if (_errors != null && _aadhaarCardBackImage == null && _errors!.containsKey('aadhaar_card_back_image')) SizedBox(height: 5),
          if (_errors != null && _aadhaarCardBackImage == null && _errors!.containsKey('aadhaar_card_back_image'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errors!['aadhaar_card_back_image'][0],
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget chequeImage(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(
            'Upload Cancel Cheque Or Bank PassBook Front Page',
            fontSize: textSizeLargeMedium,
            fontFamily: fontSemibold,
            textColor: textColorPrimary,
            isLongText: true,
          ),
          Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.all(spacing_control),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (!uploadingCheque)
                        _cancelChequeImage != null
                            ? Image.file(
                                _cancelChequeImage!,
                                width: w(100),
                                height: 200,
                                fit: BoxFit.contain,
                              )
                            : kycData!['cancelChequeImage'] != null
                                ? PNetworkImage(
                                    kycData!['cancelChequeImage'],
                                    width: w(100),
                                    fit: BoxFit.contain,
                                    height: 200,
                                  )
                                : Image.asset(
                                    'assets/images/no_image.png',
                                    width: w(100),
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                      if (uploadingCheque)
                        Container(
                          height: 200.0,
                          width: w(100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              Text(
                                "Uploading Image: $progressStringCheque ",
                              )
                            ],
                          ),
                        )
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(spacing_control),
                margin: EdgeInsets.only(top: 15, right: 10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: white_color, border: Border.all(color: colorPrimary)),
                child: GestureDetector(
                  onTap: () {
                    getChequeImage(ImgSource.Both);
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
          if (_errors != null && _cancelChequeImage == null && _errors!.containsKey('cancel_cheque_image')) SizedBox(height: 5),
          if (_errors != null && _cancelChequeImage == null && _errors!.containsKey('cancel_cheque_image'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errors!['cancel_cheque_image'][0],
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
