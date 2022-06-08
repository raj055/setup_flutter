import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_fonts/google_fonts.dart';
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
import '../widget/theme.dart';

class GuestDashboard extends StatefulWidget {
  @override
  _GuestDashboardState createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _GuestDashboardState() {
    Storage.get('cart').then(
      (value) {
        Get.put(CountCtl(value != null ? value.length : 0));
      },
    );
  }

  List<TargetFocus> targets = <TargetFocus>[];
  String? copyCode;

  GlobalKey _testimonials = GlobalKey();
  GlobalKey _dreamList = GlobalKey();
  GlobalKey _news = GlobalKey();
  GlobalKey _upgrade = GlobalKey();
  GlobalKey _notes = GlobalKey();
  GlobalKey _learning = GlobalKey();

  late SharedPreferences preferences;

  ScrollController _scrollController = ScrollController();
  ScrollController _gridViewController = ScrollController();

  List<Map<String, dynamic>> categories = [];
  bool isFinish = false;

  late TutorialCoachMark tutorial;

  final List<Map<String, dynamic>> tools = [
    {
      'name': Translator.get('Video'),
      'icon': UniconsLine.presentation_play,
      'page': 'video-tutorial',
      'color': Color(0xFF3700B3)
    },
    {'name': Translator.get('Audio'), 'icon': UniconsLine.music, 'page': 'audio-tutorial', 'color': Color(0xFFFF0237)},
    {'name': Translator.get('PDF'), 'icon': UniconsLine.file_alt, 'page': 'ebook-tutorial', 'color': Color(0xFFFFDE03)},
  ];

  @override
  void initState() {
    // PushNotificationManager().init();
    _dashboardApi = _futureBuild();

    setState(() {
      categories = [
        {
          'name': Translator.get('My Gifts'),
          'icon': UniconsLine.gift,
          'page': 'guest-gift',
        },
        {
          'name': Translator.get('Testimonials'),
          'icon': UniconsLine.thumbs_up,
          'page': 'testimonials',
          'key': _testimonials
        },
        {'name': Translator.get('Dream List'), 'icon': UniconsLine.cloud_lock, 'page': 'dream-list', 'key': _dreamList},
        {'name': Translator.get('News'), 'icon': UniconsLine.notes, 'page': 'news', 'key': _news},
        {'name': Translator.get('Gallery'), 'icon': UniconsLine.images, 'page': 'gallery-view', 'key': null},
        {
          'name': Translator.get('Profile'),
          'icon': UniconsLine.chat_bubble_user,
          'page': 'profile-update',
          'key': null
        },
        {'name': dotenv.env['VESTIGE_NAME'], 'icon': UniconsLine.hospital, 'page': 'my_vestige_list', 'key': null},
      ];
    });

    super.initState();

    if (routerName != null) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Get.toNamed(routerName!).whenComplete(() {
          routerName = null;
        });
      });
    }
  }

  Future? _dashboardApi;
  var dashboardData;

  Future _futureBuild() {
    return Api.http.get('dashboard').then(
      (res) async {
        if (res.data['data']['userStatus'] == 2) {
          logoutUser();
        } else {
          dashboardData = res.data;
          await Auth.setCurrentPackage(
            package: res.data["current_package"],
          );
          displayShowcase();
        }
        return res.data;
      },
    );
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("GuestDashboardShowShowcase");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("GuestDashboardShowShowcase", false).then(
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
    return showDialog(
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
        ) as Future<bool>? ??
        false as Future<bool>;
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
              title: Text(Translator.get(dotenv.env['APP_NAME']!)!),
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
                              UniconsLine.bell,
                              size: 16,
                              color: textColorSecondary,
                            ),
                            SizedBox(width: 10),
                            text(
                              Translator.get('notification'),
                            ),
                          ],
                        ),
                        value: 'notification',
                      ),
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
                        child: GestureDetector(
                          child: Row(
                            children: [
                              Icon(
                                UniconsLine.sign_in_alt,
                                size: 16,
                                color: textColorSecondary,
                              ),
                              SizedBox(width: 10),
                              text(Translator.get('logout')),
                            ],
                          ),
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
                                    child: text(Translator.get('No')!.toUpperCase(), fontFamily: fontBold),
                                  ),
                                  TextButton(
                                    onPressed: () => logoutUser(),
                                    child: text(Translator.get('Yes')!.toUpperCase(), fontFamily: fontBold),
                                  ),
                                ],
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                        ),
                      )
                    ];
                  },
                ),
              ],
            ),
            drawer: SafeArea(
              child: AppDrawer(
                name: dashboardData["data"]["userName"],
                packageName: dashboardData["package"],
                packageId: dashboardData["current_package"],
                expiryAt: dashboardData['expiryAt'],
                profileImage: dashboardData['data']['userProfileImage'],
                isPaid: Platform.isAndroid
                    ? true
                    : dashboardData != null && dashboardData.containsKey('isPaid')
                        ? dashboardData['isPaid']
                        : false,
              ),
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      FadeAnimation(
                        0.8,
                        _buildHeader(context),
                      ),
                      SizedBox(height: 5),
                      FadeAnimation(
                        1.0,
                        _buildCoin(context),
                      ),
                      FadeAnimation(
                        0.9,
                        _buildMemberRequest(context),
                      ),
                      FadeAnimation(
                        1.0,
                        _buildDreamList(context),
                      ),
                      SizedBox(height: 15),
                      FadeAnimation(
                        1.5,
                        _buildUserStrip(context),
                      ),
                      SizedBox(height: 15),
                      FadeAnimation(
                        1.6,
                        _buildButton(context),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.0),
          bottomRight: Radius.circular(18.0),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorPrimary, colorAccent],
        ),
        color: colorPrimary,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Get.toNamed('profile-update');
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: (dashboardData['data']['userProfileImage'] != null &&
                            dashboardData['data']['userProfileImage'].toString().isNotEmpty
                        ? NetworkImage(dashboardData['data']['userProfileImage'])
                        : AssetImage(profileImage)) as ImageProvider<Object>?,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Column(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: dashboardData["data"]["userName"] != null
                                    ? dashboardData["data"]["userName"]
                                    : "N/A",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text:
                                    " ( ${dashboardData["data"]["code"] != null ? dashboardData["data"]["code"] : null} )",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 10.0),
                        GestureDetector(
                          onTap: () {
                            copyCode = dashboardData["data"]["code"];
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
                    SizedBox(height: 5),
                    if (dashboardData["data"]["userMobile"].toString().isNotEmpty)
                      Text(
                        dashboardData["data"]["userMobile"],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    if (dashboardData["data"]["userEmail"].toString().isNotEmpty)
                      Text(
                        dashboardData["data"]["userEmail"],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                  ],
                )
              ],
            ),
            SizedBox(height: 25),
            _buildCategoriesGrid(context)
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return Container(
      height: 110,
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
              Get.toNamed(categories[index]['page']).then(
                (value) {
                  setState(() {
                    _dashboardApi = _futureBuild();
                  });
                },
              );
            },
            child: Column(
              key: categories[index]['key'],
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Color(0xFFF6F5F8),
                  maxRadius: 30.0,
                  child: Icon(
                    categories[index]['icon'],
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ),
                SizedBox(height: h(1)),
                text(
                  categories[index]['name'],
                  textColor: white,
                  fontSize: textSizeSMedium,
                  fontFamily: fontSemibold,
                ),
              ],
            ),
          );
        },
        itemCount: categories.length,
      ),
    );
  }

  Widget _buildOtherToolGrid(BuildContext context) {
    return Column(
      key: _learning,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            children: <Widget>[
              Text(
                Translator.get("Learning")!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: boxDecoration(
            radius: 10,
            showShadow: true,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 35,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: tools.map((tool) {
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
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            tool['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
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
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              color: Colors.white,
            ),
          ),
          title: text(
            Translator.get('Upgrade to Next Level'),
            fontSize: textSizeLargeMedium,
            textColor: textColorPrimary,
            fontFamily: fontBold,
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

  Widget _buildMemberRequest(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(
              'raise-request',
              arguments: {
                "isParent": dashboardData['isParent'],
                "upLine": "upLine",
              },
            );
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
                  color: Colors.green,
                ),
                child: Icon(
                  UniconsLine.exchange,
                  color: white,
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: text(
                  Translator.get('Connect'),
                  fontSize: textSizeLargeMedium,
                  textColor: colorPrimaryDark,
                  fontFamily: fontSemibold,
                ),
              ),
              subtitle: Column(
                children: <Widget>[
                  text(
                    Translator.get('Send your connection to teammate'),
                    fontSize: 16.0,
                    textColor: textColorSecondary,
                  ),
                  if (dashboardData['myLeaderDetail'] != null)
                    Row(
                      children: <Widget>[
                        text(
                          Translator.get('Current UpLine')! + " : ",
                          fontSize: 16.0,
                          textColor: textColorSecondary,
                        ),
                        Expanded(
                          child: text(
                            dashboardData['myLeaderDetail']['name'],
                            fontSize: 16.0,
                            textColor: colorPrimary,
                            textAllCaps: true,
                            fontFamily: fontBold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserStrip(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('note');
      },
      child: Container(
        key: _notes,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: boxDecoration(
          radius: 10,
          showShadow: true,
        ),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: Icon(
              UniconsLine.notes,
              color: Colors.white,
            ),
          ),
          title: text(
            Translator.get('Notes'),
            fontSize: 18.0,
            textColor: textColorPrimary,
            fontFamily: fontBold,
          ),
          subtitle: text(
            Translator.get('Click here to create your business notes'),
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
                    Get.toNamed('my_vestige_list');
                  },
                  child: _buildWikiCategory(
                    UniconsLine.hospital,
                    dotenv.env['VESTIGE_NAME'],
                    colorPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('inspiration_club_List');
                  },
                  child: _buildWikiCategory(
                    UniconsLine.mountains,
                    Translator.get("Inspiration Club"),
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

  Widget _buildDreamList(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    Translator.get("Dreams")!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.toNamed('dream-list');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD1DCFF),
                        blurRadius: 10.0, // has the effect of softening the shadow
                        spreadRadius: 1.0, // has the effect of extending the shadow
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Icon(
                        Icons.book,
                        color: Colors.deepPurple,
                        size: 30,
                      ),
                      SizedBox(height: 10),
                      Text(
                        Translator.get("Short term")!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.toNamed("dream-list", arguments: 'MidTerm');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD1DCFF),
                        blurRadius: 10.0, // has the effect of softening the shadow
                        spreadRadius: 1.0, // has the effect of extending the shadow
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Icon(
                        Icons.filter,
                        color: Colors.deepOrange,
                        size: 30,
                      ),
                      SizedBox(height: 10),
                      Text(
                        Translator.get('Mid term')!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.toNamed("dream-list", arguments: 'LongTerm');
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD1DCFF),
                        blurRadius: 10.0, // has the effect of softening the shadow
                        spreadRadius: 1.0, // has the effect of extending the shadow
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Icon(
                        Icons.assignment,
                        color: Colors.pinkAccent,
                        size: 30,
                      ),
                      SizedBox(height: 10),
                      Text(
                        Translator.get('Long term')!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Stack _buildWikiCategory(IconData icon, String? label, Color color) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(26.0),
          alignment: Alignment.centerRight,
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(height: 16.0),
              text(
                label,
                textColor: white,
                fontSize: 16.0,
                fontFamily: fontBold,
              )
            ],
          ),
        )
      ],
    );
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: Translator.get('Testimonials'),
        enableOverlayTab: true,
        keyTarget: _testimonials,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("See our user’s testimonials from here and you can add your testimonial also.")!,
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
        identify: Translator.get('DreamList'),
        enableOverlayTab: true,
        keyTarget: _dreamList,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get(
                        "Add your dreams here which you want to achieve in life and you will have suggested dreams also")!,
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
        identify: Translator.get('News'),
        enableOverlayTab: true,
        keyTarget: _news,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get('Get all the latest News here and be up to date.')!,
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
        identify: 'Upgrade',
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
                    Translator.get('You can upgrade yourself from here, you just need to enter Activation code.')!,
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
        identify: 'Notes',
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
                  Text(
                    Translator.get('Add your important notes here and access it whenever you want.')!,
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
        identify: 'Learning',
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
                  Text(
                    Translator.get('Learn exclusive content with us in form of Video, Audio and Ebooks')!,
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
    tutorial = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 5,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      onClickTarget: (target) {
        if (target.identify == "Upgrade") {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500), curve: Curves.easeInCubic);
        }

        if (target.identify == 'Learning') {
          isFinish = true;
          if (isFinish) isCheck(isFinish);
        }
      },
      onClickOverlay: (target) {
        if (target.identify == "Upgrade") {
          _scrollController.animateTo(_scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500), curve: Curves.easeInCubic);
        }

        if (target.identify == 'Learning') {
          isFinish = true;
          if (isFinish) isCheck(isFinish);
        }
      },
      onFinish: () {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      },
      onSkip: () {},
    )..show();
  }

  void isCheck(isFinish) {
    tutorial.finish();
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
}
