import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class Broadcasts extends StatefulWidget {
  @override
  _BroadcastsState createState() => _BroadcastsState();
}

class _BroadcastsState extends State<Broadcasts> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Broadcasting'),
      apiFuture: (int page) async {
        return Api.http.get("broadcast-teams?page=$page");
      },
      listItemBuilder: _broadcastListBuilder,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('broadcast-new');
        },
        label: text(
          Translator.get('Create')!.toUpperCase(),
          textColor: white,
          fontFamily: fontBold,
        ),
        icon: Icon(
          Feather.plus,
          color: white,
        ),
        backgroundColor: colorPrimary,
      ),
    );
  }

  Widget _broadcastListBuilder(broadcast, int index) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            color: white,
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  broadcast['image'] != ""
                      ? broadcast['image']
                      : 'https://542partners.com.au/wp-content/uploads/2014/09/announcement-icon.png',
                ),
              ),
              title: text(
                broadcast['name'],
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
                    broadcast['created_at'],
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onTap: () {
                Get.toNamed(
                  'broadcast-view',
                  arguments: broadcast,
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
