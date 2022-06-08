import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class ViewRequest extends StatefulWidget {
  @override
  _ViewRequestState createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  GlobalKey<PaginatorState> paginationGlobalKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  late SharedPreferences preferences;
  Translator? translator;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _refresh = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("badgeViewRequest");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("badgeViewRequest", false).then(
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translator.get('View Request')!,
        ),
        actions: <Widget>[
          IconButton(
            key: _refresh,
            onPressed: () {
              paginationGlobalKey.currentState!.changeState(
                pageLoadFuture: viewRequestData,
                resetState: true,
              );
            },
            icon: Icon(
              Icons.refresh,
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          paginationGlobalKey.currentState!.changeState(
            pageLoadFuture: viewRequestData,
            resetState: true,
          );
        },
        child: Paginator.listView(
          key: paginationGlobalKey,
          pageLoadFuture: viewRequestData,
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
    );
  }

  void _refreshData() {
    paginationGlobalKey.currentState!.changeState(
      pageLoadFuture: viewRequestData,
      resetState: true,
    );
  }

  Future<PaginationData> viewRequestData(int page) async {
    try {
      Response response = await Api.http.get('badge-request-list?page=$page');

      return PaginationData.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        return PaginationData.withError(Translator.get('Please check your Internet connection'));
      } else {
        return PaginationData.withError(Translator.get('Something went wrong.'));
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
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: boxDecoration(
            radius: 10,
            showShadow: true,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 15,
                  bottom: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    text(data['created_at']),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          data['status'],
                          style: TextStyle(
                            color: white,
                          ),
                        ),
                      ),
                      color: green,
                    ),
                  ],
                ),
              ),
              Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 5),
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            child: SvgPicture.network(
                              data['icon'],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  text(
                                    data['badge'],
                                    fontFamily: fontBold,
                                    textColor: colorPrimary,
                                    fontSize: textSizeLargeMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Api.http.post(
                          'change-badge-status',
                          data: {"badge_request_id": data['id'], "status": "2"},
                        ).then(
                          (response) async {
                            _refreshData();
                            GetBar(
                              backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                              duration: Duration(seconds: 5),
                              message: response.data['message'],
                            ).show();
                          },
                        ).catchError(
                          (error) {
                            if (error.response.statusCode == 422) {
                              Navigator.of(context).pop();
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: error.response.data['errors'],
                              ).show();
                            } else if (error.response.statusCode == 401) {
                              Navigator.of(context).pop();
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 5),
                                message: error.response.data['errors'],
                              ).show();
                            }
                          },
                        );
                      },
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      label: Text(
                        Translator.get('Approve')!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Api.http.post(
                          'change-badge-status',
                          data: {"badge_request_id": data['id'], "status": "3"},
                        ).then(
                          (response) async {
                            _refreshData();
                            GetBar(
                              backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                              duration: Duration(seconds: 5),
                              message: response.data['message'],
                            ).show();
                          },
                        ).catchError(
                          (error) {
                            if (error.response.statusCode == 422) {
                              Navigator.of(context).pop();
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                                message: error.response.data['errors'],
                              ).show();
                            } else if (error.response.statusCode == 401) {
                              Navigator.of(context).pop();
                              GetBar(
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 5),
                                message: error.response.data['errors'],
                              ).show();
                            }
                          },
                        );
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      label: Text(
                        Translator.get('Reject')!.toUpperCase(),
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ],
    );
  }

  Widget loadingWidgetMaker() {
    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(),
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
        TextButton(
          onPressed: retryListener,
          child: Text(
            Translator.get('Retry')!,
          ),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(PaginationData data) {
    return Center(
      child: emptyWidget(
        context,
        'assets/images/no_result.png',
        "${Translator.get('No Badge Request Found')}",
        "${Translator.get('There was no record based on the details you entered.')}",
      ),
    );
  }

  int? totalPagesGetter(PaginationData data) {
    return data.total;
  }

  bool pageErrorChecker(PaginationData data) {
    return data.statusCode != 200;
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: Translator.get("Refresh"),
        keyTarget: _refresh,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Click here to refresh your screen to get latest request for badge achiever.',
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
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 5,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      onClickTarget: (target) {},
      onClickOverlay: (target) {},
      onFinish: () {},
      onSkip: () {},
    )..show();
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

class PaginationData {
  List<dynamic>? data;
  int? statusCode;
  String? errorMessage;
  int? total;
  int? nItems;

  PaginationData.fromResponse(Response response) {
    this.statusCode = response.statusCode;
    data = response.data['data']['data'];
    total = response.data['data']['total'];
    nItems = data!.length;
  }

  PaginationData.withError(String? errorMessage) {
    this.errorMessage = errorMessage;
  }
}
