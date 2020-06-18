import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:restroapp/src/Screens/Offers/AvailableOffersList.dart';
import 'package:restroapp/src/Screens/Offers/RedeemPointsScreen.dart';
import 'package:restroapp/src/apihandler/ApiConstants.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/CreateOrderData.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/DeliveryTimeSlotModel.dart';
import 'package:restroapp/src/models/RazorpayOrderData.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StripeCheckOutModel.dart';
import 'package:restroapp/src/models/StripeVerifyModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TaxCalulationResponse.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ConfirmOrderScreen extends StatefulWidget {

  bool isComingFromPickUpScreen;
  DeliveryAddressData address;
  String paymentMode = "2"; // 2 = COD, 3 = Online Payment
  String areaId;
  OrderType deliveryType;
  List<Product> cartList = new List();

  ConfirmOrderScreen(this.address, this.isComingFromPickUpScreen,this.areaId,this.deliveryType);

  @override
  ConfirmOrderState createState() => ConfirmOrderState();
}

class ConfirmOrderState extends State<ConfirmOrderScreen> {

  DatabaseHelper databaseHelper = new DatabaseHelper();
  double totalPrice = 0.00;
  TaxCalculationModel taxModel;
  TextEditingController noteController = TextEditingController();
  String shippingCharges = "0";
  static const platform = const MethodChannel("razorpay_flutter");
  Razorpay _razorpay;
  StoreModel storeModel;
  DeliveryTimeSlotModel deliverySlotModel;
  int selctedTag, selectedTimeSlot;
  List<Timeslot> timeslotList;
  bool isSlotSelected = false;
  bool minOrderCheck =true;
  bool isLoading = true;
  bool hideRemoveCouponFirstTime;

  @override
  void initState() {
    super.initState();
    initRazorPay();
    listenWebViewChanges();
    selctedTag = 0;
    hideRemoveCouponFirstTime = true;
    print("-deliveryType--${widget.deliveryType}---");
    try {
      if(widget.address != null){
        if(widget.address.areaCharges != null){
          shippingCharges = widget.address.areaCharges;
          print("-shippingCharges--${widget.address.areaCharges}---");
        }
        //print("----minAmount=${widget.address.minAmount}");
        //print("----notAllow=${widget.address.notAllow}");
        checkMinOrderAmount();
      }
    } catch (e) {
      print(e);
    }
    try {
      if(widget.deliveryType == OrderType.PickUp){
        databaseHelper.getTotalPrice().then((mTotalPrice) {
          setState(() {
            totalPrice = mTotalPrice;
          });
        });
      }
    } catch (e) {
      print(e);
    }
    try {
      SharedPrefs.getStore().then((storeData){
        storeModel = storeData;
        checkLoyalityPointsOption();
        if(widget.deliveryType == OrderType.Delivery){
          if(storeModel.deliverySlot == "1"){
            ApiController.deliveryTimeSlotApi().then((response){
              setState(() {
                deliverySlotModel = response;
                for(int i = 0; i < deliverySlotModel.data.dateTimeCollection.length; i++){
                  timeslotList = deliverySlotModel.data.dateTimeCollection[i].timeslot;
                  for(int j = 0; j < timeslotList.length; j++){
                    Timeslot timeslot = timeslotList[j];
                    if(timeslot.isEnable){
                      selectedTimeSlot = j;
                      isSlotSelected = true;
                      break;
                    }
                  }
                  if(isSlotSelected){
                    selctedTag = i;
                    break;
                  }
                }
              });
            });
          }
        }
      });
    } catch (e) {
      print(e);
    }
    multiTaxCalculationApi();
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text("Confirm Order"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context, false),
          ),
        actions: <Widget>[
          InkWell(
            onTap: (){
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Padding(
              padding: EdgeInsets.only(top: 0.0, bottom: 0.0,left: 0,right: 10),
              child: Icon(Icons.home, color: Colors.white,size: 30,),
            ),
          ),

        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                          height: 45,
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                            border: new Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: TextField(
                            textAlign: TextAlign.left,
                            controller: noteController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              hintText: "Enter note",
                              border: InputBorder.none,
                            ),
                          ))),
                  showDeliverySlot(),
                  Expanded(
                    child: isLoading ? Utils.getIndicatorView()
                        : widget.cartList == null ? Text("") :ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {

                        if(widget.cartList[index].taxDetail == null ||
                            widget.cartList[index].taxDetail == null){
                          return Divider(color: Colors.grey, height: 1);
                        }else{
                          return Divider(color: Colors.white, height: 1);
                        }
                      },
                      shrinkWrap: true,
                      itemCount: widget.cartList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == widget.cartList.length) {
                          return addItemPrice();
                        } else {
                          return addProductCart(widget.cartList[index]);
                        }
                      },
                    ),
                  ),
                ]
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Wrap(
                children: [addTotalPrice(), addCouponCodeRow(), addConfirmOrder()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> multiTaxCalculationApi() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if(!isNetworkAvailable){
      Utils.showToast(AppConstant.noInternet, false);
      return;
    }
    isLoading = true;
    databaseHelper.getCartItemsListToJson().then((json) {
      ApiController.multipleTaxCalculationRequest("", "0", "$shippingCharges", json).then((response) async {
        //{"success":false,"message":"Some products are not available."}
        TaxCalculationResponse model = response;
        if(model.success){
          taxModel = model.taxCalculation;
          widget.cartList = await databaseHelper.getCartItemList();
          for(int i = 0; i < model.taxCalculation.taxDetail.length; i++){
            Product product = Product();
            product.taxDetail = model.taxCalculation.taxDetail[i];
            widget.cartList.add(product);
          }
          for (var i = 0; i < model.taxCalculation.fixedTax.length; i++) {
            Product product = Product();
            product.fixedTax = model.taxCalculation.fixedTax[i];
            widget.cartList.add(product);
          }
          setState(() {
            isLoading = false;
          });
        }else{
          var result = await DialogUtils.displayCommonDialog(context, storeModel == null ? ""
              : storeModel.storeName, "${model.message}");
          if(result != null && result == true){
            databaseHelper.deleteTable(DatabaseHelper.Favorite_Table);
            databaseHelper.deleteTable(DatabaseHelper.CART_Table);
            databaseHelper.deleteTable(DatabaseHelper.Products_Table);
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      });
    });
  }

  Widget showDeliverySlot(){
    Color selectedSlotColor, textColor;
    if(deliverySlotModel == null){
      return Container();
    }else{
      //print("--length = ${deliverySlotModel.data.dateTimeCollection.length}----");
      if(deliverySlotModel.data != null && deliverySlotModel.data.dateTimeCollection != null &&
          deliverySlotModel.data.dateTimeCollection.isNotEmpty){
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
                      width: MediaQuery.of(context).size.width,
                      color: Color(0xFFBDBDBD)
                  ),
                  Container(
                    //margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    height: 50.0,
                    child: ListView.builder(
                      itemCount: deliverySlotModel.data.dateTimeCollection.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        DateTimeCollection slotsObject = deliverySlotModel.data.dateTimeCollection[index];
                        if(selctedTag == index){
                          selectedSlotColor = Color(0xFFEEEEEE);
                          textColor = Color(0xFFff4600);
                        }else{
                          selectedSlotColor = Color(0xFFFFFFFF);
                          textColor = Color(0xFF000000);
                        }
                        return Container(
                          color: selectedSlotColor,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: InkWell(
                            onTap: (){
                              print("${slotsObject.timeslot.length}");
                              setState(() {
                                selctedTag = index;
                                timeslotList = slotsObject.timeslot;
                                isSlotSelected = false;
                                //selectedTimeSlot = 0;
                                //print("timeslotList=${timeslotList.length}");
                                for(int i = 0; i < timeslotList.length; i++){
                                  //print("isEnable=${timeslotList[i].isEnable}");
                                  Timeslot timeslot = timeslotList[i];
                                  if(timeslot.isEnable){
                                    selectedTimeSlot = i;
                                    isSlotSelected = true;
                                    break;
                                  }
                                }

                              });
                            },
                            child: Container(
                              child: Center(
                                child: Text(' ${Utils.convertStringToDate(slotsObject.label)} ',
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
                      width: MediaQuery.of(context).size.width,
                      color: Color(0xFFBDBDBD)
                  ),
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
                        if(!slotsObject.isEnable){
                          textColor = Color(0xFFBDBDBD);
                        }else{
                          textColor = Color(0xFF000000);
                        }
                        if(selectedTimeSlot == index && (slotsObject.isEnable)){
                          textColor = Color(0xFFff4600);
                        }

                        return Container(
                          //color: selectedSlotColor,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: InkWell(
                            onTap: (){
                              print("${slotsObject.label}");
                              if(slotsObject.isEnable){
                                setState(() {
                                  selectedTimeSlot = index;
                                });
                              }else{
                                Utils.showToast(slotsObject.innerText, false);
                              }
                            },
                            child: Container(
                              child: Center(
                                child: Text('${slotsObject.isEnable == true ? slotsObject.label :
                                "${slotsObject.label}(${slotsObject.innerText})"}',
                                    style: TextStyle(color: textColor)
                                ),
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
      }else{
        return Container();
      }
    }
  }

  Widget addProductCart(Product product) {

    if(product.taxDetail != null){

      return Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${product.taxDetail.label} (${product.taxDetail.rate}%)", style: TextStyle(color: Colors.black54)),
              Text("${AppConstant.currency}${product.taxDetail.tax}",
                  style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );

    }else if(product.fixedTax != null){
      return Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${product.fixedTax.fixedTaxLabel}", style: TextStyle(color: Colors.black54)),
              Text("${AppConstant.currency}${product.fixedTax.fixedTaxAmount}",
                  style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
    }else{
      return Container(
        padding: EdgeInsets.fromLTRB(15, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: SizedBox(
                      width: (Utils.getDeviceWidth(context)-150),
                      child: Container(
                        color: whiteColor,
                        child: Text(product.title,maxLines: 2,overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                ),
                Visibility(
                  visible: product.weight.isEmpty ? false : true,
                  child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text("${product.weight}",style: TextStyle(color: orangeColor),)
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text("Quantity: ${product.quantity} X ${AppConstant.currency}${double.parse(product.price).toStringAsFixed(2)}")
                ),
                //
                Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 20),
                    child: Text("Price: " + "${AppConstant.currency}${double.parse(product.price).toStringAsFixed(2)}")),
              ],
            ),
            Text(
                "${AppConstant.currency}${databaseHelper.roundOffPrice(int.parse(product.quantity) * double.parse(product.price), 2).toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, color: Colors.black45)),
          ],
        ),
      );
    }

  }

  Widget addItemPrice() {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 1,
            color: Colors.black45,
            width: MediaQuery.of(context).size.width),
        Visibility(
          visible: widget.address == null? false : true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Delivery charges:", style: TextStyle(color: Colors.black54)),
                Text("${AppConstant.currency}${widget.address == null? "0" : widget.address.areaCharges}",
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
        Visibility(
          visible: taxModel == null? false : true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Discount:", style: TextStyle(color: Colors.black54)),
                Text("${AppConstant.currency}${taxModel == null? "0" : taxModel.discount}",
                    style: TextStyle(color: Colors.black54)),
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
              Text("${AppConstant.currency}${databaseHelper.roundOffPrice((totalPrice-int.parse(shippingCharges)), 2).toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.black)),
            ],
          ),
        ),

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
            width: MediaQuery.of(context).size.width),
        Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total",style:TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${AppConstant.currency}${databaseHelper.roundOffPrice(
                    taxModel == null ? totalPrice : double.parse(taxModel.total), 2).toStringAsFixed(2)}",
                    style:TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ))
      ]),
    );
  }

  List<String> appliedCouponCodeList = List();
  List<String> appliedReddemPointsCodeList = List();
  Widget addCouponCodeRow() {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Row(
          children: <Widget>[
            //isloyalityPointsEnabled
            Visibility(
              visible:  isloyalityPointsEnabled == true ? true : false,
              child: Expanded(
                child: InkWell(
                  onTap: () async {
                    print("appliedCouponCodeList = ${appliedCouponCodeList.length}");
                    print("appliedReddemPointsCodeList = ${appliedReddemPointsCodeList.length}");

                    if(appliedCouponCodeList.isNotEmpty){
                      Utils.showToast("Please remove Applied Coupon to Redeem Points", false);
                      return;
                    }
                    var result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
                        RedeemPointsScreen(widget.address, "" ,widget.isComingFromPickUpScreen,
                            widget.areaId, (model) {
                              setState(() {
                                hideRemoveCouponFirstTime = false;
                                taxModel = model;
                                double taxModelTotal = double.parse(taxModel.total) + int.parse(shippingCharges);
                                taxModel.total = taxModelTotal.toString();
                                appliedReddemPointsCodeList.add(model.couponCode);
                                print("===discount=== ${model.discount}");
                                print("taxModel.total=${taxModel.total}");
                              });
                        },appliedReddemPointsCodeList),

                      fullscreenDialog: true,
                    ));

                  },
                  child: Container(
                    //width: 140.0,
                    height: 40.0,
                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    decoration: new BoxDecoration(color: appTheme,
                      border: new Border.all(color: appTheme, width: 1.0,),
                    ),
                    child: Center(child: Text("Redeem Points",style: TextStyle(color: whiteColor),)
                    ),
                  ),
                ),
              ),
            ),
            /*Visibility(
              visible:  isloyalityPointsEnabled == true ? false : true,
              child: Expanded(
                child: Container(
                  //width: 140.0,
                  height: 40.0,
                  decoration: new BoxDecoration(color: Colors.white,
                    border: new Border.all(color: Colors.grey, width: 1.0, ),
                  ),
                  child: Center(child: Text(
                      taxModel == null ? 'Coupon Code:' : taxModel.couponCode ?? "")
                  ),
                ),
              ),
            ),*/
            Visibility(
              //visible: taxModel == null ? false : true,
              visible: hideRemoveCouponFirstTime ? false : true,
              child: Expanded(
                child: Container(
                  //width: 130.0,
                  height: 40.0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: RaisedButton(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      textColor: Colors.white,
                      color: appTheme,
                      onPressed: () {
                        if (taxModel != null) {
                          removeCoupon();
                        }
                      },
                      child: new Text(taxModel == null ?
                      "Apply Coupon" : "Remove Coupon",softWrap: true),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {

                  if(appliedReddemPointsCodeList.isNotEmpty){
                    Utils.showToast("Please remove Applied Coupon to Avail Offers", false);
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AvailableOffersDialog(
                        widget.address, "" ,widget.isComingFromPickUpScreen,widget.areaId,(model) {
                      setState(() {
                        hideRemoveCouponFirstTime = false;
                        taxModel = model;
                        double taxModelTotal = double.parse(taxModel.total) + int.parse(shippingCharges);
                        taxModel.total = taxModelTotal.toString();
                        appliedCouponCodeList.add(model.couponCode);
                        print("===couponCode=== ${model.couponCode}");
                        print("taxModel.total=${taxModel.total}");
                      });
                    },appliedCouponCodeList),
                  );
                },
                child: Container(
                  //width: 100.0,
                  height: 40,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: new BoxDecoration(
                    color: appTheme,
                    border: new Border.all(
                      color: appTheme,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text("Available\nOffers",textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white,)),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  String selectedDeliverSlotValue = "";
  Widget addConfirmOrder() {
    return Container(
      height: 50.0,
      color: appTheme,
      child: InkWell(
        onTap: () async {

        },
        child: ButtonTheme(
          minWidth: Utils.getDeviceWidth(context),
          child: RaisedButton(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            textColor: Colors.white,
            color: appTheme,
            onPressed: () async {
              StoreModel storeObject = await SharedPrefs.getStore();
              bool status = Utils.checkStoreOpenTime(storeObject,widget.deliveryType);
              print("----checkStoreOpenTime----${status}--");

              if(!status){
                Utils.showToast("${storeObject.closehoursMessage}", false);
                return;
              }
              if(widget.deliveryType == OrderType.Delivery && widget.address.notAllow){
                if(!minOrderCheck){
                  Utils.showToast("Your order amount is to low. Minimum order amount is ${widget.address.minAmount}", false);
                  return;
                }
              }


              if(storeModel.onlinePayment == "1"){
                var result = await DialogUtils.displayPaymentDialog(context, "Select Payment","");
                //print("----result----${result}--");
                if(result == null){
                  return;
                }
                if(result == PaymentType.ONLINE){
                  widget.paymentMode = "3";
                }else{
                  widget.paymentMode = "2"; //cod
                }
              }else{
                widget.paymentMode = "2"; //cod
              }

              print("----paymentMod----${widget.paymentMode}--");
              print("-paymentGateway----${storeObject.paymentGateway}-}-");

              bool isNetworkAvailable = await Utils.isNetworkAvailable();
              if(!isNetworkAvailable){
                Utils.showToast(AppConstant.noInternet, false);
                return;
              }

              if(widget.deliveryType == OrderType.Delivery){
                if(storeObject.deliverySlot == "0"){
                  selectedDeliverSlotValue = "";
                }else{
                  if(storeObject.deliverySlot == "1" && !isSlotSelected){
                    Utils.showToast("Please select delivery slot", false);
                    return;
                  }else{
                    String slotDate = deliverySlotModel.data.dateTimeCollection[selctedTag].label;
                    String timeSlot = deliverySlotModel.data.dateTimeCollection[selctedTag].timeslot[selectedTimeSlot].label;
                    selectedDeliverSlotValue = "${Utils.convertDateFormat(slotDate)} ${timeSlot}";
                    //print("selectedDeliverSlotValue= ${selectedDeliverSlotValue}");
                  }
                }
              }else{
                selectedDeliverSlotValue = "";
              }

              if(widget.paymentMode == "3"){
                if(storeObject.paymentGateway == "Razorpay"){
                  callOrderIdApi(storeObject);
                }else if(storeObject.paymentGateway == "Stripe"){
                  callStripeApi();
                }
              }else{
                placeOrderApiCall("","","");
              }


            },
            child: Text("Confirm Order",
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> removeCoupon() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if(!isNetworkAvailable){
      Utils.showToast(AppConstant.noInternet, false);
      return;
    }
    Utils.showProgressDialog(context);
    databaseHelper.getCartItemsListToJson().then((json) {
      ApiController.multipleTaxCalculationRequest("", "0", "${shippingCharges}", json)
          .then((response) {
        Utils.hideProgressDialog(context);
        if (response != null && !response.success) {
          Utils.showToast(response.message, true);
          databaseHelper.deleteTable(DatabaseHelper.Favorite_Table);
          databaseHelper.deleteTable(DatabaseHelper.CART_Table);
          databaseHelper.deleteTable(DatabaseHelper.Products_Table);
          Navigator.of(context).popUntil((route) => route.isFirst);
        }else{
          setState(() {
            hideRemoveCouponFirstTime = true;
            taxModel = response.taxCalculation;
            appliedCouponCodeList.clear();
            appliedReddemPointsCodeList.clear();
          });
        }

      });
    });
  }


  Future<void> checkMinOrderAmount() async {
    if(widget.deliveryType == OrderType.Delivery){
      print("----minAmount=${widget.address.minAmount}");
      print("----notAllow=${widget.address.notAllow}");
      print("--------------------------------------------");
      try {
        int minAmount = double.parse(widget.address.minAmount).toInt();
        double totalPrice = await databaseHelper.getTotalPrice();
        int mtotalPrice = totalPrice.round();

        print("----minAmount=${minAmount}");
        print("--Cart--mtotalPrice=${mtotalPrice}");
        print("----shippingCharges=${shippingCharges}");

        if(widget.address.notAllow){
          if(mtotalPrice <= minAmount){
            print("---Cart-totalPrice is less than min amount----}");
            // then Store will charge shipping charges.
            minOrderCheck = false;
            setState(() {
              this.totalPrice = mtotalPrice.toDouble();
            });
          }else{
            minOrderCheck = true;
            setState(() {
              this.totalPrice = mtotalPrice.toDouble();
            });
          }
        }else{
          if(mtotalPrice <= minAmount){
            print("---Cart-totalPrice is less than min amount----}");
            // then Store will charge shipping charges.
            setState(() {
              this.totalPrice = totalPrice + int.parse(shippingCharges);
            });
          }else{
            print("-Cart-totalPrice is greater than min amount---}");
            //then Store will not charge shipping.
            setState(() {
              this.totalPrice = totalPrice;
              shippingCharges = "0";
              widget.address.areaCharges = "0";
            });
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }


  void callStripeApi() {
    Utils.showProgressDialog(context);
    double price = double.parse(taxModel.total);//;
    String mPrice = price.toString().substring(0 , price.toString().indexOf('.')).trim();
    print("----mPrice----${mPrice}--");
    ApiController.stripePaymentApi(mPrice).then((response){
      Utils.hideProgressDialog(context);
      print("----stripePaymentApi------");
      if(response != null){
        StripeCheckOutModel stripeCheckOutModel =response;
        if(stripeCheckOutModel.success){
          //launchWebView(stripeCheckOutModel);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StripeWebView(stripeCheckOutModel,storeModel)),
          );

        }else{
          Utils.showToast("Something went wrong!", true);
        }

      }else{
        Utils.showToast("Something went wrong!", true);
      }
    });


  }


  String razorpay_orderId = "";
  void openCheckout(String razorpay_order_id,StoreModel storeObject) async {
    Utils.hideProgressDialog(context);
    UserModel user = await SharedPrefs.getUser();
    //double price = totalPrice ;
    razorpay_orderId = razorpay_order_id;
    var options = {
      'key': '${storeObject.paymentSetting.apiKey}',
      'currency': "INR",
      'order_id': razorpay_order_id,
      //'amount': taxModel == null ? (price * 100) : (double.parse(taxModel.total) * 100),
      'amount': (double.parse(taxModel.total) * 100),
      'name': '${user.fullName}',
      'description': '${noteController.text}',
      'prefill': {'contact': '${user.phone}', 'email': '${user.email}'},
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
    ApiController.razorpayVerifyTransactionApi(responseObj.orderId).then((response){
      //print("----razorpayVerifyTransactionApi----${response}--");
      if(response != null){

        RazorpayOrderData model = response;
        if(model.success){
          placeOrderApiCall(responseObj.orderId,model.data.id,"Razorpay");
        }else{
          Utils.showToast("Something went wrong!", true);
          Utils.hideProgressDialog(context);
        }
      }else{
        Utils.showToast("Something went wrong!", true);
        Utils.hideProgressDialog(context);
      }
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg:response.message,timeInSecForIosWeb: 4);
    print("----_handlePaymentError--message--${response.message}--");
    print("----_handlePaymentError--code--${response.code.toString()}--");

  }

  void _handleExternalWallet(ExternalWalletResponse response) {

    /*print("----ExternalWalletResponse----${response.walletName}--");

    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIos: 4);*/
  }

  void callOrderIdApi(StoreModel storeObject) {
    Utils.showProgressDialog(context);
    double price = double.parse(taxModel.total); //totalPrice ;
    print("=======1===${price}===total==${taxModel.total}======");
    price = price * 100;
    print("=======2===${price}===========");
    String mPrice = price.toString().substring(0 , price.toString().indexOf('.'));
    print("=======mPrice===${mPrice}===========");
    ApiController.razorpayCreateOrderApi(mPrice).then((response){

      CreateOrderData model = response;
      if(model != null && response.success){
        print("----razorpayCreateOrderApi----${response.data.id}--");
        openCheckout(model.data.id,storeObject);

      }else{
        Utils.showToast("${model.message}", true);
        Utils.hideProgressDialog(context);
      }
    });
  }



  void placeOrderApiCall(String payment_request_id, String payment_id, String onlineMethod) {
    Utils.isNetworkAvailable().then((isNetworkAvailable) async {
      if (isNetworkAvailable == true) {
        databaseHelper.getCartItemsListToJson().then((json) {
          if(json == null){
            print("--json == null-json == null-");
            return;
          }

          String couponCode = taxModel == null ? "" :taxModel.couponCode;
          String discount = taxModel == null ? "0" :taxModel.discount;
          Utils.showProgressDialog(context);
          ApiController.multipleTaxCalculationRequest("${couponCode}",  "${discount}",
              shippingCharges, json).then((response) {
            //Utils.hideProgressDialog(context);
            if (response != null && !response.success) {
              Utils.showToast(response.message, true);
              databaseHelper.deleteTable(DatabaseHelper.Favorite_Table);
              databaseHelper.deleteTable(DatabaseHelper.CART_Table);
              databaseHelper.deleteTable(DatabaseHelper.Products_Table);
              Navigator.of(context).popUntil((route) => route.isFirst);
              return;
            }

            taxModel = response.taxCalculation;

            Map<String,dynamic> attributeMap = new Map<String,dynamic>();
            attributeMap["ScreenName"] = "Order Confirm Screen";
            attributeMap["action"] = "Place Order Request";
            attributeMap["totalPrice"] = "${totalPrice}";
            attributeMap["deliveryType"] = "${widget.deliveryType}";
            attributeMap["paymentMode"] = "${widget.paymentMode}";
            attributeMap["shippingCharges"] = "${shippingCharges}";
            Utils.sendAnalyticsEvent("Clicked Place Order button",attributeMap);

            ApiController.placeOrderRequest(shippingCharges,noteController.text, totalPrice.toString(),
                widget.paymentMode, taxModel, widget.address, json ,
                widget.isComingFromPickUpScreen,widget.areaId ,widget.deliveryType,
                payment_request_id,payment_id,onlineMethod,selectedDeliverSlotValue).then((response) async {
              Utils.hideProgressDialog(context);
              if(response == null){
                print("--response == null-response == null-");
                return;
              }
              eventBus.fire(updateCartCount());
              print("${widget.deliveryType}");
              //print("Location = ${storeModel.lat},${storeModel.lng}");
              if(widget.deliveryType == OrderType.PickUp){
                bool result = await DialogUtils.displayPickUpDialog(context,storeModel);
                if(result == true){
                  //print("==result== ${result}");
                  await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  eventBus.fire(updateCartCount());
                  DialogUtils.openMap(storeModel,double.parse(storeModel.lat), double.parse(storeModel.lng));
                }else{
                  //print("==result== ${result}");
                  await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }else{
                bool result = await DialogUtils.displayThankYouDialog(context,response.success? AppConstant.orderAdded: response.message);
                if(result == true){
                  await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                  eventBus.fire(updateCartCount());
                }
              }
            });


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
  }

  void callStripeVerificationApi(String payment_request_id) {
    Utils.showProgressDialog(context);
    ApiController.stripeVerifyTransactionApi(payment_request_id).then((response){
      Utils.hideProgressDialog(context);
      if(response != null){
        StripeVerifyModel object = response;
        if(object.success){

          placeOrderApiCall(payment_request_id, object.paymentId,"Stripe");

        }else{
          Utils.showToast("Transaction is not completed, please try again!", true);
          Utils.hideProgressDialog(context);
        }

      }else{
        Utils.showToast("Something went wrong!", true);
        Utils.hideProgressDialog(context);
      }
    });
  }

  bool isloyalityPointsEnabled;
  void checkLoyalityPointsOption() {
    //1 - enable, 0 means disable
    try {
      print("====-loyality===== ${storeModel.loyality}--");
      if(storeModel.loyality != null && storeModel.loyality == "1"){
            isloyalityPointsEnabled = true;
          }else{
            isloyalityPointsEnabled = false;
          }
    } catch (e) {
      print(e);
    }
  }

}

class StripeWebView extends StatefulWidget {

  StripeCheckOutModel stripeCheckOutModel;
  StoreModel storeModel;
  StripeWebView(this.stripeCheckOutModel, this.storeModel);

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
      onWillPop: (){
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
              if(url.contains("api/stripeVerifyTransaction?response=success")){
                eventBus.fire(onPageFinished(widget.stripeCheckOutModel.paymentRequestId));
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