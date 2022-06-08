import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../screens/notes/edit_note.dart';
import '../../services/api.dart';
import '../../services/debouncer.dart';
import '../../services/translator.dart';

class NoteSearch extends StatefulWidget {
  @override
  _NoteSearchState createState() => _NoteSearchState();
}

class _NoteSearchState extends State<NoteSearch> {
  final List<Color> colors = [
    Color(0xFFfff176),
    Color(0xFFffcc80),
    Color(0xFFb2ff59),
    Color(0xFFb9f6ca),
    Color(0xFFe1bee7),
  ];

  String? error;
  bool showLoader = false;
  TextEditingController _searchController = TextEditingController();
  List? searchedData = [];
  final Debouncer onSearchDebouncer = Debouncer(delay: new Duration(milliseconds: 500));

  Color? getDynamicColors() {
    Color? color;
    var rng = new Random();
    for (var i = 0; i < colors.length; i++) {
      color = colors[rng.nextInt(colors.length)];
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
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
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    ),
                    hintText: Translator.get('Search your notes here..'),
                    border: OutlineInputBorder()),
                onChanged: (text) {
                  this.onSearchDebouncer.debounce(
                    () {
                      if (text.isNotEmpty) {
                        showLoader = true;
                        getSearchedData();
                      }
                    },
                  );
                },
              ),
              if (_searchController.text.isNotEmpty && showLoader)
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

  void getSearchedData() {
    Api.httpWithoutLoader.post('notes-search', data: {"notes_search": _searchController.text}).then(
      (response) {
        if (response.data['status']) {
          List noteSearch = response.data['data'];
          noteSearch.map(
            (note) {
              note.putIfAbsent('isViewMore', () => false);
            },
          ).toList();
          response.data['data'] = noteSearch;
          if (searchedData != null)
            setState(() {
              showLoader = false;
              searchedData = response.data['data'];
              error = null;
            });
        } else {
          setState(() {
            showLoader = false;
            error = response.data['error'];
          });
        }
      },
    );
  }

  Widget buildDetails(BuildContext context, List searchedData) {
    return Column(
      children: <Widget>[
        for (Map post in searchedData)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNote(note: post),
                    ),
                  ).then(
                    (value) {
                      getSearchedData();
                    },
                  );
                },
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            post['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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
                                        FlatButton(
                                          child: Text(Translator.get("YES")!),
                                          onPressed: () {
                                            Api.http.put('notes-delete', data: {'notes_id': post['id']}).then(
                                              (res) {
                                                GetBar(
                                                  backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                                  message: res.data['message'],
                                                  duration: Duration(seconds: 2),
                                                ).show();
                                                getSearchedData();
                                              },
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          post['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: !post['isViewMore'] ? 2 : null,
                          overflow: !post['isViewMore'] ? TextOverflow.fade : TextOverflow.visible,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              Translator.get('Last updated')! + ' : ' + post['updatedAt'],
                              style: TextStyle(fontSize: 11),
                            )
                          ],
                        ),
                        if (post['description'].length > 75)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    post['isViewMore'] = !post['isViewMore'];
                                  });
                                },
                                child: Text(
                                  !post['isViewMore'] ? "View More" : "Less",
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
