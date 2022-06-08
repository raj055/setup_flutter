import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class VideoGift extends StatefulWidget {
  @override
  _VideoGiftState createState() => _VideoGiftState();
}

class _VideoGiftState extends State<VideoGift> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginatedList(
        apiFuture: (int page) async {
          return Api.http.get('gifts/${1}?page=$page');
        },
        listItemBuilder: videoGiftBuilder,
      ),
    );
  }

  Widget videoGiftBuilder(video, int index) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (video['expiryStatus'] == false) {
          Get.toNamed('learning-video-list',
              arguments: {"videoData": video['packageDescription'], "name": video['name']});
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: boxDecoration(radius: 10, showShadow: true),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  video['image'] != null
                      ? CachedNetworkImage(
                          imageUrl: video['image'],
                          width: width / 3,
                          height: width / 2.8,
                          fit: BoxFit.fill,
                        )
                      : Image.asset(
                          'assets/images/placeholder.png',
                          width: width / 3,
                          height: width / 2.8,
                          fit: BoxFit.fill,
                        ),
                  Container(
                    width: width - (width / 3) - 35,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              text(
                                capitalize(video['name']),
                                maxLine: 2,
                                textColor: colorPrimaryDark,
                                fontFamily: fontSemibold,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              text(
                                Translator.get("Gift by ")! + video['giftBy'],
                                maxLine: 1,
                                textColor: colorPrimary,
                                fontFamily: fontSemibold,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              text(
                                video['leftExpiryDays'],
                                maxLine: 1,
                                textColor: red,
                                fontFamily: fontSemibold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.all(0),
        ),
      ),
    );
  }
}
