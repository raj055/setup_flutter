import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share/share.dart';
import 'package:unicons/unicons.dart';

import '../../../services/api.dart';
import '../../../services/auth.dart';
import '../../../utils/app_utils.dart';
import '../../../widget/customWidget.dart';
import '../../../widget/network_image.dart';
import '../../../widget/theme.dart';
import '../../services/CountCtl.dart';

class ProductDetail extends StatefulWidget {
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Map? product;
  Map? productData;
  List? images;

  List? reviewData;

  Future? productFuture;

  num? dp;
  num? mrp;
  num? discount;
  num? discountAmount;

  String? productName;
  bool outOfStock = false;
  int? productId;

  void initState() {
    product = Get.arguments;
    if (product!['type'] == 'cart') {
      productId = product!['data']['product']['id'];
      productName = product!['data']['product']['name'];
    } else if (product!['type'] == 'wishlist') {
      productId = product!['data']['productId'];
      productName = product!['data']['name'];
    } else {
      productId = product!['data']['id'];
      productName = product!['data']['name'];
    }

    productFuture = getData();
    super.initState();
  }

  _ProductDetailState() {
    Get.lazyPut(() => MLMCountCtl(cartCount), fenix: true);
  }

  int? productVariationId;

  Future<Map> getData() {
    return Api.http.get("shopping/product/show/$productId").then((response) {
      if (response.data['status']) {
        setState(() {
          productData = response.data['products'];
          dp = productData!['dp'];
          mrp = productData!['mrp'];
          discount = productData!['discount'];
          discountAmount = productData!['discountAmount'];

          productData!['variation'].map((variation) {
            variation.putIfAbsent('isSelected', () => false);
          }).toList();
        });
      }

      return response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName ?? ""),
        actions: [
          IconButton(
            constraints: BoxConstraints(maxWidth: 35),
            onPressed: () {
              Get.toNamed('/search-page');
            },
            icon: Icon(UniconsLine.search),
          ),
          SizedBox(width: 10.0),
          buildWishList(context),
          SizedBox(width: 10.0),
          buildMLMCart(context),
        ],
      ),
      body: FutureBuilder(
        future: productFuture,
        builder: (context, AsyncSnapshot? snapshot) {
          if (!snapshot!.hasData) {
            return Center();
          }

          if (productData != null) {
            images = snapshot.data['products']['images'];
          }

          return (snapshot.data['status'])
              ? _buildPageContent(context)
              : Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset("assets/images/results.png"),
                      SizedBox(height: 20),
                      text("No Product Found", fontSize: textSizeLarge),
                    ],
                  ),
                );
        },
      ),
      bottomNavigationBar: productData != null ? _buildProductBuyCard(context) : SizedBox.shrink(),
    );
  }

  Widget _buildPageContent(context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildProductSliderCard(context),
          _buildProductDetailsCard(context),
          _buildProductVariationCard(context),
          if (productData!['description'] != null) _buildProductDescriptionCard(context),
          _buildProductReviewsCard(context),
          20.height,
        ],
      ),
    );
  }

  Widget _buildProductSliderCard(context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: boxDecoration(
            showShadow: true,
            bgColor: whiteColor,
          ),
          height: 300.0,
          width: double.infinity,
          child: images!.length > 0
              ? Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return CachedNetworkImage(
                      imageUrl: images![index]['fileName'],
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.contain,
                      ),
                      fit: BoxFit.contain,
                      // width:  100,
                      // height: 100,
                    );
                  },
                  itemCount: images!.length,
                  pagination: new SwiperPagination(),
                )
              : PNetworkImage(
                  productData!['mainImage'],
                  fit: BoxFit.contain,
                  errorFit: BoxFit.cover,
                ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsCard(context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: boxDecoration(
        radius: 0,
        showShadow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: text(
                  productData!['name'],
                  textColor: colorPrimaryDark,
                  fontSize: textSizeLargeMedium,
                  fontFamily: fontSemibold,
                  isLongText: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: text(
                  "Product code: ${productData!['sku']}",
                  fontSize: 12.0,
                  isLongText: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              text(
                '\₹ $dp',
                textColor: colorPrimary,
                fontFamily: fontMedium,
                fontSize: 19.0,
                fontweight: FontWeight.w600,
              ),
              SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    text(
                      '\₹ $mrp',
                      decoration: TextDecoration.lineThrough,
                      fontSize: 13.0,
                    ),
                    SizedBox(width: 5),
                    text(
                      '$discount% off',
                      textColor: colorAccent,
                      fontFamily: fontMedium,
                      fontSize: 14.0,
                      fontweight: FontWeight.w600,
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              text(
                '\₹ $discountAmount discount',
                fontSize: 12.0,
                fontFamily: fontSemibold,
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Container(
                child: Row(
                  children: [
                    text(
                      double.parse(productData!['averageRating'].toString()).toStringAsFixed(1),
                      textColor: Colors.white,
                      fontweight: FontWeight.w600,
                      fontSize: 13.0,
                    ),
                    SizedBox(width: 2.0),
                    Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
              ),
              SizedBox(width: 10.0),
              text(
                '${productData!['ratingCount']} Ratings',
                fontSize: 12.0,
                fontFamily: fontSemibold,
              ),
            ],
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildProductVariationCard(context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: boxDecoration(
        radius: 0,
        showShadow: true,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: text(
              "Select Variation",
              fontFamily: fontSemibold,
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              children: [
                for (int i = 0; i < productData!['variation'].length; i++)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ChoiceChip(
                      backgroundColor: Colors.white,
                      elevation: 5.0,
                      label: text(
                        productData!['variation'][i]['variationDetail']['name'],
                        isCentered: true,
                        isLongText: true,
                        fontSize: 15.0,
                        textColor: productData!['variation'][i]['isSelected'] ? Colors.white : Colors.black,
                      ),
                      selected: true,
                      selectedColor: productData!['variation'][i]['isSelected'] ? colorPrimary : null,
                      onSelected: (bool selected) {
                        setState(() {
                          productData!['variation'].map((variation) {
                            if (productData!['variation'][i]['id'] == variation['id']) {
                              variation['isSelected'] = true;
                              productData!['variation'][i]['isSelected'] = true;
                              productVariationId = productData!['variation'][i]['id'];
                              dp = productData!['variation'][i]['dp'];
                              mrp = productData!['variation'][i]['mrp'];
                              discount = productData!['variation'][i]['discount'];
                              discountAmount = productData!['variation'][i]['discountAmount'];
                              outOfStock = productData!['variation'][i]['outOfStock'];
                            } else {
                              variation['isSelected'] = false;
                            }
                          }).toList();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDescriptionCard(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: boxDecoration(
        radius: 0,
        showShadow: true,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: text(
              "Product Details",
              fontFamily: fontSemibold,
            ),
          ),
          SizedBox(height: 5.0),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10), child: Html(data: productData!['description'])),
        ],
      ),
    );
  }

  Widget _buildProductReviewsCard(context) {
    num? rating;

    rating = double.parse(productData!['averageRating'].toString()).toDouble();

    return Container(
      decoration: boxDecoration(
        radius: 0,
        showShadow: true,
      ),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: text(
              "Product Rating & Reviews",
              fontFamily: fontSemibold,
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            height: 140.0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          text(
                            rating.toStringAsFixed(1).toString(),
                            fontSize: 40.0,
                            fontweight: FontWeight.w600,
                            fontFamily: fontSemibold,
                            textColor: colorAccent,
                          ),
                          Icon(
                            Icons.star,
                            color: colorAccent,
                            size: 24,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      text(
                        "${productData!['ratingCount'].toString()}  Ratings",
                        fontSize: 15.0,
                        fontFamily: fontSemibold,
                        textColor: Colors.grey,
                      ),
                      SizedBox(height: 2),
                      text(
                        "${productData!['reviewCount'].toString()}  Reviews",
                        fontSize: 15.0,
                        fontFamily: fontSemibold,
                        textColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: ListView.builder(
                    itemCount: productData!['rating'].length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            text(
                              productData!['rating'][index]['name'].toString(),
                              fontSize: 16.0,
                              fontFamily: fontSemibold,
                              textColor: colorPrimaryDark,
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: LinearPercentIndicator(
                                lineHeight: 7.0,
                                percent: productData!['rating'][index]['ratingCount'] / 100,
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                progressColor: Colors.red,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            text(
                              productData!['rating'][index]['ratingCount'].toString(),
                              fontSize: 16.0,
                              fontweight: FontWeight.w600,
                              fontFamily: fontSemibold,
                              textColor: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 2),
          if (productData!['review'].length > 0) ...[
            Container(
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: productData!['review'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18.0,
                                    backgroundImage: NetworkImage(
                                      productData!['review'][index]['profileImage'],
                                    ),
                                  ),
                                  SizedBox(width: 20.0),
                                  text(
                                    productData!['review'][index]['name'],
                                    fontFamily: fontMedium,
                                  )
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        text(
                                          productData!['review'][index]['rating'].toString(),
                                          textColor: Colors.white,
                                          fontweight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                        SizedBox(width: 2.0),
                                        Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorPrimary,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
                                  ),
                                  SizedBox(width: 20.0),
                                  Expanded(
                                    child: text(
                                      productData!['review'][index]['review'],
                                      isLongText: true,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Row(
                children: [
                  text(
                    'View All Reviews',
                    textAllCaps: true,
                    textColor: colorAccent,
                    fontweight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                  SizedBox(width: 10.0),
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: colorAccent,
                  ),
                ],
              ).onTap(() {
                Get.toNamed('review-list', arguments: productData!['id']);
              }),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildProductBuyCard(context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                LikeButton(
                  size: 25,
                  isLiked: productData!['wishList']['inWishList'],
                  onTap: (bool isLiked) async {
                    bool isStatus = false;
                    if (Auth.check()!) {
                      if (isLiked) {
                        await Api.http.delete('shopping/wishlist/delete/${productData!['id']}').then((response) {
                          if (response.data['status']) {
                            isStatus = response.data['status'];
                          } else {
                            GetBar(
                              message: response.data['message'],
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.red,
                            ).show();
                          }
                        }).catchError((err) {
                          GetBar(
                            message: err.response.data['message'],
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                          ).show();
                        });
                      } else {
                        await Api.http.post('shopping/wishlist/store', data: {
                          "product_id": productData!['id'],
                        }).then((response) {
                          isStatus = response.data['status'];
                        }).catchError((err) {
                          if (err.response.statusCode == 401) {
                            Get.offNamed('/login-mlm');
                          } else {
                            AppUtils.showErrorSnackBar(err.response.data['message']);
                          }
                        });
                      }
                      // getData();
                    } else {
                      AppUtils.redirect('login-mlm', callWhileBack: () {
                        setState(() {});
                      });
                    }
                    return isStatus ? !isLiked : isLiked;
                  },
                ),
                SizedBox(height: 2.0),
                text(
                  'Wishlist',
                  fontFamily: fontLight,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: GestureDetector(
              onTap: () {
                Share.share(productData!['shareUrl']);
              },
              child: Column(
                children: [
                  Icon(
                    UniconsLine.share_alt,
                    size: 25,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 2.0),
                  text(
                    'Share',
                    fontFamily: fontLight,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (Auth.check()!) {
                if (outOfStock == false) {
                  _addProductToCart();
                }
              } else {
                AppUtils.redirect('login-mlm', callWhileBack: () {
                  setState(() {});
                });
              }
            },
            child: Container(
              height: 50,
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: outOfStock ? Colors.red : colorPrimary,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                outOfStock ? 'Out Of Stock' : 'Add to Cart',
                style: boldTextStyle(color: white_color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addProductToCart() {
    if (productVariationId != null) {
      Api.http.post('shopping/cart/add', data: {
        'product_price_id': productVariationId,
        'qty': 1,
      }).then((response) {
        if (response.data['status']) {
          AppUtils.showSuccessSnackBar('Added to cart successfully');
          MLMCountCtl.to.operation(operationToPerform: "add");
          Future.delayed(Duration(seconds: 1), () {
            AppUtils.redirect('/cart', callWhileBack: () {
              setState(() {});
            });
          });
        } else {
          AppUtils.showErrorSnackBar(response.data['message']);
        }
      });
    } else {
      AppUtils.showErrorSnackBar('First select the variation');
    }
  }
}
