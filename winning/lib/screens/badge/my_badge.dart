import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class MyBadge extends StatefulWidget {
  @override
  _MyBadgeState createState() => _MyBadgeState();
}

class _MyBadgeState extends State<MyBadge> {
  Translator? translator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Translator.get('My Badge')!)),
      body: SafeArea(
        child: FutureBuilder(
          future: Api.http.get('my-badge').then((response) => response.data),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data['data'].length == 0) {
              return Center(
                child: emptyWidget(
                  context,
                  'assets/images/no_result.png',
                  "${Translator.get('No Badge Found')}",
                  "${Translator.get('There was no record based on the details you entered.')}",
                ),
              );
            }
            List _myBadge = snapshot.data['data'];
            return ListView.builder(
              itemCount: _myBadge.length,
              itemBuilder: (context, index) {
                return Container(
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
                      _myBadge[index]['badge'],
                      fontFamily: fontSemibold,
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
