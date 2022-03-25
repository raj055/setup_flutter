import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class Incomes extends StatefulWidget {
  @override
  _IncomesState createState() => _IncomesState();
}

class _IncomesState extends State<Incomes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 2.0, title: Text('Incomes')),
      body: SafeArea(
        child: DefaultTabController(
          length: 6,
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
                                  'Mobile Recharge Income',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  'DTH Recharge Income',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  'Gas Bill Income',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  'Electricity Bill Income',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  'Offline Store Income',
                                  style: TextStyle(fontSize: 18.0, fontFamily: fontBold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  'Online Store Income',
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
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                PaginatedList(
                  noDataTitle: 'Mobile Recharge Income',
                  apiFuture: (int page) async {
                    return Api.http.get("member/incomes/mobile-recharge-income?page=$page");
                  },
                  listItemBuilder: _mobileRechargeIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'DTH Recharge Income',
                  apiFuture: (int page) async {
                    return Api.http.get("member/incomes/dth-recharge-income?page=$page");
                  },
                  listItemBuilder: _dthRechargeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Gas Bill Income',
                  apiFuture: (int page) async {
                    return Api.http.get("member/incomes/gas-bill-income?page=$page");
                  },
                  listItemBuilder: _gasBillIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Electricity Bill Income',
                  apiFuture: (int page) async {
                    return Api.http.get("member/incomes/electricity-bill-income?page=$page");
                  },
                  listItemBuilder: _electricityBillIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Offline Store Income',
                  apiFuture: (int page) async {
                    return Api.http.get("member/incomes/offline-store-income?page=$page");
                  },
                  listItemBuilder: _offlineStoreIncomeBuilder,
                ),
                PaginatedList(
                  noDataTitle: 'Online Store Income',
                  apiFuture: (int page) async {
                    return Api.http.get("member/incomes/online-store-income?page=$page");
                  },
                  listItemBuilder: _onlineStoreIncomeBuilder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileRechargeIncomeBuilder(dynamic mobileRechargeIncome, int index) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CircleAvatar(
                          backgroundColor: colorPrimary.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            UniconsLine.rupee_sign,
                            color: colorPrimary,
                            size: textSizeXLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: w(4)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          text(
                            mobileRechargeIncome['createdAt'],
                            fontFamily: fontBold,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            mobileRechargeIncome['amount'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Admin Charge (₹)",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            mobileRechargeIncome['adminCharge'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Net Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            mobileRechargeIncome['total'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(
                        "Remark :",
                        fontFamily: fontBold,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: text(
                          mobileRechargeIncome['comment'],
                          textColor: textColorSecondary,
                          isLongText: true,
                        ),
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

  Widget _dthRechargeBuilder(dynamic dhtRechargeIncome, int index) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CircleAvatar(
                          backgroundColor: colorPrimary.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            UniconsLine.rupee_sign,
                            color: colorPrimary,
                            size: textSizeXLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: w(4)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          text(
                            dhtRechargeIncome['createdAt'],
                            fontFamily: fontBold,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            dhtRechargeIncome['amount'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Admin Charge (₹)",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            dhtRechargeIncome['adminCharge'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Net Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            dhtRechargeIncome['total'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(
                        "Remark :",
                        fontFamily: fontBold,
                      ),
                      SizedBox(height: 4),
                      text(
                        dhtRechargeIncome['comment'],
                        textColor: textColorSecondary,
                        isLongText: true,
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

  Widget _gasBillIncomeBuilder(dynamic gasBillIncome, int index) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CircleAvatar(
                          backgroundColor: colorPrimary.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            UniconsLine.rupee_sign,
                            color: colorPrimary,
                            size: textSizeXLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: w(4)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          text(
                            gasBillIncome['createdAt'],
                            fontFamily: fontBold,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            gasBillIncome['amount'],
                            textColor: textColorSecondary,
                            isLongText: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Admin Charge (₹)",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            gasBillIncome['adminCharge'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Net Amount (₹)",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            gasBillIncome['total'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(
                        "Remark :",
                        fontFamily: fontBold,
                      ),
                      SizedBox(height: 4),
                      Expanded(
                        child: text(
                          gasBillIncome['comment'],
                          textColor: textColorSecondary,
                        ),
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

  Widget _electricityBillIncomeBuilder(dynamic electricityBillIncome, int index) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CircleAvatar(
                          backgroundColor: colorPrimary.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            UniconsLine.rupee_sign,
                            color: colorPrimary,
                            size: textSizeXLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: w(4)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          text(
                            electricityBillIncome['createdAt'],
                            fontFamily: fontBold,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            electricityBillIncome['amount'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Admin Charge (₹)",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            electricityBillIncome['adminCharge'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              text(
                                "Net Amount (₹)",
                                fontFamily: fontBold,
                              ),
                              SizedBox(height: 4),
                              text(
                                electricityBillIncome['total'],
                                textColor: textColorSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(
                        "Remark :",
                        fontFamily: fontBold,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: text(
                          electricityBillIncome['comment'],
                          textColor: textColorSecondary,
                          isLongText: true,
                        ),
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

  Widget _offlineStoreIncomeBuilder(dynamic offlineStoreIncome, int index) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CircleAvatar(
                          backgroundColor: colorPrimary.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            UniconsLine.rupee_sign,
                            color: colorPrimary,
                            size: textSizeXLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: w(4)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          text(
                            offlineStoreIncome['createdAt'],
                            fontFamily: fontBold,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            offlineStoreIncome['amount'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Admin Charge (₹)",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            offlineStoreIncome['adminCharge'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              text(
                                "Net Amount (₹)",
                                fontFamily: fontBold,
                              ),
                              SizedBox(height: 4),
                              text(
                                offlineStoreIncome['total'],
                                textColor: textColorSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(
                        "Remark :",
                        fontFamily: fontBold,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: text(
                          offlineStoreIncome['comment'],
                          textColor: textColorSecondary,
                          isLongText: true,
                        ),
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

  Widget _onlineStoreIncomeBuilder(dynamic onlineStoreIncome, int index) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CircleAvatar(
                          backgroundColor: colorPrimary.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            UniconsLine.rupee_sign,
                            color: colorPrimary,
                            size: textSizeXLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: w(4)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          text(
                            onlineStoreIncome['createdAt'],
                            fontFamily: fontBold,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          text(
                            "Amount (₹)",
                            fontFamily: fontBold,
                          ),
                          SizedBox(height: 4),
                          text(
                            onlineStoreIncome['amount'],
                            textColor: textColorSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            child: text(
                              "Admin Charge (₹)",
                              fontFamily: fontBold,
                            ),
                          ),
                          SizedBox(height: 4),
                          text(
                            onlineStoreIncome['adminCharge'],
                            textColor: textColorSecondary,
                            fontSize: textSizeSMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              text(
                                "Net Amount (₹)",
                                fontFamily: fontBold,
                              ),
                              SizedBox(height: 4),
                              text(
                                onlineStoreIncome['total'],
                                textColor: textColorSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      text(
                        "Remark :",
                        fontFamily: fontBold,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: text(
                          onlineStoreIncome['comment'],
                          textColor: textColorSecondary,
                          isLongText: true,
                        ),
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
