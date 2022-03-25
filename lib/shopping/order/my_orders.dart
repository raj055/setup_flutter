import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../widget/customWidget.dart';
import '../../services/api.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  int? totalItems;
  String? orderType;

  @override
  void initState() {
    orderType = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orderType == null
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Orders'.toUpperCase(),
              ),
              actions: [
                IconButton(
                  constraints: BoxConstraints(maxWidth: 35),
                  onPressed: () {},
                  icon: Icon(UniconsLine.search),
                ),
                SizedBox(width: 10.0),
                buildMLMCart(context),
              ],
            )
          : null,
      body: PaginatedList(
        pageTitle: 'Orders',
        resetStateOnRefresh: true,
        isPullToRefresh: true,
        apiFuture: _fetchOrderListFromServer,
        listItemBuilder: _orderListBuilder,
        listWithoutAppbar: orderType == null ? true : false,
      ),
    );
  }

  Widget _orderListBuilder(dynamic item, int index) {
    return InkWell(
      onTap: () {
        Get.toNamed('/my-order-detail', arguments: item['id']);
      },
      child: Card(
        child: Container(
          color: white,
          margin: EdgeInsets.only(bottom: 5),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  item['orderNo'],
                  fontFamily: fontBold,
                  isLongText: true,
                ),
                10.height,
                text(
                  "Invoice : ${item['invoiceNo']}",
                  fontFamily: fontBold,
                  isLongText: true,
                ),
                10.height,
                text(item['date'], fontSize: 14.0),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        text('Delivery Status', fontSize: 14.0),
                        8.height,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: item['deliveryStatus']['id'] == 4
                                ? Colors.blueGrey
                                : item['deliveryStatus']['id'] == 2
                                    ? Colors.blue
                                    : item['deliveryStatus']['id'] == 3
                                        ? Colors.green
                                        : Colors.orange,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: text(
                            item['deliveryStatus']['name'],
                            textColor: white,
                            textAllCaps: true,
                            fontFamily: fontSemibold,
                            fontSize: textSizeSMedium,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        text('Payment Type', fontSize: 14.0),
                        8.height,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: item['paymentType']['id'] == 1 ? Colors.cyan : Colors.green,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: text(
                            item['paymentType']['name'],
                            textColor: white,
                            textAllCaps: true,
                            fontFamily: fontSemibold,
                            fontSize: textSizeSMedium,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        text('Payment Status', fontSize: 14.0),
                        8.height,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: item['paymentStatus']['id'] == 1 || item['paymentStatus']['id'] == 2
                                ? Colors.orange
                                : item['paymentStatus']['id'] == 3
                                    ? Colors.blueGrey
                                    : item['paymentStatus']['id'] == 5
                                        ? Colors.red
                                        : item['paymentStatus']['id'] == 6
                                            ? Colors.blue
                                            : Colors.green,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: text(
                            item['paymentStatus']['name'],
                            textColor: white,
                            textAllCaps: true,
                            fontFamily: fontSemibold,
                            fontSize: textSizeSMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                10.height,
                Divider(
                  height: 3,
                  color: colorPrimary_light.withOpacity(0.5),
                  thickness: 1.2,
                ),
                Row(
                  children: [
                    text(
                      'Total Items : ',
                      textColor: textColorSecondary,
                      fontSize: textSizeSMedium,
                    ),
                    10.width,
                    text(
                      '${item['totalItems']}',
                      textColor: green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    text(
                      'Total Quantity : ',
                      textColor: textColorSecondary,
                      fontSize: textSizeSMedium,
                    ),
                    10.width,
                    text(
                      '${item['totalQuantity']}',
                      textColor: green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    text(
                      'Total MRP : ',
                      textColor: textColorSecondary,
                      fontSize: textSizeSMedium,
                    ),
                    10.width,
                    text(
                      '₹ ${item['totalMrp']}',
                      textColor: green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    text(
                      'Total Discount Price : ',
                      textColor: textColorSecondary,
                      fontSize: textSizeSMedium,
                    ),
                    10.width,
                    text(
                      '₹ ${item['totalDiscountedPrice']}',
                      textColor: green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    text(
                      'Total Taxable Amount : ',
                      textColor: textColorSecondary,
                      fontSize: textSizeSMedium,
                    ),
                    10.width,
                    text(
                      '₹ ${item['taxableAmt']}',
                      textColor: green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    text(
                      'Total GST : ',
                      textColor: textColorSecondary,
                      fontSize: textSizeSMedium,
                    ),
                    10.width,
                    text(
                      '₹ ${item['totalGst']}',
                      textColor: green,
                    ),
                  ],
                ),
                Row(
                  children: [
                    text(
                      'Total Amount : ',
                      textColor: textColorSecondary,
                      fontSize: textSizeSMedium,
                    ),
                    10.width,
                    text(
                      '₹ ${item['total']}',
                      textColor: green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _fetchOrderListFromServer(int page) async {
    var response = await Api.http.get('shopping/order?page=$page');
    return response;
  }
}
