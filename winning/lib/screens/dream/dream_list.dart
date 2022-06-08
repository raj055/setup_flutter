import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/dream/DreamTabs/longTerm.dart';
import '../../screens/dream/DreamTabs/midTerm.dart';
import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class DreamList extends StatefulWidget {
  @override
  _DreamListState createState() => _DreamListState();
}

class _DreamListState extends State<DreamList>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();
  String selectTab = "1";
  Future? _dreamApi;
  late var dreams;
  var training;
  List? typeCategory = [];
  late SharedPreferences preferences;

  @override
  void initState() {
    _dreamApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http
        .post('dream-index', data: {'category_id': selectTab}).then((res) {
      dreams = res.data;
      typeCategory = dreams["dreamCategories"]["categories"];
      training = res.data['training'];
      return res.data;
    });
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("showDreamList");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("showDreamList", false).then((bool success) {});
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dreamApi,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(Translator.get('Dream List')!)),
          );
        }
        return DefaultTabController(
          initialIndex: Get.arguments == "MidTerm"
              ? 1
              : Get.arguments == "LongTerm"
                  ? 2
                  : 0,
          length: 3,
          child: Scaffold(
            backgroundColor: Color(0xffe9e9e9),
            appBar: AppBar(
              title: Text(Translator.get('Dreams')!),
              bottom: _buildTopMenuBar(context) as PreferredSizeWidget?,
            ),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                _shortTerm(),
                MidTerm(),
                LongTerm(),
              ],
            ),
            floatingActionButton: FadeAnimation(
              1.2,
              FloatingActionButton(
                onPressed: () {
                  Get.toNamed('dream-add');
                },
                child: Icon(
                  Icons.playlist_add,
                  color: white,
                ),
                backgroundColor: colorPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopMenuBar(BuildContext context) {
    return TabBar(
      isScrollable: true,
      labelColor: white,
      indicatorColor: colorPrimary,
      unselectedLabelColor: white,
      onTap: (index) {
        setState(() {
          selectTab = (index + 1).toString();
          _dreamApi = _futureBuild();
        });
      },
      tabs: typeCategory!.map((tab) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: text(
            tab['value'],
            textColor: white,
            fontFamily: fontSemibold,
          ),
        );
      }).toList(),
    );
  }

  Widget _shortTerm() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: <Widget>[
//          if (training != null && training.length > 0)
//            FadeAnimation(
//              0.9,
//              _buildPackage(context),
//            ),
          FadeAnimation(
            0.9,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: <Widget>[
                  text(
                    Translator.get("My Dreams"),
                    fontFamily: fontBold,
                    fontSize: textSizeLargeMedium,
                    textColor: colorPrimaryDark,
                  ),
                ],
              ),
            ),
          ),
          _myDreams(dreams),
          SizedBox(height: 20),
          if (dreams['dreamCount'] < 15)
            FadeAnimation(
              1.1,
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  children: <Widget>[
                    text(
                      Translator.get("Suggested Dreams"),
                      fontFamily: fontBold,
                      fontSize: textSizeLargeMedium,
                      textColor: colorPrimaryDark,
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 10),
          if (dreams['dreamCount'] < 15) _suggestedDream(dreams),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _suggestedDream(dreams) {
    if (dreams["dreamLists"].length == 0) {
      return FadeAnimation(
        1.2,
        Container(
          width: double.infinity,
          decoration: boxDecoration(
            radius: 10,
            showShadow: true,
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              text(
                Translator.get('No Data Found'),
                textColor: colorPrimaryDark,
                fontFamily: fontBold,
                fontSize: textSizeLargeMedium,
                maxLine: 2,
              ),
              SizedBox(height: 5),
              text(
                Translator.get('Suggested dreams not found'),
                isCentered: true,
                isLongText: true,
              ),
            ],
          ),
        ),
      );
    }
    return FadeAnimation(
      1.2,
      Swiper(
        itemHeight: h(40),
        itemWidth: 300,
        itemCount: dreams["dreamLists"].length,
        layout: dreams["dreamLists"].length < 2
            ? SwiperLayout.TINDER
            : SwiperLayout.STACK,
        loop: true,
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Column(
              children: <Widget>[
                dreams["dreamLists"][index]["dreamImage"] != null
                    ? Container(
                        color: white.withOpacity(0.90),
                        child: PNetworkImage(
                          dreams["dreamLists"][index]["dreamImage"],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: h(25),
                        ),
                      )
                    : Image.asset("assets/images/placeholder.png"),
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: text(
                              dreams["dreamLists"][index]["name"],
                              fontFamily: fontSemibold,
                              maxLine: 2,
                            ),
                          ),
                          SizedBox(height: 5),
                          RaisedButton.icon(
                            icon: Icon(
                              Icons.add,
                              size: 12,
                              color: white,
                            ),
                            label: Text(
                              Translator.get('Pick This Dream')!,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: fontSemibold,
                                fontSize: textSizeMedium,
                              ),
                            ),
                            onPressed: () {
                              Get.toNamed('dream-pick', arguments: {
                                "dream": dreams["dreamLists"][index],
                                "pickDream": dreams["dreamCategories"],
                              });
                            },
                            color: red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(
                                color: red,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _myDreams(dreams) {
    if (dreams["myDreams"]["data"].length == 0) {
      return FadeAnimation(
        1.0,
        Container(
          width: double.infinity,
          decoration: boxDecoration(
            radius: 10,
            showShadow: true,
          ),
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              text(
                Translator.get('No Data Found'),
                textColor: colorPrimaryDark,
                fontFamily: fontBold,
                fontSize: textSizeLargeMedium,
                maxLine: 2,
              ),
              SizedBox(height: 5),
              text(
                Translator.get('My dream not found'),
                isCentered: true,
                isLongText: true,
              ),
            ],
          ),
        ),
      );
    }

    return FadeAnimation(
      1.0,
      Container(
        height: 300,
        child: Swiper(
          itemHeight: 300,
          itemWidth: 300,
          layout: dreams["myDreams"].length < 2
              ? SwiperLayout.TINDER
              : SwiperLayout.DEFAULT,
          loop: false,
          fade: 0.8,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: h(25),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        image: DecorationImage(
                          image: dreams["myDreams"]["data"][index]
                                      ["dreamImage"] !=
                                  null
                              ? CachedNetworkImageProvider(
                                  dreams["myDreams"]["data"][index]
                                      ["dreamImage"],
                                )
                              : Image.asset("assets/images/placeholder.png") as ImageProvider<Object>,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed('dream-edit',
                              arguments: dreams['myDreams']["data"][index]);
                        },
                        child: CircleAvatar(
                          foregroundColor: white,
                          backgroundColor: white,
                          child: Icon(
                            Feather.edit_2,
                            color: colorPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 5),
                          text(
                            dreams["myDreams"]["data"][index]["name"],
                            textColor: colorPrimary,
                            fontFamily: fontSemibold,
                            maxLine: 2,
                          ),
                          SizedBox(height: 10),
                          dreams["myDreams"]["data"][index]["targetDate"] !=
                                  null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: green,
                                        borderRadius:
                                            new BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Feather.calendar,
                                            color: white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 5),
                                          text(
                                            dreams["myDreams"]["data"][index]
                                                ["targetDate"],
                                            textColor: white,
                                            fontSize: textSizeSmall,
                                            textAllCaps: true,
                                            fontFamily: fontSemibold,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: red,
                                        borderRadius:
                                            new BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Feather.activity,
                                            color: white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 5),
                                          text(
                                            dreams["myDreams"]["data"][index]
                                                        ["leftDays"]
                                                    .toString() +
                                                " Days left",
                                            textColor: white,
                                            fontSize: textSizeSmall,
                                            textAllCaps: true,
                                            fontFamily: fontSemibold,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : RaisedButton.icon(
                                  icon: Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: white,
                                  ),
                                  label: Text(
                                    Translator.get('Date yet to select')!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: fontSemibold,
                                      fontSize: textSizeMedium,
                                    ),
                                  ),
                                  onPressed: () {},
                                  color: red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                      color: red,
                                    ),
                                  ),
                                ),
                          SizedBox(height: 10),
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          },
          itemCount: dreams["myDreams"]["data"].length,
          viewportFraction: 0.8,
          scale: 0.9,
          pagination: SwiperPagination(),
        ),
      ),
    );
  }

  Widget _buildPackage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 110.0,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 5),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (_, int index) {
            return GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TrainingDescription(
                //       trainingData: training[index]['trainingData'],
                //     ),
                //   ),
                // );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color(0xFFF6F5F8),
                    maxRadius: 30.0,
                    child: PNetworkImage(
                      dreams['training'][index]['thumbnail'],
                      fit: BoxFit.contain,
                      height: 30,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    training[index]['trainingData']['name'],
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: white),
                  )
                ],
              ),
            );
          },
          itemCount: training.length,
        ),
      ),
    );
  }
}
