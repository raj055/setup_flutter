import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RechargeThanks extends StatefulWidget {
  const RechargeThanks({Key? key}) : super(key: key);

  @override
  _RechargeThanksState createState() => _RechargeThanksState();
}

class _RechargeThanksState extends State<RechargeThanks> {
  Map? sendData;
  Map? paymentData;
  Map? paymentThanks;

  Response? paymentThanksResponse;
  Response? paymentConfirmResponse;

  @override
  void initState() {
    super.initState();
    // paymentConfirm();
  }

//   paymentConfirm() async {
//     sendData = {
//       "status": true,
//       "order_id": this.widget.data!.data['option']['order_id'],
//       "payment_id": this.widget.data!.paymentId,
//       "user_id": this.widget.data!.data['order']['user']['id'],
//       // "b2b_id": DotEnv().env['b2b_id'],
//       "token": this.widget.data!.data['order']['user']['token'],
//     };
//     print('object $sendData');
//     Api.http.post('recharge/payment', data: sendData).then((response) {
//       print(response);
//       paymentData = {
//         "order_id": this.widget.data!.data['option']['order_id'],
//         "user_id": this.widget.data!.data['order']['user']['id'],
//         "token": this.widget.data!.data['order']['user']['token'],
//         "bill_data": this.widget.data!.billDetail,
//       };
//
//       Api.http.post('recharge/thanks', data: paymentData).then((res) {
//         print('res $res');
//         this.setState(() {
//           paymentThanks = res.data;
//         });
//       });
//     });
//
// //    paymentConfirmResponse = await httpApi(context, 'recharge/payment', sendData);
// //
// //    paymentData = {
// //      "order_id": this.widget.data.data['option']['order_id'],
// //      "user_id": this.widget.data.data['order']['user']['id'],
// //      "b2b_id": DotEnv().env['b2b_id'],
// //      "token": this.widget.data.data['order']['user']['token'],
// //      "bill_data": this.widget.data.billDetail,
// //    };
// //
// //    paymentThanksResponse = await httpApi(context, 'recharge/thanks', paymentData);
//   }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        builder: (context, snapshot) {
          if (paymentThanks == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return WillPopScope(
              child: Scaffold(
                backgroundColor: Color(0xfff0f0f0),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: paymentThanks!['order']['status'] == 3
                      ? Colors.red
                      : paymentThanks!['order']['status'] == 1
                          ? Colors.green
                          : Colors.deepOrange,
                  elevation: 0,
                ),
                body: SafeArea(
                  child: ListView(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 300,
                            color: paymentThanks!['order']['status'] == 3
                                ? Colors.red
                                : paymentThanks!['order']['status'] == 1
                                    ? Colors.green
                                    : Colors.deepOrange,
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                  height: 90,
                                  margin: EdgeInsets.only(top: 60),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      paymentThanks!['order']['status'] == 3
                                          ? Icons.clear
                                          : paymentThanks!['order']['status'] == 1
                                              ? Icons.check_circle
                                              : Icons.error,
                                      size: 90.0,
                                      color: paymentThanks!['order']['status'] == 3
                                          ? Colors.red
                                          : paymentThanks!['order']['status'] == 1
                                              ? Colors.green
                                              : Colors.deepOrange,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.all(4),
                              ),
                              Text(
                                "Recharge " + paymentThanks!['orderStatus'],
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: EdgeInsets.all(4),
                              ),
                              Text(
                                "₹ " + paymentThanks!['order']['amount'].toString(),
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(10),
                                child: Card(
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    (paymentThanks!['order']['service_id'] == 3
                                                            ? 'Postpaid Recharge'
                                                            : paymentThanks!['order']['service_id'] == 4
                                                                ? 'DTH Recharge'
                                                                : paymentThanks!['order']['service_id'] == 5
                                                                    ? 'Electrity Bill Payment'
                                                                    : paymentThanks!['order']['service_id'] == 6
                                                                        ? 'Gas Bill Payment'
                                                                        : paymentThanks!['order']['service_id'] == 7
                                                                            ? 'Water Bill Payment'
                                                                            : 'Prepaid Recharge') +
                                                        " of " +
                                                        paymentThanks!['order']['operator']['name'],
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
//                                              "9033581259",
                                                    paymentThanks!['order']['account'],
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    "₹ " + paymentThanks!['order']['amount'].toString(),
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              if (paymentThanks!['order']['smartcard_id'] != null)
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Smartcard Discount",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Text(
                                                      "- ₹ " + paymentThanks!['order']['smartcard_discount'].toString(),
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
//                                        Row(
//                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                          children: <Widget>[
//                                            Text(
//                                              "Wallet Discount",
//                                              style: TextStyle(
//                                                fontWeight: FontWeight.w400,
//                                                fontSize: 18,
//                                              ),
//                                            ),
//                                            Text(
//                                              "₹ 10",
//                                              style: TextStyle(
//                                                color: Colors.redAccent,
//                                                fontWeight: FontWeight.w500,
//                                                fontSize: 20,
//                                              ),
//                                            ),
//                                          ],
//                                        ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Total",
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                  Text(
//                                              "₹ 350",
                                                    "₹ " + paymentThanks!['order']['cart_amount'].toString(),
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 22,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop:
                  null /*() {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (Route<dynamic> route) => false);
              return null;
            },*/
              );
        },
      ),
    );
  }
}
