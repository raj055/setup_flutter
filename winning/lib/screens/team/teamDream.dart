import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_fonts/google_fonts.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class TeamDream extends StatefulWidget {
  @override
  _TeamDreamState createState() => _TeamDreamState();
}

class _TeamDreamState extends State<TeamDream> {
  @override
  Widget build(BuildContext context) {
    return Auth.currentPackage() == 4
        ? PaginatedList(
            pageTitle: Translator.get('Team Dream'),
            apiFuture: (int page) async {
              return Api.http.get("downline-lists?page=$page");
            },
            listItemBuilder: _memberDreamBuilder,
          )
        : PaginatedList(
            pageTitle: Translator.get('Team Dream'),
            apiFuture: (int page) async {
              return Api.http.get("associate-lists?page=$page");
            },
            listItemBuilder: _memberDreamBuilder,
          );
  }

  Widget _memberDreamBuilder(memberDream, int index) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Get.toNamed('teamDream-details', arguments: {"id": memberDream['id'], "name": memberDream['name']});
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
                          text: memberDream['name'],
                          style: TextStyle(
                            color: Colors.black54.withOpacity(0.5),
                            fontSize: 18.0,
                            fontFamily: fontSemibold,
                          ),
                        ),
                        TextSpan(
                          text: " (${memberDream['code']})",
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).primaryColor,
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
                        memberDream['mobile'] != "" ? Feather.smartphone : Feather.mail,
                        size: 12,
                      ),
                      SizedBox(width: 10),
                      Text(
                        memberDream['mobile'] != "" ? memberDream['mobile'] : memberDream['email'],
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
    );
  }
}
