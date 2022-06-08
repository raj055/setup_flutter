import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../services/api.dart';
import '../services/translator.dart';
import '../widget/paginated_list.dart';
import '../widget/theme.dart';

class Notification extends StatefulWidget {
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Notification'),
      apiFuture: (int page) async {
        return Api.http.get("notifications?page=$page");
      },
      listItemBuilder: _notificationBuilder,
    );
  }

  Widget _notificationBuilder(notification, int index) {
    return notification != null
        ? Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(notification['display_page']);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    decoration: boxDecoration(
                      radius: 10,
                      showShadow: true,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Icon(
                            Feather.bell,
                            color: colorPrimary,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                text(
                                  notification["title"],
                                  maxLine: 2,
                                  textColor: colorPrimary,
                                  fontFamily: fontSemibold,
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  notification["body"],
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      notification["created_at"],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                      Feather.bell,
                      color: colorPrimary,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    Translator.get("No Notification Found")!,
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
}
