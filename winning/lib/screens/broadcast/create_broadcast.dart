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

class CreateBroadcast extends StatefulWidget {
  @override
  _CreateBroadcastState createState() => _CreateBroadcastState();
}

class _CreateBroadcastState extends State<CreateBroadcast> {
  List<Map>? membersList;
  @override
  void initState() {
    membersList = Get.arguments;
    super.initState();
  }

  List<Map> selectedMembersId = [];

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
        title: Text(Translator.get('Create Broadcast')!),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _broadcastFormKey,
          autovalidate: _autoValidation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10.0),
              text(Translator.get("Set broadcast image"), fontSize: 18.0),
              _buildBroadcastImage(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
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
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _createBroadcastTeam();
                    },
                    child: Container(
                      height: 40.0,
                      width: 180.0,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          Translator.get('Create Broadcast')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
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
  }

  Widget profileImage(BuildContext context, Widget image) {
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

  Widget _buildBroadcastImage() {
    Widget imageWidget;
    if (!uploading) {
      if (_imageFile == null) {
        imageWidget = CachedNetworkImage(
          imageUrl: _imageController.text,
          imageBuilder: (context, imageProvider) => Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Image.network(
            'https://542partners.com.au/wp-content/uploads/2014/09/announcement-icon.png',
            width: 120.0,
            height: 120.0,
            fit: BoxFit.fill,
          ),
        );
        return profileImage(context, imageWidget);
      } else {
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.file(
            _imageFile!,
            height: 120,
            width: 120,
            fit: BoxFit.fill,
          ),
        );
        return profileImage(context, imageWidget);
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

  Future<void> _createBroadcastTeam() async {
    selectedMembersId.clear();
    membersList!.map((Map selectedMember) {
      selectedMembersId.add({'id': selectedMember['memberId']});
    }).toList();
    if (_broadcastFormKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
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

      Map requestData = {
        "name": _broadcastNameController.text,
        "team_members": selectedMembersId,
        "image": profileImage
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
    }
  }
}
