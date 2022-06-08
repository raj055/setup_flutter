import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_fonts/google_fonts.dart';

import '../../../services/api.dart';
import '../../../services/auth.dart';
import '../../../services/translator.dart';
import '../../../widget/paginated_list.dart';

class EditTeam extends StatefulWidget {
  @override
  _EditTeamState createState() => _EditTeamState();
}

class _EditTeamState extends State<EditTeam> {
  GlobalKey<PaginatorState> associateGlobalKey = GlobalKey();
  final _editTeamFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  TextEditingController _teamNameController = TextEditingController();
  List<Map> selectedMemberList = [];
  bool isSelected = false;
  Map? editTeamDetails;

  @override
  void initState() {
    editTeamDetails = Get.arguments;
    _teamNameController.text = editTeamDetails!['name'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translator.get('Update Team')!,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Form(
                  key: _editTeamFormKey,
                  autovalidate: _autoValidation,
                  onChanged: () {},
                  child: TextFormField(
                    inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return Translator.get('Please Enter Team Name.');
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: Translator.get('Enter Team Name.'),
                      labelText: Translator.get("Team Name"),
                    ),
                    controller: _teamNameController,
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Auth.currentPackage() == 4
                    ? PaginatedList(
                        apiFuture: (int page) async {
                          return Api.http.get("downline-lists?page=$page").then((response) {
                            response.data['list']['data'].map((member) {
                              for (int i = 0; i < editTeamDetails!['teamMembers'].length; i++) {
                                member.putIfAbsent('isChecked', () {
                                  if (editTeamDetails!['teamMembers'][i]['memberId'] == member['memberId']) {
                                    selectedMemberList.add({
                                      "id": editTeamDetails!['teamMembers'][i]['memberId'],
                                    });
                                    return true;
                                  } else {
                                    return false;
                                  }
                                });
                              }
                            }).toList();
                            return response;
                          });
                        },
                        listItemBuilder: _updateMemberBuilder,
                      )
                    : PaginatedList(
                        apiFuture: (int page) async {
                          return Api.http.get("associate-lists?page=$page").then((response) {
                            response.data['list']['data'].map((member) {
                              for (int i = 0; i < editTeamDetails!['teamMembers'].length; i++) {
                                member.putIfAbsent('isChecked', () {
                                  if (editTeamDetails!['teamMembers'][i]['memberId'] == member['memberId']) {
                                    selectedMemberList.add({
                                      "id": editTeamDetails!['teamMembers'][i]['memberId'],
                                    });
                                    return true;
                                  } else {
                                    return false;
                                  }
                                });
                              }
                            }).toList();
                            return response;
                          });
                        },
                        listItemBuilder: _updateMemberBuilder,
                      ),
              ),
              SizedBox(
                height: 50.0,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _updateTeam();
                },
                child: Container(
                  height: 40.0,
                  width: 180.0,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      Translator.get('Update Team')!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _updateMemberBuilder(member, int index) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD1DCFF),
                blurRadius: 10.0,
                spreadRadius: 1.0,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          child: ListTile(
            selected: isSelected,
            onTap: () {
              _checkFunction(member, index);
            },
            trailing: _checkMembers(member, index),
            leading: CircleAvatar(
              child: Icon(
                Feather.user,
              ),
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: member['name'],
                          style: GoogleFonts.montserrat(
                            color: Colors.black87,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: " (${member['code']})",
                          style: GoogleFonts.montserrat(
                            color: Colors.black54,
                            fontSize: 18.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
            subtitle: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        member['mobile'] != "" ? Feather.smartphone : Feather.mail,
                        size: 12,
                      ),
                      SizedBox(width: 10),
                      Text(
                        member['mobile'] != "" ? member['mobile'] : member['email'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black45,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _checkFunction(data, int index) {
    setState(() {
      data['isChecked'] = !data['isChecked'];

      if (data['isChecked']) {
        setState(() {
          if (selectedMemberList.length == 0) {
            selectedMemberList.add(
              {"id": data['memberId']},
            );
          } else {
            int index = selectedMemberList.indexWhere((m) => m["id"] == data['memberId']);

            if (index == -1) {
              selectedMemberList.add(
                {
                  "id": data['memberId'],
                },
              );
            }
          }
        });
      } else if (!data['isChecked']) {
        for (int i = 0; i < selectedMemberList.length; i++) {
          if (selectedMemberList[i]['id'] == data['memberId']) {
            selectedMemberList.removeAt(i);
          }
        }
      }
    });
  }

  void _updateTeam() {
    setState(() {
      _autoValidation = true;
    });

    Map sendData = {
      'team_id': editTeamDetails!['id'],
      'name': _teamNameController.text,
      'team_members': selectedMemberList,
    };

    if (_editTeamFormKey.currentState!.validate())
      Api.http.post('update-team', data: sendData).then(
        (response) {
          if (response.data['status']) {
            Get.offAllNamed('home');
            Get.toNamed('my-team');
          }
          GetBar(
            backgroundColor: response.data['status'] ? Colors.green : Colors.red,
            duration: Duration(seconds: 5),
            message: response.data['message'],
          ).show();
        },
      ).catchError(
        (error) {
          if (error.response.statusCode == 422) {
            GetBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              message: Translator.get("Select at least one team member")!,
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
  }

  Widget _checkMembers(data, index) {
    return Checkbox(
      activeColor: Colors.blue,
      value: data['isChecked'],
      onChanged: (val) {
        _checkFunction(data, index);
      },
    );
  }
}
