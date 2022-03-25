import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class PDFViewer extends StatefulWidget {
  const PDFViewer({Key? key}) : super(key: key);

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  var filePath;
  late PdfController pdfController;

  @override
  void initState() {
    filePath = Get.arguments;
    pdfController = PdfController(
      document: PdfDocument.openFile(filePath),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filePath.split('/').last),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: PdfView(
          controller: pdfController,
        ),
      ),
    );
  }
}
