import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../services/api.dart';
import '../../../services/translator.dart';
import '../../../widget/paginated_list.dart';
import '../../../widget/theme.dart';

class MyTeam extends StatefulWidget {
  @override
  _MyTeamState createState() => _MyTeamState();
}

class _MyTeamState extends State<MyTeam> {
  Translator? translator;
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _creteTeam = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("myTeam");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("myTeam", false).then(
        (bool success) {
          initTargets();
          Future.delayed(
            Duration(milliseconds: 500),
            () {
              showTutorial();
            },
          );
        },
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('My Team'),
      apiFuture: (int page) async {
        return Api.http.get("teams?page=$page");
      },
      listItemBuilder: _teamBuilder,
      floatingActionButton: FloatingActionButton.extended(
        key: _creteTeam,
        onPressed: () {
          Get.toNamed('create-team');
        },
        label: text(
          Translator.get('Create Team')!.toUpperCase(),
          textColor: white,
          fontFamily: fontSemibold,
        ),
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }

  Widget _teamBuilder(dynamic team, int index) {
    return team != null
        ? Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: boxDecoration(
                  radius: 10,
                  showShadow: true,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.toNamed('team-details', arguments: team);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      text(
                        team['name'],
                        textColor: colorPrimaryDark,
                        fontFamily: fontSemibold,
                      ),
                      text(
                        team['created_at'],
                        fontSize: textSizeSMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: emptyWidget(
              context,
              'assets/images/no_result.png',
              "Translator.get('No Team Data Found'),",
              "${Translator.get('There was no record based on the details you entered.')}",
            ),
          );
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "CreateTeam",
        keyTarget: _creteTeam,
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
                    Translator.get('Click here to create your custom team to get better monitoring.')!,
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
