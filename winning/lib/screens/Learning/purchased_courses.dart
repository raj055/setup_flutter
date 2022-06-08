import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class PurchasedCourses extends StatefulWidget {
  @override
  _PurchasedCoursesState createState() => _PurchasedCoursesState();
}

class _PurchasedCoursesState extends State<PurchasedCourses> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: "Purchase Courses",
      apiFuture: (int page) async {
        return Api.http.get("order-history?page=$page");
      },
      listItemBuilder: _coursesBuilder,
    );
  }

  Widget _coursesBuilder(courses, int index) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (courses['type'] == 'Video') {
              Get.toNamed('learning-video-list', arguments: {
                "videoData": courses['packageDescription'],
                "name": courses['name']
              });
            } else if (courses['type'] == 'Audio') {
              Get.toNamed('learning-audio-list', arguments: {
                "videoData": courses['packageDescription'],
                "name": courses['name']
              });
            } else if (courses['type'] == 'E-Book') {
              Get.toNamed('learning-ebook-list', arguments: {
                "eBookData": courses['packageDescription'],
                "name": courses['name']
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: boxDecoration(
                    radius: 10,
                    showShadow: true,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        child: PNetworkImage(
                          courses['image'],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: h(30),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, bottom: 0, top: 8),
                        child: text(
                          ReCase(courses['name']).titleCase,
                          maxLine: 2,
                          fontFamily: fontSemibold,
                          textColor: colorPrimaryDark,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
                SizedBox(height: 10)
              ],
            ),
          ),
        )
      ],
    );
  }
}
