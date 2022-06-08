import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:url_launcher/url_launcher.dart';

import '../../../services/api.dart';
import '../../../services/translator.dart';
import '../../../widget/FadeAnimation.dart';
import '../../../widget/network_image.dart';
import '../../../widget/paginated_list.dart';
import '../../../widget/theme.dart';

class InvitedGuest extends StatefulWidget {
  @override
  _InvitedGuestState createState() => _InvitedGuestState();
}

class _InvitedGuestState extends State<InvitedGuest> {
  GlobalKey<PaginatedListState> invitedPaginatedListKey = GlobalKey();
  Map? guestList;
  String selectTab = "2";
  Response? response;
  List? training;
  bool isRefresh = false;

  void launchWhatsApp(
    String? phone,
    String message,
  ) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw GetBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        message: Translator.get('WhatsApp not found')!,
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // if (training != null && training.length > 0)
        //    FadeAnimation(
        //      0.9,
        //      _buildPackage(context),
        //    ),
        if (guestList != null)
          FadeAnimation(
            1.0,
            _buildNewGuestRecord(context, guestList),
          ),
        Expanded(
          child: PaginatedList(
            key: invitedPaginatedListKey,
            apiFuture: (int page) async {
              return Api.http.post(
                'guest-lists?page=$page',
                data: {
                  'label_id': selectTab,
                },
              ).then((response) {
                if (guestList == null && training == null || isRefresh) {
                  setState(
                    () {
                      guestList = response.data;
                      training = response.data['training'];
                    },
                  );
                  isRefresh = false;
                }
                return response;
              });
            },
            listItemBuilder: invitedGuestBuilder,
            resetStateOnRefresh: true,
          ),
        ),
      ],
    );
  }

  Widget _buildNewGuestRecord(BuildContext context, guestList) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: boxDecoration(
            radius: 10,
            showShadow: true,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translator.get("LifeTime Total")!,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      guestList['total'] != null ? guestList['total'].toString() : "0",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translator.get("New in last 28 days")!,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      guestList['lastTwentyEightDays'] != null ? guestList['lastTwentyEightDays'].toString() : "0",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translator.get("New in last 7 Days")!,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      guestList['lastSevenDays'] != null ? guestList['lastSevenDays'].toString() : "0",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translator.get("Pending Action")!,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      guestList['pendingAction'] != null ? guestList['pendingAction'].toString() : "0",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget invitedGuestBuilder(invitedGuest, index) {
    return SizedBox(
      child: FadeAnimation(
        0.9,
        Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: boxDecoration(
                radius: 10,
                showShadow: true,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorPrimary.withOpacity(0.2),
                                  radius: 20,
                                  child: Icon(
                                    Feather.user,
                                    color: colorPrimary,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 10)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(
                                invitedGuest["name"],
                                textColor: textColorPrimary,
                                fontFamily: fontSemibold,
                                fontSize: textSizeMedium,
                                maxLine: 2,
                              ),
                              text(
                                invitedGuest["mobile"],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      launch("tel: ${invitedGuest["mobile"]}");
                                    },
                                    icon: Icon(
                                      Feather.phone_call,
                                      size: 20,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {
                                        launch("sms: ${invitedGuest["mobile"]}");
                                      },
                                      icon: Icon(
                                        Feather.message_circle,
                                        size: 20,
                                        color: red,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {
                                        launchWhatsApp(invitedGuest["mobile"], "");
                                      },
                                      icon: Icon(
                                        MaterialCommunityIcons.whatsapp,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(
                                "${Translator.get('Date')} : ",
                              ),
                              text(
                                invitedGuest["createdAt"],
                                textColor: colorPrimaryDark,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(
                                '${Translator.get('Invited For')}${'\n'}${Translator.get('Seminar/Webinar')}',
                                maxLine: 3,
                              ),
                              SizedBox(height: 6),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                _showDialog(invitedGuest["seminarList"]);
                              },
                              icon: Icon(
                                Feather.alert_circle,
                                color: colorPrimary,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: text(
                                Translator.get('Meeting Attended'),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: FlatButton(
                                  child: Text(
                                    Translator.get('Yes')!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    Api.http.put(
                                      "change-invited-guest-label",
                                      data: {
                                        "meeting_attended": "1",
                                        "guest_id": index,
                                        "mobile": invitedGuest["mobile"],
                                        "label_id": "3"
                                      },
                                    ).then(
                                      (res) {
                                        GetBar(
                                          backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                          duration: Duration(seconds: 5),
                                          message: res.data['message'],
                                        ).show();

                                        invitedPaginatedListKey.currentState!.refresh();
                                      },
                                    ).catchError(
                                      (error) {
                                        if (error.response.statusCode == 422) {
                                          GetBar(
                                            backgroundColor: error.data['status'] ? Colors.green : Colors.red,
                                            duration: Duration(seconds: 5),
                                            message: error.response.data['errors'],
                                          ).show();
                                        }
                                      },
                                    );
                                  },
                                  color: green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: FlatButton(
                                  child: Text(
                                    Translator.get('No')!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    Api.http.put(
                                      "change-invited-guest-label",
                                      data: {
                                        "meeting_attended": "2",
                                        "guest_id": index,
                                        "mobile": invitedGuest["mobile"],
                                        "label_id": "3"
                                      },
                                    ).then(
                                      (res) {
                                        GetBar(
                                          backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                          duration: Duration(seconds: 5),
                                          message: res.data['message'],
                                        ).show();

                                        invitedPaginatedListKey.currentState!.refresh();
                                      },
                                    ).catchError(
                                      (error) {
                                        if (error.response.statusCode == 422) {
                                          GetBar(
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 5),
                                            message: error.response.data['errors'],
                                          ).show();
                                        }
                                      },
                                    );
                                  },
                                  color: red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            if (invitedGuest['user'] == true)
              Container(
                width: 4,
                height: 35,
                margin: EdgeInsets.only(top: 16, left: 10),
                color: Color(0XFF3DDB85),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 110.0,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 5),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (_, int index) {
            return GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TrainingDescription(
                //       trainingData: training[index]['trainingData'],
                //     ),
                //   ),
                // );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color(0xFFF6F5F8),
                    maxRadius: 30.0,
                    child: PNetworkImage(
                      training![index]['thumbnail'],
                      fit: BoxFit.contain,
                      height: 30,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    training![index]['trainingData']['name'],
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            );
          },
          itemCount: training!.length,
        ),
      ),
    );
  }

  void _showDialog(seminarList) {
    if (seminarList != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Text(seminarList['title']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                seminarDetails(Translator.get("hostName")!, seminarList['hostName'] ?? ""),
                seminarDetails(Translator.get("hostMobile")!, seminarList['hostMobile'] ?? ""),
                seminarDetails(Translator.get("date")!, seminarList['date'] ?? "" + " " + seminarList['time'] ?? ""),
                seminarDetails(Translator.get("city")!, seminarList['city'] ?? ""),
                seminarDetails(Translator.get("coHostName")!, seminarList['coHostName'] ?? ""),
                seminarDetails(Translator.get("coHostMobile")!, seminarList['coHostMobile'] ?? ""),
                seminarDetails(Translator.get("venue")!, seminarList['venue'] ?? ""),
              ],
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    child: Text(
                      Translator.get("Close")!,
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Text(Translator.get('No seminar/webinar data found')!),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    child: Text(
                      Translator.get('Close')!,
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
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

  Widget seminarDetails(String name, String details) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              name + " : ",
              style: TextStyle(fontSize: 15),
            ),
            Text(
              details,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        SizedBox(height: 5.0)
      ],
    );
  }
}
