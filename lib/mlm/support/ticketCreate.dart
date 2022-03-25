import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../services/api.dart';
import '../../../services/validator_x.dart';

class TicketCreate extends StatefulWidget {
  @override
  _TicketCreateState createState() => _TicketCreateState();
}

class _TicketCreateState extends State<TicketCreate> {
  final _ticketFormKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  ValidatorX validator = ValidatorX();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _ticketFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^[ ,-]'))],
                  validator: validator.add(
                    key: 'message',
                    rules: [
                      ValidatorX.mandatory(message: "The message field is required"),
                    ],
                  ),
                  onChanged: (value) {
                    validator.clearErrorsAt('message');
                  },
                  controller: _commentController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: MaterialButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      "Send".toUpperCase(),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      if (_ticketFormKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Map sendData = {
                          'message': _commentController.text,
                        };
                        Api.http.post('member/support-tickets/store', data: sendData).then(
                          (response) {
                            GetBar(
                              backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                              duration: Duration(seconds: 3),
                              message: response.data['message'],
                            ).show();
                            Timer(Duration(seconds: 3), () {
                              Get.back();
                            });
                          },
                        ).catchError(
                          (error) {
                            if (error.response.statusCode == 422) {
                              setState(() {});
                            } else if (error.response.statusCode == 401) {
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: error.response.data['errors'],
                              ).show();
                              setState(() {
                                validator.setErrors(error.response.data['errors']);
                              });
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
