import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Response;
import 'package:searchable_dropdown/searchable_dropdown.dart';

import '../../../services/api.dart';
import '../../../services/auth.dart';
import '../../../services/translator.dart';
import '../../../widget/theme.dart';
import '../../guest_dashboard.dart';
import '../../home.dart';

class ProfessionalProfile extends StatefulWidget {
  @override
  _ProfessionalProfileState createState() => _ProfessionalProfileState();
}

class _ProfessionalProfileState extends State<ProfessionalProfile> {
  bool _autoValidation = false;
  Map<String, dynamic>? _errors = {};
  final _professionalProfileFormKey = GlobalKey<FormState>();
  List _defaultLevels = [
    {"name": "Yes", "value": '1'},
    {"name": "No", "value": '0'},
  ];
  Translator? translator;
  String? _levels;
  String? experienceType;
  List? _experienceType = [];
  List<Map> workCompanyList = [];
  Future? _professionalProfileApi;
  var professionalProfileData;
  TextEditingController _workExperienceController = TextEditingController();
  TextEditingController _currentIncomeController = TextEditingController();
  TextEditingController _howMuchTeamController = TextEditingController();
  TextEditingController _occupationController = TextEditingController();
  TextEditingController _vestigeIdController = TextEditingController();

  List? crownList = [];
  var crownVal;

  List? _crownType = [];

  @override
  void initState() {
    _professionalProfileApi = _futureBuild();
    _futureBuildCrownMembers();
    super.initState();
  }

  // @override
  // String toString() {
  //   return this.name;
  // }

  Future _futureBuildCrownMembers() {
    return Api.http.get('crowns').then(
      (res) {
        setState(() {
          crownList = res.data['list'];
          _professionalProfileApi!.then((value) {
            List crownListSelected =
                crownList!.where((element) => element['id'] == professionalProfileData['data']['crown_id']).toList();

            crownVal = crownListSelected[0];
          });
        });
        return res.data;
      },
    );
  }

  Future _futureBuild() {
    return Api.http.get('professional-profile').then(
      (res) {
        setState(() {
          professionalProfileData = res.data;
          _crownType = professionalProfileData['crowns'];
          // crownVal = professionalProfileData['data']['crown_id'] != null ? professionalProfileData['data']['crown_id'].toString() : null;
          crownVal = professionalProfileData['data']['crown'] != null ? professionalProfileData['data']['crown'] : null;
          // crownVal = "Crown 3";
          _experienceType = professionalProfileData['direct_selling_experiences'];
          _workExperienceController.text = res.data['data']['work_experience_count'].toString();

          if (res.data['data']['income'] != null) _currentIncomeController.text = res.data['data']['income'].toString();

          _levels = res.data['data']['direct_selling_experience'] != null
              ? res.data['data']['direct_selling_experience']
              : null;

          if (res.data['data']['occupation'] != null)
            _occupationController.text = res.data['data']['occupation'].toString();
          if (res.data['data']['vestige_id'] != null)
            _vestigeIdController.text = res.data['data']['vestige_id'].toString();

          if (professionalProfileData['data']['direct_selling_experience_count'] != 0)
            experienceType = professionalProfileData['data']['direct_selling_experience_count'] != null
                ? professionalProfileData['data']['direct_selling_experience_count'].toString()
                : null;
          if (res.data['data']['team_count'] != null)
            _howMuchTeamController.text = res.data['data']['team_count'].toString();
        });
        professionalProfileData = res.data;

        if (professionalProfileData['data']['last_worked_companies'].length > 0) {
          for (Map company in professionalProfileData['data']['last_worked_companies']) {
            workCompanyList.add(
              {
                "company_name": TextEditingController(text: company['value']),
              },
            );
          }
        } else {
          workCompanyList.add(
            {
              "company_name": TextEditingController(),
            },
          );
        }
        return res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: FutureBuilder(
          future: _professionalProfileApi,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Form(
                key: _professionalProfileFormKey,
                autovalidate: _autoValidation,
                onChanged: () {
                  setState(() {
                    _errors = {};
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      if (crownList!.length > 0) _crownMemberList(context),
                      SizedBox(height: 20),
                      TextFormField(
                        inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[0]|[ ,.-]'))],
                        keyboardType: TextInputType.number,
                        controller: _vestigeIdController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: Translator.get('Vestige ID'),
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[0]|[ ,.-]'))],
                        keyboardType: TextInputType.number,
                        controller: _workExperienceController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: Translator.get('Work experience (Years)'),
                        ),
                        maxLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '${Translator.get('The work experience field')}${Translator.get(' is required')}';
                          }
                          if (_errors != null && _errors!.containsKey('work_experience_count')) {
                            return _errors!['work_experience_count'][0];
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[0]|[ ,.-]'))],
                        keyboardType: TextInputType.number,
                        controller: _currentIncomeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: Translator.get('Current Individual Income (Yearly)'),
                        ),
                        maxLines: 1,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '${Translator.get('The income field ')}${Translator.get(' is required')}';
                          }
                          if (_errors != null && _errors!.containsKey('income')) {
                            return _errors!['income'][0];
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                        controller: _occupationController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: Translator.get('Occupation'),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '${Translator.get('The occupation field ')}${Translator.get(' is required')}';
                          }
                          if (_errors != null && _errors!.containsKey('occupation')) {
                            return _errors!['occupation'][0];
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _levels,
                        decoration: InputDecoration(
                          labelText: Translator.get('Direct Selling Experience'),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _levels = newValue;
                            if (_levels == '0') {
                              _howMuchTeamController.clear();
                              _add();
                            }
                          });
                        },
                        items: _defaultLevels.map<DropdownMenuItem<String>>(
                          (level) {
                            return DropdownMenuItem<String>(
                              child: Text(level['name']),
                              value: level['value'],
                            );
                          },
                        ).toList(),
                      ),
                      SizedBox(height: 20),
                      if (_levels == '1') ...[
                        if (professionalProfileData != null)
                          DropdownButtonFormField<String>(
                            isDense: true,
                            isExpanded: true,
                            validator: (String? value) {
                              if (value == null) {
                                return Translator.get('Select Direct Selling Experience Count');
                              }
                              if (_errors != null && _errors!.containsKey('direct_selling_experience_count')) {
                                return _errors!['direct_selling_experience_count'][0];
                              }
                              return null;
                            },
                            value: experienceType,
                            decoration: InputDecoration(
                              labelText: Translator.get('How many years of Direct selling experience ?'),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                experienceType = newValue;
                              });
                            },
                            items: professionalProfileData['direct_selling_experiences'].map<DropdownMenuItem<String>>(
                              (value) {
                                return DropdownMenuItem<String>(
                                  value: value['id'].toString(),
                                  child: Text(value['value']),
                                );
                              },
                            ).toList(),
                          ),
                        SizedBox(height: 20),
                        TextFormField(
                          inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                          keyboardType: TextInputType.number,
                          controller: _howMuchTeamController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: Translator.get('How much Team Created ?'),
                          ),
                          maxLines: 1,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '${Translator.get('Field ')}${Translator.get(' is required')}';
                            }
                            if (_errors != null && _errors!.containsKey('team_count')) {
                              return _errors!['team_count'][0];
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        _add(),
                      ],
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: Text(
                            Translator.get('save')!.toUpperCase(),
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () async {
                            setState(() {
                              _autoValidation = true;
                            });

                            List companies = [];
                            for (Map company in workCompanyList) {
                              if (company['company_name'].text.toString().isNotEmpty) {
                                companies.add(
                                  {"company_name": company['company_name'].text},
                                );
                              }
                            }

                            if (_professionalProfileFormKey.currentState!.validate()) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              Map sendData = {
                                'work_experience_count': _workExperienceController.text,
                                'income': _currentIncomeController.text,
                                'occupation': _occupationController.text,
                                'vestige_id': _vestigeIdController.text,
                                'direct_selling_experience': _levels,
                                "direct_selling_experience_count": _levels == '1' ? experienceType : null,
                                'team_count': _howMuchTeamController.text,
                                'companies': companies,
                                // if (crownVal != null) 'crown_id': crownVal['id'],
                                'crown_id': crownVal != null ? crownVal['id'] : null,
                              };

                              Api.http.post('professional-profile', data: sendData).then(
                                (response) async {
                                  if (response.data['status']) {
                                    if (response.data['profile']) {
                                      await Auth.setProfile(response.data['profile']);
                                      if (Auth.user()!['member']['package_id'] == 1) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => GuestDashboard(),
                                            ),
                                            (route) => false);
                                      } else {
                                        Navigator.pushAndRemoveUntil(
                                            context, MaterialPageRoute(builder: (context) => Home()), (route) => false);
                                      }
                                    }
                                  }
                                  GetBar(
                                    backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                                    duration: Duration(seconds: 3),
                                    message: response.data['message'],
                                  ).show();
                                },
                              ).catchError(
                                (error) {
                                  if (error.response.statusCode == 422) {
                                    setState(() {
                                      _errors = error.response.data['errors'];
                                    });
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _add({String? companyName}) {
    List<Widget> children = [];
    for (int i = 0; i < workCompanyList.length; i++) {
      children.add(
        Column(
          children: <Widget>[
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                    controller: workCompanyList[i]['company_name'],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: i == 0 ? 'Worked with which company ?' : "Company name  ${i + 1}",
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    if (i == 0)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: RaisedButton(
                          child: Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.white,
                          ),
                          color: Theme.of(context).primaryColor,
                          padding: EdgeInsets.all(15),
                          onPressed: () {
                            setState(() {
                              workCompanyList.add({
                                "company_name": TextEditingController(),
                              });
                            });
                          },
                        ),
                      ),
                  ],
                ),
                if (i != 0)
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      child: Icon(
                        Icons.delete,
                        size: 24,
                        color: Colors.white,
                      ),
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(15),
                      onPressed: () {
                        setState(() {
                          workCompanyList.removeAt(i);
                        });
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    return Column(
      children: children,
    );
  }

  Widget _crownMemberList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0XFF70757a),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SearchableDropdown.single(
        validator: (value) {
          if (_errors != null && _errors!.containsKey('crown_id')) {
            return _errors!['crown_id'][0];
          }
          return null;
        },
        iconEnabledColor: Colors.black,
        isExpanded: true,
        displayClearIcon: false,
        items: crownList!.map<DropdownMenuItem>(
          (selectedCrown) {
            return DropdownMenuItem(
              value: selectedCrown,
              child: text(
                selectedCrown['name'],
              ),
            );
          },
        ).toList(),
        value: crownVal,
        hint: Translator.get("Crown Members"),
        searchHint: Translator.get("Crown Members"),
        onChanged: ((newValue) {
          setState(() {
            crownVal = newValue;
            _errors = {};
          });
        }),
      ),
    );
  }
}
