import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:vimeoplayer/vimeoplayer.dart';
import 'package:wakelock/wakelock.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../screens/Learning/video_details.dart';
import '../../services/size_config.dart';

class DocumentVideoPlay extends StatefulWidget {
  @override
  _DocumentVideoPlayState createState() => _DocumentVideoPlayState();
}

class _DocumentVideoPlayState extends State<DocumentVideoPlay> {
  Map? _videoPlay;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    Wakelock.enable();
    _videoPlay = Get.arguments;
    if (mounted) {
      if (_videoPlay!.containsKey('video_id') && _videoPlay!['video_id'] != null ||
          _videoPlay!.containsKey('audio_id') && _videoPlay!['audio_id'] != null) {
        setState(() {
          _controller = YoutubePlayerController(
            flags: YoutubePlayerFlags(
              forceHD: true,
              autoPlay: true,
              controlsVisibleAtStart: true,
            ),
            // initialVideoId: "-_KNHNqCqUo",
            initialVideoId: _videoPlay![_videoPlay!.containsKey('video_id') ? 'video_id' : 'audio_id'],
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
    // return Scaffold(
    //   resizeToAvoidBottomInset: false,
    //   appBar: MediaQuery.of(context).orientation == Orientation.portrait
    //       ? AppBar(
    //           leading: BackButton(color: Colors.white),
    //           title: Text(_videoPlay['title']),
    //           backgroundColor: Color(0xAA15162B),
    //         )
    //       : PreferredSize(
    //           child: Container(
    //             color: Colors.transparent,
    //           ),
    //           preferredSize: Size(0.0, 0.0),
    //         ),
    //   body: ListView(
    //     children: <Widget>[
    //       VimeoPlayer(
    //         id: _videoPlay['vimeo_id'],
    //         // id: '363505234',
    //         autoPlay: true,
    //       ),
    //     ],
    //   ),
    // );
    return _videoPlay!['vimeo_id'] != null ? buildVimeo() : buildBody();
    // return _videoPlay['vimeo_id'] != null ? buildBody() : buildVimeo();
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
          appBar: AppBar(
            title: Text(_videoPlay!['title']),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        child: player,
                        // child: _videoPlay['video_id'] != null ? player : buildFileNotFound(),

                        // borderRadius: BorderRadius.circular(10),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _videoPlay!['title'],
                              style: TextStyle(
                                fontSize: SizeConfig.height(2.5),
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
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildVimeo() {
    // return Scaffold(
    //   resizeToAvoidBottomInset: false,
    //   appBar: MediaQuery.of(context).orientation == Orientation.portrait
    //       ? AppBar(
    //           // leading: BackButton(color: Colors.white),
    //           title: Text("_videoPlay['title']"),
    //           // backgroundColor: Color(0xAA15162B),
    //         )
    //       : PreferredSize(
    //           child: Container(
    //             color: Colors.transparent,
    //           ),
    //           preferredSize: Size(0.0, 0.0),
    //         ),
    //   body: ListView(
    //     children: <Widget>[
    //       VimeoPlayer(
    //         id: '517036923',
    //         autoPlay: true,
    //       ),
    //     ],
    //   ),
    // );

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_videoPlay!['title']),
      ),
      body: ListView(
        children: <Widget>[
          if (_videoPlay!['vimeo_id'] != null)
            VimeoPlayer(
              // videoId: _videoPlay['vimeo_id'],
              id: _videoPlay!['vimeo_id'],
              autoPlay: true,
            )
          else
            buildFileNotFound(),
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
                        _videoPlay!['title'],
                        style: TextStyle(
                          fontSize: SizeConfig.height(2.5),
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
        ],
      ),
    );
  }
}
