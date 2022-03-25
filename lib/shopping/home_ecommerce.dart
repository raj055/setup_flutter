import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unicons/unicons.dart';

import '../../../services/CountCtl.dart';
import '../../../services/auth.dart';
import '../../../widget/customWidget.dart';
import '../../../widget/product_widget.dart';
import '../../services/api.dart';
import '../../services/extension.dart';
import '../../services/size_config.dart';
import '../../utils/app_utils.dart';
import '../../widget/theme.dart';
import '../widget/network_image.dart';
import 'account/my_account.dart';
import 'category/category.dart';
import 'filter/filter_page.dart';
import 'order/my_orders.dart';
import 'recharge/recharge_page.dart';

class HomeECommerce extends StatefulWidget {
  @override
  _HomeECommerceState createState() => _HomeECommerceState();
}

class _HomeECommerceState extends State<HomeECommerce> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;

  Future<bool> _onWillPop() {
    if (_selectedIndex == 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: Text('Are you sure?'),
          content: Text(
            'Do you want to exit an App',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: Text('Yes'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _selectedIndex = 0;
      });
    }

    return Future.value(false);
  }

  int _selectedIndex = 0;
  List<Widget> tabPages = [];

  static List<Widget> _widgetOptions = <Widget>[];

  @override
  void initState() {
    _widgetOptions = [
      Ecommerce(
        switchTabCallback: (taskBlockIndex) {
          _onItemTapped(taskBlockIndex!);
        },
      ),
      Category(),
      MyOrders(),
      Recharge(),
      MyAccount(),
    ];
    _pageController = PageController(initialPage: _selectedIndex);

    super.initState();
  }

  void _onItemTapped(int index) {
    if (index == 2 && !Auth.check()!) {
      AppUtils.redirect('/login-mlm', callWhileBack: () {
        Get.offAllNamed('ecommerce');
      });
    } else if (index == 3 && !Auth.check()!) {
      AppUtils.redirect('/login-mlm', callWhileBack: () {
        Get.offAllNamed('ecommerce');
      });
    } else if (index == 4 && !Auth.check()!) {
      AppUtils.redirect('/login-mlm', callWhileBack: () {
        Get.offAllNamed('ecommerce');
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(UniconsLine.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(UniconsLine.apps), label: 'Category'),
            BottomNavigationBarItem(icon: Icon(UniconsLine.shopping_bag), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(UniconsLine.sim_card), label: 'Recharge'),
            BottomNavigationBarItem(icon: Icon(UniconsLine.user), label: 'Account'),
          ],
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontFamily: fontSemibold,
            fontSize: textSizeSMedium,
          ),
          selectedItemColor: colorAccent,
          unselectedItemColor: black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class Ecommerce extends StatefulWidget {
  final Function(
    int? taskBlockIndex,
  )? switchTabCallback;

  Ecommerce({Key? key, this.switchTabCallback}) : super(key: key);

  // const Ecommerce({Key? key}) : super(key: key);

  @override
  _EcommerceState createState() => _EcommerceState();
}

class _EcommerceState extends State<Ecommerce> {
  _EcommerceState() {
    Get.lazyPut(() => MLMCountCtl(cartCount), fenix: true);
  }

  ValueNotifier<Map?> _notifier = ValueNotifier(null);
  SharedPreferences? preferences;
  List categories = [
    {
      "id": 0,
      "name": "Category",
      "prefix": "",
      "url": "",
      "subCategory": [],
    }
  ];
  List categoryData = [];

  List? advertisement = [];
  List? priceStore = [];
  List? bestSeller = [];
  List? trendingNow = [];
  List bestSellersId = [];
  Map? filterData;
  late Map dashboardDetails;
  GlobalKey<_HomeECommerceState> homeKey = GlobalKey();
  // Widget? productWidget;

  late Future _future;
  ScrollController? controller;

  List<Widget> mainWidgetList = [];

  Future<Map> getDashboard() {
    return Api.http.get("shopping/dashboard").then((response) {
      setState(() {
        response.data['list']['bestSeller'].map((seller) {
          bestSellersId.add(seller['id']);
        }).toList();
        Auth.setVendor(isVendor: response.data['isVendor']);
        cartCount = response.data['list']['cartCount'] != null ? response.data['list']['cartCount'] : 0;
      });

      return response.data;
    });
  }

  @override
  void initState() {
    _future = getDashboard();

    // productWidget = getProductWidget();

    super.initState();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  // Widget getProductWidget() {
  //   print("#update");
  //   return ValueListenableBuilder(
  //     valueListenable: _notifier,
  //     builder: (context, value, child) => ProductWidget(
  //       isFilter: false,
  //       productFilters: value as Map,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot? snapshot) {
        if (!snapshot!.hasData) {
          return Center();
        }
        dashboardDetails = snapshot.data['list'];
        categoryData = snapshot.data['list']['categories'];
        if (categories.length == 1) categories.insertAll(1, snapshot.data['list']['categories']);
        advertisement = snapshot.data['list']['advertisementBanner'];
        priceStore = snapshot.data['list']['priceStore'];
        bestSeller = snapshot.data['list']['bestSeller'];
        trendingNow = snapshot.data['list']['trendingNow'];

        categories.map((category) {
          if (category['id'] == 0) {
            category['url'] = dashboardDetails['categoryImage'];
          }
          return category;
        }).toList();

        mainWidgetList = [
          SliverFixedExtentList(
            itemExtent: 80.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return topBarWidget();
              },
              childCount: 1,
            ),
          ),
          SliverAppBar(
            backgroundColor: whiteColor,
            title: searchWidget(),
            pinned: true,
          ),
          SliverFixedExtentList(
            itemExtent: 305.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Column(
                  children: [
                    categoryList(),
                    buildAdvertisement(context),
                  ],
                );
              },
              childCount: 1,
            ),
          ),
          if (bestSeller!.length > 0)
            SliverFixedExtentList(
              itemExtent: 250,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: [
                      buildBestSeller(context),
                    ],
                  );
                },
                childCount: 1,
              ),
            ),
          if (trendingNow!.length > 0)
            SliverFixedExtentList(
              itemExtent: 250,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: [
                      buildTrendingNow(context),
                    ],
                  );
                },
                childCount: 1,
              ),
            ),
          if (priceStore!.length > 0)
            SliverFixedExtentList(
              itemExtent: 170,
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: [
                      buildPrice(context),
                    ],
                  );
                },
                childCount: 1,
              ),
            ),
          SliverAppBar(
            backgroundColor: Color(0xffF5F8FA),
            flexibleSpace: FilterPage(filterData: (data) {
              setState(() {
                filterData = data;
              });
            }),
            pinned: true,
          ),
          SliverFixedExtentList(
            itemExtent: h(78.0),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ProductWidget(
                  isFilter: false,
                  productFilters: filterData,
                );
              },
              childCount: 1,
            ),
          ),
        ];

        return SafeArea(
          child: CustomScrollView(
            slivers: mainWidgetList,
            shrinkWrap: true,
          ),
        );
      },
    );
  }

  Widget topBarWidget() {
    return Container(
      color: whiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: dashboardDetails['profileImage'] != null
                        ? NetworkImage(dashboardDetails['profileImage'])
                        : AssetImage('assets/images/users.png') as ImageProvider,
                    radius: 20,
                  ),
                  onTap: () {
                    setState(() {
                      _future = getDashboard();
                    });
                  },
                ),
                5.width,
                text(
                  dashboardDetails['name'] != "" ? dashboardDetails['name'] : "User",
                  fontFamily: fontMedium,
                  fontSize: textSizeMedium,
                  textColor: black,
                ),
              ],
            ),
          ),
          Row(
            children: [
              buildWishList(context),
              5.width,
              buildNotification(context),
              5.width,
              buildMLMCart(context, isHomePage: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget searchWidget() {
    return Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: TextFormField(
        onTap: () {
          Get.toNamed('search-page');
        },
        readOnly: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search Products",
          hintStyle: TextStyle(
            fontSize: textSizeMedium,
            fontFamily: fontRegular,
            color: textColorSecondary,
          ),
          contentPadding: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
          prefixIcon: Icon(
            UniconsLine.search,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget categoryList() {
    if (categories.length > 0) {
      return SizedBox(
        height: 95,
        child: listviewBuilder(
          _buildCategoryItem,
          items: categories,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          scrollPhysics: const ClampingScrollPhysics(),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildCategoryItem(data, index) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (data['id'] == 0) {
          widget.switchTabCallback!(1);
          // Get.toNamed('/category');
          Category();
        } else {
          Get.toNamed('/sub-category', arguments: data);
        }
      },
      child: Container(
        width: width * 0.25,
        padding: EdgeInsets.symmetric(vertical: 10),
        color: whiteColor,
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: data['url'],
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                ),
                fit: BoxFit.cover,
                height: width * 0.14,
                width: width * 0.14,
              ),
            ),
            2.height,
            text(
              data['name'],
              overflow: TextOverflow.ellipsis,
              fontSize: textSizeSmall,
              isCentered: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAdvertisement(context) {
    var width = MediaQuery.of(context).size.width;
    return (advertisement != null && advertisement!.length > 0)
        ? Stack(
            children: <Widget>[
              Container(
                height: 200,
                width: width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 5.0,
                ),
                color: whiteColor,
                child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: PNetworkImage(
                          advertisement![index]['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  itemCount: advertisement!.length,
                  autoplay: true,
                  autoplayDisableOnInteraction: true,
                  viewportFraction: 1.0,
                  scale: 0.9,
                  pagination: SwiperPagination(),
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }

  Widget buildBestSeller(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: whiteColor,
      ),
      child: SizedBox(
        height: 235.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 2.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  text(
                    'Best Sellers',
                    fontFamily: fontSemibold,
                    fontSize: textSizeLargeMedium,
                  ),
                  text(
                    'View All',
                    fontFamily: fontSemibold,
                    fontSize: textSizeSMedium,
                    textColor: colorAccent,
                    textAllCaps: true,
                  ).onClick(() {
                    Get.toNamed("/best-seller-page", arguments: {
                      "category": bestSellersId,
                      "bestSeller": true,
                    });
                  }),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: bestSeller!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          height: h(20.0),
                          width: w(35.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/boarder.jpg'),
                              fit: BoxFit.cover,
                            ),
                            color: Colors.pink.shade100,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: bestSeller![index]['url'] != null
                              ? PNetworkImage(
                                  bestSeller![index]['url'],
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/no_image.png',
                                  fit: BoxFit.contain,
                                ),
                        ).onClick(() {
                          Get.toNamed("/product-list", arguments: {
                            "category": [bestSeller![index]['categoryId']],
                          });
                        }),
                        10.height,
                        text(
                          bestSeller![index]['name'],
                          fontFamily: fontMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTrendingNow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: whiteColor,
      ),
      child: SizedBox(
        height: 235,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 2.0,
              ),
              child: Row(
                children: [
                  text(
                    'Trending Now',
                    fontFamily: fontSemibold,
                    fontSize: textSizeLargeMedium,
                  ),
                  5.width,
                  Icon(
                    UniconsLine.bolt_alt,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: trendingNow!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: h(20.0),
                          width: w(40.0),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: PNetworkImage(
                              trendingNow![index]['url'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ).onClick(() {
                          Get.toNamed("/trending-list", arguments: trendingNow![index]);
                        }),
                        10.height,
                        text(
                          trendingNow![index]['name'],
                          fontFamily: fontMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPrice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: boxDecoration(
        showShadow: true,
        bgColor: whiteColor,
      ),
      child: SizedBox(
        height: 160,
        width: h(99.99),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: text(
                'Price Store',
                fontFamily: fontSemibold,
                fontSize: textSizeLargeMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: priceStore!.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: h(10.0),
                          width: 90.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                HexColor(dashboardDetails['color1']),
                                HexColor(dashboardDetails['color2']),
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                          child: Center(
                            child: text(
                              priceStore![index]['name'],
                              fontFamily: fontBold,
                            ).onClick(() {
                              Get.toNamed("/product-list", arguments: {
                                'price': [priceStore![index]['id']],
                              });
                            }),
                          ),
                        ),
                      ),
                      text(
                        'Under${priceStore![index]['name']}',
                        fontSize: 14.0,
                        isLongText: true,
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
