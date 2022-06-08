import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class UserHistory extends StatefulWidget {
  @override
  _UserHistoryState createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  SharedPreferences? preferences;
  Translator? translator;
  List<TargetFocus> targets = <TargetFocus>[];

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('History'),
      apiFuture: (int page) async {
        return Api.http.get("badge-history?page=$page");
      },
      listItemBuilder: _badgeHistoryBuilder,
    );
  }

  Widget _badgeHistoryBuilder(history, int index) {
    return Column(
      children: <Widget>[
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
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 5,
                  bottom: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    text(history['date']),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          history['status_id'] == 1
                              ? 'Pending'
                              : history['status_id'] == 2
                                  ? 'Approved'
                                  : history['status_id'] == 3
                                      ? 'Rejected'
                                      : 'N/A',
                          style: TextStyle(
                            color: white,
                            fontFamily: fontSemibold,
                          ),
                        ),
                      ),
                      color: history['status_id'] == 1
                          ? Colors.deepOrange
                          : history['status_id'] == 2
                              ? Colors.green
                              : history['status_id'] == 3
                                  ? Colors.red
                                  : Colors.black,
                    ),
                  ],
                ),
              ),
              Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 5),
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            child: SvgPicture.network(
                              history['icon'],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  text(
                                    history['badge'],
                                    fontFamily: fontBold,
                                    textColor: colorPrimary,
                                    fontSize: textSizeLargeMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (history['status_id'] == 2 || history['status_id'] == 3) Divider(thickness: 1),
              if (history['status_id'] == 2 || history['status_id'] == 3)
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 10, bottom: 10),
                      child: Row(
                        children: [
                          text(
                            history['status_id'] == 2
                                ? 'Approved By : '
                                : history['status_id'] == 3
                                    ? 'Rejected By :'
                                    : 'N/A',
                          ),
                          if (history['responseBy'] != null)
                            text(
                              history['responseBy'],
                              textColor: green,
                              fontFamily: fontSemibold,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
