import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class CoreSteps extends StatefulWidget {
  @override
  _CoreStepsState createState() => _CoreStepsState();
}

class _CoreStepsState extends State<CoreSteps> {
  List coreStepListID = [];
  List? coreStepData = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get("10 Core Steps")!),
        actions: <Widget>[
          Auth.currentPackage() == 3 || Auth.currentPackage() == 4
              ? IconButton(
                  icon: Icon(Icons.description),
                  onPressed: () {
                    Get.toNamed('member-core-step-list');
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
      body: PaginatedList(
        apiFuture: (int page) async {
          return Api.http.get('core-steps?page=$page').then((res) {
            coreStepData = res.data['list']['data'];

            res.data['list']['data'].map((step) {
              step.putIfAbsent('isChecked', () => false);
              if (step['statusId'] == 1) {
                step['isChecked'] = true;
                coreStepListID.add({"id": step['id']});
              }
            }).toList();

            return res;
          });
        },
        listItemBuilder: coreStepBuilder,
      ),
      bottomNavigationBar: coreStepListID.length > 0
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: submitButton(context),
            )
          : SizedBox.shrink(),
    );
  }

  Widget coreStepBuilder(coreSteps, index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 80,
            child: text(
              coreSteps['name'],
              fontFamily: fontMedium,
              textColor: colorPrimaryDark,
              fontSize: textSizeLargeMedium,
            ),
          ),
          Expanded(
            flex: 15,
            child: Switch(
              // selected: coreSteps['isChecked'],
              value: coreSteps['isChecked'],
              activeColor: colorPrimary,
              onChanged: (bool? selected) {
                setState(() {
                  coreSteps['isChecked'] = !coreSteps['isChecked'];
                  selected = coreSteps['isChecked'];
                  if (selected!) {
                    setState(() {
                      if (coreStepListID.length == 0) {
                        coreStepListID.add(
                          {"id": coreSteps['id']},
                        );
                      } else {
                        int i = coreStepListID.indexWhere((m) => m["id"] == coreSteps['id']);

                        if (i == -1) {
                          coreStepListID.add(
                            {
                              "id": coreSteps['id'],
                            },
                          );
                        }
                      }
                    });
                  } else if (!coreSteps['isChecked']) {
                    for (int i = 0; i < coreStepListID.length; i++) {
                      if (coreStepListID[i]['id'] == coreSteps['id']) {
                        setState(() {
                          coreStepListID.removeAt(i);
                        });
                      }
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget submitButton(BuildContext context) {
    return FadeAnimation(
      0.3,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  Api.http.post('core-steps', data: {'coreSteps': coreStepListID}).then(
                    (response) {
                      GetBar(
                        backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                        duration: Duration(seconds: 5),
                        message: response.data['message'],
                      ).show();
                      Future.delayed(Duration(seconds: 2), () => Get.back());
                    },
                  ).catchError(
                    (error) {
                      if (error.response.statusCode == 422) {
                        GetBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                          message: error.response.data['errors'],
                        ).show();
                      } else if (error.response.statusCode == 401) {
                        GetBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                          message: error.response.data['errors'],
                        ).show();
                      }
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: colorPrimary,
                    ),
                    child: Center(
                      child: Text(
                        Translator.get("Submit")!.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
