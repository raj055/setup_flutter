import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

import '../../../../services/DownloadCtrl.dart';
import '../../../../widget/network_image.dart';
import '../../../services/auth.dart';
import '../../../services/size_config.dart';
import '../../services/api.dart';
import '../../widget/BottomNavigationBar.dart';
import '../../widget/theme.dart';
import '../app_drawer.dart';
import '../genyology/mlm_genealogy.dart';
import '../wallet/wallet.dart';
import 'components/day_wise_downline.dart';
import 'components/last_7_days_earning_graph.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void dispose() {
    indexController.close();
    super.dispose();
  }

  PageController pageController = PageController(initialPage: 0);
  StreamController<int> indexController = StreamController<int>.broadcast();

  late double width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          indexController.add(index);
        },
        controller: pageController,
        children: [
          MainDashboard(),
          Wallet(),
          MLMGenealogy(),
        ],
      ),
      bottomNavigationBar: StreamBuilder<Object>(
        stream: indexController.stream,
        builder: (context, snapshot) {
          int? cIndex = snapshot.data as int?;
          return CurvedNavigationBar(
            currentIndex: cIndex,
            backgroundColor: app_background,
            color: white,
            initialIndex: 0,
            items: <Widget>[
              Icon(UniconsLine.home),
              Icon(UniconsLine.wallet),
              Icon(UniconsLine.code_branch),
            ],
            onTap: (int value) {
              indexController.add(value);
              pageController.jumpToPage(value);
            },
          );
        },
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late double width;
  late SharedPreferences preferences;

  late Future<Map> _future;

  bool themeSwitch = false;

  late Map mlmDashboard;

  Uint8List? _bytesImage;

  DownloadCtrl downloadCtrl = DownloadCtrl();

  Future<Map> getDashboard() {
    return Api.http.get("member/dashboard").then((response) {
      setState(() {
        mlmDashboard = response.data;
        Auth.setVendor(isVendor: mlmDashboard['member']['isVendor']);
        Auth.setMemberId(memberId: mlmDashboard['member']['MemberId']);
        _bytesImage = Base64Decoder().convert(mlmDashboard['member']['qrCodeImage']);
      });
      return response.data;
    });
  }

  Future scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', false, ScanMode.QR);
      if (barcodeScanRes != '-1') {
        Get.toNamed('/qr-view', arguments: barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  @override
  void initState() {
    _future = getDashboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SafeArea(
        child: AppDrawer(),
      ),
      appBar: AppBar(
        elevation: 2.0,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _future = getDashboard();
            });
          },
          child: Text('Dashboard'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(UniconsLine.map_pin_alt),
            onPressed: () {
              Get.toNamed('/near-me-store');
            },
          ),
          IconButton(
            icon: Icon(Icons.power_settings_new_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => logoutBox(context),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }
          Map dashboardDetail = snapshot.data;

          List bankDetail = snapshot.data['bankDetails'];

          return Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                height: width,
                color: colorPrimary,
                child: Container(
                  alignment: Alignment.center,
                  height: 100,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 50),
                          padding: EdgeInsets.only(top: 60),
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            color: app_background,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _memberInfo(context, dashboardDetail),
                              SizedBox(height: 8),
                              _qrCodeScan(context, dashboardDetail),
                              SizedBox(height: 5),
                              _memberAbout(context, dashboardDetail),
                              _blockArea(context, dashboardDetail),
                              SizedBox(height: 16),
                              _referralLink(context, dashboardDetail),
                              SizedBox(height: 16),
                              if (bankDetail.length > 0) _buildBankDetail(context, bankDetail),
                              SizedBox(height: 16),
                              _dayWiseEarning(),
                              SizedBox(height: 16),
                              _dayWiseDownLine(),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            dashboardDetail['member']['profileImageUrl'],
                          ),
                          radius: 50,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _memberAbout(BuildContext context, Map dashboardDetail) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Container(
        child: Column(
          children: <Widget>[
            ExpansionTile(
              title: text(
                "Member Info",
                fontFamily: fontSemibold,
                fontSize: textSizeLargeMedium,
              ),
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 5.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        rowHeading(
                          'Full Name : ',
                          dashboardDetail['member']['name'],
                        ),
                        SizedBox(height: 10.0),
                        rowHeading(
                          'Mobile : ',
                          dashboardDetail['member']['mobile'],
                        ),
                        SizedBox(height: 10.0),
                        rowHeading(
                          'Email : ',
                          dashboardDetail['member']['email'] != null ? dashboardDetail['member']['email'] : "--",
                        ),
                        SizedBox(height: 10.0),
                        rowHeading(
                          'Account Status : ',
                          dashboardDetail['member']['memberStatus'],
                        ),
                        SizedBox(height: 10.0),
                        rowHeading(
                          'KYC Status : ',
                          dashboardDetail['member']['kycStatus'],
                        ),
                        if (Auth.isVendor() == true) ...[
                          SizedBox(height: 10.0),
                          rowHeading(
                            'Shop Name : ',
                            dashboardDetail['member']['shopName'] != null ? dashboardDetail['member']['shopName'] : "--",
                          ),
                          SizedBox(height: 10.0),
                          rowHeading(
                            'Category Name : ',
                            dashboardDetail['member']['category'] != null ? dashboardDetail['member']['category'] : "--",
                          ),
                          SizedBox(height: 10.0),
                          rowHeading(
                            'Sub-Category Name : ',
                            dashboardDetail['member']['subCategory'] != null ? dashboardDetail['member']['subCategory'] : "--",
                          ),
                        ],
                        SizedBox(height: 10.0),
                        rowHeading(
                          'Registration Date : ',
                          dashboardDetail['member']['regDate'],
                        ),
                        SizedBox(height: 10.0),
                        rowHeading(
                          'Activation Date : ',
                          dashboardDetail['member']['actDate'] ?? "",
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberInfo(BuildContext context, Map dashboardDetail) {
    return Column(
      children: [
        text(
          dashboardDetail['member']['name'],
          textColor: textColorPrimary,
          fontFamily: fontMedium,
          fontSize: textSizeNormal,
        ),
        text(
          dashboardDetail['member']['code'],
          fontSize: textSizeLargeMedium,
        ),
      ],
    );
  }

  Widget _buildBankDetail(BuildContext context, List bank) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 16),
                child: text(
                  'Banking Partners',
                  fontSize: textSizeLargeMedium,
                  fontFamily: fontBold,
                  textColor: textColorPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: text('View All'),
                    onTap: () {
                      Get.toNamed('/banking-partner');
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        Container(
          height: h(40),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bank.length,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                width: w(80),
                decoration: boxDecoration(
                  showShadow: true,
                  bgColor: white,
                  radius: 10.0,
                ),
                margin: EdgeInsets.only(
                  left: index == 0 ? 15 : 7.5,
                  right: (bank.length) - 1 == index ? 15 : 7.5,
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
                                      Icon(
                                        Icons.domain,
                                        color: colorPrimary,
                                        size: textSizeXLarge,
                                      ),
                                      SizedBox(width: w(2)),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          text(
                                            bank[index]['name'],
                                            fontFamily: fontBold,
                                          ),
                                          text(bank[index]['branchName'], textColor: textColorSecondary, fontSize: textSizeSMedium),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  child: text(
                                    bank[index]['acType'],
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      text(
                                        "A/C No",
                                        fontFamily: fontBold,
                                      ),
                                      SizedBox(height: 4),
                                      text(
                                        bank[index]['acNumber'],
                                        textColor: textColorSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Align(
                                      child: text(
                                        "IFSC",
                                        fontFamily: fontBold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    text(
                                      bank[index]['ifsc'],
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
                                    text(
                                      "UPI Id",
                                      fontFamily: fontBold,
                                      isLongText: true,
                                    ),
                                    SizedBox(height: 4),
                                    text(
                                      bank[index]['upiId'] ?? "--",
                                      textColor: textColorSecondary,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Align(
                                      child: text(
                                        "QR Code",
                                        fontFamily: fontBold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    bank[index]['qrImage'] != ''
                                        ? PNetworkImage(
                                            bank[index]['qrImage'],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.contain,
                                          )
                                        : Image.asset(
                                            'assets/images/no_image.png',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.contain,
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
            },
          ),
        ),
      ],
    );
  }

  Widget _blockArea(BuildContext context, Map dashboardDetail) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/wallet');
                  },
                  child: _buildBlocks(
                    "Wallet Income",
                    Colors.indigo.withOpacity(1.0),
                    dashboardDetail['walletBalance'].toString(),
                    icon: UniconsLine.wallet,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _goToIncomeTab(argument: 'myDirects');
                  },
                  child: _buildBlocks(
                    "My Directs",
                    Colors.deepOrange.withOpacity(1.0),
                    dashboardDetail['myDirects'].toString(),
                    icon: UniconsLine.arrows_merge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _goToIncomeTab(argument: 'myDownLine');
                  },
                  child: _buildBlocks(
                    "Total Patrons",
                    Colors.green.withOpacity(1.0),
                    dashboardDetail['myDownLine'].toString(),
                    icon: UniconsLine.corner_right_down,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/wallet');
                  },
                  child: _buildBlocks(
                    "Total Earning",
                    Colors.pink.withOpacity(1.0),
                    dashboardDetail['totalEarning'].toString(),
                    icon: UniconsLine.rupee_sign,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/orders');
                  },
                  child: _buildBlocks(
                    "Total Orders",
                    Colors.indigoAccent.withOpacity(1.0),
                    dashboardDetail['totalOrders'].toString(),
                    icon: UniconsLine.shopping_cart,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/payout');
                  },
                  child: _buildBlocks(
                    "Total Payout",
                    Colors.cyan.withOpacity(1.0),
                    dashboardDetail['totalPayout'].toString(),
                    icon: UniconsLine.coins,
                  ),
                ),
              ),
            ],
          ),
          if (Auth.isVendor() == true) ...[
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed('/vendor-wallet-transaction');
                    },
                    child: _buildBlocks(
                      "Vendor Wallet",
                      Colors.indigoAccent.withOpacity(1.0),
                      dashboardDetail['vendorWallet'].toString(),
                      icon: UniconsLine.shopping_cart,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _goToIncomeTab(argument: 'sales');
                    },
                    child: _buildBlocks(
                      "Vendor Total Sale",
                      Colors.cyan.withOpacity(1.0),
                      dashboardDetail['vendorTotalSales'].toString(),
                      icon: UniconsLine.coins,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed('/vendor-payout');
                    },
                    child: _buildBlocks(
                      "Total Vendor Payout",
                      Colors.indigoAccent.withOpacity(1.0),
                      dashboardDetail['totalVendorPayout'].toString(),
                      icon: UniconsLine.coins,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBlocks(String label, Color color, dynamic count, {IconData? icon, bool isIcon = true}) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 25, horizontal: isIcon ? 10 : 50),
          alignment: Alignment.centerRight,
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              text(
                count.toString(),
                fontSize: textSizeNormal,
                fontFamily: fontBold,
                textColor: white,
              ),
              const SizedBox(height: 5.0),
              text(label, textColor: white, fontFamily: fontMedium, isLongText: true),
            ],
          ),
        )
      ],
    );
  }

  void logoutUser() async {
    await Auth.logout();

    Get.offAllNamed('/login-mlm');
  }

  Widget logoutBox(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            SizedBox(height: 24),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(shape: BoxShape.circle, color: green),
              child: Icon(
                Icons.done,
                color: white,
              ),
            ),
            SizedBox(height: 24),
            text(
              'Are you sure you want to logout ?',
              textColor: textColorPrimary,
              fontFamily: fontBold,
              fontSize: textSizeLargeMedium,
              isCentered: true,
              isLongText: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: text(
                    'No',
                    fontSize: textSizeLargeMedium,
                    fontFamily: fontBold,
                    textColor: green,
                  ),
                ),
                TextButton(
                  onPressed: () => logoutUser(),
                  child: text(
                    'Yes',
                    fontSize: textSizeLargeMedium,
                    fontFamily: fontBold,
                    textColor: red,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _goToIncomeTab({String? argument}) {
    Get.toNamed('/reports', arguments: argument)!.then((value) {
      setState(() {
        // _futureBuild();
      });
    });
  }

  Widget _referralLink(BuildContext context, Map dashboardDetail) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      decoration: boxDecoration(radius: 10, showShadow: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              readOnly: true,
              onChanged: (String value) {},
              cursorColor: Colors.deepOrange,
              decoration: InputDecoration(
                hintText: dashboardDetail['refLink'],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 13,
                ),
                suffixIcon: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      new ClipboardData(text: dashboardDetail['refLink']),
                    );
                    GetBar(
                      duration: Duration(seconds: 5),
                      message: 'Referral Link copied to clipboard',
                      backgroundColor: colorPrimary,
                    ).show();
                  },
                  icon: Icon(
                    Icons.content_copy,
                    size: 18,
                  ),
                  label: Text('COPY'),
                  style: ElevatedButton.styleFrom(
                    primary: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      side: BorderSide(
                        color: colorPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrCodeScan(BuildContext context, Map dashboardDetail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (dashboardDetail['member']['qrCodeImage'] != null && dashboardDetail['member']['qrCodeImage'] != "")
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: boxDecoration(radius: 10, showShadow: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      iconSize: 35,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  child: Image.memory(
                                    _bytesImage!,
                                    height: 300,
                                    width: 300,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: text(
                                        'Close',
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    if (dashboardDetail['qrCodeUrl'] != "")
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            downloadCtrl.download(dashboardDetail['qrCodeUrl'], context);
                                          },
                                          child: text(
                                            'Download',
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        UniconsLine.qrcode_scan,
                      ),
                    ),
                    text(
                      "View Qr Code",
                      fontSize: 17.0,
                      fontweight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: boxDecoration(radius: 10, showShadow: true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    iconSize: 35,
                    onPressed: () {
                      scanQR();
                    },
                    icon: Icon(
                      UniconsLine.qrcode_scan,
                    ),
                  ),
                  text(
                    "Scan Qr Code",
                    fontSize: 17.0,
                    fontweight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _dayWiseEarning() {
    return DayWiseEarningGraph(
      title: 'Last 7 Days Earning Graph',
      dayWiseEarning: mlmDashboard['dayWiseEarnings'],
    );
  }

  _dayWiseDownLine() {
    return DayWiseDownLineGraph(
      title: 'Last 7 Days Patron Members',
      dayWiseDownLine: mlmDashboard['dayWiseDownline'],
    );
  }
}
