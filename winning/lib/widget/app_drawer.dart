import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';
import 'package:share/share.dart';
import 'package:unicons/unicons.dart';

import '../services/auth.dart';
import '../services/translator.dart';
import '../widget/theme.dart';

class AppDrawer extends StatefulWidget {
  final String? name;
  final String? packageName;
  final String? expiryAt;
  final int? expiryLeftDays;
  final String? profileImage;
  final int? packageId;
  final bool? isPaid;

  const AppDrawer({
    Key? key,
    this.name,
    this.packageName,
    this.expiryAt,
    this.expiryLeftDays,
    this.packageId,
    this.profileImage,
    this.isPaid,
  }) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<Entry> data = [];
  Widget? drawerHeader;

  @override
  void initState() {
    _populateDrawerItems();

    super.initState();
  }

  _populateDrawerItems() {
    data = <Entry>[
      Entry("test", {'icon': Icons.streetview, 'page': 'null'}),
      if (Auth.currentPackage() == 1) ...[
        Entry(Translator.get('Dashboard'), {
          'icon': UniconsLine.estate,
          'page': 'guest-dashboard',
        }),
        Entry(Translator.get('Dream List'), {
          'icon': UniconsLine.cloud_lock,
          'page': 'dream-list',
        }),
        // if (Platform.isAndroid || widget.isPaid)
        Entry(Translator.get("Activation Codes"), {
          'icon': UniconsLine.registered,
          'page': 'promo_code',
        }),
        Entry(Translator.get("Invitation Script"), {'icon': UniconsLine.receipt_alt, 'page': 'invitation-category'}),
        if (Platform.isAndroid || widget.isPaid!)
          Entry(Translator.get("Meeting"), {
            'icon': UniconsLine.meeting_board,
            'page': 'meeting_list',
          }),
        Entry(Translator.get("Team Request List"), {
          'icon': UniconsLine.user_arrows,
          'page': 'team_request_list',
        }),
        Entry(Translator.get("Notes"), {'icon': UniconsLine.notes, 'page': 'note'}),
        Entry(Translator.get("News"), {'icon': UniconsLine.newspaper, 'page': 'news'}),
        Entry(Translator.get("Gallery"), {'icon': UniconsLine.images, 'page': 'gallery-view'}),
        Entry(Translator.get("Guest Gift"), {'icon': UniconsLine.gift, 'page': 'guest-gift'}),
        Entry(Translator.get("Inspiration Club"), {
          'icon': UniconsLine.mountains,
          'page': 'inspiration_club_List',
        }),
        Entry(Translator.get(dotenv.env['VESTIGE_NAME']!), {
          'icon': UniconsLine.hospital,
          'page': 'my_vestige_list',
        }),
        Entry(Translator.get("Testimonials"), {'icon': UniconsLine.clipboard_notes, 'page': 'testimonials'}),
        Entry(Translator.get("FAQs"), {'icon': UniconsLine.file_question_alt, 'page': 'faq-question'}),
        Entry(Translator.get("Feedback"), {'icon': UniconsLine.feedback, 'page': 'feedback'}),
        Entry(Translator.get("About CEP"), {'icon': UniconsLine.dashboard, 'page': 'about-cep'}),
        Entry(Translator.get("About Us"), {'icon': UniconsLine.info_circle, 'page': 'about-us'}),
        Entry(Translator.get("About Vestige"), {'icon': UniconsLine.hospital, 'page': 'about-vestige'}),
        Entry(Translator.get("Contact Us"), {'icon': UniconsLine.phone_volume, 'page': 'contact-us'}),
        Entry(
          Translator.get("Share"),
          {
            'icon': UniconsLine.share_alt,
            'callback': () {
              Share.share(dotenv.env['PLAYSTORE_URL']!);
            }
          },
        ),
      ],
      if (Auth.currentPackage() == 2 || Auth.currentPackage() == 3 || Auth.currentPackage() == 4) ...[
        Entry(Translator.get('Dashboard'), {
          'icon': UniconsLine.estate,
          'page': 'home',
        }),
        if (Auth.currentPackage() == 2 || Auth.currentPackage() == 3) ...[
          // if (Platform.isAndroid || widget.isPaid)
          Entry(Translator.get("Upgrade Package"), {
            'icon': UniconsLine.package,
            'page': 'upgrade_package',
          }),
        ],
        // if (Platform.isAndroid || widget.isPaid)
        Entry(Translator.get("Activation Codes"), {
          'icon': UniconsLine.registered,
          'page': 'promo_code',
        }),
        Entry(Translator.get(dotenv.env['PRODUCT_NAME']!), {
          'icon': UniconsLine.dashboard,
          'page': 'elibrary_list',
        }),
        Entry(Translator.get('Dream List'), {
          'icon': UniconsLine.cloud_lock,
          'page': 'dream-list',
        }),
        Entry(Translator.get("Guest List"), {
          'icon': UniconsLine.users_alt,
          'page': 'guest-list',
        }),
        Entry(Translator.get("Invitation Script"), {
          'icon': UniconsLine.receipt_alt,
          'page': 'invitation-category',
        }),
        if (Platform.isAndroid || widget.isPaid!)
          Entry(Translator.get("Meeting"), {
            'icon': UniconsLine.meeting_board,
            'page': 'meeting_list',
          }),
        Entry(Translator.get("Genealogy"), {
          'icon': UniconsLine.channel,
          'page': 'genealogy',
        }),
        Entry(Translator.get("Notes"), {
          'icon': UniconsLine.notes,
          'page': 'note',
        }),
        Entry(Translator.get("Activity"), {
          'icon': UniconsLine.comparison,
          'page': 'activity',
        }),
        if (Platform.isAndroid || widget.isPaid!)
          Entry(Translator.get("Gift To Guest"), {
            'icon': UniconsLine.gift,
            'page': 'gift-sharing',
          }),
        Entry(Translator.get('My Analytics'), {
          'icon': UniconsLine.chart_pie_alt,
          'page': 'analytics',
        }),
        if (Auth.currentPackage() == 2) ...[
          Entry(Translator.get("Team Request List"), {
            'icon': UniconsLine.user_arrows,
            'page': 'team_request_list',
          }),
        ],
        if (Auth.currentPackage() == 3 || Auth.currentPackage() == 4) ...[
          Entry(
            Translator.get("Team"),
            {
              'icon': UniconsLine.user_plus,
              'page': null,
            },
            <Entry>[
              if (Auth.currentPackage() == 4) ...[
                Entry(Translator.get('My Team'), {
                  'icon': null,
                  'page': 'my-team',
                })
              ],
              Entry(Translator.get('Team Request List'), {
                'icon': null,
                'page': 'team_request_list',
              }),
              Entry(Translator.get('Team Analytics'), {'icon': null, 'page': 'team-analytics'}),
              Entry(Translator.get('Team Activity'), {
                'icon': null,
                'page': 'team-activity',
              }),
              Entry(Translator.get('Team Dream'), {'icon': null, 'page': 'team-dream'}),
              Entry(Translator.get('Badge Achiever'), {
                'icon': null,
                'page': 'badge-achiever',
              }),
              Entry(Translator.get("10 Core Steps"), {
                'icon': null,
                'page': 'core-steps',
              }),
            ],
          ),
        ],
        Entry(
          Translator.get("Badge"),
          {
            'icon': UniconsLine.award,
            'page': null,
          },
          <Entry>[
            Entry(Translator.get('My Badge'), {
              'icon': null,
              'page': 'my-badge',
            }),
            Entry(Translator.get('Request for Badge'), {'icon': null, 'page': 'request-badge'}),
            Entry(Translator.get('View Request'), {
              'icon': null,
              'page': 'view-request',
            }),
            Entry(Translator.get('History'), {'icon': null, 'page': 'user-history'}),
          ],
        ),
        Entry(Translator.get("Broadcast"), {
          'icon': UniconsLine.comment_alt_lines,
          'page': null,
        }, <Entry>[
          Entry(Translator.get('My Broadcast'), {
            'icon': null,
            'page': 'category-my-broadcast',
          }),
          if (Auth.currentPackage() == 3 || Auth.currentPackage() == 4) ...[
            Entry(Translator.get('Team Broadcast'), {
              'icon': null,
              'page': 'broadcast-team',
            }),
          ],
          if (Auth.currentPackage() == 4) ...[
            Entry(Translator.get('Broadcasting'), {
              'icon': null,
              'page': 'broadcasting',
            }),
          ]
        ]),
        Entry(Translator.get("News"), {
          'icon': UniconsLine.newspaper,
          'page': 'news',
        }),
        Entry(Translator.get("Gallery"), {
          'icon': UniconsLine.images,
          'page': 'gallery-view',
        }),
        Entry(Translator.get("Inspiration Club"), {
          'icon': UniconsLine.mountains,
          'page': 'inspiration_club_List',
        }),
        Entry(Translator.get(dotenv.env['VESTIGE_NAME']!), {
          'icon': UniconsLine.hospital,
          'page': 'my_vestige_list',
        }),
        Entry(Translator.get("Testimonials"), {
          'icon': UniconsLine.clipboard_notes,
          'page': 'testimonials',
        }),
        Entry(Translator.get("FAQs"), {
          'icon': UniconsLine.file_question_alt,
          'page': 'faq-question',
        }),
        Entry(Translator.get("Feedback"), {
          'icon': UniconsLine.feedback,
          'page': 'feedback',
        }),
        Entry(Translator.get("About CEP"), {
          'icon': UniconsLine.dashboard,
          'page': 'about-cep',
        }),
        Entry(Translator.get("About Us"), {
          'icon': UniconsLine.info_circle,
          'page': 'about-us',
        }),
        Entry(Translator.get("About Vestige"), {
          'icon': UniconsLine.hospital,
          'page': 'about-vestige',
        }),
        Entry(Translator.get("Contact Us"), {
          'icon': UniconsLine.phone_volume,
          'page': 'contact-us',
        }),
        Entry(
          Translator.get("Share"),
          {
            'icon': UniconsLine.share_alt,
            'callback': () {
              if (Platform.isAndroid) {
                Share.share(dotenv.env['PLAYSTORE_URL']!);
              } else if (Platform.isIOS) {
                Share.share(dotenv.env['APPSTORE_URL']!);
              }
            }
          },
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    drawerHeader = UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: colorPrimary),
      accountName: text(
        ReCase(widget.name.toString().replaceAll('null', "N/A")).titleCase,
        fontFamily: fontSemibold,
        textColor: white,
      ),
      accountEmail: Row(
        children: [
          text(
            widget.packageName!,
            textColor: white,
          ),
          SizedBox(width: 5),
          if (widget.expiryLeftDays != null)
            text(
              "( " + widget.expiryLeftDays.toString() + " Days Left  )",
              textColor: white,
            )
        ],
      ),
      currentAccountPicture: widget.profileImage != null && widget.profileImage!.isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage(widget.profileImage!),
              backgroundColor: Colors.white,
            )
          : CircleAvatar(
              backgroundImage: AssetImage(profileImage),
            ),
    );
    return Drawer(
      child: Container(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Column(children: <Widget>[drawerHeader!]);
            } else {
              return EntryItem(data[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildUserSidebarInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: text(
                  ReCase(widget.name.toString().replaceAll('null', "N/A")).titleCase,
                  fontFamily: fontSemibold,
                  textColor: colorPrimaryDark,
                  isLongText: true,
                ),
              ),
              SizedBox(width: 5),
              widget.packageName != null
                  ? text(
                      "( " + widget.packageName! + " )",
                      textColor: colorPrimary,
                      fontFamily: fontSemibold,
                      isLongText: true,
                    )
                  : Text('null'),
              SizedBox(height: 5.0),
            ],
          ),
          SizedBox(height: 5.0),
          Row(
            children: <Widget>[
              text(
                'Expiry Left Days : ',
                fontFamily: fontSemibold,
                textColor: colorPrimaryDark,
                isLongText: true,
              ),
              text(int.parse(widget.expiryLeftDays.toString()).toString()),
            ],
          ),
          Divider(
            height: 2,
            thickness: 1,
          ),
        ],
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

  final String? title;
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
        padding: depth > 0 ? EdgeInsets.only(left: 0.0) : EdgeInsets.all(0),
        child: ListTile(
          dense: true,
          leading: Icon(
            root.data['icon'],
            color: colorPrimary,
            size: textSizeLarge,
          ),
          onTap: () {
            Get.back();
            setState(() {
              _expanded = false;
            });

            if (root.data.containsKey('page')) {
              if (root.data['page'] == 'home') {
                Get.offAllNamed(root.data['page']);
              } else {
                Get.toNamed(root.data['page']);
              }
            }

            if (root.data.containsKey('callback')) {
              root.data['callback']();
            }
          },
          title: text(
            root.title,
            fontSize: textSizeMedium,
            fontFamily: fontSemibold,
            textColor: colorPrimaryDark,
          ),
        ),
      );
    }

    return ListTileTheme(
      dense: true,
      child: ExpansionTile(
        key: PageStorageKey<Entry>(root),
        title: text(
          root.title,
          fontFamily: fontSemibold,
          fontSize: textSizeMedium,
          textColor: colorPrimaryDark,
        ),
        initiallyExpanded: _expanded,
        children: root.children.map(
          (child) {
            return _buildTiles(child, depth: depth + 1);
          },
        ).toList(),
        onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
        trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: colorPrimary),
        leading: Icon(
          root.data['icon'],
          color: colorPrimary,
          size: textSizeLarge,
        ),
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
