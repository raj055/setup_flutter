import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';

class AssociateNameAnalytics extends StatefulWidget {
  @override
  _AssociateNameAnalyticsState createState() => _AssociateNameAnalyticsState();
}

class _AssociateNameAnalyticsState extends State<AssociateNameAnalytics> {
  String? type;
  @override
  void initState() {
    type = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Auth.currentPackage() == 4
        ? PaginatedList(
            pageTitle: Translator.get('Members List'),
            apiFuture: (int page) async {
              return Api.http.get("downline-lists?page=$page");
            },
            listItemBuilder: _memberAnalyticsBuilder,
          )
        : PaginatedList(
            pageTitle: Translator.get('Members List'),
            apiFuture: (int page) async {
              return Api.http.get("associate-lists?page=$page");
            },
            listItemBuilder: _memberAnalyticsBuilder,
          );
  }

  Widget _memberAnalyticsBuilder(memberAnalytics, int index) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          if (type == "analytics") {
            Get.toNamed('analytics-details', arguments: {
              "id": memberAnalytics['userId'],
              "name": memberAnalytics['name']
            });
          } else if (type == "activity") {
            Get.toNamed('teamActivity-details', arguments: {
              "id": memberAnalytics['memberId'],
              "name": memberAnalytics['name']
            });
          }
        },
        child: Card(
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Feather.user,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(memberAnalytics['name'] ?? ""),
              ),
              _buildDivider(),
              ListTile(
                leading: memberAnalytics['mobile'] != ""
                    ? Icon(
                        Feather.smartphone,
                        color: Theme.of(context).primaryColor,
                      )
                    : Icon(
                        Feather.mail,
                        color: Theme.of(context).primaryColor,
                      ),
                title: memberAnalytics['mobile'] != ""
                    ? Text(memberAnalytics['mobile'])
                    : Text(memberAnalytics['email']),
              ),
              _buildDivider(),
              ListTile(
                leading: Icon(
                  Icons.landscape,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(memberAnalytics['code']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
}
