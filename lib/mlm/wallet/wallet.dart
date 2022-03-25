import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/api.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? type;

  @override
  void initState() {
    type = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Transactions'),
        automaticallyImplyLeading: type != null ? true : false,
      ),
      body: PaginatedList(
        apiFuture: (int page) async {
          return Api.http.get("member/wallet-transaction?page=$page");
        },
        listItemBuilder: _walletBuilder,
        resetStateOnRefresh: true,
        isPullToRefresh: true,
        listWithoutAppbar: true,
      ),
    );
  }

  Widget _walletBuilder(dynamic item, int index) {
    return Container(
      decoration: boxDecoration(radius: 10, showShadow: true),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: colorPrimary.withOpacity(0.2),
                    radius: 20,
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: colorPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    item['date'],
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item['type'] == "Debit" ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: text(
                  item['type'],
                  textColor: white,
                  textAllCaps: true,
                  fontFamily: fontSemibold,
                  fontSize: textSizeSMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  text(
                    "Total Amount",
                    fontFamily: fontSemibold,
                    fontSize: textSizeSMedium,
                  ),
                  Row(
                    children: [
                      text(
                        '₹ ${item['amount']}'.toString(),
                        textColor: item['type'] == "Debit" ? Colors.red : Colors.green,
                        fontFamily: fontBold,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  text(
                    "Net Amount",
                    fontFamily: fontSemibold,
                    fontSize: textSizeSMedium,
                  ),
                  Row(
                    children: [
                      text(
                        '₹ ${item['total']}'.toString(),
                        textColor: colorPrimary,
                        fontFamily: fontBold,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  text(
                    "Admin Charge",
                    fontFamily: fontSemibold,
                    fontSize: textSizeSMedium,
                  ),
                  text(
                    '₹ ${item['adminCharge']}'.toString(),
                    textColor: textColorSecondary,
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
          Divider(height: 25),
          Column(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Remark : ',
                      style: TextStyle(
                        fontSize: textSizeSMedium,
                        color: colorPrimary,
                        fontFamily: fontSemibold,
                      ),
                    ),
                    TextSpan(
                      text: item['remark'],
                      style: TextStyle(
                        fontSize: textSizeSMedium,
                        color: textColorSecondary,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
