import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/Address/DeliveryAddressList.dart';
import 'package:restroapp/src/Screens/Address/StoreLocationScreen.dart';
import 'package:restroapp/src/Screens/Address/StoreLocationScreenWithMultiplePick.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionUtils.dart';
import 'package:restroapp/src/UI/CustomGridView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/PickUpModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class OrderSelectionScreen extends StatefulWidget {
  String pickupfacility, delieveryAdress, dineInFacility;

  OrderSelectionScreen(this.pickupfacility, this.delieveryAdress,
      {this.dineInFacility = '0'});

  @override
  _OrderSelectionScreen createState() => _OrderSelectionScreen();
}

class _OrderSelectionScreen extends State<OrderSelectionScreen> {
  DatabaseHelper databaseHelper = new DatabaseHelper();

  //StoreModel store;
  bool pickUpFacility = false, delieveryAddress = false, dineInFacility = false;

  bool subscriptionOrderAvailable = false;

  bool isShowViewInGrid = false;

  @override
  void initState() {
    super.initState();
    if (widget.pickupfacility == "1") {
      pickUpFacility = true;
    }
    if (widget.delieveryAdress == "1") {
      delieveryAddress = true;
    }
    if (widget.dineInFacility == "1") {
      dineInFacility = true;
    }
    subscriptionOrderAvailable = checkForTodaysSubscriptionOrder();
    //If all options are disable then show delivery option
    if (widget.pickupfacility == "0" &&
        widget.delieveryAdress == "0" &&
        widget.dineInFacility == "0") {
      delieveryAddress = true;
    }
    //if more then 3 option visible then show in grid
//    if (pickUpFacility && delieveryAddress && dineInFacility &&
//        subscriptionOrderAvailable) {
//      isShowViewInGrid = true;
//    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                child: Image(
                    image: AssetImage('images/cancelicon.png'),
                    height: 15,
                    width: 15),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Text("Select Your Option"),
          ],
        ),
        content: Container(
            width: double.maxFinite,
            child: isShowViewInGrid
                ? CustomGridView(
                    _getChildren(isGrid: isShowViewInGrid),
                    columns: 2,
                  )
                : ListView(
                    shrinkWrap: true,
                    children: _getChildren(isGrid: isShowViewInGrid),
                  )));
  }

  _getChildren({bool isGrid}) {
    return <Widget>[
      subscriptionOrderAvailable
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    StoreDataObj storeObject = await SharedPrefs.getStoreData();
                    bool status = Utils.checkStoreOpenTime(storeObject,
                        deliveryType: OrderType.Delivery);
                    if (!status) {
                      Navigator.pop(context);
                      DialogUtils.displayCommonDialog(
                        context,
                        storeObject.storeName,
                        storeObject.closehoursMessage,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    showOfferAvailDialog(context, (_buildContext) {
                      handleSubscriptionFoodOrderClick(_buildContext);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10.0, 00.0, 10.0, 10.0),
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                          margin:
                              const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                          height: 100.0,
                          width: 150.0,
                          decoration: new BoxDecoration(
                            image: DecorationImage(
                              image: new AssetImage(
                                'images/nextdaydelivery.png',
                              ),
                              fit: BoxFit.scaleDown,
                            ),
                            shape: BoxShape.rectangle,
                          ),
                        ),
                        Text('${getSubscriptionPlanName()} -',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('next day delivery',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                Divider(height: 30, thickness: 2, indent: 40, endIndent: 40),
              ],
            )
          : Container(),
      Visibility(
        visible: delieveryAddress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                print('@@CartBottomView----' + "DeliveryScreen");

                StoreDataObj storeObject = await SharedPrefs.getStoreData();
                bool status = Utils.checkStoreOpenTime(storeObject,
                    deliveryType: OrderType.Delivery);
                if (!status) {
//                              Utils.showToast("${storeObject.closehoursMessage}", false);
                  Navigator.pop(context);
                  DialogUtils.displayCommonDialog(
                    context,
                    storeObject.storeName,
                    storeObject.closehoursMessage,
                  );
                  return;
                }
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DeliveryAddressList(true, OrderType.Delivery)),
                );
              },
              child: new Container(
                margin: EdgeInsets.fromLTRB(10.0, 00.0, 10.0, 10.0),
                padding: EdgeInsets.all(10.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                      height: 100.0,
                      width: 150.0,
                      decoration: new BoxDecoration(
                        image: DecorationImage(
                          image: new AssetImage(
                            'images/delivernow.png',
                          ),
                          fit: BoxFit.scaleDown,
                        ),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    Text(
                      "Deliver",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // Code to create the view for address.
                  ],
                ),
              ),
            ),
            Divider(height: 30, thickness: 2, indent: 40, endIndent: 40),
          ],
        ),
      ),
      Visibility(
        visible: pickUpFacility,
        child: GestureDetector(
          onTap: () async {
            print('@@CartBottomView----' + "PickUPActivy");

            StoreDataObj storeObject = await SharedPrefs.getStoreData();
            bool status = Utils.checkStoreOpenTime(storeObject,
                deliveryType: OrderType.PickUp);
            if (!status) {
//                              Utils.showToast("${storeObject.closehoursMessage}", false);
              Navigator.pop(context);
              DialogUtils.displayCommonDialog(
                context,
                storeObject.storeName,
                storeObject.closehoursMessage,
              );
              return;
            }

            Utils.showProgressDialog(context);
            ApiController.getStorePickupAddress().then((response) {
              Utils.hideProgressDialog(context);
              PickUpModel storeArea = response;

              print('---PickUpModel---${storeArea.data.length}--');
              if (storeArea != null && storeArea.data.isNotEmpty) {
                if (storeArea.data.length == 1) {
                  Datum areaObject = storeArea.data[0];
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            StoreLocationScreen(areaObject, OrderType.PickUp)),
                  );
                } else {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
//                                        builder: (context) => PickUpOrderScreen(storeArea,OrderType.PickUp)),
                        builder: (context) =>
                            StoreLocationScreenWithMultiplePick(
                                storeArea, OrderType.PickUp)),
                  );
                }
              } else {
                Utils.showToast("No pickup data found!", true);
              }
            });
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                // First child in the Row for the name and the
                Expanded(
                  // Name and Address are in the same column
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Code to create the view for name.
                      Container(
                        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                        height: 100.0,
                        width: 150.0,
                        decoration: new BoxDecoration(
                          image: DecorationImage(
                            image: new AssetImage(
                              'images/pickup.png',
                            ),
                            fit: BoxFit.scaleDown,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      // Code to create the view for address.
                      Text(
                        "Pickup",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Icon to indicate the phone number.
              ],
            ),
          ),
        ),
      ),
      Visibility(
        visible: dineInFacility,
        child: GestureDetector(
          onTap: () async {
            print('@@CartBottomView----' + "PickUPActivy");

            StoreDataObj storeObject = await SharedPrefs.getStoreData();
            //In DineIN uses the same approach of PickUp
            bool status = Utils.checkStoreOpenTime(storeObject,
                deliveryType: OrderType.PickUp);
            if (!status) {
//                              Utils.showToast("${storeObject.closehoursMessage}", false);
              Navigator.pop(context);
              DialogUtils.displayCommonDialog(
                context,
                storeObject.storeName,
                storeObject.closehoursMessage,
              );
              return;
            }
            Utils.showProgressDialog(context);
            ApiController.getStorePickupAddress().then((response) {
              Utils.hideProgressDialog(context);
              PickUpModel storeArea = response;

              print('---PickUpModel---${storeArea.data.length}--');
              if (storeArea != null && storeArea.data.isNotEmpty) {
                if (storeArea.data.length == 1) {
                  Datum areaObject = storeArea.data[0];
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            StoreLocationScreen(areaObject, OrderType.DineIn)),
                  );
                } else {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
//                                        builder: (context) => PickUpOrderScreen(storeArea,OrderType.PickUp)),
                        builder: (context) =>
                            StoreLocationScreenWithMultiplePick(
                                storeArea, OrderType.DineIn)),
                  );
                }
              } else {
                Utils.showToast("No DineIn data found!", true);
              }
            });
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                // First child in the Row for the name and the
                Expanded(
                  // Name and Address are in the same column
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Code to create the view for name.
                      Divider(
                          height: 30, thickness: 2, indent: 40, endIndent: 40),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                        height: 100.0,
                        width: 150.0,
                        decoration: new BoxDecoration(
                          image: DecorationImage(
                            image: new AssetImage(
                              'images/dine_in.png',
                            ),
                            fit: BoxFit.scaleDown,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      // Code to create the view for address.
                      Text(
                        "DineIn",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Icon to indicate the phone number.
              ],
            ),
          ),
        ),
      ),
    ];
  }
}
