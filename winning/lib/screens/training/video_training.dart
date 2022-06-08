import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../services/size_config.dart';

class VideoTraining extends StatefulWidget {
  @override
  _VideoTrainingState createState() => _VideoTrainingState();
}

class _VideoTrainingState extends State<VideoTraining> {
  Map? _videoPlay;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    setState(() {
      _videoPlay = Get.arguments;
      _controller = YoutubePlayerController(
        flags: YoutubePlayerFlags(
          autoPlay: true,
          controlsVisibleAtStart: true,
        ),
        initialVideoId: _videoPlay!['video_id'],
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    if (_videoPlay == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Color(0xFFE9E9E9),
          appBar: AppBar(
            title: Text(_videoPlay!['title']),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            child: player,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          SizedBox(height: 20),
                          Text(
                            _videoPlay!['title'],
                            style: TextStyle(
                              fontSize: SizeConfig.height(3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _videoPlay!['description'],
                            style: TextStyle(
                              fontSize: SizeConfig.height(2),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
