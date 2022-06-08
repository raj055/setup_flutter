import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/size_config.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class LearningVideoList extends StatefulWidget {
  @override
  _LearningVideoListState createState() => _LearningVideoListState();
}

class _LearningVideoListState extends State<LearningVideoList> {
  Map? learningVideoData;

  @override
  void initState() {
    learningVideoData = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List descriptionList = learningVideoData!['videoData'];

    return Scaffold(
      appBar: AppBar(title: Text(learningVideoData!['name'])),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: descriptionList.length,
        itemBuilder: (BuildContext context, int index) {
          return _learningVideoList(descriptionList, index);
        },
      ),
    );
  }

  Widget _learningVideoList(descriptionList, index) {
    return FadeAnimation(
      0.9,
      GestureDetector(
        onTap: () {
          Get.toNamed(
            'learning/video_details',
            arguments: descriptionList[index],
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
                      child: PNetworkImage(
                        descriptionList[index]['thumbnail'],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: h(30),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, bottom: 0, top: 5),
                      child: text(
                        descriptionList[index]['title'],
                        fontFamily: fontSemibold,
                        maxLine: 2,
                        textColor: colorPrimary,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, bottom: 0, top: 5),
                      child: text(
                        descriptionList[index]['description'],
                        fontFamily: fontRegular,
                        maxLine: 2,
                        fontSize: textSizeSmall,
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
        // descriptionList[index]['description'],
      ),
    );
  }
}
