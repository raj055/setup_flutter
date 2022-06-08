import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:get/get.dart' hide Response;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class MeetingDetails extends StatefulWidget {
  @override
  _MeetingDetailsState createState() => _MeetingDetailsState();
}

class _MeetingDetailsState extends State<MeetingDetails> {
  final _purchaseFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  String? copyLink;
  String selectTab = "1";
  var seminar;
  Response? response;
  TextEditingController emailController = TextEditingController();

  List? training;
  Map? meetingDetails;

  int pos = 0;

  final flutterWebViewPlugin = FlutterWebviewPlugin();
  String? paymentLink;

  late Razorpay razorpay;
  String? orderId;

  @override
  void initState() {
    meetingDetails = Get.arguments;
    _initializeRazorpay();
    super.initState();
  }

  String? validateEmail(String? value) {
    Pattern pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern as String);
    if (!regex.hasMatch(value!) || value == null)
      return 'Enter a valid email address';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: meetingDetails!['name'],
      apiFuture: (int page) async {
        return Api.http.post(
          'seminar-webinar-lists?page=$page',
          data: {'meeting_id': meetingDetails!['id']},
        );
      },
      listItemBuilder: _meetingDetailsBuilder,
      floatingActionButton: Auth.currentPackage() == 4 ? FadeAnimation(1.2, meetingFloatingButton(context)) : null,
    );
  }

  Widget meetingFloatingButton(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      marginRight: 18,
      marginBottom: 20,
      backgroundColor: Colors.orange,
      children: [
        SpeedDialChild(
          child: Icon(Icons.event_available),
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Seminar',
          labelStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            Get.toNamed('seminar_create', arguments: meetingDetails);
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.event_available),
          backgroundColor: Theme.of(context).accentColor,
          label: 'Webinar',
          labelStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            Get.toNamed('webinar_create', arguments: meetingDetails);
          },
        )
      ],
    );
  }

  Widget _meetingDetailsBuilder(meetingDetail, int index) {
    return Column(
      children: <Widget>[
        FadeAnimation(
          0.9,
          Container(
            decoration: boxDecoration(radius: 10, showShadow: true),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: CircleAvatar(
                            backgroundColor: colorPrimary.withOpacity(0.2),
                            radius: 20,
                            child: Icon(
                              Feather.calendar,
                              color: colorPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: text(
                                        meetingDetail["title"] != null ? meetingDetail["title"] : 'N/A',
                                        textColor: colorPrimaryDark,
                                        fontFamily: fontSemibold,
                                        fontSize: textSizeMedium,
                                        maxLine: 2,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: meetingDetail["seminarWebinarType"] == 'Seminar'
                                            ? green
                                            : meetingDetail["seminarWebinarType"] == 'Webinar'
                                                ? red
                                                : blue,
                                        borderRadius: BorderRadius.all(Radius.circular(25)),
                                      ),
                                      child: text(
                                        meetingDetail["seminarWebinarType"] != null
                                            ? meetingDetail["seminarWebinarType"]
                                            : 'N/A',
                                        textColor: white,
                                        textAllCaps: true,
                                        fontFamily: fontSemibold,
                                        fontSize: textSizeSmall,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    meetingDetail['duration_type'] != 1
                                        ? text(
                                            meetingDetail["date"] != null ? meetingDetail["date"] : 'N/A',
                                            fontSize: textSizeSMedium,
                                            textColor: textColorSecondary,
                                            fontFamily: fontRegular,
                                          )
                                        : text('Daily'),
                                    text(
                                      meetingDetail['payment_type'] == 2 ? 'PAID' : 'FREE',
                                      fontSize: textSizeSMedium,
                                      textColor: meetingDetail['payment_type'] == 2 ? green : colorPrimary,
                                      fontFamily: fontSemibold,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    text(
                                      "${Translator.get("Speaker")} : ",
                                      textColor: textColorSecondary,
                                    ),
                                    text(
                                      meetingDetail["hostName"] != null ? meetingDetail["hostName"] : 'N/A',
                                      textColor: colorPrimaryDark,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 1.2,
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (meetingDetail['payment_type'] == 2 && meetingDetail['type'] == 2) {
                              if (meetingDetail['payment_status'] == 1) {
                                copyLink =
                                    meetingDetail["invitationUrl"] != null ? meetingDetail["invitationUrl"] : 'N/A';
                                Clipboard.setData(ClipboardData(text: copyLink));

                                GetBar(
                                  backgroundColor: green,
                                  duration: Duration(seconds: 2),
                                  message: "Webinar Link Copy",
                                ).show();
                              } else {
                                GetBar(
                                  backgroundColor: red,
                                  duration: Duration(seconds: 2),
                                  message: "Please first buy link  after you can invite this link",
                                ).show();
                              }
                            } else if (meetingDetail['payment_type'] == 1 && meetingDetail['type'] == 2) {
                              copyLink =
                                  meetingDetail["invitationUrl"] != null ? meetingDetail["invitationUrl"] : 'N/A';
                              Clipboard.setData(ClipboardData(text: copyLink));

                              GetBar(
                                backgroundColor: green,
                                duration: Duration(seconds: 2),
                                message: "Webinar Link Copy",
                              ).show();
                            } else if (meetingDetail['type'] == 1) {
                              copyLink =
                                  meetingDetail["invitationUrl"] != null ? meetingDetail["invitationUrl"] : 'N/A';
                              Clipboard.setData(ClipboardData(text: copyLink));
                              GetBar(
                                backgroundColor: green,
                                duration: Duration(seconds: 2),
                                message: "Seminar Link Copy",
                              ).show();
                            }
                          },
                          child: Container(
                            decoration: boxDecoration(
                                color: colorPrimaryDark, radius: 5, bgColor: colorPrimaryDark.withOpacity(0.1)),
                            padding: EdgeInsets.fromLTRB(
                              spacing_middle,
                              spacing_control,
                              spacing_middle,
                              spacing_control,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Feather.share,
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                text(
                                  'Invite',
                                  textColor: colorPrimaryDark,
                                  fontFamily: fontSemibold,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (meetingDetail['type'] == 2)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              if (meetingDetail['payment_type'] == 2 && meetingDetail['payment_status'] == 2) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0.0,
                                        backgroundColor: Colors.transparent,
                                        child: successBox(context, meetingDetail),
                                      );
                                    });
                              } else {
                                String url = meetingDetail["webinar_link"].toString();
                                await launch(
                                  url,
                                  enableJavaScript: true,
                                );
                              }
                            },
                            child: Container(
                              decoration: boxDecoration(
                                color: green,
                                radius: 5,
                                bgColor: green.withOpacity(0.1),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                spacing_middle,
                                spacing_control,
                                spacing_middle,
                                spacing_control,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Feather.zap,
                                    size: 16,
                                    color: green,
                                  ),
                                  SizedBox(width: 5),
                                  text(
                                    'Join',
                                    textColor: green,
                                    fontFamily: fontSemibold,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => _buildMeetingDetails(context, meetingDetail),
                            );
                          },
                          child: Container(
                            decoration: boxDecoration(
                              color: colorPrimary,
                              radius: 5,
                              bgColor: colorPrimary.withOpacity(0.1),
                            ),
                            padding: EdgeInsets.fromLTRB(
                              spacing_middle,
                              spacing_control,
                              spacing_middle,
                              spacing_control,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Feather.info,
                                  size: 16,
                                  color: colorPrimary,
                                ),
                                SizedBox(width: 5),
                                text(
                                  'Details',
                                  textColor: colorPrimary,
                                  fontFamily: fontSemibold,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildMeetingDetails(BuildContext context, data) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: text(
                          data["title"] != null ? data["title"] : 'N/A',
                          maxLine: 2,
                        ),
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
                          color: textColorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 0.1,
                  color: colorPrimaryDark,
                  child: Divider(),
                ),
                Container(
                  width: double.infinity,
                  height: 10,
                ),
                rowHeading(
                  Translator.get("Date/Time"),
                  data["date"] != null
                      ? data["date"]
                      : "N/A" + data["time"] != null
                          ? data["time"]
                          : 'N/A',
                ),
                Container(
                  width: double.infinity,
                  height: 20,
                  child: Divider(),
                ),
                rowHeading(
                  Translator.get("City"),
                  data["city"] != null ? data["city"] : 'N/A',
                ),
                Container(
                  width: double.infinity,
                  height: 20,
                  child: Divider(),
                ),
                rowHeading(
                  Translator.get('Venue'),
                  data["venue"] != null ? data["venue"] : 'N/A',
                ),
                Container(
                  width: double.infinity,
                  height: 20,
                  child: Divider(),
                ),
                rowHeading(
                  Translator.get("Host"),
                  data["hostName"] != null ? data["hostName"] : 'N/A',
                ),
                Container(
                  width: double.infinity,
                  height: 20,
                  child: Divider(),
                ),
                rowHeading(
                  Translator.get("Co-Host"),
                  data["coHostName"] != null ? data["coHostName"] : 'N/A',
                ),
                Container(
                  width: double.infinity,
                  height: 20,
                  child: Divider(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget successBox(BuildContext context, meetingDetail) {
    var width = MediaQuery.of(context).size.width;

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
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              emailController.clear();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.close,
                color: textColorPrimary,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, color: green),
            child: Icon(
              Feather.file_text,
              color: white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: text(
              meetingDetail["title"] != null ? meetingDetail["title"] : 'N/A',
              textColor: textColorPrimary,
              fontFamily: fontBold,
              fontSize: textSizeMedium,
              maxLine: 2,
            ),
          ),
          Form(
            key: _purchaseFormKey,
            autovalidate: _autoValidation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                text(
                  Translator.get("Amount : ")! + meetingDetail['payment_amount'],
                  fontFamily: fontBold,
                  textColor: red,
                  fontSize: textSizeLarge,
                ),
                SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: validateEmail,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      contentPadding: const EdgeInsets.all(16.0),
                      hintText: Translator.get("eg.test@gmail.com"),
                      labelText: Translator.get("Enter Email For Webinar Link"),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();

                    setState(() {
                      _autoValidation = true;
                    });

                    if (_purchaseFormKey.currentState!.validate() && emailController.text != null) {
                      _confirmOrder(meetingDetail);
                    }

                    // Map sendData = {
                    //   "seminar_webinar_id": meetingDetail['id'],
                    //   'email': emailController.text,
                    //   "amount": meetingDetail['payment_amount']
                    // };
                    //
                    // if (_purchaseFormKey.currentState.validate()) if (paymentLink != null) {
                    //   handlePaymentGateway(paymentLink);
                    // } else if (emailController.text != null) {
                    //   Api.http.post('buy-webinar', data: sendData).then(
                    //     (response) {
                    //       setState(
                    //         () {
                    //           paymentLink = response.data['response']['longurl'];
                    //         },
                    //       );
                    //
                    //       handlePaymentGateway(paymentLink);
                    //     },
                    //   ).catchError(
                    //     (error) {
                    //       if (error.response.statusCode == 422) {
                    //         GetBar(
                    //           backgroundColor: Colors.red,
                    //           duration: Duration(seconds: 5),
                    //           message: error.response.data['errors'],
                    //         ).show();
                    //       } else if (error.response.statusCode == 401) {
                    //         GetBar(
                    //           backgroundColor: Colors.red,
                    //           duration: Duration(seconds: 5),
                    //           message: error.response.data['errors'],
                    //         ).show();
                    //       }
                    //     },
                    //   );
                    // }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: new BoxDecoration(
                      color: colorPrimary,
                      shape: BoxShape.rectangle,
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                    ),
                    alignment: Alignment.center,
                    child: text('Proceed to Payment'.toUpperCase(),
                        textColor: white, fontFamily: fontMedium, fontSize: textSizeNormal),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _confirmOrder(meetingDetail) {
    Api.http.post('buy-webinar', data: {
      "seminar_webinar_id": meetingDetail['id'],
      'email': emailController.text,
      "amount": meetingDetail['payment_amount']
    }).then((response) {
      if (response.data['status']) {
        orderId = response.data['order_id'];
        _proceedForRazorPay(response.data);
      } else {
        GetBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          message: response.data['message'],
        ).show();
      }
    });
  }

  void _proceedForRazorPay(Map data) {
    var options = {
      "key": data['key'],
      "amount": data['amount'],
      "name": data['user_name'],
      "description": data['description'],
      "prefill": {"contact": data['mobile_no'], "email": data['email']},
      "external": {
        "wallets": ["paytm"]
      },
      'notes': {'order_id': data['order_id']},
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print("errroe ${e.toString()}");
    }
  }

  void _initializeRazorpay() {
    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void onPaymentSuccess(PaymentSuccessResponse response) {
    _razorPayResponse(response.paymentId);
  }

  void onErrorFailure(PaymentFailureResponse response) {
    // Get.toNamed('shopping-thanks', arguments: orderId);
  }

  void onExternalWallet(ExternalWalletResponse response) {}

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void _razorPayResponse(String? paymentId) {
    Api.http.post('pay-webinar-success', data: {
      "order_id": orderId,
      "transaction_id": paymentId,
    }).then((response) {
      if (response.data['status']) {
        Get.offAllNamed("home");
        Get.toNamed("meeting_list");
        Get.toNamed(
          'meeting_details',
          arguments: {"id": meetingDetails!['id'], "name": meetingDetails!['name']},
        );
      } else {
        GetBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          message: response.data['message'],
        ).show();
      }
    });
  }
}
