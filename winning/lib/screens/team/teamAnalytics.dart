import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class TeamAnalytics extends StatefulWidget {
  @override
  _TeamAnalyticsState createState() => _TeamAnalyticsState();
}

class _TeamAnalyticsState extends State<TeamAnalytics> {
  GlobalKey<PaginatorState> associateGlobalKey = GlobalKey();
  final format = DateFormat("yyyy-MM-dd");
  var type = "2";
  Translator? translator;
  Future? _teamAnalyticsApi;
  late var teamAnalyticsData;
  double teamPerformanceMaxY = 0;

  @override
  void initState() {
    _teamAnalyticsApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.get('analytics?type=$type').then(
      (res) {
        teamAnalyticsData = res.data;
        return res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Translator.get('Team Analytics')!)),
      body: FutureBuilder(
        future: _teamAnalyticsApi,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: teamAnalyticsData["chartData"].length,
            itemBuilder: (context, index) {
              Map chartDetails = teamAnalyticsData["chartData"][index];
              String? chartName = chartDetails['name'];

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
                  decoration: boxDecoration(
                    radius: 10,
                    showShadow: true,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  text(
                                    chartName,
                                    fontFamily: fontBold,
                                    textColor: colorPrimary,
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
                                      borderRadius: BorderRadius.circular(4)),
                                  color: const Color(0xffffffff),
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: teamPerformanceMaxY + 2,
                                      minY: 0,
                                      barTouchData: BarTouchData(
                                        enabled: false,
                                        touchTooltipData: BarTouchTooltipData(
                                          tooltipBgColor: Colors.transparent,
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
                                              rod.y.round().toString(),
                                              TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
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
                                              color: const Color(0xff7589a2),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          margin: 20,
                                          getTitles: (double value) {
                                            switch (value.toInt()) {
                                              case 0:
                                                return chartData.length >= 0
                                                    ? chartData[0]['date']
                                                    : "null";
                                              case 1:
                                                return chartData.length >= 1
                                                    ? chartData[1]['date']
                                                    : "null";
                                              case 2:
                                                return chartData.length >= 2
                                                    ? chartData[2]['date']
                                                    : "null";
                                              case 3:
                                                return chartData.length >= 3
                                                    ? chartData[3]['date']
                                                    : "null";
                                              case 4:
                                                return chartData.length >= 4
                                                    ? chartData[4]['date']
                                                    : "null";
                                              case 5:
                                                return chartData.length >= 5
                                                    ? chartData[5]['date']
                                                    : "null";
                                              case 6:
                                                return chartData.length >= 6
                                                    ? chartData[6]['date']
                                                    : "null";

                                              default:
                                                return '';
                                            }
                                          },
                                        ),
                                        leftTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      barGroups: _buildList(chartData),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : text(
                              Translator.get('No analytics in this category')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('associate_name_analytics', arguments: "analytics");
        },
        label: text(
          Translator.get('Member Analytics')!.toUpperCase(),
          textColor: white,
          fontFamily: fontSemibold,
        ),
        backgroundColor: Colors.redAccent,
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
