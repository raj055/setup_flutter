import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class RaiseRequest extends StatefulWidget {
  @override
  _RaiseRequestState createState() => _RaiseRequestState();
}

class _RaiseRequestState extends State<RaiseRequest> {
  final _requestFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  TextEditingController _memberCodeController = TextEditingController();
  TextEditingController _memberNameController = TextEditingController();
  String? leaderName;

  Map? profileData;

  Future? _future;

  // Future _futureProfile() {
  //   return Api.http.get('profile').then(
  //     (res) {
  //       setState(() {
  //         profileData = res.data;
  //         if (profileData['leaderRequest'] != null && profileData['leaderRequest']['status'] == "Pending") {
  //           _memberCodeController.text = profileData['leaderRequest']['code'];
  //           _memberNameController.text = profileData['leaderRequest']['name'];
  //         }
  //       });
  //       return res.data;
  //     },
  //   );
  // }

  String? validateCode(String? value) {
    if (value!.length != 8)
      return Translator.get('WT App Code must be of 8 digit');
    else
      return null;
  }

  Map? requestData;

  @override
  void initState() {
    requestData = Get.arguments;
    // _future = _futureProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: requestData!['upLine'] == "upLine"
            ? Text(Translator.get('Connect to Up line')!)
            : Text(Translator.get('Connect to Down line')!),
      ),
      body:
          /*FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return*/
          SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _requestFormKey,
                  autovalidate: _autoValidation,
                  onChanged: () {},
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                        onChanged: (value) {
                          _checkCode();
                        },
                        keyboardType: TextInputType.number,
                        validator: validateCode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: Translator.get('Enter WT App Code'),
                          labelText: Translator.get("WT App Code"),
                        ),
                        controller: _memberCodeController,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                        readOnly: true,
                        controller: _memberNameController,
                        validator: (value) => value!.isEmpty ? Translator.get("Member Name can't be empty") : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: Translator.get('Member Name'),
                          labelText: Translator.get("Member Name"),
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 20),
                      // if (profileData != null && profileData['leaderRequest'] == null ||
                      //     profileData['leaderRequest']['status'] == 'Rejected')
                      _sendButton(context),
                      // if (profileData != null &&
                      //     profileData['leaderRequest'] != null &&
                      //     profileData['leaderRequest']['status'] == 'Pending')
                      //   text(
                      //     'You have already send a request, your request has been pending.',
                      //     isLongText: true,
                      //     textColor: red,
                      //     fontFamily: fontSemibold,
                      //   ),
                      // SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //   },
      // ),
    );
  }

  _checkCode() {
    if (_memberCodeController.text.length == 8)
      Api.http.post('get-leader', data: {"code": _memberCodeController.text}).then(
        (response) async {
          setState(
            () {
              leaderName = response.data['leader'];
              _memberNameController.text = leaderName!;
            },
          );
        },
      ).catchError(
        (error) {
          if (error.response.statusCode == 422) {
            GetBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              message: error.response.data['errors']['code'][0],
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

  _sendButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        color: colorPrimary,
        padding: EdgeInsets.all(15),
        child: text(
          Translator.get('Connect'),
          textColor: white,
          fontFamily: fontBold,
          textAllCaps: true,
        ),
        onPressed: () {
          if (_requestFormKey.currentState!.validate()) if (requestData!['upLine'] == "upLine") {
            if (requestData!['isParent']) {
              Get.toNamed(
                'request-warning-popup',
                arguments: {
                  "code": _memberCodeController.text,
                  "upLine": "upLine",
                },
              );
            } else {
              setState(() {
                _autoValidation = true;
              });
              Map requestData = {
                'code': _memberCodeController.text,
              };
              if (_requestFormKey.currentState!.validate())
                Api.http.post('leader-request', data: requestData).then(
                  (response) async {
                    Navigator.of(context).pop();
                    GetBar(
                      backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                      duration: Duration(seconds: 3),
                      message: response.data['message'],
                    ).show();
                  },
                ).catchError(
                  (error) {
                    if (error.response.statusCode == 422) {
                      GetBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                        message: error.response.data['errors']['code'][0],
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
          } else {
            // if (requestData['isChildren']) {
            //   Get.toNamed(
            //     'request-warning-popup',
            //     arguments: {
            //       "code": _memberCodeController.text,
            //       "downLine": "downLine",
            //     },
            //   );
            // } else {
            setState(() {
              _autoValidation = true;
            });
            Map requestData = {
              'code': _memberCodeController.text,
            };
            if (_requestFormKey.currentState!.validate())
              Api.http.post('add-downline', data: requestData).then(
                (response) async {
                  Navigator.of(context).pop();
                  GetBar(
                    backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                    duration: Duration(seconds: 5),
                    message: response.data['message'],
                  ).show();
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
          // }
        },
      ),
    );
  }
}
