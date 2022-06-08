import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../screens/notes/edit_note.dart';
import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final List colors = [
    Color(0xFFfff176),
    Color(0xFFffcc80),
    Color(0xFFb2ff59),
    Color(0xFFb9f6ca),
    Color(0xFFe1bee7),
  ];

  GlobalKey<PaginatorState> paginationGlobalKey = GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  num countValue = 2;
  num aspectWidth = 2;
  num aspectHeight = 1;
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _add = GlobalKey();
  GlobalKey _search = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("note");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("note", false).then(
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
        title: Text(Translator.get('Notes')!),
        actions: <Widget>[
          IconButton(
            key: _search,
            onPressed: () {
              Get.toNamed('note-search').then(
                (value) {
                  paginationGlobalKey.currentState!.changeState(
                    pageLoadFuture: noteData,
                    resetState: true,
                  );
                },
              );
            },
            icon: Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            ),
          ),
          IconButton(
            key: _add,
            onPressed: () {
              Get.toNamed('addNote').then(
                (value) {
                  if (value != null) {
                    GetBar(
                      backgroundColor: value['status'] ? Colors.green : Colors.red,
                      duration: Duration(seconds: 3),
                      message: value['message'],
                    ).show();
                  }

                  paginationGlobalKey.currentState!.changeState(
                    pageLoadFuture: noteData,
                    resetState: true,
                  );
                },
              );
            },
            icon: Icon(
              Icons.add_circle_outline,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          paginationGlobalKey.currentState!.changeState(
            pageLoadFuture: noteData,
            resetState: true,
          );
        },
        child: Paginator.listView(
          key: paginationGlobalKey,
          pageLoadFuture: noteData,
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

  Future<PaginationData> noteData(int page) async {
    try {
      Response response = await Api.http.get('notes?page=$page');

      List notes = response.data['notes']['data'];
      notes.map((note) {
        note.putIfAbsent('isViewMore', () => false);
      }).toList();
      response.data['notes']['data'] = notes;
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: text(
                          data['title'],
                          textColor: colorPrimaryDark,
                          fontFamily: fontBold,
                          isLongText: true,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text(Translator.get("Are You Sure Want To Delete?")!),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(Translator.get("YES")!),
                                        onPressed: () {
                                          Api.http.put(
                                            'notes-delete',
                                            data: {'notes_id': data['id']},
                                          ).then(
                                            (res) {
                                              GetBar(
                                                backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                                message: res.data['message'],
                                                duration: Duration(seconds: 3),
                                              ).show();
                                              setState(
                                                () {},
                                              );
                                              paginationGlobalKey.currentState!.changeState(
                                                pageLoadFuture: noteData,
                                                resetState: true,
                                              );
                                            },
                                          );
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text(Translator.get("No")!),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Feather.trash,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNote(note: data),
                        ),
                      ).then(
                        (value) {
                          if (value != null) {
                            GetBar(
                              backgroundColor: value['status'] ? Colors.green : Colors.red,
                              duration: Duration(seconds: 3),
                              message: value['message'],
                            ).show();
                          }

                          paginationGlobalKey.currentState!.changeState(
                            pageLoadFuture: noteData,
                            resetState: true,
                          );
                        },
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        text(
                          data['description'],
                          maxLine: !data['isViewMore'] ? 2 : null,
                          overflow: !data['isViewMore'] ? TextOverflow.fade : TextOverflow.visible,
                          textColor: textColorPrimary,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${Translator.get('Last updated')} : ' + data['updatedAt'],
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        if (data['description'].length > 75)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(
                                    () {
                                      data['isViewMore'] = !data['isViewMore'];
                                    },
                                  );
                                },
                                child: Text(
                                  !data['isViewMore'] ? Translator.get("View More")! : Translator.get("Less")!,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
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
        FlatButton(
          onPressed: retryListener,
          child: Text(Translator.get('Retry')!),
        )
      ],
    );
  }

  Widget emptyListWidgetMaker(PaginationData data) {
    return Center(
      child: emptyWidget(
        context,
        'assets/images/no_result.png',
        "${Translator.get('No Notes Found')}",
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
        identify: "Search",
        keyTarget: _search,
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
                    Translator.get("Click here to search from notes which you have already saved.")!,
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
        identify: "Add",
        keyTarget: _add,
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
                    Translator.get("Click here to add your business notes.")!,
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
    data = response.data['notes']['data'];
    total = response.data['notes']['total'];
    nItems = data!.length;
  }

  PaginationData.withError(String? errorMessage) {
    this.errorMessage = errorMessage;
  }
}
