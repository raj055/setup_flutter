import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;
import 'package:recase/recase.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/network_image.dart';
import '../../widget/paginated_list.dart';
import '../../widget/theme.dart';

class CepPrime extends StatefulWidget {
  @override
  _CepPrimeState createState() => _CepPrimeState();
}

class _CepPrimeState extends State<CepPrime> {
  @override
  Widget build(BuildContext context) {
    return PaginatedList(
      pageTitle: Translator.get("CEP Prime"),
      apiFuture: (int page) async {
        return Api.http.get("cep-prime?page=$page");
      },
      listItemBuilder: _eLibraryBuilder,
      appBarAction: <Widget>[
        IconButton(
          onPressed: () {
            Get.toNamed('cep-prime-category-search');
          },
          icon: Icon(
            Feather.search,
          ),
        ),
      ],
    );
  }

  Widget _eLibraryBuilder(dynamic eLibrary, int index) {
    return GestureDetector(
      onTap: () {
        eLibrary['videos'].length > 0
            ? Get.toNamed(
                'document_video_tool',
                arguments: {
                  "details": eLibrary['videos'],
                  "name": eLibrary['name'],
                  "id": eLibrary['id'],
                  "pageType": eLibrary['pageType'],
                },
              )
            : eLibrary['audios'].length > 0
                ? Get.toNamed(
                    'document_video_tool',
                    arguments: {
                      "details": eLibrary['audios'],
                      "name": eLibrary['name'],
                      "id": eLibrary['id'],
                      "pageType": eLibrary['pageType'],
                    },
                  )
                : eLibrary['ebooks'].length > 0
                    ? Get.toNamed(
                        'document_ebook_view',
                        arguments: {
                          "details": eLibrary['ebooks'],
                          "name": eLibrary['name'],
                          "id": eLibrary['id'],
                          "pageType": eLibrary['pageType'],
                        },
                      )
                    : Center();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: boxDecoration(
                radius: 10,
                showShadow: true,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    child: eLibrary['thumbnail'] != null
                        ? PNetworkImage(
                            eLibrary['thumbnail'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            // height: h(25),
                          )
                        : Image.asset("assets/images/placeholder.png"),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 0, top: 8),
                    child: text(
                      ReCase(eLibrary['name']).titleCase,
                      fontFamily: fontSemibold,
                      maxLine: 2,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
