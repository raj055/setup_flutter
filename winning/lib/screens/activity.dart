import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/api.dart';
import '../services/translator.dart';
import '../widget/indicator.dart';
import '../widget/theme.dart';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  Future? _activityApi;
  late var activityData;
  var chartData;
  List tempChartData = [];
  int? touchedIndex;

  @override
  void initState() {
    _activityApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.get('my-activity').then(
      (res) {
        activityData = res.data;
        return res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Translator.get('Activity')!)),
      body: FutureBuilder(
        future: _activityApi,
        builder: (BuildContext context, AsyncSnapshot sanpshot) {
          if (!sanpshot.hasData) {
            return Center();
          }
          return _buildBody(context);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    num total = 0;

    for (Map details in activityData['donutCharts']) {
      total += details["value"];
    }

    if (total == 0) {
      return _buildNoActivityView();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: _buildChart(context),
          ),
          SizedBox(height: 30),
          Text(
            activityData['percentage'].toString() + "%",
            style: TextStyle(
              fontSize: 60,
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(
            color: Colors.blue,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.close),
                SizedBox(width: 10),
                Text(
                  Translator.get('Closed -')! + activityData['percentage'].toString() + "%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Container(
                padding: EdgeInsets.all(15),
                child: text(
                  activityData['message'],
                  isLongText: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActivityView() {
    return Center(
      child: emptyWidget(
        context,
        'assets/images/no_result.png',
        "${Translator.get('No Activity Data Found')}",
        "${Translator.get('There was no record based on the details you entered.')}",
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(height: 10),
              Expanded(
                child: PieChart(
                  PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (pieTouchResponse) {
                          setState(() {
                            if (pieTouchResponse.touchInput is FlLongPressEnd ||
                                pieTouchResponse.touchInput is FlPanEnd) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex = pieTouchResponse.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections() as List<PieChartSectionData>),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Indicator(
                    color: Color(0xff0293ee),
                    text: Translator.get('presentationGuests'),
                    isSquare: true,
                    size: 14,
                  ),
                  SizedBox(height: 10),
                  Indicator(
                    color: Color(0xfff8b250),
                    text: Translator.get('closedGuests'),
                    isSquare: true,
                    size: 14,
                  ),
                ],
              ),
              SizedBox(
                width: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData?> showingSections() {
    return List.generate(
      2,
      (i) {
        final isTouched = i == touchedIndex;
        final double fontSize = isTouched ? 25 : 16;
        final double radius = isTouched ? 60 : 50;
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: const Color(0xff0293ee),
              value: double.parse(activityData['donutCharts'][0]['value'].toString()),
              title: activityData["donutCharts"][0]["value"] != 0
                  ? activityData["donutCharts"][0]["value"].toString()
                  : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
            );
          case 1:
            return PieChartSectionData(
              color: const Color(0xfff8b250),
              value: double.parse(activityData["donutCharts"][1]["value"].toString()),
              title: activityData["donutCharts"][1]["value"] != 0
                  ? activityData["donutCharts"][1]["value"].toString()
                  : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
            );
          default:
            return null;
        }
      },
    );
  }
}
