import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../../widget/customWidget.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';
import '../../widget/theme.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Auth.user() ${Auth.user()}");
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        automaticallyImplyLeading: false,
        title: Text('Account'),
        actions: [
          IconButton(
            constraints: BoxConstraints(maxWidth: 35),
            onPressed: () {
              Get.toNamed('/search-page');
            },
            icon: Icon(UniconsLine.search),
          ),
          SizedBox(width: 10.0),
          buildMLMCart(context),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: white,
            padding: EdgeInsets.only(
              left: spacing_standard_new,
              top: spacing_standard_new,
              right: 12,
              bottom: spacing_standard_new,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: Auth.user() != null && Auth.user()!['profileImage'] != null
                      ? CachedNetworkImageProvider(Auth.user()!['profileImage'])
                      : CachedNetworkImageProvider(
                          "https://d2g3lqmw8kz6f3.cloudfront.net/40802131-209d-4adc-9c4f-410aa2de3ffc/images/user.png",
                        ),
                ),
                SizedBox(width: w(4)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      text(
                        Auth.user()!['name'],
                        fontSize: textSizeLargeMedium,
                        fontFamily: fontBold,
                        textColor: textColorPrimary,
                      ),
                      SizedBox(width: 10),
                      text(
                        Auth.user()!['code'],
                        fontSize: textSizeLargeMedium,
                        fontFamily: fontBold,
                        textColor: textColorPrimary,
                      ),
                      text(
                        Auth.user()!['email'] ?? "",
                        fontSize: textSizeMedium,
                        textColor: textColorSecondary,
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/profile-mlm')!.then((value) {
                      setState(() {});
                    });
                  },
                  child: Icon(
                    UniconsLine.edit,
                    color: textColorPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10, left: 16),
            child: text(
              'General',
              fontFamily: fontBold,
              textAllCaps: true,
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: boxDecoration(
              bgColor: white,
              showShadow: true,
              radius: 0,
            ),
            child: Column(
              children: <Widget>[
                option(UniconsLine.lock, 'Change Password', '/change-password'),
                option(UniconsLine.gift, 'Refer & Earn', '/dashboard'),
                option(UniconsLine.power, 'Log Out', 'logout'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget option(var icon, var heading, String page) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (page == 'address') {
            Get.toNamed('/addresses', arguments: "account");
          } else if (page == "logout") {
            await Auth.logout();
            Get.offAllNamed('/ecommerce');
          } else {
            Get.toNamed(page);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    icon,
                    color: textColorPrimary,
                  ),
                ),
                SizedBox(width: 16),
                text(
                  heading,
                  fontFamily: fontMedium,
                  fontSize: textSizeMedium,
                ),
              ],
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: textColorSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
