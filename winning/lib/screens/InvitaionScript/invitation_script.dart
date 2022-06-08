import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/customWidget.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class InvitationScript extends StatefulWidget {
  @override
  _InvitationScriptState createState() => _InvitationScriptState();
}

class _InvitationScriptState extends State<InvitationScript> {
  SharedPreferences? preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  var invitationId;

  @override
  void initState() {
    invitationId = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Invitation Script'),
      apiFuture: (int page) async {
        return Api.httpWithoutLoader.post(
          'invitation-scripts?page=$page',
          data: {'invitation_category_id': invitationId},
        );
      },
      listItemBuilder: _invitationBuilder,
      showLoader: true,
      loadingWidgetBuilder: _buildLoadingWidget,
    );
  }

  Widget _buildLoadingWidget() {
    return loadingWidget(barCount: 1);
  }

  Widget _invitationBuilder(invitation, int index) {
    return Container(
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: text(
                    invitation['title'],
                    textColor: colorPrimaryDark,
                    fontFamily: fontSemibold,
                    isLongText: true,
                    maxLine: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      new ClipboardData(
                        text: invitation['description'],
                      ),
                    );

                    Get.snackbar(
                      null,
                      Translator.get('Copied')!,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      margin: EdgeInsets.all(8),
                      colorText: Colors.white,
                    );
                  },
                  child: Icon(
                    Feather.copy,
                  ),
                )
              ],
            ),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: text(
                      invitation['description'],
                      isLongText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
