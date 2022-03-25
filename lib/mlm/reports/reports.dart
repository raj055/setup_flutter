import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../../../services/auth.dart';
import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: Get.arguments == "myDownLine"
              ? 1
              : Get.arguments == "sales"
                  ? 3
                  : 0,
          length: Auth.isVendor() == true ? 4 : 3,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: new Container(
                color: Colors.white,
                child: new SafeArea(
                  child: Container(
                    // color: app_background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: new TabBar(
                            labelPadding: EdgeInsets.only(left: 0, right: 0),
                            indicatorWeight: 4.0,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: colorPrimary,
                            labelColor: colorPrimary,
                            isScrollable: true,
                            unselectedLabelColor: textColorSecondary,
                            tabs: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                child: new Text(
                                  'My Direct',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  'My Patrons',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  'TDS Report',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              if (Auth.isVendor() == true)
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text(
                                    'Sales Report',
                                    style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
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
            ),
            body: TabBarView(
              children: <Widget>[
                PaginatedList(
                  noDataTitle: 'My Direct',
                  apiFuture: (int page) async {
                    return Api.http.get("member/reports/direct?page=$page");
                  },
                  listItemBuilder: _myDirectBuilder,
                  resetStateOnRefresh: true,
                ),
                PaginatedList(
                  noDataTitle: 'My Patrons',
                  apiFuture: (int page) async {
                    return Api.http.get("member/reports/downline?page=$page");
                  },
                  listItemBuilder: _myDownlineBuilder,
                  resetStateOnRefresh: true,
                ),
                FutureBuilder(
                  future: Api.http.get('member/reports/tds-report').then(
                        (response) => response.data,
                      ),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.data['list'].length == 0) {
                      return Center(
                        child: Container(
                          color: white,
                          constraints: BoxConstraints(maxWidth: 500.0),
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/no_result.png',
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fitWidth,
                              ),
                              Positioned(
                                bottom: 30,
                                left: 20,
                                right: 20,
                                child: Container(
                                  decoration: boxDecoration(
                                    radius: 10,
                                    showShadow: true,
                                    bgColor: Colors.grey[200],
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      text(
                                        'No Data Found in TDS Report',
                                        textColor: colorPrimaryDark,
                                        fontFamily: fontBold,
                                        fontSize: textSizeLargeMedium,
                                        maxLine: 2,
                                      ),
                                      SizedBox(height: 5),
                                      text(
                                        'There was no record based on the details you entered.',
                                        isCentered: true,
                                        isLongText: true,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                    List _tdsList = snapshot.data['list'];
                    return ListView.builder(
                      itemCount: _tdsList.length,
                      itemBuilder: (context, index) {
                        return _tdsReportBuilder(_tdsList[index], index);
                      },
                    );
                  },
                ),
                if (Auth.isVendor() == true)
                  PaginatedList(
                    noDataTitle: 'Sales Reports',
                    apiFuture: (int page) async {
                      return Api.http.get("member/reports/sales-report?page=$page");
                    },
                    listItemBuilder: _salesReportBuilder,
                    resetStateOnRefresh: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _myDirectBuilder(dynamic myDirect, int index) {
    return Container(
      width: w(80),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: white,
        radius: 10.0,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 7.5,
        vertical: 7.5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                UniconsLine.thumbs_up,
                                color: colorPrimary,
                                size: textSizeXLarge,
                              ),
                            ),
                            SizedBox(width: w(4)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                text(
                                  myDirect['name'],
                                  fontFamily: fontBold,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                text(
                                  myDirect['createdAt'],
                                  fontFamily: fontBold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: w(2)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: myDirect['status'] == 'Active'
                              ? Colors.green
                              : myDirect['status'] == 'Free'
                                  ? Colors.red
                                  : Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: text(
                          myDirect['status'],
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: textSizeSMedium,
                        ),
                      )
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "Member ID",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            myDirect['code'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Parent ID",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            myDirect['parentId'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myDownlineBuilder(dynamic mydownline, int index) {
    return Container(
      width: w(80),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: white,
        radius: 10.0,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 7.5,
        vertical: 7.5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                UniconsLine.thumbs_up,
                                color: colorPrimary,
                                size: textSizeXLarge,
                              ),
                            ),
                            SizedBox(width: w(4)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                text(
                                  mydownline['name'],
                                  fontFamily: fontBold,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                text(
                                  mydownline['createdAt'],
                                  fontFamily: fontBold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: w(2)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: mydownline['status'] == 'Active'
                              ? Colors.green
                              : mydownline['status'] == 'Free'
                                  ? Colors.red
                                  : Colors.black,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: text(
                          mydownline['status'],
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: textSizeSMedium,
                        ),
                      )
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "Member ID",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            mydownline['code'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Parent ID",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            mydownline['parentId'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tdsReportBuilder(dynamic tdsReport, int index) {
    return Container(
      width: w(80),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: white,
        radius: 10.0,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 7.5,
        vertical: 7.5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                UniconsLine.rupee_sign,
                                color: colorPrimary,
                                size: textSizeXLarge,
                              ),
                            ),
                            SizedBox(width: w(4)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                text(
                                  tdsReport['month'],
                                  fontFamily: fontBold,
                                ),
                                text(
                                  tdsReport['panCard'] != null ? tdsReport['panCard'] : "N / A ",
                                  textColor: textColorSecondary,
                                  fontSize: textSizeSMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: w(2)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: green,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: text(
                          tdsReport['tds'].toString(),
                          textColor: white,
                          textAllCaps: true,
                          fontFamily: fontSemibold,
                          fontSize: textSizeSMedium,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _salesReportBuilder(dynamic sales, int index) {
    return Container(
      width: w(80),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: white,
        radius: 10.0,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 7.5,
        vertical: 7.5,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                UniconsLine.thumbs_up,
                                color: colorPrimary,
                                size: textSizeXLarge,
                              ),
                            ),
                            SizedBox(width: w(4)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                text(
                                  sales['customerName'],
                                  fontFamily: fontBold,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                text(
                                  sales['date'],
                                  fontFamily: fontBold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "Member ID",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            sales['customerCode'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          text(
                            "Member MOBILE",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            sales['customerNumber'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            child: text(
                              "AMOUNT",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            "\₹ ${sales['amount']}",
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            child: text(
                              "COMPANY CHARGE",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            "\₹ ${sales['companyCharge']}",
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            "GST AMOUNT",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            "\₹ ${sales['gstAmt']}",
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          text(
                            "PAYABLE AMOUNT",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            "\₹ ${sales['payableAmt']}",
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
