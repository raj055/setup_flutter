import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../services/api.dart';

class PlanScreen extends StatefulWidget {
  final Map<String, String> data;

  PlanScreen(this.data);

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final Color primaryColor = Colors.blue;

  final Color bgColor = Color(0xffF9E0E3);

  final Color secondaryColor = Color(0xff324558);

  Response? rechargePlans;

  Future<Response> getData(String url) async {
    Response response = await Api.http.get(url);

    final int statusCode = response.statusCode!;

    try {
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw Exception("Error While fetching data");
      }
    } catch (e) {
      print('e $e');
    }

    return response;
  }

  @override
  void initState() {
    super.initState();
//    getData('recharge/circle?b2b_id=' + b2bId);
  }

  getAllData(String url) {
    return getData(url);
  }

  Widget planData(Map res) {
    return Card(
      child: Container(
        padding: EdgeInsets.only(top: 0, bottom: 20, left: 0, right: 0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(res['recharge_description']),
                      )
//                            Text('Col'),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      OutlineButton(
                        padding: EdgeInsets.all(0),
                        child: Text('₹ ' + res['recharge_value']),
                        onPressed: () {
                          Navigator.pop(context, res['recharge_value']);
                        },
                        borderSide: BorderSide(color: Colors.blue),
                        textColor: Colors.blue,
                      )
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Talktime',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          res['recharge_talktime'],
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Data',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '-\n',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Validity',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(res['recharge_validity'] + '\n'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
          // future: getAllData('recharge/rechargePlans?code=' +
          //     this.widget.data!['operatorCode'] +
          //     '&circle=' +
          //     this.widget.data!['circleCode']),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
//            if (!snapshot.hasData) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('You do not have any plans yet.'),
          );
        }

        List plans = snapshot.data.data;

        return DefaultTabController(
          initialIndex: 0,
          length: plans.length,
          child: Theme(
            data: ThemeData(
              primaryColor: primaryColor,
              appBarTheme: AppBarTheme(
                color: Colors.white,
                textTheme: TextTheme(
                  title: TextStyle(
                    color: secondaryColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconTheme: IconThemeData(color: secondaryColor),
                actionsIconTheme: IconThemeData(
                  color: secondaryColor,
                ),
              ),
            ),
            child: Scaffold(
              backgroundColor: Color(0xFFCACACA),
              appBar: AppBar(
                centerTitle: true,
                title: Text('Recharge Plans'),
                bottom: TabBar(
                  isScrollable: true,
                  labelColor: primaryColor,
                  indicatorColor: primaryColor,
                  unselectedLabelColor: secondaryColor,
                  tabs: <Widget>[
                    for (var res in plans)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(res['name']),
                      ),
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  for (var res in plans)
                    ListView.builder(
                      itemBuilder: (context, index) {
                        return planData(res['data'][index]);
                      },
                      itemCount: res['data'].length,
                    )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
