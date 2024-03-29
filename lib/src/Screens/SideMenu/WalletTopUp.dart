import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:restroapp/src/Screens/BookOrder/ConfirmOrderScreen.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/CreateOrderData.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/PeachPayCheckOutResponse.dart';
import 'package:restroapp/src/models/PeachPayVerifyResponse.dart';
import 'package:restroapp/src/models/PhonePeResponse.dart';
import 'package:restroapp/src/models/PhonePeVerifyResponse.dart';
import 'package:restroapp/src/models/RazorpayError.dart';
import 'package:restroapp/src/models/StripeCheckOutModel.dart';
import 'package:restroapp/src/models/StripeVerifyModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/models/WalletOnlineTopUp.dart';
import 'package:restroapp/src/models/RazorPayTopUP.dart';
import 'package:restroapp/src/models/RazorpayOrderData.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/WalletModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/widgets/web_view/PhonePeWebView.dart';

class WalletTopUp extends StatefulWidget {
  WalletModel walleModel;

  WalletTopUp(BrandData passedStore, this.walleModel,){
    store=BrandData.fromJson(jsonDecode(jsonEncode(passedStore)));
  }

  BrandData store;

  @override
  _WalletTopUpState createState() {
    return _WalletTopUpState(walleModel);
  }
}

class _WalletTopUpState extends State<WalletTopUp> {
  WalletModel walleModel;
  final _enterMoney = new TextEditingController();

  Razorpay _razorpay;

  bool isPayTmSelected = false;
  bool isAnotherOnlinePaymentGatwayFound = false;
  bool isPayTmActive = false;

  _WalletTopUpState(
    this.walleModel,
  );

  StreamSubscription onPayTMPageFinishedStream,
      onPhonePePageFinishedStream,
      onPeachPayFinishedStream,onStripeFinishedStream;

  @override
  void initState() {
    super.initState();
    initRazorPay();

    ApiController.getUserWallet().then((response) {
      setState(() {
        this.walleModel = response;
      });
    });

    //event bus
    onPayTMPageFinishedStream =
        eventBus.on<onPayTMPageFinished>().listen((event) {
      callWalletOnlineTopApi(event.orderId, event.txnId, event.amount, 'paytm');
    });

    onPhonePePageFinishedStream =
        eventBus.on<onPhonePeFinished>().listen((event) {
      callPhonePeFinishedOrderApi(
          event.paymentRequestId, event.transId, event.amount);
    });
    onPeachPayFinishedStream =
        eventBus.on<onPeachPayFinished>().listen((event) {
      print("Event Bus called");
      callPeachPayPaytmOrderApi(
          event.url, event.checkoutID, event.resourcePath, event.amount);
    });
    onStripeFinishedStream =
        eventBus.on<onPageFinished>().listen((event) {
          print("<---onPageFinished------->");
          callStripeVerificationApi(event.url,event.amount);
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (onPayTMPageFinishedStream != null) onPayTMPageFinishedStream.cancel();
    if (onPhonePePageFinishedStream != null)
      onPhonePePageFinishedStream.cancel();
    if (onPeachPayFinishedStream != null) onPeachPayFinishedStream.cancel();
    if (onStripeFinishedStream != null) onStripeFinishedStream.cancel();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          elevation: 0,
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SafeArea(
              child: GestureDetector(
                onTap: () {
                  Utils.hideKeyboard(context);
                },
                child: Container(
                  child: Column(
                    children: [
                      Container(
                          color: appTheme,
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Wallet Balance",
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 16),
                                  ),
                                  walleModel == null
                                      ? Container()
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              child: Text(
                                                  "${AppConstant.currency}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16)),
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 1, 0, 0),
                                            ),
                                            Text(
                                                "${walleModel.data.userWallet}",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24)),
                                          ],
                                        ),
                                  SizedBox(
                                    height: 50,
                                  )
                                ],
                              ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: Image.asset(
                                  "images/walletbalancegreaphics.png",
                                  width: 200,
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(height: 50, color: appTheme),
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                          ),
                                          Text(
                                            'TopUp amount',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey[400],
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      30, 0, 0, 0),
                                                  child: Text(
                                                    AppConstant.currency,
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Flexible(
                                                child: Container(
                                                  width: 100,
                                                  //margin: EdgeInsets.fromLTRB(0,0,0,0),
                                                  child: TextFormField(
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      new LengthLimitingTextInputFormatter(
                                                          15),
                                                    ],
                                                    onChanged: (text) {
                                                      print(text);
                                                      print(
                                                          '${_enterMoney.text}');
                                                    },
                                                    controller: _enterMoney,
                                                    textAlign: TextAlign.left,
                                                    decoration: InputDecoration(
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      hintStyle: TextStyle(
                                                          fontSize: 20),
                                                      hintText: widget
                                                          .store
                                                          .walletSettings
                                                          .defaultTopUpAmount,
                                                      border: InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                            height: 1.8,
                                            indent: 60,
                                            endIndent: 60,
                                          ),
                                          // SizedBox(height: 250,),
                                        ],
                                      ),
                                      Visibility(
                                        visible: widget.store.walletSettings
                                                    .status ==
                                                '1' &&
                                            widget.store.walletSettings
                                                    .customerWalletTopUpStatus ==
                                                '1',
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 50),
                                          width: 180,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              print(
                                                  'Button pressed ${_enterMoney.text}');
                                              setState(() {
                                                checkTopUpCondition(
                                                    _enterMoney);
                                              });
                                            },
                                            child: Text('Submit'),
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(appTheme),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkTopUpCondition(TextEditingController enterMoney) async {
    //If user not entered his own amount then pick default amount
    String amount = enterMoney.text.trim().isNotEmpty
        ? enterMoney.text.trim()
        : widget.store.walletSettings.defaultTopUpAmount;

    double wallet_balance = double.parse(walleModel.data.userWallet);

    double topupAmount = double.parse(amount);
    double minTopUpLimit =
        double.parse(widget.store.walletSettings.minTopUpAmount);
    double maxTopUpLimit =
        double.parse(widget.store.walletSettings.maxTopUpAmount);
    double maxWalletHoldingLimit =
        double.parse(widget.store.walletSettings.maxTopUpHoldAmount);
//minTopUpLimit
    if (topupAmount < minTopUpLimit) {
      print("Min top Up amount is ${minTopUpLimit}");

      Utils.showToast(
          'Min top Up amount is ${widget.store.walletSettings.minTopUpAmount}',
          false);
    } else if (topupAmount > maxTopUpLimit) {
      print("Maximum topup limit is ${maxTopUpLimit}");
      Utils.showToast(
          'Maximum topup limit is ${widget.store.walletSettings.maxTopUpAmount}',
          false);
    } else if (maxWalletHoldingLimit < (topupAmount + wallet_balance)) {
      Utils.showToast(
          'Your total wallet holding capacity is ${widget.store.walletSettings.maxTopUpHoldAmount}',
          false);
    } else {
      //callRazorPayToken(amount, storeObject);
      showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(20)),
              color: Colors.white,
            ),
            height: 170,
            child: ListView.builder(
                itemCount: 1,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: appTheme,
                      border: Border.all(
                        color: appTheme,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: ListTile(
                      onTap: () async {
                        //TODO: Due to client requirement, we don't show ipay88 and peachpay
                        removeIpayAndPeachPay();
                        Navigator.pop(context);
                        String result = await DialogUtils
                            .displayMultipleOnlinePaymentMethodDialog(
                                context, widget.store);
                        if (result.isEmpty) {
                          return;
                        }

                        callPaymentGateWay(result, amount);
                        // if (paymentGatewaySettings.paymentGateway
                        //     .toLowerCase()
                        //     .contains('paytm')) {
                        //   Navigator.pop(context);
                        //   // callPayTmApi(amount, storeObject);
                        // } else if (paymentGatewaySettings.paymentGateway
                        //     .toLowerCase()
                        //     .contains('razorpay')) {
                        //   Navigator.pop(context);
                        //   callRazorPayToken(amount, widget.store);
                        // }
                      },
                      title: Text(
                        // '* ${paymentGatewaySettings.paymentGateway}',
                        '* Online',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
          );
        },
      );
    }
  }

  callPaymentGateWay(String paymentGateway, String amount) async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if (!isNetworkAvailable) {
      Utils.showToast(AppConstant.noInternet, false);
      return;
    }
    UserModelMobile user = await SharedPrefs.getUserMobile();
    String userId = user.id;
    switch (paymentGateway) {
      case "Razorpay":
        callRazorPayToken(amount, widget.store);
        break;
      case "Stripe":
        // Utils.showToast("Under Development", false);
        callStripeApi(amount);
        break;
      case "Paytmpay":
        Utils.showToast("Under Development", false);
        break;
      case "Phonepe":
        // Utils.showToast("Under Development", false);
        Utils.showProgressDialog(context);
        ApiController.phonepeCreateOrderApi(
                // double.parse('1').toStringAsFixed(2),
                double.parse('1').toStringAsFixed(2),
                '',
                '',
                widget.store.walletSettings.storeId,
                widget.store.currencyAbbr,
                merchantUserId: userId)
            .then((response) {
          PhonePeResponse model = response;
          if (model != null && response.success) {
            // Hit createOnlineTopUpApi
            ApiController.createOnlineTopUPApi(
                    amount, model.paymentRequestId, "Phonepe")
                .then((response) {
              RazorPayTopUP modelPay = response;
              Utils.hideProgressDialog(context);
              if (modelPay != null && response.success) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhonePeWebView(
                            model,
                            widget.store.walletSettings.storeId,
                            amount: amount,
                          )),
                );
              } else {
                Utils.showToast("Error", true);
                Utils.hideProgressDialog(context);
              }
            });
          }
        });
        break;
      case "PeachPayments":
        Utils.showToast("Under Development", false);
        ApiController.peachPayCreateOrderApi(
                amount,
                '',
                '',
                widget.store.walletSettings.storeId,
                widget.store.currencyAbbr.trim())
            .then((response) {
          PeachPayCheckOutResponse model = response;
          if (model != null && response.success) {
            ApiController.createOnlineTopUPApi(
                    amount, model.data.id, "Peachpay")
                .then((response) {
              RazorPayTopUP modelPay = response;
              Utils.hideProgressDialog(context);
              if (modelPay != null && response.success) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PeachPayWebView(
                          model, widget.store.walletSettings.storeId,
                          amount: amount)),
                );
              } else {
                Utils.showToast("Error", true);
                Utils.hideProgressDialog(context);
              }
            });
          } else {
            Utils.showToast("Server Error", true);
          }
        });
        break;
    }
  }

  //-----------------------------------------------------------------------------------------------
  //RazorPay Code Start
  callRazorPayToken(String mPrice, BrandData store) {
    double price = double.parse(mPrice); //totalPrice ;
    print("=======1===${price}===total==${mPrice}======");
    price = price * 100;
    print("=======2===${price}===========");
    String mPriceUpdated =
        price.toString().substring(0, price.toString().indexOf('.'));
    Utils.showProgressDialog(context);
    ApiController.razorpayCreateOrderApi(
            mPriceUpdated, "", "", "0", widget.store.currencyAbbr)
        .then((response) {
      CreateOrderData model = response;
      if (model != null && response.success) {
        print("----razorpayCreateOrderApi----${response.data.id}--");
        print("----razorpayCreateOrderApi----${response}--");
        // Hit createOnlineTopUpApi
        ApiController.createOnlineTopUPApi(mPrice, model.data.id, "razorpay")
            .then((response) {
          RazorPayTopUP modelPay = response;
          Utils.hideProgressDialog(context);
          if (modelPay != null && response.success) {
            //Opening Gateway
            openCheckout(store, mPrice, model.data.id);
          } else {
            Utils.showToast("${model.message}", true);
            Utils.hideProgressDialog(context);
          }
        });
      } else {
        print('def123');
        Utils.showToast("${model.message}", true);
        Utils.hideProgressDialog(context);
      }
    });
  }
  void callStripeApi(String amount) {
    Utils.showProgressDialog(context);
    double price = double.parse(amount);
    price = price * 100;
    print("----taxModel.total----${amount}--");
    String mPrice =
    price.toString().substring(0, price.toString().indexOf('.')).trim();
    print("----mPrice----${mPrice}--");
    ApiController.stripePaymentApi(mPrice, widget.store.walletSettings.brandId,currency: widget.store.currencyAbbr.trim()).then((response) {
      Utils.hideProgressDialog(context);
      print("----stripePaymentApi------");
      if (response != null) {
        StripeCheckOutModel stripeCheckOutModel = response;
        if (stripeCheckOutModel.success) {
          ApiController.createOnlineTopUPApi(mPrice, stripeCheckOutModel.paymentRequestId, "stripe",currency: widget.store.currencyAbbr.trim())
              .then((response) {
            RazorPayTopUP modelPay = response;
            Utils.hideProgressDialog(context);
            if (modelPay != null && response.success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StripeWebView(stripeCheckOutModel,amount: amount,)),
              );
            } else {
              Utils.showToast("${modelPay.message}", true);
              Utils.hideProgressDialog(context);
            }
          });

        } else {
          Utils.showToast("${stripeCheckOutModel.message}!", true);
        }
      } else {
        Utils.showToast("Something went wrong!", true);
      }
    });
  }

  void callStripeVerificationApi(String payment_request_id,String amount) {
    Utils.showProgressDialog(context);
    ApiController.stripeVerifyTransactionApi(payment_request_id, widget.store.walletSettings.brandId)
        .then((response) {
      if (response != null) {
        StripeVerifyModel object = response;
        if (object.success) {
          callWalletOnlineTopApi(object.paymentRequestId, object.paymentId, amount, 'Stripe');
        } else {
          Utils.showToast(
              "Transaction is not completed, please try again!", true);
          Utils.hideProgressDialog(context);
        }
      } else {
        Utils.showToast("Something went wrong!", true);
        Utils.hideProgressDialog(context);
      }
    });
  }

  void openCheckout(
      BrandData storeObject, String mprice, String razorPayID) async {
    Utils.hideProgressDialog(context);
    UserModel user = await SharedPrefs.getUser();
    print('${double.parse(mprice) * 100}');
    //find razor pay key
    String key = '';
    for (var pgs in storeObject.paymentGatewaySettings) {
      if (pgs.paymentGateway.contains('Razorpay')) {
        key = pgs.apiKey;
        break;
      }
    }
    var options = {
      'key': '${key}',
      'currency': 'INR',
      'order_id': razorPayID,
      'amount': (double.parse(mprice).round() * 100),
      'name': '${storeObject.name}',
      'description': '',
      'prefill': {
        'contact': '${user.phone}',
        'email': '${user.email}',
        'name': '${user.fullName}'
      },
    };
    try {
      //open payment gateway
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void initRazorPay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse responseObj) {
    //Show Loading....
    Utils.showProgressDialog(context);
    print(' razorpay------------------------- $responseObj');
    ApiController.razorpayVerifyTransactionApi(responseObj.orderId, '0')
        .then((response) {
      print("----razorpayVerifyTransactionApi----${response}--");
      if (response != null) {
        RazorpayOrderData model = response;
        if (model.success) {
          double amount = model.data.amount / 100;
          callWalletOnlineTopApi(responseObj.paymentId, model.data.id,
              amount.toString(), 'razorpay');
        } else {
          Utils.showToast("Something went wrong!", true);
          Utils.hideProgressDialog(context);
        }
      } else {
        Utils.showToast("Something went wrong!", true);
        Utils.hideProgressDialog(context);
      }
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showFailedDialog();
    try {
      String string = response.message;
      RazorpayError error = RazorpayError.fromRawJson(jsonDecode(string));
      Fluttertoast.showToast(
          msg: error.error.description, timeInSecForIosWeb: 4);
    } catch (e) {}
    print("----_handlePaymentError--message--${response.message}--");
    print("----_handlePaymentError--code--${response.code.toString()}--");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    /*print("----ExternalWalletResponse----${response.walletName}--");
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIos: 4);*/
  }

  Future<void> _showFailedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: const Text(
            'Sorry!',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Center(child: Text('Your transaction has failed.')),
                Center(child: Text('Please go back and try again.')),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    child: ElevatedButton(
                      child: Text('Ok'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(appTheme),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showSuccessDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future(() => false);
          },
          child: AlertDialog(
            title: Center(
                child: const Text(
              'Successful!',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Center(child: Text('Your transaction is successful.')),
                ],
              ),
            ),
            actions: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      child: ElevatedButton(
                        child: Text('Ok'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(appTheme),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void callWalletOnlineTopApi(String paymentId, String paymentRequestId,
      String amount, String paymentType) {
    ApiController.onlineTopUP(paymentId, paymentRequestId, amount, paymentType)
        .then((response) {
      WalletOnlineTopUp modelPay = response;

      Utils.hideProgressDialog(context);
      _showSuccessDialog().then((value) => Navigator.pop(context, true));
    });
  }

  void callPhonePeFinishedOrderApi(
      String paymentRequestId, String transId, String amount) {
    Utils.showProgressDialog(context);
    ApiController.phonePeVerifyTransactionApi(paymentRequestId, '0')
        .then((response) {
      print("----phonePeVerifyTransactionApi----${response}--");
      if (response != null) {
        PhonePeVerifyResponse model = response;
        if (model.success) {
          callWalletOnlineTopApi(paymentRequestId, transId, amount, 'Phonepe');
        } else {
          Utils.hideProgressDialog(context);
          Utils.showToast("payment failed", true);
        }
      } else {
        Utils.hideProgressDialog(context);
        Utils.showToast("Something went wrong!", true);
      }
    });
  }

  void callPeachPayPaytmOrderApi(
      String url, String checkoutID, String resourcePath, String amount) {
    Utils.showProgressDialog(context);
    ApiController.peachPayVerifyTransactionApi(
            checkoutID, widget.store.walletSettings.storeId)
        .then((response) {
      Utils.hideProgressDialog(context);
      //print("----razorpayVerifyTransactionApi----${response}--");
      if (response != null) {
        PeachPayVerifyResponse model = response;
        if (model.success) {
          callWalletOnlineTopApi(
              model.data.checkoutId, model.data.id, amount, 'Phonepe');
        } else {
          Utils.hideProgressDialog(context);
          Utils.showToast("payment failed", true);
        }
      } else {
        Utils.hideProgressDialog(context);
        Utils.showToast("Something went wrong!", true);
      }
    });
  }

  void removeIpayAndPeachPay() {
    PaymentGatewaySettings iPay88PG, peachPaymentsPG,stripePaymentsPG;
    for (int i = 0; i < widget.store.paymentGatewaySettings.length; i++) {
      if (widget.store.paymentGatewaySettings[i].paymentGateway
          .contains('iPay88')) {
        iPay88PG = widget.store.paymentGatewaySettings[i];
      }
      if (widget.store.paymentGatewaySettings[i].paymentGateway
          .contains('PeachPayments')) {
        peachPaymentsPG = widget.store.paymentGatewaySettings[i];
      }
      if (widget.store.paymentGatewaySettings[i].paymentGateway
          .contains('Stripe')) {
        stripePaymentsPG = widget.store.paymentGatewaySettings[i];
      }
    }
    if (peachPaymentsPG != null) {
      widget.store.paymentGatewaySettings.remove(peachPaymentsPG);
    }
    if (iPay88PG != null) {
      widget.store.paymentGatewaySettings.remove(iPay88PG);
    }
    // if (stripePaymentsPG != null) {
    //   widget.store.paymentGatewaySettings.remove(stripePaymentsPG);
    // }
  }
//Razor Code End
//-----------------------------------------------------------------------------------------------
//Paytm Api

//   void callPayTmApi(String mPrice, StoreModel store) async {
//     DatabaseHelper databaseHelper = new DatabaseHelper();
//     String address = "NA", pin = "NA";
//     double amount = databaseHelper.roundOffPrice(double.parse(mPrice), 2);
//     print("----amount----- ${amount}");
//     Utils.showProgressDialog(context);
//     ApiController.createPaytmTxnToken(address, pin, amount, "", "")
//         .then((value) async {
//       if (value != null && value.success) {
//         ApiController.createOnlineTopUPApi(mPrice, value.orderid)
//             .then((response) {
//           RazorPayTopUP modelPay = response;
//           print(response);
//           Utils.hideProgressDialog(context);
//           if (modelPay != null && response.success) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       PaytmWebView(value, storeModel, amount: mPrice)),
//             );
//           } else {
//             Utils.hideProgressDialog(context);
//           }
//         });
//       } else {
//         Utils.hideProgressDialog(context);
//         Utils.showToast("Api Error", false);
//       }
//     });
//   }
}
