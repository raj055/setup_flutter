import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';
import 'ProfileTab/personal_profile.dart';
import 'ProfileTab/professional_profile.dart';

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? leaderName;
  Future? _profileApi;
  Map? profileData;
  Translator? translator;

  String? validateCode(String value) {
    if (value.length != 8)
      return Translator.get('WT App Code must be of 8 digit');
    else
      return null;
  }

  @override
  void initState() {
    super.initState();
    _profileApi = _futureBuild();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future _futureBuild() {
    return Api.http.get('profile').then(
      (res) {
        profileData = res.data;
        return res.data;
      },
    );
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() {
    return !Navigator.canPop(context)
        ? showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  Translator.get('Are you sure?')!,
                ),
                content: Text(
                  Translator.get('Do you want to exit an App')!,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      Translator.get('No')!,
                    ),
                  ),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text(
                      Translator.get('Yes')!,
                    ),
                  ),
                ],
              ),
            ) as Future<bool>? ??
            false as Future<bool>
        : Future.delayed(Duration.zero, () => true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder(
        future: _profileApi,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(Translator.get('Update Profile')!),
              bottom: TabBar(
                controller: _tabController,
                labelColor: white,
                indicatorColor: colorPrimary,
                unselectedLabelColor: white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  _buildTab(
                    tab: Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: text(
                            Translator.get('Personal'),
                            textColor: white,
                            fontFamily: fontSemibold,
                          ),
                        ),
                      ),
                    ),
                  )!,
                  _buildTab(
                    tab: Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: text(
                            Translator.get('Professional'),
                            textColor: white,
                            fontFamily: fontSemibold,
                          ),
                        ),
                      ),
                    ),
                  )!,
                ],
              ),
            ),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                PersonalProfile(switchTabCallback: () {
                  _tabController!.animateTo(1);
                }),
                ProfessionalProfile(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget? _buildTab({Tab? tab}) {
    if (!Auth.profile()!) {
      return GestureDetector(
        onTap: () => {},
        behavior: HitTestBehavior.opaque,
        child: tab,
      );
    }

    return tab;
  }
}
