import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/api.dart';
import '../services/size_config.dart';
import '../services/translator.dart';
import '../widget/network_image.dart';
import '../widget/paginated_list.dart';
import '../widget/theme.dart';

class NewsHistory extends StatefulWidget {
  @override
  _NewsHistoryState createState() => _NewsHistoryState();
}

class _NewsHistoryState extends State<NewsHistory> {
  SharedPreferences? preferences;
  List<TargetFocus> targets = <TargetFocus>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('News'),
      apiFuture: (int page) async {
        return Api.http.get("news?page=$page");
      },
      listItemBuilder: _newsBuilder,
    );
  }

  Widget _newsBuilder(news, int index) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: PNetworkImage(
                  news['image_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: h(25),
                ),
              ),
              SizedBox(height: 20),
              text(
                news['title'],
                maxLine: 3,
                textColor: colorPrimaryDark,
                fontFamily: fontSemibold,
                fontSize: textSizeLargeMedium,
              ),
              SizedBox(height: h(1)),
              text(
                news['description'],
                isLongText: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
