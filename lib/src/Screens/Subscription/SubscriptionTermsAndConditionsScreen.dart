import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class SubscriptionTermsAndConditionsScreen extends StatelessWidget {
  String appScreen;
  String htmlData = '';

  SubscriptionTermsAndConditionsScreen(this.appScreen, this.htmlData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(appScreen),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Html(
            data: htmlData,
            padding: EdgeInsets.all(10.0),
            customTextStyle: (node, base) {
              return TextStyle(fontSize: 16);
            },
          ),
        ),
      ),
    );
  }
}
