import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart' hide Response;

import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';

class TrainingDescription extends StatefulWidget {
  final Map? trainingData;

  const TrainingDescription({
    Key? key,
    this.trainingData,
  }) : super(key: key);

  @override
  _TrainingDescriptionState createState() => _TrainingDescriptionState();
}

class _TrainingDescriptionState extends State<TrainingDescription> {
  @override
  Widget build(BuildContext context) {
    Map descriptionList = widget.trainingData!;

    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: AppBar(
        title: Text(Translator.get('Training Description')!),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            _buildVideoTools(descriptionList),
            SizedBox(height: 15),
            _buildAudioTools(descriptionList),
            SizedBox(height: 15),
            _buildReading(descriptionList),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTools(descriptionList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    child: Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 14,
                    ),
                    radius: 12,
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                  SizedBox(width: 15),
                  Text(
                    Translator.get("Video Training")!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Container(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: descriptionList["videos"].length,
              itemBuilder: (BuildContext context, int i) {
                return GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      'training/video_training',
                      arguments: descriptionList['videos'][i],
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    color: Colors.white,
                    height: 120,
                    width: 300,
                    child: Flex(
                      direction: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 0,
                            ),
                            child: PNetworkImage(
                              descriptionList['videos'][i]['thumbnail'],
                              fit: BoxFit.contain,
                              height: 100,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  descriptionList['videos'][i]['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: SizeConfig.width(2.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: SizeConfig.height(2),
                                ),
                                Text(
                                  descriptionList['videos'][i]['description'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: SizeConfig.width(2.7),
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioTools(descriptionList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    child: Icon(
                      Icons.audiotrack,
                      color: Colors.white,
                      size: 14,
                    ),
                    radius: 12,
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                  SizedBox(width: 15),
                  Text(
                    Translator.get("Audio Training")!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: GestureDetector(
            onTap: () {
              // Get.toNamed('learning-video-list', arguments: {
              //   "videoData": post['packageDescription'],
              //   "name": post['name']
              // });

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => LearningVideoList(
              //       learningVideoData: descriptionList['audios'],
              //       name: descriptionList['name'],
              //     ),
              //   ),
              // );
            },
            child: Container(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: descriptionList['audios'].length,
                itemBuilder: (BuildContext context, int i) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    color: Colors.white,
                    height: 120,
                    width: 300,
                    child: Flex(
                      direction: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 0,
                            ),
                            child: PNetworkImage(
                              descriptionList['audios'][i]['thumbnail'],
                              fit: BoxFit.contain,
                              height: 100,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  descriptionList['audios'][i]['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: SizeConfig.width(2.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: SizeConfig.height(2),
                                ),
                                Text(
                                  descriptionList['audios'][i]['description'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: SizeConfig.width(2.7),
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookTools(descriptionList, i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         EBookTraining(learningVideoData: descriptionList['ebooks']),
            //   ),
            // );
          },
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      descriptionList['ebooks'][i]['thumbnail'],
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: 150,
                height: 150,
              ),
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  color: Colors.black87,
                  child: Text(
                    descriptionList['ebooks'][i]['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildReading(descriptionList) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 14,
                    ),
                    radius: 12,
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                  SizedBox(width: 15),
                  Text(
                    Translator.get("Reading Training")!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Container(
            width: double.infinity,
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: descriptionList['ebooks'].length,
              itemBuilder: (BuildContext context, int i) {
                return _buildBookTools(descriptionList, i);
              },
            ),
          ),
        ),
      ],
    );
  }
}
