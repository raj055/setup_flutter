import 'package:flutter/material.dart';

import '../../screens/guestGift/audio_gift.dart';
import '../../screens/guestGift/ebook_gift.dart';
import '../../screens/guestGift/video_gift.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class GuestGift extends StatefulWidget {
  @override
  _GuestGiftState createState() => _GuestGiftState();
}

class _GuestGiftState extends State<GuestGift> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guest Gift'),
        bottom: TabBar(
          onTap: (index) {},
          labelStyle: primaryTextStyle(),
          indicatorColor: colorPrimary,
          physics: BouncingScrollPhysics(),
          labelColor: white,
          controller: _tabController,
          tabs: [
            Tab(
              child: text(
                Translator.get("Video Gift"),
                textColor: white,
                fontFamily: fontMedium,
              ),
            ),
            Tab(
              child: text(
                Translator.get('Audio Gift'),
                textColor: white,
                fontFamily: fontMedium,
              ),
            ),
            Tab(
              child: text(
                Translator.get("EBook Gift"),
                textColor: white,
                fontFamily: fontMedium,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          VideoGift(),
          AudioGift(),
          EBookGift(),
        ],
      ),
    );
  }
}
