import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class RequestWarningPopup extends StatefulWidget {
  const RequestWarningPopup({Key? key}) : super(key: key);

  @override
  _RequestWarningPopupState createState() => _RequestWarningPopupState();
}

class _RequestWarningPopupState extends State<RequestWarningPopup> {
  bool? checkBoxValue = false;
  Map? requestData;

  @override
  void initState() {
    requestData = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(Translator.get("Information For Change Up/Down line")!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                Translator.get("You already have connected with upline."),
                fontSize: textSizeLargeMedium,
              ),
              SizedBox(
                height: 10,
              ),
              text(
                Translator.get(
                    'If you want to connect with another upline then whenever he/she will accept your request, exciting upline will be removed. Please make sure you are aware about all this.'),
                isLongText: true,
                fontSize: textSizeLargeMedium,
              ),
              SizedBox(
                height: 10,
              ),
              text(
                Translator.get('Please make sure you are aware about all this.'),
                isLongText: true,
                fontSize: textSizeLargeMedium,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Checkbox(
                              value: checkBoxValue,
                              onChanged: (bool? value) {
                                setState(
                                  () {
                                    checkBoxValue = value;
                                  },
                                );
                              },
                            ),
                          ),
                          text(
                            Translator.get('I agree to the'),
                            fontSize: textSizeNormal,
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          checkBoxValue = !checkBoxValue!;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                    ),
                    Row(
                      children: [
                        SizedBox(width: w(1)),
                        text(
                          "${Translator.get('Terms')} & ${Translator.get('Condition')}",
                          textColor: Colors.black,
                          fontSize: textSizeNormal,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    if (!checkBoxValue!) {
                      GetBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                        message: Translator.get('You need to accept terms & condition')!,
                      ).show();
                    } else {
                      _showDialog();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).accentColor,
                        ),
                        child: Center(
                          child: Text(
                            "${Translator.get('Agree')} & ${Translator.get('Continue')}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
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
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: text(
            Translator.get('Are you sure you want to send request.'),
            isLongText: true,
            fontSize: textSizeLargeMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: text(
                    Translator.get("Cancel"),
                    textColor: red,
                    fontFamily: fontSemibold,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  child: text(
                    Translator.get("Send"),
                    textColor: green,
                    fontFamily: fontSemibold,
                  ),
                  onPressed: () {
                    Map sendData = {
                      'code': requestData!['code'],
                    };

                    Api.http
                        .post(requestData!['upLine'] == "upLine" ? 'leader-request' : 'add-downline', data: sendData)
                        .then(
                      (response) async {
                        Navigator.of(context).pop();

                        Auth.currentPackage() == 1 ? Get.offAllNamed("guest-dashboard") : Get.offAllNamed("home");
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
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
