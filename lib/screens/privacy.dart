import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const content = '''
    FruitPlus is the first private agricultural processor in Dubai that aims to improve, 
    improve and optimize all components of the agricultural supply chain. 
    The most advanced method of managing agricultural supply chains in the world today is Contract Farming, 
    which ensures maximum elimination of intermediaries, enhancing farmers
    ' livelihoods, direct supply of "from home to home" agricultural products and 
    strict application of health and quality standards. On food production.
     Therefore, FruitPlus considers its main concern to promote this method in Dubai 
     and by the end of 2019, it will provide users with at least 25% of all products 
     offered in its online store in a conventional agricultural manner.
''';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).agreeWithPrivacy,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            content,
            style: TextStyle(fontSize: 15.0, height: 1.4),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
