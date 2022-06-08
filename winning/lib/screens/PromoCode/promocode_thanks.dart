import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class PromoCodeThanks extends StatefulWidget {
  @override
  _PromoCodeThanksState createState() => _PromoCodeThanksState();
}

class _PromoCodeThanksState extends State<PromoCodeThanks> {
  late String copyLink;
  late Future thanksFuture;
  late Map orderData;

  @override
  void initState() {
    orderData = Get.arguments;
    thanksFuture = _futureBuild();
    super.initState();
  }

  Map? thanksPage;

  Future _futureBuild() {
    return Api.http.post('thank-you', data: {"order_no": orderData['orderID']}).then(
      (res) async {
        if (res.data['status']) {
          setState(() {
            thanksPage = res.data['list'];
          });
        }
        return res.data;
      },
    );
  }

  Future<bool> _onWillPop() {
    if (orderData['expire'] == null) {
      Get.offAllNamed("home");
    } else {
      Get.offNamed('promo-code-list');
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0XFFF5F5F5),
        body: FutureBuilder(
          future: thanksFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center();
            }
            return Column(
              children: [
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: thanksPage!['statusId'] == 1 ? green : red,
                    ),
                    Center(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 90,
                            margin: EdgeInsets.only(top: 60),
                            child: CircleAvatar(
                              backgroundColor: thanksPage!['statusId'] == 1 ? green : red,
                              radius: 50,
                              child: Icon(
                                thanksPage!['statusId'] == 1 ? Feather.check_circle : Feather.x,
                                size: 70.0,
                                color: white,
                              ),
                              //child: PNetworkImage(rocket),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: text(
                              thanksPage!['status'],
                              textColor: white,
                              fontSize: textSizeLargeMedium,
                              fontFamily: fontSemibold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (thanksPage!['promoCodes'] != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: thanksPage!['promoCodes'].length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              decoration: boxDecoration(
                                showShadow: false,
                                radius: 10.0,
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: 7.5,
                                vertical: 7.5,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              text(
                                                thanksPage!['date'],
                                                textColor: colorPrimaryDark,
                                              ),
                                            ],
                                          ),
                                          Divider(height: 10),
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
                                                        Feather.slack,
                                                        color: colorPrimary,
                                                        size: textSizeXLarge,
                                                      ),
                                                    ),
                                                    SizedBox(width: w(4)),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Row(
                                                          children: [
                                                            if (thanksPage!['promoCodes'][index]['fromPackage'] != null)
                                                              text(
                                                                thanksPage!['promoCodes'][index]['fromPackage'] + " - ",
                                                                fontFamily: fontSemibold,
                                                                textColor: colorPrimary,
                                                              ),
                                                            text(
                                                              thanksPage!['promoCodes'][index]['toPackage'],
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
                                                                      thanksPage!['promoCodes'][index]['code'],
                                                                      textColor: red,
                                                                      fontFamily: fontSemibold,
                                                                    ),
                                                                    SizedBox(width: 5),
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        copyLink =
                                                                            thanksPage!['promoCodes'][index]['code'];
                                                                        Clipboard.setData(
                                                                          ClipboardData(text: copyLink),
                                                                        );
                                                                        GetBar(
                                                                          backgroundColor: Colors.green,
                                                                          duration: Duration(seconds: 2),
                                                                          message:
                                                                              Translator.get('Activation code copied')!,
                                                                        ).show();
                                                                      },
                                                                      child: Icon(
                                                                        Feather.copy,
                                                                        size: 16,
                                                                        color: colorPrimaryDark,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          },
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
                                                  thanksPage!['promoCodes'][index]['promoCodeType'].toUpperCase(),
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
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
