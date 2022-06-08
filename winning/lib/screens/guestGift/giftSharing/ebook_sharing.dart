import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../services/api.dart';
import '../../../services/translator.dart';
import '../../../widget/paginated_list.dart';
import '../../../widget/theme.dart';

class EBookGiftSharing extends StatefulWidget {
  @override
  _EBookGiftSharingState createState() => _EBookGiftSharingState();
}

class _EBookGiftSharingState extends State<EBookGiftSharing> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      apiFuture: (int page) async {
        return Api.http.get('user-gifts/${3}?page=$page');
      },
      listItemBuilder: eBookGiftBuilder,
    );
  }

  Widget eBookGiftBuilder(eBook, int index) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: boxDecoration(radius: 10, showShadow: true),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                eBook['image'] != null
                    ? CachedNetworkImage(
                        imageUrl: eBook['image'],
                        width: width / 3,
                        height: width / 2.8,
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        'assets/images/placeholder.png',
                        width: width / 3,
                        height: width / 2.8,
                        fit: BoxFit.fill,
                      ),
                Container(
                  width: width - (width / 3) - 35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            text(
                              capitalize(eBook['name']),
                              maxLine: 2,
                              textColor: colorPrimaryDark,
                              fontFamily: fontSemibold,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            text(
                              Translator.get("Gift To ")! + eBook['giftTo'],
                              maxLine: 1,
                              textColor: colorPrimary,
                              fontFamily: fontSemibold,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            text(
                              eBook['leftExpiryDays'],
                              maxLine: 1,
                              textColor: colorPrimaryDark,
                              fontFamily: fontSemibold,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        margin: EdgeInsets.all(0),
      ),
    );
  }
}
