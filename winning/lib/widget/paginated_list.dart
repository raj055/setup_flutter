import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:flutter_paginator/type_definitions.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/translator.dart';
import '../widget/theme.dart';

class PaginatedList extends StatefulWidget {
  final String? pageTitle;
  final Future<Response> Function(int page) apiFuture;
  final Widget Function(dynamic item, int index) listItemBuilder;
  final dynamic Function(dynamic item)? listItemGetter;
  final bool showLoader;
  final Widget Function()? loadingWidgetBuilder;
  final Widget? emptyListWidgetBuilder;
  final Widget? floatingActionButton;
  final List<Widget>? appBarAction;
  final bool resetStateOnRefresh;
  final bool isPullToRefresh;
  final bool isReverse;

  const PaginatedList({
    Key? key,
    required this.apiFuture,
    required this.listItemBuilder,
    this.pageTitle,
    this.listItemGetter,
    this.showLoader = false,
    this.loadingWidgetBuilder,
    this.emptyListWidgetBuilder,
    this.floatingActionButton,
    this.appBarAction,
    this.resetStateOnRefresh = false,
    this.isPullToRefresh = true,
    this.isReverse = false,
  })  : assert(apiFuture != null),
        assert(listItemBuilder != null),
        super(key: key);

  @override
  PaginatedListState createState() => PaginatedListState();
}

class PaginatedListState extends State<PaginatedList> {
  final GlobalKey<RefreshIndicatorState> liquidRefreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<PaginatorState> paginationKey = GlobalKey();
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];

  @override
  void initState() {
    // displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();

    bool showcaseVisibilityStatus = preferences.getBool(widget.pageTitle!);

    if (showcaseVisibilityStatus == null) {
      preferences.setBool(widget.pageTitle!, false).then(
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

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "Refresh",
        keyTarget: refreshIndicatorKey,
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
                    Translator.get("Click here to refresh your screen to get latest news from authority.")!,
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

  void _refreshData() {
    paginationKey.currentState!.changeState(
      pageLoadFuture: pageLoadFuture,
      resetState: widget.resetStateOnRefresh,
    );
  }

  void refresh() {
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.pageTitle != null
          ? AppBar(
              title: Text(
                widget.pageTitle!,
              ),
              actions: widget.appBarAction != null
                  ? widget.appBarAction
                  : [
                      IconButton(
                        key: refreshIndicatorKey,
                        onPressed: () {
                          paginationKey.currentState!.changeState(
                            pageLoadFuture: pageLoadFuture,
                            resetState: true,
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                        ),
                      ),
                    ],
            )
          : null,
      body: widget.isPullToRefresh
          ? LiquidPullToRefresh(
              key: liquidRefreshIndicatorKey,
              color: colorPrimary,
              onRefresh: () async {
                if (widget.isPullToRefresh) _refreshData();
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Paginator.listView(
                      reverse: widget.isReverse,
                      key: paginationKey,
                      shrinkWrap: true,
                      pageLoadFuture: pageLoadFuture,
                      pageItemsGetter: pageItemsGetter,
                      listItemBuilder: widget.listItemBuilder,
                      loadingWidgetBuilder: loadingWidgetBuilder,
                      errorWidgetBuilder: errorWidgetBuilder,
                      emptyListWidgetBuilder: emptyListWidgetBuilder,
                      totalItemsGetter: totalPagesGetter,
                      pageErrorChecker: pageErrorChecker,
                      scrollPhysics: BouncingScrollPhysics(),
                    ),
                  )
                ],
              ),
            )
          : Paginator.listView(
              key: paginationKey,
              shrinkWrap: true,
              reverse: widget.isReverse,
              pageLoadFuture: pageLoadFuture,
              pageItemsGetter: pageItemsGetter,
              listItemBuilder: widget.listItemBuilder,
              loadingWidgetBuilder: loadingWidgetBuilder,
              errorWidgetBuilder: errorWidgetBuilder,
              emptyListWidgetBuilder: emptyListWidgetBuilder,
              totalItemsGetter: totalPagesGetter,
              pageErrorChecker: pageErrorChecker,
              scrollPhysics: BouncingScrollPhysics(),
            ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Future<Pagination> pageLoadFuture(int page) async {
    try {
      Response response = await widget.apiFuture(page);
      // if (response == null || isRefresh) {
      //   isRefresh = false;
      // }
      return Pagination.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        return Pagination.withError('Please check your Internet connection');
      } else {
        return Pagination.withError('Something went wrong.');
      }
    }
  }

  List<dynamic> pageItemsGetter(Pagination pagination) {
    List<dynamic> list = [];

    pagination.items!.forEach((item) {
      if (widget.listItemGetter != null) {
        list.add(widget.listItemGetter!(item));
      } else {
        list.add(item);
      }
    });

    return list;
  }

  Widget loadingWidgetBuilder() {
    if (widget.showLoader == false) {
      return SizedBox.shrink();
    }

    if (widget.loadingWidgetBuilder != null) {
      return widget.loadingWidgetBuilder!();
    }

    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidgetBuilder(Pagination pagination, RetryListener retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(pagination.errorMessage!),
        ),
        TextButton(
          onPressed: retryListener,
          child: CustomButton(
            textContent: 'Retry',
            onPressed: retryListener,
          ),
        )
      ],
    );
  }

  Widget? emptyListWidgetBuilder(Pagination pagination) {
    if (widget.emptyListWidgetBuilder != null) {
      return widget.emptyListWidgetBuilder;
    }

    return Center(
      child: emptyWidget(
        context,
        'assets/images/no_result.png',
        widget.pageTitle != null
            ? "${Translator.get('No Data Found In')} ${(widget.pageTitle)}"
            : "${Translator.get('No Data Found')} ",
        "${Translator.get('There was no record based on the details you entered.')}",
      ),
    );
  }

  int? totalPagesGetter(Pagination? pagination) {
    return pagination!.total!;
  }

  bool pageErrorChecker(Pagination pagination) {
    return pagination.statusCode != 200;
  }
}

class Pagination {
  List<dynamic>? items;
  int? statusCode;
  late String? errorMessage;
  int? total;
  int? nItems;

  Pagination.fromResponse(Response response) {
    this.statusCode = response.statusCode;
    items = response.data['list']['data'];
    total = response.data['list']['total'];
    nItems = items!.length;
  }

  Pagination.withError(String errorMessage) {
    this.errorMessage = errorMessage;
  }
}
