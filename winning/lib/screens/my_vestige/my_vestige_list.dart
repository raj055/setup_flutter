import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class MyVestigeList extends StatefulWidget {
  @override
  _MyVestigeListState createState() => _MyVestigeListState();
}

class _MyVestigeListState extends State<MyVestigeList> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get(dotenv.env['VESTIGE_NAME']!),
      apiFuture: (int page) async {
        return Api.http.get("vestige?page=$page");
      },
      listItemBuilder: _vestigeBuilder,
      appBarAction: <Widget>[
        IconButton(
          onPressed: () {
            Get.toNamed('my-vestige-category-search');
          },
          icon: Icon(
            Feather.search,
          ),
        ),
      ],
    );
  }

  Widget _vestigeBuilder(dynamic vestige, int index) {
    return vestige != null
        ? Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  vestige['videos'].length > 0
                      ? Get.toNamed(
                          'document_video_tool',
                          arguments: {
                            "details": vestige['videos'],
                            "name": vestige['name'],
                            "id": vestige['id'],
                            "pageType": vestige['pageType'],
                          },
                        )
                      : vestige['audios'].length > 0
                          ? Get.toNamed(
                              'document_video_tool',
                              arguments: {
                                "details": vestige['audios'],
                                "name": vestige['name'],
                                "id": vestige['id'],
                                "pageType": vestige['pageType'],
                              },
                            )
                          : vestige['ebooks'].length > 0
                              ? Get.toNamed(
                                  'document_ebook_view',
                                  arguments: {
                                    "details": vestige['ebooks'],
                                    "name": vestige['name'],
                                    "id": vestige['id'],
                                    "pageType": vestige['pageType'],
                                  },
                                )
                              : Center();
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
                                vestige['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: h(25),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 0, top: 8),
                              child: text(
                                ReCase(vestige['name']).titleCase,
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
                      Feather.zap,
                      color: Theme.of(context).primaryColor,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    Translator.get("No")! +
                        Translator.get(dotenv.env['VESTIGE_NAME']!)! +
                        Translator.get("Tutorial Found")!,
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
