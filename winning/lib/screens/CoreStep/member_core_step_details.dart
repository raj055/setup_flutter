import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/theme.dart';

class MemberCoreStepDetails extends StatefulWidget {
  @override
  _MemberCoreStepDetailsState createState() => _MemberCoreStepDetailsState();
}

class _MemberCoreStepDetailsState extends State<MemberCoreStepDetails> {
  Map? memberDetails;
  Future? coreDetailsFuture;
  List? coreStepList = [];
  final format = DateFormat("yyyy-MM-dd");

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    memberDetails = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(memberDetails!['name'])),
      body: Container(
        child: Column(
          children: <Widget>[
            _buildTargetCalenderField(context),
            _buildFutureBuilder(),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureBuilder() {
    if (_dateController.text != "") {
      return FutureBuilder(
        future: Api.http.post('downline-core-steps', data: {
          "user_id": memberDetails!['userId'],
          "date": _dateController.text,
        }),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center();
          }
          Response? coreStep = snapshot.data;

          if (coreStep != null && coreStep.data.containsKey('list')) {
            coreStepList = coreStep.data['list'];
          }

          return coreStepList!.length > 0
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: coreStepList!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: boxDecoration(
                        radius: 3,
                        showShadow: true,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          text(
                            coreStepList![index]['core_step']['name'],
                            textColor: colorPrimaryDark,
                            fontSize: textSizeLargeMedium,
                          ),
                          text(
                            coreStepList![index]['core_step']['status'] == 1 ? 'Active' : "InActive",
                            textColor: green,
                            fontFamily: fontBold,
                          ),
                        ],
                      ),
                    );
                  },
                )
              : FadeAnimation(
                  1.2,
                  Container(
                    width: double.infinity,
                    decoration: boxDecoration(
                      radius: 10,
                      showShadow: true,
                    ),
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        text(
                          Translator.get('No Data Found'),
                          textColor: colorPrimaryDark,
                          fontFamily: fontBold,
                          fontSize: textSizeLargeMedium,
                          maxLine: 2,
                        ),
                      ],
                    ),
                  ),
                );
        },
      );
    } else {
      return Center();
    }
  }

  Widget _buildTargetCalenderField(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: boxDecoration(
            showShadow: true,
          ),
          child: DateTimeField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select Date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onChanged: (value) {
              setState(() {
                _dateController.text;
              });
            },
            format: format,
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                context: context,
                firstDate: DateTime(2021),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime.now(),
              ) as Future<DateTime>;
            } as Future<DateTime> Function(BuildContext, DateTime),
            controller: _dateController,
          ),
        ),
      ],
    );
  }
}
