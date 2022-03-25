import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../../../services/size_config.dart';
import '../../services/CountCtl.dart';
import '../../services/api.dart';
import '../../utils/app_utils.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List? cartProducts;

  var totalBv, amount, shippingCharge, total;

  @override
  void initState() {
    _fetchMyCartFromServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('My Cart'),
            SizedBox(height: 5),
            Text(
              (cartProducts != null && cartProducts!.length > 0) ? '${cartProducts!.length} Items' : 'Items',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: (cartProducts != null && cartProducts!.length > 0)
          ? SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _cartTotals(),
                  for (int i = 0; i < cartProducts!.length; i++) cartItem(cartProducts![i], context),
                ],
              ),
            )
          : emptyCartItems(),
      bottomNavigationBar: (cartProducts != null && cartProducts!.length > 0) ? _checkoutSection(context) : SizedBox.shrink(),
    );
  }

  Widget emptyCartItems() {
    return (cartProducts != null && cartProducts!.length == 0)
        ? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/insurance.png',
                  height: 256,
                  width: 256,
                  fit: BoxFit.contain,
                ),
                text(
                  'Your cart is empty!',
                  textColor: colorPrimaryDark,
                  fontFamily: fontBold,
                  fontSize: textSizeLargeMedium,
                  maxLine: 2,
                ),
                SizedBox(height: 5),
                text(
                  'Its a good day to buy the items you saved for later!',
                  isCentered: true,
                  isLongText: true,
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  Widget cartItem(Map product, BuildContext context) {
    return product.isNotEmpty
        ? GestureDetector(
            onTap: () {
              AppUtils.redirect('product-detail', arguments: {"type": "cart", "data": product});
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: boxDecoration(
                radius: 10,
                showShadow: true,
              ),
              height: h(20.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        PNetworkImage(
                          product['imageUrl'],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: text(
                                  product['product']['name'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLine: 2,
                                  fontFamily: fontRegular,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  UniconsLine.trash_alt,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () {
                                  if (num.parse(product['product']['company_stock']) > 0) {
                                    _removeFromCartDialog(product['id']);
                                  } else {
                                    _removeFromCart(product['id']);
                                  }
                                },
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              AppUtils.redirect('product-detail', arguments: {"type": "cart", "data": product});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    text(
                                      '\₹ ${product['dp']}',
                                      textColor: colorPrimary,
                                      fontFamily: fontMedium,
                                      fontSize: 19.0,
                                      fontweight: FontWeight.w600,
                                    ),
                                    SizedBox(width: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: text(
                                        '\₹ ${product['mrp']}',
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          product['outOfStock'] ? _buildOutOfStockProduct(context) : _buildIncrementDecrementWidget(product)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildIncrementDecrementWidget(Map product) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          color: colorPrimary,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: Icon(
                Icons.remove,
                size: 20,
                color: white,
              ),
              onTap: () {
                int updatedQuantity = _setupQuantity(product['selected_qty'], 'subtract');
                if (updatedQuantity > 0) {
                  _addToCart(product['id'], updatedQuantity);
                } else {
                  _removeFromCartDialog(product['id']);
                }
              },
              behavior: HitTestBehavior.opaque,
            ),
            SizedBox(width: 8),
            text(
              '${product['selected_qty']}',
              textColor: white,
            ),
            SizedBox(width: 8),
            GestureDetector(
              child: Icon(
                Icons.add,
                size: 20,
                color: white,
              ),
              onTap: () {
                _addToCart(
                  product['id'],
                  _setupQuantity(product['selected_qty'], 'add'),
                );
              },
              behavior: HitTestBehavior.opaque,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutOfStockProduct(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: red),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            UniconsLine.shopping_cart,
            size: 16,
            color: red,
          ),
          SizedBox(width: 10),
          text(
            'OUT OF STOCK',
            textColor: red,
            textAllCaps: true,
            fontFamily: fontSemibold,
            fontSize: textSizeSMedium,
          ),
        ],
      ),
    );
  }

  Widget _checkoutSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        int outOfStockCount = 0;
        cartProducts!.forEach((product) {
          if (product['outOfStock']) {
            outOfStockCount++;
          }
        });
        if (outOfStockCount > 0) {
          AppUtils.showErrorSnackBar('Your have 1 or more out of stock items in your cart. Please remove it to proceed.');
        } else {
          Get.toNamed('/payments');
          // Get.toNamed('/payments')!.then((value) {
          //   if (value != null && !value) {
          //     _fetchMyCartFromServer();
          //   }
          // });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(color: colorPrimary),
        child: Row(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                text(
                  "CHECKOUT",
                  fontSize: textSizeLargeMedium,
                  fontFamily: fontBold,
                  textColor: white,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: white,
                    size: textSizeMedium,
                  ),
                )
              ],
            ),
            Spacer(),
            text(
              "\₹ $total",
              fontSize: textSizeLargeMedium,
              fontFamily: fontBold,
              textColor: white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartTotals() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text("Sub Total"),
              text(
                "\₹ $amount",
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              text(
                "Total Amount",
                textColor: red,
                fontSize: textSizeLargeMedium,
              ),
              text(
                "\₹ $total",
                textColor: red,
                fontSize: textSizeLargeMedium,
                fontFamily: fontSemibold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _fetchMyCartFromServer() {
    Api.http.get('shopping/cart').then((response) {
      if (response.data['status']) {
        setCartDetails(response);
      } else {
        setState(() {
          cartProducts = [];
        });
      }
    });
  }

  void _addToCart(int productId, int quantity) {
    Api.http.post('shopping/cart/add', data: {
      'product_price_id': productId,
      'qty': quantity,
    }).then((response) {
      if (response.data['status']) {
        // _fetchMyCartFromServer();
        setCartDetails(response);
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }

  void setCartDetails(response) {
    setState(() {
      cartProducts = response.data['cart']['products'];
      MLMCountCtl.to.changeCount(cartProducts!.length);
      if (response.data['cart']['totalDp'] != null) {
        amount = num.parse(response.data['cart']['totalDp'].toString());
      } else {
        amount = num.parse('0');
      }

      if (response.data['cart']['totalShipping'] != null) {
        shippingCharge = num.parse(response.data['cart']['totalShipping'].toString());
      } else {
        shippingCharge = num.parse('0');
      }

      if (response.data['cart']['totalDp'] != null) {
        total = num.parse(response.data['cart']['totalDp'].toString());
      } else {
        total = num.parse('0');
      }
      if (response.data['cart']['totalBv'] != null) {
        totalBv = num.parse(response.data['cart']['totalBv'].toString());
      } else {
        totalBv = num.parse('0');
      }
    });
  }

  void _removeFromCart(int productId) {
    Api.http.post('shopping/cart/remove', data: {'product_price_id': productId}).then((response) {
      if (response.data['status']) {
        _fetchMyCartFromServer();
        MLMCountCtl.to.operation(operationToPerform: "subtract");
      } else {
        AppUtils.showErrorSnackBar(response.data['message']);
      }
    });
  }

  int _setupQuantity(int currentQuantity, String operationToPerform) {
    int updateQuantity;
    if (operationToPerform == 'add') {
      updateQuantity = currentQuantity + 1;
    } else {
      updateQuantity = currentQuantity - 1;
    }
    return updateQuantity;
  }

  void _removeFromCartDialog(int productId) {
    Get.dialog(Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: text(
                  'Are you sure want to remove this item from cart ?',
                  isLongText: true,
                  fontFamily: fontBold,
                  textColor: colorPrimaryDark,
                ),
              ),
              SizedBox(height: 10),
              Divider(
                color: textColorSecondary,
                height: 1,
                thickness: 0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        UniconsLine.multiply,
                        color: red,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    child: VerticalDivider(
                      color: textColorSecondary,
                      width: 1,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _removeFromCart(productId);
                      },
                      child: Icon(
                        UniconsLine.check,
                        color: green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
