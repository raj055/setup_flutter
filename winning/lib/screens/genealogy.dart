import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api.dart';
import '../services/auth.dart';
import '../services/size_config.dart';
import '../services/translator.dart';

class Genealogy extends StatefulWidget {
  @override
  _GenealogyState createState() => _GenealogyState();
}

class _GenealogyState extends State<Genealogy> {
  int? _childCount;
  String? _code = '';
  String? _name = '';
  TextEditingController _codeController = TextEditingController();
  String searchCode = '';

  List memberCodeList = [Auth.user()!['code']];
  List memberNameList = [Auth.user()!['name']];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('Genealogy')!),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _code = _codeController.text;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(Translator.get('WT App Code')!),
                    content: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        BlacklistingTextInputFormatter(RegExp(r'[- ,.]')),
                      ],
                      autofocus: true,
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: Translator.get('WT App Code'),
                        hintText: Translator.get('Search by WT App Code...'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(Translator.get('Cancel')!),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(Translator.get('Search')!),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());

                          setState(() {
                            _code = _codeController.text;
                            searchCode = _codeController.text;
                          });
                          _codeController.clear();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: buildGenealogy(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map mainNode = snapshot.data!['tree'];
          List membersList = snapshot.data!['tree']['children'];
          _childCount = membersList.length;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 9.0,
              vertical: 5,
            ),
            child: Column(
              children: <Widget>[
                if (memberCodeList.length > 1)
                  Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              memberCodeList.removeLast();
                              memberNameList.removeLast();
                              if (memberCodeList.length > 0) {
                                _code = memberCodeList.last;
                                _name = memberNameList.last;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  _buildMemberIcon(mainNode, true),
                                  Text(Translator.get('Sponsor Count')! + ' : ' + _childCount.toString()),
                                ],
                              ),
                              if (_childCount != 0)
                                Container(
                                  height: 1.0,
                                  width: 40.0,
                                  color: Colors.black,
                                ),
                            ],
                          )
                        ],
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: membersList
                              .asMap()
                              .map(
                                (index, member) {
                                  double containerHeight = 170.0;

                                  return MapEntry(
                                    index,
                                    Container(
                                      height: containerHeight,
                                      child: Row(
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                child: VerticalDivider(
                                                  thickness: 1,
                                                  color: Colors.black,
                                                ),
                                                height: verticalDividerHeight(index, containerHeight, membersList),
                                                width: 1,
                                              ),
                                            ],
                                            mainAxisAlignment: verticalDividerAlignment(index, membersList),
                                          ),
                                          Container(
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.black,
                                            ),
                                            width: 30,
                                            height: 1,
                                          ),
                                          SizedBox(width: 10),
                                          _buildMemberIcon(member, false),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                              .values
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future buildGenealogy() {
    return Api.http
        .get('genealogy/${memberCodeList.length > 0 ? _code : searchCode.isNotEmpty ? _code : Auth.user()!['code']}')
        .then((res) => res.data);
  }

  MainAxisAlignment verticalDividerAlignment(int index, List members) {
    if (index == 0) {
      return MainAxisAlignment.end;
    } else if ((index + 1) == members.length) {
      return MainAxisAlignment.start;
    }

    return MainAxisAlignment.center;
  }

  double verticalDividerHeight(int index, double containerHeight, List members) {
    if (members.length == 1) {
      return 0;
    } else if (index == 0 || (index + 1) == members.length) {
      return containerHeight / 2;
    }

    return containerHeight;
  }

  Widget _buildMemberIcon(Map mainNode, bool isRoot) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: CircleAvatar(
              backgroundImage: (mainNode['image'] != ''
                  ? NetworkImage(mainNode['image'])
                  : AssetImage("assets/images/users.png")) as ImageProvider<Object>?,
              radius: 35,
            ),
            onTap: () {
              if (mainNode['code'] != '' && mainNode['package'] != null) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                        child: Container(
                          width: 260.0,
                          height: 250.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // dialog top
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                    color: Colors.grey,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          mainNode['code'].toString(),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        highlightColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(),
                                  child: Text(
                                    Translator.get('Name: ')! + mainNode['name'],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(),
                                  child: Text(
                                    Translator.get('Join Date')! + ' : ' + mainNode['joining_date'],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(),
                                  child: Text(
                                    Translator.get('Package Name')! + ' : ' + mainNode['package']['name'],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(),
                                  child: Text(
                                    Translator.get('Package')! + ' : ₹ ' + mainNode['package']['amount'],
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          SizedBox(height: 5),
          GestureDetector(
            child: Text(mainNode['code']),
            onTap: () {
              if (memberCodeList.length == 0) {
                memberCodeList.add(mainNode['code']);
                memberNameList.add(mainNode['name']);
                setState(() {
                  _code = mainNode['code'];
                  memberNameList.map((memberName) => _name = memberName).toList();
                });
              } else {
                int _index = memberCodeList.indexWhere((code) => code == mainNode['code']);
                if (_index == -1) {
                  memberCodeList.add(mainNode['code']);
                  memberNameList.add(mainNode['name']);
                  setState(() {
                    _code = mainNode['code'];
                    memberNameList.map((memberName) => _name = memberName).toList();
                  });
                }
              }

              // if (mainNode['code'] != '' && _childCount != 0) {
              //   setState(() {
              //     _code = mainNode['code'].toString();
              //   });
              // }
            },
          ),
          SizedBox(height: 5),
          Container(
            width: SizeConfig.width(33),
            child: GestureDetector(
              child: Text(
                mainNode['name'] ?? "",
                // test,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                if (mainNode['code'] != '') {
                  setState(() {
                    _code = mainNode['code'].toString();
                  });
                }
              },
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
