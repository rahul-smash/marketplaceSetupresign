import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:restroapp/src/Screens/Offers/AvailableOffersList.dart';
import 'package:restroapp/src/Screens/Offers/RedeemPointsScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionUtils.dart';
import 'package:restroapp/src/apihandler/ApiConstants.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/CreateOrderData.dart';
import 'package:restroapp/src/models/CreatePaytmTxnTokenResponse.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/DeliveryTimeSlotModel.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/OrderDetailsModel.dart';
import 'package:restroapp/src/models/PeachPayCheckOutResponse.dart';
import 'package:restroapp/src/models/PeachPayVerifyResponse.dart';
import 'package:restroapp/src/models/PhonePeResponse.dart';
import 'package:restroapp/src/models/PhonePeVerifyResponse.dart';
import 'package:restroapp/src/models/RazorpayOrderData.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
import 'package:restroapp/src/models/StripeCheckOutModel.dart';
import 'package:restroapp/src/models/StripeVerifyModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TaxCalulationResponse.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/ValidateCouponsResponse.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/models/WalletModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/widgets/web_view/PhonePeWebView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ConfirmOrderScreen extends StatefulWidget {
  bool isComingFromPickUpScreen;
  DeliveryAddressData address;
  StoreRadiousResponse storeRadius;
  String paymentMode = "2"; // 2 = COD, 3 = Online Payment
  String areaId;
  OrderType deliveryType;
  OrderType subscriptionOrderType;
  Area areaObject;
  StoreDataObj storeModel;
  List<Product> cartList = new List();
  PaymentType _character = PaymentType.COD;

  ConfirmOrderScreen(this.address, this.isComingFromPickUpScreen, this.areaId,
      this.deliveryType,
      {this.areaObject, this.paymentMode = "2", this.storeModel}) {
    //Subscription Order Type
    if (this.deliveryType == OrderType.SUBSCRIPTION_ORDER) {
      this.subscriptionOrderType = this.deliveryType;
      this.deliveryType = OrderType.Delivery;
    }
  }

  @override
  ConfirmOrderState createState() => ConfirmOrderState(storeModel: storeModel);
}

class ConfirmOrderState extends State<ConfirmOrderScreen> {
  DatabaseHelper databaseHelper = new DatabaseHelper();
  double totalPrice = 0.00;
  double totalSavings = 0.00;
  String totalSavingsText = "";
  TaxCalculationModel taxModel;

  //TextEditingController noteController = TextEditingController();
  String shippingCharges = "0";
  static const platform = const MethodChannel("razorpay_flutter");
  Razorpay _razorpay;
  StoreDataObj storeModel;
  DeliveryTimeSlotModel deliverySlotModel;
  int selctedTag, selectedTimeSlot;
  List<Timeslot> timeslotList;
  bool isSlotSelected = false;
  StoreDataModel storeCheckData;

  //Store provides instant delivery of the orders.
  bool isInstantDelivery = false;
  bool minOrderCheck = true;
  bool isLoading = true;
  bool hideRemoveCouponFirstTime;
  List<String> appliedCouponCodeList = List();
  List<String> appliedReddemPointsCodeList = List();
  TextEditingController couponCodeController = TextEditingController();
  bool isCommentAdded = false;

  String comment = "";
  bool isDeliveryResponseFalse = false;
  bool ispaytmSelected = false;

  bool isPayTmActive = false;

  double totalMRpPrice = 0.0;
  List<OrderDetail> responseOrderDetail = List();

  bool isOrderVariations = false;

  bool showCOD = true;
  BrandData _brandData;

  String couponType = '';

  bool isOneTimeApiCalled = false;

  WalletModel userWalleModel;

  ConfirmOrderState({this.storeModel});

  @override
  void initState() {
    super.initState();
    _brandData = SingletonBrandData
        .getInstance()
        .brandVersionModel
        .brand;
    if (widget.subscriptionOrderType != null) {
      //selecting delivery slots
      selectedDeliverSlotValue = getSubscriptionNextMealDate();
      if (SingletonBrandData
          .getInstance()
          ?.userPurchaseMembershipResponse
          ?.data
          ?.additionalInfo !=
          null) {
        if (SingletonBrandData
            .getInstance()
            .userPurchaseMembershipResponse
            .data
            .additionalInfo
            .toLowerCase() ==
            'lunch') {
          selectedDeliverSlotValue =
              selectedDeliverSlotValue + ", 11:30 AM - 12:30 PM";
        } else {
          selectedDeliverSlotValue =
              selectedDeliverSlotValue + ", 7:30 PM - 8:30 PM";
        }
      }
    }

    initRazorPay();
    listenWebViewChanges();
    checkPaytmActive();
    selctedTag = 0;
    hideRemoveCouponFirstTime = true;
    print("You are on confirm order screen");
    //print("-deliveryType--${widget.deliveryType}---");
    try {
      checkLoyalityPointsOption();
      if (widget.deliveryType == OrderType.Delivery) {
        /*if (storeModel.deliverySlot == "1")*/ {
          ApiController.deliveryTimeSlotApi(storeModel.id).then((response) {
            setState(() {
              if (!response.success) {
                isDeliveryResponseFalse = true;
                return;
              }
              deliverySlotModel = response;
              print(
                  "deliverySlotModel.data.is24X7Open =${deliverySlotModel.data
                      .is24X7Open}");
              isInstantDelivery = deliverySlotModel.data.is24X7Open == "1";
              for (int i = 0;
              i < deliverySlotModel.data.dateTimeCollection.length;
              i++) {
                timeslotList =
                    deliverySlotModel.data.dateTimeCollection[i].timeslot;
                for (int j = 0; j < timeslotList.length; j++) {
                  Timeslot timeslot = timeslotList[j];
                  if (timeslot.isEnable) {
                    selectedTimeSlot = j;
                    isSlotSelected = true;
                    break;
                  }
                }
                if (isSlotSelected) {
                  selctedTag = i;
                  break;
                }
              }
            });
          });
        }
      }
    } catch (e) {
      print(e);
    }
    multiTaxCalculationApi();

    if (widget.storeModel != null) {
      if (_brandData.cod == "1") {
        showCOD = true;
        widget.paymentMode = "2";
      } else if (_brandData.cod == "0") {
        showCOD = false;
      }
      if (_brandData.onlinePayment == "0" && _brandData.cod == "0") {
        showCOD = true;
        widget.paymentMode = "2";
      }
      if (_brandData.cod == "0" && _brandData.onlinePayment == "1") {
        widget._character = PaymentType.ONLINE;
        widget.paymentMode = "3";
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("Confirm Order"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: <Widget>[
//          InkWell(
//            onTap: () {
//              Navigator.of(context).popUntil((route) => route.isFirst);
//            },
//            child: Padding(
//              padding:
//                  EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0, right: 10),
//              child: Icon(
//                Icons.home,
//                color: Colors.white,
//                size: 30,
//              ),
//            ),
//          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(children: [
              Expanded(
                child: isLoading
                    ? Utils.getIndicatorView()
                    : widget.cartList == null
                    ? Text("")
                    : ListView(
                  children: <Widget>[
                    addCommentWidget(context),
                    showDeliverySlot(),
                    ListView.separated(
                      separatorBuilder:
                          (BuildContext context, int index) {
                        if (widget.cartList[index].taxDetail ==
                            null ||
                            widget.cartList[index].taxDetail ==
                                null) {
                          return Divider(
                              color: Colors.black12, height: 2);
                        } else {
                          return Divider(
                              color: Colors.white, height: 1);
                        }
                      },
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: widget.cartList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == widget.cartList.length) {
                          return addItemPrice();
                        } else {
                          return addProductCart(
                              widget.cartList[index]);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Wrap(
                children: [
                  addTotalPrice(),
                  addEnterCouponCodeView(),
                  addCouponCodeRow(),
                  addPaymentOptions(),
                  addConfirmOrder()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void callPaytmPayApi() async {
    String address = "NA",
        pin = "NA";
    if (widget.deliveryType == OrderType.Delivery) {
      if (widget.address.address2 != null &&
          widget.address.address2.isNotEmpty) {
        if (widget.address.address != null &&
            widget.address.address.isNotEmpty) {
          address = widget.address.address +
              ", " +
              widget.address.address2 +
              " " +
              widget.address.areaName +
              " " +
              widget.address.city;
        } else {
          address = widget.address.address2 +
              " " +
              widget.address.areaName +
              " " +
              widget.address.city;
        }
      } else {
        if (widget.address.address != null &&
            widget.address.address.isNotEmpty) {
          address = widget.address.address +
              " " +
              widget.address.areaName +
              " " +
              widget.address.city;
        }
      }

      if (widget.address.zipCode != null && widget.address.zipCode.isNotEmpty)
        pin = widget.address.zipCode;
    } else if (widget.deliveryType == OrderType.PickUp ||
        widget.deliveryType == OrderType.DineIn) {
//      address = widget.areaObject.pickupAdd;
      //TODO add pickupAdd
      address = '';
      pin = 'NA';
    }

    print(
        "amount ${databaseHelper.roundOffPrice(
            taxModel == null ? totalPrice : double.parse(taxModel.total), 2)
            .toStringAsFixed(2)}"
            " address $address zipCode $pin");
    double amount = databaseHelper.roundOffPrice(
        taxModel == null ? totalPrice : double.parse(taxModel.total), 2);
    Utils.showProgressDialog(context);

    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    //new changes
    Utils.getCartItemsListToJson(
        isOrderVariations: isOrderVariations,
        responseOrderDetail: responseOrderDetail)
        .then((orderJson) {
      if (orderJson == null) {
        print("--orderjson == null-orderjson == null-");
        return;
      }
      String storeAddress = "";
      try {
        storeAddress = "${storeModel.storeName}, ${storeModel.location},"
            "${storeModel.city}, ${storeModel.state}, ${storeModel
            .country}, ${storeModel.zipcode}";
      } catch (e) {
        print(e);
      }

      String userId = user.id;
      OrderDetailsModel detailsModel = OrderDetailsModel(
          shippingCharges,
          comment,
          totalPrice.toString(),
          widget.paymentMode,
          taxModel,
          widget.address,
          widget.isComingFromPickUpScreen,
          widget.areaId,
          widget.deliveryType,
          "",
          "",
          deviceId,
          "Paytm",
          userId,
          deviceToken,
          storeAddress,
          selectedDeliverSlotValue,
          totalSavingsText,
          posBranchCode: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.posBranchCode ??
              ''
              : '',
          membershipId: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.id ??
              ''
              : '',
          membershipPlanDetailId: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.membershipPlanDetailId ??
              ''
              : '',
          additionalInfo: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.additionalInfo ?? ''
              : '',
          isMembershipCouponEnabled: widget.subscriptionOrderType != null
              ? '1'
              : '0');
      ApiController.createPaytmTxnToken(
          address, pin, amount, orderJson, detailsModel.orderDetails)
          .then((value) async {
        Utils.hideProgressDialog(context);
        if (value != null && value.success) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaytmWebView(value)),
          );
        } else {
          Utils.showToast("Api Error", false);
        }
      });
    });
  }

  Future<void> multiTaxCalculationApi() async {
    await constraints();
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if (!isNetworkAvailable) {
      Utils.showToast(AppConstant.noInternet, false);
      return;
    }
    isLoading = true;
    userWalleModel = await ApiController.getUserWallet();

    String discount = widget.subscriptionOrderType != null
        ? getSubscriptionCouponDiscountPlan()
        : '0';
    String couponCode = widget.subscriptionOrderType != null
        ? getSubscriptionCouponCodePlan()
        : '';

    String charges =
    widget.subscriptionOrderType != null ? '0' : shippingCharges;
    databaseHelper.getCartItemsListToJson().then((json) {
      ApiController.multipleTaxCalculationRequest(
          couponCode, discount, "$charges", json,
          isMembershipCouponEnabled:
          widget.subscriptionOrderType != null ? '1' : '0')
          .then((response) async {
        //{"success":false,"message":"Some products are not available."}
        TaxCalculationResponse model = response;
        if (model.success) {
          taxModel = model.taxCalculation;
          widget.cartList = await databaseHelper.getCartItemList();
          for (int i = 0; i < model.taxCalculation.taxDetail.length; i++) {
            Product product = Product();
            product.taxDetail = model.taxCalculation.taxDetail[i];
            widget.cartList.add(product);
          }
          for (var i = 0; i < model.taxCalculation.fixedTax.length; i++) {
            Product product = Product();
            product.fixedTax = model.taxCalculation.fixedTax[i];
            widget.cartList.add(product);
          }
          if (model.taxCalculation.orderDetail != null &&
              model.taxCalculation.orderDetail.isNotEmpty) {
            responseOrderDetail = model.taxCalculation.orderDetail;
            bool someProductsUpdated = false;
            isOrderVariations = model.taxCalculation.isChanged;
            for (int i = 0; i < responseOrderDetail.length; i++) {
              if (responseOrderDetail[i]
                  .productStatus
                  .compareTo('out_of_stock') ==
                  0 ||
                  responseOrderDetail[i]
                      .productStatus
                      .compareTo('price_changed') ==
                      0) {
                someProductsUpdated = true;
                break;
              }
            }
            if (someProductsUpdated) {
              DialogUtils.displayCommonDialog(
                  context,
                  storeModel == null ? "" : storeModel.storeName,
                  "Some Cart items were updated. Please review the cart before procceeding.",
                  buttonText: 'Procceed');
              constraints();
            }
          }

          calculateTotalSavings();
          setState(() {
            isLoading = false;
          });
        } else {
          var result = await DialogUtils.displayCommonDialog(
              context,
              storeModel == null ? "" : storeModel.storeName,
              "${model.message}");
          if (result != null && result == true) {
//            databaseHelper.deleteTable(DatabaseHelper.Favorite_Table);
            databaseHelper.deleteTable(DatabaseHelper.CART_Table);
//            databaseHelper.deleteTable(DatabaseHelper.Products_Table);
            eventBus.fire(updateCartCount());
            eventBus.fire(onCartRemoved());
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      });
    });
  }

  Widget showDeliverySlot() {
    Color selectedSlotColor, textColor;
    if (deliverySlotModel == null) {
      return Container();
    } else {
      //print("--length = ${deliverySlotModel.data.dateTimeCollection.length}----");
      if (deliverySlotModel.data != null &&
          deliverySlotModel.data.dateTimeCollection != null &&
          deliverySlotModel.data.dateTimeCollection.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text("When would you like your service?"),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text("${Utils.getDate()}"),
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      height: 1,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      color: Color(0xFFBDBDBD)),
                  Container(
                    //margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    height: 50.0,
                    child: ListView.builder(
                      itemCount:
                      deliverySlotModel.data.dateTimeCollection.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        DateTimeCollection slotsObject =
                        deliverySlotModel.data.dateTimeCollection[index];
                        if (selctedTag == index) {
                          selectedSlotColor = Color(0xFFEEEEEE);
                          textColor = Color(0xFFff4600);
                        } else {
                          selectedSlotColor = Color(0xFFFFFFFF);
                          textColor = Color(0xFF000000);
                        }
                        return Container(
                          color: selectedSlotColor,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: InkWell(
                            onTap: () {
                              print("${slotsObject.timeslot.length}");
                              setState(() {
                                selctedTag = index;
                                timeslotList = slotsObject.timeslot;
                                isSlotSelected = false;
                                //selectedTimeSlot = 0;
                                //print("timeslotList=${timeslotList.length}");
                                for (int i = 0; i < timeslotList.length; i++) {
                                  //print("isEnable=${timeslotList[i].isEnable}");
                                  Timeslot timeslot = timeslotList[i];
                                  if (timeslot.isEnable) {
                                    selectedTimeSlot = i;
                                    isSlotSelected = true;
                                    break;
                                  }
                                }
                              });
                            },
                            child: Container(
                              child: Center(
                                child: Text(
                                    ' ${Utils.convertStringToDate(
                                        slotsObject.label)} ',
                                    style: TextStyle(color: textColor)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      height: 1,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      color: Color(0xFFBDBDBD)),
                  Container(
                    //margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    height: 50.0,
                    child: ListView.builder(
                      itemCount: timeslotList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Timeslot slotsObject = timeslotList[index];
                        print("----${slotsObject.label}-and ${selctedTag}--");

                        //selectedTimeSlot
                        Color textColor;
                        if (!slotsObject.isEnable) {
                          textColor = Color(0xFFBDBDBD);
                        } else {
                          textColor = Color(0xFF000000);
                        }
                        if (selectedTimeSlot == index &&
                            (slotsObject.isEnable)) {
                          textColor = Color(0xFFff4600);
                        }

                        return Container(
                          //color: selectedSlotColor,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: InkWell(
                            onTap: () {
                              print("${slotsObject.label}");
                              if (slotsObject.isEnable) {
                                setState(() {
                                  selectedTimeSlot = index;
                                });
                              } else {
                                Utils.showToast(slotsObject.innerText, false);
                              }
                            },
                            child: Container(
                              child: Center(
                                child: Text(
                                    '${slotsObject.isEnable == true
                                        ? slotsObject.label
                                        : "${slotsObject.label}(${slotsObject
                                        .innerText})"}',
                                    style: TextStyle(color: textColor)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }

  String getUserRemaningWallet() {
    double balance = (double.parse(userWalleModel.data.userWallet) -
        double.parse(taxModel.walletRefund) -
        double.parse(taxModel.shipping));
    //print("balance=${balance}");
    if (balance > 0.0) {
      // USer balance is greater than zero.
      return databaseHelper.roundOffPrice(balance, 2).toStringAsFixed(2);
    } else {
      // USer balance is less than or equal to zero.
      return "0.00";
    }
    //return "${userWalleModel == null ? "" : userWalleModel.data.userWallet}";
  }

  Widget addProductCart(Product product) {
    OrderDetail detail;
    if (product.id != null)
      for (int i = 0; i < responseOrderDetail.length; i++) {
        if (product.id.compareTo(responseOrderDetail[i].productId) == 0 &&
            product.variantId.compareTo(responseOrderDetail[i].variantId) ==
                0) {
          detail = responseOrderDetail[i];
          break;
        }
      }
    Color containerColor =
    detail != null && detail.productStatus.contains('out_of_stock')
        ? Colors.black12
        : Colors.transparent;
    String mrpPrice =
    detail != null && detail.productStatus.contains('price_changed')
        ? detail.newMrpPrice
        : product.mrpPrice;
    String price =
    detail != null && detail.productStatus.contains('price_changed')
        ? detail.newPrice
        : product.price;
    String imageUrl = product.imageType == "0"
        ? product.image == null
        ? product.image10080
        : product.image
        : product.imageUrl;
    if (product.taxDetail != null) {
      return Container(
        color: containerColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${product.taxDetail.label} (${product.taxDetail.rate}%)",
                  style: TextStyle(color: Colors.black54)),
              detail != null && detail.productStatus.contains('out_of_stock')
                  ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Text(
                      "Out of Stock",
                      style: TextStyle(color: Colors.red),
                    ),
                  ))
                  : Text("${AppConstant.currency}${product.taxDetail.tax}",
                  style: TextStyle(
                      color: detail != null &&
                          detail.productStatus.contains('out_of_stock')
                          ? Colors.red
                          : Colors.black54)),
            ],
          ),
        ),
      );
    } else if (product.fixedTax != null) {
      return Container(
        color: containerColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${product.fixedTax.fixedTaxLabel}",
                  style: TextStyle(color: Colors.black54)),
              detail != null && detail.productStatus.contains('out_of_stock')
                  ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Text(
                      "Out of Stock",
                      style: TextStyle(color: Colors.red),
                    ),
                  ))
                  : Text(
                  "${AppConstant.currency}${product.fixedTax.fixedTaxAmount}",
                  style: TextStyle(
                      color: detail != null &&
                          detail.productStatus.contains('out_of_stock')
                          ? Colors.red
                          : Colors.black54)),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: containerColor,
        padding: EdgeInsets.fromLTRB(15, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            imageUrl == ""
                ? Container(
//              padding: EdgeInsets.fromLTRB(0,5,0,5),
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              width: 80.0,
              height: 80.0,
              child: Utils.getImgPlaceHolder(),
            )
                : Padding(
                padding: EdgeInsets.only(left: 5, right: 20),
                child: Container(
//                  padding: EdgeInsets.fromLTRB(0,5,0,5),
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
//                  decoration: BoxDecoration(border: Border.all(color: Colors.black38,width: 1)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(
                      color: Colors.grey,
                      width: .5,
                    ),
                  ),
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: CachedNetworkImage(
                          imageUrl: "${imageUrl}", fit: BoxFit.cover
                        //placeholder: (context, url) => CircularProgressIndicator(),
                        //errorWidget: (context, url, error) => Icon(Icons.error),
                      )),
                  /*child: Image.network(imageUrl,width: 60.0,height: 60.0,
                                          fit: BoxFit.cover),*/
                )),
            Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: SizedBox(
                        width: (Utils.getDeviceWidth(context) - 150),
                        child: Container(
                          child: Text(product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: product.weight.isEmpty ? false : true,
                      child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "${product.weight}",
                            style: TextStyle(color: appThemeSecondary),
                          )),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 20),
                        child: Text(
                            "${product.quantity} X ${AppConstant
                                .currency}${double.parse(price).toStringAsFixed(
                                2)}")),
                    //
                    /*Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 20),
                    child: Text("Price: " + "${AppConstant.currency}${double.parse(product.price).toStringAsFixed(2)}")
                ),*/
                  ],
                )),
            detail != null && detail.productStatus.contains('out_of_stock')
                ? Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 1),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Text(
                    "Out of Stock",
                    style: TextStyle(color: Colors.red),
                  ),
                ))
                : Text(
                "${AppConstant.currency}${databaseHelper.roundOffPrice(
                    int.parse(product.quantity) * double.parse(price), 2)
                    .toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 16,
                    color: detail != null &&
                        detail.productStatus.contains('out_of_stock')
                        ? Colors.red
                        : Colors.black45)),
          ],
        ),
      );
    }
  }

  Widget addItemPrice() {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//        Container(
//            height: .5,
//            color: Colors.black12,
//            width: MediaQuery.of(context).size.width),
        Visibility(
          visible:
          widget.address != null && widget.subscriptionOrderType == null
              ? true
              : false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Delivery charges:",
                    style: TextStyle(color: Colors.black)),
                Text(
                    "${AppConstant.currency}${taxModel == null
                        ? widget.areaObject == null ? "0" : widget.areaObject
                        .charges
                        : taxModel.shipping}",
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),
        Visibility(
          visible: taxModel == null ? false : true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Discount:", style: TextStyle(color: Colors.black)),
                Text(
                    "${AppConstant.currency}${taxModel == null ? "0" : taxModel
                        .discount}",
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Items Price", style: TextStyle(color: Colors.black)),
              Text(
//                  "${AppConstant.currency}${databaseHelper.roundOffPrice((totalPrice - int.parse(shippingCharges)), 2).toStringAsFixed(2)}",
                  "${AppConstant.currency}${taxModel == null ? databaseHelper
                      .roundOffPrice(
                      (totalPrice - int.parse(shippingCharges)), 2)
                      .toStringAsFixed(2) : taxModel.itemSubTotal}",
                  style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        Visibility(
          visible: _brandData.walletSetting == "1" ? true : false,
          child: Container(
            child: Padding(
                padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                      child: Icon(
                        Icons.done,
                        color: appTheme,
                        size: 30,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("My Wallet",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              taxModel == null
                                  ? "Remaining Balance: ${AppConstant.currency}"
                                  : "Remaining Balance: ${AppConstant
                                  .currency} ${getUserRemaningWallet()}",
                              style:
                              TextStyle(color: Colors.black, fontSize: 15)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5, top: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("You Used",
                              style:
                              TextStyle(color: Colors.black, fontSize: 16)),
                          Text(
                              "${AppConstant.currency} ${taxModel == null
                                  ? "0.00"
                                  : databaseHelper.roundOffPrice(
                                  double.parse(taxModel.walletRefund), 2)
                                  .toStringAsFixed(2)}",
                              style: TextStyle(color: appTheme, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
        addMRPPrice(),
        addTotalSavingPrice(),

      ]),
    );
  }

  Widget addTotalPrice() {
    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 1,
            color: Colors.black45,
            width: MediaQuery
                .of(context)
                .size
                .width),
//        addMRPPrice(),
//        addTotalSavingPrice(),
        Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                //TODO: recheck this
                Text(
                    "${AppConstant.currency}${databaseHelper.roundOffPrice(
                        taxModel == null ? totalPrice : double.parse(
                            taxModel.total) > 0
                            ? double.parse(taxModel.total)
                            : 0, 2).toStringAsFixed(2)}",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ))
      ]),
    );
  }

  Widget addTotalSavingPrice() {
    if (totalSavings != 0.00)
      return Container(
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Cart Discount",
                      style: TextStyle(
//                          fontWeight: FontWeight.bold,
                          color: appTheme,
                          fontSize: 16)),
                  Text('-${AppConstant.currency}$totalSavingsText',
                      style: TextStyle(
//                          fontWeight: FontWeight.bold,
                          color: appTheme,
                          fontSize: 16)),
                ],
              )));
    else
      return Container();
  }

  Widget addMRPPrice() {
    if (totalSavings != 0.00)
      return Container(
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 10, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("MRP Price",
                      style: TextStyle(
//                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14)),
                  Text(
                      '${AppConstant.currency}${totalMRpPrice.toStringAsFixed(
                          2)}',
                      style: TextStyle(
//                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14)),
                ],
              )));
    else
      return Container();
  }

  void calculateTotalSavings() {
    //calculate total savings
    totalMRpPrice = 0;
    totalSavings = 0;
    if (widget.cartList != null && widget.cartList.isNotEmpty) {
      for (Product product in widget.cartList) {
        if (product != null &&
            product.mrpPrice != null &&
            product.price != null &&
            product.quantity != null) {
          bool isProductOutOfStock = false;
          OrderDetail detail;
          //check product is out of stock of not
          if (isOrderVariations) {
            InnnerFor:
            for (int i = 0; i < responseOrderDetail.length; i++) {
              if (responseOrderDetail[i]
                  .productStatus
                  .compareTo('out_of_stock') ==
                  0 &&
                  responseOrderDetail[i].productId.compareTo(product.id) == 0 &&
                  responseOrderDetail[i]
                      .variantId
                      .compareTo(product.variantId) ==
                      0) {
                isProductOutOfStock = true;
                break InnnerFor;
              }
              if (responseOrderDetail[i]
                  .productStatus
                  .compareTo('price_changed') ==
                  0 &&
                  responseOrderDetail[i].productId.compareTo(product.id) == 0 &&
                  responseOrderDetail[i]
                      .variantId
                      .compareTo(product.variantId) ==
                      0) {
                detail = responseOrderDetail[i];
                break InnnerFor;
              }
            }
          }

          if (!isProductOutOfStock) {
            String mrpPrice =
            detail != null && detail.productStatus.contains('price_changed')
                ? detail.newMrpPrice
                : product.mrpPrice;
            String price =
            detail != null && detail.productStatus.contains('price_changed')
                ? detail.newPrice
                : product.price;
            totalSavings += (double.parse(mrpPrice) - double.parse(price)) *
                double.parse(product.quantity);
            totalMRpPrice +=
            (double.parse(mrpPrice) * double.parse(product.quantity));
          }
        }
      }
      //Y is P% of X
      //P% = Y/X
      //P= (Y/X)*100
      double totalSavedPercentage = (totalSavings / totalMRpPrice) * 100;
      totalSavingsText =
//          "${databaseHelper.roundOffPrice(totalSavings, 2).toStringAsFixed(2)} (${totalSavedPercentage.toStringAsFixed(2)}%)";
      "${databaseHelper.roundOffPrice(totalSavings, 2).toStringAsFixed(2)}";
      setState(() {});
    }
  }

  Widget addCouponCodeRow() {
    //As Per Flow if subscription order would not contain coupons
    if (widget.subscriptionOrderType != null) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 5),
      child: Container(
        child: Wrap(
          children: <Widget>[
            Visibility(
              visible: isloyalityPointsEnabled == true ? true : false,
              child: InkWell(
                onTap: () async {
                  //print("appliedCouponCodeList = ${appliedCouponCodeList.length}");
                  //print("appliedReddemPointsCodeList = ${appliedReddemPointsCodeList.length}");
                  if (isCouponsApplied) {
                    Utils.showToast(
                        "Please remove Applied Coupon to Redeem Loyality Points",
                        false);
                    return;
                  }
                  if (appliedCouponCodeList.isNotEmpty) {
                    Utils.showToast(
                        "Please remove Applied Coupon to Redeem Points", false);
                    return;
                  }
                  if (taxModel != null &&
                      appliedReddemPointsCodeList.isNotEmpty) {
                    removeCoupon();
                  } else {
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              RedeemPointsScreen(
                                  widget.address,
                                  "",
                                  widget.isComingFromPickUpScreen,
                                  widget.areaId, (model) async {
                                await updateTaxDetails(model);
                                setState(() {
                                  hideRemoveCouponFirstTime = false;
                                  taxModel = model;
                                  double taxModelTotal =
                                  double.parse(taxModel.total);
                                  taxModel.total = taxModelTotal.toString();
                                  appliedReddemPointsCodeList.add(
                                      model.couponCode);
                                  print("===discount=== ${model.discount}");
                                  print("taxModel.total=${taxModel.total}");
                                });
                              },
                                  appliedReddemPointsCodeList,
                                  isOrderVariations,
                                  responseOrderDetail,
                                  taxModel: taxModel),
                          fullscreenDialog: true,
                        ));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 40.0,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      decoration: BoxDecoration(
                        color: whiteColor,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          appliedReddemPointsCodeList.isEmpty
                              ? "Redeem Loyality Points"
                              : "${taxModel.couponCode} Applied",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: appliedCouponCodeList.isEmpty
                                  ? isCouponsApplied
                                  ? appTheme.withOpacity(0.5)
                                  : appTheme
                                  : appTheme.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    Icon(appliedReddemPointsCodeList.isNotEmpty
                        ? Icons.cancel
                        : Icons.keyboard_arrow_right),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isloyalityPointsEnabled == true ? true : false,
              child: Utils.showDivider(context),
            ),
            InkWell(
              onTap: () {
                print(
                    "appliedCouponCodeList = ${appliedCouponCodeList.length}");
                print(
                    "appliedReddemPointsCodeList = ${appliedReddemPointsCodeList
                        .length}");
                if (isCouponsApplied) {
                  Utils.showToast(
                      "Please remove Applied Coupon to Avail Offers", false);
                  return;
                }
                if (appliedReddemPointsCodeList.isNotEmpty) {
                  Utils.showToast(
                      "Please remove Applied Coupon to Avail Offers", false);
                  return;
                }
                if (taxModel != null && appliedCouponCodeList.isNotEmpty) {
                  removeCoupon();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        AvailableOffersDialog(
                          widget.address,
                          widget.paymentMode,
                          widget.isComingFromPickUpScreen,
                          widget.areaId,
                              (model) async {
                            await updateTaxDetails(model);
                            setState(() {
                              hideRemoveCouponFirstTime = false;
                              taxModel = model;
                              double taxModelTotal = double.parse(
                                  taxModel.total);
                              taxModel.total = taxModelTotal.toString();
                              appliedCouponCodeList.add(model.couponCode);
                              couponType = model.couponType;
                              ;
                              print("===couponCode=== ${model.couponCode}");
                              print("taxModel.total=${taxModel.total}");
                            });
                          },
                          appliedCouponCodeList,
                          isOrderVariations,
                          responseOrderDetail,
                          taxModel: taxModel,
                        ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        isloyalityPointsEnabled ? 0 : 0, 0, 0, 0),
                    height: 40,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    decoration: new BoxDecoration(
                      color: whiteColor,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          appliedCouponCodeList.isEmpty
                              ? "Available Offers"
                              : "${taxModel.couponCode} Applied",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: appliedReddemPointsCodeList.isEmpty
                                  ? isCouponsApplied
                                  ? appTheme.withOpacity(0.5)
                                  : appTheme
                                  : appTheme.withOpacity(0.5))),
                    ),
                  ),
                  Icon(appliedCouponCodeList.isNotEmpty
                      ? Icons.cancel
                      : Icons.keyboard_arrow_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addPaymentOptions() {
    bool showOptions = false;
    if (_brandData.onlinePayment != null) {
      if (_brandData.onlinePayment == "1") {
        showOptions = true;
      } else {
        showOptions = false; //cod
      }
    } else {
      if (isPayTmActive) {
        showOptions = true;
      }
    }

    return Visibility(
      visible: showOptions,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 5),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Utils.showDivider(context),
            Container(
              child: Text("Select Payment",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appTheme,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            Visibility(
              visible: showCOD,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Radio(
                    value: PaymentType.COD,
                    groupValue: widget._character,
                    activeColor: appTheme,
                    onChanged: (PaymentType value) async {
                      setState(() {
                        widget._character = value;
                        if (value == PaymentType.COD) {
                          widget.paymentMode = "2";
                          ispaytmSelected = false;
                        }
                      });
                    },
                  ),
                  Text('COD',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
            Visibility(
              visible: _brandData.onlinePayment != null &&
                  _brandData.onlinePayment.compareTo('1') == 0,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Radio(
                    value: PaymentType.ONLINE,
                    activeColor: appTheme,
                    groupValue: widget._character,
                    onChanged: (PaymentType value) async {
                      setState(() {
                        widget._character = value;
                        if (value == PaymentType.ONLINE) {
                          widget.paymentMode = "3";
                          ispaytmSelected = false;
                        }
                      });
                    },
                  ),
                  Text('Online',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
            Visibility(
              visible: isPayTmActive,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Radio(
                    value: PaymentType.ONLINE_PAYTM,
                    activeColor: appTheme,
                    groupValue: widget._character,
                    onChanged: (PaymentType value) async {
                      setState(() {
                        widget._character = value;
                        if (value == PaymentType.ONLINE_PAYTM) {
                          widget.paymentMode = "3";
                          ispaytmSelected = true;
                        }
                      });
                    },
                  ),
                  Text('Paytm',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isCouponsApplied = false;

  Widget addEnterCouponCodeView() {
    //As Per Flow if subscription order would not contain coupons
    if (widget.subscriptionOrderType != null) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 40,
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                border: new Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                child: TextField(
                  textAlign: TextAlign.left,
                  controller: couponCodeController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: "Coupon Code",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40.0,
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                textColor: Colors.white,
                color: appTheme,
                onPressed: () async {
                  print("---Apply Coupon----");
                  if (couponCodeController.text
                      .trim()
                      .isEmpty) {} else {
                    print(
                        "--${appliedCouponCodeList
                            .length}-and -${appliedReddemPointsCodeList
                            .length}---");
                    if (appliedCouponCodeList.isNotEmpty ||
                        appliedReddemPointsCodeList.isNotEmpty) {
                      Utils.showToast(
                          "Please remove the applied coupon first!", false);
                      return;
                    }
                    if (isCouponsApplied) {
                      removeCoupon();
                    } else {
                      String couponCode = couponCodeController.text;
                      Utils.showProgressDialog(context);
                      Utils.hideKeyboard(context);
                      databaseHelper
                          .getCartItemsListToJson(
                          isOrderVariations: isOrderVariations,
                          responseOrderDetail: responseOrderDetail)
                          .then((json) async {
                        ValidateCouponResponse couponModel =
                        await ApiController.validateOfferApiRequest(
                            couponCodeController.text,
                            widget.paymentMode,
                            json,
                            couponType,
                            widget.isComingFromPickUpScreen ? '1' : '2');
                        if (couponModel.success) {
                          print("---success----");
                          Utils.showToast("${couponModel.message}", false);
                          print("------------2---------${shippingCharges}");
                          TaxCalculationResponse model =
                          await ApiController.multipleTaxCalculationRequest(
                              couponCodeController.text,
                              couponModel.discountAmount,
                              "${shippingCharges}",
                              json,
                              isMembershipCouponEnabled:
                              widget.subscriptionOrderType != null
                                  ? '1'
                                  : '0');
                          Utils.hideProgressDialog(context);
                          if (model != null && !model.success) {
                            Utils.showToast(model.message, true);
//                            databaseHelper
//                                .deleteTable(DatabaseHelper.Favorite_Table);
                            databaseHelper
                                .deleteTable(DatabaseHelper.CART_Table);
//                            databaseHelper
//                                .deleteTable(DatabaseHelper.Products_Table);
                            eventBus.fire(updateCartCount());
                            eventBus.fire(onCartRemoved());
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          } else {
                            await updateTaxDetails(model.taxCalculation);
                            if (model.taxCalculation.orderDetail != null &&
                                model.taxCalculation.orderDetail.isNotEmpty) {
                              responseOrderDetail =
                                  model.taxCalculation.orderDetail;
                              bool someProductsUpdated = false;
                              isOrderVariations =
                                  model.taxCalculation.isChanged;
                              for (int i = 0;
                              i < responseOrderDetail.length;
                              i++) {
                                if (responseOrderDetail[i]
                                    .productStatus
                                    .compareTo('out_of_stock') ==
                                    0 ||
                                    responseOrderDetail[i]
                                        .productStatus
                                        .compareTo('price_changed') ==
                                        0) {
                                  someProductsUpdated = true;
                                  break;
                                }
                              }
                              if (someProductsUpdated) {
                                DialogUtils.displayCommonDialog(
                                    context,
                                    storeModel == null
                                        ? ""
                                        : storeModel.storeName,
                                    "Some Cart items were updated. Please review the cart before procceeding.",
                                    buttonText: 'Procceed');
                                constraints();
                              }
                            }
                            calculateTotalSavings();
                            setState(() {
                              taxModel = model.taxCalculation;
                              isCouponsApplied = true;
                              couponCodeController.text = couponCode;
                            });
                          }
                        } else {
                          Utils.showToast("${couponModel.message}", false);
                          Utils.hideProgressDialog(context);
                          Utils.hideKeyboard(context);
                        }
                      });
                    }
                  }
                },
                child: new Text(
                    isCouponsApplied ? "Remove Coupon" : "Apply Coupon"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateTaxDetails(TaxCalculationModel taxModel) async {
    widget.cartList = await databaseHelper.getCartItemList();
    for (int i = 0; i < taxModel.taxDetail.length; i++) {
      Product product = Product();
      product.taxDetail = taxModel.taxDetail[i];
      widget.cartList.add(product);
    }
    for (var i = 0; i < taxModel.fixedTax.length; i++) {
      Product product = Product();
      product.fixedTax = taxModel.fixedTax[i];
      widget.cartList.add(product);
    }
  }

  String selectedDeliverSlotValue = "";

  Widget addConfirmOrder() {
    return Container(
      height: 50.0,
      color: appTheme,
      child: InkWell(
        onTap: () async {},
        child: ButtonTheme(
          minWidth: Utils.getDeviceWidth(context),
          child: RaisedButton(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            textColor: Colors.white,
            color: appTheme,
            onPressed: () async {
              bool isNetworkAvailable = await Utils.isNetworkAvailable();
              if (!isNetworkAvailable) {
                Utils.showToast(AppConstant.noInternet, false);
                return;
              }

              print("Butttin is pressed9***************");
              Utils.showProgressDialog(context);
              var response =
              await ApiController.getStoreVersionData(storeModel.id);

              Utils.hideProgressDialog(context);
              Utils.hideKeyboard(context);
              StoreDataModel storeCheckData = response;
              if (response.success == true) {
                if (storeCheckData != null && storeCheckData.success)
                  setState(() {
                    storeModel = storeCheckData.store;
                  });
              }
              ;
              if (Utils.isRedundentClick(DateTime.now())) {
                return;
              }
//              StoreDataObj storeObject = await SharedPrefs.getStoreData();
              bool status = Utils.checkStoreOpenTime(storeModel,
                  deliveryType: widget.deliveryType);
              print("----checkStoreOpenTime----${status}--");
              print("${storeModel.storeStatus}*********");
              if (storeModel.storeStatus == "0") {
                DialogUtils.displayCommonDialog(
                  context,
                  storeModel.storeName,
                  storeModel.storeMsg,
                );
                return;
              }
              if (!status) {
                DialogUtils.displayCommonDialog(
                  context,
                  storeModel.storeName,
                  storeModel.closehoursMessage,
                );
                return;
              }
              if (widget.deliveryType == OrderType.Delivery &&
                  widget.address.notAllow) {
                if (!minOrderCheck) {
                  Utils.showToast(
                      "Your order amount is too low. Minimum order amount is ${widget
                          .address.minAmount}",
                      false);
                  return;
                }
              }
//              if (widget.deliveryType == OrderType.PickUp &&
//                  widget.areaObject != null) {
//                if (!minOrderCheck) {
//                  Utils.showToast(
//                      "Your order amount is too low. Minimum order amount is ${widget.areaObject.minOrder}",
//                      false);
//                  return;
//                }
//              }
              if (widget.deliveryType == OrderType.Delivery &&
                  widget.areaObject.notAllow) {
                print("abb***************");
                double totalItemPrice = double.parse(taxModel.itemSubTotal);
                double minOrderChecking =
                double.parse(
                    widget.areaObject.minOrder);
                print(
                    "abb*************** ${totalItemPrice} and ${minOrderChecking}");
                if (minOrderChecking > totalItemPrice) {
                  Utils.showToast(
                      "Your order amount is too low. Minimum order amount is ${widget
                          .areaObject.minOrder}",
                      false);
                  return;
                }
              }
              if (widget.deliveryType == OrderType.PickUp &&
                  widget.areaObject != null) {
                //  !minOrderCheck
                double totalItemPrice = double.parse(taxModel.itemSubTotal);
                double minOrderChecking =
                double.parse(
                    widget.areaObject.minOrder);
                if (minOrderChecking > totalItemPrice) {
                  Utils.showToast(
                      "Your order amount is too low. Minimum order amount is ${widget
                          .areaObject.minOrder}",
                      false);
                  return;
                }
              }
              if (checkThatItemIsInStocks()) {
                DialogUtils.displayCommonDialog(
                    context,
                    _brandData == null ? "" : _brandData.name,
                    "Some Cart items were updated. Please review the cart before procceeding.",
                    buttonText: 'Ok');
                return;
              }
//              if (storeModel.onlinePayment == "1") {
//                var result = await DialogUtils.displayPaymentDialog(
//                    context, "Select Payment", "");
//                //print("----result----${result}--");
//                if (result == null) {
//                  return;
//                }
//                if (result == PaymentType.ONLINE) {
//                  widget.paymentMode = "3";
//                } else {
//                  widget.paymentMode = "2"; //cod
//                }
//              } else {
//                widget.paymentMode = "2"; //cod
//              }

              print("----paymentMod----${widget.paymentMode}--");

              if (widget.deliveryType == OrderType.Delivery) {
                /*if (storeModel.deliverySlot == "0") {
                  selectedDeliverSlotValue = "";
                } else*/
                {
                  //Store provides instant delivery of the orders.
                  print(isInstantDelivery);
                  if (isDeliveryResponseFalse) {
                    selectedDeliverSlotValue = "";
                  } else if (/*storeModel.deliverySlot == "1" &&*/
                  isInstantDelivery) {
                    //Store provides instant delivery of the orders.
                    selectedDeliverSlotValue = "";
                  } else if (/*storeModel.deliverySlot == "1" &&*/
                  !isSlotSelected && !isInstantDelivery) {
                    Utils.showToast("Please select delivery slot", false);
                    return;
                  } else {
                    String slotDate = deliverySlotModel
                        .data.dateTimeCollection[selctedTag].label;
                    String timeSlot = deliverySlotModel
                        .data
                        .dateTimeCollection[selctedTag]
                        .timeslot[selectedTimeSlot]
                        .label;
                    selectedDeliverSlotValue =
                    "${Utils.convertDateFormat(slotDate)}, ${timeSlot}";
                    print(
                        "selectedDeliverSlotValue= ${selectedDeliverSlotValue}");
                  }
                }
              } else {
                selectedDeliverSlotValue = "";
              }

//              if (widget.deliveryType == OrderType.Delivery) {
//                //The "performPlaceOrderOperation" are called in below method
//                checkDeliveryAreaDeleted(storeModel,
//                    addressId: widget.address.id);
//              } else if (widget.deliveryType == OrderType.PickUp) {
//                performPlaceOrderOperation(storeModel);
//              }
              performPlaceOrderOperation(storeModel);
            },
            child: Text(
              "Confirm Order",
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
      ),
    );
  }

  performPlaceOrderOperation(StoreDataObj storeObject) async {
    String json = await databaseHelper.getCartItemsListToJson(
        isOrderVariations: isOrderVariations,
        responseOrderDetail: responseOrderDetail);
    if (json == null) {
      print("--json == null-json == null-");
      return;
    }

    String couponCode = taxModel == null ? "" : taxModel.couponCode;
    String discount = taxModel == null ? "0" : taxModel.discount;
    if (widget.deliveryType == OrderType.PickUp ||
        widget.deliveryType == OrderType.DineIn)
      Utils.showProgressDialog(context);

    Map<String, dynamic> attributeMap = new Map<String, dynamic>();
    attributeMap["ScreenName"] = "Order Confirm Screen";
    attributeMap["action"] = "Place Order Request";
    attributeMap["totalPrice"] = "${totalPrice}";
    attributeMap["deliveryType"] = "${widget.deliveryType}";
    attributeMap["paymentMode"] = "${widget.paymentMode}";
    attributeMap["shippingCharges"] = "${shippingCharges}";
    Utils.sendAnalyticsEvent("Clicked Place Order button", attributeMap);

    if (widget.subscriptionOrderType != null &&
        widget.paymentMode == "3" &&
        taxModel != null &&
        double.parse(taxModel.total) <= 0) {
      Utils.hideProgressDialog(context);
      placeOrderApiCall('0', '0', "Razorpay");
    } else if (
    widget.paymentMode == "3" &&
        taxModel != null && double.parse(taxModel.walletRefund) > 0 &&
        double.parse(taxModel.total) <= 0) {
      Utils.hideProgressDialog(context);
      placeOrderApiCall('0', '0', "Razorpay");
    } else if (widget.paymentMode == "3") {
      Utils.hideProgressDialog(context);
      if (ispaytmSelected) {
        callPaymentGateWay("Paytmpay");
      } else {
        String paymentGateway = _brandData.paymentGateway;
        if (_brandData.paymentGatewaySettings != null &&
            _brandData.paymentGatewaySettings.isNotEmpty) {
          //case only single gateway is coming
          if (_brandData.paymentGatewaySettings.length == 1) {
            paymentGateway =
                _brandData.paymentGatewaySettings.first.paymentGateway;
            callPaymentGateWay(paymentGateway);
          } else {
            //remove paytm option
            int indexToRemove = -1;
            for (int i = 0; i < _brandData.paymentGatewaySettings.length; i++) {
              if (_brandData.paymentGatewaySettings[i].paymentGateway
                  .toLowerCase()
                  .contains('paytm')) {
                indexToRemove = i;
                break;
              }
            }
            if (indexToRemove != -1) {
              _brandData.paymentGatewaySettings.removeAt(indexToRemove);
            }
            if (_brandData.paymentGatewaySettings.length == 1) {
              paymentGateway =
                  _brandData.paymentGatewaySettings.first.paymentGateway;
              callPaymentGateWay(paymentGateway);
            } else {
              String result =
              await DialogUtils.displayMultipleOnlinePaymentMethodDialog(
                  context, _brandData);
              if (result.isEmpty) {
                Utils.hideProgressDialog(context);
                return;
              }
              paymentGateway = result;
              callPaymentGateWay(paymentGateway);
            }
          }
          return;
        } else {
          //case payment gateway setting list empty
          callPaymentGateWay(paymentGateway);
        }
      }
    } else {
      placeOrderApiCall("", "", "");
    }
  }

  callPaymentGateWay(String paymentGateway) {
    Utils.hideProgressDialog(context);
    switch (paymentGateway) {
      case "Razorpay":
        callOrderIdApi("Razorpay");
        break;
      case "Stripe":
        callStripeApi();
        break;
      case "Paytmpay":
        callPaytmPayApi();
        break;
      case "PeachPayments":
        callOrderIdApi("Peachpay");
        break;
      case "Phonepe":
        callOrderIdApi("Phonepe");
        break;
    }
  }

  Future<void> removeCoupon() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if (!isNetworkAvailable) {
      Utils.showToast(AppConstant.noInternet, false);
      return;
    }
    Utils.showProgressDialog(context);
    print("------------3---------${shippingCharges}");
    databaseHelper
        .getCartItemsListToJson(
        isOrderVariations: isOrderVariations,
        responseOrderDetail: responseOrderDetail)
        .then((json) {
      ApiController.multipleTaxCalculationRequest(
          "", "0", "${shippingCharges}", json,
          isMembershipCouponEnabled:
          widget.subscriptionOrderType != null ? '1' : '0')
          .then((response) async {
        Utils.hideProgressDialog(context);
        Utils.hideKeyboard(context);
        if (response != null && !response.success) {
          Utils.showToast(response.message, true);
//          databaseHelper.deleteTable(DatabaseHelper.Favorite_Table);
          databaseHelper.deleteTable(DatabaseHelper.CART_Table);
//          databaseHelper.deleteTable(DatabaseHelper.Products_Table);
          eventBus.fire(updateCartCount());
          eventBus.fire(onCartRemoved());
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          await updateTaxDetails(response.taxCalculation);
          if (response.taxCalculation.orderDetail != null &&
              response.taxCalculation.orderDetail.isNotEmpty) {
            responseOrderDetail = response.taxCalculation.orderDetail;
            bool someProductsUpdated = false;
            isOrderVariations = response.taxCalculation.isChanged;
            for (int i = 0; i < responseOrderDetail.length; i++) {
              if (responseOrderDetail[i]
                  .productStatus
                  .compareTo('out_of_stock') ==
                  0 ||
                  responseOrderDetail[i]
                      .productStatus
                      .compareTo('price_changed') ==
                      0) {
                someProductsUpdated = true;
                break;
              }
            }
            if (someProductsUpdated) {
              DialogUtils.displayCommonDialog(
                  context,
                  storeModel == null ? "" : storeModel.storeName,
                  "Some Cart items were updated. Please review the cart before procceeding.",
                  buttonText: 'Procceed');
              constraints();
            }
          }
          calculateTotalSavings();

          setState(() {
            hideRemoveCouponFirstTime = true;
            taxModel = response.taxCalculation;
            appliedCouponCodeList.clear();
            appliedReddemPointsCodeList.clear();
            isCouponsApplied = false;
            couponCodeController.text = "";
          });
        }
      });
    });
  }

  Future<void> checkMinOrderAmount() async {
    if (widget.deliveryType == OrderType.Delivery) {
      print("----minAmount=${widget.address.minAmount}");
      print("----notAllow=${widget.address.notAllow}");
      print("--------------------------------------------");
      int minAmount = 0;
      try {
        try {
          minAmount = double.parse(widget.areaObject.minOrder).toInt();
        } catch (e) {
          print(e);
        }
        double totalPrice = await databaseHelper.getTotalPrice(
            isOrderVariations: isOrderVariations,
            responseOrderDetail: responseOrderDetail);
        int mtotalPrice = totalPrice.round();

        print("----minAmount=${minAmount}");
        print("--Cart--mtotalPrice=${mtotalPrice}");
        print("----shippingCharges=${shippingCharges}");
        print("----widget.areaObject.isShippingMandatory=${widget.areaObject
            .isShippingMandatory}");

        if (widget.areaObject.notAllow) {
          if (mtotalPrice <= minAmount) {
            print("---Cart-totalPrice is less than min amount----}");
            // then Store will charge shipping charges.
            minOrderCheck = false;
            setState(() {
              this.totalPrice = mtotalPrice.toDouble();
            });
          } else {
            minOrderCheck = true;
            print("---Cart-totalPrice is greater than min amount----}");
            setState(() {
              this.totalPrice = mtotalPrice.toDouble();
              if (widget.areaObject.isShippingMandatory == '0') {
                shippingCharges = "0";
                widget.address.areaCharges = "0";
                widget.areaObject.charges = "0";
              }
            });
          }
        } else {
          if (mtotalPrice <= minAmount) {
            print("---Cart-totalPrice is less than min amount----}");
            // then Store will charge shipping charges.
            setState(() {
              this.totalPrice = totalPrice + int.parse(shippingCharges);
            });
          } else {
            print("-Cart-totalPrice is greater than min amount---}");
            //then Store will not charge shipping.
            setState(() {
              this.totalPrice = totalPrice;
              if (widget.areaObject.isShippingMandatory == '0') {
                shippingCharges = "0";
                widget.address.areaCharges = "0";
                widget.areaObject.charges = "0";
              }
            });
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> checkMinOrderPickAmount() async {
    if ((widget.deliveryType == OrderType.PickUp ||
        widget.deliveryType == OrderType.DineIn) &&
        widget.areaObject != null) {
      print("----minAmount=${widget.areaObject.minOrder}");
      print("----notAllow=${widget.areaObject.notAllow}");
      print("--------------------------------------------");
      int minAmount = 0;
      try {
        try {
          if (widget.areaObject.minOrder.isNotEmpty)
            minAmount = double.parse(widget.areaObject.minOrder).toInt();
        } catch (e) {
          print(e);
        }
        double totalPrice = await databaseHelper.getTotalPrice(
            isOrderVariations: isOrderVariations,
            responseOrderDetail: responseOrderDetail);
        int mtotalPrice = totalPrice.round();

        print("----minAmount=${minAmount}");
        print("--Cart--mtotalPrice=${mtotalPrice}");
        //TODO:In Future check here "not allow".
        if (mtotalPrice <= minAmount) {
          print("---Cart-totalPrice is less than min amount----}");
          // then Store will charge shipping charges.
          minOrderCheck = false;
          setState(() {
            this.totalPrice = mtotalPrice.toDouble();
          });
        } else {
          minOrderCheck = true;
          setState(() {
            this.totalPrice = mtotalPrice.toDouble();
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void callStripeApi() {
    Utils.showProgressDialog(context);
    double price = double.parse(taxModel.total);
    price = price * 100;
    print("----taxModel.total----${taxModel.total}--");
    String mPrice =
    price.toString().substring(0, price.toString().indexOf('.')).trim();
    print("----mPrice----${mPrice}--");
    ApiController.stripePaymentApi(mPrice, storeModel.id).then((response) {
      Utils.hideProgressDialog(context);
      print("----stripePaymentApi------");
      if (response != null) {
        StripeCheckOutModel stripeCheckOutModel = response;
        if (stripeCheckOutModel.success) {
          //launchWebView(stripeCheckOutModel);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StripeWebView(stripeCheckOutModel)),
          );
        } else {
          Utils.showToast("${stripeCheckOutModel.message}!", true);
        }
      } else {
        Utils.showToast("Something went wrong!", true);
      }
    });
  }

  String razorpay_orderId = "";

  void openCheckout(String razorpay_order_id, BrandData storeObject) async {
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
    razorpay_orderId = razorpay_order_id;
    var options = {
      'key': '${key}',
      'currency': "INR",
      'order_id': razorpay_order_id,
      //'amount': taxModel == null ? (price * 100) : (double.parse(taxModel.total) * 100),
      'amount': (double.parse(taxModel.total) * 100),
      'name': '${storeModel.storeName}',
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

  void _handlePaymentSuccess(PaymentSuccessResponse responseObj) {
    //Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId, timeInSecForIos: 4);
    Utils.showProgressDialog(context);
    ApiController.razorpayVerifyTransactionApi(
        responseObj.orderId, storeModel.id)
        .then((response) {
      //print("----razorpayVerifyTransactionApi----${response}--");
      if (response != null) {
        RazorpayOrderData model = response;
        if (model.success) {
          placeOrderApiCall(responseObj.orderId, model.data.id, "Razorpay");
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
    Fluttertoast.showToast(msg: response.message, timeInSecForIosWeb: 4);
    print("----_handlePaymentError--message--${response.message}--");
    print("----_handlePaymentError--code--${response.code.toString()}--");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    /*print("----ExternalWalletResponse----${response.walletName}--");
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIos: 4);*/
  }

  void callOrderIdApi(String paymentGateWay) async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    if (!isNetworkAviable) {
      Utils.showToast(AppConstant.noInternet, false);
      return;
    }
    Utils.showProgressDialog(context);
    double price = double.parse(taxModel.total); //totalPrice ;
    print("=======1===${price}===total==${taxModel.total}======");
    price = price * 100;
    print("=======2===${price}===========");
    String mPrice =
    price.toString().substring(0, price.toString().indexOf('.'));
    print("=======mPrice===${mPrice}===========");
    UserModelMobile user = await SharedPrefs.getUserMobile();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    //new changes
    Utils.getCartItemsListToJson(
        isOrderVariations: isOrderVariations,
        responseOrderDetail: responseOrderDetail)
        .then((orderJson) {
      if (orderJson == null) {
        print("--orderjson == null-orderjson == null-");
        return;
      }
      String storeAddress = "";
      try {
        storeAddress = "${storeModel.storeName}, ${storeModel.location},"
            "${storeModel.city}, ${storeModel.state}, ${storeModel
            .country}, ${storeModel.zipcode}";
      } catch (e) {
        print(e);
      }

      String userId = user.id;
      OrderDetailsModel detailsModel = OrderDetailsModel(
          shippingCharges,
          comment,
          totalPrice.toString(),
          widget.paymentMode,
          taxModel,
          widget.address,
          widget.isComingFromPickUpScreen,
          widget.areaId,
          widget.deliveryType,
          "",
          "",
          deviceId,
          paymentGateWay,
          userId,
          deviceToken,
          storeAddress,
          selectedDeliverSlotValue,
          totalSavingsText,
          posBranchCode: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.posBranchCode ??
              ''
              : '',
          membershipId: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.id ??
              ''
              : '',
          membershipPlanDetailId: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.membershipPlanDetailId ??
              ''
              : '',
          additionalInfo: widget.subscriptionOrderType != null
              ? SingletonBrandData
              .getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.additionalInfo ?? ''
              : '',
          isMembershipCouponEnabled: widget.subscriptionOrderType != null
              ? '1'
              : '0');
      switch (paymentGateWay) {
        case "Razorpay":
          ApiController.razorpayCreateOrderApi(
              mPrice,
              orderJson,
              detailsModel.orderDetails,
              storeModel.id,
              _brandData.currencyAbbr)
              .then((response) {
            CreateOrderData model = response;
            if (model != null && response.success) {
              print("----razorpayCreateOrderApi----${response.data.id}--");
              openCheckout(model.data.id, _brandData);
            } else {
              Utils.showToast("${model.message}", true);
              Utils.hideProgressDialog(context);
            }
          });
          break;
        case "Peachpay":
          ApiController.peachPayCreateOrderApi(
              double.parse(taxModel.total).toStringAsFixed(2),
              orderJson,
              detailsModel.orderDetails,
              storeModel.id,
              _brandData.currencyAbbr)
              .then((response) {
            Utils.hideProgressDialog(context);
            PeachPayCheckOutResponse model = response;
            if (model == null) {
              Utils.showToast(AppConstant.noInternet, false);
            } else if (model != null && response.success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PeachPayWebView(model, storeModel.id)),
              );
            } else {
              Utils.showToast("Server Error", true);
            }
          });
          break;

        case "Phonepe":
          ApiController.phonepeCreateOrderApi(
            // double.parse(taxModel.total).toStringAsFixed(2), orderJson,
              double.parse(
                  '1'
              ).toStringAsFixed(2), orderJson,
              detailsModel.orderDetails,
              storeModel.id,
              _brandData.currencyAbbr, merchantUserId: userId)
              .then((response) {
            Utils.hideProgressDialog(context);
            PhonePeResponse model = response;
            if (model == null) {
              Utils.showToast(AppConstant.noInternet, false);
            }
            else if (model != null && response.success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PhonePeWebView(model, storeModel.id)),
              );
            } else {
              Utils.showToast("Server Error", true);
            }
          });
          break;
      }
    });
  }

  void placeOrderApiCall(String payment_request_id, String payment_id,
      String onlineMethod) {
    if (isOneTimeApiCalled) {
      return;
    }

    isOneTimeApiCalled = true;
    Utils.hideKeyboard(context);
    Utils.showProgressDialog(context);
    Utils.isNetworkAvailable().then((isNetworkAvailable) async {
      if (isNetworkAvailable == true) {
        /*databaseHelper
            .getCartItemsListToJson(
                isOrderVariations: isOrderVariations,
                responseOrderDetail: responseOrderDetail)
            .then((json) {*/
        Utils.getCartItemsListToJson(
            isOrderVariations: isOrderVariations,
            responseOrderDetail: responseOrderDetail)
            .then((json) {
          if (json == null) {
            print("--json == null-json == null-");
            return;
          }

//          String couponCode = taxModel == null ? "" : taxModel.couponCode;
//          String discount = taxModel == null ? "0" : taxModel.discount;
//          Utils.showProgressDialog(context);
//          ApiController.multipleTaxCalculationRequest(
//                  "${couponCode}", "${discount}", shippingCharges, json)
//              .then((response) {

          print("-paymentMode-${widget.paymentMode}");

          ApiController.placeOrderRequest(
              shippingCharges,
              comment,
              totalPrice.toString(),
              widget.paymentMode,
              taxModel,
              widget.address,
              json,
              widget.isComingFromPickUpScreen,
              widget.areaId,
              widget.deliveryType,
              payment_request_id,
              payment_id,
              onlineMethod,
              selectedDeliverSlotValue,
              cart_saving: totalSavings.toStringAsFixed(2),
              walletRefund: _brandData.walletSetting == "0"
                  ? ""
                  : taxModel == null
                  ? "0"
                  : "${taxModel.walletRefund}",
              posBranchCode: widget.subscriptionOrderType != null
                  ? SingletonBrandData
                  .getInstance()
                  ?.userPurchaseMembershipResponse
                  ?.data
                  ?.posBranchCode ??
                  ''
                  : '',
              membershipId: widget.subscriptionOrderType != null
                  ? SingletonBrandData
                  .getInstance()
                  ?.userPurchaseMembershipResponse
                  ?.data
                  ?.id ??
                  ''
                  : '',
              membershipPlanDetailId: widget.subscriptionOrderType != null
                  ? SingletonBrandData
                  .getInstance()
                  ?.userPurchaseMembershipResponse
                  ?.data
                  ?.membershipPlanDetailId ??
                  ''
                  : '',
              additionalInfo: widget.subscriptionOrderType != null
                  ? SingletonBrandData
                  .getInstance()
                  ?.userPurchaseMembershipResponse
                  ?.data
                  ?.additionalInfo ?? ''
                  : '',
              isMembershipCouponEnabled: widget.subscriptionOrderType != null
                  ? '1'
                  : '0')
              .then((response) async {
            Utils.hideProgressDialog(context);
            if (response == null) {
              print("--response == null-response == null-");
              return;
            }
            if (onlineMethod == 'Phonepe' && response.success == false
                && response.message.contains(
                    'Record has already been saved successfully!')) {

            } else if (response.success == false) {
              DialogUtils.displayCommonDialog(
                  context, _brandData.name, response.message);
              return;
            }
            if (AppConstant.isLoggedIn)
              ApiController.getUserMembershipPlanApi();
            eventBus.fire(updateCartCount());
            print("${widget.deliveryType}");
            //print("Location = ${storeModel.lat},${storeModel.lng}");
            if (widget.deliveryType == OrderType.PickUp ||
                widget.deliveryType == OrderType.DineIn) {
              bool result = await DialogUtils.displayPickUpDialog(context);
              if (result == true) {
                //print("==result== ${result}");
                await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                Navigator.of(context).popUntil((route) => route.isFirst);
                eventBus.fire(updateCartCount());
                eventBus.fire(onCartRemoved());
                DialogUtils.openMap(storeModel, double.parse(storeModel.lat),
                    double.parse(storeModel.lng));
              } else {
                //print("==result== ${result}");
                await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                eventBus.fire(updateCartCount());
                eventBus.fire(onCartRemoved());
                eventBus.fire(openHome());
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            } else {
              bool result = await DialogUtils.displayThankYouDialog(context,
                  response.success ? AppConstant.orderAdded :
                  (onlineMethod == 'Phonepe' && response.success == false
                      && response.message.contains(
                          AppConstant.record_already_exist_msg))
                      ? AppConstant.orderAdded : response.message);
              if (result == true) {
                await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                Navigator.of(context).popUntil((route) => route.isFirst);
                eventBus.fire(onCartRemoved());
                eventBus.fire(updateCartCount());
                eventBus.fire(openHome());
              }
            }
          });
        });
      } else {
        Utils.showToast(AppConstant.noInternet, false);
      }
    });
  }

  void initRazorPay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void listenWebViewChanges() {
    eventBus.on<onPageFinished>().listen((event) {
      print("<---onPageFinished------->");
      callStripeVerificationApi(event.url);
    });

    eventBus.on<onPayTMPageFinished>().listen((event) {
      print("Event Bus called");
      callPaytmApi(event.url, event.orderId, event.txnId);
    });
    eventBus.on<onPeachPayFinished>().listen((event) {
      print("Event Bus called");
      callPeachPayPaytmOrderApi(
          event.url, event.checkoutID, event.resourcePath);
    });
    eventBus.on<onPhonePeFinished>().listen((event) {
      callPhonePeFinishedOrderApi(
          event.paymentRequestId, event.transId);
    });
  }

  void callPaytmApi(String url, String orderId, String txnID) {
    placeOrderApiCall(orderId, txnID, 'paytm');
  }

  void callPeachPayPaytmOrderApi(String url, String checkoutID,
      String resourcePath) {
    Utils.showProgressDialog(context);
    ApiController.peachPayVerifyTransactionApi(checkoutID, storeModel.id)
        .then((response) {
      Utils.hideProgressDialog(context);
      //print("----razorpayVerifyTransactionApi----${response}--");
      if (response != null) {
        PeachPayVerifyResponse model = response;
        if (model.success) {
          placeOrderApiCall(
              response.data.checkoutId, response.data.id, 'PeachPayments');
        } else {
          Utils.showToast("payment failed", true);
        }
      } else {
        Utils.showToast("Something went wrong!", true);
      }
    });
  }

  void callPhonePeFinishedOrderApi(String paymentRequestId,
      String transId) {
    Utils.showProgressDialog(context);
    ApiController.phonePeVerifyTransactionApi(
        paymentRequestId, storeModel.id)
        .then((response) {
      Utils.hideProgressDialog(context);
      print("----phonePeVerifyTransactionApi----${response}--");
      if (response != null) {
        PhonePeVerifyResponse model = response;
        if (model.success) {
          placeOrderApiCall(
              response.paymentRequestId, response.data.data.providerReferenceId,
              'Phonepe');
        } else {
          Utils.showToast("payment failed", true);
        }
      } else {
        Utils.showToast("Something went wrong!", true);
      }
    });
  }

  void callStripeVerificationApi(String payment_request_id) {
    Utils.showProgressDialog(context);
    ApiController.stripeVerifyTransactionApi(payment_request_id, storeModel.id)
        .then((response) {
      Utils.hideProgressDialog(context);
      if (response != null) {
        StripeVerifyModel object = response;
        if (object.success) {
          placeOrderApiCall(payment_request_id, object.paymentId, "Stripe");
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

  bool isloyalityPointsEnabled = false;

  void checkLoyalityPointsOption() {
    //1 - enable, 0 means disable
    try {
      print("====-loyality===== ${_brandData.loyality}--");
      if (_brandData.loyality != null && _brandData.loyality == "1") {
        this.isloyalityPointsEnabled = true;
      } else {
        this.isloyalityPointsEnabled = false;
      }
      /* print("====-loyality===== ${storeModel.loyality}--");
      if (storeModel.loyality != null && storeModel.loyality == "1") {
        this.isloyalityPointsEnabled = true;
      } else {
        this.isloyalityPointsEnabled = false;
      }*/
    } catch (e) {
      print(e);
    }
  }

  Widget addCommentWidget(BuildContext context) {
    return !isCommentAdded
        ? InkWell(
      onTap: () async {
        String result =
        await DialogUtils.displayCommentDialog(context, comment);
        comment = result;
        if (comment != "") {
          setState(() {
            isCommentAdded = !isCommentAdded;
          });
        }
      },
      child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              Padding(
                child: Icon(Icons.add, size: 18.0),
                padding: EdgeInsets.only(right: 3),
              ),
              new Text(
                "Add Comment",
                style: new TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Medium',
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              )
            ],
          ),
          color: grayLightColor),
    )
        : Container(
        padding: const EdgeInsets.all(20.0),
        child: getCommentedView(context),
        color: grayLightColor);
  }

  Widget getCommentedView(BuildContext context) {
    return Wrap(children: <Widget>[
      Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: new Text(
                    "Your Comment",
                    style: new TextStyle(
                        fontFamily: 'bold',
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )),
              InkWell(
                onTap: () async {
                  String result =
                  await DialogUtils.displayCommentDialog(context, comment);
                  comment = result;
                  setState(() {
                    if (comment != "") {
                      isCommentAdded = true;
                    } else {
                      isCommentAdded = false;
                    }
                  });
                },
                child: Padding(
                  child: Icon(
                    Icons.edit,
                    size: 18.0,
                  ),
                  padding: EdgeInsets.only(right: 5, left: 5),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    comment = "";
                    isCommentAdded = false;
                    Utils.showToast("Comment Deleted", true);
                  });
                },
                child: Padding(
                  child: Icon(Icons.delete, size: 18.0),
                  padding: EdgeInsets.only(right: 5, left: 5),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: new Text(
                    comment,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        ],
      )
    ]);
  }

  void checkPaytmActive() {
    //TODO: Fix me
//    String paymentGateway = storeModel.paymentGateway;
//    if (storeModel.paymentGatewaySettings != null &&
//        storeModel.paymentGatewaySettings.isNotEmpty) {
//      //case only single gateway is comming
//      if (storeModel.paymentGatewaySettings.length == 1) {
//        paymentGateway = storeModel.paymentGatewaySettings.first.paymentGateway;
//        if (paymentGateway.toLowerCase().contains('paytm')) {
//          isPayTmActive = true;
//        }
//      } else {
//        for (int i = 0; i < storeModel.paymentGatewaySettings.length; i++) {
//          paymentGateway = storeModel.paymentGatewaySettings[i].paymentGateway;
//          if (paymentGateway.toLowerCase().contains('paytm')) {
//            isPayTmActive = true;
//            break;
//          }
//        }
//      }
//    } else {
//      if (paymentGateway.toLowerCase().contains('paytm')) {
//        isPayTmActive = true;
//      }
//    }
  }

  Future<bool> constraints() async {
    try {
      if (widget.areaObject != null) {
        if (widget.areaObject.charges != null) {
          if (responseOrderDetail.isNotEmpty && checkThatItemIsInStocks())
            shippingCharges = '0';
          else {
            shippingCharges = widget.areaObject.charges;
          }
        }
        //print("----minAmount=${widget.address.minAmount}");
        //print("----notAllow=${widget.address.notAllow}");
        await checkMinOrderAmount();
      }
      await checkMinOrderPickAmount();
    } catch (e) {
      print(e);
    }
    try {
      if (widget.deliveryType == OrderType.PickUp) {
        databaseHelper
            .getTotalPrice(
            isOrderVariations: isOrderVariations,
            responseOrderDetail: responseOrderDetail)
            .then((mTotalPrice) {
          setState(() {
            totalPrice = mTotalPrice;
          });
        });
      }
    } catch (e) {
      print(e);
    }
    if (responseOrderDetail.isNotEmpty &&
        checkThatItemIsInStocks() &&
        taxModel != null) {
      shippingCharges = '0';
      taxModel.total = '0';
      totalPrice = 0;
    }
    if (mounted) {
      setState(() {});
    }
    return Future(() => true);
  }

  bool checkThatItemIsInStocks() {
    bool isAllItemsInOutOfStocks = true;
    for (int j = 0; j < widget.cartList.length; j++) {
      Product product = widget.cartList[j];
      if (product.id != null) {
        //check product is out of stock
        bool productOutOfStock = _checkIsProductISOutOfStock(product);
        if (!productOutOfStock) {
          isAllItemsInOutOfStocks = false;
          break;
        }
      }
    }
    return isAllItemsInOutOfStocks;
  }

  bool _checkIsProductISOutOfStock(Product product) {
    bool productOutOfStock = false;
    for (int i = 0; i < responseOrderDetail.length; i++) {
      if (product.id.compareTo(responseOrderDetail[i].productId) == 0 &&
          product.variantId.compareTo(responseOrderDetail[i].variantId) == 0) {
        if (responseOrderDetail[i].productStatus.compareTo('out_of_stock') ==
            0) {
          productOutOfStock = true;
        } else {
          productOutOfStock = false;
        }
        break;
      }
    }
    return productOutOfStock;
  }
}

/*Code for ios*/
class StripeWebView extends StatefulWidget {
  String amount;
  StripeCheckOutModel stripeCheckOutModel;

  StripeWebView(this.stripeCheckOutModel,{this.amount});

  @override
  _StripeWebViewState createState() {
    return _StripeWebViewState();
  }
}

class _StripeWebViewState extends State<StripeWebView> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

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
            initialUrl: '${widget.stripeCheckOutModel.checkoutUrl}',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            navigationDelegate: (NavigationRequest request) {
              //print('=======NavigationRequest======= $request}');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              //print('======Page started loading======: $url');
            },
            onPageFinished: (String url) {
              print('======Page finished loading======: $url');
              if (url.contains(
                  "stripe/stripeVerifyTransaction?response=success")) {
                eventBus.fire(onPageFinished(
                    widget.stripeCheckOutModel.paymentRequestId,amount:widget.amount));
                Navigator.pop(context);
              }
            },
            gestureNavigationEnabled: false,
          );
        }),
      ),
    );
  }
}

class PaytmWebView extends StatelessWidget {
  CreatePaytmTxnTokenResponse stripeCheckOutModel;
  Completer<WebViewController> _controller = Completer<WebViewController>();

  PaytmWebView(this.stripeCheckOutModel);

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
            initialUrl: '${stripeCheckOutModel.url}',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            navigationDelegate: (NavigationRequest request) {
              //print('=======NavigationRequest======= $request}');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              //print('======Page started loading======: $url');
            },
            onPageFinished: (String url) {
              print('==2====onLoadStop======: $url');
              if (url.contains("/api/paytmPaymentResult/orderId:")) {
                String txnId =
                url.substring(url.indexOf("/TxnId:") + "/TxnId:".length);
                url = url.replaceAll("/TxnId:" + txnId, "");
                String orderId = url
                    .substring(url.indexOf("/orderId:") + "/orderId:".length);
                print(txnId);
                print(orderId);
                eventBus.fire(
                    onPayTMPageFinished(url, orderId = orderId, txnId = txnId));
                Navigator.pop(context);
              } else if (url.contains("api/paytmPaymentResult/failure:")) {
                Navigator.pop(context);
                Utils.showToast("Payment Failed", false);
              }
            },
            gestureNavigationEnabled: false,
          );
        }),
      ),
    );
  }
}

class PeachPayWebView extends StatelessWidget {
  PeachPayCheckOutResponse responseModel;
  Completer<WebViewController> _controller = Completer<WebViewController>();
  String storeID;
  String amount;

  PeachPayWebView(this.responseModel, this.storeID,{this.amount});

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
            initialUrl:
            '${ApiConstants.baseUrl3.replaceAll(
                "storeId", storeID)}${ApiConstants
                .processPeachpayPayment}${responseModel.data.id}',
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
              if (url.contains("/peachpay/peachPayVerify?id=")) {
                String resourcePath = url.substring(
                    url.indexOf("&resourcePath=") + "&resourcePath=".length);
                url = url.replaceAll("&resourcePath=" + resourcePath, "");
                String checkoutID =
                url.substring(url.indexOf("?id=") + "?id=".length);
                print(resourcePath);
                print(checkoutID);
                eventBus
                    .fire(onPeachPayFinished(url, checkoutID, resourcePath,amount:amount));
                Navigator.pop(context);
              } else if (url.contains("failure")) {
                Navigator.pop(context);
                Utils.showToast("Payment Failed", false);
              }
            },
            gestureNavigationEnabled: false,
          );
        }),
      ),
    );
  }
}
