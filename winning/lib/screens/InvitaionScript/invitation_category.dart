import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/customWidget.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class InvitationCategory extends StatefulWidget {
  @override
  _InvitationCategoryState createState() => _InvitationCategoryState();
}

class _InvitationCategoryState extends State<InvitationCategory> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Invitation Categories'),
      apiFuture: (int page) async {
        return Api.httpWithoutLoader.get("invitation-category?page=$page");
      },
      listItemBuilder: _invitationCategoryBuilder,
      showLoader: true,
      loadingWidgetBuilder: _buildLoadingWidget,
    );
  }

  Widget _buildLoadingWidget() {
    return loadingWidget(barCount: 0);
  }

  Widget _invitationCategoryBuilder(invitationCategory, int index) {
    return invitationCategory != null
        ? _meetingItems(invitationCategory, index)
        : Center(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Feather.calendar,
                      color: colorPrimary,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    Translator.get("No Invitation Categories Found")!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget _meetingItems(data, index) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Get.toNamed('invitation-script', arguments: data['id']);
            },
            child: Container(
              decoration: boxDecoration(
                radius: 10,
                showShadow: true,
              ),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                children: [
                  Icon(
                    Feather.file_text,
                    color: colorPrimary,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  text(
                    ReCase(data['name']).headerCase,
                    fontFamily: fontSemibold,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
