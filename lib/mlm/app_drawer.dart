import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

import '../../services/auth.dart';
import '../../widget/theme.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final List<Entry> data = <Entry>[
    Entry("Home", {'icon': UniconsLine.home, 'page': '/dashboard'}),
    Entry("Profile", {'icon': UniconsLine.user, 'page': '/profile-mlm'}),
    Entry("KYC", {'icon': UniconsLine.image, 'page': '/kyc'}),
    Entry("Change Password", {'icon': UniconsLine.lock, 'page': '/change-password'}),
    Entry("Change Transaction Password", {'icon': UniconsLine.lock, 'page': '/transaction-change-password'}),
    Entry("Genealogy Tree", {'icon': UniconsLine.code_branch, 'page': 'genealogy'}),
    Entry("Self Purchase Invoice", {'icon': UniconsLine.shopping_cart_alt, 'page': 'orders'}),
    Entry("Payout", {'icon': UniconsLine.briefcase, 'page': '/payout'}),
    if (Auth.isVendor()!) ...[
      Entry("Vendor Payout", {'icon': UniconsLine.briefcase, 'page': '/vendor-payout'}),
      Entry("Vendor Invoice", {'icon': UniconsLine.shopping_cart, 'page': '/vendor-invoice'}),
      Entry("Vendor Wallet Transaction", {'icon': UniconsLine.briefcase, 'page': '/vendor-wallet-transaction'}),
    ],
    Entry("Offline Order", {'icon': UniconsLine.briefcase, 'page': '/off-line-orders'}),
    // Entry("Withdrawal Request", {'icon': UniconsLine.web_grid_alt, 'page': '/withdrawal-request-list'}),
    Entry("Wallet Transactions", {'icon': UniconsLine.file_plus, 'page': 'wallet'}),
    Entry("Reports", {'icon': UniconsLine.file, 'page': '/reports'}),
    Entry("Incomes", {'icon': UniconsLine.signal, 'page': '/income-mlm'}),
    Entry("Banking Partner", {'icon': UniconsLine.home, 'page': '/banking-partner'}),
    Entry("Support", {'icon': UniconsLine.headphones_alt, 'page': '/support'}),
  ];

  Widget? drawerHeader;

  @override
  Widget build(BuildContext context) {
    drawerHeader = UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: colorPrimary),
      accountName: Text(
        Auth.user()!['name'].toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      accountEmail: Text(
        Auth.user()!['code'].toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        radius: 30,
        backgroundImage: Auth.user()!['profileImage'] != null
            ? CachedNetworkImageProvider(Auth.user()!['profileImage'])
            : CachedNetworkImageProvider(
                "https://d1jmctim2yaoco.cloudfront.net/7950ad76-d5ba-466d-982a-14466ed82947/images/user.png",
              ),
      ),
    );

    return Drawer(
      child: Container(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            /* if (index == 0) {
              return Column(
                children: <Widget>[drawerHeader!],
              );
            } else {*/
            return EntryItem(data[index]);
            // }
          },
        ),
      ),
    );
  }
}

class Draw {
  final String? title;
  final IconData? icon;

  Draw({
    this.title,
    this.icon,
  });
}

class Entry {
  Entry(this.title, this.data, [this.children = const <Entry>[]]);

  final String title;
  final Map data;
  final List<Entry> children;
}

class EntryItem extends StatefulWidget {
  const EntryItem(this.entry);

  final Entry entry;

  @override
  _EntryItemState createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  bool _expanded = false;

  Widget _buildTiles(Entry root, {int depth = 0}) {
    if (root.children.isEmpty) {
      return Padding(
        padding: depth > 0 ? EdgeInsets.only(left: 15.0) : EdgeInsets.all(0),
        child: ListTile(
          leading: Icon(
            root.data['icon'],
            color: colorPrimary,
          ),
          onTap: () {
            Get.back();
            setState(() {
              _expanded = false;
            });
            if (root.data['page'] == 'genealogy') {
              Get.toNamed('/genealogy-mlm', arguments: "genealogy");
            } else if (root.data['page'] == 'wallet') {
              Get.toNamed('/wallet', arguments: "wallet");
            } else if (root.data['page'] == 'orders') {
              Get.toNamed('/orders', arguments: "orders");
            } else {
              Get.toNamed(root.data['page']);
            }
          },
          title: text(
            root.title,
            isLongText: true,
            fontSize: textSizeMedium,
            fontFamily: fontMedium,
            textColor: colorPrimaryDark,
          ),
        ),
      );
    }

    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: text(
        root.title,
        fontSize: textSizeLargeMedium,
        fontFamily: fontMedium,
        textColor: colorPrimaryDark,
      ),
      initiallyExpanded: _expanded,
      children: root.children.map((child) {
        return _buildTiles(child, depth: depth + 1);
      }).toList(),
      onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
      trailing: Icon(
        _expanded ? Icons.expand_less : Icons.expand_more,
        color: colorPrimary,
      ),
      leading: Icon(
        root.data['icon'],
        color: colorPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildTiles(widget.entry),
    );
  }
}
