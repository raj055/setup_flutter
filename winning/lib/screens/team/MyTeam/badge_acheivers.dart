import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../screens/team/MyTeam/badge_acheivers_list.dart';
import '../../../services/api.dart';
import '../../../services/translator.dart';
import '../../../widget/theme.dart';

class BadgeAchiever extends StatefulWidget {
  @override
  _BadgeAchieverState createState() => _BadgeAchieverState();
}

class _BadgeAchieverState extends State<BadgeAchiever> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('Badge')!),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: Api.http.get('badges').then((response) => response.data),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data['badges'].length == 0) {
              return Center(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Feather.award,
                          color: colorPrimary,
                          size: 50,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        Translator.get('No Badge Found')!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
            List _myBadge = snapshot.data['badges'];
            return ListView.builder(
              itemCount: _myBadge.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BadgeAchieverList(
                          badgeList: _myBadge[index]['id'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: boxDecoration(
                      radius: 10,
                      showShadow: true,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: SvgPicture.network(_myBadge[index]['icon']),
                        backgroundColor: Colors.white,
                      ),
                      title: text(
                        _myBadge[index]['name'],
                        fontFamily: fontSemibold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
