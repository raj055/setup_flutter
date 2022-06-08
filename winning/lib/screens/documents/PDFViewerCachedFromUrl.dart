import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewerCachedFromUrl extends StatefulWidget {
  final String? url;
  final String? name;
  const PDFViewerCachedFromUrl({Key? key, required this.url, this.name}) : super(key: key);

  @override
  _PDFViewerCachedFromUrlState createState() => _PDFViewerCachedFromUrlState();
}

class _PDFViewerCachedFromUrlState extends State<PDFViewerCachedFromUrl> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late CurvedAnimation _animation;

  late double _swipeOffset;
  @override
  void initState() {
    _swipeOffset = 0.0;
    initialAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initialAnimation() {
    _animationController = AnimationController(duration: Duration(milliseconds: 2000), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Interval(0, 0.25, curve: Curves.decelerate));

    _animationController.repeat(reverse: true);
    _animation.addListener(() {
      setState(() {});
    });
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name!),
      ),
      body: Stack(
        children: <Widget>[
          PDF(
            swipeHorizontal: false,
            onPageChanged: (page, total) {
              currentPage = page;
            },
          ).cachedFromUrl(
            widget.url!,
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
          if (currentPage == 0)
            Positioned(
              bottom: (_swipeOffset / 2) + (MediaQuery.of(context).size.height / 40 * (1 - _animation.value)),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.keyboard_arrow_up, color: Colors.black),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 240, bottom: MediaQuery.of(context).size.height / 40),
                    child: Transform.scale(
                      scale: 1 + (_swipeOffset * 2 / (MediaQuery.of(context).size.height)),
                      child: Text("Swipe Up"),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
