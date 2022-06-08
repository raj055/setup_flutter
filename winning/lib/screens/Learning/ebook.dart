import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';

import '../../services/CountCtl.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/storage.dart';
import '../../services/translator.dart';
import '../../widget/customWidget.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class EBookScreen extends StatefulWidget {
  @override
  _EBookScreenState createState() => _EBookScreenState();
}

class _EBookScreenState extends State<EBookScreen> {
  var progressString = "";
  bool downloading = false;
  var progressStringInvoice = "";

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> downloadFile(BuildContext context, String url) async {
    String _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('EBook'),
      apiFuture: (int page) async {
        return Api.http.get("${3}/learning?page=$page");
      },
      listItemBuilder: _learningEBookBuilder,
      appBarAction: <Widget>[
        IconButton(
          onPressed: () {
            Get.toNamed('learning-ebook-search');
          },
          icon: Icon(
            Feather.search,
          ),
        ),
        buildStackCart(),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('purchased-courses');
        },
        label: text(
          'Purchased'.toUpperCase(),
          textColor: white,
          fontFamily: fontSemibold,
        ),
        icon: Icon(
          Feather.eye,
          color: white,
          size: 16,
        ),
        backgroundColor: green,
      ),
    );
  }

  Widget _learningEBookBuilder(dynamic eBook, int index) {
    var width = MediaQuery.of(context).size.width;

    return eBook != null
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (eBook['status_id'] == 0) {
                Get.toNamed('learning-ebook-list',
                    arguments: {"eBookData": eBook['packageDescription'], "name": eBook['name']});
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: boxDecoration(radius: 10, showShadow: true),
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: eBook['image'],
                      width: width / 3,
                      height: width / 2.8,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 120.0,
                        height: 120.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      width: width - (width / 3) - 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          if (eBook['payment_status'] == true)
                            Row(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: new BorderRadius.only(
                                        bottomRight: const Radius.circular(16.0),
                                        topRight: const Radius.circular(16.0)),
                                  ),
                                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                                  margin: EdgeInsets.only(top: 20, bottom: 10),
                                  child: text(
                                    'Purchased',
                                    textColor: colorPrimaryDark,
                                    fontSize: textSizeSmall,
                                    textAllCaps: true,
                                    fontFamily: fontBold,
                                  ),
                                ),
                              ],
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                text(
                                  eBook['name'],
                                  maxLine: 2,
                                  textColor: colorPrimaryDark,
                                  fontFamily: fontSemibold,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    text(
                                      eBook['status_id'] == 0
                                          ? "Free"
                                          : eBook['price'] != null
                                              ? "₹ ${eBook['price'].toString()}"
                                              : "Free".toUpperCase(),
                                      textColor: red,
                                      fontFamily: fontSemibold,
                                      fontSize: textSizeLargeMedium,
                                    ),
                                  ],
                                ),
                                if (Auth.currentPackage() != 1 && eBook['gift_price'] != null)
                                  Row(
                                    children: [
                                      text(
                                        "Gift Price ₹ ${eBook['gift_price']}",
                                        textColor: Colors.blue,
                                        fontFamily: fontSemibold,
                                        fontSize: 15.0,
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (Auth.currentPackage() != 1 && eBook['gift_price'] != null)
                                      RaisedButton(
                                        child: Text(
                                          /*Translator.get('add cart').toUpperCase()*/ "Send Gift",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Get.toNamed('gift-member-list', arguments: eBook);
                                        },
                                        color: Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    SizedBox(width: 5.0),
                                    if (eBook['status'] == 'Paid' && eBook['payment_status'] == false)
                                      RaisedButton.icon(
                                        icon: Icon(
                                          Icons.shopping_cart,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          Translator.get('add cart')!.toUpperCase(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          FocusScope.of(context).requestFocus(FocusNode());

                                          Storage.get('cart').then((res) async {
                                            if (res != null) {
                                              List _cart = res;

                                              int _index = _cart.indexWhere((d) => d['id'] == eBook['id']);

                                              if (_index > -1) {
                                                GetBar(
                                                  duration: Duration(seconds: 5),
                                                  message: Translator.get("Already added in Cart list.")!,
                                                  backgroundColor: Colors.green,
                                                ).show();
                                              } else {
                                                _cart.add(eBook);
                                                CountCtl.to.increment();
                                                Storage.set('cart', _cart);

                                                GetBar(
                                                  duration: Duration(seconds: 5),
                                                  message: Translator.get("Successfully added in cart list.")!,
                                                  backgroundColor: Colors.green,
                                                ).show();
                                              }
                                            } else {
                                              Storage.set('cart', [eBook]);
                                              CountCtl.to.increment();
                                              GetBar(
                                                duration: Duration(seconds: 5),
                                                message: Translator.get("Successfully added in cart list.")!,
                                                backgroundColor: Colors.green,
                                              ).show();
                                            }
                                          });
                                        },
                                        color: Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                margin: EdgeInsets.all(0),
              ),
            ),
          )
        : Center();
  }
}
