import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';

class AddNote extends StatefulWidget {
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _addNoteFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  Map<String, dynamic>? _errors = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Translator.get('Add Notes')!,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _addNoteFormKey,
            autovalidate: _autoValidation,
            onChanged: () {
              setState(() {
                _errors = {};
              });
            },
            child: Column(
              children: <Widget>[
                TextFormField(
                  inputFormatters: [
                    BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))
                  ],
                  controller: _titleController,
                  validator: (title) {
                    if (title!.isEmpty) {
                      return Translator.get('Title is required');
                    }
                    if (_errors != null && _errors!.containsKey('title')) {
                      return _errors!['title'][0];
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(), hintText: 'Title'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  inputFormatters: [
                    BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))
                  ],
                  controller: _descriptionController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return Translator.get('Description is required');
                    }
                    if (_errors != null && _errors!.containsKey('description')) {
                      return _errors!['description'][0];
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    counterText: "",
                    border: UnderlineInputBorder(),
                    labelText: Translator.get("Enter your note"),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      Translator.get("Save")!.toUpperCase(),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        _autoValidation = true;
                      });

                      if (_addNoteFormKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Map sendData = {
                          'title': _titleController.text,
                          'description': _descriptionController.text,
                        };

                        Api.http.post('notes-create', data: sendData).then(
                          (response) {
                            if (response.data['status']) {
                              Get.back(result: response.data);
                            } else {
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: response.data['message'],
                              ).show();
                            }
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
}
