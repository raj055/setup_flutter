import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class BroadcastView extends StatefulWidget {
  @override
  _BroadcastViewState createState() => _BroadcastViewState();
}

class _BroadcastViewState extends State<BroadcastView> {
  GlobalKey<PaginatedListState> broadcastPaginatedListKey = GlobalKey();

  Map? broadcastDetails;

  TextEditingController _sendMessageController = TextEditingController();
  List messages = [];

  @override
  void initState() {
    broadcastDetails = Get.arguments;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf8f8f8),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Get.toNamed('edit-broadcast', arguments: broadcastDetails);
          },
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: AssetImage(
                      'Loading',
                    ),
                    image: Image.network(
                      broadcastDetails!['image'] != ""
                          ? broadcastDetails!['image']
                          : 'https://542partners.com.au/wp-content/uploads/2014/09/announcement-icon.png',
                      height: 35,
                      width: 10,
                    ).image,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    text(
                      broadcastDetails!['name'],
                      textColor: white,
                      fontFamily: fontSemibold,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: text(
                        Translator.get("online"),
                        fontSize: textSizeSMedium,
                        textColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 5),
            child: PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (dynamic value) {
                Get.toNamed('edit-broadcast', arguments: broadcastDetails);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 1,
                  child: text(Translator.get("Broadcast list info")),
                ),
              ],
            ),
          )
        ],
      ),
      body: PaginatedList(
        key: broadcastPaginatedListKey,
        apiFuture: (int page) async {
          return Api.http.post(
            'team-broadcast-list?page=$page',
            data: {"broadcast_team_id": broadcastDetails!['broadcast_team_id']},
          ).then((res) {
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
                  inputFormatters: [
                    BlacklistingTextInputFormatter(RegExp(r'^ '))
                  ],
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
                    if (_sendMessageController.text.isNotEmpty &&
                        _sendMessageController.text.trim().length > 0) {
                      FocusScope.of(context).requestFocus(FocusNode());

                      Map sendData = {
                        "message": _sendMessageController.text,
                        "broadcast_team_id":
                            broadcastDetails!['broadcast_team_id']
                      };

                      Api.http
                          .post('broadcasts/team', data: sendData)
                          .then((response) {
                        if (response.data['status']) {
                          _sendMessageController.clear();
                          broadcastPaginatedListKey.currentState!.refresh();
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
                DateTime.now()
                        .difference(DateTime.parse(detail['newDate']))
                        .inDays !=
                    DateTime.now()
                        .difference(
                            DateTime.parse(messages[index + 1]['newDate']))
                        .inDays))
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
                  DateTime.now()
                              .difference(DateTime.parse(detail['newDate']))
                              .inDays ==
                          0
                      ? Translator.get("Today")!
                      : DateTime.now()
                                  .difference(DateTime.parse(detail['newDate']))
                                  .inDays ==
                              1
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
            boxShadow: [
              BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12))
            ],
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
        padding: const EdgeInsets.only(
            right: 8.0, left: 10.0, top: 4.0, bottom: 4.0),
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
}
