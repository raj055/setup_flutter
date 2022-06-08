import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:vimeoplayer/vimeoplayer.dart';
import 'package:wakelock/wakelock.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../services/size_config.dart';

class VideoDetails extends StatefulWidget {
  @override
  _VideoDetailsState createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails> {
  Map? _videoDetails;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    Wakelock.enable();
    _videoDetails = Get.arguments;
    if (mounted) {
      if (_videoDetails!.containsKey('video_id') && _videoDetails!['video_id'] != null ||
          _videoDetails!.containsKey('audio_id') && _videoDetails!['audio_id'] != null) {
        setState(() {
          _controller = YoutubePlayerController(
            flags: YoutubePlayerFlags(
              autoPlay: true,
              controlsVisibleAtStart: true,
            ),
            initialVideoId: _videoDetails![_videoDetails!.containsKey('video_id') ? 'video_id' : 'audio_id'],
          );
        });
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoDetails!['vimeo_id'] != null ? buildVimeo() : buildBody();
  }

  Widget buildBody() {
    if (_videoDetails == null) {
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
            title: Text(_videoDetails!['title']),
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
                          _videoDetails!['video_id'] != null
                              ? ClipRRect(
                                  child: player,
                                  borderRadius: BorderRadius.circular(10),
                                )
                              : buildFileNotFound(),
                          SizedBox(height: 20),
                          Text(
                            _videoDetails!['title'],
                            style: TextStyle(
                              fontSize: SizeConfig.height(2.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _videoDetails!['description'],
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

  Widget buildVimeo() {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_videoDetails!['title']),
      ),
      body: ListView(
        children: <Widget>[
          _videoDetails!['vimeo_id'] != null
              ? VimeoPlayer(
                  id: _videoDetails!['vimeo_id'],
                  autoPlay: true,
                )
              : buildFileNotFound(),
          Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _videoDetails!['title'],
                        style: TextStyle(
                          fontSize: SizeConfig.height(2.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _videoDetails!['description'],
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
        ],
      ),
    );
  }
}

Widget buildFileNotFound() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          "File not found",
          style: TextStyle(
            fontSize: SizeConfig.height(2.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}
