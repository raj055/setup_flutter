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

class PresentationGuest extends StatefulWidget {
  @override
  _PresentationGuestState createState() => _PresentationGuestState();
}

class _PresentationGuestState extends State<PresentationGuest> {
  GlobalKey<PaginatedListState> presentationGuestPaginatedListKey = GlobalKey();
  var guestList;
  String selectTab = "3";
  String followUp = "4";
  List<String?> _statusValues = [];
  List changeTypeLabels = [];
  late var labelList;
  Response? response;
  List? typeLabels = [];
  List? training;
  bool isRefresh = false;

  @override
  void initState() {
    _futureBuildLabels();
    super.initState();
  }

  Future _futureBuildLabels() {
    return Api.http.get('presentation-labels').then(
      (res) {
        labelList = res.data;
        typeLabels = labelList["guestLabels"];
        return res.data;
      },
    );
  }

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
        //   FadeAnimation(
        //     0.9,
        //     _buildPackage(context),
        //   ),
        if (guestList != null)
          FadeAnimation(
            1.0,
            _buildNewGuestRecord(context, guestList),
          ),
        Expanded(
          child: PaginatedList(
            key: presentationGuestPaginatedListKey,
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
            listItemBuilder: presentationGuestBuilder,
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

  Widget presentationGuestBuilder(presentationGuest, index) => SizedBox(
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
                                presentationGuest["name"],
                                textColor: textColorPrimary,
                                fontFamily: fontSemibold,
                                fontSize: textSizeMedium,
                                maxLine: 2,
                              ),
                              text(
                                presentationGuest["mobile"],
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
                                      launch("tel: ${presentationGuest["mobile"]}");
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
                                        launch("sms: ${presentationGuest["mobile"]}");
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
                                        launchWhatsApp(presentationGuest["mobile"], "");
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
                                presentationGuest["createdAt"],
                                textColor: colorPrimaryDark,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(
                                '${Translator.get('Invited For')}${'\n'}${Translator.get('Seminar/Webinar')}',
                                maxLine: 2,
                              ),
                              SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(child: _buildChangeStatusField(presentationGuest, index)),
                      Expanded(
                        child: TextButton(
                          child: text(
                            Translator.get('Start Follow Up'),
                            fontFamily: fontSemibold,
                            textColor: Colors.deepOrange,
                          ),
                          onPressed: () {
                            Api.http.post(
                              'change-guest-label',
                              data: {"mobile": presentationGuest["mobile"], "label_id": followUp},
                            ).then(
                              (response) async {
                                GetBar(
                                  backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                  duration: Duration(seconds: 5),
                                  message: response.data['message'],
                                ).show();

                                presentationGuestPaginatedListKey.currentState!.refresh();
                              },
                            ).catchError(
                              (error) {
                                if (error.response.statusCode == 422) {
                                  GetBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
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
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            if (presentationGuest['user'] == true)
              Container(
                width: 4,
                height: 35,
                margin: EdgeInsets.only(top: 16, left: 10),
                color: Color(0XFF3DDB85),
              ),
          ],
        ),
      ));

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

  Widget _buildChangeStatusField(data, index) {
    _statusValues.add(null);

    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: DropdownButtonFormField(
        isDense: true,
        isExpanded: true,
        value: _statusValues[index],
        onChanged: ((String? newValue) {
          setState(
            () {
              _statusValues[index] = newValue;
            },
          );

          Api.http.post(
            'change-guest-label',
            data: {"mobile": data["mobile"], "label_id": _statusValues[index]},
          ).then(
            (response) async {
              GetBar(
                backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                duration: Duration(seconds: 5),
                message: response.data['message'],
              ).show();

              presentationGuestPaginatedListKey.currentState!.refresh();
            },
          ).catchError(
            (error) {
              if (error.response.statusCode == 422) {
                GetBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
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
        }),
        hint: text(Translator.get('Change Status')),
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
        ),
        items: typeLabels!.map<DropdownMenuItem<String>>(
          (value) {
            return DropdownMenuItem<String>(
              value: value['id'].toString(),
              child: text(
                value['value'],
                fontFamily: fontSemibold,
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
