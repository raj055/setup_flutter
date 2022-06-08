import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class AudioGift extends StatefulWidget {
  @override
  _AudioGiftState createState() => _AudioGiftState();
}

class _AudioGiftState extends State<AudioGift> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginatedList(
        apiFuture: (int page) async {
          return Api.http.get('gifts/${2}?page=$page');
        },
        listItemBuilder: audioGiftBuilder,
      ),
    );
  }

  Widget audioGiftBuilder(audio, int index) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (audio['expiryStatus'] == false) {
          Get.toNamed('learning-audio-list',
              arguments: {"videoData": audio['packageDescription'], "name": audio['name']});
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
                  audio['image'] != null
                      ? CachedNetworkImage(
                          imageUrl: audio['image'],
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
                                capitalize(audio['name']),
                                maxLine: 2,
                                textColor: colorPrimaryDark,
                                fontFamily: fontSemibold,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              text(
                                Translator.get("Gift by ")! + audio['giftBy'],
                                maxLine: 1,
                                textColor: colorPrimary,
                                fontFamily: fontSemibold,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              text(
                                audio['leftExpiryDays'],
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
