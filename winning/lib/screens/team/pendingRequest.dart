import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class PendingRequest extends StatefulWidget {
  @override
  _PendingRequestState createState() => _PendingRequestState();
}

class _PendingRequestState extends State<PendingRequest> {
  Future<bool> _onScreenBack() {
    Auth.currentPackage() == 1 ? Get.offAllNamed("guest-dashboard") : Get.offAllNamed("home");
    Get.toNamed('team_request_list');
    return Future.delayed(Duration.zero, () => true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onScreenBack,
      child: PaginatedList(
        pageTitle: Translator.get('Pending Request'),
        apiFuture: (int page) async {
          return Api.http.get("requests-list?page=$page");
        },
        listItemBuilder: _pendingRequestBuilder,
      ),
    );
  }

  Widget _pendingRequestBuilder(dynamic request, int index) {
    return request != null
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD1DCFF),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    Feather.user,
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: request['name'],
                                style: GoogleFonts.montserrat(
                                  color: Colors.black87,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: " (${request['code']})",
                                style: GoogleFonts.montserrat(
                                  color: Colors.black54,
                                  fontSize: 18.0,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                subtitle: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: <Widget>[
                            Icon(
                              request['mobile'] != "" ? Feather.smartphone : Feather.mail,
                              size: 12,
                            ),
                            SizedBox(width: 10),
                            Text(
                              request['mobile'] != "" ? request['mobile'] : request['email'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black45,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            color: Colors.amberAccent,
                          ),
                          child: text(request['requestType'] ?? ""),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              if (request['requestType'] == "Downline") {
                                _showDialog(request);
                              } else {
                                Api.http.post(
                                  'requests-status-change',
                                  data: {"request_id": request['id'], "status": "2"},
                                ).then(
                                  (response) async {
                                    if (response.data['status']) {
                                      Auth.currentPackage() == 1
                                          ? Get.offAllNamed("guest-dashboard")
                                          : Get.offAllNamed("home");
                                      Get.toNamed("team_request_list");
                                      Get.toNamed("pending_request");
                                      GetBar(
                                        backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                        duration: Duration(seconds: 5),
                                        message: response.data['message'],
                                      ).show();
                                    }
                                  },
                                ).catchError(
                                  (error) {
                                    if (error.response.statusCode == 422) {
                                      Navigator.of(context).pop();
                                      GetBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                        message: error.response.data['errors'],
                                      ).show();
                                    } else if (error.response.statusCode == 401) {
                                      Navigator.of(context).pop();
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
                            icon: Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                            label: Text(
                              "Approve".toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Api.http.post(
                                'requests-status-change',
                                data: {"request_id": request['id'], "status": "3"},
                              ).then(
                                (response) async {
                                  if (response.data['status']) {
                                    Auth.currentPackage() == 1
                                        ? Get.offAllNamed("guest-dashboard")
                                        : Get.offAllNamed("home");
                                    Get.toNamed("team_request_list");
                                    Get.toNamed("pending_request");
                                    GetBar(
                                      backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                      duration: Duration(seconds: 5),
                                      message: response.data['message'],
                                    ).show();
                                  }
                                },
                              ).catchError(
                                (error) {
                                  if (error.response.statusCode == 422) {
                                    Navigator.of(context).pop();
                                    GetBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                      message: error.response.data['errors'],
                                    ).show();
                                  } else if (error.response.statusCode == 401) {
                                    Navigator.of(context).pop();
                                    GetBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 5),
                                      message: error.response.data['errors'],
                                    ).show();
                                  }
                                },
                              );
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            label: Text(
                              Translator.get("Reject")!.toUpperCase(),
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Feather.user_check,
                      color: colorPrimary,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    Translator.get("No Pending Request Found")!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ),
          );
  }

  void _showDialog(request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            // Translator.get("Requests Status"),
            Translator.get(
                'You already have connected with Upline. If you want to connect with another upline then whenever he/she will accept your request, exciting upline will be removed. Please make sure you are aware about all this.')!,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          // content: Text(Translator.get("Member Name"), style: TextStyle(fontSize: 15)),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(
                    Translator.get("Cancel")!,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  child: Text(
                    // Translator.get("Send"),
                    "Accept",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Api.http.post(
                      'requests-status-change',
                      data: {"request_id": request['id'], "status": "2"},
                    ).then(
                      (response) async {
                        if (response.data['status']) {
                          Auth.currentPackage() == 1 ? Get.offAllNamed("guest-dashboard") : Get.offAllNamed("home");
                          Get.toNamed("team_request_list");
                          Get.toNamed("pending_request");
                          GetBar(
                            backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                            duration: Duration(seconds: 5),
                            message: response.data['message'],
                          ).show();
                        }
                      },
                    ).catchError(
                      (error) {
                        if (error.response.statusCode == 422) {
                          Navigator.of(context).pop();
                          GetBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                            message: error.response.data['errors'],
                          ).show();
                        } else if (error.response.statusCode == 401) {
                          Navigator.of(context).pop();
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
