import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:prokit_flutter/food/model/FoodModel.dart';
import 'package:prokit_flutter/food/utils/FlutterSlider.dart';
import 'package:prokit_flutter/food/utils/FoodColors.dart';
import 'package:prokit_flutter/food/utils/FoodDataGenerator.dart';
import 'package:prokit_flutter/food/utils/FoodString.dart';
import 'package:prokit_flutter/food/utils/FoodWidget.dart';
import 'package:prokit_flutter/main/utils/AppWidget.dart';

import 'FoodBookDetail.dart';
import 'FoodRestaurantsDescription.dart';

class FoodViewRestaurants extends StatefulWidget {
  static String tag = '/FoodViewRestaurants';

  @override
  FoodViewRestaurantsState createState() => FoodViewRestaurantsState();
}

class FoodViewRestaurantsState extends State<FoodViewRestaurants> {
  List<ViewRestaurants> mList;
  List<images> mList1;
  List<Filter> mList2;
  var mPeopleList, mCuisine, mFilterList;
  var mTime = 0;

  @override
  void initState() {
    mList = addViewRestaurantsData();
    mList1 = addViewImagesData();
    mPeopleList = ["1", "2", "3", "4", "5"];
    mFilterList = [
      "Pure Veg Places",
      "Express Delivery",
      "Great Offer",
    ];
    mCuisine = [
      "South Indian",
      "American",
      "BBQ",
      "Bakery",
      "Biryani",
      "Burger",
      "Cafe",
      "Charcoal Chicken",
      "Chiness",
      "Fast Food",
      "Juice",
      "Gujarati",
      "Salad",
    ];
  }

  @override
  Widget build(BuildContext context) {
    //changeStatusColor(food_app_background);

    double lowerValue = 100;
    double upperValue = 1000;

    Widget mFilter() {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), color: food_white),
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 24),
                      Text(food_lbl_by_price, style: primaryTextStyle()),
                      FlutterSlider(
                        values: [30, 420],
                        rangeSlider: true,
                        max: 500,
                        min: 0,
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          lowerValue = lowerValue;
                          upperValue = upperValue;
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 16),
                      Text(food_lbl_cuisine, style: primaryTextStyle()),
                      SizedBox(height: 16),
                      Tags(
                        itemCount: mCuisine.length,
                        spacing: 16,
                        alignment: WrapAlignment.start,
                        itemBuilder: (int index) {
                          return Tooltip(
                            textStyle: primaryTextStyle(size: 16),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: food_colorPrimary),
                            padding: EdgeInsets.all(8),
                            message: mCuisine[index],
                            child: ItemTags(
                              title: mCuisine[index],
                              activeColor: food_colorPrimary_light,
                              color: food_colorPrimary,
                              textColor: food_white,
                              textActiveColor: food_textColorPrimary,
                              padding: EdgeInsets.all(8),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              highlightColor: food_colorAccent,
                              index: index,
                              onPressed: (item) {
                                setState(() {});
                              }, // equired
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      Text(food_lbl_rating, style: primaryTextStyle()),
                      SizedBox(height: 16),
                      GridView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: mPeopleList.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                mTime = index;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: mTime == index ? food_colorPrimary : food_view_color),
                              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                mPeopleList[index],
                                style: primaryTextStyle(color: mTime == index ? food_white : food_textColorPrimary),
                              ).center(),
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.0),
                      ),
                      SizedBox(height: 16),
                      Text(food_lbl_more_filter, style: primaryTextStyle()),
                      SizedBox(height: 16),
                      Tags(
                        itemCount: mFilterList.length,
                        spacing: 10,
                        alignment: WrapAlignment.start,
                        itemBuilder: (int index) {
                          return Tooltip(
                            textStyle: TextStyle(fontSize: 16),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: food_colorPrimary, boxShadow: defaultBoxShadow()),
                            padding: EdgeInsets.all(8),
                            message: mFilterList[index],
                            child: ItemTags(
                                title: mFilterList[index],
                                color: food_colorPrimary,
                                textColor: food_white,
                                activeColor: food_colorPrimary_light,
                                textActiveColor: food_textColorPrimary,
                                padding: EdgeInsets.all(8),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                highlightColor: food_colorAccent,
                                index: index,
                                onPressed: (item) {
                                  setState(() {});
                                } // required
                                ),
                          );
                        },
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                finish(context);
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                decoration: BoxDecoration(border: Border.all(color: food_textColorPrimary), borderRadius: BorderRadius.circular(50)),
                                child: Text(food_lbl_cancel, style: primaryTextStyle()).center(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                finish(context);
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                decoration: BoxDecoration(color: food_colorPrimary, borderRadius: BorderRadius.circular(50)),
                                child: Text(food_lbl_filter, style: primaryTextStyle(color: food_white)).center(),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: food_app_background,
      appBar: appBar(
        context,
        '',
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              mFilter();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(boxShadow: defaultBoxShadow(), color: white),
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(food_lbl_lunch_in_delhi_ncr, style: boldTextStyle(size: 20)),
                          SizedBox(height: 4),
                          mAddress(context),
                          SizedBox(height: 16),
                          search(context),
                        ],
                      ),
                    ),
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: mList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return RestaurantsInfo(mList[index], mList1[index], index);
                      },
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

// ignore: must_be_immutable
class RestaurantsInfo extends StatelessWidget {
  ViewRestaurants model;
  images model1;

  RestaurantsInfo(ViewRestaurants model, images model1, int pos) {
    this.model = model;
    this.model1 = model1;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FoodRestaurantsDescription().launch(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(boxShadow: defaultBoxShadow(), color: white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              placeholder: placeholderWidgetFn(),
              imageUrl: model1.image,
              width: width,
              height: 250,
              fit: BoxFit.fill,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(model.name, style: primaryTextStyle(size: 18)),
                  SizedBox(height: 4),
                  Row(children: <Widget>[
                    mRating(model.rating),
                    SizedBox(width: 4),
                    Text(model.review, style: primaryTextStyle(color: food_textColorSecondary)),
                  ]),
                  SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text(model.rs, style: primaryTextStyle(color: food_textColorSecondary)),
                      SizedBox(width: 4),
                      Container(decoration: BoxDecoration(shape: BoxShape.circle, color: food_view_color), width: 8, height: 8),
                      SizedBox(width: 4),
                      Text(model.sector, style: primaryTextStyle(color: food_textColorSecondary)),
                      SizedBox(width: 4),
                      Container(decoration: BoxDecoration(shape: BoxShape.circle, color: food_view_color), width: 8, height: 8),
                      SizedBox(width: 4),
                      Text(model.kms, style: primaryTextStyle(color: food_textColorSecondary)),
                    ],
                  ),
                  Container(margin: EdgeInsets.only(top: 16), height: 0.5, color: food_view_color, width: width),
                ],
              ),
            ),
            mViewAll(context, food_lbl_book_a_table, onTap: () {
              FoodBookDetail().launch(context);
            }),
          ],
        ),
      ),
    );
  }
}
