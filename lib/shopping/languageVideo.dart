import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../services/api.dart';
import '../../services/extension.dart';
import '../../services/size_config.dart';
import '../../widget/theme.dart';

class LanguageVideo extends StatefulWidget {
  const LanguageVideo({Key? key}) : super(key: key);

  @override
  _LanguageVideoState createState() => _LanguageVideoState();
}

class _LanguageVideoState extends State<LanguageVideo> {
  List languageVideo = [];
  late Future _future;

  Future<Map> getVideo() {
    return Api.http.get("shopping/introductory-video").then((response) {
      return response.data;
    });
  }

  @override
  void initState() {
    _future = getVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: white,
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }
          languageVideo = snapshot.data['list']['data'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(
                  'Choose your language',
                  textAllCaps: true,
                  fontFamily: fontBold,
                ),
                20.height,
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (int i = 0; i < languageVideo.length; i++) _languageVideoBuilder(i),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _languageVideoBuilder(i) {
    print(" languageVideo[i]['language'] ${languageVideo[i]['language']}");
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15,
      ),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: colorAccent,
        child: text(
          languageVideo[i]['language'],
          fontFamily: fontBold,
          textColor: white,
          isCentered: true,
        ),
      ).onClick(() {
        if (languageVideo[i]['link'] != null) {
          Get.to(
            () => VideoWatch(
              languageData: languageVideo[i],
            ),
          );
        } else {
          GetBar(
            duration: Duration(seconds: 3),
            message: 'Video not found',
            backgroundColor: Colors.red,
          ).show();
        }
      }),
    );
  }
}

class VideoWatch extends StatefulWidget {
  final Map? languageData;

  const VideoWatch({Key? key, this.languageData}) : super(key: key);

  @override
  _VideoWatchState createState() => _VideoWatchState();
}

class _VideoWatchState extends State<VideoWatch> {
  late YoutubePlayerController _controller;

  String? youtubeLink;

  @override
  void initState() {
    Wakelock.enable();

    setState(() {
      youtubeLink = widget.languageData!['link'].split('embed/').sublist(1).join('embed/').trim();
      _controller = YoutubePlayerController(
        flags: YoutubePlayerFlags(
          forceHD: true,
          autoPlay: true,
          controlsVisibleAtStart: true,
        ),
        // initialVideoId: "geKLYcY6KWk",
        initialVideoId: youtubeLink!,
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    _controller.dispose();
    super.dispose();
  }

  setData(String key, String value) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: key, value: value);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            elevation: 2.0,
            title: Text(widget.languageData!['language']),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      child: player,
                      // borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            height: h(8.0),
            decoration: BoxDecoration(
              color: colorAccent,
            ),
            child: Center(
              child: text(
                'Continue',
                textColor: white,
                fontFamily: fontBold,
                fontSize: textSizeLargeMedium,
                textAllCaps: true,
              ),
            ).onClick(() {
              setData('isWellCome', 'true');
              Get.offAllNamed('/ecommerce');
            }),
          ),
        );
      },
    );
  }
}
