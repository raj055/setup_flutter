import 'package:flutter/material.dart';

import '../../services/translator.dart';
import '../../widget/theme.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('About Us')!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/15.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  text(
                    Translator.get(
                        'Winning Team was started by Leading Motivational Speaker ,Educator,Business Consultant ,a Successful Entrepreneur and success icon for many Indians Mr.SP Bharill.Its headquarters is in Jaipur and it is oprating in many states of india.We aspire to go global in the time to come and serve our associates worldwide.'),
                    fontSize: textSizeMedium,
                    isLongText: true,
                  ),
                  SizedBox(height: 20),
                  text(
                    Translator.get(
                        "Winning team's purpose is to identify the needs and provides business solutions and empowering peole to realize their dreams,provding them with the best education to build the long term,sustainable, profitable,duplicatable & biggest independent business with values & principles."),
                    fontSize: textSizeMedium,
                    isLongText: true,
                  ),
                  SizedBox(height: 20),
                  text(
                    Translator.get(
                        "Winning team is one of the best education and vocational traning companies in India."),
                    fontSize: textSizeMedium,
                    isLongText: true,
                  ),
                  SizedBox(height: 20),
                  text(
                    Translator.get(
                        "It provides education ,personality development trainong,workshops and seminars.The aim is to inspire and encourages people,making them to realize their true potential to filfill their dreams.This is one of the major areas in which Winning Team is involves."),
                    fontSize: textSizeMedium,
                    isLongText: true,
                  ),
                  SizedBox(height: 20),
                  text(
                    Translator.get(
                        "Winning Team stands for Intigrity,Commitment,Excellence and Unity.It has been stadfast in adhering to its business values and ethics as a result ,it has earned the trustof people in India."),
                    fontSize: textSizeMedium,
                    isLongText: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
