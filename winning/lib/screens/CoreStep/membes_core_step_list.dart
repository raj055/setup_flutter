import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class MemberCoreStepList extends StatefulWidget {
  @override
  _MemberCoreStepListState createState() => _MemberCoreStepListState();
}

class _MemberCoreStepListState extends State<MemberCoreStepList> {
  final format = DateFormat("dd-MM-yyyy");

  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get("Member"),
      apiFuture: (int page) async {
        return Api.http.get("downline-lists?page=$page");
      },
      listItemBuilder: _memberBuilder,
    );
  }

  Widget _memberBuilder(member, int index) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Get.toNamed('member-core-step-details', arguments: member);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
            ),
            child: ListTile(
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
                            style: TextStyle(
                              color: colorPrimaryDark,
                              fontFamily: fontSemibold,
                              fontSize: textSizeLargeMedium,
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
                        member['mobile'] != ""
                            ? Icon(
                                Feather.smartphone,
                                size: 12,
                              )
                            : Icon(
                                Feather.mail,
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
        ),
      ],
    );
  }
}
