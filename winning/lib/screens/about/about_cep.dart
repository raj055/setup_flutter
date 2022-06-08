import 'package:flutter/material.dart';

import '../../services/translator.dart';
import '../../widget/theme.dart';

class AboutCep extends StatefulWidget {
  @override
  _AboutCepState createState() => _AboutCepState();
}

class _AboutCepState extends State<AboutCep> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('About CEP')!),
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
                      'assets/images/aboutcep.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  text(
                    Translator.get(
                        'Winning Team was started by Leading Motivational Speaker,Educator,Business Consultant,a Successful Entrepreneur and sucess icon for many Indians Mr.SP Bharill.Its headquarters is in Jaipur and it is operating in many states of India.We aspire to go global in the time to come and serve our associates worldwide Winning teams purpose is to identify the needs and provide business solutions and empowering people to realize their dreams,providing them with the best education to build the long term,sustainable,business with values & principles.Winning team is one of the best education and vocational training companies in India.It provides education,personality development trainings,workshops and seminars.The aim is to inspire and encourages people,making them to realize their true potential to fulfill their dreams.This is one of the major areas in which Winning Team is involved.Winning Team stands for integrity,Commitment,Excellence and Unity.It has been steadfast in adhering to its business values and ethics;as a result,it has earned the trust of people in india.'),
                    fontSize: textSizeLargeMedium,
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
