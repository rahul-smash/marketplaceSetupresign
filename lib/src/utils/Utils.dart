import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginMobileScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginEmailScreen.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/DeviceInfo.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TaxCalulationResponse.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart';


import 'DialogUtils.dart';

class Utils {
  static ProgressDialog pr;

  static void showToast(String msg, bool shortLength) {
    try {
      if (shortLength) {
        Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: toastbgColor.withOpacity(0.9),
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: toastbgColor.withOpacity(0.9),
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print(e);
    }
  }

  static Widget getEmptyView1(String value) {
    return Container(
      child: Center(
        child: Text(value,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
            )),
      ),
    );
  }

  static Future<PackageInfo> getAppVersionDetails() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    SharedPrefs.storeSharedValue(AppConstant.appName, packageInfo.appName);
    SharedPrefs.storeSharedValue(
        AppConstant.old_appverion, packageInfo.version);

    return packageInfo;
  }

  static Widget showIndicator() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
            backgroundColor: Colors.black26,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
      ),
    );
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    /*if (!regex.hasMatch(value))
      return true;
    else
      return false;*/
    return regex.hasMatch(value);
  }

  static Future<void> showLoginDialog(BuildContext context) async {
    try {
      //User Login with Mobile and OTP
      // 1 = email and 0 = ph-no
      //StoreDataObj model = await SharedPrefs.getStoreData();
      BrandData model =
          SingletonBrandData.getInstance().brandVersionModel.brand;
      if (model.internationalOtp == "0") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginMobileScreen("menu")),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "LoginMobileScreen";
        Utils.sendAnalyticsEvent("Clicked LoginMobileScreen", attributeMap);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginEmailScreen("menu")),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "LoginEmailScreen";
        Utils.sendAnalyticsEvent("Clicked LoginEmailScreen", attributeMap);
      }
    } catch (e) {
      print(e);
    }
  }

  static void showLoginDialog2(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login"),
          content: Text(AppConstant.pleaseLogin),
          actions: [
            FlatButton(
              child: new Text("YES"),
              onPressed: () {
                Navigator.of(context).pop();
                SharedPrefs.getStore().then((storeData) {
                  StoreModel model = storeData;
                  //print("---internationalOtp--${model.internationalOtp}");
                  //User Login with Mobile and OTP
                  // 1 = email and 0 = ph-no
                  if (model.internationalOtp == "0") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginMobileScreen("menu")),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginEmailScreen("menu")),
                    );
                  }
                });
              },
            ),
            FlatButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> isNetworkAvailable() async {
    bool isNetworkAvailable = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      isNetworkAvailable = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      isNetworkAvailable = true;
    }
    return isNetworkAvailable;
  }

  static void showProgressDialog(BuildContext context) {
    //For normal dialog
    if (pr != null && pr.isShowing()) {
      pr.hide();
    }
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.show();
  }

  static void hideProgressDialog(BuildContext context) {
    //For normal dialog
    try {
      if (pr != null && pr.isShowing()) {
        pr.hide();
        pr = null;
      } else {
        if (pr != null) {
          pr.hide();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static double roundOffPrice(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static showFavIcon(String isFav) {
    Icon favIcon;
    //print("-showFavIcon- ${isFav}");
    if (isFav == null) {
      favIcon = Icon(Icons.favorite_border);
      return favIcon;
    }
    if (isFav == "1") {
      favIcon = Icon(
        Icons.favorite,
        color: darkRed,
      );
    } else if (isFav == "0") {
      favIcon = Icon(Icons.favorite_border);
    }
    return favIcon;
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    try {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static Widget showDivider(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 1,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: Color(0xFFDBDCDD),
    );
  }

  static Widget getEmptyView(String value) {
    return Container(
      child: Expanded(
        child: Center(
          child: Text(value,
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
              )),
        ),
      ),
    );
  }

  static Widget getImgPlaceHolder() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: CachedNetworkImage(
          imageUrl: "${AppConstant.placeholderUrl}", fit: BoxFit.cover),
    );
  }

  static Widget showVariantDropDown(ClassType classType, Product product) {
    //print("variants = ${product.variants} and ${classType}");

    if (classType == ClassType.CART) {
      return Icon(Icons.keyboard_arrow_down,
          color: appThemeSecondary, size: 25);
    } else {
      bool isVariantNull = false;
      if (product.variants != null) {
        if (product.variants.length == 1) {
          isVariantNull = true;
        }
      }
      return Icon(Icons.keyboard_arrow_down,
          color: isVariantNull ? whiteColor : appThemeSecondary, size: 25);
    }
  }

  static String getDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('MMM yyyy');
    String formatted = formatter.format(now);
    //print(formatted); // something like 2013-04-20
    return formatted;
  }

  static String getCurrentDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    //print(formatted); // something like 2013-04-20
    return formatted;
  }

  static String getCurrentDateTime() {
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy hh:mm');
    String formatted = formatter.format(now);
    //print(formatted); // something like 2013-04-20
    return formatted;
  }

  static convertStringToDate2(String dateObj) {
    DateFormat dateFormat = DateFormat("dd-MM-yyyy");
    DateTime dateTime = dateFormat.parse(dateObj);
    DateFormat formatter = new DateFormat('dd MMM yyyy');
    String formatted = formatter.format(dateTime);
    //print(formatted);
    return formatted;
  }

  static convertStringToDate(String dateObj) {
    DateFormat dateFormat = DateFormat("dd MMM yyyy");
    DateTime dateTime = dateFormat.parse(dateObj);
    DateFormat formatter = new DateFormat('dd MMM');
    String formatted = formatter.format(dateTime);
    //print(formatted);
    return formatted;
  }

  static convertDateFormat(String dateObj) {
    DateFormat dateFormat = DateFormat("dd MMM yyyy");
    DateTime dateTime = dateFormat.parse(dateObj);
    DateFormat formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(dateTime);
    //print(formatted);
    return formatted;
  }

  static convertOrderDateTime(String date) {
    String formatted = date;
    try {
      DateFormat format = new DateFormat("yyyy-MM-dd hh:mm:ss");
      //UTC time true
      DateTime time = format.parse(date, true);
      time = time.toLocal();
      //print("time.toLocal()=   ${time.toLocal()}");
      DateFormat formatter = new DateFormat('dd MMM yyyy, hh:mm a');
      formatted = formatter.format(time.toLocal());
    } catch (e) {
      print(e);
    }

    return formatted;
  }

  static convertOrderDate(String date) {
    String formatted = date;
    try {
      DateFormat format = new DateFormat("yyyy-MM-dd hh:mm:ss");
      //UTC time true
      DateTime time = format.parse(date, true);
      time = time.toLocal();
      //print("time.toLocal()=   ${time.toLocal()}");
      DateFormat formatter = new DateFormat('dd MMM, yyyy');
      formatted = formatter.format(time.toLocal());
    } catch (e) {
      print(e);
    }

    return formatted;
  }

  static convertNotificationDateTime(String date, {bool onlyTime = false}) {
    String formatted = date;
    try {
      DateFormat format = new DateFormat("dd MMM yyyy hh:mm a");
      //UTC time true
      DateTime time = format.parse(date, true);
      time = time.toLocal();
      //print("time.toLocal()=   ${time.toLocal()}");
      DateFormat formatter = new DateFormat('dd MMM yyyy');
      if (onlyTime) {
        formatter = new DateFormat('hh:mm a');
      }
      formatted = formatter.format(time.toLocal());
    } catch (e) {
      print(e);
    }

    return formatted;
  }

  static bool getDayOfWeek(String arrOpenhoursFrom, String arrOpenhoursTo) {
    bool isStoreOpen;
    DateFormat dateFormat = DateFormat("hh:mma");
    DateFormat apiDateFormat = new DateFormat("yyyy-MM-dd hh:mm a");

    var currentDate = DateTime.now();
//    print(currentDate
//        .toString()); // prints something like 2019-12-10 10:02:22.287949

    String currentTime = apiDateFormat.format(currentDate);
    //currentTime = currentTime.replaceAll("AM", "am").replaceAll("PM","pm");
    /*print("----------------------------------------------");
    print("openhoursFrom= ${store.openhoursFrom}");
    print("openhoursTo=   ${store.openhoursTo}");
    print("currentTime=   ${currentTime}");
    print("----------------------------------------------");*/

    String openhours_From =
        arrOpenhoursFrom.replaceAll("am", " AM").replaceAll("pm", " PM");
    String openhours_To =
        arrOpenhoursTo.replaceAll("am", " AM").replaceAll("pm", " PM");
    // print("--${getCurrentDate()}--openhoursFrom----${openhours_From} and ${openhours_To}");

    String openhoursFrom =
        "${getCurrentDate()} ${openhours_From}"; //"2020-06-02 09:30 AM";
    String openhoursTo =
        "${getCurrentDate()} ${openhours_To}"; //"2020-06-02 06:30 PM";
    String currentDateTime = currentTime; //"2020-06-02 08:30 AM";

    DateTime storeOpenTime = apiDateFormat.parse(openhoursFrom);
    DateTime storeCloseTime = apiDateFormat.parse(openhoursTo);
    DateTime currentTimeObj = apiDateFormat.parse(currentDateTime);

    //print("${dateFormat.format(storeOpenTime)} and ${dateFormat.format(storeCloseTime)}");
    //print("currentTimeObj = ${currentTimeObj.toString()}");
    //print("----------------------------------------------");
    //print("openhoursFrom=   ${openhoursFrom}");
    //print("openhoursTo=     ${openhoursTo}");
    //print("currentDateTime= ${currentDateTime}");
    //print("----------------------------------------------");
    if (currentTimeObj.isAfter(storeOpenTime) &&
        currentTimeObj.isBefore(storeCloseTime)) {
      // do something
      //print("---if----isAfter---and --isBefore---}");
      isStoreOpen = true;
    } else {
      //print("---else---else--else---else----else-------------}");
      isStoreOpen = false;
    }
    return isStoreOpen;
  }

  static bool checkStoreOpenDays(String storeOpenDays) {
    bool isStoreOpenToday;
    var date = DateTime.now();
    //print(DateFormat('EEE').format(date)); // prints Tuesday
    String dayName = DateFormat('EEE').format(date).toLowerCase();

    List<String> storeOpenDaysList = storeOpenDays.split(",");
    //print("${dayName} and ${storeOpenDaysList}");

    if (storeOpenDaysList.contains(dayName)) {
      //print("true contains");
      isStoreOpenToday = true;
    } else {
      //print("false contains");
      isStoreOpenToday = false;
    }
    return isStoreOpenToday;
  }

  static bool checkStoreOpenTime(StoreDataObj storeObject,
      {OrderType deliveryType = OrderType.Delivery}) {
    // in case of deliver ignore is24x7Open
    bool status = false;
    try {
      // user selct deliver  = is24x7Open ignore , if delivery slots is 1
      //if delivery slots = 0 , is24x7Open == 0, proced aage, then check time
      if (deliveryType == OrderType.Delivery) {
        if (storeObject.deliverySlot == "1") {
          status = true;
        } else if (storeObject.deliverySlot == "0" &&
            storeObject.is24X7Open == "0") {
          bool isStoreOpenToday =
              Utils.checkStoreOpenDays(storeObject.storeOpenDays);
          if (isStoreOpenToday) {
            bool isStoreOpen = Utils.getDayOfWeek(
                storeObject.openhoursFrom, storeObject.openhoursTo);
            status = isStoreOpen;
          } else {
            status = false;
          }
        } else if (storeObject.is24X7Open == "1") {
          status = true;
        }
      } else {
        if (deliveryType == OrderType.PickUp||deliveryType==OrderType.DineIn) {
          if (storeObject.is24X7Open == "1") {
            // 1 = means store open 24x7
            // 0 = not open for 24x7
            status = true;
          } else if (storeObject.openhoursFrom.isEmpty ||
              storeObject.openhoursFrom.isEmpty) {
            status = true;
          } else {
            bool isStoreOpenToday =
                Utils.checkStoreOpenDays(storeObject.storeOpenDays);
            if (isStoreOpenToday) {
              bool isStoreOpen = Utils.getDayOfWeek(
                  storeObject.openhoursFrom, storeObject.openhoursTo);
              status = isStoreOpen;
            } else {
              status = false;
            }
          }
        }
      }
      return status;
    } catch (e) {
      print(e);
      return true;
    }
  }

  static bool checkStoreOpenTiming(StoreData storeObject) {
    // in case of deliver ignore is24x7Open
    bool status = false;
    try {
      if (storeObject.timimg.is24X7Open == "1") {
        // 1 = means store open 24x7
        // 0 = not open for 24x7
        status = true;
      } else if (storeObject.timimg.openhoursFrom.isEmpty ||
          storeObject.timimg.openhoursFrom.isEmpty) {
        status = true;
      } else {
        bool isStoreOpenToday =
            Utils.checkStoreOpenDays(storeObject.timimg.storeOpenDays);
        if (isStoreOpenToday) {
          bool isStoreOpen = Utils.getDayOfWeek(
              storeObject.timimg.openhoursFrom, storeObject.timimg.openhoursTo);
          status = isStoreOpen;
        } else {
          status = false;
        }
      }

      return status;
    } catch (e) {
      print(e);
      return true;
    }
  }

//  static bool checkStoreOpenTime(StoreDataObj storeObject,OrderType deliveryType) {
//    // in case of deliver ignore is24x7Open
//    bool status = false;
//    try {
//      if (storeObject.is24X7Open == "0") {
//          bool isStoreOpenToday = Utils.checkStoreOpenDays(storeObject);
//          if (isStoreOpenToday) {
//            bool isStoreOpen = Utils.getDayOfWeek(storeObject);
//            status = isStoreOpen;
//          } else {
//            status = false;
//          }
//        } else if (storeObject.is24X7Open == "1") {
//          status = true;
//        }
//      return status;
//    } catch (e) {
//      print(e);
//      return true;
//    }
//  }

  static Widget getIndicatorView() {
    return Center(
      child: CircularProgressIndicator(
          backgroundColor: Colors.black26,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
    );
  }

  static Widget getEmptyView2(String value) {
    return Container(
      child: Center(
        child: Text(value,
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
            )),
      ),
    );
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static Future<void> setSetCurrentScreen(
      String screenName, String screenClassOverride) async {
    await analytics.setCurrentScreen(
      screenName: '${screenName}',
      screenClassOverride: '${screenClassOverride}',
    );
  }

  static Future<void> sendAnalyticsEvent(
      String name, Map<String, dynamic> parameters) async {
    String eventName = name.replaceAll(" ", "_");
    await analytics.logEvent(
      name: '${eventName}',
      parameters: parameters,
    );
  }

  static Future<void> sendSearchAnalyticsEvent(String searchTerm) async {
    await analytics.logSearch(
      searchTerm: '${searchTerm}',
    );
  }

  static Future<List<DeliveryAddressData>> checkDeletedAreaFromStore(
      BuildContext context, List<DeliveryAddressData> addressList,
      {bool showDialogBool, bool hitApi = false, String id = ""}) async {
    DeliveryAddressData deletedItem;
    print(id);
    for (int i = 0; i < addressList.length; i++) {
      print(addressList[i].id.compareTo(id) == 0);
      if (id.isNotEmpty &&
          addressList[i].id.compareTo(id) == 0 &&
          addressList[i].isDeleted) {
        deletedItem = addressList[i];
        break;
      } else if (id.isEmpty && addressList[i].isDeleted) {
        deletedItem = addressList[i];
        break;
      }
    }

    if (deletedItem != null) {
      bool results = false;
      if (showDialogBool) {
        results = await DialogUtils.showAreaRemovedDialog(
            context, deletedItem.areaName);
      } else {
        results = true;
      }
      if (results) {
        //Hit api
        if (hitApi)
          ApiController.deleteDeliveryAddressApiRequest(deletedItem.id);
        addressList.remove(deletedItem);
        addressList = await checkDeletedAreaFromStore(context, addressList,
            showDialogBool: false, hitApi: hitApi);
      }
    }
    return addressList;
  }

  static Future<String> getCartItemsListToJson(
      {bool isOrderVariations = true,
      List<OrderDetail> responseOrderDetail}) async {
    List jsonList = OrderDetail.encodeToJson(responseOrderDetail,
        removeOutOfStockProducts: true);
    String encodedDoughnut = jsonEncode(jsonList);
    return encodedDoughnut;
  }

  static bool checkIfStoreClosed(StoreModel store) {
    if (store.storeStatus == "0") {
      //0 mean Store close
      return true;
    } else {
      return false;
    }
  }

  static Color colorGeneralization(Color passedColor, String colorString) {
    Color returnedColor = passedColor;
    if (colorString != null) {
      try {
        returnedColor = Color(int.parse(colorString.replaceAll("#", "0xff")));
      } catch (e) {
        print(e);
      }
    }
    return returnedColor;
  }

  static DateTime loginClickTime;

  static bool isRedundentClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
      print("first click");
      return false;
    }
    print('diff is ${currentTime.difference(loginClickTime).inSeconds}');
    if (currentTime.difference(loginClickTime).inMilliseconds < 1200) {
      //set this difference time in seconds
      return true;
    }

    loginClickTime = currentTime;
    return false;
  }
  static convertWalletDate(String date) {
    String formatted = date;
    try {
      DateFormat format = new DateFormat("yyyy-MM-dd hh:mm:ss");
      //UTC time true
      DateTime time = format.parse(date, true);
      time = time.toLocal();
      //print("time.toLocal()=   ${time.toLocal()}");
      DateFormat formatter = new DateFormat(
          'dd MMM, yyyy hh:mm aa'); // Change hh:mm:aa to hh:mm aa
      formatted = formatter.format(time.toLocal());
    } catch (e) {
      print(e);
    }

    return formatted;
  }

  static void getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = await DeviceInfoPlugin();
    PackageInfo packageInfo = await Utils.getAppVersionDetails();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    Map<String, dynamic> param = Map();
    param['app_version'] = packageInfo.version;
    param['device_id'] = deviceId;
    param['device_token'] = deviceToken;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      param['device_brand'] = androidInfo.brand;
      param['device_model'] = androidInfo.model;
      param['device_os'] = androidInfo.version.sdkInt;
      param['device_os_version'] = androidInfo.version.sdkInt;

      param['platform'] = 'android';
      param['model'] = androidInfo.model;
      param['manufacturer'] = androidInfo.manufacturer;
      param['isPhysicalDevice'] = androidInfo.isPhysicalDevice;
      param['androidId'] = androidInfo.androidId;
      param['brand'] = androidInfo.brand;
      param['device'] = androidInfo.device;
      param['display'] = androidInfo.display;
      param['version_sdkInt'] = androidInfo.version.sdkInt;
      param['version_release'] = androidInfo.version.release;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      param['device_brand'] = iosInfo.model;
      param['device_model'] = iosInfo.model;
      param['device_os'] = iosInfo.systemName;
      param['device_os_version'] = iosInfo.systemVersion;

      param['platform'] = 'ios';
      param['name'] = iosInfo.name;
      param['systemName'] = iosInfo.systemName;
      param['systemVersion'] = iosInfo.systemVersion;
      param['model'] = iosInfo.model;
      param['isPhysicalDevice'] = iosInfo.isPhysicalDevice;
      param['release'] = iosInfo.utsname.release;
      param['version'] = iosInfo.utsname.version;
      param['machine'] = iosInfo.utsname.machine;
    }
    DeviceInfo.getInstance(deviceInfo: param);
  }
  static String removeAllHtmlTags(String htmlText) {
    try {
      var document = parse(htmlText);
      String parsedString = parse(document.body.text).documentElement.text;
      return parsedString;
    } catch (e) {
      print(e);
      return "";
    }
  }
}

Future<void> share2(String referEarn, BrandData store) async {
  if (referEarn != null && store.isRefererFnEnable) {
    await FlutterShare.share(
        title: '${store.name}',
        linkUrl: referEarn,
        chooserTitle: 'Refer & Earn');
  } else {
    await FlutterShare.share(
        title: 'Kindly download',
        text: 'Kindly download' + store.name + 'app from',
        linkUrl:
            Platform.isIOS ? store.iphoneShareLink : store.androidShareLink,
        chooserTitle: 'Share');
  }
}

enum HomeScreenEnum {
  HOME_BAND_VIEW,
  HOME_SEARCH_VIEW,
  HOME_RESTAURANT_VIEW,
  HOME_BAND_CATEGORIES_VIEW,
  HOME_SELECTED_STORE_VIEW
}

enum ClassType { CART, SubCategory, Favourites, Home, Search }

enum OrderType { Delivery, PickUp, Menu, SUBSCRIPTION_ORDER ,DineIn}

enum PaymentType { COD, ONLINE, ONLINE_PAYTM, CANCEL }

enum PaymentMethod {
  WALLET,
  ORDER,
  SUBSCRIPTION,
  SUBSCRIPTION_ORDER,
  WALLET_TOP_UP
}

enum RadioButtonEnum { SELECTD, UNSELECTED }

class AdditionItemsConstants {
  static const ABOUT_US = "About Us";
  static const FAQ = "FAQ";
  static const TERMS_CONDITIONS = "Terms and Conditions";
  static const PRIVACY_POLICY = "Privacy Policy";
  static const REFUND_POLICY = "Refund Policy";
  static const Shipping_Charge = "Shipping Charge";
}
