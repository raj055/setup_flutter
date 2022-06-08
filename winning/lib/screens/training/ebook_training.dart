import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/FadeAnimation.dart';
import '../../widget/network_image.dart';

class EBookTraining extends StatefulWidget {
  final List? learningVideoData;

  const EBookTraining({Key? key, this.learningVideoData}) : super(key: key);

  @override
  _EBookTrainingState createState() => _EBookTrainingState();
}

class _EBookTrainingState extends State<EBookTraining> {
  String? urlPDFPath;
  Map? eBookData;

  @override
  Widget build(BuildContext context) {
    List descriptionList = widget.learningVideoData!;

    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: AppBar(
        title: Text(Translator.get("EBooks")!),
        centerTitle: true,
        elevation: 0,
      ),
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
      GestureDetector(
        onTap: () async {
          eBookData = descriptionList[index];
          urlPDFPath = descriptionList[index]['file'];
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) =>
          //           PdfPage(eBook: eBookData, path: urlPDFPath)),
          // );
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD1DCFF),
                blurRadius: 10.0,
                spreadRadius: 1.0,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              5.0,
            ),
          ),
          margin: const EdgeInsets.all(8),
          height: 120,
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
                  child: PNetworkImage(
                    descriptionList[index]['thumbnail'],
                    fit: BoxFit.contain,
                    height: 100,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        descriptionList[index]['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: SizeConfig.width(4.0),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: SizeConfig.height(2),
                      ),
                      Text(
                        descriptionList[index]['description'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: SizeConfig.width(3.0),
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
}

// class PdfPage extends StatefulWidget {
//   final String path;
//   final Map eBook;
//
//   const PdfPage({Key key, this.path, this.eBook}) : super(key: key);
//
//   @override
//   _PdfPageState createState() => _PdfPageState();
// }
//
// class _PdfPageState extends State<PdfPage> {
//   String urlPDFPath;
//
//   @override
//   void initState() {
//     super.initState();
//
//     getFileFromUrl(widget.path).then(
//       (f) {
//         setState(
//           () {
//             urlPDFPath = f.path;
//           },
//         );
//       },
//     );
//   }
//
//   Future<File> getFileFromUrl(String url) async {
//     try {
//       var data = await http.get(url);
//       var bytes = data.bodyBytes;
//       var dir = await getApplicationDocumentsDirectory();
//       File file = File("${dir.path}/mypdfonline.pdf");
//
//       File urlFile = await file.writeAsBytes(bytes);
//       return urlFile;
//     } catch (e) {
//       throw Exception("Error opening url file");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var bookView = widget.eBook;
//     return Scaffold(
//       backgroundColor: Color(0xFFE9E9E9),
//       appBar: AppBar(
//         title: Text(widget.eBook['title']),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Stack(
//               children: <Widget>[
//                 Container(
//                   padding: EdgeInsets.all(16.0),
//                   margin: EdgeInsets.only(top: 16.0),
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(5.0)),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Container(
//                         margin: EdgeInsets.only(left: 96.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Text(
//                               bookView['title'],
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               bookView['description'],
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: SizeConfig.width(3.0),
//                                 color: Colors.grey.shade600,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Center(
//                             child: RaisedButton(
//                               color: Colors.amber,
//                               child: Text(Translator.get("Open PDF")),
//                               onPressed: () {
//                                 if (urlPDFPath != null) {
//                                   // Navigator.push(
//                                   //   context,
//                                   //   MaterialPageRoute(
//                                   //     builder: (context) => PdfViewPage(
//                                   //         path: urlPDFPath,
//                                   //         name: bookView['title']),
//                                   //   ),
//                                   // );
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   height: 80,
//                   width: 80,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10.0),
//                       image: DecorationImage(
//                           image: CachedNetworkImageProvider(
//                             bookView['thumbnail'],
//                           ),
//                           fit: BoxFit.cover)),
//                   margin: EdgeInsets.only(left: 16.0),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class PdfViewPage extends StatefulWidget {
//   final String path;
//   final String name;
//
//   const PdfViewPage({Key key, this.path, this.name}) : super(key: key);
//
//   @override
//   _PdfViewPageState createState() => _PdfViewPageState();
// }
//
// class _PdfViewPageState extends State<PdfViewPage> {
//   int _totalPages = 0;
//   int _currentPage = 0;
//   bool pdfReady = false;
//   PDFViewController _pdfViewController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.name),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: <Widget>[
//           PDFView(
//             filePath: widget.path,
//             autoSpacing: true,
//             enableSwipe: true,
//             pageSnap: true,
//             swipeHorizontal: true,
//             nightMode: false,
//             onError: (e) {},
//             onRender: (_pages) {
//               setState(() {
//                 _totalPages = _pages;
//                 pdfReady = true;
//               });
//             },
//             onViewCreated: (PDFViewController vc) {
//               _pdfViewController = vc;
//             },
//             onPageChanged: (int page, int total) {
//               setState(() {});
//             },
//             onPageError: (page, e) {},
//           ),
//           !pdfReady
//               ? Center(
//                   child: CircularProgressIndicator(),
//                 )
//               : Offstage()
//         ],
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           _currentPage > 0
//               ? FloatingActionButton.extended(
//                   backgroundColor: Colors.red,
//                   label: Text("${Translator.get('Go to')} ${_currentPage - 1}"),
//                   onPressed: () {
//                     _currentPage -= 1;
//                     _pdfViewController.setPage(_currentPage);
//                   },
//                 )
//               : Offstage(),
//           _currentPage + 1 < _totalPages
//               ? FloatingActionButton.extended(
//                   backgroundColor: Colors.green,
//                   label: Text("${Translator.get('Go to')} ${_currentPage + 1}"),
//                   onPressed: () {
//                     _currentPage += 1;
//                     _pdfViewController.setPage(_currentPage);
//                   },
//                 )
//               : Offstage(),
//         ],
//       ),
//     );
//   }
// }
