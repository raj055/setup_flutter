import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../../services/api.dart';
import '../../../services/translator.dart';
import '../../../widget/theme.dart';

class TeamDetails extends StatefulWidget {
  @override
  _TeamDetailsState createState() => _TeamDetailsState();
}

class _TeamDetailsState extends State<TeamDetails> {
  Future? _teamAnalyticsApi;
  late var teamAnalytics;
  Map? teamDetails;
  double teamPerformanceMaxY = 0;

  @override
  void initState() {
    teamDetails = Get.arguments;
    _teamAnalyticsApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http
        .post('team-analytics', data: {'team_id': teamDetails!['id']}).then(
      (response) {
        teamAnalytics = response.data;
        return response.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamDetails!['name']),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Get.toNamed('edit-team', arguments: teamDetails);
              },
              child: Icon(
                Icons.edit,
                size: 25,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: text(
                        Translator.get('Team Members Name'),
                        fontFamily: fontSemibold,
                        textColor: colorPrimaryDark,
                      ),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: teamDetails!['teamMembers'].length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: boxDecoration(
                              radius: 10,
                              showShadow: true,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(Feather.user),
                              ),
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: teamDetails!['teamMembers']
                                                [index]['memberName'],
                                            style: TextStyle(
                                              color: Colors.black54
                                                  .withOpacity(0.5),
                                              fontSize: textSizeMedium,
                                              fontFamily: fontSemibold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                "(${teamDetails!['teamMembers'][index]['memberCode']})",
                                            style: TextStyle(
                                              fontSize: textSizeMedium,
                                              fontFamily: fontSemibold,
                                              color: colorPrimary,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                              subtitle: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            Icon(
                                              Feather.smartphone,
                                              size: 12,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              teamDetails!['teamMembers'][index]
                                                  ['memberMobile'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black45,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          teamDetails!['teamMembers'][index]
                                              ['memberPackage'],
                                          style: TextStyle(
                                            color: colorPrimary,
                                            fontFamily: fontBold,
                                            fontSize: textSizeLargeMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Container(
                child: FutureBuilder(
                  future: _teamAnalyticsApi,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center();
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: teamAnalytics["chartData"].length,
                      itemBuilder: (context, index) {
                        Map chartDetails = teamAnalytics["chartData"][index];
                        String chartName = chartDetails['name'];

                        List chartData = chartDetails['data'].map(
                          (data) {
                            if (data['count'] > teamPerformanceMaxY) {
                              teamPerformanceMaxY = double.parse(
                                data['count'].toString(),
                              );
                            }
                            return {
                              'date': data['date'],
                              'count': data['count'],
                            };
                          },
                        ).toList();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 15,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 15,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              chartName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                chartData.length > 0
                                    ? Container(
                                        height: 220,
                                        child: AspectRatio(
                                          aspectRatio: 1.7,
                                          child: Card(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            color: const Color(0xffffffff),
                                            child: BarChart(
                                              BarChartData(
                                                alignment: BarChartAlignment
                                                    .spaceAround,
                                                maxY: teamPerformanceMaxY + 2,
                                                minY: 0,
                                                barTouchData: BarTouchData(
                                                  enabled: false,
                                                  touchTooltipData:
                                                      BarTouchTooltipData(
                                                    tooltipBgColor:
                                                        Colors.transparent,
                                                    tooltipPadding:
                                                        const EdgeInsets.all(0),
                                                    tooltipBottomMargin: 8,
                                                    getTooltipItem: (
                                                      BarChartGroupData group,
                                                      int groupIndex,
                                                      BarChartRodData rod,
                                                      int rodIndex,
                                                    ) {
                                                      return BarTooltipItem(
                                                        rod.y
                                                            .round()
                                                            .toString(),
                                                        TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                titlesData: FlTitlesData(
                                                  show: true,
                                                  bottomTitles: SideTitles(
                                                    showTitles: true,
                                                    textStyle: TextStyle(
                                                        color: const Color(
                                                            0xff7589a2),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                    margin: 20,
                                                    getTitles: (double value) {
                                                      switch (value.toInt()) {
                                                        case 0:
                                                          return chartData
                                                                      .length >=
                                                                  0
                                                              ? chartData[0]
                                                                  ['date']
                                                              : "null";
                                                        case 1:
                                                          return chartData
                                                                      .length >=
                                                                  1
                                                              ? chartData[1]
                                                                  ['date']
                                                              : "null";
                                                        case 2:
                                                          return chartData
                                                                      .length >=
                                                                  2
                                                              ? chartData[2]
                                                                  ['date']
                                                              : "null";
                                                        case 3:
                                                          return chartData
                                                                      .length >=
                                                                  3
                                                              ? chartData[3]
                                                                  ['date']
                                                              : "null";
                                                        case 4:
                                                          return chartData
                                                                      .length >=
                                                                  4
                                                              ? chartData[4]
                                                                  ['date']
                                                              : "null";
                                                        case 5:
                                                          return chartData
                                                                      .length >=
                                                                  5
                                                              ? chartData[5]
                                                                  ['date']
                                                              : "null";
                                                        case 6:
                                                          return chartData
                                                                      .length >=
                                                                  6
                                                              ? chartData[6]
                                                                  ['date']
                                                              : "null";

                                                        default:
                                                          return '';
                                                      }
                                                    },
                                                  ),
                                                  leftTitles: SideTitles(
                                                      showTitles: false),
                                                ),
                                                borderData: FlBorderData(
                                                  show: false,
                                                ),
                                                barGroups:
                                                    _buildList(chartData),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        Translator.get(
                                            "No analytics in this category")!,
                                      ),
                                SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildList(chartData) {
    List<BarChartGroupData> chartRod = [];
    for (int i = 0; i < chartData.length; i++) {
      chartRod.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                y: double.parse(chartData[i]['count'].toString()),
                color: Colors.lightBlueAccent),
          ],
          showingTooltipIndicators: [0, 1, 2, 3, 4, 5, 6],
        ),
      );
    }
    return chartRod;
  }
}
