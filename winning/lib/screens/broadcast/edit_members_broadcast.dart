import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';

class EditBroadcastMembers extends StatefulWidget {
  @override
  _EditBroadcastMembersState createState() => _EditBroadcastMembersState();
}

class _EditBroadcastMembersState extends State<EditBroadcastMembers> {
  List<Map> selectedMembers = [];
  List<Map> selectedMembersId = [];
  List members = [];
  int count = 0;
  int? membersLength;

  var image;

  int? teamId;

  @override
  void initState() {
    teamId = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translator.get('Edit Members Broadcast')!,
        ),
        actions: <Widget>[
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          if (count > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    selectedMembersId.clear();
                    selectedMembers.map((Map selectedMember) {
                      selectedMembersId.add({'id': selectedMember['memberId']});
                    }).toList();

                    Api.http.post('update-broadcast-team', data: {
                      "broadcast_team_id": teamId,
                      "team_members": selectedMembersId,
                    }).then((response) {
                      if (response.data['status']) {
                        Get.back();
                      }
                    });
                  },
                  child: Text(
                    Translator.get("Add Members")!,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
        ],
      ),
      body: Column(
        children: <Widget>[
          if (count > 0)
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.transparent,
              ),
              height: 90.0,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Wrap(
                    spacing: 15.0,
                    runSpacing: 4.0,
                    children: selectedMembers.map((selectedContact) {
                      return Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 25,
                                child: Image.asset('assets/images/users.png'),
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      members.map((member) {
                                        if (selectedContact['memberId'] ==
                                            member['memberId']) {
                                          member["isSelected"] =
                                              !member["isSelected"];
                                        }
                                      }).toList();

                                      for (int i = 0;
                                          i < selectedMembers.length;
                                          i++) {
                                        if (selectedContact['memberId'] ==
                                            selectedMembers[i]['memberId']) {
                                          selectedMembers.removeAt(i);
                                        }
                                      }
                                      count = selectedMembers.length;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 10,
                                    child: Icon(
                                      Icons.clear,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            selectedContact['name'].toString().replaceRange(
                                selectedContact['name'].toString().length < 4
                                    ? 3
                                    : selectedContact['name']
                                                .toString()
                                                .length <
                                            6
                                        ? 4
                                        : 6,
                                selectedContact['name'].toString().length,
                                "..."),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          Divider(height: 2),
          Expanded(
            child: PaginatedList(
              apiFuture: (int page) async {
                return Api.http.post("members?page=$page",
                    data: {'broadcast_team_id': teamId});
              },
              listItemBuilder: _membersBuilder,
              listItemGetter: (item) {
                item['isSelected'] = false;
                members.add(item);
                Future.delayed(Duration.zero, () async {
                  setState(() {});
                });
                return item;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _membersBuilder(member, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          member['isSelected'] = !member['isSelected'];

          if (member['isSelected'] == false) {
            for (int i = 0; i < selectedMembers.length; i++) {
              if (member['memberId'] == selectedMembers[i]['memberId']) {
                selectedMembers.removeAt(i);
              }
            }

            count = selectedMembers.length;
          } else {
            selectedMembers.add(member);
          }
          count = selectedMembers.length;
        });
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                child: member['isSelected']
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                      )
                    : Image.asset('assets/images/users.png'),
              ),
              title: Text(
                member['name'] ?? '',
              ),
            ),
          )
        ],
      ),
    );
  }
}
