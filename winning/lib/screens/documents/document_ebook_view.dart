import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/size_config.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';
import 'PDFViewerCachedFromUrl.dart';

class DocumentEBookView extends StatefulWidget {
  @override
  _DocumentEBookViewState createState() => _DocumentEBookViewState();
}

class _DocumentEBookViewState extends State<DocumentEBookView> {
  String? urlPDFPath;
  Map? eBookData;
  Map? documentVideoData;

  @override
  void initState() {
    documentVideoData = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List descriptionList = documentVideoData!['details'];

    return Scaffold(
      appBar: AppBar(
        title: Text(documentVideoData!['name']),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (documentVideoData!['pageType'] == "cep") {
                Get.toNamed('document-ebook-search', arguments: {
                  "id": documentVideoData!['id'],
                  "pageType": documentVideoData!['pageType'],
                  "typeId": documentVideoData!['details'][0]['typeId'],
                });
              } else if (documentVideoData!['pageType'] == "vestige") {
                Get.toNamed('document-ebook-search', arguments: {
                  "id": documentVideoData!['id'],
                  "pageType": documentVideoData!['pageType'],
                  "typeId": documentVideoData!['details'][0]['typeId'],
                });
              } else if (documentVideoData!['pageType'] == "inspiration") {
                Get.toNamed('document-ebook-search', arguments: {
                  "id": documentVideoData!['id'],
                  "pageType": documentVideoData!['pageType'],
                  "typeId": documentVideoData!['details'][0]['typeId'],
                });
              } else if (documentVideoData!['pageType'] == "cep-prime") {
                Get.toNamed('document-ebook-search', arguments: {
                  "id": documentVideoData!['id'],
                  "pageType": documentVideoData!['pageType'],
                  "typeId": documentVideoData!['details'][0]['typeId'],
                });
              }
            },
            icon: Icon(
              Feather.search,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: descriptionList.length,
        itemBuilder: (BuildContext context, int index) {
          return _documentVideoList(descriptionList, index);
        },
      ),
    );
  }

  Widget _documentVideoList(descriptionList, index) {
    return FadeAnimation(
      0.9,
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: boxDecoration(
                radius: 10,
                showShadow: true,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    child: PNetworkImage(
                      descriptionList[index]['thumbnail'],
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 0, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ReCase(descriptionList[index]['title']).titleCase,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0XFF333333),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                softWrap: true,
                              ),
                              SizedBox(height: SizeConfig.height(1)),
                              Text(
                                descriptionList[index]['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0XFF747474),
                                ),
                                maxLines: 3,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      RaisedButton.icon(
                        icon: Icon(
                          Icons.insert_drive_file,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          'View PDF'.toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (descriptionList[index]['file'] != "") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFViewerCachedFromUrl(
                                  url: descriptionList[index]['file'],
                                  name: descriptionList[index]['title'],
                                ),
                              ),
                            );
                          } else {
                            GetBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              message: "File not Found",
                            ).show();
                          }
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
