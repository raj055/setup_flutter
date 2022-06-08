import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/debouncer.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';

class GuestSearch extends StatefulWidget {
  @override
  _GuestSearchState createState() => _GuestSearchState();
}

class _GuestSearchState extends State<GuestSearch> {
  bool showLoader = false;
  String followUp = "4";
  TextEditingController _searchController = TextEditingController();
  List? searchedData = [];
  final Debouncer onSearchDebouncer = Debouncer(delay: Duration(milliseconds: 500));
  List<String> _statusValues = [];
  List<String> _statusPresentationValues = [];

  List? typeLabels = [];

  Future _futureBuild() {
    return Api.http.get('new-guest-labels').then((res) {
      typeLabels = res.data["guestLabels"];
      return res.data;
    });
  }

  @override
  void initState() {
    _futureBuild();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Translator.get('Guest List Search')!)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
                  hintText: Translator.get('Search Guest. . .'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (text) {
                  this.onSearchDebouncer.debounce(
                    () {
                      if (text.isNotEmpty) {
                        showLoader = false;
                        Api.httpWithoutLoader.post(
                          'guest-search',
                          data: {"guest-search": _searchController.text},
                        ).then(
                          (response) {
                            if (response.data['status']) {
                              setState(() {
                                showLoader = true;
                                searchedData = response.data['data'];
                                searchedData!.map((search) {
                                  search.putIfAbsent('guestLabel', () => null);
                                }).toList();
                              });
                            } else {
                              setState(() {
                                showLoader = true;
                              });
                            }
                          },
                        );
                      }
                    },
                  );
                  setState(() {
                    _searchController.text.length;
                  });
                },
              ),
              if (searchedData == null)
                Center(
                  child: CircularProgressIndicator(),
                ),
              if (searchedData != null &&
                  searchedData!.length > 0 &&
                  _searchController.text.isNotEmpty &&
                  _searchController.text.length > 0)
                Expanded(
                    child: ListView.builder(
                  itemCount: searchedData!.length,
                  itemBuilder: (context, index) {
                    return buildDetails(context, searchedData!, index);
                  },
                )

                    // ListView(
                    //   children: <Widget>[
                    //     buildDetails(context, searchedData),
                    //   ],
                    // ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetails(BuildContext context, List searchedData, index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // for (Map guestSearchData in searchedData)
        if (searchedData[index]['label_name'] == 'New Guest') ...[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: FadeAnimation(
              0.0,
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD1DCFF),
                      blurRadius: 10.0,
                      // has the effect of softening the shadow
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.account_circle,
                                    size: SizeConfig.width(8),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: SizeConfig.width(2)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  searchedData[index]["name"],
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["mobile"],
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: SizeConfig.width(4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Date")! + " : ",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["created_at"],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Trust")!,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: 0.3,
                                  backgroundColor: Colors.black12,
                                  valueColor: AlwaysStoppedAnimation(Colors.green),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: _buildChangeStatusField(searchedData, index),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ] else if (searchedData[index]['label_name'] == 'Invited') ...[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: FadeAnimation(
              0.0,
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD1DCFF),
                      blurRadius: 10.0,
                      // has the effect of softening the shadow
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.account_circle,
                                    size: SizeConfig.width(8),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: SizeConfig.width(2)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  searchedData[index]["name"],
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["mobile"],
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: SizeConfig.width(4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Date")! + " : ",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["created_at"],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Invited For")! + "\n" + Translator.get("Webinar")!,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Text(Translator.get('Meeting Attended')!),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            FlatButton(
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                Api.http.put(
                                  "change-invited-guest-label",
                                  data: {
                                    "meeting_attended": "1",
                                    "guest_id": searchedData[index]['user_id'],
                                    "mobile": searchedData[index]["mobile"],
                                    "label_id": "3"
                                  },
                                ).then(
                                  (res) {
                                    GetBar(
                                      backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                      duration: Duration(seconds: 5),
                                      message: res.data['message'],
                                    ).show();
                                  },
                                ).catchError(
                                  (error) {
                                    if (error.response.statusCode == 422) {
                                      GetBar(
                                        backgroundColor: error.data['status'] ? Colors.green : Colors.red,
                                        duration: Duration(seconds: 5),
                                        message: error.response.data['errors'],
                                      ).show();
                                    }
                                  },
                                );
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                            ),
                            SizedBox(width: 10),
                            FlatButton(
                              child: Text(
                                'No',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                Api.http.put(
                                  "change-invited-guest-label",
                                  data: {
                                    "meeting_attended": "2",
                                    "guest_id": searchedData[index]['user_id'],
                                    "mobile": searchedData[index]["mobile"],
                                    "label_id": "3"
                                  },
                                ).then(
                                  (res) {
                                    GetBar(
                                      backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                      duration: Duration(seconds: 5),
                                      message: res.data['message'],
                                    ).show();
                                  },
                                ).catchError(
                                  (error) {
                                    if (error.response.statusCode == 422) {
                                      GetBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 5),
                                        message: error.response.data['errors'],
                                      ).show();
                                    }
                                  },
                                );
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (searchedData[index]['label_name'] == 'Presentation') ...[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: FadeAnimation(
              0.0,
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD1DCFF),
                      blurRadius: 10.0,
                      // has the effect of softening the shadow
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.account_circle,
                                    size: SizeConfig.width(8),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: SizeConfig.width(2)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  searchedData[index]["name"],
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["mobile"],
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: SizeConfig.width(4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Date")! + " : ",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["created_at"],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Invited For")! + "\n" + Translator.get("Webinar")!,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(child: _buildChangeStatusPresentationField(searchedData, index)),
                        Expanded(
                          child: FlatButton(
                            child: Text(
                              Translator.get('Start Follow Up')!,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              Api.http.post(
                                'change-guest-label',
                                data: {"mobile": searchedData[index]["mobile"], "label_id": followUp},
                              ).then(
                                (response) async {
                                  GetBar(
                                    backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                    duration: Duration(seconds: 5),
                                    message: response.data['message'],
                                  ).show();
                                },
                              ).catchError(
                                (error) {
                                  if (error.response.statusCode == 422) {
                                    GetBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                      message: error.response.data['errors'],
                                    ).show();
                                  } else if (error.response.statusCode == 401) {
                                    GetBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 5),
                                      message: error.response.data['errors'],
                                    ).show();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (searchedData[index]['label_name'] == 'Follow Up') ...[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: FadeAnimation(
              0.0,
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD1DCFF),
                      blurRadius: 10.0,
                      // has the effect of softening the shadow
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.account_circle,
                                    size: SizeConfig.width(8),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: SizeConfig.width(2)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  searchedData[index]["name"],
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["mobile"],
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: SizeConfig.width(4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Date")! + " : ",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["created_at"],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Auto Follow Up")! + "\n" + Translator.get("ON/OFF")!,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Text(Translator.get('Joined With You')!),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            FlatButton(
                              child: Text(
                                Translator.get('Yes')!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                Api.http.put(
                                  "change-follow-up-guest-label",
                                  data: {"joined": "1", "mobile": searchedData[index]["mobile"], "label_id": "4"},
                                ).then(
                                  (res) {
                                    GetBar(
                                      backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                      duration: Duration(seconds: 5),
                                      message: res.data['message'],
                                    ).show();
                                  },
                                ).catchError(
                                  (error) {
                                    if (error.response.statusCode == 422) {
                                      GetBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 5),
                                        message: error.response.data['errors'],
                                      ).show();
                                    }
                                  },
                                );
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                            ),
                            SizedBox(width: 10),
                            FlatButton(
                              child: Text(
                                Translator.get('No')!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                Api.http.put(
                                  "change-follow-up-guest-label",
                                  data: {"joined": "2", "mobile": searchedData[index]["mobile"], "label_id": "4"},
                                ).then(
                                  (res) {
                                    GetBar(
                                      backgroundColor: res.data['status'] ? Colors.green : Colors.red,
                                      duration: Duration(seconds: 5),
                                      message: res.data['message'],
                                    ).show();
                                  },
                                ).catchError(
                                  (error) {
                                    if (error.response.statusCode == 422) {
                                      GetBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 5),
                                        message: error.response.data['errors'],
                                      ).show();
                                    }
                                  },
                                );
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
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
        ] else if (searchedData[index]['label_name'] == 'Closed') ...[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: FadeAnimation(
              0.0,
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD1DCFF),
                      blurRadius: 10.0,
                      // has the effect of softening the shadow
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.account_circle,
                                    size: SizeConfig.width(8),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: SizeConfig.width(2)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  searchedData[index]["name"],
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["mobile"],
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: SizeConfig.width(4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Date")! + " : ",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["created_at"],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Days to Close")!,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]['day'] != null ? searchedData[index]['day'].toString() : "0",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (searchedData[index]['label_name'] == 'Died') ...[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            child: FadeAnimation(
              0.0,
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD1DCFF),
                      blurRadius: 10.0,
                      // has the effect of softening the shadow
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.account_circle,
                                    size: SizeConfig.width(8),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: SizeConfig.width(2)),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  searchedData[index]["name"],
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["mobile"],
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: SizeConfig.width(4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Date")! + " : ",
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]["created_at"],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  Translator.get("Days to Died")!,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  searchedData[index]['day'] != null ? searchedData[index]['day'].toString() : "0",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (searchedData[index]['status'] == false) ...[
          Center(
            child: Text(searchedData[index]['error']),
          )
        ],
      ],
    );
  }

  Widget _buildChangeStatusField(searchedData, listIndex) {
    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: DropdownButtonFormField(
        isDense: true,
        isExpanded: true,
        value: searchedData[listIndex]['guestLabel'],
        onChanged: (dynamic newValue) {
          setState(() {
            searchedData[listIndex]['guestLabel'] = newValue;
          });

          Map sendData = {
            "mobile": searchedData[listIndex]["mobile"],
            "label_id": searchedData[listIndex]['guestLabel']
          };

          Api.http.post('change-guest-label', data: sendData).then(
            (response) async {
              GetBar(
                backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                duration: Duration(seconds: 5),
                message: response.data['message'],
              ).show();
            },
          ).catchError(
            (error) {
              if (error.response.statusCode == 422) {
                GetBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  message: error.response.data['errors'],
                ).show();
              } else if (error.response.statusCode == 401) {
                GetBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                  message: error.response.data['errors'],
                ).show();
              }
            },
          );
        },
        hint: Text(Translator.get('Change Status')!),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        items: typeLabels!.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value['id'].toString(),
            child: Text(value['value']),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChangeStatusPresentationField(guestSearchData, listIndex) {
    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: DropdownButtonFormField(
        isDense: true,
        isExpanded: true,
        value: guestSearchData[listIndex]['guestLabel'],
        onChanged: ((dynamic newValue) {
          setState(() {
            searchedData![listIndex]['guestLabel'] = newValue;
          });

          Api.http.post(
            'change-guest-label',
            data: {
              "mobile": guestSearchData[listIndex]["mobile"],
              "label_id": searchedData![listIndex]['guestLabel'],
            },
          ).then(
            (response) async {
              GetBar(
                backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                duration: Duration(seconds: 5),
                message: response.data['message'],
              ).show();
            },
          ).catchError(
            (error) {
              if (error.response.statusCode == 422) {
                GetBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  message: error.response.data['errors'],
                ).show();
              } else if (error.response.statusCode == 401) {
                GetBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                  message: error.response.data['errors'],
                ).show();
              }
            },
          );
        }),
        hint: Text(Translator.get('Change Status')!),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        items: typeLabels!.map<DropdownMenuItem<String>>(
          (value) {
            return DropdownMenuItem<String>(
              value: value['id'].toString(),
              child: Text(value['value']),
            );
          },
        ).toList(),
      ),
    );
  }
}
