// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
//
// const bool _kAutoConsume = true;
//
// const String _kConsumableId = 'consumable';
// const String _kUpgradeId = 'upgrade';
// const String _kSilverSubscriptionId = 'subscription_silver';
// const String _kGoldSubscriptionId = 'subscription_gold';
// const String _kNonRenewSubscriptionId = 'test_id';
// const List<String> _kProductIds = <String>[
//   _kConsumableId,
//   _kUpgradeId,
//   _kSilverSubscriptionId,
//   _kGoldSubscriptionId,
//   _kNonRenewSubscriptionId,
// ];
//
// class Test extends StatefulWidget {
//   @override
//   _TestState createState() => _TestState();
// }
//
// class _TestState extends State<Test> {
//   StreamSubscription<List<PurchaseDetails>> _subscription;
//
//   final _inAppPurchase = InAppPurchaseConnection.instance;
//   // StreamSubscription<List<PurchaseDetails>> _subscription;
//   List<String> _notFoundIds = [];
//   List<ProductDetails> _products = [];
//   List<PurchaseDetails> _purchases = [];
//   List<String> _consumables = [];
//   bool _isAvailable = false;
//   bool _purchasePending = false;
//   bool _loading = true;
//   String _queryProductError;
//
//   void initState() {
//     final Stream purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;
//     _subscription = purchaseUpdated.listen((purchaseDetailsList) {
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       print('onDone ');
//       _subscription.cancel();
//     }, onError: (error) {
//       print('error $error');
//       // handle error here.
//     });
//     initStoreInfo();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         // _showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           // _handleError(purchaseDetails.error!);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//           bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             print('valid');
//             // _deliverProduct(purchaseDetails);
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         }
//         if (purchaseDetails.pendingCompletePurchase) {
//           await InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
//         }
//       }
//     });
//   }
//
//   Future<void> initStoreInfo() async {
//     final bool isAvailable = await _inAppPurchase.isAvailable();
//     if (!isAvailable) {
//       setState(() {
//         _isAvailable = isAvailable;
//         _products = [];
//         _purchases = [];
//         _notFoundIds = [];
//         _consumables = [];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
//     if (productDetailResponse.error != null) {
//       setState(() {
//         _queryProductError = productDetailResponse.error.message;
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = [];
//         _notFoundIds = productDetailResponse.notFoundIDs;
//         _consumables = [];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     if (productDetailResponse.productDetails.isEmpty) {
//       setState(() {
//         _queryProductError = null;
//         _isAvailable = isAvailable;
//         _products = productDetailResponse.productDetails;
//         _purchases = [];
//         _notFoundIds = productDetailResponse.notFoundIDs;
//         _consumables = [];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     // await _inAppPurchase.restorePurchases();
//
//     // List<String> consumables = await ConsumableStore.load();
//     // List<String> consumables = await ConsumableStore.load();
//     setState(() {
//       _isAvailable = isAvailable;
//       _products = productDetailResponse.productDetails;
//       _notFoundIds = productDetailResponse.notFoundIDs;
//       // _consumables = consumables;
//       _purchasePending = false;
//       _loading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> stack = [];
//     if (_queryProductError == null) {
//       stack.add(
//         ListView(
//           children: [
//             _buildConnectionCheckTile(),
//             _buildProductList(),
//             _buildConsumableBox(),
//           ],
//         ),
//       );
//     } else {
//       stack.add(Center(
//         child: Text(_queryProductError),
//       ));
//     }
//     if (_purchasePending) {
//       stack.add(
//         Stack(
//           children: [
//             Opacity(
//               opacity: 0.3,
//               child: const ModalBarrier(dismissible: false, color: Colors.grey),
//             ),
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('IAP Example'),
//         ),
//         body: Stack(
//           children: stack,
//         ),
//       ),
//     );
//   }
//
//   Card _buildConnectionCheckTile() {
//     if (_loading) {
//       return Card(child: ListTile(title: const Text('Trying to connect...')));
//     }
//     final Widget storeHeader = ListTile(
//       leading: Icon(_isAvailable ? Icons.check : Icons.block, color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
//       title: Text('The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
//     );
//     final List<Widget> children = <Widget>[storeHeader];
//
//     if (!_isAvailable) {
//       children.addAll([
//         Divider(),
//         ListTile(
//           title: Text('Not connected', style: TextStyle(color: ThemeData.light().errorColor)),
//           subtitle: const Text('Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
//         ),
//       ]);
//     }
//     return Card(child: Column(children: children));
//   }
//
//   Card _buildProductList() {
//     if (_loading) {
//       return Card(child: (ListTile(leading: CircularProgressIndicator(), title: Text('Fetching products...'))));
//     }
//     if (!_isAvailable) {
//       return Card();
//     }
//     final ListTile productHeader = ListTile(title: Text('Products for Sale'));
//     List<ListTile> productList = <ListTile>[];
//     if (_notFoundIds.isNotEmpty) {
//       productList.add(ListTile(
//           title: Text('[${_notFoundIds.join(", ")}] not found', style: TextStyle(color: ThemeData.light().errorColor)),
//           subtitle: Text('This app needs special configuration to run. Please see example/README.md for instructions.')));
//     }
//
//     // This loading previous purchases code is just a demo. Please do not use this as it is.
//     // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
//     // We recommend that you use your own server to verify the purchase data.
//     Map<String, PurchaseDetails> purchases = Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
//       if (purchase.pendingCompletePurchase) {
//         _inAppPurchase.completePurchase(purchase);
//       }
//       return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//     }));
//     productList.addAll(_products.map(
//       (ProductDetails productDetails) {
//         PurchaseDetails previousPurchase = purchases[productDetails.id];
//         return ListTile(
//             title: Text(
//               productDetails.title,
//             ),
//             subtitle: Text(
//               productDetails.description,
//             ),
//             trailing: previousPurchase != null
//                 ? Icon(Icons.check)
//                 : TextButton(
//                     child: Text(productDetails.price),
//                     style: TextButton.styleFrom(
//                       backgroundColor: Colors.green[800],
//                       primary: Colors.white,
//                     ),
//                     onPressed: () {
//                       PurchaseParam purchaseParam;
//
//                       // if (Platform.isAndroid) {
//                       //   // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
//                       //   // verify the latest status of you your subscription by using server side receipt validation
//                       //   // and update the UI accordingly. The subscription purchase status shown
//                       //   // inside the app may not be accurate.
//                       //   final oldSubscription =
//                       //   _getOldSubscription(productDetails, purchases);
//                       //
//                       //   purchaseParam = GooglePlayPurchaseParam(
//                       //       productDetails: productDetails,
//                       //       applicationUserName: null,
//                       //       changeSubscriptionParam: (oldSubscription != null)
//                       //           ? ChangeSubscriptionParam(
//                       //         oldPurchaseDetails: oldSubscription,
//                       //         prorationMode: ProrationMode
//                       //             .immediateWithTimeProration,
//                       //       )
//                       //           : null);
//                       // } else {
//                       purchaseParam = PurchaseParam(
//                         productDetails: productDetails,
//                         applicationUserName: null,
//                       );
//                       // }
//
//                       // if (productDetails.id == _kConsumableId) {
//                       //   _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: _kAutoConsume || Platform.isIOS);
//                       // } else {
//                       _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//                       // _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//                       // }
//                     },
//                   ));
//       },
//     ));
//
//     return Card(child: Column(children: <Widget>[productHeader, Divider()] + productList));
//   }
//
//   Card _buildConsumableBox() {
//     if (_loading) {
//       return Card(
//         child: ListTile(
//           leading: CircularProgressIndicator(),
//           title: Text('Fetching consumables...'),
//         ),
//       );
//     }
//     if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
//       return Card();
//     }
//     final ListTile consumableHeader = ListTile(title: Text('Purchased consumables'));
//     final List<Widget> tokens = _consumables.map((String id) {
//       return GridTile(
//         child: IconButton(
//           icon: Icon(
//             Icons.stars,
//             size: 42.0,
//             color: Colors.orange,
//           ),
//           splashColor: Colors.yellowAccent,
//           onPressed: () => consume(id),
//         ),
//       );
//     }).toList();
//     return Card(
//         child: Column(children: <Widget>[
//       consumableHeader,
//       Divider(),
//       GridView.count(
//         crossAxisCount: 5,
//         children: tokens,
//         shrinkWrap: true,
//         padding: EdgeInsets.all(16.0),
//       )
//     ]));
//   }
//
//   Future<void> consume(String id) async {
//     // await ConsumableStore.consume(id);
//     // final List<String> consumables = await ConsumableStore.load();
//     setState(() {
//       // _consumables = consumables;
//     });
//   }
//
//   void showPendingUI() {
//     setState(() {
//       _purchasePending = true;
//     });
//   }
//
//   void deliverProduct(PurchaseDetails purchaseDetails) async {
//     // IMPORTANT!! Always verify purchase details before delivering the product.
//     if (purchaseDetails.productID == _kConsumableId) {
//       // await ConsumableStore.save(purchaseDetails.purchaseID);
//       // List<String> consumables = await ConsumableStore.load();
//       setState(() {
//         _purchasePending = false;
//         // _consumables = consumables;
//       });
//     } else {
//       setState(() {
//         _purchases.add(purchaseDetails);
//         _purchasePending = false;
//       });
//     }
//   }
//
//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//     });
//   }
//
//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
//     // IMPORTANT!! Always verify a purchase before delivering the product.
//     // For the purpose of an example, we directly return true.
//     return Future<bool>.value(true);
//   }
//
//   void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
//     // handle invalid purchase here if  _verifyPurchase` failed.
//   }
//
//   // void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//   //   purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
//   //     if (purchaseDetails.status == PurchaseStatus.pending) {
//   //       showPendingUI();
//   //     } else {
//   //       if (purchaseDetails.status == PurchaseStatus.error) {
//   //         handleError(purchaseDetails.error);
//   //       } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//   //         bool valid = await _verifyPurchase(purchaseDetails);
//   //         if (valid) {
//   //           deliverProduct(purchaseDetails);
//   //         } else {
//   //           _handleInvalidPurchase(purchaseDetails);
//   //           return;
//   //         }
//   //       }
//   //       if (Platform.isAndroid) {
//   //         if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
//   //           final InAppPurchaseAndroidPlatformAddition androidAddition =
//   //           _inAppPurchase.getPlatformAddition<
//   //               InAppPurchaseAndroidPlatformAddition>();
//   //           await androidAddition.consumePurchase(purchaseDetails);
//   //         }
//   //       }
//   //       if (purchaseDetails.pendingCompletePurchase) {
//   //         await _inAppPurchase.completePurchase(purchaseDetails);
//   //       }
//   //     }
//   //   });
//   // }
//
//   // GooglePlayPurchaseDetails _getOldSubscription(
//   //     ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
//   //   // This is just to demonstrate a subscription upgrade or downgrade.
//   //   // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
//   //   // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
//   //   // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
//   //   // Please remember to replace the logic of finding the old subscription Id as per your app.
//   //   // The old subscription is only required on Android since Apple handles this internally
//   //   // by using the subscription group feature in iTunesConnect.
//   //   GooglePlayPurchaseDetails? oldSubscription;
//   //   if (productDetails.id == _kSilverSubscriptionId &&
//   //       purchases[_kGoldSubscriptionId] != null) {
//   //     oldSubscription =
//   //     purchases[_kGoldSubscriptionId] as GooglePlayPurchaseDetails;
//   //   } else if (productDetails.id == _kGoldSubscriptionId &&
//   //       purchases[_kSilverSubscriptionId] != null) {
//   //     oldSubscription =
//   //     purchases[_kSilverSubscriptionId] as GooglePlayPurchaseDetails;
//   //   }
//   //   return oldSubscription;
//   // }
// }

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

// Original code link: https://github.com/flutter/plugins/blob/master/packages/in_app_purchase/example/lib/main.dart

const bool kAutoConsume = true;

// const String _kConsumableId = '';
const String _kSubscriptionId = '';
// const List<String> _kProductIds = <String>['noadforfifteendays', _kSubscriptionId];
// const List<String> _kProductIds = <String>[_kConsumableId, 'noadforfifteendays', _kSubscriptionId];

// TODO: Please Add your android product ID here
const List<String> _kAndroidProductIds = <String>[''];
//Example
//const List<String> _kAndroidProductIds = <String>[
//  'ADD_YOUR_ANDROID_PRODUCT_ID_1',
//  'ADD_YOUR_ANDROID_PRODUCT_ID_2',
//  'ADD_YOUR_ANDROID_PRODUCT_ID_3'
//];

// TODO: Please Add your iOS product ID here
// const List<String> _kiOSProductIds = <String>[''];
//Example
const List<String> _kiOSProductIds = <String>[
  "associate_promo_code",
  // 'leader_promo_code',
  // 'core_committee_promo_code',
];

// Set<String> _kiOSProductIds = Set.from([
//   "associate_promo_code",
//   "leader_promo_code",
//   "core_committee_promo_code",
// ]);
// const Set<String> _kiOSProductIds = <String>{
//   'associate_promo_code',
//   // 'leader_promo_code',
//   // 'core_committee_promo_code',
// };

// class Test extends StatefulWidget {
//   @override
//   _TestState createState() => _TestState();
// }
//
// class _TestState extends State<Test> {
//   final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
//   StreamSubscription<List<PurchaseDetails>> _subscription;
//   List<String> _notFoundIds = [];
//   // List<ProductDetails> _products = [];
//   List<PurchaseDetails> _purchases = [];
//   List<String> _consumables = [];
//   bool _isAvailable = false;
//   bool _purchasePending = false;
//   bool _loading = true;
//   String _queryProductError;
//
//   List<PurchasableProduct> _products;
//
//   @override
//   void initState() {
//     DateTime currentDate = DateTime.now();
//     DateTime noADDate;
//
//     var fiftyDaysFromNow = currentDate.add(new Duration(days: 50));
//     print('${fiftyDaysFromNow.month} - ${fiftyDaysFromNow.day} - ${fiftyDaysFromNow.year} ${fiftyDaysFromNow.hour}:${fiftyDaysFromNow.minute}');
//
//     Stream purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;
//     _subscription = purchaseUpdated.listen((purchaseDetailsList) {
//       print('called _subscription $purchaseDetailsList');
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       print('called done');
//       _subscription.cancel();
//     }, onError: (error) {
//       print('error $error');
//
//       // handle error here.
//     });
//     initStoreInfo();
//     super.initState();
//   }
//
//   Future<bool> isAppPurchaseAvailable() async {
//     final bool available = await InAppPurchaseConnection.instance.isAvailable();
//
//     debugPrint('#PurchaseService.isAppPurchaseAvailable() => $available');
//
//     return available;
//     if (!available) {
//       // The store cannot be reached or accessed. Update the UI accordingly.
//
//       return false;
//     }
//   }
//
//   Future<void> initStoreInfo() async {
//     final bool isAvailable = await _connection.isAvailable();
//     print('is Available  $isAvailable ');
//     if (!isAvailable) {
//       setState(() {
//         _isAvailable = isAvailable;
//         _products = [];
//         _purchases = [];
//         _notFoundIds = [];
//         _consumables = [];
//         _purchasePending = false;
//         _loading = false;
//       });
//       return;
//     }
//
//     // print('productDetailResponse $_kiOSProductIds');
//     // print('productDetailResponse ${_kiOSProductIds.toSet()}');
//     // ProductDetailsResponse productDetailResponse =
//     //     // await _connection.queryProductDetails(Platform.isIOS ? _kiOSProductIds.toSet() : _kAndroidProductIds.toSet()); //_kProductIds.toSet());
//     //     await _connection.queryProductDetails(_kiOSProductIds.toSet()); //_kProductIds.toSet());
//     // const Set<String> _kIds = <String>{'product1', 'product2'};
//     if (await isAppPurchaseAvailable()) {
//       // ProductDetailsResponse productDetailResponse = await InAppPurchaseConnection.instance.queryProductDetails(_kiOSProductIds.toSet());
//       ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(_kiOSProductIds.toSet());
//       // ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(<String>{
//       //   'associate_promo_code',
//       //   // 'leader_promo_code',
//       //   // 'core_committee_promo_code',
//       // });
//       // if (response.notFoundIDs.isNotEmpty) {
//       //   // Handle the error.
//       // }
//       // List<ProductDetails> products = response.productDetails;
//       print('productDetailResponse.error != null ${productDetailResponse.error != null}');
//       print('productDetailResponse productDetails ${productDetailResponse.productDetails}');
//       print('productDetailResponse not found id ${productDetailResponse.notFoundIDs}');
//       print('productDetailResponse err ${productDetailResponse.error}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.price}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.id}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.description}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.title}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.rawPrice}');
//       print('productDetailResponse not found id 2 ${productDetailResponse.notFoundIDs}');
//       print('productDetailResponse err 2 ${productDetailResponse.error}');
//
//       // print('productDetailResponse err msg ${productDetailResponse.error.message}');
//       if (productDetailResponse.error != null || productDetailResponse.productDetails.length > 0) {
//         print('called');
//         setState(() {
//           _queryProductError = productDetailResponse.error.message;
//           _isAvailable = isAvailable;
//           _products = productDetailResponse.productDetails.map((e) => PurchasableProduct(e)).toList();
//           // _products = productDetailResponse.productDetails;
//           _purchases = [];
//           _notFoundIds = productDetailResponse.notFoundIDs;
//           _consumables = [];
//           _purchasePending = false;
//           _loading = false;
//         });
//         print('_products $_products');
//         return;
//       }
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.price}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.id}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.description}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.title}');
//       print('productDetailResponse productDetails 2  ${productDetailResponse.productDetails.first.rawPrice}');
//       print('productDetailResponse not found id 2 ${productDetailResponse.notFoundIDs}');
//       print('productDetailResponse err 2 ${productDetailResponse.error}');
//
//       print('_products $_products');
//       print('_queryProductError $_queryProductError');
//
//       if (productDetailResponse.productDetails.isEmpty) {
//         setState(() {
//           _queryProductError = null;
//           _isAvailable = isAvailable;
//           // _products = productDetailResponse.productDetails;
//           _products = [];
//           _purchases = [];
//           _notFoundIds = productDetailResponse.notFoundIDs;
//           _consumables = [];
//           _purchasePending = false;
//           _loading = false;
//         });
//         return;
//       }
//
//       // final QueryPurchaseDetailsResponse purchaseResponse = await _connection.queryPastPurchases();
//       // if (purchaseResponse.error != null) {
//       //   // handle query past purchase error..
//       // }
//       // final List<PurchaseDetails> verifiedPurchases = [];
//       // for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
//       //   if (await _verifyPurchase(purchase)) {
//       //     verifiedPurchases.add(purchase);
//       //   }
//       // }
//       // List<String> consumables = await ConsumableStore.load();
//       // setState(() {
//       //   _isAvailable = isAvailable;
//       //   _products = productDetailResponse.productDetails;
//       //   _purchases = verifiedPurchases;
//       //   _notFoundIds = productDetailResponse.notFoundIDs;
//       //   _consumables = consumables;
//       //   _purchasePending = false;
//       //   _loading = false;
//       // });
//     } else {
//       debugPrint('#PurchaseService.loadProductsForSale() store not available');
//       // return null;
//     }
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> stack = [];
//     if (_queryProductError == null) {
//       stack.add(
//         ListView(
//           children: [
//             _buildConnectionCheckTile(),
//             _buildProductList(),
//             // _buildConsumableBox(),
//           ],
//         ),
//       );
//     } else {
//       stack.add(Center(
//         child: Text(_queryProductError),
//       ));
//     }
//     if (_purchasePending) {
//       stack.add(
//         Stack(
//           children: [
//             Opacity(
//               opacity: 0.3,
//               child: const ModalBarrier(dismissible: false, color: Colors.grey),
//             ),
//             Center(
//               child: CircularProgressIndicator(),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('IAP Example'),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.clear),
//               onPressed: () {
//                 Get.back();
//               },
//             ),
//           ],
//         ),
//         body: Stack(
//           children: stack,
//         ),
//       ),
//     );
//   }
//
//   Card _buildConnectionCheckTile() {
//     if (_loading) {
//       return Card(child: ListTile(title: const Text('Trying to connect...')));
//     }
//     final Widget storeHeader = ListTile(
//       leading: Icon(_isAvailable ? Icons.check : Icons.block, color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
//       title: Text('The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
//     );
//     final List<Widget> children = <Widget>[storeHeader];
//
//     if (!_isAvailable) {
//       children.addAll([
//         Divider(),
//         ListTile(
//           title: Text('Not connected', style: TextStyle(color: ThemeData.light().errorColor)),
//           subtitle: const Text('Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
//         ),
//       ]);
//     }
//     return Card(child: Column(children: children));
//   }
//
//   Card _buildProductList() {
//     if (_loading) {
//       return Card(child: (ListTile(leading: CircularProgressIndicator(), title: Text('Fetching products...'))));
//     }
//     if (!_isAvailable) {
//       return Card();
//     }
//     final ListTile productHeader = ListTile(title: Text('Products for Sale'));
//     List<ListTile> productList = <ListTile>[];
//     if (_notFoundIds.isNotEmpty) {
//       productList.add(ListTile(
//           title: Text('[${_notFoundIds.join(", ")}] not found', style: TextStyle(color: ThemeData.light().errorColor)),
//           subtitle: Text('This app needs special configuration to run. Please see example/README.md for instructions.')));
//     }
//
//     // This loading previous purchases code is just a demo. Please do not use this as it is.
//     // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
//     // We recommend that you use your own server to verity the purchase data.
//     Map<String, PurchaseDetails> purchases = Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
//       if (purchase.pendingCompletePurchase) {
//         InAppPurchaseConnection.instance.completePurchase(purchase);
//       }
//       return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
//     }));
//     productList.addAll(_products.map(
//       (productDetails) {
//         PurchaseDetails previousPurchase = purchases[productDetails.id];
//         return ListTile(
//             title: Text(
//               productDetails.title,
//             ),
//             subtitle: Text(
//               productDetails.description,
//             ),
//             trailing: previousPurchase != null
//                 ? Icon(Icons.check)
//                 : FlatButton(
//                     child: Text(productDetails.price),
//                     color: Colors.green[800],
//                     textColor: Colors.white,
//                     onPressed: () {
//                       print('called');
//                       // PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails, applicationUserName: null, sandboxTesting: false);
//                       // if (productDetails.id == _kConsumableId) {
//                       //   _connection.buyConsumable(purchaseParam: purchaseParam, autoConsume: kAutoConsume || Platform.isIOS);
//                       // } else {
//                       // _connection.buyNonConsumable(purchaseParam: purchaseParam);
//                       // }
//                     },
//                   ));
//       },
//     ));
//
//     return Card(child: Column(children: <Widget>[productHeader, Divider()] + productList));
//   }
//
//   Card _buildConsumableBox() {
//     if (_loading) {
//       return Card(child: (ListTile(leading: CircularProgressIndicator(), title: Text('Fetching consumables...'))));
//     }
//     // if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
//     //   return Card();
//     // }
//     final ListTile consumableHeader = ListTile(title: Text('Purchased consumables'));
//     final List<Widget> tokens = _consumables.map((String id) {
//       return GridTile(
//         child: IconButton(
//           icon: Icon(
//             Icons.stars,
//             size: 42.0,
//             color: Colors.orange,
//           ),
//           splashColor: Colors.yellowAccent,
//           onPressed: () => consume(id),
//         ),
//       );
//     }).toList();
//     return Card(
//         child: Column(children: <Widget>[
//       consumableHeader,
//       Divider(),
//       GridView.count(
//         crossAxisCount: 5,
//         children: tokens,
//         shrinkWrap: true,
//         padding: EdgeInsets.all(16.0),
//       )
//     ]));
//   }
//
//   Future<void> consume(String id) async {
//     print('consume id is $id');
//     await ConsumableStore.consume(id);
//     final List<String> consumables = await ConsumableStore.load();
//     setState(() {
//       _consumables = consumables;
//     });
//   }
//
//   void showPendingUI() {
//     setState(() {
//       _purchasePending = true;
//     });
//   }
//
//   void deliverProduct(PurchaseDetails purchaseDetails) async {
//     print('deliverProduct'); // Last
//     // IMPORTANT!! Always verify a purchase purchase details before delivering the product.
//     // if (purchaseDetails.productID == _kConsumableId) {
//     //   await ConsumableStore.save(purchaseDetails.purchaseID);
//     //   List<String> consumables = await ConsumableStore.load();
//     //   setState(() {
//     //     _purchasePending = false;
//     //     _consumables = consumables;
//     //   });
//     // } else {
//     setState(() {
//       _purchases.add(purchaseDetails);
//       _purchasePending = false;
//     });
//     // }
//   }
//
//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//     });
//   }
//
//   Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
//     // IMPORTANT!! Always verify a purchase before delivering the product.
//     // For the purpose of an example, we directly return true.
//     print('_verifyPurchase');
//     return Future<bool>.value(true);
//   }
//
//   void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
//     // handle invalid purchase here if  _verifyPurchase` failed.
//     print('_handleInvalidPurchase');
//   }
//
//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     print('_listenToPurchaseUpdated');
//     purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           handleError(purchaseDetails.error);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased) {
//           bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             deliverProduct(purchaseDetails);
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         }
//         if (Platform.isAndroid) {
//           // if (!kAutoConsume && purchaseDetails.productID == _kConsumableId) {
//           //   await InAppPurchaseConnection.instance.consumePurchase(purchaseDetails);
//           // }
//         }
//         if (purchaseDetails.pendingCompletePurchase) {
//           await InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
//         }
//       }
//     });
//   }
// }

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  @override
  void initState() {
    var provider = Provider.of<ProviderModel>(context, listen: false);
    provider.initialize();
    provider.verifyPurchase();
    super.initState();
  }

  @override
  void dispose() {
    var provider = Provider.of<ProviderModel>(context, listen: false);
    provider.subscription!.cancel();
    super.dispose();
  }

  void _buyProduct(ProductDetails prod) {
    print('prod $prod');
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderModel>(context);
// This is our app UI where we show our products
    return Scaffold(
      appBar: AppBar(
        title: Text("In App Purchase List of products"),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          child: ListView(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.grey.withOpacity(0.2),
                    child: FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            provider.available ? "Store is Available" : "Store is not Available",
                            style: TextStyle(fontSize: 22, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              for (var prod in provider.products)
                if (provider.hasPurchased(prod.id) != null) ...[
                  Center(
                    child: Text(
// If you want to change title change it from google console in-app products section
                      "You Paid for ${prod.title} \n THANK YOU!💕",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                  Container(height: 50),
                ] else ...[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
// If you want to change description change it from google console in-app products section
                          "${prod.title}",
                          style: TextStyle(fontSize: 22, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        Text(
// If you want to change description change it from google console in-app products section
                          "${prod.description}",
                          style: TextStyle(fontSize: 22, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        Text(
// If you want to change price change it from google console in-app products section
                          "${prod.price}",
                          style: TextStyle(fontSize: 22, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        FlatButton(
                          onPressed: () => _buyProduct(prod),
                          child: Text('Pay'),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  Container(height: 10)
                ]
            ],
          ),
        ),
      ),
    );
  }
}

enum ProductStatus {
  purchasable,
  purchased,
  pending,
}

class PurchasableProduct {
  String get id => productDetails.id;
  String get title => productDetails.title;
  String get description => productDetails.description;
  String get price => productDetails.price;
  ProductStatus status;
  ProductDetails productDetails;

  PurchasableProduct(this.productDetails) : status = ProductStatus.purchasable;
}

// This is just a development prototype for locally storing consumables. Do not
// use this.

// Original code link: https://github.com/flutter/plugins/blob/master/packages/in_app_purchase/example/lib/consumable_store.dart

// class ConsumableStore {
//   static const String _kPrefKey = 'consumables';
//   static Future<void> _writes = Future.value();
//
//   static Future<void> save(String id) {
//     _writes = _writes.then((void _) => _doSave(id));
//     return _writes;
//   }
//
//   static Future<void> consume(String id) {
//     _writes = _writes.then((void _) => _doConsume(id));
//     return _writes;
//   }
//
//   static Future<List<String>> load() async {
//     return (await SharedPreferences.getInstance()).getStringList(_kPrefKey) ?? [];
//   }
//
//   static Future<void> _doSave(String id) async {
//     List<String> cached = await load();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     cached.add(id);
//     await prefs.setStringList(_kPrefKey, cached);
//   }
//
//   static Future<void> _doConsume(String id) async {
//     List<String> cached = await load();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     cached.remove(id);
//     await prefs.setStringList(_kPrefKey, cached);
//   }
// }

class ProviderModel with ChangeNotifier {
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  bool available = true;
  late StreamSubscription? subscription;

// here to add more Products in this case we have 2 Product IDs

  final String myFirstProductID = 'associate_promo_code';
  final String mySecondProductID = 'leader_promo_code';

// here to Create boolean for our First Product to check if its Purchased our not.

  bool _isFirstItemPurchased = false;
  bool get isFirstItemPurchased => _isFirstItemPurchased;
  set isFirstItemPurchased(bool value) {
    _isFirstItemPurchased = value;
    notifyListeners();
  }

// here to Create boolean for our Second Product to check if its Purchased our not.

  bool _isSecondItemPurchased = false;
  bool get isSecondItemPurchased => _isSecondItemPurchased;
  set isSecondItemPurchased(bool value) {
    _isSecondItemPurchased = value;
    notifyListeners();
  }

// here is the list of purchases

  List _purchases = [];
  List get purchases => _purchases;
  set purchases(List value) {
    _purchases = value;
    notifyListeners();
  }

// our product list

  List _products = [];
  List get products => _products;
  set products(List value) {
    _products = value;
    print('_products ${_products.first.title}');
    notifyListeners();
  }

// here we initialize and check our purchases

  void initialize() async {
    available = await _iap.isAvailable();
    if (available) {
      await _getProducts();
      await _getPastPurchases();
      verifyPurchase();
      subscription = _iap.purchaseUpdatedStream.listen((data) {
        purchases.addAll(data);
        verifyPurchase();
      });
    }
  }

  void verifyPurchase() {
//   here verify and complete our First Product Purchase
    PurchaseDetails? purchase = hasPurchased(myFirstProductID);
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);

        if (purchase != null && purchase.status == PurchaseStatus.purchased) {
          isFirstItemPurchased = true;
        }
      }
    }

//   here verify and complete our second Product Purchase

    PurchaseDetails? secondPurchase = hasPurchased(mySecondProductID);
    if (secondPurchase != null && secondPurchase.status == PurchaseStatus.purchased) {
      if (secondPurchase.pendingCompletePurchase) {
        _iap.completePurchase(secondPurchase);

        if (secondPurchase != null && secondPurchase.status == PurchaseStatus.purchased) {
          isSecondItemPurchased = true;
        }
      }
    }
  }

  PurchaseDetails? hasPurchased(String? productID) {
    return purchases.firstWhere((purchase) => purchase.productID == productID, orElse: () => null);
  }

  Future<void> _getProducts() async {
    Set<String> ids = Set.from([myFirstProductID, mySecondProductID]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    print(' products ${response.productDetails.length}');
    print(' products ${response.productDetails.first.title}');
    print(' products ${response.productDetails.first.description}');
    print(' products ${response.productDetails.first.id}');
    print(' products ${response.productDetails.first.price}');
    products = response.productDetails;
  }

  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        _iap.consumePurchase(purchase);
      }
    }
    purchases = response.pastPurchases;
  }
}
