import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';

import '../../../services/api.dart';
import '../../../widget/theme.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showLoader = false;
  TextEditingController _searchController = TextEditingController();
  List searchedData = [];
  List searchedCategoryData = [];
  var error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    UniconsLine.search,
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
                  hintText: 'Search by product name or category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                style: primaryTextStyle(
                  fontFamily: fontMedium,
                ),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    showLoader = false;
                    Api.httpWithoutLoader.post(
                      'shopping/search-suggestion',
                      data: {"name": _searchController.text},
                    ).then(
                      (response) {
                        if (response.data['status']) {
                          setState(() {
                            showLoader = true;
                            searchedData = response.data['product'];
                            searchedCategoryData = response.data['category'];

                            error = null;
                          });
                        } else {
                          setState(() {
                            showLoader = true;
                            error = response.data['message'];
                          });
                        }
                      },
                    );
                  } else {
                    setState(
                      () {
                        searchedData = [];
                        searchedCategoryData = [];
                      },
                    );
                  }
                },
              ),
              if (error != null)
                if (_searchController.text.isNotEmpty && error == null)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              if (error != null) SizedBox(height: 5),
              if (error != null && _searchController.text.isNotEmpty)
                Center(
                  child: Text(error),
                ),
              if (searchedData.length > 0 && _searchController.text.isNotEmpty) SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    buildDetails(context, searchedData),
                    SizedBox(height: 10),
                    buildCategoryDetails(context, searchedCategoryData),
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
              horizontal: 5,
              vertical: 0,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.toNamed('/product-detail', arguments: {"type": "search", "data": post});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Icon(
                          UniconsLine.search,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text(
                              capitalize(post['name']),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildCategoryDetails(BuildContext context, List searchedCategoryData) {
    return Column(
      children: <Widget>[
        for (Map post in searchedCategoryData)
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.toNamed("/product-list", arguments: {
                  "category": [post['id']],
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Icon(
                          UniconsLine.search,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            text(
                              capitalize(post['name']),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      text(
                        'Category',
                        textColor: colorPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    searchedData = [];
    super.dispose();
  }
}
