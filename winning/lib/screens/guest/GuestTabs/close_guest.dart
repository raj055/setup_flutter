import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:url_launcher/url_launcher.dart';

import '../../../services/api.dart';
import '../../../services/size_config.dart';
import '../../../services/translator.dart';
import '../../../widget/FadeAnimation.dart';
import '../../../widget/network_image.dart';
import '../../../widget/paginated_list.dart';

class CloseGuest extends StatefulWidget {
  @override
  _CloseGuestState createState() => _CloseGuestState();
}

class _CloseGuestState extends State<CloseGuest> {
  GlobalKey<PaginatedListState> closeGuestPaginatedListKey = GlobalKey();
  var guestList;
  String selectTab = "5";
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
            key: closeGuestPaginatedListKey,
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
            listItemBuilder: closeGuestBuilder,
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
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD1DCFF),
                blurRadius: 10.0, // has the effect of softening the shadow
                spreadRadius: 1.0, // has the effect of extending the shadow
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
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
                      guestList["total"] != null
                          ? guestList["total"].toString()
                          : "0",
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
                      guestList["lastTwentyEightDays"] != null
                          ? guestList["lastTwentyEightDays"].toString()
                          : "0",
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
                      guestList["lastSevenDays"] != null
                          ? guestList["lastSevenDays"].toString()
                          : "0",
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
                      guestList['pendingAction'] != null
                          ? guestList['pendingAction'].toString()
                          : "0",
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

  Widget closeGuestBuilder(closeGuest, index) => SizedBox(
        child: FadeAnimation(
          0.9,
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD1DCFF),
                  blurRadius: 10.0, // has the effect of softening the shadow
                  spreadRadius: 1.0, // has the effect of extending the shadow
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                20.0,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 15,
                    bottom: 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: IntrinsicHeight(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.account_circle,
                                size: SizeConfig.width(8),
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: SizeConfig.width(2)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              closeGuest["name"],
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              closeGuest["mobile"],
                              style: TextStyle(color: Colors.black54),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      launch("tel: ${closeGuest["mobile"]}");
                                    },
                                    icon: Icon(
                                      Feather.phone_call,
                                      size: SizeConfig.width(5),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      launch("sms: ${closeGuest["mobile"]}");
                                    },
                                    icon: Icon(
                                      Feather.message_square,
                                      size: SizeConfig.width(5),
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      launchWhatsApp(closeGuest["mobile"], "");
                                    },
                                    icon: Icon(
                                      MaterialCommunityIcons.whatsapp,
                                      color: Colors.green,
                                      size: SizeConfig.width(5),
                                    ),
                                  ),
                                ),
                                if (closeGuest['user'] == true)
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.android,
                                        color: Color(0XFF3DDB85),
                                        size: SizeConfig.width(5),
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
                    top: 5,
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
                            Text(
                              '${Translator.get('Date')}${':'}',
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              closeGuest["createdAt"],
                              style: TextStyle(
                                color: Colors.black,
                              ),
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
                            Text(
                              Translator.get('Days to Close')!,
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              closeGuest['day'] != null
                                  ? closeGuest['day'].toString()
                                  : "0",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

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
}
