import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/translator.dart';

class SeminarCreate extends StatefulWidget {
  @override
  _SeminarCreateState createState() => _SeminarCreateState();
}

class _SeminarCreateState extends State<SeminarCreate> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _coHostnameController = TextEditingController();
  final TextEditingController _coHostPhoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final format = DateFormat("dd-MM-yyyy");
  final timeFormat = DateFormat("HH:mm");
  DateTime? _formDate;
  final _seminarWebinarFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  Map<String, dynamic>? _errors = {};
  TimeOfDay? _time = TimeOfDay.now();
  String? _selectedFormDate;
  Map? meetingCategoryDetails;

  @override
  void initState() {
    meetingCategoryDetails = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('Seminar Create')!),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _seminarWebinarFormKey,
            autovalidate: _autoValidation,
            onChanged: () {
              setState(() {
                _errors = {};
              });
            },
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ]'))],
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('title')} ${Translator.get(' is required')}';
                    }
                    if (_errors != null && _errors!.containsKey('title')) {
                      return _errors!['title'][0];
                    }
                    return null;
                  },
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: Translator.get("Title"),
                  ),
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ]'))],
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('Description')} ${Translator.get(' is required')}';
                    }
                    if (_errors != null && _errors!.containsKey('title')) {
                      return _errors!['title'][0];
                    }
                    return null;
                  },
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: Translator.get("Description"),
                  ),
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ]'))],
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('Host name')} ${Translator.get(' is required')}';
                    }
                    if (_errors != null && _errors!.containsKey('name')) {
                      return _errors!['name'][0];
                    }
                    return null;
                  },
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: Translator.get("Host Name"),
                  ),
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  controller: _phoneController,
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'[ ,.-]'))],
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('Host mobile number')} ${Translator.get(' is required')}';
                    }
                    if (value.length < 10) {
                      return Translator.get('Mobile number is must be 10 digit long');
                    }
                    if (_errors!.containsKey('host_mobile')) {
                      return _errors!['host_mobile'][0];
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: Translator.get("Host Mobile Number"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                DateTimeField(
                  format: format,
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: Translator.get('Date'),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onShowPicker: (context, currentValue) async {
                    _formDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      initialDate: currentValue != null ? currentValue : DateTime.now(),
                      lastDate: DateTime(2050),
                    );
                    if (_formDate != null) {
                      setState(() {
                        _selectedFormDate = _formDate!.toLocal().toString().split(' ')[0];
                      });

                      return _formDate!;
                    }
                    return currentValue;
                  },
                  validator: (date) =>
                      (date == null) ? '${Translator.get('Date')} ${Translator.get(' is required')}' : null,
                ),
                SizedBox(height: 24.0),
                DateTimeField(
                  format: timeFormat,
                  controller: _timeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: Translator.get('Time'),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onShowPicker: (context, currentValue) async {
                    _time = await showTimePicker(
                        context: context, initialTime: currentValue as TimeOfDay? ?? TimeOfDay.now());

                    if (_time != null) {
                      return DateTimeField.convert(_time!);
                    }
                    return currentValue;
                  },
                  validator: (time) =>
                      (time == null) ? '${Translator.get('Time')} ${Translator.get(' is required')}' : null,
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('venue')} ${Translator.get(' is required')}';
                    }
                    if (_errors != null && _errors!.containsKey('city')) {
                      return _errors!['city'][0];
                    }
                    return null;
                  },
                  controller: _venueController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: Translator.get("venue name"),
                  ),
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('City')} ${Translator.get(' is required')}';
                    }
                    if (_errors != null && _errors!.containsKey('city')) {
                      return _errors!['city'][0];
                    }
                    return null;
                  },
                  controller: _cityController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: Translator.get("city"),
                  ),
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ]'))],
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('co-Host name')} ${Translator.get(' is required')}';
                    }
                    if (_errors != null && _errors!.containsKey('co_host_name')) {
                      return _errors!['co_host_name'][0];
                    }
                    return null;
                  },
                  controller: _coHostnameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: Translator.get("co-Host Name"),
                  ),
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  controller: _coHostPhoneController,
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'[ ,.-]'))],
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('co-Host mobile number')} ${Translator.get(' is required')}';
                    }
                    if (value.length < 10) {
                      return Translator.get('Mobile number is must be 10 digit long');
                    }
                    if (_errors!.containsKey('co_host_mobile')) {
                      return _errors!['co_host_mobile'][0];
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: Translator.get("co-Host Mobile Number"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
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
                      if (_seminarWebinarFormKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());

                        Map sendData = {
                          "meeting_category": meetingCategoryDetails!['id'],
                          "title": _titleController.text,
                          "description": _descriptionController.text,
                          "host_name": _nameController.text,
                          "host_mobile": _phoneController.text,
                          "date": _dateController.text,
                          "time": _timeController.text,
                          "city": _cityController.text,
                          "co_host_name": _coHostnameController.text,
                          "co_host_mobile": _coHostPhoneController.text,
                          "venue": _venueController.text,
                          "type": "1"
                        };
                        Api.http.post('seminar-webinars', data: sendData).then(
                          (response) {
                            GetBar(
                              backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                              duration: Duration(seconds: 3),
                              message: response.data['message'],
                            ).show();

                            Get.offAndToNamed('home');
                            Get.toNamed('meeting_details', arguments: meetingCategoryDetails);
                          },
                        ).catchError(
                          (error) {
                            if (error.response.statusCode == 422) {
                              setState(
                                () {
                                  _errors = error.response.data['errors'];
                                },
                              );
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
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
