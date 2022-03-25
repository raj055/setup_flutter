import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../widget/paginated_list.dart';
import 'jj../../../services/CountCtl.dart';
import 'jj../../../services/auth.dart';
import 'jj../../../utils/app_utils.dart';
import 'jj../../../widget/theme.dart';

void showDialogSingleButton(BuildContext context, Map data, {GlobalKey<PaginatedListState>? customCode}) {
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
                bottomRight: Radius.circular(10),
              ),
            ),
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
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data['status'] ? "Success!" : "Oops!!!",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(height: 10.0),
                      Flexible(
                        child: Text(data['msg']),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          MaterialButton(
                            child: Text("Ok"),
                            color: Colors.green,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                              if (customCode != null) {
                                customCode.currentState!.refresh();
                              }
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

Widget buildWishList(context, {Function? funAfterBack}) {
  return IconButton(
    constraints: BoxConstraints(maxWidth: 35),
    onPressed: () {
      Auth.check()!
          ? AppUtils.redirect('/wishlist', callWhileBack: funAfterBack)
          : AppUtils.redirect(
              'login-mlm',
              pageToRedirectAfterLogin: '/wishlist',
              callWhileBack: funAfterBack,
            );
    },
    icon: Icon(UniconsLine.heart),
  );
}

Widget buildNotification(context, {Function? funAfterBack}) {
  return IconButton(
    constraints: BoxConstraints(maxWidth: 35),
    onPressed: () {
      Auth.check()!
          ? AppUtils.redirect('/notification', callWhileBack: funAfterBack)
          : AppUtils.redirect(
              'login-mlm',
              pageToRedirectAfterLogin: '/notification',
              callWhileBack: funAfterBack,
            );
    },
    icon: Icon(UniconsLine.bell),
  );
}

Widget buildMLMCart(context, {Function? funAfterBack, bool isHomePage = false}) {
  return InkWell(
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(right: spacing_middle),
          padding: EdgeInsets.all(spacing_standard),
          child: Icon(
            UniconsLine.shopping_cart_alt,
          ),
        ),
        Positioned(
          top: isHomePage ? -8 : 0,
          right: 10,
          child: Container(
            margin: EdgeInsets.only(top: spacing_control),
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorPrimary,
            ),
            child: GetBuilder<MLMCountCtl>(
              builder: (_) {
                return text(
                  _.countMLM.toString(),
                  textColor: white,
                  fontSize: textSizeSmall,
                );
              },
            ),
          ),
        ),
      ],
    ),
    onTap: () {
      Auth.check()!
          ? AppUtils.redirect('/cart', callWhileBack: funAfterBack)
          : AppUtils.redirect(
              'login-mlm',
              pageToRedirectAfterLogin: '/cart',
              callWhileBack: funAfterBack,
            );
    },
    radius: spacing_standard_new,
  );
}

String validateMobile(String? value) {
  String pattern = r'[6789][0-9]{9}$';
  RegExp regExp = new RegExp(pattern);
  if (value!.length == 0) {
    return "Mobile is Required";
  } else if (value.length != 10) {
    return "Mobile number must 10 digits";
  } else if (!regExp.hasMatch(value)) {
    return "Mobile Number invalid";
  }
  return '';
}

String validateWhatsApp(String? value) {
  String pattern = r'[6789][0-9]{9}$';
  RegExp regExp = new RegExp(pattern);
  if (value!.length == 0) {
    return "WhatsApp number is Required";
  } else if (value.length != 10) {
    return "WhatsApp number must 10 digits";
  } else if (!regExp.hasMatch(value)) {
    return "WhatsApp Number invalid";
  }
  return '';
}
