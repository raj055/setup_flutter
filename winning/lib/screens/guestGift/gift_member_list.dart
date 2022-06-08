import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_paginator/flutter_paginator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';

class GiftMemberList extends StatefulWidget {
  @override
  _GiftMemberListState createState() => _GiftMemberListState();
}

class _GiftMemberListState extends State<GiftMemberList> {
  GlobalKey<PaginatorState> associateGlobalKey = GlobalKey();
  List<Map> selectedMemberList = [];
  bool isSelected = false;

  Map? giftLearning;

  @override
  void initState() {
    giftLearning = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get("Member Gift"),
      apiFuture: (int page) async {
        return Api.http.get("downline-guests?page=$page").then((response) {
          response.data['list']['data'].map((member) {
            member.putIfAbsent('isChecked', () => false);
          }).toList();

          return response;
        });
      },
      appBarAction: [
        if (selectedMemberList.length > 0)
          IconButton(
            onPressed: () {
              Get.toNamed('purchase-gift', arguments: {"members": selectedMemberList, "learning": giftLearning});
            },
            icon: Icon(
              Feather.check,
            ),
          ),
      ],
      listItemBuilder: _memberGiftBuilder,
    );
  }

  Widget _memberGiftBuilder(member, int index) {
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
              {"id": data['userId']},
            );
          } else {
            int index = selectedMemberList.indexWhere((m) => m["id"] == data['userId']);

            if (index == -1) {
              selectedMemberList.add(
                {
                  "id": data['userId'],
                },
              );
            }
          }
        });
      } else if (!data['isChecked']) {
        for (int i = 0; i < selectedMemberList.length; i++) {
          if (selectedMemberList[i]['id'] == data['userId']) {
            setState(() {
              selectedMemberList.removeAt(i);
            });
          }
        }
      }
    });
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
