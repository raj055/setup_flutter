import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicons/unicons.dart';

import '../../../../services/DownloadCtrl.dart';
import '../../../services/size_config.dart';
import '../../services/api.dart';
import '../../utils/app_utils.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class MyOrderDetail extends StatefulWidget {
  @override
  _MyOrderDetailState createState() => _MyOrderDetailState();
}

class _MyOrderDetailState extends State<MyOrderDetail> {
  late int id;
  Map? orderData;
  late Future orderFuture;

  DownloadCtrl downloadCtrl = DownloadCtrl();
  var invoiceUrl;
  String? invoiceId;

  @override
  void initState() {
    id = Get.arguments;
    orderFuture = orderDetails();
    downloadCtrl.init();
    getId();
    super.initState();
  }

  @override
  void dispose() {
    downloadCtrl.dispose();
    super.dispose();
  }

  Future getId() {
    return Api.http.get("shopping/order/order-invoice/$id").then((response) async {
      if (response.data['status']) {
        setState(() {
          invoiceUrl = response.data['url'];
        });
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
      return response.data;
    });
  }

  Future orderDetails() {
    return Api.http.get("shopping/order/show/$id").then((response) {
      setState(() {
        orderData = response.data['order'];
      });
      return response.data;
    });
  }

  int? currStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Detail'),
        actions: [
          if (invoiceUrl != null && orderData!['paymentStatus']['id'] == 4 && orderData!['deliveryStatus']['id'] == 2)
            IconButton(
              icon: Icon(
                UniconsLine.download_alt,
                color: Colors.black54,
              ),
              tooltip: 'Download Invoice',
              onPressed: () {
                downloadCtrl.download(invoiceUrl, context);
              },
            )
        ],
      ),
      body: FutureBuilder(
        future: orderFuture,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildOrdersList(context),
                Divider(
                  height: 1,
                  color: colorPrimary_light,
                ),
                Container(
                  decoration: boxDecoration(
                    radius: 0,
                    showShadow: false,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      if (orderData!['status']['id'] == 7)
                        TextButton(
                          onPressed: () {
                            getId();
                          },
                          child: Text(
                            'Invoice',
                            style: secondaryTextStyle(),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: colorPrimary_light,
                ),
                SizedBox(height: 8.0),
                _buildPayment(context)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return Container(
      decoration: boxDecoration(
        radius: 0,
        showShadow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (orderData!['orderNo'] != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: text('Order ID - ${orderData!['orderNo']}'),
            ),
          Divider(
            height: 1,
            color: colorPrimary_light,
          ),
          for (int i = 0; i < orderData!['products'].length; i++) productDetail(orderData!['products'][i]),
        ],
      ),
    );
  }

  Widget productDetail(Map product) {
    return Column(
      children: [
        Container(
          height: h(35),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: text(
                              product['name'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              fontFamily: fontRegular,
                              fontSize: textSizeLargeMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                text(
                                  '\₹ ${product['dp']}',
                                  textColor: colorPrimary,
                                  fontFamily: fontMedium,
                                  fontSize: 19.0,
                                  fontweight: FontWeight.w600,
                                ),
                                SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: text(
                                    '\₹ ${product['mrp']}',
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 13.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          text(
                            'Discount Price : \₹ ${product['dp']}',
                            fontSize: 13.0,
                            fontweight: FontWeight.w600,
                          ),
                          text(
                            'Taxable Amount : \₹ ${product['taxableAmt']}',
                            fontSize: 13.0,
                            fontweight: FontWeight.w600,
                          ),
                          text(
                            'GST Amount : \₹ ${product['gstAmt']}',
                            fontSize: 13.0,
                            fontweight: FontWeight.w600,
                          ),
                          Row(
                            children: <Widget>[
                              text(
                                'Quantity' + ' : ' + product['quantity'].toString(),
                              ),
                            ],
                          ),
                          text(
                            'Total : \₹ ${product['total']}',
                            fontSize: 13.0,
                            fontweight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        alignment: Alignment.topLeft,
                        child: MaterialButton(
                          color: colorPrimary,
                          onPressed: () {
                            Get.toNamed('/review-add', arguments: {
                              "editType": product['inReviewList'],
                              "product": product,
                            })!
                                .then((value) {
                              setState(() {
                                orderFuture = orderDetails();
                              });
                            });
                          },
                          child: text(
                            product['inReviewList'] ? 'Edit Review' : 'Add Review',
                            textColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (product['url'] != null)
                      PNetworkImage(
                        product['url'],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: colorPrimary_light,
        ),
      ],
    );
  }

  Widget _buildPayment(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: boxDecoration(
        radius: 0,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     text("MRP"),
          //     text("\₹ ${orderData!['mrp']}"),
          //   ],
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     text("Discount Price"),
          //     text("\₹ ${orderData!['dp']}"),
          //   ],
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     text("Taxable Amount"),
          //     text("\₹ ${orderData!['dp']}"),
          //   ],
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     text("GST"),
          //     text("\₹ ${orderData!['dp']}"),
          //   ],
          // ),
          // Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Total",
                textColor: red,
                fontSize: textSizeLargeMedium,
              ),
              text(
                "\₹ " + orderData!['total'],
                textColor: red,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
