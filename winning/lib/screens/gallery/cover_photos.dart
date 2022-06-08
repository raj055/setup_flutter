import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/api.dart';
import '../../services/size_config.dart';
import '../../services/translator.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class GalleryView extends StatefulWidget {
  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late SharedPreferences preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _refresh = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences.getBool("gallery");

    if (showcaseVisibilityStatus == null) {
      preferences.setBool("gallery", false).then(
        (bool success) {
          initTargets();
          Future.delayed(
            Duration(milliseconds: 500),
            () {
              showTutorial();
            },
          );
        },
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('Gallery'),
      apiFuture: (int page) async {
        return Api.http.get("photo-gallery?page=$page");
      },
      listItemBuilder: _galleryBuilder,
    );
  }

  Widget _galleryBuilder(dynamic gallery, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () {
              if (gallery['sub_image_urls'].length > 0)
                Get.toNamed('gallery-photos', arguments: gallery['sub_image_urls']);
              // Get.toNamed('gallery-photos', arguments: gallery['id']);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            gallery['cover_image_url'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: h(30),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                        child: text(
                          gallery['title'],
                          textColor: white,
                          overflow: TextOverflow.ellipsis,
                          fontFamily: fontSemibold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void initTargets() {
    targets.add(
      TargetFocus(
        identify: "Refresh",
        keyTarget: _refresh,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("Click here to refresh your screen to get latest picture uploaded here.")!,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 15.0,
      ),
    );
  }

  void showTutorial() {
    TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.black,
        paddingFocus: 5,
        opacityShadow: 0.8,
        textSkip: "SKIP",
        onClickTarget: (target) {},
        onClickOverlay: (target) {},
        onFinish: () {},
        onSkip: () {})
      ..show();
  }

  void _afterLayout(_) {
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        showTutorial();
      },
    );
  }
}
