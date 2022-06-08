import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../services/api.dart';
import '../services/debouncer.dart';
import '../services/translator.dart';
import '../widget/FadeAnimation.dart';
import '../widget/theme.dart';

class MasterSearch extends StatefulWidget {
  @override
  _MasterSearchState createState() => _MasterSearchState();
}

class _MasterSearchState extends State<MasterSearch> {
  bool showLoader = false;
  TextEditingController _searchController = TextEditingController();
  List? searchedData = [];
  final Debouncer onSearchDebouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF9F9F9),
      // appBar: AppBar(title: Text(Translator.get('Master Search'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                decoration: boxDecoration(radius: 10, showShadow: true),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Feather.search,
                      color: colorPrimary,
                    ),
                    suffixIcon: GestureDetector(
                      child: Icon(Icons.close),
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
                    hintText: Translator.get('Search all. . .'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 15.0, top: 15.0),
                  ),
                  onChanged: (text) {
                    this.onSearchDebouncer.debounce(
                      () {
                        if (text.isNotEmpty) {
                          showLoader = false;
                          Api.httpWithoutLoader.post(
                            'master-search',
                            data: {"master_search": _searchController.text},
                          ).then(
                            (response) {
                              if (response.data['status']) {
                                if (mounted) {
                                  setState(() {
                                    showLoader = true;
                                    searchedData = response.data['data']['records'];
                                  });
                                }
                              } else {
                                if (mounted) {
                                  setState(() {
                                    showLoader = true;
                                  });
                                }
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              if (searchedData == null)
                Center(
                  child: CircularProgressIndicator(),
                ),
              if (searchedData != null && searchedData!.length > 0 && _searchController.text.isNotEmpty)
                SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    buildDetails(context, searchedData!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetails(BuildContext context, List searchedData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (Map mSearchData in searchedData)
          SizedBox(
            child: FadeAnimation(
              0.9,
              GestureDetector(
                onTap: () {
                  if (mSearchData['page_view'] == 'learning-video-list') {
                    Get.toNamed('learning-video-list', arguments: {
                      "videoData": mSearchData['video']['packageDescription'],
                      "name": mSearchData['video']['name']
                    });
                  } else if (mSearchData['page_view'] == 'learning-audio-list') {
                    Get.toNamed('learning-audio-list', arguments: {
                      "videoData": mSearchData['audio']['packageDescription'],
                      "name": mSearchData['audio']['name']
                    });
                  } else if (mSearchData['page_view'] == 'learning-ebook-list') {
                    Get.toNamed('learning-ebook-list', arguments: {
                      "eBookData": mSearchData['ebook']['packageDescription'],
                      "name": mSearchData['ebook']['name']
                    });
                  } else {
                    Get.toNamed(mSearchData['page_view']);
                  }
                },
                child: Column(
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0x95E9EBF0),
                        ),
                        width: 36,
                        height: 36,
                        child: Icon(
                          Feather.trending_up,
                          color: colorPrimary,
                          size: 16,
                        ),
                      ),
                      title: text(
                        mSearchData['title'],
                        isLongText: true,
                        textColor: colorPrimaryDark,
                      ),
                      trailing: Icon(
                        Feather.chevron_right,
                        color: colorPrimary,
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
