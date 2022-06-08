import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class DocumentAudioSearch extends StatefulWidget {
  @override
  _DocumentAudioSearchState createState() => _DocumentAudioSearchState();
}

class _DocumentAudioSearchState extends State<DocumentAudioSearch> {
  Translator? translator;
  String? error;
  bool showLoader = false;
  TextEditingController _searchController = TextEditingController();
  List? searchedData = [];

  Map? audioDataSearch;

  @override
  void initState() {
    audioDataSearch = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Feather.search,
                  ),
                  suffixIcon: GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () {
                      setState(
                        () {
                          _searchController.clear();
                        },
                      );
                    },
                  ),
                  hintText: Translator.get('Search ..'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (text) {
                  if (audioDataSearch!['pageType'] == 'inspiration') {
                    if (text.isNotEmpty) {
                      showLoader = false;
                      Map sendData = {
                        "title": _searchController.text,
                        "inspiration_id": audioDataSearch!['id'],
                        "type": audioDataSearch!['typeId'],
                      };
                      Api.httpWithoutLoader
                          .post(
                        'inspiration-club-content-search',
                        data: sendData,
                      )
                          .then((response) {
                        if (response.data['status']) {
                          if (mounted) {
                            setState(() {
                              showLoader = true;
                              searchedData = response.data['list'];
                              error = null;
                            });
                          }
                        } else {
                          setState(() {
                            showLoader = true;
                            error = response.data['error'];
                          });
                        }
                      });
                    } else {
                      setState(() {
                        searchedData = null;
                      });
                    }
                  } else if (audioDataSearch!['pageType'] == 'vestige') {
                    if (text.isNotEmpty) {
                      showLoader = false;
                      Map sendData = {
                        "title": _searchController.text,
                        "vestige_id": audioDataSearch!['id'],
                        "type": audioDataSearch!['typeId'],
                      };
                      Api.httpWithoutLoader
                          .post(
                        'vestige-content-search',
                        data: sendData,
                      )
                          .then((response) {
                        if (response.data['status']) {
                          setState(() {
                            showLoader = true;
                            searchedData = response.data['list'];
                            error = null;
                          });
                        } else {
                          setState(() {
                            showLoader = true;
                            error = response.data['error'];
                          });
                        }
                      });
                    } else {
                      setState(() {
                        searchedData = null;
                      });
                    }
                  } else if (audioDataSearch!['pageType'] == 'cep') {
                    if (text.isNotEmpty) {
                      showLoader = false;
                      Map sendData = {
                        "title": _searchController.text,
                        "cep_id": audioDataSearch!['id'],
                        "type": audioDataSearch!['typeId'],
                      };
                      Api.httpWithoutLoader
                          .post(
                        'cep-sub-category-search',
                        data: sendData,
                      )
                          .then(
                        (response) {
                          if (response.data['status']) {
                            setState(() {
                              showLoader = true;
                              searchedData = response.data['list'];
                              error = null;
                            });
                          } else {
                            setState(() {
                              showLoader = true;
                              error = response.data['error'];
                            });
                          }
                        },
                      );
                    } else {
                      setState(() {
                        searchedData = null;
                      });
                    }
                  } else if (audioDataSearch!['pageType'] == 'cep-prime') {
                    if (text.isNotEmpty) {
                      showLoader = false;
                      Map sendData = {
                        "title": _searchController.text,
                        "cep_prime_id": audioDataSearch!['id'],
                        "type": audioDataSearch!['typeId'],
                      };
                      Api.httpWithoutLoader
                          .post(
                        'cep-prime-sub-category-search',
                        data: sendData,
                      )
                          .then(
                        (response) {
                          if (response.data['status']) {
                            setState(() {
                              showLoader = true;
                              searchedData = response.data['list'];
                              error = null;
                            });
                          } else {
                            setState(() {
                              showLoader = true;
                              error = response.data['error'];
                            });
                          }
                        },
                      );
                    } else {
                      setState(() {
                        searchedData = null;
                      });
                    }
                  }
                },
              ),
              if (error != null)
                if (searchedData == null && _searchController.text.isNotEmpty && error == null)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              if (error != null) SizedBox(height: 5),
              if (error != null && _searchController.text.isNotEmpty)
                Center(
                  child: Text(error!),
                ),
              if (searchedData != null && searchedData!.length > 0 && _searchController.text.isNotEmpty)
                SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    if (searchedData != null && _searchController.text.isNotEmpty && error == null)
                      buildDetails(context, searchedData!),
                    SizedBox(height: 10)
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
      children: <Widget>[
        for (Map post in searchedData)
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD1DCFF),
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                10.0,
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.toNamed(
                  'document_video_play',
                  arguments: post,
                );
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
                      post['title'],
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
      ],
    );
  }
}
