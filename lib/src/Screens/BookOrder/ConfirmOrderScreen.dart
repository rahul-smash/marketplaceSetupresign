import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_view/flutter_web_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:restroapp/src/Screens/Offers/AvailableOffersList.dart';
import 'package:restroapp/src/apihandler/ApiConstants.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/CreateOrderData.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/DeliveryTimeSlotModel.dart';
import 'package:restroapp/src/models/RazorpayOrderData.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
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

class ConfirmOrderScreen extends StatefulWidget {

  bool isComingFromPickUpScreen;
  DeliveryAddressData address;
  String paymentMode = "2"; // 2 = COD, 3 = Online Payment
  String areaId;
  OrderType deliveryType;

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
  FlutterWebView flutterWebView = new FlutterWebView();
  StoreModel storeModel;
  DeliveryTimeSlotModel deliverySlotModel;
  int selctedTag, selectedTimeSlot;
  List<Timeslot> timeslotList;
  bool isSlotSelected = false;
  bool minOrderCheck =true;

  @override
  void initState() {
    super.initState();
    initRazorPay();
    selctedTag = 0;
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
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
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
          if(mtotalPrice < minAmount){
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
          if(mtotalPrice < minAmount){
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
          )),
      body: Column(children: [
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
        Expanded(child: FutureBuilder(
          future: databaseHelper.getCartItemList(),
          builder: (context, projectSnap) {
            if (projectSnap.connectionState == ConnectionState.none &&
                projectSnap.hasData == null) {
              return Container();
            } else {
              if (projectSnap.hasData) {

                return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(color: Colors.grey, height: 1),
                  shrinkWrap: true,
                  itemCount: projectSnap.data.length + 1,
                  itemBuilder: (context, index) {
                    return index == projectSnap.data.length
                        ? addItemPrice(): addProductCart(projectSnap.data[index]);
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.black26,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black26)),
                );
              }
            }
          },
        ))
      ]),
      bottomNavigationBar: Container(
        height: 135,
        color: Colors.white,
        child: Column(
          children: [addTotalPrice(), addCouponCodeRow(), addConfirmOrder()],
        ),
      ),
    );
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
                    child: Text(product.title,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text("Quantity: " + product.quantity)),
                Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 20),
                    child: Text("Price: " + "${AppConstant.currency}${product.price}")),
              ],
            ),
            Text(
                "${AppConstant.currency}${databaseHelper.roundOffPrice(int.parse(product.quantity) * double.parse(product.price), 2)}",
                style: TextStyle(fontSize: 16, color: Colors.black45)),
          ],
        ));
  }


  Widget addItemPrice() {

    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 1,
            color: Colors.black45,
            width: MediaQuery.of(context).size.width),
        Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Items Price", style: TextStyle(color: Colors.black54)),
                Text("${AppConstant.currency}${databaseHelper.roundOffPrice((totalPrice-int.parse(shippingCharges)), 2)}",
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
        ),
        Visibility(
          visible: widget.address == null? false : true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Shipping Charges:", style: TextStyle(color: Colors.black54)),
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

      ]),
    );
  }


  Widget addTotalPrice() {
    return Container(
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
                    taxModel == null ? totalPrice : double.parse(taxModel.total), 2)}",
                    style:TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ))
      ]),
    );
  }

  List<String> appliedCouponCodeList = List();
  Widget addCouponCodeRow() {
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Row(
          children: <Widget>[
            new Flexible(
                child: Container(width: 140.0,height: 40.0,
                    decoration: new BoxDecoration(color: Colors.white,
                      border: new Border.all(color: Colors.grey, width: 1.0, ),
                    ),
                    child: Center(child: Text(
                        taxModel == null ? 'Coupon Code:' : taxModel.couponCode ?? "")))
                ),
            Container( width: 130.0,height: 40.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: RaisedButton(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  textColor: Colors.white,color: Colors.green,
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
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AvailableOffersDialog(
                      widget.address, "" ,widget.isComingFromPickUpScreen,widget.areaId,(model) {
                        setState(() {
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
              child: Container(height: 40,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  border: new Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Text("Available\nOffers",textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black,)),
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

          StoreModel storeObject = await SharedPrefs.getStore();
          bool status = checkStoreOpenTime(storeObject);
          print("----checkStoreOpenTime----${status}--");

          if(!status){
            Utils.showToast("Store is closed.", false);
            return;
          }
          if(widget.deliveryType == OrderType.Delivery && widget.address.notAllow){
            if(!minOrderCheck){
              Utils.showToast("Your order amount is to low. Minimum order amount is ${widget.address.minAmount}", false);
              return;
            }
          }
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Confirm Order",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ],
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
      ApiController.multipleTaxCalculationRequest("", "0", "0", json).then((response) {
        Utils.hideProgressDialog(context);
        setState(() {
          taxModel = null;
          appliedCouponCodeList.clear();
        });
      });
    });
  }


  void callStripeApi() {
    Utils.showProgressDialog(context);
    double price = totalPrice;
    String mPrice = price.toString().substring(0 , price.toString().indexOf('.')).trim();
    print("----mPrice----${mPrice}--");
    ApiController.stripePaymentApi(mPrice).then((response){
      Utils.hideProgressDialog(context);
      print("----stripePaymentApi------");
      if(response != null){
        StripeCheckOutModel stripeCheckOutModel =response;
        if(stripeCheckOutModel.success){

          launchWebView(stripeCheckOutModel);

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
    double price = totalPrice ;
    razorpay_orderId = razorpay_order_id;
    var options = {
      'key': '${storeObject.paymentSetting.apiKey}',
      'currency': "INR",
      'order_id': razorpay_order_id,
      'amount': taxModel == null ? (price * 100) : (double.parse(taxModel.total) * 100),
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
    Fluttertoast.showToast(msg:response.message,timeInSecForIos: 4);
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
    double price = totalPrice ;
    print("=======1===${price}===========");
    price = price * 100;
    print("=======2===${price}===========");
    String mPrice = price.toString().substring(0 , price.toString().indexOf('.'));
    print("=======mPrice===${mPrice}===========");
    ApiController.razorpayCreateOrderApi(mPrice).then((response){
      print("----razorpayCreateOrderApi----${response.data.id}--");

      CreateOrderData model = response;
      if(model != null && response.success){

        openCheckout(model.data.id,storeObject);

      }else{
        Utils.showToast("Something went wrong!", true);
        Utils.hideProgressDialog(context);
      }
    });
  }



  void placeOrderApiCall(String payment_request_id, String payment_id, String onlineMethod) {
    Utils.isNetworkAvailable().then((isNetworkAvailable) async {
      if (isNetworkAvailable == true) {
        Utils.showProgressDialog(context);
        databaseHelper.getCartItemsListToJson().then((json) {
          if(json == null){
            print("--json == null-json == null-");
            return;
          }

          ApiController.placeOrderRequest(shippingCharges,noteController.text, totalPrice.toString(),
              widget.paymentMode, taxModel, widget.address, json ,
              widget.isComingFromPickUpScreen,widget.areaId ,
              payment_request_id,payment_id,onlineMethod,selectedDeliverSlotValue).then((response) async {
            Utils.hideProgressDialog(context);
            if(response == null){
              print("--response == null-response == null-");
              return;
            }

            print("${widget.deliveryType}");
            //print("Location = ${storeModel.lat},${storeModel.lng}");
            if(widget.deliveryType == OrderType.PickUp){
              bool result = await DialogUtils.displayPickUpDialog(context,storeModel);
              if(result == true){
                //print("==result== ${result}");
                await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                Navigator.of(context).popUntil((route) => route.isFirst);
                eventBus.fire(updateCartCount());
                DialogUtils.openMap(double.parse(storeModel.lat), double.parse(storeModel.lng));
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

  void launchWebView(StripeCheckOutModel stripeCheckOutModel) {
    print("----checkoutUrl----${stripeCheckOutModel.checkoutUrl}");
    flutterWebView.launch("${stripeCheckOutModel.checkoutUrl}",
        javaScriptEnabled: true,
        toolbarActions: [ToolbarAction("Dismiss", 1)],
        barColor: appTheme,
        tintColor: Colors.white
         );
    flutterWebView.onToolbarAction.listen((identifier) {
      switch (identifier) {
        case 1:
          flutterWebView.dismiss();
          break;
      }
    });
    flutterWebView.listenForRedirect("mobile://test.com", true);

    flutterWebView.onWebViewDidStartLoading.listen((url) {
      print("---listen----${url}");
      String mUrl = url;
      if(mUrl.contains("api/stripeVerifyTransaction?response=success")){
        flutterWebView.dismiss();
        callStripeVerificationApi(stripeCheckOutModel.paymentRequestId);
      }
    });
    flutterWebView.onWebViewDidLoad.listen((url) {
      print("---onWebViewDidLoad----${url}");
    });
    flutterWebView.onRedirect.listen((url) {
      print("---onRedirect----${url}");
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
          Utils.showToast("Something went wrong!", true);
          Utils.hideProgressDialog(context);
        }

      }else{
        Utils.showToast("Something went wrong!", true);
        Utils.hideProgressDialog(context);
      }
    });
  }

  bool checkStoreOpenTime(StoreModel storeObject) {
    // in case of deliver ignore is24x7Open
    bool status = false;
    if(storeObject.is24x7Open == "1" && widget.deliveryType == OrderType.PickUp){
      // 1 = means store open 24x7
      // 0 = not open for 24x7
      status = true;
    }else if (storeObject.openhoursFrom.isEmpty || storeObject.openhoursFrom.isEmpty) {
      status = true;
    } else {
      bool isStoreOpenToday = Utils.checkStoreOpenDays(storeObject);
      if(isStoreOpenToday){
        bool isStoreOpen = Utils.getDayOfWeek(storeObject);
        status = isStoreOpen;
      }else{
        status = false;
      }
    }
    return status;
  }




}
