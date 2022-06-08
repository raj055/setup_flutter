import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const bool _kAutoConsume = true;

// const String _kConsumableId = 'consumable';
// const String _kUpgradeId = 'upgrade';
// const String _kSilverSubscriptionId = 'subscription_silver';
// const String _kGoldSubscriptionId = 'subscription_gold';
const List<String> _kProductIds = <String>[
  'associate_promo_code',
  'leader_promo_code',
  'core_committee_promo_code',
  // _kConsumableId,
  // _kUpgradeId,
  // _kSilverSubscriptionId,
  // _kGoldSubscriptionId,
];

class Test1 extends StatefulWidget {
  @override
  Test1State createState() => Test1State();
}

class Test1State extends State<Test1> {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  // List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      print('purchaseDetailsList $purchaseDetailsList');
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        // _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        // _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        // _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse = await _connection.queryPastPurchases();
    print('purchaseResponse $purchaseResponse');
    print('purchaseResponse ${purchaseResponse.pastPurchases.length}');
    // print('purchaseResponse ${purchaseResponse.pastPurchases.first}');
    // print('purchaseResponse ${purchaseResponse.pastPurchases.first.purchaseID}');
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }
    // List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = verifiedPurchases;
      _notFoundIds = productDetailResponse.notFoundIDs;
      // _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
            // _buildConsumableBox(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError!),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IAP Example'),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        body: Stack(
          children: stack,
        ),
      ),
    );
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block, color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text('The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected', style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text('Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(child: (ListTile(leading: CircularProgressIndicator(), title: Text('Fetching products...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    final ListTile productHeader = ListTile(title: Text('Products for Sale'));
    List<ListTile> productList = <ListTile>[];
    if (_notFoundIds.isNotEmpty) {
      productList.add(ListTile(
          title: Text('[${_notFoundIds.join(", ")}] not found', style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: Text('This app needs special configuration to run. Please see example/README.md for instructions.')));
    }

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    Map<String, PurchaseDetails> purchases = Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: previousPurchase != null
                ? Icon(Icons.check)
                : TextButton(
                    child: Text(productDetails.price),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      primary: Colors.white,
                    ),
                    onPressed: () {
                      // NOTE: If you are making a subscription purchase/upgrade/downgrade, we recommend you to
                      // verify the latest status of you your subscription by using server side receipt validation
                      // and update the UI accordingly. The subscription purchase status shown
                      // inside the app may not be accurate.
                      final oldSubscription = _getOldSubscription(productDetails, purchases);
                      PurchaseParam purchaseParam = PurchaseParam(
                          productDetails: productDetails,
                          applicationUserName: null,
                          changeSubscriptionParam: Platform.isAndroid && oldSubscription != null
                              ? ChangeSubscriptionParam(oldPurchaseDetails: oldSubscription, prorationMode: ProrationMode.immediateWithTimeProration)
                              : null);
                      // if (productDetails.id == _kConsumableId) {
                      //   _connection.buyConsumable(purchaseParam: purchaseParam, autoConsume: _kAutoConsume || Platform.isIOS);
                      // } else {
                      _connection.buyNonConsumable(purchaseParam: purchaseParam);
                      // }
                    },
                  ));
      },
    ));

    return Card(child: Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  // Card _buildConsumableBox() {
  //   if (_loading) {
  //     return Card(child: (ListTile(leading: CircularProgressIndicator(), title: Text('Fetching consumables...'))));
  //   }
  //   if (!_isAvailable || _notFoundIds.contains(_kConsumableId)) {
  //     return Card();
  //   }
  //   final ListTile consumableHeader = ListTile(title: Text('Purchased consumables'));
  //   final List<Widget> tokens = _consumables.map((String id) {
  //     return GridTile(
  //       child: IconButton(
  //         icon: Icon(
  //           Icons.stars,
  //           size: 42.0,
  //           color: Colors.orange,
  //         ),
  //         splashColor: Colors.yellowAccent,
  //         onPressed: () => consume(id),
  //       ),
  //     );
  //   }).toList();
  //   return Card(
  //       child: Column(children: <Widget>[
  //     consumableHeader,
  //     Divider(),
  //     GridView.count(
  //       crossAxisCount: 5,
  //       children: tokens,
  //       shrinkWrap: true,
  //       padding: EdgeInsets.all(16.0),
  //     )
  //   ]));
  // }

  // Future<void> consume(String id) async {
  //   await ConsumableStore.consume(id);
  //   final List<String> consumables = await ConsumableStore.load();
  //   // setState(() {
  //   //   _consumables = consumables;
  //   // });
  // }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    // if (purchaseDetails.productID == _kConsumableId) {
    //   await ConsumableStore.save(purchaseDetails.purchaseID);
    //   List<String> consumables = await ConsumableStore.load();
    //   setState(() {
    //     _purchasePending = false;
    //     _consumables = consumables;
    //   });
    // } else {
    setState(() {
      _purchases.add(purchaseDetails);
      _purchasePending = false;
    });
    // }
  }

  void handleError(IAPError? error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      print('purchaseDetails $purchaseDetails');
      print('purchaseDetails status ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        // if (Platform.isAndroid) {
        //   if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
        //     await InAppPurchaseConnection.instance.consumePurchase(purchaseDetails);
        //   }
        // }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  PurchaseDetails? _getOldSubscription(ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    PurchaseDetails? oldSubscription;
    // if (productDetails.id == _kSilverSubscriptionId && purchases[_kGoldSubscriptionId] != null) {
    //   oldSubscription = purchases[_kGoldSubscriptionId];
    // } else if (productDetails.id == _kGoldSubscriptionId && purchases[_kSilverSubscriptionId] != null) {
    //   oldSubscription = purchases[_kSilverSubscriptionId];
    // }
    return oldSubscription;
  }
}

class ConsumableStore {
  static const String _kPrefKey = 'consumables';
  static Future<void> _writes = Future.value();

  /// Adds a consumable with ID `id` to the store.
  ///
  /// The consumable is only added after the returned Future is complete.
  static Future<void> save(String id) {
    _writes = _writes.then((void _) => _doSave(id));
    return _writes;
  }

  /// Consumes a consumable with ID `id` from the store.
  ///
  /// The consumable was only consumed after the returned Future is complete.
  static Future<void> consume(String id) {
    _writes = _writes.then((void _) => _doConsume(id));
    return _writes;
  }

  /// Returns the list of consumables from the store.
  static Future<List<String>> load() async {
    return (await SharedPreferences.getInstance()).getStringList(_kPrefKey) ?? [];
  }

  static Future<void> _doSave(String id) async {
    List<String> cached = await load();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.add(id);
    await prefs.setStringList(_kPrefKey, cached);
  }

  static Future<void> _doConsume(String id) async {
    List<String> cached = await load();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cached.remove(id);
    await prefs.setStringList(_kPrefKey, cached);
  }
}
