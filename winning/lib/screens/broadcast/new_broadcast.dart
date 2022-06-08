import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class NewBroadcast extends StatefulWidget {
  @override
  _NewBroadcastState createState() => _NewBroadcastState();
}

class _NewBroadcastState extends State<NewBroadcast> {
  List<Map> selectedMembers = [];
  List<Map> selectedMembersId = [];
  List members = [];
  int count = 0;
  int? membersLength;

  TextEditingController _broadcastNameController = TextEditingController();

  final _broadcastFormKey = GlobalKey<FormState>();
  bool _autoValidation = false;
  var progressString = "";
  bool uploading = false;
  File? _imageFile;
  TextEditingController _imageController = TextEditingController();

  var image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translator.get('Create New Broadcast')!,
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
          if (count > 1)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // _showDialog();

                    Get.toNamed('broadcast-create', arguments: selectedMembers);
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
                                        if (selectedContact['memberId'] == member['memberId']) {
                                          member["isSelected"] = !member["isSelected"];
                                        }
                                      }).toList();

                                      for (int i = 0; i < selectedMembers.length; i++) {
                                        if (selectedContact['memberId'] == selectedMembers[i]['memberId']) {
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
                                    : selectedContact['name'].toString().length < 6
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
            child: Auth.currentPackage() == 4
                ? PaginatedList(
                    apiFuture: (int page) async {
                      return Api.http.get("downline-lists?page=$page");
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
                  )
                : PaginatedList(
                    apiFuture: (int page) async {
                      return Api.http.get("associate-lists?page=$page");
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
                member['name'] != null ? member['name'] : "",
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _imageFile = image;

            return _alertCustom(context);
          },
        );
      },
    );
  }

  AlertDialog _alertCustom(BuildContext context) {
    return AlertDialog(
      title: Text(Translator.get("Create Broadcast")!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      content: Form(
        key: _broadcastFormKey,
        autovalidate: _autoValidation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildBroadcastImage(),
            TextFormField(
              controller: _broadcastNameController,
              inputFormatters: [BlacklistingTextInputFormatter(RegExp(r'^[ ,-]'))],
              decoration: InputDecoration(
                hintText: Translator.get('Enter Broadcast Name'),
              ),
              validator: (value) {
                if (value == null) {
                  return Translator.get('Please Enter Broadcast Name');
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: Text(
                Translator.get("Create")!,
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                selectedMembersId.clear();
                selectedMembers.map((Map selectedMember) {
                  selectedMembersId.add({'id': selectedMember['memberId']});
                }).toList();
                Map requestData = {
                  "name": _broadcastNameController.text,
                  "team_members": selectedMembersId,
                };

                Api.http.post('create-broadcast-team', data: requestData).then(
                  (response) async {
                    if (response.data['status']) {
                      Get.offAllNamed("home");
                      Get.toNamed("broadcasting");
                    }
                    GetBar(
                      backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                      duration: Duration(seconds: 3),
                      message: response.data['message'],
                    ).show();
                  },
                ).catchError(
                  (error) {
                    print(error);
                  },
                );
                _broadcastNameController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBroadcastImage() {
    Widget imageWidget;
    if (!uploading) {
      if (_imageFile == null) {
        imageWidget = CachedNetworkImage(
          imageUrl: _imageController.text,
          imageBuilder: (context, imageProvider) => Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/users.png',
            height: 100.0,
            width: 100.0,
            fit: BoxFit.fill,
          ),
        );
        return broadcastImage(context, imageWidget);
      } else {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(
            _imageFile!,
            height: 100,
            width: 100,
            fit: BoxFit.fill,
          ),
        );
        return broadcastImage(context, imageWidget);
      }
    } else {
      return Container(
        height: 120.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 20.0),
            Text(
              Translator.get("Uploading Image:")! + "$progressString ",
            )
          ],
        ),
      );
    }
  }

  Widget broadcastImage(BuildContext context, Widget image) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(spacing_standard_new),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: spacing_standard,
              margin: EdgeInsets.all(spacing_control),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: image,
            ),
          ),
          Container(
            padding: EdgeInsets.all(spacing_control),
            margin: EdgeInsets.only(bottom: 30, right: 15),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: white, border: Border.all(color: colorPrimary, width: 1)),
            child: GestureDetector(
              onTap: () {
                getImage(ImgSource.Both);
              },
              child: Icon(
                Icons.camera_alt,
                color: colorPrimary,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future getImage(ImgSource source) async {
    image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(Feather.camera),
      galleryIcon: Icon(Feather.image),
      cameraText: text(Translator.get("From Camera")),
      galleryText: text(Translator.get("From Gallery")),
      barrierDismissible: true,
    );

    if (image != null) _imageController.text = image.path.split("/").last;
    // _alertCustom(context);
  }
}
