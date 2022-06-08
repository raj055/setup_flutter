import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../services/api.dart';
import '../services/translator.dart';
import '../widget/customWidget.dart';
import '../widget/paginated_list.dart';
import '../widget/theme.dart';

class FaqList extends StatefulWidget {
  @override
  _FaqListState createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get('FAQs'),
      apiFuture: (int page) async {
        return Api.httpWithoutLoader.get("faqs?page=$page");
      },
      listItemBuilder: _faqsBuilder,
      showLoader: true,
      loadingWidgetBuilder: _buildLoadingWidget,
    );
  }

  Widget _buildLoadingWidget() {
    return loadingWidget(barCount: 1);
  }

  Widget _faqsBuilder(dynamic faq, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: boxDecoration(
        radius: 10,
        showShadow: true,
      ),
      child: Column(
        children: <Widget>[
          ExpansionTile(
            title: text(
              faq['question'],
              textColor: colorPrimary,
              fontFamily: fontSemibold,
              isLongText: true,
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: text(
                  faq['answer'],
                  isLongText: true,
                ),
              ),
            ],
            initiallyExpanded: false,
          ),
        ],
      ),
    );
  }
}
