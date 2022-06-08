import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class ThanksPage extends StatefulWidget {
  @override
  _ThanksPageState createState() => _ThanksPageState();
}

class _ThanksPageState extends State<ThanksPage> {
  late Future thanksFuture;
  late Map orderData;
  late Map thanksPage;

  Future _futureBuild() {
    return Api.http.post('thank-you', data: {"order_no": orderData['orderID']}).then(
      (res) async {
        return res.data;
      },
    );
  }

  @override
  void initState() {
    orderData = Get.arguments;
    thanksFuture = _futureBuild();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Translator.get('Thank you for purchase')!,
          ),
          leading: IconButton(
            onPressed: () {
              Get.offAllNamed('home');
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: FutureBuilder(
          future: thanksFuture,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center();
            }

            thanksPage = snapshot.data!['list'];

            return Column(
              children: <Widget>[
                Container(
                  width: double.maxFinite,
                  height: 50,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD1DCFF),
                        blurRadius: 10.0, // has the effect of softening the shadow
                        spreadRadius: 1.0, // has the effect of extending the shadow
                      ),
                    ],
                    color: thanksPage['statusId'] == 1 ? green : red,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      thanksPage['status'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Divider(height: 2.0),
                Expanded(
                  flex: 5,
                  child: ListView.builder(
                    itemCount: thanksPage['result'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFD1DCFF),
                              blurRadius: 10.0, // has the effect of softening the shadow
                              spreadRadius: 1.0, // has the effect of extending the shadow
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: PNetworkImage(
                                        thanksPage['result'][index]['image'],
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            thanksPage['result'][index]['name'],
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            thanksPage['result'][index]['price'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
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
