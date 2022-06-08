import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';

class LearningEBookContentSearch extends StatefulWidget {
  @override
  _LearningEBookContentSearchState createState() =>
      _LearningEBookContentSearchState();
}

class _LearningEBookContentSearchState
    extends State<LearningEBookContentSearch> {
  String? error;
  bool showLoader = false;
  String type = "3";
  TextEditingController _searchController = TextEditingController();
  List? searchedData = [];

  @override
  void initState() {
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
                    prefixIcon: GestureDetector(
                      child: Icon(
                        Icons.arrow_back,
                      ),
                      onTap: () {
                        Get.back();
                      },
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
                    border: OutlineInputBorder()),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    showLoader = false;
                    Api.httpWithoutLoader.post(
                      'learning-content-search',
                      data: {
                        "learning_id": Get.parameters['learningId'],
                        "learning_content_search": _searchController.text,
                        "type": type
                      },
                    ).then(
                      (response) {
                        if (response.data['status']) {
                          setState(
                            () {
                              showLoader = true;
                              searchedData = response.data['data'];
                            },
                          );
                        } else {
                          setState(
                            () {
                              error = response.data['error'];
                              error = null;
                            },
                          );
                        }
                      },
                    );
                  } else {
                    setState(
                      () {
                        searchedData = null;
                      },
                    );
                  }
                },
              ),
              if (error != null)
                if (searchedData == null &&
                    _searchController.text.isNotEmpty &&
                    error == null)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              if (error != null) SizedBox(height: 5),
              if (error != null && _searchController.text.isNotEmpty)
                Center(
                  child: Text(error!),
                ),
              if (searchedData != null &&
                  searchedData!.length > 0 &&
                  _searchController.text.isNotEmpty)
                SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    if (searchedData != null &&
                        _searchController.text.isNotEmpty &&
                        error == null)
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
                5.0,
              ),
            ),
            margin: const EdgeInsets.all(8),
            height: 120,
            width: double.infinity,
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: PNetworkImage(
                        post['image'],
                        fit: BoxFit.contain,
                        height: 100,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          ReCase(post['ebook_title']).titleCase,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: SizeConfig.width(3.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: SizeConfig.height(1),
                        ),
                        Text(
                          post['ebook_description'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig.width(3.5),
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
