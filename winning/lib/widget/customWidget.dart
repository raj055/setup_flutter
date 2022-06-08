import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/CountCtl.dart';
import '../services/auth.dart';
import '../services/storage.dart';
import '../services/translator.dart';
import '../widget/theme.dart';

void showDialogSingleButton(BuildContext context, Map data) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(right: 16.0),
            height: 150,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(75),
                    bottomLeft: Radius.circular(75),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Row(
              children: <Widget>[
                SizedBox(width: 20.0),
                CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      data['status'] ? Icons.done : Icons.close,
                      color: data['status'] ? Colors.green : Colors.red,
                      size: 60.0,
                    )),
                SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data['status'] ? "Success!" : "Oops!!!",
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 10.0),
                      Flexible(
                        child: Text(data['msg']),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          RaisedButton(
                            child: Text(Translator.get("Ok")!),
                            color: Colors.green,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildStackCart() {
  return Stack(
    children: [
      IconButton(
        onPressed: () {
          Get.toNamed('cart');
        },
        icon: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Icon(
            Feather.shopping_cart,
          ),
        ),
      ),
      Positioned(
        top: 10,
        right: 5,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: 0),
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: GetBuilder<CountCtl>(
              builder: (_) {
                return text(
                  ' ${CountCtl.to != null ? CountCtl.to.count : "0"}',
                  textColor: white,
                  fontSize: textSizeSmall,
                );
              },
            ),
          ),
        ),
      )
    ],
  );
}

Widget loadingWidget({required int? barCount, bool? isShowAvatar, bool? isCircleAvatar}) {
  return Container(
    child: CardListSkeleton(
      style: SkeletonStyle(
        // backgroundColor: Colors.grey,
        theme: SkeletonTheme.Light,
        isShowAvatar: isShowAvatar ?? false,
        isCircleAvatar: isCircleAvatar ?? false,
        isAnimation: true,
        barCount: barCount,
        // colors: [Colors.black, Colors.green],
      ),
    ),
  );
}

void logoutUser() async {
  SharedPreferences preferences;

  preferences = await SharedPreferences.getInstance();
  //  CountCtl.to.resetCount();
  Auth.logout();
  Storage.delete('cart');
  Get.offAllNamed('login');
}
