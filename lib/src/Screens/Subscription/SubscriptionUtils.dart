import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restroapp/src/Screens/BookOrder/ConfirmOrderScreen.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/MembershipPlanResponse.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
import 'package:restroapp/src/models/UserPurchaseMembershipResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

/*Dialogs-------------------------------------------------------------------------------------------*/
Future<bool> showSubscriptionSuccessDialog(
    BuildContext _context, Function onPressed) async {
  return showDialog<bool>(
    context: _context,
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
                      onPressed: onPressed,
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

Future<void> showSubscriptionFailedDialog(BuildContext _context) async {
  return showDialog<void>(
    context: _context,
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
                    child: Text(
                      'Ok',
                      style: TextStyle(color: appTheme),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(appThemeSecondary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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

Future<bool> showCancelSubscriptionDialog(
    BuildContext _context, Function _onPressed) async {
  return showDialog<bool>(
    context: _context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(mainAxisSize: MainAxisSize.min, children: [
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
          SizedBox(
            height: 20,
          ),
          Text(
            'Sorry you won\'t get any refund on cancellation of this plan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(thickness: 2, indent: 50, endIndent: 50, height: 40),
          Text(
            'Are you sure, you want to cancel your meal delivery plan?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          MaterialButton(
            color: appThemeSecondary,
            child: Text(
              'Proceed to Cancel',
              style: TextStyle(color: appTheme),
            ),
            onPressed: _onPressed,
          )
        ]),
      );
    },
  );
}

Future<bool> showOfferAvailDialog(
    BuildContext _context, Function _onPressed) async {
  return showDialog<bool>(
    context: _context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      bool isEnable = true;
      Timer t = Timer(Duration(seconds: 3), () {
        isEnable = false;
        _onPressed(context);
      });
      // and later, before the timer goes off...

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: WillPopScope(
          onWillPop: () {
            return Future(() => false);
          },
          child: InkWell(
            onTap: () {
              if (isEnable) {
                isEnable = false;
                t.cancel();
                _onPressed(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('images/congratsgiftimage.png'),
                ),
                Text('Congrats,'),
                Text('we will got,'),
                SizedBox(
                  height: 15,
                ),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(0.0, -4.0),
                        child: Text(
                          '${AppConstant.currency}',
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TextSpan(
                        text: '${getSubscriptionCouponDiscountPlan()}',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  ]),
                ),
                SizedBox(
                  height: 15,
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'discount ',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    TextSpan(
                        text: 'on this offer',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                  ]),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

getSubscriptionCouponDiscountPlan() {
  UserPurchaseMembershipResponse response =
      SingletonBrandData.getInstance().userPurchaseMembershipResponse;
  return response.data.couponDetails.discount.isNotEmpty
      ? response.data.couponDetails.discount
      : response.data.couponDetails.discountUpto.isNotEmpty
          ? response.data.couponDetails.discountUpto
          : '0';
}

String getSubscriptionCouponCodePlan() {
  UserPurchaseMembershipResponse response =
      SingletonBrandData.getInstance().userPurchaseMembershipResponse;
  return response.data.couponDetails.couponCode;
}

Future<bool> showCanceledSubscriptionDialog(
    BuildContext _context, Function _onPressed) async {
  return showDialog<bool>(
    context: _context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: AlertDialog(
          title: Column(children: [
            Text('Your plan'),
            Text('has been canceled.'),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: appThemeSecondary,
              child: Text(
                'Ok',
                style: TextStyle(color: appTheme),
              ),
              onPressed: _onPressed,
            )
          ]),
        ),
      );
    },
  );
}

/*Utils-------------------------------------------------------------------------------------------*/

bool checkIsPlanPurchased() {
  UserPurchaseMembershipResponse response =
      SingletonBrandData.getInstance().userPurchaseMembershipResponse;
  return response != null && response.data.status;
}

bool checkIsRewPlanPurchased() {
  UserPurchaseMembershipResponse response =
      SingletonBrandData.getInstance().userPurchaseMembershipResponse;
  return response != null && response.data != null && !response.data.status;
}

bool checkForTodaysSubscriptionOrder() {
  bool isMemberShipOn =
      SingletonBrandData.getInstance().brandVersionModel.brand.isMembershipOn ==
          '1';
  UserPurchaseMembershipResponse response =
      SingletonBrandData.getInstance().userPurchaseMembershipResponse;
  return isMemberShipOn &&
      response != null &&
      response.data != null &&
      response.data.status &&
      !response.data.todayOrdered &&
      checkCurrentDateWithInThePlan();
}

String getSubscriptionPlanName() {
  MembershipPlanResponse response =
      SingletonBrandData.getInstance().membershipPlanResponse;
  if (response != null && response.data != null) {
    return response.data.planName;
  } else {
    return '';
  }
}

String convertSubscriptionDate(DateTime dateTime) {
  DateFormat formatter = new DateFormat('dd MMM yyyy');
  String formatted = formatter.format(dateTime);
  return formatted;
}

String getSubscriptionNextMealDate() {
  DateTime today = DateTime.now();
  today.add(Duration(days: 1));
  DateFormat formatter = new DateFormat('dd MMM yyyy');
  String formatted = formatter.format(today);
  return formatted;
}

bool checkCurrentDateWithInThePlan() {
  DateTime now = DateTime.now();
  bool isSameDate(DateTime currentDate, DateTime other) {
    return currentDate.year == other.year &&
        currentDate.month == currentDate.month &&
        currentDate.day == other.day;
  }

  UserPurchaseMembershipResponse response =
      SingletonBrandData.getInstance().userPurchaseMembershipResponse;
  //TODO: recheck About this
  bool isOnEndDay = isSameDate(now, response.data.endDate);
  return !now.isBefore(response.data.startDate) &&
      (isOnEndDay || !now.isAfter(response.data.endDate));
}

/*Button Clicks------------------------------------------------------------------*/
handleSubscriptionFoodOrderClick(BuildContext _context) {
  Utils.showProgressDialog(_context);
  ApiController.getAddressApiRequest().then((responses) async {
    Utils.hideProgressDialog(_context);

    if (responses != null && responses.success) {
      String defaultAddressID = SingletonBrandData.getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.defaultAddressId ??
          '';
      DeliveryAddressData address = null;
      //find address
      for (int i = 0; i < responses.data.length; i++) {
        if (defaultAddressID == responses.data[i].id)
          address = responses.data[i];
      }

      if (address != null) {
        _navigateToCheckoutOrder(address, _context);
      }
    }
  });
}

void _navigateToCheckoutOrder(
    DeliveryAddressData address, BuildContext context) async {
  StoreDataObj store = await SharedPrefs.getStoreData();
  double distanceInKm = Utils.calculateDistance(
      double.parse(address.lat),
      double.parse(address.lng),
      double.parse(store.lat),
      double.parse(store.lng));

  int distanceInKms = distanceInKm.toInt();

  StoreRadiousResponse storeRadiousResponse =
      await ApiController.storeRadiusApi();

  Area area;
  //print("---${areaList.length}---and-- ${distanceInKms}---");
  for (int i = 0; i < storeRadiousResponse.data.length; i++) {
    Area areaObject = storeRadiousResponse.data[i];
    int radius = int.parse(areaObject.radius);
    if (distanceInKms < radius && areaObject.radiusCircle == "Within") {
      area = areaObject;
      break;
    } else {}
  }
  if (area == null) {
    Navigator.pop(context);
    bool dialogResult = await DialogUtils.displayLocationNotAvailbleDialog(
        context, 'We dont\'t serve\nin your area',
        buttonText1: 'Ok');
    if (dialogResult != null && dialogResult) {}
  } else {
    StoreDataObj storeModel = await SharedPrefs.getStoreData();
    {
      if (area.note.isEmpty) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmOrderScreen(
                    address,
                    false,
                    "",
                    OrderType.SUBSCRIPTION_ORDER,
                    areaObject: area,
                    storeModel: storeModel,
                  )),
        );
      } else {
        var result = await DialogUtils.displayOrderConfirmationDialog(
          context,
          "Confirmation",
          area.note,
        );
        if (result == true) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConfirmOrderScreen(
                    address, false, "", OrderType.SUBSCRIPTION_ORDER,
                    areaObject: area, storeModel: storeModel)),
          );
        }
      }
    }
  }
}
