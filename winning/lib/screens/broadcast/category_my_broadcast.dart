import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class CategoryMyBroadcast extends StatefulWidget {
  @override
  _CategoryMyBroadcastState createState() => _CategoryMyBroadcastState();
}

class _CategoryMyBroadcastState extends State<CategoryMyBroadcast> {
  late Map broadcastCategory;

  Future? broadcast;

  Map? broadcastData;

  @override
  void initState() {
    broadcast = _broadcastCategory();
    super.initState();
  }

  Future _broadcastCategory() {
    return Api.http.get('broadcasts/category').then(
      (res) {
        setState(() {
          broadcastCategory = res.data;
        });
        return broadcastCategory;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translator.get('My Broadcast')!,
        ),
      ),
      body: FutureBuilder(
        future: broadcast,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }
          return broadcastCategory['list'].length > 0
              ? _broadcastListBuilder()
              : Center(
                  child: emptyWidget(
                    context,
                    'assets/images/no_result.png',
                    "${Translator.get('No Data Found')}",
                    "${Translator.get('There was no record based on the details you entered.')}",
                  ),
                );
        },
      ),
    );
    /*PaginatedList(
      pageTitle: Translator.get('My Broadcast'),
      apiFuture: (int page) async {
        return Api.http.get("broadcast-teams?page=$page");
      },
      listItemBuilder: _broadcastListBuilder,
    );*/
  }

  Widget _broadcastListBuilder() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: broadcastCategory['list'].length,
      itemBuilder: (context, index) {
        broadcastData = broadcastCategory['list'][index];
        return Row(
          children: <Widget>[
            Expanded(
              child: Container(
                color: white,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://542partners.com.au/wp-content/uploads/2014/09/announcement-icon.png',
                    ),
                  ),
                  title: text(
                    broadcastData!['name'],
                    textColor: colorPrimaryDark.withOpacity(0.8),
                    fontFamily: fontSemibold,
                  ),
                  subtitle: text(
                    'Tap here for broadcast list',
                    maxLine: 1,
                    overflow: TextOverflow.ellipsis,
                    fontSize: textSizeSmall,
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        broadcastData!['date'],
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed(
                      'broadcast-my',
                      arguments: broadcastCategory['list'][index],
                    );
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
