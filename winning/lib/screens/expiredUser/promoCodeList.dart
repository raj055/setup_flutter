import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/customWidget.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class PromoCodeList extends StatefulWidget {
  @override
  _PromoCodeListState createState() => _PromoCodeListState();
}

class _PromoCodeListState extends State<PromoCodeList> {
  Translator? translator;
  late var width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('Activation Codes')!),
        actions: <Widget>[
          GestureDetector(
            child: Row(children: [
              Icon(
                Feather.log_out,
                size: 16,
              ),
              SizedBox(width: 10),
              // text(Translator.get('logout')),
            ]),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  title: text(
                    Translator.get('Are you sure you want to logout?'),
                    fontFamily: fontSemibold,
                    isLongText: true,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: text(Translator.get('No')!.toUpperCase(), fontFamily: fontBold),
                    ),
                    TextButton(
                      onPressed: () => logoutUser(),
                      child: text(Translator.get('Yes')!.toUpperCase(), fontFamily: fontBold),
                    ),
                  ],
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(left: 16, bottom: 16, right: 16),
            decoration: boxDecoration(radius: 10, showShadow: true, bgColor: white),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFACB5FD)),
                        width: width / 6.5,
                        height: width / 6.5,
                        padding: EdgeInsets.all(10),
                        child: Image.asset('assets/images/code.png'),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            'You account has expired!',
                            textColor: red,
                            fontSize: textSizeMedium,
                            fontFamily: fontMedium,
                          ),
                          text(
                            'Renew quickly to keep using our services.',
                            isLongText: true,
                            fontSize: textSizeMedium,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        textContent: 'Buy',
                        onPressed: () {
                          Get.toNamed('purchase_promocode', arguments: 'expiry');
                        },
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: CustomButton(
                        textContent: 'Upgrade',
                        onPressed: () {
                          Get.toNamed('renew-package');
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Activation Code List',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Expanded(
            child: PaginatedList(
              apiFuture: (int page) async {
                return Api.httpWithoutLoader.get("promo-codes?page=$page");
              },
              showLoader: true,
              listItemBuilder: _promoCodeBuilder,
              loadingWidgetBuilder: _buildLoadingWidget,
              emptyListWidgetBuilder: Center(
                child: Center(
                  child: Text(
                    'No activation code found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return loadingWidget(barCount: 2);
  }

  Widget _promoCodeBuilder(dynamic promoCode, int index) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FadeAnimation(
            0.9,
            Container(
              decoration: boxDecoration(
                radius: 10,
                showShadow: true,
              ),
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        text(
                          promoCode["date"],
                          fontSize: textSizeSMedium,
                          textColor: textColorSecondary,
                          fontFamily: fontSemibold,
                        ),
                        Row(
                          children: <Widget>[
                            if (promoCode['promocodeType'] == "Upgrade")
                              text(
                                promoCode["promocodeType"],
                                fontSize: textSizeSMedium,
                                textColor: textColorSecondary,
                                fontFamily: fontSemibold,
                              ),
                            SizedBox(width: 15.0),
                            if (promoCode['status'] == 'Un-Used') ...[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                  child: text(
                                    Translator.get('Unused')!.toUpperCase(),
                                    textColor: white,
                                    fontSize: textSizeSmall,
                                    fontFamily: fontSemibold,
                                  ),
                                ),
                                color: Colors.green,
                              ),
                            ],
                            if (promoCode['status'] == 'Used') ...[
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: text(
                                    Translator.get('Used')!.toUpperCase(),
                                    textColor: white,
                                    fontSize: textSizeSmall,
                                    fontFamily: fontSemibold,
                                  ),
                                ),
                                color: Colors.red,
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            text(
                              promoCode['promocodeType'] == "Normal"
                                  ? promoCode["type"] ?? ""
                                  : promoCode["fromPackageType"],
                              fontFamily: fontSemibold,
                              textColor: colorPrimary,
                            ),
                            if (promoCode['promocodeType'] == "Upgrade")
                              text(
                                " - " + promoCode["type"],
                                fontFamily: fontSemibold,
                                textColor: colorPrimary,
                              ),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    text(
                                      promoCode["code"],
                                      textColor: blue,
                                      fontFamily: fontSemibold,
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              text("OwnedBy : "),
                              text(promoCode["ownedBy"]),
                            ],
                          ),
                          if (promoCode['status'] == 'Un-Used')
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('renew-package', arguments: promoCode["code"]);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: red,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: text(
                                  'Upgrade',
                                  textColor: white,
                                  textAllCaps: true,
                                  fontFamily: fontSemibold,
                                  fontSize: textSizeSMedium,
                                ),
                              ),
                              behavior: HitTestBehavior.opaque,
                            )
                        ],
                      ),
                    ),
                    if (promoCode['status'] == 'Used') ...[
                      SizedBox(height: 10),
                      Column(
                        children: <Widget>[
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        "UsedBy: ",
                                        style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        promoCode["usedBy"],
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Column(
                                children: <Widget>[
                                  Text(
                                    promoCode["usedAt"],
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
