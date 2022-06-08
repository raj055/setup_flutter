// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:crypto/crypto.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart' hide Response;
// import 'package:package_info/package_info.dart';
//
// import '../services/storage.dart';
// import '../utils/label_texts.dart';
// import '../widget/theme.dart';

// class Translator {
//   static Map<String, dynamic> _translatedTexts = {};
//
//   static List translations;
//
//   static String labelTextMd5 = generateMd5(jsonEncode(LabelTexts.texts));
//
//   static init() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String version = packageInfo.version;
//     List storeLangs = await Storage.get('stored-lang') ?? [];
//     String lang = await Storage.get('app-lang');
//
//     if (storeLangs.length > 0) {
//       int _index = storeLangs.indexWhere((s) => s['lang'] == lang);
//
//       if (_index > -1 && storeLangs[0]['labelText'] == labelTextMd5 && storeLangs[0]['appVersion'] == version) {
//         storeLangs.map((single) {
//           if (single['lang'] == lang && single['value'] != null) {
//             _translatedTexts = single['value'];
//           }
//         }).toList();
//       } else {
//         Storage.delete('stored-lang');
//
//         await translate();
//       }
//     } else {
//       await translate();
//     }
//   }
//
//   static Future translate({showLoading}) async {
//     if (showLoading != null && showLoading) {
//       showLoadingDialog();
//     }
//     _translatedTexts = {};
//
//     String lang = await Storage.get('app-lang');
//     List storeLangs = await Storage.get('stored-lang') ?? [];
//     bool isStore = false;
//     int _index;
//     // log(json.encode(storeLangs));
//
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//
//     String version = packageInfo.version;
//
//     if (lang == null || lang == 'en') {
//       LabelTexts.texts.forEach((text) {
//         _translatedTexts.putIfAbsent(text.toLowerCase(), () => text);
//       });
//       return Future.value();
//     }
//
//     LabelTexts.fixedTranslatedTexts.forEach((key, value) {
//       if (LabelTexts.texts.contains(key)) {
//         if (lang == 'hi' && LabelTexts.fixedTranslatedTexts[key].containsKey('hi')) {
//           _translatedTexts.putIfAbsent(
//             key.toLowerCase(),
//             () => LabelTexts.fixedTranslatedTexts[key]['hi'],
//           );
//         } else if (lang == 'gu' && LabelTexts.fixedTranslatedTexts[key].containsKey('gu')) {
//           _translatedTexts.putIfAbsent(
//             key.toLowerCase(),
//             () => LabelTexts.fixedTranslatedTexts[key]['gu'],
//           );
//         } else if (lang == 'ml' && LabelTexts.fixedTranslatedTexts[key].containsKey('ml')) {
//           _translatedTexts.putIfAbsent(
//             key.toLowerCase(),
//             () => LabelTexts.fixedTranslatedTexts[key]['ml'],
//           );
//         } else if (lang == 'bn' && LabelTexts.fixedTranslatedTexts[key].containsKey('bn')) {
//           _translatedTexts.putIfAbsent(
//             key.toLowerCase(),
//             () => LabelTexts.fixedTranslatedTexts[key]['bn'],
//           );
//         } else if (lang == 'kn' && LabelTexts.fixedTranslatedTexts[key].containsKey('kn')) {
//           _translatedTexts.putIfAbsent(
//             key.toLowerCase(),
//             () => LabelTexts.fixedTranslatedTexts[key]['kn'],
//           );
//         } else if (lang == 'te' && LabelTexts.fixedTranslatedTexts[key].containsKey('te')) {
//           _translatedTexts.putIfAbsent(
//             key.toLowerCase(),
//             () => LabelTexts.fixedTranslatedTexts[key]['te'],
//           );
//         }
//       }
//     });
//
//     if (storeLangs.length > 0) {
//       _index = storeLangs.indexWhere((s) => s['lang'] == lang);
//
//       if (_index > -1) {
//         storeLangs.map((single) {
//           if (single['lang'] == lang && single['value'] != null) {
//             _translatedTexts = single['value'];
//             isStore = true;
//           }
//         }).toList();
//       }
//     }
//
//     if (!isStore) {
//       Dio http = new Dio();
//
//       int max = LabelTexts.texts.length;
//       int pageLength = 99;
//       int start = 0;
//
//       while (start < max) {
//         int end = start + pageLength;
//         int maxRange;
//         if (end >= max) {
//           end = max;
//           maxRange = end;
//         } else {
//           maxRange = end + 1;
//         }
//
//         await http.post(
//           'https://translation.googleapis.com/language/translate/v2',
//           queryParameters: {
//             "key": dotenv.env['GOOGLE_API_KEY'],
//           },
//           data: {
//             "q": LabelTexts.texts.getRange(start, maxRange).map((text) => text.toLowerCase()).toList(),
//             "target": lang,
//           },
//         ).then((Response response) {
//           translations = response.data['data']['translations'].map((translation) {
//             return translation['translatedText'];
//           }).toList();
//
//           translations.asMap().forEach((index, translation) {
//             _translatedTexts.putIfAbsent(LabelTexts.texts[index + start].toLowerCase(), () => translation);
//           });
//         }).catchError((error) {});
//
//         start = end + 1;
//       }
//
//       if (storeLangs == null || storeLangs.length == 0) {
//         Storage.set(
//           'stored-lang',
//           [
//             {
//               "lang": lang,
//               "value": _translatedTexts,
//               "labelText": labelTextMd5,
//               "appVersion": version,
//             }
//           ],
//         );
//       } else {
//         if (_index == -1) {
//           storeLangs.add({
//             "lang": lang,
//             "value": _translatedTexts,
//             "labelText": labelTextMd5,
//             "appVersion": version,
//           });
//           Storage.set('stored-lang', storeLangs);
//         }
//       }
//     }
//   }
//
//   static String get(String text) {
//     if (_translatedTexts.containsKey(text.toLowerCase())) {
//       return _translatedTexts[text.toLowerCase()];
//     } else {
//       throw new Exception("Text $text is not defined for translation.");
//     }
//   }
//
//   static void showLoadingDialog() {
//     Get.dialog(
//       WillPopScope(
//           onWillPop: () async => false,
//           child: SimpleDialog(backgroundColor: colorPrimary, children: <Widget>[
//             Center(
//               child: Column(children: [
//                 CircularProgressIndicator(
//                     valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFF6F5F8).withOpacity(0.9))),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Text(
//                   "Please Wait..",
//                   style: TextStyle(
//                     color: Color(0xFFF6F5F8).withOpacity(0.9),
//                   ),
//                 )
//               ]),
//             )
//           ])),
//       barrierDismissible: false,
//     );
//   }
//
//   static String generateMd5(dynamic input) {
//     return md5.convert(utf8.encode(jsonEncode(input))).toString();
//   }
//
//   static void hideLoadingDialog() {
//     if (Get.isDialogOpen) {
//       Get.back();
//     }
//   }
// }

import 'dart:developer';

import '../services/storage.dart';
import '../utils/label_texts.dart';

class Translator {
  static Map<String?, dynamic>? _translatedTexts = {};

  static List? translations;

  static init() async {
    String? lang = await Storage.get('app-lang');

    if (lang == 'en') {
      LabelTexts.texts.forEach((text) {
        _translatedTexts!.putIfAbsent(text.toLowerCase(), () => text);
      });
    } else {
      await Storage.get('stored-lang').then((language) {
        language.map((e) {
          if (lang == e['lang']) {
            _translatedTexts = e['value'];
          }
          /*else {
            LabelTexts.texts.forEach((text) {
              _translatedTexts.putIfAbsent(text.toLowerCase(), () => text);
            });
          }*/
        }).toList();
      });
    }
  }

  static String? get(String text) {
    if (_translatedTexts!.containsKey(text.toLowerCase())) {
      return _translatedTexts![text.toLowerCase()];
    } else {
      return text;
    }
  }

  static Future translate({showLoading}) async {
    String? lang = await Storage.get('app-lang');
    await Storage.get('stored-lang').then((language) {
      log("language $language");
      language.map((e) {
        if (lang == e['lang']) {
          _translatedTexts = e['value'];
        } else if (lang == "en") {
          _translatedTexts = {};
          LabelTexts.texts.forEach((text) {
            _translatedTexts!.putIfAbsent(text.toLowerCase(), () => text);
          });
        }
      }).toList();
    });
  }
}
