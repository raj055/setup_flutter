import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';

class DreamPick extends StatefulWidget {
  @override
  _DreamPickState createState() => _DreamPickState();
}

class _DreamPickState extends State<DreamPick> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _pickDreamsFormKey = GlobalKey<FormState>();
  final format = DateFormat("dd-MM-yyyy");
  bool _autoValidate = false;
  TextEditingController _dateController = TextEditingController();
  var selectedCategory;
  var dreamType;
  String? _categoryVal;
  String? _categorySubVal;
  Map? pickDream;

  @override
  void initState() {
    pickDream = Get.arguments;
    _futurePickDream();
    super.initState();
  }

  void _futurePickDream() {
    _categoryVal = pickDream!["dream"]['category_id'] != null
        ? _categoryVal = pickDream!["dream"]['category_id'].toString()
        : null;
    _categorySubVal = pickDream!["dream"]['sub_category_id'] != null
        ? _categorySubVal = pickDream!["dream"]['sub_category_id'].toString()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    var dreamList = pickDream!["dream"];
    dreamType = pickDream!["pickDream"];

    return Scaffold(
      backgroundColor: Color(0xffe9e9e9),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(Translator.get('Pick Dream')!),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              child: FadeAnimation(
                0.8,
                Column(
                  children: <Widget>[
                    _buildDreamImageField(context, dreamList),
                  ],
                ),
              ),
            ),
            FadeAnimation(
              1.0,
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: Form(
                    key: _pickDreamsFormKey,
                    autovalidate: _autoValidate,
                    onChanged: () {},
                    child: Column(
                      children: <Widget>[
                        _buildCategoryField(context),
                        SizedBox(height: 15),
                        _buildSubCategoryField(context),
                        SizedBox(height: 15),
                        _buildTargetCalenderField(context),
                        SizedBox(height: 15),
                        _submitButton(context, dreamList)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context, dreamList) {
    int? _dreamId = dreamList['dreamId'];

    return FadeAnimation(
      1.2,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _autoValidate = true;
                  });

                  if (_pickDreamsFormKey.currentState!.validate()) {
                    FocusScope.of(context).requestFocus(FocusNode());

                    Map sendData = {
                      'dream_id': _dreamId,
                      'category_id': _categoryVal,
                      'sub_category_id': _categorySubVal,
                      'target_date': _dateController.text,
                    };

                    Api.http.post('pick-dream', data: sendData).then(
                      (response) {
                        GetBar(
                          backgroundColor: response.data['status']
                              ? Colors.green
                              : Colors.red,
                          duration: Duration(seconds: 5),
                          message: response.data['message'],
                        ).show();

                        if (dreamList['category'] == "Short Term") {
                          if (Auth.currentPackage() == 1) {
                            Get.offAllNamed('guest-dashboard');
                            Get.toNamed("dream-list");
                          } else {
                            Get.offAllNamed('home');
                            Get.toNamed("dream-list");
                          }
                        } else if (dreamList['category'] == "Mid Term") {
                          if (Auth.currentPackage() == 1) {
                            Get.offAllNamed('guest-dashboard');
                            Get.toNamed("dream-list", arguments: 'MidTerm');
                          } else {
                            Get.offAllNamed('home');
                            Get.toNamed("dream-list", arguments: 'MidTerm');
                          }
                        } else if (dreamList['category'] == "Long Term") {
                          if (Auth.currentPackage() == 1) {
                            Get.offAllNamed('guest-dashboard');
                            Get.toNamed("dream-list", arguments: 'LongTerm');
                          } else {
                            Get.offAllNamed('home');
                            Get.toNamed("dream-list", arguments: 'LongTerm');
                          }
                        }
                      },
                    ).catchError(
                      (error) {
                        if (error.response.statusCode == 422) {
                          String? message;
                          if (error.response.data['errors']
                              .containsKey('dream_id')) {
                            message =
                                error.response.data['errors']['dream_id'][0];
                          } else if (error.response.data['errors']
                              .containsKey('category_id')) {
                            message =
                                error.response.data['errors']['category_id'][0];
                          } else if (error.response.data['errors']
                              .containsKey('sub_category_id')) {
                            message = error.response.data['errors']
                                ['sub_category_id'][0];
                          }

                          GetBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 5),
                            message: message!,
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
                        Translator.get("Submit")!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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

  Widget _buildDreamImageField(BuildContext context, dreamList) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: PNetworkImage(
            dreamList["dreamImage"],
            fit: BoxFit.contain,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dreamList["name"],
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetCalenderField(BuildContext context) {
    return Column(
      children: <Widget>[
        DateTimeField(
          controller: _dateController,
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
      value: _categoryVal,
      onChanged: ((String? newValue) {
        setState(() {
          _categoryVal = newValue;
        });
      }),
      hint: Text(Translator.get('Choose Category')!),
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
      ),
      items: dreamType["categories"].map<DropdownMenuItem<String>>(
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
        setState(
          () {
            _categorySubVal = newValue;
          },
        );
      }),
      items: dreamType["subCategories"].map<DropdownMenuItem<String>>(
        (value) {
          return DropdownMenuItem<String>(
            value: value['id'].toString(),
            child: Text(value['value']),
          );
        },
      ).toList(),
    );
  }
}
