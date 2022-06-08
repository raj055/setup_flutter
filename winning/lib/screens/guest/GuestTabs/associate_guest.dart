import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:url_launcher/url_launcher.dart';

import '../../../services/api.dart';
import '../../../services/size_config.dart';
import '../../../services/translator.dart';
import '../../../widget/FadeAnimation.dart';
import '../../../widget/paginated_list.dart';

class AssociateGuest extends StatefulWidget {
  @override
  _AssociateGuestState createState() => _AssociateGuestState();
}

class _AssociateGuestState extends State<AssociateGuest> {
  String selectTab = "2";
  var guestList;

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
    return PaginatedList(
      apiFuture: (int page) async {
        return Api.http
            .post('guest-user-lists?page=$page', data: {'level': selectTab});
      },
      listItemBuilder: associateBuilder,
    );
  }

  Widget associateBuilder(associate, index) => SizedBox(
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
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
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
                              associate["name"],
                              softWrap: true,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              associate["phone"],
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
                                IconButton(
                                  onPressed: () {
                                    launch("tel: ${associate["mobile"]}");
                                  },
                                  icon: Icon(
                                    Feather.phone_call,
                                    size: SizeConfig.width(5),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    launch("sms: ${associate["mobile"]}");
                                  },
                                  icon: Icon(
                                    Feather.message_square,
                                    size: SizeConfig.width(5),
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    launchWhatsApp(associate["mobile"], "");
                                  },
                                  icon: Icon(
                                    MaterialCommunityIcons.whatsapp,
                                    color: Colors.green,
                                    size: SizeConfig.width(5),
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
              ],
            ),
          ),
        ),
      );
}
