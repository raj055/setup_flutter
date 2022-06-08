import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';

import '../../services/Vapor.dart';
import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class EditBroadcast extends StatefulWidget {
  @override
  _EditBroadcastState createState() => _EditBroadcastState();
}

class _EditBroadcastState extends State<EditBroadcast> {
  Map? broadcastTeamDetails;
  Future? _editBroadcast;
  late Map editBroadcastData;

  TextEditingController _broadcastNameController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

  var progressString = "";
  bool uploading = false;
  File? _imageFile;

  @override
  void initState() {
    broadcastTeamDetails = Get.arguments;
    _editBroadcast = _futureBuild();

    super.initState();
  }

  Future _futureBuild() {
    return Api.http
        .post('edit-broadcast-team', data: {'broadcast_team_id': broadcastTeamDetails!['broadcast_team_id']}).then(
      (res) {
        editBroadcastData = res.data;
        return res.data;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _editBroadcast,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                backgroundColor: Colors.grey.shade400.withOpacity(0.5),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    editBroadcastData['broadcast_team_name'],
                    style: TextStyle(fontFamily: fontSemibold),
                  ),
                  background: CachedNetworkImage(
                    imageUrl: editBroadcastData['image'],
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.network(
                      'https://images.pexels.com/photos/443356/pexels-photo-443356.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Feather.camera),
                    tooltip: Translator.get('Camera'),
                    onPressed: () async {
                      getImage(ImgSource.Both);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Feather.edit_2),
                    tooltip: Translator.get('Edit Team Name'),
                    onPressed: () {
                      setState(() {
                        _broadcastNameController.text = broadcastTeamDetails!['broadcast_team_name'];
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              Translator.get('Edit Team Name')!,
                            ),
                            content: TextFormField(
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
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    child: Text(
                                      Translator.get('Update')!,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () {
                                      Api.http.post('update-broadcast-team-name', data: {
                                        "broadcast_team_id": broadcastTeamDetails!['broadcast_team_id'],
                                        "name": _broadcastNameController.text
                                      }).then(
                                        (response) async {
                                          _broadcastNameController.clear();
                                          if (response.data['status']) {
                                            setState(() {
                                              _editBroadcast = _futureBuild();
                                            });
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
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Feather.user_plus),
                    tooltip: Translator.get('Add Members'),
                    onPressed: () {
                      Get.toNamed(
                        'edit-broadcast-members',
                        arguments: broadcastTeamDetails!['broadcast_team_id'],
                      ).then((value) {
                        setState(() {
                          _editBroadcast = _futureBuild();
                        });
                      });
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      decoration: boxDecoration(
                        showShadow: true,
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: text(
                              editBroadcastData['teamMembers'].length.toString() + '  recipients',
                              textColor: colorPrimary,
                            ),
                          ),
                          Divider(height: 1),
                          ListView.builder(
                            padding: EdgeInsets.all(0),
                            itemCount: editBroadcastData['teamMembers'].length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Dismissible(
                                direction: DismissDirection.endToStart,
                                key: Key(editBroadcastData['teamMembers'].toString()[index]),
                                confirmDismiss: (direction) async {
                                  final bool? res = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                        content: Text(
                                            "Are you sure you want to delete ${editBroadcastData['teamMembers'][index]['memberName']}?"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              Translator.get("Cancel")!,
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              Translator.get("Delete")!,
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () {
                                              Api.http.post('broadcast-member-delete', data: {
                                                'broadcast_team_id': broadcastTeamDetails!['broadcast_team_id'],
                                                'member_id': editBroadcastData['teamMembers'][index]['memberId'],
                                              }).then((res) {
                                                setState(() {
                                                  _editBroadcast = _futureBuild();
                                                });
                                                return res.data;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return res;
                                },
                                background: Container(
                                  color: Colors.red,
                                  child: Align(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          Translator.get("Delete")!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                                child: GestureDetector(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 25,
                                      child: Image.asset('assets/images/users.png'),
                                    ),
                                    title: Text(editBroadcastData['teamMembers'][index]['memberName']),
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future getImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(Feather.camera),
      galleryIcon: Icon(Feather.image),
      cameraText: text(Translator.get("From Camera")),
      galleryText: text(Translator.get("From Gallery")),
      barrierDismissible: true,
    );

    if (image != null) _imageController.text = image.path.split("/").last;

    setState(() {
      _imageFile = image;
    });

    if (_imageFile != null)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Text("Are you sure you want to Update Image ?"),
            actions: <Widget>[
              TextButton(
                child: Text(
                  Translator.get("Cancel")!,
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  Translator.get("Update")!,
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  dynamic profileImage;
                  if (_imageFile != null) {
                    profileImage = await Vapor.upload(
                      _imageFile!,
                      progressCallback: (int? completed, int? total) {
                        setState(() {
                          uploading = true;
                          progressString = ((completed! / total!) * 100).toStringAsFixed(0) + "%";
                        });
                      },
                    );
                  }
                  setState(
                    () {
                      uploading = false;
                    },
                  );

                  if (_imageFile != null) {
                    Api.http.post('update-broadcast-team-image', data: {
                      'broadcast_team_id': broadcastTeamDetails!['broadcast_team_id'],
                      'image': profileImage,
                    }).then((res) {
                      setState(() {
                        _editBroadcast = _futureBuild();
                      });
                      return res.data;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  }

  Widget profileImage(BuildContext context /*, Widget image*/) {
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
              // child: image,
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
}
