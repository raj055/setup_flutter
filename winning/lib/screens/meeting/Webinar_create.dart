import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/translator.dart';

class WebinarCreate extends StatefulWidget {
  @override
  _WebinarCreateState createState() => _WebinarCreateState();
}

class _WebinarCreateState extends State<WebinarCreate> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _webLinkController = TextEditingController();
  final TextEditingController _paymentAmountController = TextEditingController();
  final TextEditingController _coHostnameController = TextEditingController();
  final TextEditingController _coHostPhoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List _paymentType = [
    {"type": "Free", "value": '1'},
    {"type": "Paid", "value": '2'},
  ];
  String? _selectPayment;
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
        title: Text(Translator.get('Webinar Create')!),
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
                      return '${Translator.get('Title')} ${Translator.get(' is required')}';
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
                    hintText: Translator.get("City"),
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
                SizedBox(height: 24),
                TextFormField(
                  controller: _webLinkController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return '${Translator.get('Webinar link')} ${Translator.get(' is required')}';
                    }
                    if (_errors != null && _errors!.containsKey('webinar_link')) {
                      return _errors!['webinar_link'][0];
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: Translator.get('Webinar link'),
                  ),
                ),
                SizedBox(height: 24.0),
                DropdownButtonFormField<String>(
                  value: _selectPayment,
                  decoration: InputDecoration(
                    labelText: Translator.get('Select Payment Type'),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectPayment = newValue;
                    });
                  },
                  items: _paymentType.map<DropdownMenuItem<String>>(
                    (level) {
                      return DropdownMenuItem<String>(
                        child: Text(level['type']),
                        value: level['value'],
                      );
                    },
                  ).toList(),
                ),
                if (_selectPayment == '2') SizedBox(height: 24),
                if (_selectPayment == '2')
                  TextFormField(
                    controller: _paymentAmountController,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return '${Translator.get('Payment amount')} ${Translator.get(' is required')}';
                      }
                      if (value.length < 2) {
                        return Translator.get('Payment amount is must be 2 digit');
                      }
                      if (_errors!.containsKey('payment_amount')) {
                        return _errors!['payment_amount'][0];
                      }
                      return null;
                    },
                    inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[0,.]|[ ,-]'))],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: Translator.get('Enter amount'),
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
                          "webinar_link": _webLinkController.text,
                          "type": "2",
                          "payment_type": _selectPayment,
                          "payment_amount": _paymentAmountController.text,
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
