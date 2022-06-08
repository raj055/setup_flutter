import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart' hide Response;

import '../services/auth.dart';
import '../services/size_config.dart';
import '../services/storage.dart';
import '../services/translator.dart';
import '../widget/theme.dart';

class AppLanguage extends StatefulWidget {
  @override
  _AppLanguageState createState() => _AppLanguageState();
}

class _AppLanguageState extends State<AppLanguage> {
  List<LanguageModel> _languages = [
    LanguageModel(
      'en',
      'English',
      ConfirmDialogModel(
          'Change Language', 'You can change the language anytime through your language settings.', 'Yes', 'No'),
    ),
    LanguageModel(
      'hi',
      'हिन्दी',
      ConfirmDialogModel('भाषा बदलो', 'आप अपनी भाषा सेटिंग के माध्यम से कभी भी भाषा बदल सकते हैं।', 'हाँ', 'नहीं'),
    ),
    LanguageModel(
      'gu',
      'ગુજરાતી',
      ConfirmDialogModel('ભાષા બદલો', 'તમે તમારી ભાષા સેટિંગ્સ દ્વારા કોઈપણ સમયે ભાષા બદલી શકો છો.', 'હા', 'ના'),
    ),
    LanguageModel(
      'ml',
      'മലയാളം',
      ConfirmDialogModel('ഭാഷ മാറ്റുക',
          'നിങ്ങളുടെ ഭാഷാ ക്രമീകരണങ്ങളിലൂടെ നിങ്ങൾക്ക് എപ്പോൾ വേണമെങ്കിലും ഭാഷ മാറ്റാൻ കഴിയും.', 'അതെ', 'ഇല്ല'),
    ),
    LanguageModel(
      'bn',
      'বাংলা',
      ConfirmDialogModel('ভাষা পরিবর্তন করুন',
          'আপনি আপনার ভাষা সেটিংসের মাধ্যমে যে কোনও সময় ভাষা পরিবর্তন করতে পারেন।', 'হ্যাঁ', 'না'),
    ),
    LanguageModel(
      'kn',
      'ಕನ್ನಡ',
      ConfirmDialogModel(
          'ಭಾಷೆ ಬದಲಿಸಿ', 'ನಿಮ್ಮ ಭಾಷಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳ ಮೂಲಕ ನೀವು ಯಾವಾಗ ಬೇಕಾದರೂ ಭಾಷೆಯನ್ನು ಬದಲಾಯಿಸಬಹುದು.', 'ಹೌದು', 'ಇಲ್ಲ'),
    ),
    LanguageModel(
      'te',
      'తెలుగు',
      ConfirmDialogModel('భాష మార్చు', 'మీరు మీ భాషా సెట్టింగ్‌ల ద్వారా ఎప్పుడైనా భాషను మార్చవచ్చు.', 'అవును', 'లేదు'),
    ),
  ];

  String? defaultLanguage;
  bool? firstTime = false;

  @override
  initState() {
    defaultLanguage = '';
    Map? arg = Get.arguments;
    if (arg != null) firstTime = arg['firstTime'];
    _fetchCurrentAppLanguage();
    super.initState();
  }

  Future<Null> _fetchCurrentAppLanguage() async {
    String? storedLang = await Storage.get('app-lang');
    setState(() {
      defaultLanguage = storedLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (firstTime!) {
          Get.offAllNamed('login');
          return Future.delayed(Duration.zero, () => true);
        }
        return Future.delayed(Duration.zero, () => true);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorPrimary, colorAccent],
                    ),
                    color: colorPrimary,
                  ),
                  child: Column(
                    children: [
                      Text(
                        Translator.get('Choose Your Language')!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_languages.length > 0)
                  for (int index = 0; index < _languages.length; index++)
                    GestureDetector(
                      onTap: () {
                        if (!firstTime! && defaultLanguage == _languages[index].languageCode) {
                          String? text = Translator.get("Already selected language!!!");
                          GetBar(
                            duration: Duration(seconds: 3),
                            message: text != null ? text : "No data",
                            backgroundColor: Colors.red,
                          ).show();
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return languageConfirm(context, _languages[index]);
                              });
                        }
                      },
                      child: ListTile(
                        leading: Icon(Icons.translate),
                        title: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  _languages[index].languageName,
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(width: w(2)),
                                Text(
                                  '(${_languages[index].languageCode})',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: defaultLanguage == _languages[index].languageCode ? Icon(Icons.check_circle) : null,
                      ),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget languageConfirm(BuildContext context, LanguageModel lang) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0)),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Image(
                width: MediaQuery.of(context).size.width,
                image: AssetImage('assets/images/langauge.jpg'),
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 5),
            text(
              lang.dialogModel.dialogTitle,
              fontFamily: fontBold,
              textColor: colorPrimaryDark,
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                bottom: 15,
              ),
              child: text(
                lang.dialogModel.dialogMessage,
                isLongText: true,
              ),
            ),
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
                      Feather.x,
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
                      defaultLanguage = lang.languageCode;
                      _setPrefferdLanguage();
                    },
                    child: Icon(
                      Feather.check,
                      color: green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setPrefferdLanguage() async {
    if (await Storage.get('app-lang') != defaultLanguage) {
      await Storage.set('app-lang', defaultLanguage);
      Get.back();
      // await Translator.translate();
      await Translator.translate(showLoading: true);
    }
    if (firstTime!) {
      Get.offAllNamed('login');
    } else if (Auth.currentPackage() == 1) {
      Get.offAllNamed('guest-dashboard');
    } else {
      Get.offAllNamed('home');
    }
  }
}

class LanguageModel {
  String languageCode;
  String languageName;
  ConfirmDialogModel dialogModel;

  LanguageModel(this.languageCode, this.languageName, this.dialogModel);
}

class ConfirmDialogModel {
  String dialogTitle;
  String dialogMessage;
  String dialogYes;
  String dialogNo;

  ConfirmDialogModel(this.dialogTitle, this.dialogMessage, this.dialogYes, this.dialogNo);
}
