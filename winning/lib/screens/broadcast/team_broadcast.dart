import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class TeamBroadcast extends StatefulWidget {
  @override
  _TeamBroadcastState createState() => _TeamBroadcastState();
}

class _TeamBroadcastState extends State<TeamBroadcast> {
  String? text;
  TextEditingController? _sendMessageController;
  GlobalKey<PaginatedListState> myBroadcastPaginatedListKey = GlobalKey();

  final List<String> avatars = [
    'https://vectorified.com/image/avatar-icon-vector-30.jpg',
    'https://vectorified.com/image/avatar-icon-vector-30.jpg',
  ];

  Map? broadcastDetails;

  List messages = [];

  late SharedPreferences preferences;

  List<TargetFocus> targets = <TargetFocus>[];

  GlobalKey _refresh = GlobalKey();
  GlobalKey _message = GlobalKey();
  GlobalKey _submit = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
    _sendMessageController = TextEditingController();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("TeamBroadcast");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("TeamBroadcast", false).then((bool success) {
        initTargets();
        Future.delayed(
          Duration(milliseconds: 500),
          () {
            showTutorial();
          },
        );
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: PaginatedList(
        pageTitle: Translator.get('Team Broadcast'),
        appBarAction: <Widget>[],
        key: myBroadcastPaginatedListKey,
        apiFuture: (int page) async {
          return Api.http
              .get(
            'broadcasts/team?page=$page',
          )
              .then((res) {
            if (res.data['status']) {
              if (messages.length == 0 || page == 1) {
                messages = [];
              }
            }
            return res;
          });
        },
        listItemBuilder: _buildBroadcastDetail,
        listItemGetter: (item) {
          item['newDate'] =
              "${item['date'].toString().split('-')[2]}-${item['date'].toString().split('-')[1]}-${item['date'].toString().split('-')[0]}";
          messages.add(item);
          Future.delayed(Duration.zero, () async {
            setState(() {});
          });

          return item;
        },
        resetStateOnRefresh: true,
        isPullToRefresh: false,
        isReverse: true,
      ),
      bottomSheet: Container(
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 5),
                margin: EdgeInsets.only(bottom: 10, left: 15, right: 5),
                decoration: boxDecoration(
                  radius: 5,
                  showShadow: true,
                  bgColor: Colors.white60,
                ),
                child: TextFormField(
                  inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^ '))],
                  maxLines: 15,
                  controller: _sendMessageController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: Translator.get('Type your message'),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 12, bottom: 15, top: 10),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: colorPrimary,
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 15,
                  ),
                  onPressed: () {
                    if (_sendMessageController!.text.isNotEmpty && _sendMessageController!.text.trim().length > 0) {
                      FocusScope.of(context).requestFocus(FocusNode());

                      Map sendData = {
                        "message": _sendMessageController!.text,
                      };

                      Api.http.post('broadcasts/team', data: sendData).then((response) {
                        if (response.data['status']) {
                          _sendMessageController!.clear();
                          myBroadcastPaginatedListKey.currentState!.refresh();
                        }
                      }).catchError((error) {
                        print('err  $error');
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastDetail(detail, int index) {
    return Column(
      children: <Widget>[
        if (index + 1 == messages.length ||
            (index + 1 != 0 &&
                DateTime.now().difference(DateTime.parse(detail['newDate'])).inDays !=
                    DateTime.now().difference(DateTime.parse(messages[index + 1]['newDate'])).inDays))
          Container(
            height: h(7),
            child: Align(
              alignment: Alignment.center,
              child: Bubble(
                margin: BubbleEdges.only(top: 10),
                alignment: Alignment.center,
                nip: BubbleNip.no,
                color: primary.withOpacity(0.6),
                child: Text(
                  DateTime.now().difference(DateTime.parse(detail['newDate'])).inDays == 0
                      ? Translator.get("Today")!
                      : DateTime.now().difference(DateTime.parse(detail['newDate'])).inDays == 1
                          ? Translator.get("Yesterday")!
                          : detail['date'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: white,
                    fontSize: 11.0,
                  ),
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment(1, 0),
          child: sendMessageWidget(
            msg: detail['message'],
            time: detail['time'],
          ),
        ),
        if (index == 0) SizedBox(height: 60),
      ],
    );
  }

  Widget _customBubble({required String time, required String message}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: .5, spreadRadius: 1.0, color: Colors.black.withOpacity(.12))],
            color: white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(5.0),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 50.0),
                child: Text(message),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(time,
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 10.0,
                        )),
                    SizedBox(width: 3.0),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget sendMessageWidget({required String msg, required String time}) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 10.0, top: 4.0, bottom: 4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: _customBubble(
            message: msg,
            time: time,
          ),
        ),
      ),
    );
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "Refresh",
        keyTarget: _refresh,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get('Click here to refresh your screen to get latest message sent by you.')!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15.0,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Message",
        keyTarget: _message,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get('Click here to enter your valuable content to route in team.')!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15.0,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Submit",
        keyTarget: _submit,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get('Click here to initiate your message to broadcast.')!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15.0,
      ),
    );
  }

  void showTutorial() {
    TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.black,
        paddingFocus: 5,
        opacityShadow: 0.8,
        textSkip: "SKIP",
        onClickTarget: (target) {},
        onClickOverlay: (target) {},
        onFinish: () {},
        onSkip: () {})
      ..show();
  }

  void _afterLayout(_) {
    Future.delayed(Duration(milliseconds: 500), () {
      showTutorial();
    });
  }
}
