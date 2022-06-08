import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class EBookDetails extends StatefulWidget {
  @override
  _EBookDetailsState createState() => _EBookDetailsState();
}

class _EBookDetailsState extends State<EBookDetails> {
  Translator? translator;
  String? urlPDFPath;
  Map? eBookData;
  Map? learningEBookData;

  @override
  void initState() {
    learningEBookData = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List descriptionList = learningEBookData!['eBookData'];

    return Scaffold(
      appBar: AppBar(title: Text(learningEBookData!["name"])),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: descriptionList.length,
        itemBuilder: (BuildContext context, int index) {
          return _learningVideoList(descriptionList, index);
        },
      ),
    );
  }

  Widget _learningVideoList(descriptionList, index) {
    return FadeAnimation(
      0.9,
      Container(
        decoration: boxDecoration(
          radius: 10,
          showShadow: true,
        ),
        margin: const EdgeInsets.all(8),
        height: 170,
        width: double.infinity,
        child: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 1,
                  vertical: 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PNetworkImage(
                    descriptionList[index]['thumbnail'],
                    fit: BoxFit.contain,
                    height: 100,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        ReCase(descriptionList[index]['title']).titleCase,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: SizeConfig.width(3.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.height(1),
                    ),
                    Expanded(
                      child: Text(
                        descriptionList[index]['description'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: SizeConfig.width(3.5),
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.height(1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({Key? key, required this.url, this.name}) : super(key: key);

  final String? url;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name!),
      ),
      body: const PDF().cachedFromUrl(
        url!,
        placeholder: (double progress) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(double.parse(progress.toString()).toInt().toString() + "%"),
          ],
        ),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
