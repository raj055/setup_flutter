import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class DetailsTeamDream extends StatefulWidget {
  @override
  _DetailsTeamDreamState createState() => _DetailsTeamDreamState();
}

class _DetailsTeamDreamState extends State<DetailsTeamDream> {
  GlobalKey<PaginatorState> associateDreamGlobalKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  var teamAssociateDreamData;
  var chartData;
  List tempChartData = [];
  Map? teamDreamDetails;
  static const t3_white = Color(0XFFffffff);
  static const shadow_color = Color(0X95E9EBF0);
  static const t3_colorPrimary = Color(0xff1252AC);
  static const t3_colorPrimaryDark = Color(0xffEF3037);

  @override
  void initState() {
    teamDreamDetails = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(teamDreamDetails!['name'])),
      body: FadeAnimation(
        0.9,
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            associateDreamGlobalKey.currentState!.changeState(
              pageLoadFuture: leadershipBonusData,
              resetState: true,
            );
          },
          child: Paginator.listView(
            key: associateDreamGlobalKey,
            pageLoadFuture: leadershipBonusData,
            pageItemsGetter: listItemsGetter,
            listItemBuilder: listItemBuilder,
            loadingWidgetBuilder: loadingWidgetMaker,
            errorWidgetBuilder: errorWidgetMaker,
            emptyListWidgetBuilder: emptyListWidgetMaker,
            totalItemsGetter: totalPagesGetter,
            pageErrorChecker: pageErrorChecker,
            scrollPhysics: BouncingScrollPhysics(),
          ),
        ),
      ),
    );
  }

  Future<PaginationData> leadershipBonusData(int page) async {
    try {
      Response response = await Api.http.post('team-associate-dreams', data: {"id": teamDreamDetails!['id']});

      return PaginationData.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        return PaginationData.withError(
          Translator.get('Please check your Internet connection'),
        );
      } else {
        return PaginationData.withError(
          Translator.get('Something went wrong.'),
        );
      }
    }
  }

  List<dynamic> listItemsGetter(PaginationData details) {
    List<dynamic> list = [];
    details.data!.forEach(
      (detail) {
        list.add(detail);
      },
    );

    return list;
  }

  Widget listItemBuilder(data, int index) {
    return _dreamDetailsField(data);
  }

  Widget _dreamDetailsField(data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Container(
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            child: PNetworkImage(
                              data['dreamImage'],
                              fit: BoxFit.contain,
                              height: 250,
                              width: double.infinity,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                child: Expanded(
                                  child: Text(
                                    data['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0XFF333333),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            data['targetDate'],
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RaisedButton(
                      textColor: Color(0XFFffffff),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0))),
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: <Color>[t3_colorPrimary, t3_colorPrimaryDark]),
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              data['category'],
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: null,
    );
  }

  Widget errorWidgetMaker(PaginationData data, retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(data.errorMessage!),
        ),
        FlatButton(
          onPressed: retryListener,
          child: Text(
            Translator.get('Retry')!,
          ),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(PaginationData data) {
    return FadeAnimation(
      1.0,
      Center(
        child: emptyWidget(
          context,
          'assets/images/no_result.png',
          "${Translator.get("No Member Dreams Found")}",
          "${Translator.get('There was no record based on the details you entered.')}",
        ),
      ),
    );
  }

  BoxDecoration boxDecoration(
      {double radius = 2, Color color = Colors.transparent, Color bgColor = t3_white, var showShadow = false}) {
    return BoxDecoration(
        color: bgColor,
        boxShadow: showShadow
            ? [BoxShadow(color: shadow_color, blurRadius: 4, spreadRadius: 1)]
            : [BoxShadow(color: Colors.transparent)],
        border: Border.all(color: color),
        borderRadius: BorderRadius.all(Radius.circular(radius)));
  }

  int? totalPagesGetter(PaginationData data) {
    return data.total;
  }

  bool pageErrorChecker(PaginationData data) {
    return data.statusCode != 200;
  }
}

class PaginationData {
  List<dynamic>? data;
  int? statusCode;
  String? errorMessage;
  int? total;
  int? nItems;

  PaginationData.fromResponse(Response response) {
    this.statusCode = response.statusCode;
    data = response.data['dreams']['data'];
    total = response.data['dreams']['total'];
    nItems = data!.length;
  }

  PaginationData.withError(String? errorMessage) {
    this.errorMessage = errorMessage;
  }
}
