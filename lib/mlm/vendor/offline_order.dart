import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nb_utils/nb_utils.dart' hide white;
import 'package:unicons/unicons.dart';

import '../../../../services/DownloadCtrl.dart';
import '../../../../utils/app_utils.dart';
import '../../services/api.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class OffLineOrders extends StatefulWidget {
  @override
  _OffLineOrdersState createState() => _OffLineOrdersState();
}

class _OffLineOrdersState extends State<OffLineOrders> {
  DownloadCtrl downloadCtrl = DownloadCtrl();

  var invoiceUrl;

  Future getId(id) {
    return Api.http.get("member/vendor-invoice/invoice/$id").then((response) async {
      if (response.data['status']) {
        setState(() {
          invoiceUrl = response.data['invoiceUrl'];
        });
        downloadCtrl.download(invoiceUrl, context);
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
      return response.data;
    });
  }

  @override
  void initState() {
    downloadCtrl.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: 'Offline Orders',
      isPullToRefresh: true,
      apiFuture: _fetchOrderListFromServer,
      listItemBuilder: _offLinOrderListBuilder,
      resetStateOnRefresh: true,
    );
  }

  Widget _offLinOrderListBuilder(dynamic item, int index) {
    return Card(
      child: Container(
        color: white,
        margin: EdgeInsets.only(bottom: 5),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(item['date'], fontSize: 14.0),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      getId(item['id']);
                    },
                    icon: Icon(
                      UniconsLine.download_alt,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              text(
                "Order no : ${item['orderNo']}",
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
              Divider(
                height: 3,
                color: colorPrimary_light.withOpacity(0.5),
                thickness: 1.2,
              ),
              Row(
                children: [
                  text(
                    'Bill Amount: ',
                    textColor: textColorSecondary,
                    fontSize: textSizeSMedium,
                  ),
                  10.width,
                  text(
                    '₹ ${item['amount']}',
                    textColor: green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _fetchOrderListFromServer(int page) async {
    var response = await Api.http.get('shopping/offline-store?page=$page');
    return response;
  }
}
