import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class MeetingList extends StatefulWidget {
  @override
  _MeetingListState createState() => _MeetingListState();
}

class _MeetingListState extends State<MeetingList> {
  Map? data;
  @override
  void initState() {
    data = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Meeting Categories'),
      apiFuture: (int page) async {
        return Api.http.get("meeting-list?page=$page");
      },
      listItemBuilder: _meetingBuilder,
    );
  }

  Widget _meetingBuilder(dynamic meeting, index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Get.toNamed(
              'meeting_details',
              arguments: {"id": meeting['id'], "name": meeting['name']},
            );
          },
          child: Container(
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
            ),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  child: meeting['thumbnail'] != null
                      ? PNetworkImage(
                          meeting['thumbnail'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: h(30),
                        )
                      : Image.asset("assets/images/placeholder.png"),
                  borderRadius: BorderRadius.circular(10),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 0, top: 8),
                  child: text(
                    ReCase(meeting['name']).titleCase,
                    fontFamily: fontSemibold,
                    maxLine: 2,
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        )
      ],
    );
  }
}
