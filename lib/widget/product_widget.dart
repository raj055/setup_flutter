import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';
import 'package:unicons/unicons.dart';

import '../../../shopping/filter/filter_page.dart';
import '../../../widget/theme.dart';
import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';
import '../../utils/app_utils.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_grid.dart';

class ProductWidget extends StatefulWidget {
  final productFilters;

  final bool isFilter;

  const ProductWidget({Key? key, this.productFilters, this.isFilter = true}) : super(key: key);

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  GlobalKey<PaginatedGridState> _productPageListKey = GlobalKey();
  Map? previousFilters;
  Map? filterData;

  @override
  void initState() {
    previousFilters = widget.productFilters;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProductWidget oldWidget) {
    if (widget.productFilters != null) {
      _productPageListKey.currentState!.refreshData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (previousFilters != widget.productFilters) {
      _productPageListKey.currentState!.refreshData();
      previousFilters = widget.productFilters;
    }
    return Column(
      children: [
        if (widget.isFilter) ...{
          FilterPage(filterData: (data) {
            print("###data $data");
            setState(() {
              filterData = data;
            });
            _productPageListKey.currentState!.refreshData();
          }),
        },
        Expanded(
          child: PaginatedGrid(
            key: _productPageListKey,
            layoutHeight: 0.57,
            apiFuture: (int page) async {
              print("***sendData ${sendData()}");
              return widget.isFilter
                  ? Api.http.post(
                      'shopping/product?page=$page',
                      data: sendData(),
                    )
                  : Api.httpWithoutLoader.post(
                      'shopping/product?page=$page',
                      data: sendData(),
                    );
            },
            listItemBuilder: gridItemBuilderProductOfferBox,
            resetStateOnRefresh: true,
          ),
        ),
      ],
    );
  }

  refreshData() {
    _productPageListKey.currentState!.refreshData();
  }

  Map<String, dynamic> sendData() {
    print("filterData $filterData");
    print("widget.productFilters ${widget.productFilters}");
    return filterData != null
        ? {
            "sortBy_id": filterData!.containsKey('sort') ? filterData!['sort'] : 0,
            "category_id": filterData!['filter']['categories'].length > 0 ? filterData!['filter']['categories'] : null,
            "gender_id": filterData!['filter']['gender'].length > 0 ? filterData!['filter']['gender'] : null,
            "price_id": filterData!['filter']['price'].length > 0 ? filterData!['filter']['price'] : null,
            "rating_id": filterData!['filter']['ratings'].length > 0 ? filterData!['filter']['ratings'] : null,
            "discount_id": filterData!['filter']['discount'].length > 0 ? filterData!['filter']['discount'] : null,
          }
        : widget.productFilters != null
            ? {
                "sortBy_id": widget.productFilters!.containsKey('sort') ? widget.productFilters!['sort'] : 0,
                "category_id": widget.productFilters!.containsKey('category')
                    ? widget.productFilters!['category']
                    : widget.productFilters!.containsKey('filter')
                        ? widget.productFilters!['filter']['categories']
                        : null,
                "gender_id": widget.productFilters!.containsKey('gender')
                    ? widget.productFilters!['gender']
                    : widget.productFilters!.containsKey('filter')
                        ? widget.productFilters!['filter']['gender']
                        : null,
                "price_id": widget.productFilters!.containsKey('price')
                    ? widget.productFilters!['price']
                    : widget.productFilters!.containsKey('filter')
                        ? widget.productFilters!['filter']['price']
                        : null,
                "rating_id": widget.productFilters!.containsKey('filter')
                    ? (widget.productFilters!['filter']['ratings'].length > 0 ? widget.productFilters!['filter']['ratings'] : null)
                    : null,
                "discount_id": widget.productFilters!.containsKey('filter')
                    ? (widget.productFilters!['filter']['discount'].length > 0 ? widget.productFilters!['filter']['discount'] : null)
                    : null,
              }
            : {
                "sortBy_id": null,
                "category_id": null,
                "gender_id": null,
                "price_id": null,
                "rating_id": null,
                "discount_id": null,
              };
  }

  Widget gridItemBuilderProductOfferBox(itemData, int index) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/product-detail', arguments: {"type": "productList", "data": itemData});
      },
      child: Container(
        width: w(50.0),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        margin: const EdgeInsets.only(bottom: 1.0),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? Radius.circular(10) : Radius.circular(0),
            topRight: index == 1 ? Radius.circular(10) : Radius.circular(0),
            bottomLeft: index == 2 ? Radius.circular(10) : Radius.circular(0),
            bottomRight: index == 3 ? Radius.circular(10) : Radius.circular(0),
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: <Widget>[
                PNetworkImage(
                  itemData['url'],
                  fit: BoxFit.cover,
                  height: h(25),
                  width: w(90),
                ),
                SizedBox(height: 5),
                Positioned(
                  top: 5,
                  right: 5,
                  child: LikeButton(
                    size: 25,
                    isLiked: itemData!['wishList']['inWishList'],
                    onTap: (bool isLiked) async {
                      bool isStatus = false;
                      if (Auth.check()!) {
                        if (isLiked) {
                          await Api.http.delete('shopping/wishlist/delete/${itemData['id']}').then((response) {
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
                            "product_id": itemData['id'],
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
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: text(
                            itemData['name'],
                            fontSize: textSizeSmall,
                          ),
                          flex: 8,
                        ),
                        Expanded(
                          flex: 2,
                          child: IconButton(
                            constraints: BoxConstraints(),
                            onPressed: () {
                              Share.share(itemData!['shareUrl']);
                            },
                            icon: Icon(UniconsLine.share_alt),
                            iconSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        text(
                          '\र ${itemData!['dp']}',
                          fontFamily: fontSemibold,
                        ),
                        10.width,
                        Row(
                          children: [
                            text(
                              '\र ${itemData!['mrp']}',
                              decoration: TextDecoration.lineThrough,
                              textColor: Colors.grey,
                              fontSize: textSizeSMedium,
                            ),
                            5.width,
                            text(
                              '${itemData!['discount']}% off',
                              textColor: greenColor,
                              fontFamily: fontMedium,
                              fontSize: textSizeSMedium,
                            ),
                          ],
                        )
                      ],
                    ),
                    2.height,
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/discount.png',
                          width: 16,
                        ),
                        5.width,
                        text(
                          '\र ${itemData!['discountAmount']} Discount',
                          fontSize: textSizeSMedium,
                          fontFamily: fontRegular,
                        ),
                      ],
                    ),
                    8.height,
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 7.0),
                          child: Row(
                            children: [
                              text(
                                double.parse(itemData!['averageRating'].toString()).toStringAsFixed(1),
                                textColor: Colors.white,
                                fontFamily: fontSemibold,
                                fontSize: textSizeSmall,
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
                        ),
                        10.width,
                        text(
                          '${itemData!['ratingCount']} Ratings',
                          fontFamily: fontMedium,
                          textColor: grey,
                          fontSize: textSizeSmall,
                        ),
                      ],
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
