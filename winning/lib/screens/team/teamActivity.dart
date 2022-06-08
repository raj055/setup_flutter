import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/indicator.dart';
import '../../widget/theme.dart';

class TeamActivity extends StatefulWidget {
  @override
  _TeamActivityState createState() => _TeamActivityState();
}

class _TeamActivityState extends State<TeamActivity> {
  Future? _teamActivityApi;
  List tempChartData = [];
  int? touchedIndex;
  Translator? translator;
  late var teamActivityData;

  @override
  void initState() {
    _teamActivityApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.get('team-activity').then(
      (res) {
        teamActivityData = res.data;
        return res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: AppBar(
        title: Text(
          Translator.get('Team Activity')!,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _teamActivityApi,
          builder: (BuildContext context, AsyncSnapshot sanpshot) {
            if (!sanpshot.hasData) {
              return Center();
            }
            return Column(
              children: <Widget>[
                Center(
                  child: _buildChart(context),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('associate_name_analytics', arguments: "activity");
        },
        label: text(
          Translator.get('Member Activity')!.toUpperCase(),
          textColor: white,
          fontFamily: fontSemibold,
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD1DCFF),
            blurRadius: 10.0, // has the effect of softening the shadow
            spreadRadius: 1.0, // has the effect of extending the shadow
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20.0,
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (pieTouchResponse) {
                          setState(
                            () {
                              if (pieTouchResponse.touchInput is FlLongPressEnd ||
                                  pieTouchResponse.touchInput is FlPanEnd) {
                                touchedIndex = -1;
                              } else {
                                touchedIndex = pieTouchResponse.touchedSectionIndex;
                              }
                            },
                          );
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
              const SizedBox(
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
              value: double.parse(teamActivityData['donutCharts'][0]['value'].toString()),
              title: teamActivityData["donutCharts"][0]["value"] != 0
                  ? teamActivityData["donutCharts"][0]["value"].toString()
                  : '',
              radius: radius,
              titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
            );
          case 1:
            return PieChartSectionData(
              color: const Color(0xfff8b250),
              value: double.parse(teamActivityData["donutCharts"][1]["value"].toString()),
              title: teamActivityData["donutCharts"][1]["value"] != 0
                  ? teamActivityData["donutCharts"][1]["value"].toString()
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
