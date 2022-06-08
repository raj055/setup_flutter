import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/translator.dart';

class DetailsAnalytics extends StatefulWidget {
  @override
  _DetailsAnalyticsState createState() => _DetailsAnalyticsState();
}

class _DetailsAnalyticsState extends State<DetailsAnalytics> {
  final format = DateFormat("yyyy-MM-dd");
  var type = "3";
  Future? _teamMemberAnalyticsApi;
  late var teamMemberAnalyticsData;
  double teamPerformanceMaxY = 0;
  Map? detailsAnalytics;

  @override
  void initState() {
    detailsAnalytics = Get.arguments;
    _teamMemberAnalyticsApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http
        .get("analytics?type=$type&userId=${detailsAnalytics!["id"]}")
        .then(
      (res) {
        teamMemberAnalyticsData = res.data;
        return res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(detailsAnalytics!["name"]),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _teamMemberAnalyticsApi,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }
          if (teamMemberAnalyticsData['status']) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: teamMemberAnalyticsData["chartData"].length,
              itemBuilder: (context, index) {
                Map chartDetails = teamMemberAnalyticsData["chartData"][index];
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                        borderRadius: BorderRadius.circular(4)),
                                    color: const Color(0xffffffff),
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
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
                            : Text(Translator.get(
                                "No analytics in this category")!),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Icon(
                        Icons.table_chart,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      Translator.get('No data found')!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
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
