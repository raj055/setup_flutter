import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';

class DetailsTeamActivity extends StatefulWidget {
  @override
  _DetailsTeamActivityState createState() => _DetailsTeamActivityState();
}

class _DetailsTeamActivityState extends State<DetailsTeamActivity> {
  Future? _teamAssociateActivityApi;
  late var teamAssociateData;
  var chartData;
  List tempChartData = [];
  Map? detailsTeamActivity;

  @override
  void initState() {
    detailsTeamActivity = Get.arguments;
    _teamAssociateActivityApi = _futureBuild();
    super.initState();
  }

  Future _futureBuild() {
    return Api.http.post('team-associate-activity', data: {"id": detailsTeamActivity!["id"]}).then(
      (response) {
        setState(() {
          teamAssociateData = response.data;
        });

        return response;
      },
    ).catchError(
      (error) {
        if (error.response.statusCode == 422) {
          GetBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: AppBar(
        title: Text(detailsTeamActivity!["name"]),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _teamAssociateActivityApi,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center();
            }

            return Column(
              children: <Widget>[
                Center(
                  child: _buildChart(context),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      Translator.get("Activity details")!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.blue,
                ),
                _dreamDetailsField(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    num total = 0;

    for (Map details in teamAssociateData['donutCharts']) {
      total += details["value"];
    }

    if (total > 0) {
      return Container(
        height: 300,
        width: SizeConfig.screenWidth! - 100,
        child: DonutPieChart.withSampleData(teamAssociateData),
      );
    }
    return Center();
  }

  Widget _dreamDetailsField() {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            teamAssociateData['percentage'].toString() + " %",
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}

class DonutPieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool? animate;

  DonutPieChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory DonutPieChart.withSampleData(activityData) {
    return DonutPieChart(
      _createSampleData(activityData),
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(
      seriesList,
      animate: animate!,
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 80,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(),
        ],
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, String?>> _createSampleData(activityData) {
    final data = [
      LinearSales(activityData["donutCharts"][0]["id"], activityData["donutCharts"][0]["value"]),
      LinearSales(activityData["donutCharts"][1]["id"], activityData["donutCharts"][1]["value"]),
    ];

    return [
      charts.Series<LinearSales, String?>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.month,
        measureFn: (LinearSales sales, _) => sales.sales!,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final String? month;
  final int? sales;

  LinearSales(this.month, this.sales);
}
