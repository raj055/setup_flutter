import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_paginator/flutter_paginator.dart';

import '../../../services/api.dart';
import '../../../services/translator.dart';

class BadgeAchieverList extends StatefulWidget {
  final int? badgeList;

  const BadgeAchieverList({Key? key, this.badgeList}) : super(key: key);
  @override
  _BadgeAchieverListState createState() => _BadgeAchieverListState();
}

class _BadgeAchieverListState extends State<BadgeAchieverList> {
  GlobalKey<PaginatorState> paginationGlobalKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translator.get('Badge Achiever List')!,
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          paginationGlobalKey.currentState!.changeState(
            pageLoadFuture: badgeAchData,
            resetState: true,
          );
        },
        child: Paginator.listView(
          key: paginationGlobalKey,
          pageLoadFuture: badgeAchData,
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

  Future<PaginationData> badgeAchData(int page) async {
    try {
      Response response = await Api.http.post('team-badges?page=$page', data: {"badge_id": widget.badgeList});

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
    details.data!.forEach((detail) {
      list.add(detail);
    });
    return list;
  }

  Widget listItemBuilder(data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xFFD1DCFF),
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            20.0,
          ),
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
                  Container(
                    child: Text(data['date']),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        data['memberCode'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        Translator.get('NAME')!,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 5),
                      Text(
                        data['name'],
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        Translator.get('MOBILE NO.')!,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 5),
                      Text(
                        data['mobile'].toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return Center(
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
                Feather.message_square,
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            ),
            SizedBox(height: 20),
            Text(
              Translator.get("No List Found")!,
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
    data = response.data['teamBadges']['data'];
    total = response.data['teamBadges']['total'];
    nItems = data!.length;
  }

  PaginationData.withError(String? errorMessage) {
    this.errorMessage = errorMessage;
  }
}
