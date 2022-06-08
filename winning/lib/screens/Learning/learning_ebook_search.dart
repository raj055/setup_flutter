import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class LearningEBookSearch extends StatefulWidget {
  @override
  _LearningEBookSearchState createState() => _LearningEBookSearchState();
}

class _LearningEBookSearchState extends State<LearningEBookSearch> {
  String? error;
  bool showLoader = false;
  String type = "3";
  TextEditingController _searchController = TextEditingController();
  List? searchedData = [];

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
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
                    hintText: Translator.get('Search ..'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    showLoader = false;
                    Api.httpWithoutLoader.post(
                      'learning-search',
                      data: {"search": _searchController.text, "type": type},
                    ).then(
                      (response) {
                        if (response.data['status']) {
                          setState(() {
                            showLoader = true;
                            searchedData = response.data['data'];
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
        for (Map post in searchedData as Iterable<Map<dynamic, dynamic>>)
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
                if (post['status_id'] == 0) {
                  Get.toNamed('learning-ebook-list',
                      arguments: {"eBookData": post['packageDescription'], "name": post['name']});
                } else {
                  _showDialog();
                  setState(() {});
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: PNetworkImage(
                          post['image'] != null && post['image'].length > 0 ? post['image'] : 'null',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                capitalize(post['name']),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                post['price'] != null ? "₹ ${post['price'].toString()}" : "Free".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
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

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Translator.get("Requests Status")!,
          ),
          content: Text(Translator.get("Member Name")!, style: TextStyle(fontSize: 15)),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text(
                    Translator.get("Reject")!,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  child: Text(
                    Translator.get("Approve")!,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
