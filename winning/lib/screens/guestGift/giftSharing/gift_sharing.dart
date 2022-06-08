import 'package:flutter/material.dart';

import '../../../screens/guestGift/giftSharing/audio_sharing.dart';
import '../../../screens/guestGift/giftSharing/ebook_sharing.dart';
import '../../../screens/guestGift/giftSharing/video_sharing.dart';
import '../../../services/translator.dart';
import '../../../widget/theme.dart';

class GiftSharing extends StatefulWidget {
  @override
  _GiftSharingState createState() => _GiftSharingState();
}

class _GiftSharingState extends State<GiftSharing> with SingleTickerProviderStateMixin {
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
        title: Text(Translator.get("Guest Sharing")!),
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
                Translator.get("Audio Gift"),
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
          VideoGiftSharing(),
          AudioGiftSharing(),
          EBookGiftSharing(),
        ],
      ),
    );
  }
}
