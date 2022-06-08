import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/size_config.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class DocumentVideoTool extends StatefulWidget {
  @override
  _DocumentVideoToolState createState() => _DocumentVideoToolState();
}

class _DocumentVideoToolState extends State<DocumentVideoTool> {
  Map? _documentVideoList;

  @override
  void initState() {
    _documentVideoList = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_documentVideoList!['name']),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (_documentVideoList!['details'][0]['typeName'] == "Audio") {
                Get.toNamed('document-Audio-search', arguments: {
                  "id": _documentVideoList!['id'],
                  "pageType": _documentVideoList!['pageType'],
                  "typeId": _documentVideoList!['details'][0]['typeId'],
                });
              }
              if (_documentVideoList!['details'][0]['typeName'] == "Video") {
                Get.toNamed('document-video-search', arguments: {
                  "id": _documentVideoList!['id'],
                  "pageType": _documentVideoList!['pageType'],
                  "typeId": _documentVideoList!['details'][0]['typeId'],
                });
              }
            },
            icon: Icon(
              Feather.search,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _documentVideoList!['details'].length,
        itemBuilder: (BuildContext context, int index) {
          return _videoList(_documentVideoList, index);
        },
      ),
    );
  }

  Widget _videoList(_documentVideoList, index) {
    return FadeAnimation(
      0.9,
      GestureDetector(
        onTap: () {
          Get.toNamed(
            'document_video_play',
            arguments: _documentVideoList['details'][index],
          );
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
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      child: _documentVideoList['details'][index]['thumbnail'] != null
                          ? PNetworkImage(
                              _documentVideoList['details'][index]['thumbnail'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: h(30),
                            )
                          : Image.asset("assets/images/placeholder.png"),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 0, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text(
                            ReCase(_documentVideoList['details'][index]['title']).titleCase,
                            maxLine: 2,
                            textColor: colorPrimaryDark,
                            fontFamily: fontSemibold,
                          ),
                          SizedBox(height: SizeConfig.height(1)),
                          text(
                            _documentVideoList['details'][index]['description'],
                            maxLine: 3,
                            fontSize: textSizeSmall,
                          ),
                        ],
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
      ),
    );
  }
}
