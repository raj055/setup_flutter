import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api.dart';
import '../../services/translator.dart';
import '../../widget/theme.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  Future? _contactApi;

  Future _futureBuild() {
    return Api.http.get('contact-info').then(
      (res) {
        return res.data;
      },
    );
  }

  @override
  void initState() {
    _contactApi = _futureBuild();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _contactApi,
      builder: (context, AsyncSnapshot? snapshot) {
        if (!snapshot!.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        Map contactDetails = snapshot.data['data'];

        return Scaffold(
          appBar: AppBar(
            title: Text(Translator.get('Contact Us')!),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/facebook.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      text(
                        Translator.get(dotenv.env['APP_NAME']!),
                        fontFamily: fontBold,
                        fontSize: textSizeLargeMedium,
                        textColor: textColorPrimary,
                      ),
                      SizedBox(height: 10),
                      text(
                        contactDetails['address'],
                        isLongText: true,
                        fontSize: textSizeLargeMedium,
                      ),
                      SizedBox(height: 5.0),
                      text(
                        contactDetails['city'] + " - " + contactDetails['pincode'] + "\n" + contactDetails['state'],
                        fontSize: textSizeLargeMedium,
                        maxLine: 2,
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: <Widget>[
                          text(
                            '${Translator.get('Phone no')} : ',
                            fontSize: textSizeLargeMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              launch("tel:${contactDetails['mobile']}");
                            },
                            child: text(
                              contactDetails['mobile'],
                              fontSize: textSizeLargeMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          launch('mailto:${contactDetails['email']}');
                        },
                        child: text(
                          "${Translator.get('Email')} : " + contactDetails['email'],
                          fontSize: textSizeLargeMedium,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
