import 'package:flutter/material.dart';

import '../../services/translator.dart';

class AboutVestige extends StatefulWidget {
  @override
  _AboutVestigeState createState() => _AboutVestigeState();
}

class _AboutVestigeState extends State<AboutVestige> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translator.get('About Vestige')!),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                      'assets/images/aboutVestige.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    Translator.get(
                        'Vestige Marketing Pvt.Ltd ,wgich started its operations in the year 2004,is a leading direct selling company dealing in world class health and personal care products.Vestige is constantly growing at a phenomenal rate every year.The growth rate in itself speaks volumes about the quality of the products,the marketing plan and the management that has been able to deliver such a rewarding and sustainable system.')!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    Translator.get(
                        "Vestige is constantly expanding its product range to introduce innovative products every year, manufactured at state-of-the-art manufacturing facilities,which are GMP certified.Vestige is an ISO 9001-2015 certified company and believes in offering world class service levels to all its customers.With over 2000+ online and offline sales outlets pan India,one international office  and several distributor centres .Vestige has built  a widespread network of distributors,which is constantly expanding every year.")!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    Translator.get(
                        "Vestige believes in empowering its members with the opportunity to lead their lives on their own terms.With the motto of spreading Wellth,i.e. spreading wealth throught wellness,Vestige has continued to enrich the lives of everyone who is a part of the company and those who belives in its products.")!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87.withOpacity(0.8),
                    ),
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
