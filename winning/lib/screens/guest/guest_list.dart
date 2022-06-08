import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart' hide Response;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/guest/GuestTabs/associate_guest.dart';
import '../../screens/guest/GuestTabs/leader_guest.dart';
import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';
import 'GuestTabs/close_guest.dart';
import 'GuestTabs/core_committee_guest.dart';
import 'GuestTabs/died_guest.dart';
import 'GuestTabs/followUp_guest.dart';
import 'GuestTabs/guest.dart';
import 'GuestTabs/invited_guest.dart';
import 'GuestTabs/presentation_guest.dart';
import 'guest_search.dart';

const iOSLocalizedLabels = false;

class GuestList extends StatefulWidget {
  @override
  _GuestListState createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  final _guestUpdateFormKey = GlobalKey<FormState>();
  final _guestAddFormKey = GlobalKey<FormState>();
  GlobalKey<PaginatedListState> newGuestPaginatedListKey = GlobalKey();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TabController? _tabController;

  bool _autoValidation = false;
  Response? response;
  Translator? translator;
  var tabIndex;
  Future? _labelsApi;
  late var guestList;
  List? typeLabels = [];
  List? changeTypeLabels = [];
  List? training;
  var guestData;
  String selectTab = "1";
  List<String?> _statusValues = [];
  bool loader = false;
  var searchedData;
  bool isRefresh = false;
  int? _countryVal;
  List? countriesList = [];

  late List selectedCountries;
  int? countryId = 1;
  late Map selectedCountry;

  late PermissionStatus status;

  String? validateMobile(String value) {
    if (phoneNumber == "+91") {
      return Translator.get('Mobile Number must be of 10 digit');
    } else if (value.length >= 4) {
      return Translator.get('Mobile Number must be of 4 digit');
    } else
      return null;
  }

  void launchWhatsApp(
    String? phone,
    String message,
  ) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw GetBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        message: Translator.get('WhatsApp not found')!,
      ).show();
    }
  }

  String phoneNumber = "+91";

  @override
  void initState() {
    _labelsApi = _futureBuild();
    _askPermissions();
    _changeStatusFutureBuild();
    _futureBuildCountries();
    super.initState();
  }

  Future _futureBuildCountries() {
    return Api.http.post('countries').then(
      (res) {
        if (mounted) {
          setState(() {
            countriesList = res.data['list'];
            _countryVal = 1;
          });
        }
        return res.data;
      },
    );
  }

  Future _futureBuild() {
    return Api.http.get('guest-labels').then(
      (res) {
        guestList = res.data;
        typeLabels = guestList["guestLabels"];
        return res.data;
      },
    );
  }

  Future _changeStatusFutureBuild() {
    return Api.http.get('new-guest-labels').then(
      (res) {
        guestList = res.data;
        changeTypeLabels = guestList["guestLabels"];
        return res.data;
      },
    );
  }

  void _askPermissions() async {
    status = await Permission.contacts.status;

    if (!status.isGranted) {
      await Permission.contacts.request();
      // Permission.contacts.shouldShowRequestRationale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: Get.arguments == "Follow"
          ? 3
          : Get.arguments == "Close"
              ? 4
              : Get.arguments == "Invited"
                  ? 1
                  : Get.arguments == "Presentation"
                      ? 2
                      : Get.arguments == "NotInterested"
                          ? 5
                          : Get.arguments == "Associate"
                              ? 7
                              : Get.arguments == "Leader"
                                  ? 8
                                  : Get.arguments == "CoreCommittee"
                                      ? 9
                                      : Get.arguments == "guest"
                                          ? 6
                                          : 0,
      length: 10,
      child: FutureBuilder(
        future: _labelsApi,
        builder: (BuildContext context, AsyncSnapshot sanpshot) {
          if (!sanpshot.hasData) {
            return Center();
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(Translator.get('Guest List')!),
              leading: IconButton(
                onPressed: () {
                  Get.offAllNamed('home');
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Get.to(GuestSearch());
                  },
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                labelColor: white,
                indicatorColor: colorPrimary,
                unselectedLabelColor: white,
                onTap: (index) {
                  setState(() {
                    tabIndex = (index + 1).toString();
                  });
                },
                tabs: typeLabels!.map(
                  (tab) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: text(
                        tab['value'],
                        textColor: white,
                        fontFamily: fontSemibold,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                _newGuest(),
                InvitedGuest(),
                PresentationGuest(),
                FollowUpGuest(),
                CloseGuest(),
                DiedGuest(),
                Guest(),
                AssociateGuest(),
                LeaderGuest(),
                CoreCommittee(),
              ],
            ),
            floatingActionButton: tabIndex == "7"
                ? Center()
                : tabIndex == "8"
                    ? Center()
                    : tabIndex == "9"
                        ? Center()
                        : guestFloatingButton(context),
          );
        },
      ),
    );
  }

  Widget guestFloatingButton(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      marginRight: 18,
      marginBottom: 20,
      backgroundColor: Colors.orange,
      children: [
        SpeedDialChild(
          child: Icon(Feather.refresh_ccw),
          backgroundColor: colorPrimary,
          label: Translator.get('Contact sync')!,
          labelStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            Get.toNamed('guest-add', arguments: {
              "isDenied": status.isDenied,
              "isPermanentlyDenied": status.isPermanentlyDenied,
            }).then((value) {
              print("status.isPermanentlyDenied ${status.isPermanentlyDenied}");
            });
          },
        ),
        SpeedDialChild(
          child: Icon(Feather.user_plus),
          backgroundColor: Theme.of(context).accentColor,
          label: Translator.get('New Contact')!,
          labelStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          onTap: () {
            _buildAddGuest(context);
          },
        )
      ],
    );
  }

  Widget _newGuest() {
    return Column(
      children: <Widget>[
        // if (training != null && training.length > 0)
        //   FadeAnimation(
        //     0.9,
        //     _buildPackage(context),
        //   ),
        if (guestData != null)
          FadeAnimation(
            1.0,
            _buildNewGuestRecord(context, guestData),
          ),
        Expanded(
          child: PaginatedList(
            key: newGuestPaginatedListKey,
            apiFuture: newGuestApiFuture,
            listItemBuilder: newGuestBuilder,
            resetStateOnRefresh: true,
          ),
        ),
      ],
    );
  }

  Future<Response> newGuestApiFuture(int page) async {
    return Api.http.post(
      'guest-lists?page=$page',
      data: {
        'label_id': selectTab,
      },
    ).then((response) {
      if (guestData == null && training == null || isRefresh) {
        setState(() {
          guestData = response.data;
          training = response.data['training'];
        });
        isRefresh = false;
      }
      return response;
    });
  }

  Widget _buildNewGuestRecord(BuildContext context, guestData) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: boxDecoration(
            radius: 10,
            showShadow: true,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    text(
                      Translator.get("LifeTime Total"),
                    ),
                    text(
                      guestData['total'] != null ? guestData['total'].toString() : "0",
                      textColor: blue,
                      fontFamily: fontSemibold,
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    text(
                      Translator.get("New in last 28 days"),
                    ),
                    text(
                      guestData['lastTwentyEightDays'] != null ? guestData['lastTwentyEightDays'].toString() : "0",
                      textColor: red,
                      fontFamily: fontSemibold,
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    text(Translator.get("New in last 7 Days")),
                    text(
                      guestData['lastSevenDays'] != null ? guestData['lastSevenDays'].toString() : "0",
                      textColor: green,
                      fontFamily: fontSemibold,
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    text(Translator.get("Pending Action")),
                    text(
                      guestData['pendingAction'] != null ? guestData['pendingAction'].toString() : "0",
                      textColor: colorPrimary,
                      fontFamily: fontSemibold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget newGuestBuilder(newGuest, index) {
    return SizedBox(
      child: FadeAnimation(
        0.9,
        Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: boxDecoration(
                radius: 10,
                showShadow: true,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorPrimary.withOpacity(0.2),
                                  radius: 20,
                                  child: Icon(
                                    Feather.user,
                                    color: colorPrimary,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 10)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(
                                newGuest["name"],
                                textColor: textColorPrimary,
                                fontFamily: fontSemibold,
                                fontSize: textSizeMedium,
                                maxLine: 2,
                              ),
                              text(
                                /*newGuest['country']['code'] + " " +*/ newGuest["mobile"],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      launch("tel: ${newGuest["mobile"]}");
                                    },
                                    icon: Icon(
                                      Feather.phone_call,
                                      size: 20,
                                      color: colorPrimary,
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {
                                        launch("sms: ${newGuest["mobile"]}");
                                      },
                                      icon: Icon(
                                        Feather.message_circle,
                                        size: 20,
                                        color: red,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {
                                        newGuest['country'] != null
                                            ? launchWhatsApp(newGuest['country']['code'] + newGuest["mobile"], "")
                                            : launchWhatsApp(newGuest["mobile"], "");
                                      },
                                      icon: Icon(
                                        MaterialCommunityIcons.whatsapp,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(
                                "${Translator.get('Date')} : ",
                              ),
                              text(
                                newGuest["createdAt"],
                                textColor: colorPrimaryDark,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              text(Translator.get("Trust")),
                              LinearProgressIndicator(
                                value: 0.9,
                                backgroundColor: Colors.black12,
                                valueColor: AlwaysStoppedAnimation(green),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(child: _buildChangeStatusField(newGuest, index)),
                      Expanded(
                        child: TextButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Feather.edit,
                                color: colorPrimary,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              text(
                                Translator.get('Edit'),
                                textColor: colorPrimary,
                                fontFamily: fontSemibold,
                                textAllCaps: true,
                              ),
                            ],
                          ),
                          onPressed: () {
                            _updateGuest(newGuest, index);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            if (newGuest['user'] == true)
              Container(
                width: 4,
                height: 35,
                margin: EdgeInsets.only(top: 16, left: 10),
                color: Color(0XFF3DDB85),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildPackage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 110.0,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 5),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (_, int index) {
            return GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TrainingDescription(
                //       trainingData: training[index]['trainingData'],
                //     ),
                //   ),
                // );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color(0xFFF6F5F8),
                    maxRadius: 30.0,
                    child: PNetworkImage(
                      training![index]['thumbnail'],
                      fit: BoxFit.contain,
                      height: 30,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    training![index]['trainingData']['name'],
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            );
          },
          itemCount: training!.length,
        ),
      ),
    );
  }

  Widget _buildChangeStatusField(data, index) {
    _statusValues.add(null);

    return Container(
      padding: EdgeInsets.only(left: 10.0),
      child: DropdownButtonFormField(
        isDense: true,
        isExpanded: true,
        value: _statusValues[index],
        onChanged: (String? newValue) {
          setState(() {
            _statusValues[index] = newValue;
          });

          Map sendData = {"mobile": data["mobile"], "label_id": _statusValues[index]};

          Api.http.post('change-guest-label', data: sendData).then(
            (response) async {
              GetBar(
                backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                duration: Duration(seconds: 3),
                message: response.data['message'],
              ).show();
              _statusValues.clear();

              newGuestPaginatedListKey.currentState!.refresh();
            },
          ).catchError(
            (error) {
              if (error.response.statusCode == 422) {
                GetBar(
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  message: error.response.data['errors'],
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
        },
        hint: text(Translator.get('Change Status')),
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
        ),
        items: changeTypeLabels!.map<DropdownMenuItem<String>>(
          (value) {
            return DropdownMenuItem<String>(
              value: value['id'].toString(),
              child: text(
                value['value'],
                fontFamily: fontSemibold,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  _updateGuest(data, index) {
    var guestId = data['id'];

    TextEditingController _nameController = TextEditingController(text: data['name']);
    TextEditingController _numberController = TextEditingController(text: data['mobile']);

    Get.bottomSheet(
      Form(
        key: _guestUpdateFormKey,
        autovalidate: _autoValidation,
        onChanged: () {},
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      Translator.get('Edit Guest Details')!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: Translator.get("Enter Guest Name"),
                          labelText: Translator.get("Guest Name"),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: _countryCode(context),
                            flex: 1,
                          ),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9]"))],
                              // validator: validateMobile,
                              controller: _numberController,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: Translator.get('Enter Guest Number'),
                                labelText: Translator.get("Guest Mobile Number"),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      _addButton(context, _nameController, _numberController, guestId)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _addButton(BuildContext context, _nameController, _numberController, guestId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text(Translator.get('Cancel')!),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(
          width: 10,
        ),
        TextButton(
          child: Text(Translator.get('Save')!),
          onPressed: () {
            Map sendData = {
              "name": _nameController.text,
              "mobile": _numberController.text,
              "country_id": countryId,
              "guest_id": guestId,
            };

            Api.http.put("guest-update", data: sendData).then(
              (res) {
                Get.back();
                newGuestPaginatedListKey.currentState!.refresh();
                // Get.toNamed('guest-list').then(
                //   (value) {
                //     Navigator.popAndPushNamed(context, 'guest-list');
                //   },
                // );
              },
            ).catchError(
              (error) {
                if (error.response.statusCode == 422) {
                  GetBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    message: error.response.data['errors'],
                  ).show();
                } else if (error.response.statusCode == 401) {
                  GetBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    message: error.response.data['message'],
                  ).show();
                }
              },
            );
          },
        )
      ],
    );
  }

  _buildAddGuest(BuildContext context) {
    Get.bottomSheet(
      Form(
        key: _guestAddFormKey,
        autovalidate: _autoValidation,
        onChanged: () {},
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Text(
                        Translator.get('Create New Guest')!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _nameController.clear();
                        _mobileController.clear();
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return Translator.get('Please Enter Guest Name.');
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: Translator.get('Enter Guest Name'),
                            labelText: Translator.get('Guest Name'),
                          ),
                          controller: _nameController,
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: _countryCode(context),
                            ),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9]"))],
                                // validator: validateMobile,
                                maxLength: 13,
                                controller: _mobileController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(),
                                  hintText: Translator.get('Enter Guest Number'),
                                  labelText: Translator.get('Guest Mobile Number'),
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        _sendButton(context)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _sendButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text(
            Translator.get('Cancel')!,
            style: TextStyle(fontSize: 16),
          ),
          onPressed: () {
            _nameController.clear();
            _mobileController.clear();
            Navigator.of(context).pop();
          },
        ),
        SizedBox(
          width: 10,
        ),
        TextButton(
          child: Text(
            Translator.get('Add New Guest')!,
            style: TextStyle(fontSize: 16),
          ),
          onPressed: () {
            setState(() {
              _autoValidation = true;
            });
            if (_guestAddFormKey.currentState!.validate()) {
              FocusScope.of(context).requestFocus(FocusNode());
              Map guestData = {
                'name': _nameController.text,
                'mobile': _mobileController.text,
                "country_id": countryId,
                'label_id': "1",
              };

              Api.http.post('add-guest', data: guestData).then(
                (response) async {
                  _nameController.clear();
                  _mobileController.clear();
                  Get.back();
                  newGuestPaginatedListKey.currentState!.refresh();
                  // Get.toNamed('guest-list').then(
                  //   (value) {
                  //     Navigator.popAndPushNamed(context, 'guest-list');
                  //   },
                  // );
                },
              ).catchError(
                (error) {
                  if (error.response.statusCode == 422) {
                    GetBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      message: error.response.data['errors'],
                    ).show();
                  } else if (error.response.statusCode == 401) {
                    GetBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      message: error.response.data['message'],
                    ).show();
                  }
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _countryCode(BuildContext context) {
    return DropdownButtonFormField(
      iconEnabledColor: Colors.black,
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16.0),
        hintText: Translator.get("Select Country"),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      value: _countryVal,
      onChanged: ((dynamic newValue) {
        setState(() {
          _countryVal = newValue;
          selectedCountries = countriesList!.where((country) => country['id'] == newValue).toList();
          selectedCountry = selectedCountries[0];
          countryId = selectedCountry['id'];
        });
      }),
      items: countriesList!.map<DropdownMenuItem<int>>(
        (value) {
          return DropdownMenuItem<int>(
            value: value['id'],
            child: text(
              value['name'],
              fontFamily: fontSemibold,
            ),
          );
        },
      ).toList(),
      selectedItemBuilder: (BuildContext context) {
        String? text = Translator.get("Select Country");

        if (_countryVal != null) {
          Map selectedCountry = countriesList!.firstWhere((element) => element['id'] == _countryVal);
          text = selectedCountry['code'];
        }

        return countriesList!.map((dynamic value) {
          return Text(
            text != null ? text : "",
            style: TextStyle(color: Colors.black),
          );
        }).toList();
      },
    );
  }
}
