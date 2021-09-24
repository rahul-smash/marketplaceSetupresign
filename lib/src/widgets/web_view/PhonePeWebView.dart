import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restroapp/src/apihandler/ApiConstants.dart';
import 'package:restroapp/src/models/PhonePeResponse.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PhonePeWebView extends StatelessWidget {
  PhonePeResponse responseModel;
  Completer<WebViewController> _controller = Completer<WebViewController>();
  String storeID;

  PhonePeWebView(this.responseModel, this.storeID);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        //print("onWillPop onWillPop");
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Used for removing back buttoon.
          title: Text('Payment'),
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl: '${responseModel.data.data.redirectUrl}',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            navigationDelegate: (NavigationRequest request) {
              //print('=======NavigationRequest======= $request}');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('======Page started loading======: $url');
            },
            onPageFinished: (String url) {
              print('==2====onLoadStop======: $url');
              // if (url.contains("/peachpay/peachPayVerify?id=")) {
              //   String resourcePath =
              //   url.substring(
              //       url.indexOf("&resourcePath=") + "&resourcePath=".length);
              //   url = url.replaceAll("&resourcePath=" + resourcePath, "");
              //   String checkoutID = url
              //       .substring(url.indexOf("?id=") + "?id=".length);
              //   print(resourcePath);
              //   print(checkoutID);
              //   eventBus.fire(
              //       onPeachPayFinished(url, checkoutID, resourcePath));
              //   Navigator.pop(context);
              // } else if (url.contains("failure")) {
              //   Navigator.pop(context);
              //   Utils.showToast("Payment Failed", false);
              // }
            },
            gestureNavigationEnabled: false,
          );
        }),
      ),
    );
  }
}
