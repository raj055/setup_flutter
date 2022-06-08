import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../services/api.dart';
import '../services/translator.dart';
import '../widget/paginated_list.dart';
import '../widget/theme.dart';

class Testimonials extends StatefulWidget {
  @override
  _TestimonialsState createState() => _TestimonialsState();
}

class _TestimonialsState extends State<Testimonials> {
  int? testimonialAddData;

  late SharedPreferences? preferences;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey _refresh = GlobalKey();
  GlobalKey _add = GlobalKey();

  @override
  void initState() {
    displayShowcase();
    super.initState();
  }

  displayShowcase() async {
    preferences = await SharedPreferences.getInstance();
    bool showcaseVisibilityStatus = preferences!.getBool("testimonials");

    if (showcaseVisibilityStatus == null) {
      preferences!.setBool("testimonials", false).then(
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
      pageTitle: Translator.get('Testimonials'),
      apiFuture: (int page) async {
        return Api.http.get("testimonials?page=$page").then((response) {
          if (page == 1) {
            setState(() {
              testimonialAddData = response.data['userTestimonialStatus'];
            });
          }

          return response;
        });
      },
      listItemBuilder: _testimonialsBuilder,
      listItemGetter: (item) {
        item.putIfAbsent('isViewMore', () => false);
        return item;
      },
      floatingActionButton: Visibility(
        visible: testimonialAddData == 3 || testimonialAddData == 1 || testimonialAddData == null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton.extended(
            key: _add,
            onPressed: () {
              if (testimonialAddData == 3 || testimonialAddData == null) {
                Get.toNamed('testimonial-add');
              } else if (testimonialAddData == 1) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
                      contentPadding: EdgeInsets.only(top: 10.0),
                      content: Stack(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height: 20.0,
                                ),
                                Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: new Text(
                                    Translator.get("Approval Pending!")!,
                                    style: TextStyle(fontSize: 30.0, color: Colors.white),
                                  ),
                                ) //
                                    ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    Translator.get(
                                        'Your Request has not been approved by Admin. Wait for Admin response')!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                  width: 5.0,
                                ),
                                Divider(
                                  color: Colors.grey,
                                  height: 4.0,
                                ),
                                InkWell(
                                  child: Container(
                                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(32.0), bottomRight: Radius.circular(32.0)),
                                    ),
                                    child: Text(
                                      Translator.get("OK")!,
                                      style: TextStyle(color: Colors.blue, fontSize: 25.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            label: Text(
              Translator.get('Add +')!.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _testimonialsBuilder(testimonial, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.only(top: 16.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 96.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      text(
                        testimonial['name'],
                        fontFamily: fontBold,
                        textColor: colorPrimaryDark,
                        fontSize: textSizeLargeMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          text(
                            testimonial['message'],
                            maxLine: !testimonial['isViewMore'] ? 2 : null,
                            overflow: !testimonial['isViewMore'] ? TextOverflow.fade : TextOverflow.visible,
                          ),
                          if (testimonial['message'].length > 75)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      testimonial['isViewMore'] = !testimonial['isViewMore'];
                                    });
                                  },
                                  child: Text(
                                    !testimonial['isViewMore'] ? "View More" : "Less",
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: CachedNetworkImageProvider(testimonial['image_url']),
                fit: BoxFit.cover,
              ),
            ),
            margin: EdgeInsets.only(left: 16.0),
          ),
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
                    Translator.get("Click here to refresh screen to get last updated testimonial.")!,
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

    targets.add(
      TargetFocus(
        identify: "Add",
        keyTarget: _add,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Translator.get("Click here to add your testimonial.")!,
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
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 5,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      onClickTarget: (target) {},
      onClickOverlay: (target) {},
      onFinish: () {},
      onSkip: () {},
    )..show();
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
