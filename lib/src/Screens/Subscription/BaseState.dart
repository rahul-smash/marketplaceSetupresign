import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/CreateOrderData.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/OrderDetailsModel.dart';
import 'package:restroapp/src/models/RazorpayError.dart';
import 'package:restroapp/src/models/RazorpayOrderData.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/Utils.dart';

/*This Class Contains Common Modules like Payment*/
abstract class BaseState<T extends StatefulWidget> extends State {
  Razorpay _razorpay;
  PaymentMethod _paymentMethod;
  bool _isPaymentEnable = false;
  Function _handlePaymentSuccess;
  Function handlePaymentError;
  Map<PaymentMethod, Map<String, dynamic>> _extraFields = Map();

  @override
  void initState() {
    super.initState();
  }

  void enablePaymentModule(
    PaymentMethod paymentMethod,
    Function handlePaymentSuccess,
    Function errorMethod,
  ) {
    _paymentMethod = paymentMethod;
    _isPaymentEnable = true;
    _handlePaymentSuccess = handlePaymentSuccess;
    handlePaymentError = errorMethod;
    initRazorPay();
  }

  void initRazorPay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorPayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    if (_isPaymentEnable) {
      _razorpay.clear();
    }
  }

  void initRazorPayPayment(PaymentMethod paymentMethod,
      Map<String, dynamic> _extraFieldsMap, String mTotalAmount,
      {OrderDetailsModel detailsModel, String orderJson = ''}) async {
    _extraFields.putIfAbsent(_paymentMethod, () => _extraFieldsMap);
    Utils.showProgressDialog(context);
    double price = double.parse(mTotalAmount); //totalPrice ;
    price = price * 100;
    String mPrice =
        price.toString().substring(0, price.toString().indexOf('.'));
    String id = await _getStoreId();
    ApiController.razorpayCreateOrderApi(
            mPrice,
            orderJson,
            detailsModel?.orderDetails,
            id,
            SingletonBrandData.getInstance()
                .brandVersionModel
                .brand
                .currencyAbbr)
        .then((response) {
      CreateOrderData model = response;
      if (model != null) {
        if (!model.success) {
          Utils.showToast("${model.message}", true);
          Utils.hideProgressDialog(context);
          handlePaymentError();
          return;
        }
        if (model.data.message != null && model.data.message.isNotEmpty) {
          Utils.hideProgressDialog(context);
          handlePaymentError();
          return;
        }
        print("----razorpayCreateOrderApi----${response.data.id}--");

        switch (_paymentMethod) {
          case PaymentMethod.SUBSCRIPTION:
            _callSubscriptionApi(mTotalAmount, response.data.id);
            break;
          case PaymentMethod.ORDER:
          default:
            Utils.hideProgressDialog(context);
            _openCheckout(mTotalAmount, model.data.id,
                SingletonBrandData.getInstance().brandVersionModel.brand);
        }
      } else {
        Utils.hideProgressDialog(context);
        handlePaymentError();
      }
    });
  }

  void _openCheckout(
      String mTotalAmount, String razorpay_order_id, BrandData storeObject,
      {StoreDataObj storeModel}) async {
    Utils.hideProgressDialog(context);
    if (storeObject.paymentGatewaySettings.isEmpty) {
      Utils.showToast('Payment Gateway is not configured', false);
      return;
    }
    //find razor pay key
    String key = '';
    for (var pgs in storeObject.paymentGatewaySettings) {
      if (pgs.paymentGateway.contains('Razorpay')) {
        key = pgs.apiKey;
        break;
      }
    }
    UserModelMobile user = await SharedPrefs.getUserMobile();
    //double price = totalPrice ;
    var options = {
      'key': '${key}',
      'currency': "INR",
      'order_id': razorpay_order_id,
      'amount': (double.parse(mTotalAmount) * 100),
//      'name': '${storeModel.storeName}',
      'description': '',
      'prefill': {
        'contact': '${user.phone}',
        'email': '${user.email}',
        'name': '${user.fullName}'
      },
      /*'external': {
        'wallets': ['paytm']
      }*/
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handleRazorPayPaymentSuccess(PaymentSuccessResponse responseObj) async {
    Utils.showProgressDialog(context);
    String id = await _getStoreId();
    ApiController.razorpayVerifyTransactionApi(responseObj.orderId, id)
        .then((response) {
      if (response != null) {
        RazorpayOrderData model = response;
        if (model.success) {
          switch (_paymentMethod) {
            case PaymentMethod.SUBSCRIPTION:
              _subscriptionVerificationApi(responseObj, model);
              break;
            case PaymentMethod.ORDER:
            default:
              Utils.hideProgressDialog(context);
              _handlePaymentSuccess();
          }
        } else {
          Utils.showToast("Something went wrong!", true);
          Utils.hideProgressDialog(context);
          handlePaymentError();
        }
      } else {
        Utils.hideProgressDialog(context);
        handlePaymentError();
      }
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    bool isShowErrorMsg = handlePaymentError(response);
    if (isShowErrorMsg == true) {
      try {
        String string = response.message;
        RazorpayError error = RazorpayError.fromJson(jsonDecode(string));
        Fluttertoast.showToast(
            msg: error.error.description, timeInSecForIosWeb: 4);
      } catch (e) {}
      Fluttertoast.showToast(msg: response.message, timeInSecForIosWeb: 4);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _subscriptionVerificationApi(
      PaymentSuccessResponse responseObj, RazorpayOrderData model) {
    Map<String, dynamic> _subscriptionPlanFields = _extraFields[_paymentMethod];
    if (_subscriptionPlanFields != null && _subscriptionPlanFields.isNotEmpty) {
      ApiController.getPurchasedOnlineMembership(
              razorpay_order_id: responseObj.orderId,
              puchaseType: _subscriptionPlanFields['purchaseType'],
              amountPaid: _subscriptionPlanFields['amountPaid'],
              additionalInfo: _subscriptionPlanFields['additionalInfo'],
              posBranchCode: _subscriptionPlanFields['posBranchCode'],
              defaultAddressId: _subscriptionPlanFields['defaultAddressId'],
              paymentId: model.data.id,
              onlineMethod: 'Razorpay')
          .then((value) {
        if (value != null) {
          if (value.success) {
            Utils.hideProgressDialog(context);
            _handlePaymentSuccess();
          } else {
            Utils.showToast(value.message, false);
            Utils.hideProgressDialog(context);
            handlePaymentError();
          }
        } else {
          Utils.hideProgressDialog(context);
          handlePaymentError();
        }
      });
    } else {
      handlePaymentError();
    }
  }

  void _callSubscriptionApi(
    String mTotalAmount,
    String razorpayOrderId,
  ) {
    ApiController.getPurchaseOnlineMembership(
            mTotalAmount, razorpayOrderId, 'Razorpay')
        .then((value) {
      if (value != null) {
        if (value.success) {
          Utils.hideProgressDialog(context);
          _openCheckout(mTotalAmount, razorpayOrderId,
              SingletonBrandData.getInstance().brandVersionModel.brand);
        } else {
          Utils.showToast(value.message, false);
          Utils.hideProgressDialog(context);
          handlePaymentError();
        }
      } else {
        Utils.hideProgressDialog(context);
        handlePaymentError();
      }
    });
  }

  Future<String> _getStoreId() async {
    StoreDataObj store = await SharedPrefs.getStoreData();
    switch (_paymentMethod) {
      case PaymentMethod.SUBSCRIPTION:
        return '0';
        break;
      case PaymentMethod.ORDER:
      default:
        return store.id;
    }
  }
}
