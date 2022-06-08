import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:unicons/unicons.dart';

import '../main.dart';
import '../services/CountCtl.dart';
import '../services/api.dart';
import '../services/auth.dart';
import '../services/size_config.dart';
import '../services/storage.dart';
import '../services/translator.dart';
import '../widget/FadeAnimation.dart';
import '../widget/app_drawer.dart';
import '../widget/customWidget.dart';
import '../widget/indicator.dart';
import '../widget/theme.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TargetFocus> targets = <TargetFocus>[];

  GlobalKey _notes = GlobalKey();
  GlobalKey _upgrade = GlobalKey();
  GlobalKey _eLearning = GlobalKey();
  GlobalKey _eLearningPrime = GlobalKey();
  GlobalKey _seminar = GlobalKey();
  GlobalKey _dream = GlobalKey();
  GlobalKey _guest = GlobalKey();
  GlobalKey _learning = GlobalKey();

  late SharedPreferences? preferences;

  ScrollController _scrollController = ScrollController();
  ScrollController _gridViewController = ScrollController();

  int? touchedIndex;
  List<Map<String, dynamic>> categories = [];

  List<Map<String, dynamic>> _tools = [];

  bool isFinish = false;

  late TutorialCoachMark? tutorial;
  String? copyCode;

  // _HomeState() {
  //   Storage.get('cart').then((value) {
  //     Get.put(CountCtl(value != null ? value.length : 0));
  //   });
  // }

  @override
  void initState() {
    // PushNotificationManager().init();

    _dashboardApi = _futureBuild();

    super.initState();

    if (routerName != null) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Get.toNamed(routerName!).whenComplete(() {
          routerName = null;
        });
      });
    }
  }

  _populateCategories() {
    categories = [
      {
        'name': Translator.get(dotenv.env['PRODUCT_NAME']!),
        'icon': UniconsLine.dashboard,
        'page': 'elibrary_list',
        'key': _eLearning,
      },
      if (Auth.currentPackage() == 4)
        {
          'name': Translator.get('CEP Prime'),
          'icon': UniconsLine.atom,
          'page': 'cep-prime',
          'key': _eLearningPrime,
        },
      if (Platform.isAndroid ||
          dashboardData != null && dashboardData!.containsKey('isPaid') && dashboardData!['isPaid'])
        {
          'name': Translator.get('Meeting'),
          'icon': UniconsLine.meeting_board,
          'page': 'meeting_list',
          'arguments': {"data": "123"},
          'key': _seminar
        },
      {'name': Translator.get('Dream List'), 'icon': UniconsLine.cloud_lock, 'page': 'dream-list', 'key': _dream},
      {'name': Translator.get('Guest List'), 'icon': UniconsLine.users_alt, 'page': 'guest-list', 'key': _guest},
      {'name': Translator.get('Profile'), 'icon': UniconsLine.chat_bubble_user, 'page': 'profile-update', 'key': null},
    ];
  }

  _populateTools() {
    _tools = [
      {
        'name': Translator.get('Video'),
        'icon': UniconsLine.presentation_play,
        'page': 'video-tutorial',
        'color': Color(0xFF3700B3)
      },
      {
        'name': Translator.get('Audio'),
        'icon': UniconsLine.music,
        'page': 'audio-tutorial',
        'color': Color(0xFFFF0237)
      },
      {
        'name': Translator.get('PDF'),
        'icon': UniconsLine.file_alt,
        'page': 'ebook-tutorial',
        'color': Color(0xFFFFDE03)
      },
    ];
  }

  Future? _dashboardApi;
  Map? dashboardData;
  double teamPerformanceMaxY = 0;

  num teamTotal = 0;

  Future _futureBuild() {
    return Api.http.get('dashboard').then(
      (res) async {
        dashboardData = res.data;

        if (res.data['data']['userStatus'] == 2) {
          logoutUser();
        } else if (res.data['isExpiry']) {
          Get.offAllNamed('promo-code-list');
        } else {
          res.data['performanceChartData'].forEach(
            (chartData) {
              chartData['data'].forEach(
                (chartDetails) {
                  teamTotal += chartDetails['value'];
                  if (chartDetails['value'] > teamPerformanceMaxY) {
                    teamPerformanceMaxY = double.parse(
                      chartDetails['value'].toString(),
                    );
                  }
                },
              );
            },
          );

          setState(() {
            _populateCategories();
            _populateTools();
          });

          await Auth.setCurrentPackage(
            package: res.data["current_package"],
          );

          await Auth.setCep(cep: res.data['cep']);

          displayShowcase();
        }
        return res.data;
      },
    ).catchError(
      (error) {
        if (error.response.statusCode == 401) {
          Get.offAllNamed("login");
        }
      },
    );
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences!.getBool("dashboardShowShowcase");

    if (showcaseVisibilityStatus == null) {
      preferences!.setBool("dashboardShowShowcase", false).then(
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

  Future<bool> _onWillPop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: text(
          Translator.get('Are you sure you want to exit an app?'),
          isLongText: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(Translator.get('No')!),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: Text(Translator.get('Yes')!),
          ),
        ],
      ),
    );
    return Future.value(false);
  }

  _handleDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder(
        future: _dashboardApi,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorPrimary, colorAccent],
                  ),
                ),
              ),
              title: GestureDetector(
                onTap: () {
                  // 532570189

                  // Map sendData = {
                  //   "thumbnail": "https://winning-team-staging.s3.amazonaws.com/9379/18d8e0ad-bb43-437b-ba69-ad0770ec7b7b.jpeg",
                  //   "video_id": "dC4NRuKS4G0",
                  //   "vimeo_id": "532570189",
                  //   "title": "(Webinar) Aatmnirbhar Success Plan, description: By Rajeev Balwani",
                  //   "typeId": 1,
                  //   "typeName": "Video",
                  // };
                  //
                  // Get.toNamed(
                  //   'document_video_play',
                  //   arguments: sendData,
                  // );

                  // Get.toNamed('test1');
                },
                child: Text(
                  Translator.get(dotenv.env['APP_NAME']!)!,
                ),
              ),
              elevation: 0,
              leading: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/menu.svg",
                  color: white,
                  width: 25,
                  height: 25,
                ),
                onPressed: () {
                  _handleDrawer();
                },
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Get.toNamed('master_search');
                  },
                  icon: Icon(
                    UniconsLine.search,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                    _gridViewController.jumpTo(_gridViewController.position.minScrollExtent);

                    setState(() {
                      initTargets();
                      showTutorial();
                    });
                  },
                  icon: Icon(
                    UniconsLine.presentation_play,
                    size: 20,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    UniconsLine.bell,
                    size: 20,
                  ),
                  onPressed: () {
                    Get.toNamed('notification');
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (String page) {
                    Get.toNamed(page);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              UniconsLine.language,
                              size: 16,
                              color: textColorSecondary,
                            ),
                            SizedBox(width: 10),
                            text(Translator.get('Language')),
                          ],
                        ),
                        value: 'app-language',
                      ),
                      PopupMenuItem(
                        child: InkWell(
                          child: Row(children: [
                            Icon(
                              UniconsLine.sign_in_alt,
                              size: 16,
                              color: textColorSecondary,
                            ),
                            SizedBox(width: 10),
                            text(Translator.get('logout')),
                          ]),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                title: text(
                                  Translator.get('Are you sure you want to logout?'),
                                  fontFamily: fontSemibold,
                                  isLongText: true,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: text(
                                      Translator.get('No')!.toUpperCase(),
                                      fontFamily: fontBold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => logoutUser(),
                                    child: text(
                                      Translator.get('Yes')!.toUpperCase(),
                                      fontFamily: fontBold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ];
                  },
                ),
              ],
            ),
            drawer: SafeArea(
              child: AppDrawer(
                name: dashboardData!["data"]["userName"],
                packageName: dashboardData!["package"],
                packageId: dashboardData!["current_package"],
                expiryAt: dashboardData!['expiryAt'],
                expiryLeftDays: dashboardData!['expiryAtLeftDays'],
                profileImage: dashboardData!['data']['userProfileImage'],
                isPaid: Platform.isAndroid
                    ? true
                    : dashboardData != null && dashboardData!.containsKey('isPaid')
                        ? dashboardData!['isPaid']
                        : false,
                // profileImage: dashboardData['data']['userProfileImage'] != null ||
                //         dashboardData['data']['userProfileImage'] != ''
                //     ? dashboardData['data']['userProfileImage']
                //     : profileImage,
              ),
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
//                      if (dashboardData['myBadge'].length > 0)
                      FadeAnimation(
                        0.8,
                        _buildHeader(context),
                      ),
                      if (!dashboardData!['isExpiry'])
                        FadeAnimation(
                          0.8,
                          _buildCategoriesGrid(context),
                        ),
                      _buildMemberRaiseRequest(context),
                      if (Auth.currentPackage() == 4) ...[
                        FadeAnimation(
                          0.9,
                          _buildMemberDownLineRequest(context),
                        ),
                      ],
                      if (Auth.currentPackage() == 1 || Auth.currentPackage() == 2 || Auth.currentPackage() == 3) ...[
                        // if (Platform.isAndroid || dashboardData != null && dashboardData.containsKey('isPaid') && dashboardData['isPaid'])
                        FadeAnimation(
                          1.0,
                          _buildCoin(context),
                        ),
                        SizedBox(height: 5),
                      ],
                      FadeAnimation(
                        1.2,
                        _pieChart(context),
                      ),
                      SizedBox(height: 5),
                      FadeAnimation(
                        1.2,
                        _buildGridBox(context),
                      ),
                      if (Auth.currentPackage() == 3 || Auth.currentPackage() == 4)
                        FadeAnimation(
                          1.4,
                          _buildTeamChart(context),
                        ),
                      SizedBox(height: 15),
                      FadeAnimation(
                        1.5,
                        _buildNoteStrip(context),
                      ),
                      SizedBox(height: 15),
                      FadeAnimation(
                        1.6,
                        _buildButton(context),
                      ),
                      if (Platform.isAndroid ||
                          dashboardData != null && dashboardData!.containsKey('isPaid') && dashboardData!['isPaid'])
                        FadeAnimation(
                          1.7,
                          _buildOtherToolGrid(context),
                        ),
                      SizedBox(height: 15),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget mOption(var icon, var value, var subValue, var iconColor, var bgColor) {
    var width = MediaQuery.of(context).size.width;

    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
          width: width * 0.08,
          height: width * 0.08,
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              text(
                value,
                fontFamily: fontMedium,
                textColor: colorPrimaryDark,
                isLongText: true,
              ),
              text(
                subValue,
                textColor: textColorSecondary,
                fontSize: 16.0,
                isLongText: true,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: white,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorPrimary, colorAccent],
          ),
          color: colorPrimary,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed('profile-update');
                // Get.toNamed('genealogy');
              },
              child: CircleAvatar(
                radius: 40,
                backgroundImage: (dashboardData!['data']['userProfileImage'] != null &&
                        dashboardData!['data']['userProfileImage'] != ""
                    ? NetworkImage(dashboardData!['data']['userProfileImage'])
                    : AssetImage(profileImage)) as ImageProvider<Object>?,
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: text(
                          dashboardData!["data"]["userName"] != null ? dashboardData!["data"]["userName"] : "N/A",
                          fontFamily: fontBold,
                          textColor: white,
                          fontSize: textSizeLargeMedium,
                          isLongText: true,
                        ),
                      ),
                      if (dashboardData!['myBadge'].length > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: new BorderRadius.only(
                              bottomLeft: const Radius.circular(16.0),
                              topLeft: const Radius.circular(16.0),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                          child: Row(
                            children: [
                              SvgPicture.network(
                                dashboardData!['myBadge']['image'],
                                height: 15,
                                width: 15,
                                color: white,
                              ),
                              SizedBox(width: 5),
                              text(
                                dashboardData!['myBadge']['badgeName'],
                                textColor: white,
                                fontSize: textSizeSmall,
                                textAllCaps: true,
                                fontFamily: fontSemibold,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        text('WT App Code : ', textColor: white),
                        text(
                          dashboardData!["data"]["code"] != null ? dashboardData!["data"]["code"] : null,
                          textColor: white,
                          isLongText: true,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            copyCode = dashboardData!["data"]["code"];
                            Clipboard.setData(
                              ClipboardData(text: copyCode),
                            );
                            GetBar(
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                              message: Translator.get('Member code copied')!,
                            ).show();
                          },
                          child: Icon(
                            Feather.copy,
                            size: 16,
                            color: white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (dashboardData!['data']['vestige_id'] != null)
                    Row(
                      children: [
                        text('Vestige ID : ', textColor: white),
                        text(
                          dashboardData!['data']["vestige_id"].toString() != null
                              ? dashboardData!['data']["vestige_id"].toString()
                              : null,
                          textColor: white,
                          isLongText: true,
                        ),
                      ],
                    ),
                  if (dashboardData!["data"]["userMobile"].toString().isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Feather.smartphone,
                            size: 13,
                            color: white,
                          ),
                        ),
                        SizedBox(width: 5),
                        if (dashboardData!["data"]["userMobile"] != null)
                          text(
                            dashboardData!["data"]["userMobile"],
                            textColor: white,
                          ),
                      ],
                    ),
                  if (dashboardData!["data"]["userEmail"].toString().isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Feather.mail,
                            size: 13,
                            color: white,
                          ),
                        ),
                        SizedBox(width: 5),
                        if (dashboardData!["data"]["userEmail"] != null)
                          text(
                            dashboardData!["data"]["userEmail"],
                            textColor: white,
                          ),
                      ],
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        color: white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: text(
              Translator.get('Top picks for you'),
              fontFamily: fontSemibold,
              fontSize: textSizeLargeMedium,
              textColor: colorPrimaryDark,
            ),
          ),
          Container(
            height: 116,
            child: GridView.builder(
              controller: _gridViewController,
              padding: EdgeInsets.symmetric(vertical: 5),
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 10.0,
              ),
              itemBuilder: (_, int index) {
                return GestureDetector(
                  onTap: () {
                    Map? arguments;

                    if (categories[index].containsKey("arguments")) {
                      arguments = categories[index]['arguments'];
                    }

                    Get.toNamed(
                      categories[index]['page'],
                      arguments: arguments,
                    ).then(
                      (value) {
                        setState(
                          () {
                            _dashboardApi = _futureBuild();
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    child: Column(
                      key: categories[index]['key'],
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0x95E9EBF0),
                            ),
                            width: width * 0.17,
                            height: width * 0.17,
                            child: Icon(
                              categories[index]['icon'],
                              color: colorPrimary,
                              size: 30,
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Expanded(
                          child: text(
                            categories[index]['name'],
                            textColor: textColorSecondary,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              itemCount: categories.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => _goToGuestTab(),
                  child: _buildTile(
                      color: Color(0xFFFFFFFF),
                      icon: UniconsLine.users_alt,
                      // title: Translator.get("Guest"),
                      title: Translator.get('Guest List'),
                      data: dashboardData!["data"]["newGuests"].toString(),
                      navigate: "See All",
                      simpleIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: textColorSecondary,
                        size: textSizeSmall,
                      ),
                      navigateIcon: dashboardData!["data"]["previousDayGuestCount"] <
                              dashboardData!["data"]["currentDayGuestCount"]
                          ? Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 25,
                            )
                          : dashboardData!["data"]["previousDayGuestCount"] >
                                  dashboardData!["data"]["currentDayGuestCount"]
                              ? Icon(
                                  Icons.trending_down,
                                  color: Colors.red,
                                  size: 25,
                                )
                              : Icon(null)),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () => _goToGuestTab(argument: "Follow"),
                  child: _buildTile(
                    color: Color(0xFFFFFFFF),
                    icon: UniconsLine.folder_check,
                    title: Translator.get("Follow Ups"),
                    data: dashboardData!["data"]["followUpGuests"].toString(),
                    navigate: "See All",
                    simpleIcon: Icon(
                      Icons.arrow_forward_ios,
                      color: textColorSecondary,
                      size: textSizeSmall,
                    ),
                    navigateIcon: dashboardData!["data"]["previousDayFollowUpCount"] <
                            dashboardData!["data"]["currentDayFollowUpCount"]
                        ? Icon(
                            Icons.trending_up,
                            color: Colors.green,
                            size: 25,
                          )
                        : dashboardData!["data"]["previousDayFollowUpCount"] >
                                dashboardData!["data"]["currentDayFollowUpCount"]
                            ? Icon(
                                Icons.trending_down,
                                color: Colors.red,
                                size: 25,
                              )
                            : Icon(null),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => _goToGuestTab(argument: "Invited"),
                  child: _buildTile(
                    color: Color(0xFFFFFFFF),
                    icon: UniconsLine.invoice,
                    title: Translator.get("Invited"),
                    data: dashboardData!["data"]["invitedGuests"].toString(),
                    navigate: "See All",
                    simpleIcon: Icon(
                      Icons.arrow_forward_ios,
                      color: textColorSecondary,
                      size: textSizeSmall,
                    ),
                    navigateIcon: dashboardData!["data"]["previousDayInvitedCount"] <
                            dashboardData!["data"]["currentDayInvitedCount"]
                        ? Icon(
                            Icons.trending_up,
                            color: Colors.green,
                            size: 25,
                          )
                        : dashboardData!["data"]["previousDayInvitedCount"] >
                                dashboardData!["data"]["currentDayInvitedCount"]
                            ? Icon(
                                Icons.trending_down,
                                color: Colors.red,
                                size: 25,
                              )
                            : Icon(null),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () => _goToGuestTab(argument: "Close"),
                  child: _buildTile(
                    color: Color(0xFFFFFFFF),
                    icon: UniconsLine.meh_closed_eye,
                    title: Translator.get("Close"),
                    data: dashboardData!["data"]["closedGuests"].toString(),
                    navigate: "See All",
                    simpleIcon: Icon(
                      Icons.arrow_forward_ios,
                      color: textColorSecondary,
                      size: textSizeSmall,
                    ),
                    navigateIcon: dashboardData!["data"]["previousDayClosedCount"] <
                            dashboardData!["data"]["currentDayClosedCount"]
                        ? Icon(
                            Icons.trending_up,
                            color: Colors.green,
                            size: 25,
                          )
                        : dashboardData!["data"]["previousDayClosedCount"] >
                                dashboardData!["data"]["currentDayClosedCount"]
                            ? Icon(
                                Icons.trending_down,
                                color: Colors.red,
                                size: 25,
                              )
                            : Icon(null),
                  ),
                ),
              ),
            ],
          ),
          if (Auth.currentPackage() == 2 || Auth.currentPackage() == 3 || Auth.currentPackage() == 4)
            SizedBox(height: 10),
          if (Auth.currentPackage() == 2 || Auth.currentPackage() == 3 || Auth.currentPackage() == 4) ...[
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _goToGuestTab(argument: "Presentation"),
                    child: _buildTile(
                      color: Color(0xFFFFFFFF),
                      icon: UniconsLine.meeting_board,
                      title: Translator.get("Presentation"),
                      data: dashboardData!["data"]["presentationGuests"].toString(),
                      navigate: "See All",
                      simpleIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: textColorSecondary,
                        size: textSizeSmall,
                      ),
                      navigateIcon: dashboardData!["data"]["previousDayPresentationCount"] <
                              dashboardData!["data"]["currentDayPresentationCount"]
                          ? Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 25,
                            )
                          : dashboardData!["data"]["previousDayPresentationCount"] >
                                  dashboardData!["data"]["currentDayPresentationCount"]
                              ? Icon(
                                  Icons.trending_down,
                                  color: Colors.red,
                                  size: 25,
                                )
                              : Icon(null),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _goToGuestTab(argument: "NotInterested"),
                    child: _buildTile(
                      color: Color(0xFFFFFFFF),
                      icon: UniconsLine.sad,
                      title: Translator.get("Not Interested"),
                      data: dashboardData!["data"]["diedGuests"].toString(),
                      navigate: "See All",
                      simpleIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: textColorSecondary,
                        size: textSizeSmall,
                      ),
                      navigateIcon: dashboardData!["data"]["previousDayNotInterestedCount"] <
                              dashboardData!["data"]["currentDayNotInterestedCount"]
                          ? Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 25,
                            )
                          : dashboardData!["data"]["previousDayNotInterestedCount"] >
                                  dashboardData!["data"]["currentDayNotInterestedCount"]
                              ? Icon(
                                  Icons.trending_down,
                                  color: Colors.red,
                                  size: 25,
                                )
                              : Icon(null),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _goToGuestTab(argument: "Associate"),
                    child: _buildTile(
                      color: Color(0xFFFFFFFF),
                      icon: UniconsLine.dashboard,
                      title: dashboardData!['packageData'][0]['value'],
                      data: dashboardData!["data"]["associates"].toString(),
                      navigate: "See All",
                      simpleIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: textColorSecondary,
                        size: textSizeSmall,
                      ),
                      navigateIcon: Icon(null),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed('guest-list', arguments: "Leader").then((value) {
                        if (mounted) {
                          setState(() {
                            _futureBuild();
                          });
                        }
                      });
                    },
                    child: _buildTile(
                      color: Color(0xFFFFFFFF),
                      icon: UniconsLine.parcel,
                      title: dashboardData!['packageData'][1]['value'],
                      data: dashboardData!["data"]["leaders"].toString(),
                      navigate: "See All",
                      simpleIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: textColorSecondary,
                        size: textSizeSmall,
                      ),
                      navigateIcon: Icon(null),
                    ),
                  ),
                ),
              ],
            ),
            if (Auth.currentPackage() != 4) SizedBox(height: 10),
            if (Auth.currentPackage() != 4)
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goToGuestTab(argument: "guest"),
                      child: _buildTile(
                        color: Color(0xFFFFFFFF),
                        icon: UniconsLine.atom,
                        title: Translator.get('guest'),
                        data: dashboardData!["data"]["guests"].toString(),
                        navigate: "See All",
                        simpleIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: textColorSecondary,
                          size: textSizeSmall,
                        ),
                        navigateIcon: Icon(null),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(child: SizedBox.shrink()),
                ],
              ),
            if (Auth.currentPackage() == 4) SizedBox(height: 10),
            if (Auth.currentPackage() == 4)
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goToGuestTab(argument: "CoreCommittee"),
                      child: _buildTile(
                        color: Color(0xFFFFFFFF),
                        icon: UniconsLine.atom,
                        title: dashboardData!['packageData'][2]['value'],
                        data: dashboardData!["data"]["coreCommittee"].toString(),
                        navigate: "See All",
                        simpleIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: textColorSecondary,
                          size: textSizeSmall,
                        ),
                        navigateIcon: Icon(null),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goToGuestTab(argument: "guest"),
                      child: _buildTile(
                        color: Color(0xFFFFFFFF),
                        icon: UniconsLine.user,
                        title: Translator.get('guest'),
                        data: dashboardData!["data"]["guests"].toString(),
                        navigate: "See All",
                        simpleIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: textColorSecondary,
                          size: textSizeSmall,
                        ),
                        navigateIcon: Icon(null),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  void _goToGuestTab({String? argument}) {
    Get.toNamed('guest-list', arguments: argument).then((value) {
      setState(() {
        _futureBuild();
      });
    });
  }

  Widget _buildOtherToolGrid(BuildContext context) {
    return Column(
      key: _learning,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: text(
            Translator.get('Learning'),
            fontFamily: fontSemibold,
            fontSize: textSizeLargeMedium,
            textColor: colorPrimaryDark,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: boxDecoration(
            radius: 10,
            showShadow: true,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 35,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _tools.map((tool) {
                return Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => {Get.toNamed(tool['page'])},
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tool['color'],
                            ),
                            child: Icon(
                              tool['icon'],
                              color: white,
                            ),
                          ),
                          text(
                            tool['name'],
                            fontFamily: fontSemibold,
                          )
                        ],
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoin(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('upgrade_package');
      },
      child: Container(
        key: _upgrade,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: boxDecoration(
          radius: 10,
          showShadow: true,
        ),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
            ),
            child: Icon(
              Feather.trending_up,
              color: white,
            ),
          ),
          title: text(
            Translator.get('Upgrade to Next Level'),
            fontSize: textSizeLargeMedium,
            textColor: textColorPrimary,
            fontFamily: fontSemibold,
          ),
          subtitle: text(
            Translator.get('You will get all benefits of our App'),
            fontSize: 16.0,
            textColor: textColorSecondary,
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Color(0xFFC4C5C9),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteStrip(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('note');
      },
      child: Container(
        key: _notes,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: boxDecoration(
          radius: 10,
          showShadow: true,
        ),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: Icon(
              UniconsLine.notes,
              color: white,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: text(
              Translator.get('Notes'),
              fontSize: textSizeLargeMedium,
              textColor: colorPrimaryDark,
              fontFamily: fontSemibold,
            ),
          ),
          subtitle: text(
            Translator.get('Click here to create your business notes'),
            fontSize: 16.0,
            textColor: textColorSecondary,
          ),
          trailing: Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('activity');
                  },
                  child: _buildWikiCategory(
                    UniconsLine.comparison,
                    Translator.get('Personal Activity circle'),
                    colorPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('core-steps');
                  },
                  child: _buildWikiCategory(
                    UniconsLine.setting,
                    Translator.get("10 Core Steps"),
                    colorAccent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTeamChart(BuildContext context) {
    if (teamTotal > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: text(
              Translator.get('Team Performance'),
              fontFamily: fontSemibold,
              fontSize: textSizeLargeMedium,
              textColor: colorPrimaryDark,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1.10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(18)),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 25.0, left: 5.0, top: 25.0),
                                  child: LineChart(
                                    sampleData1(),
                                    swapAnimationDuration: const Duration(milliseconds: 250),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                thickness: 0.5,
                                color: Colors.grey,
                                endIndent: 30.0,
                                indent: 30.0,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const <Widget>[
                                    Indicator(
                                      color: Color(0xff4af699),
                                      text: 'New Guest',
                                      isSquare: true,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Indicator(
                                      color: Color(0xffaa4cfc),
                                      text: 'Presentation Guest',
                                      isSquare: true,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Indicator(
                                      color: Color(0xff27b6fc),
                                      text: 'Closed Guest',
                                      isSquare: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Center();
  }

  Widget _buildMemberRaiseRequest(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          if (Auth.currentPackage() == 2 || Auth.currentPackage() == 3) ...[
            // if (dashboardData != null && dashboardData['leaderRequest'] == null || dashboardData['leaderRequest']['status'] != 'Approved') ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(
                    'raise-request',
                    arguments: {
                      "isParent": dashboardData!['isParent'],
                      "upLine": "upLine",
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: boxDecoration(
                    radius: 10,
                    showShadow: true,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: mOption(
                    UniconsLine.envelope_upload,
                    'Connect',
                    'Request UpLine',
                    colorPrimary,
                    colorPrimary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            // ],
          ],
          if (Auth.currentPackage() == 2 || Auth.currentPackage() == 3) ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    Get.toNamed(
                      'raise-request',
                      arguments: {
                        "isChildren": dashboardData!['isChildren'],
                        "downLine": "downLine",
                      },
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: boxDecoration(
                    radius: 10,
                    showShadow: true,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: mOption(
                    UniconsLine.envelope_download,
                    'Connect',
                    'Request DownLine',
                    colorAccent,
                    colorAccent.withOpacity(0.2),
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildMemberDownLineRequest(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (mounted) {
              Get.toNamed(
                'raise-request',
                arguments: {
                  "isChildren": dashboardData!['isChildren'],
                  "downLine": "downLine",
                },
              );
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
            ),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              leading: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Icon(
                  UniconsLine.exchange,
                  color: white,
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: text(
                  Translator.get('Connecting'),
                  fontSize: textSizeLargeMedium,
                  textColor: colorPrimaryDark,
                  fontFamily: fontSemibold,
                ),
              ),
              subtitle: text(
                Translator.get('Send your connection to teammate'),
                fontSize: 16.0,
                textColor: textColorSecondary,
                isLongText: true,
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          textStyle: const TextStyle(
            color: Color(0xff72719b),
            fontFamily: fontBold,
            fontSize: 16,
          ),
          margin: 10,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          margin: 5,
          reservedSize: 25,
          getTitles: (value) {
            if (teamPerformanceMaxY < 10) {
              return value.toString();
            }
            return value % (teamPerformanceMaxY / 10).round() == 0 ? value.toStringAsFixed(0) : '';
          },
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      ),
      minX: 1,
      maxX: 7,
      minY: 0,
      lineBarsData: linesBarData1(),
      axisTitleData: FlAxisTitleData(
        leftTitle: AxisTitle(
          showTitle: true,
          margin: 0,
          titleText: 'Guest',
          textStyle: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        bottomTitle: AxisTitle(
          showTitle: true,
          margin: 0,
          reservedSize: 5.0,
          titleText: 'Last 7 Days',
          textStyle: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      preventCurveOverShooting: true,
      spots: [
        FlSpot(
          1,
          double.parse(
            dashboardData!['performanceChartData'][0]['data'][0]['value'].toString(),
          ),
        ),
        FlSpot(
          2,
          double.parse(
            dashboardData!['performanceChartData'][0]['data'][1]['value'].toString(),
          ),
        ),
        FlSpot(
          3,
          double.parse(
            dashboardData!['performanceChartData'][0]['data'][2]['value'].toString(),
          ),
        ),
        FlSpot(
          4,
          double.parse(
            dashboardData!['performanceChartData'][0]['data'][3]['value'].toString(),
          ),
        ),
        FlSpot(
          5,
          double.parse(
            dashboardData!['performanceChartData'][0]['data'][4]['value'].toString(),
          ),
        ),
        FlSpot(
          6,
          double.parse(
            dashboardData!['performanceChartData'][0]['data'][5]['value'].toString(),
          ),
        ),
        FlSpot(
          7,
          double.parse(
            dashboardData!['performanceChartData'][0]['data'][6]['value'].toString(),
          ),
        ),
      ],
      isCurved: true,
      colors: [
        const Color(0xff4af699),
      ],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    final LineChartBarData lineChartBarData2 = LineChartBarData(
      preventCurveOverShooting: true,
      spots: [
        FlSpot(
          1,
          double.parse(
            dashboardData!['performanceChartData'][1]['data'][0]['value'].toString(),
          ),
        ),
        FlSpot(
          2,
          double.parse(
            dashboardData!['performanceChartData'][1]['data'][1]['value'].toString(),
          ),
        ),
        FlSpot(
          3,
          double.parse(
            dashboardData!['performanceChartData'][1]['data'][2]['value'].toString(),
          ),
        ),
        FlSpot(
          4,
          double.parse(
            dashboardData!['performanceChartData'][1]['data'][3]['value'].toString(),
          ),
        ),
        FlSpot(
          5,
          double.parse(
            dashboardData!['performanceChartData'][1]['data'][4]['value'].toString(),
          ),
        ),
        FlSpot(
          6,
          double.parse(
            dashboardData!['performanceChartData'][1]['data'][5]['value'].toString(),
          ),
        ),
        FlSpot(
          7,
          double.parse(
            dashboardData!['performanceChartData'][1]['data'][6]['value'].toString(),
          ),
        ),
      ],
      isCurved: true,
      colors: [
        const Color(0xffaa4cfc),
      ],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(show: false, colors: [
        const Color(0x00aa4cfc),
      ]),
    );

    final LineChartBarData lineChartBarData3 = LineChartBarData(
      preventCurveOverShooting: true,
      spots: [
        FlSpot(
          1,
          double.parse(
            dashboardData!['performanceChartData'][2]['data'][0]['value'].toString(),
          ),
        ),
        FlSpot(
          2,
          double.parse(
            dashboardData!['performanceChartData'][2]['data'][1]['value'].toString(),
          ),
        ),
        FlSpot(
          3,
          double.parse(
            dashboardData!['performanceChartData'][2]['data'][2]['value'].toString(),
          ),
        ),
        FlSpot(
          4,
          double.parse(
            dashboardData!['performanceChartData'][2]['data'][3]['value'].toString(),
          ),
        ),
        FlSpot(
          5,
          double.parse(
            dashboardData!['performanceChartData'][2]['data'][4]['value'].toString(),
          ),
        ),
        FlSpot(
          6,
          double.parse(
            dashboardData!['performanceChartData'][2]['data'][5]['value'].toString(),
          ),
        ),
        FlSpot(
          7,
          double.parse(
            dashboardData!['performanceChartData'][2]['data'][6]['value'].toString(),
          ),
        ),
      ],
      isCurved: true,
      colors: const [
        Color(0xff27b6fc),
      ],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    return [
      lineChartBarData1,
      lineChartBarData2,
      lineChartBarData3,
    ];
  }

  Widget _pieChart(BuildContext context) {
    num total = 0;
    for (Map details in dashboardData!['chartData']) {
      total += details["value"];
    }

    if (total > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: text(
              Translator.get('Personal Performance'),
              fontFamily: fontSemibold,
              fontSize: textSizeLargeMedium,
              textColor: colorPrimaryDark,
            ),
          ),
          Container(
            height: h(45),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: PieChart(
                        PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (pieTouchResponse) {
                                setState(
                                  () {
                                    if (pieTouchResponse.touchInput is FlLongPressEnd ||
                                        pieTouchResponse.touchInput is FlPanEnd) {
                                      touchedIndex = -1;
                                    } else {
                                      touchedIndex = pieTouchResponse.touchedSectionIndex;
                                    }
                                  },
                                );
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 0,
                            centerSpaceRadius: h(10),
                            sections: showingSections(dashboardData) as List<PieChartSectionData>),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Indicator(
                            color: Color(0xff0293ee),
                            text: Translator.get('New Guests'),
                            isSquare: false,
                            size: SizeConfig.width(3.1),
                          ),
                          SizedBox(height: h(3)),
                          Indicator(
                            color: Color(0xfff8b250),
                            text: Translator.get('Invited'),
                            isSquare: false,
                            size: SizeConfig.width(3.1),
                          ),
                          SizedBox(height: h(3)),
                          Indicator(
                            color: Color(0xff845bef),
                            text: Translator.get('Presentation'),
                            isSquare: false,
                            size: SizeConfig.width(3.1),
                          ),
                          SizedBox(height: h(3)),
                          Indicator(
                            color: Color(0xff13d38e),
                            text: Translator.get('Followup'),
                            isSquare: false,
                            size: SizeConfig.width(3.1),
                          ),
                          SizedBox(height: h(3)),
                          Indicator(
                            color: Color(0xffe57373),
                            text: Translator.get('Closed'),
                            isSquare: false,
                            size: SizeConfig.width(3.1),
                          ),
                          SizedBox(height: h(3)),
                          Indicator(
                            color: Color(0xff212121),
                            text: Translator.get('Not Interested'),
                            isSquare: false,
                            size: SizeConfig.width(3.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Center();
  }

  Stack _buildWikiCategory(IconData icon, String? label, Color color) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 5),
          alignment: Alignment.centerRight,
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              icon,
              size: 40,
              color: white,
            ),
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: white,
              ),
              const SizedBox(height: 16.0),
              text(
                label,
                textColor: white,
                fontFamily: fontBold,
              )
            ],
          ),
        )
      ],
    );
  }

  void initTargets() {
    if (categories != null) {
      targets.add(
        TargetFocus(
          identify: "E-Learning",
          keyTarget: _eLearning,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    text(
                      Translator.get("Constant E-learning program can be accessed from here."),
                      fontFamily: fontBold,
                      textColor: white,
                      fontSize: textSizeNormal,
                      isLongText: true,
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

    targets.add(
      TargetFocus(
        identify: "Seminars",
        enableOverlayTab: true,
        keyTarget: _seminar,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(
                    Translator.get("Get all details of Seminars and Webinars here."),
                    isLongText: true,
                    fontFamily: fontBold,
                    textColor: white,
                    fontSize: textSizeNormal,
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
        identify: "Dream list",
        enableOverlayTab: true,
        keyTarget: _dream,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(
                    Translator.get("Add your dreams and see already added dreams here."),
                    fontFamily: fontBold,
                    textColor: white,
                    fontSize: textSizeNormal,
                    isLongText: true,
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
        identify: "Guest",
        enableOverlayTab: true,
        keyTarget: _guest,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(
                    Translator.get("See all New added guest here."),
                    fontFamily: fontBold,
                    textColor: white,
                    fontSize: textSizeNormal,
                    isLongText: true,
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

    if (Auth.currentPackage() == 1 || Auth.currentPackage() == 2 || Auth.currentPackage() == 3) {
      targets.add(
        TargetFocus(
          identify: "Upgrade",
          enableOverlayTab: true,
          keyTarget: _upgrade,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Translator.get("You can upgrade yourself from here, you just need to enter Activation code.")!,
                      style: TextStyle(
                        fontFamily: fontBold,
                        color: white,
                        fontSize: 20.0,
                      ),
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

    targets.add(
      TargetFocus(
        identify: "Notes",
        enableOverlayTab: true,
        keyTarget: _notes,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(
                    Translator.get("Add your notes here for your reference."),
                    fontFamily: fontBold,
                    textColor: white,
                    fontSize: textSizeNormal,
                    isLongText: true,
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
        identify: "Learning",
        enableOverlayTab: true,
        keyTarget: _learning,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  text(
                    "${Translator.get('Learn through Video, Audio and E-book from experts.')}",
                    fontFamily: fontBold,
                    textColor: white,
                    fontSize: textSizeNormal,
                    isLongText: true,
                  ),
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15,
      ),
    );
  }

  void showTutorial() {
    tutorial = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 5,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      onClickTarget: (target) {
        if (target.identify == "Dream list") {
          _gridViewController.animateTo(
            _gridViewController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInCubic,
          );
        }

        if (Auth.currentPackage() == 1 || Auth.currentPackage() == 2 || Auth.currentPackage() == 3) {
          if (target.identify == "Upgrade") {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInCubic,
            );
          }
        } else {
          if (target.identify == "Guest") {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInCubic,
            );
          }
        }

        if (target.identify == 'Learning') {
          isFinish = true;
          if (isFinish) isCheck(isFinish);
        }
      },
      onClickOverlay: (target) {
        if (target.identify == "Dream list") {
          _gridViewController.animateTo(
            _gridViewController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInCubic,
          );
        }

        if (Auth.currentPackage() == 1 || Auth.currentPackage() == 2 || Auth.currentPackage() == 3) {
          if (target.identify == "Upgrade") {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInCubic,
            );
          }
        } else {
          if (target.identify == "Guest") {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInCubic,
            );
          }
        }

        if (target.identify == 'Learning') {
          isFinish = true;
          if (isFinish) isCheck(isFinish);
        }
      },
      onFinish: () {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        _gridViewController.jumpTo(_gridViewController.position.minScrollExtent);
      },
      onSkip: () {},
    )..show();
  }

  void isCheck(isFinish) {
    tutorial!.finish();
    isFinish = false;
  }

  void _afterLayout(_) {
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        showTutorial();
      },
    );
  }

  Widget _buildTile({
    Color? color,
    IconData? icon,
    String? title,
    String? data,
    String? navigate,
    Icon? navigateIcon,
    Icon? simpleIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: textColorPrimary,
                size: textSizeLargeMedium,
              ),
              SizedBox(width: w(3)),
              Expanded(
                child: text(
                  title,
                  fontFamily: fontSemibold,
                  fontSize: textSizeMedium,
                  overflow: TextOverflow.fade,
                  textColor: textColorPrimary,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: text(
                          data,
                          textColor: colorPrimary,
                          fontFamily: fontBold,
                          fontSize: textSizeLarge,
                        ),
                      ),
                      navigateIcon!
                    ],
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      text(
                        navigate,
                        textColor: textColorSecondary,
                        fontFamily: fontSemibold,
                        fontSize: textSizeSMedium,
                      ),
                      simpleIcon!
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  List<PieChartSectionData?> showingSections(dashboardData) {
    return List.generate(
      6,
      (i) {
        final isTouched = i == touchedIndex;
        final double fontSize = isTouched ? 25 : 16;
        final double radius = isTouched ? 60 : 50;
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: const Color(0xff0293ee),
              value: double.parse(dashboardData["chartData"][0]["value"].toString()),
              title:
                  dashboardData["chartData"][0]["value"] != 0 ? dashboardData["chartData"][0]["value"].toString() : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontFamily: fontBold, color: white),
            );
          case 1:
            return PieChartSectionData(
              color: const Color(0xfff8b250),
              value: double.parse(dashboardData["chartData"][1]["value"].toString()),
              title:
                  dashboardData["chartData"][1]["value"] != 0 ? dashboardData["chartData"][1]["value"].toString() : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontFamily: fontBold, color: white),
            );
          case 2:
            return PieChartSectionData(
              color: const Color(0xff845bef),
              value: double.parse(dashboardData["chartData"][2]["value"].toString()),
              title:
                  dashboardData["chartData"][2]["value"] != 0 ? dashboardData["chartData"][2]["value"].toString() : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontFamily: fontBold, color: white),
            );
          case 3:
            return PieChartSectionData(
              color: const Color(0xff13d38e),
              value: double.parse(dashboardData["chartData"][3]["value"].toString()),
              title:
                  dashboardData["chartData"][3]["value"] != 0 ? dashboardData["chartData"][3]["value"].toString() : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontFamily: fontBold, color: white),
            );
          case 4:
            return PieChartSectionData(
              color: const Color(0xffe57373),
              value: double.parse(dashboardData["chartData"][4]["value"].toString()),
              title:
                  dashboardData["chartData"][4]["value"] != 0 ? dashboardData["chartData"][4]["value"].toString() : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontFamily: fontBold, color: white),
            );
          case 5:
            return PieChartSectionData(
              color: const Color(0xff212121),
              value: double.parse(dashboardData["chartData"][5]["value"].toString()),
              title:
                  dashboardData["chartData"][5]["value"] != 0 ? dashboardData["chartData"][5]["value"].toString() : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontFamily: fontBold, color: white),
            );
          default:
            return null;
        }
      },
    );
  }
}

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Storage.get('cart').then((value) {
      Get.put(CountCtl(value != null ? value.length : 0));
      // Get.lazyPut(() => CountCtl(value != null ? value.length : 0));
    });
  }
}
