import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:restroapp/src/models/IpayOrderData.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';

class InAppWebViewPage extends StatefulWidget {
  Ipay88OrderData responseModel;
  String storeID;

  InAppWebViewPage(this.responseModel, this.storeID);

  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  InAppWebViewController _webViewController;
  ContextMenu contextMenu;

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                var selectedText = await _webViewController.getSelectedText();
                await _webViewController.clearFocus();
                await _webViewController.evaluateJavascript(
                    source: "window.alert('You have selected: $selectedText')");
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await _webViewController.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("InAppWebView")),
        body: Container(
            child: Column(children: <Widget>[
          Expanded(
            child: Container(
              child: InAppWebView(
                initialUrl: "${widget.responseModel.data.url}",
                contextMenu: contextMenu,
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadStart: (InAppWebViewController controller, String url) {
                  print("onLoadStart popup $url");
                  {
                    print('==2====onLoadStop======: $url');
                    if (url.contains("ipay88/ipay88ResUrl") &&
                        url.contains("Status=1")) {
                      String status = url.substring(
                          url.indexOf("&Status=") + "&Status=".length);
                      url = url.replaceAll("&Status=" + status, "");
                      String transId = url.substring(
                          url.indexOf("&TransId=") + "&TransId=".length);
                      url = url.replaceAll("&TransId=" + transId, "");
                      String requestId = url.substring(
                          url.indexOf("payment_request_id=") +
                              "payment_request_id=".length);
                      print(requestId);
                      print(transId);
                      print(status);
                      eventBus.fire(
                          onIPay88Finished(url, requestId, transId, status));
                      Navigator.pop(context);
                    } else if (url.contains("ipay88/ipay88ResUrl") &&
                        url.contains("Status=0")) {
                      Navigator.pop(context);
                      String status = url.substring(
                          url.indexOf("&Status=") + "&Status=".length);
                      url = url.replaceAll("&Status=" + status, "");
                      String transId = url.substring(
                          url.indexOf("&TransId=") + "&TransId=".length);
                      url = url.replaceAll("&TransId=" + transId, "");
                      String requestId = url.substring(
                          url.indexOf("payment_request_id=") +
                              "payment_request_id=".length);
                      print(requestId);
                      print(transId);
                      print(status);
                      print(
                          "------------------------Showing TOAST-------------------------------");
                      Utils.showToast("Payment Failed", false);
                    }
                  }
                },
                onLoadStop: (InAppWebViewController controller, String url) {
                  print("onLoadStop popup $url");
                  Navigator.pop(context);
                  Utils.showToast("Payment Failed", false);
                },
              ),
            ),
          ),
        ])));
  }
}
