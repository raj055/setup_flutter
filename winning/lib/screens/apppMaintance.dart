import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;

import '../services/translator.dart';
import '../widget/theme.dart';

class AppMaintenance extends StatefulWidget {
  @override
  _AppMaintenanceState createState() => _AppMaintenanceState();
}

class _AppMaintenanceState extends State<AppMaintenance> {
  Map? maintenance;

  @override
  void initState() {
    maintenance = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(Translator.get("App Maintenance")!),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                emptyWidget(
                  context,
                  maintenance!['title'] == null
                      ? 'assets/images/maintenance.png'
                      : 'assets/images/logo.png',
                  maintenance!['title'] ?? 'Maintenance Mode',
                  maintenance!['message'] ??
                      'This app is currently under going maintenance and will be back online shortly, Thank you for your patience.',
                ),
              ],
            ),
          ),
          RaisedButton(
            child: Text(Translator.get("EXIT APP")!),
            textColor: Colors.white,
            color: colorPrimary,
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
    );
  }
}
