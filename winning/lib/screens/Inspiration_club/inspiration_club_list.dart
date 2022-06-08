import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class InspirationClubList extends StatefulWidget {
  @override
  _InspirationClubListState createState() => _InspirationClubListState();
}

class _InspirationClubListState extends State<InspirationClubList> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Inspiration Club'),
      apiFuture: (int page) async {
        return Api.http.get("inspiration-club?page=$page");
      },
      listItemBuilder: _inspirationBuilder,
      appBarAction: <Widget>[
        IconButton(
          onPressed: () {
            Get.toNamed('inspiration-category-search');
          },
          icon: Icon(
            Feather.search,
          ),
        ),
      ],
    );
  }

  Widget _inspirationBuilder(inspiration, int index) {
    return inspiration != null
        ? Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  inspiration['videos'].length > 0
                      ? Get.toNamed(
                          'document_video_tool',
                          arguments: {
                            "details": inspiration['videos'],
                            "name": inspiration['name'],
                            "id": inspiration['id'],
                            "pageType": inspiration['pageType'],
                          },
                        )
                      : inspiration['audios'].length > 0
                          ? Get.toNamed(
                              'document_video_tool',
                              arguments: {
                                "details": inspiration['audios'],
                                "name": inspiration['name'],
                                "id": inspiration['id'],
                                "pageType": inspiration['pageType'],
                              },
                            )
                          : inspiration['ebooks'].length > 0
                              ? Get.toNamed(
                                  'document_ebook_view',
                                  arguments: {
                                    "details": inspiration['ebooks'],
                                    "name": inspiration['name'],
                                    "id": inspiration['id'],
                                    "pageType": inspiration['pageType'],
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
                                inspiration['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: h(25),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, bottom: 0, top: 8),
                              child: text(
                                ReCase(inspiration['name']).titleCase,
                                maxLine: 2,
                                fontFamily: fontSemibold,
                                textColor: colorPrimaryDark,
                              ),
                            ),
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
                    Translator.get("No Inspiration Club Tutorial Found")!,
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
