import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:restroapp/src/Screens/Dashboard/MarketPlaceHomeScreen.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/ConfigModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'src/models/BrandModel.dart';
import 'src/models/VersionModel.dart';
import 'src/utils/DialogUtils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AppConstant.isLoggedIn = await SharedPrefs.isUserLoggedIn();

  bool isAdminLogin = false;
  String jsonResult = await loadAsset();
  final parsed = json.decode(jsonResult);
  ConfigModel configObject = ConfigModel.fromJson(parsed);
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    SharedPrefs.storeSharedValue(
        AppConstant.deviceId, iosDeviceInfo.identifierForVendor);
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    SharedPrefs.storeSharedValue(
        AppConstant.deviceId, androidDeviceInfo.androidId);
  }

  if (configObject.isGroceryApp == "true") {
    AppConstant.isRestroApp = false;
  } else {
    AppConstant.isRestroApp = true;
  }

  String branch_id =
      await SharedPrefs.getStoreSharedValue(AppConstant.branch_id);
  if (branch_id == null || branch_id.isEmpty) {
  } else if (branch_id.isNotEmpty) {
    configObject.storeId = branch_id;
  }
  //print(configObject.storeId);

  Crashlytics.instance.enableInDevMode = true;
  /*StoreResponse storeData =
      await ApiController.versionApiRequest("${configObject.storeId}");*/

  BrandVersionModel brandVersionModel = await ApiController.getBrandVersion();
  BrandModel.getInstance(brandVersionModelObj: brandVersionModel).brandVersionModel;

  //setAppThemeColors(brandVersionModel.store);
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  SharedPrefs.storeSharedValue(AppConstant.isAdminLogin, "${isAdminLogin}");

  PackageInfo packageInfo = await Utils.getAppVersionDetails();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // To turn off landscape mode
  runZoned(() {
    runApp(MarketPlaceApp(packageInfo, configObject, brandVersionModel));
  }, onError: Crashlytics.instance.recordError);

}

class MarketPlaceApp extends StatefulWidget {

  ConfigModel configObject;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  BrandVersionModel storeData;
  PackageInfo packageInfo;

  MarketPlaceApp(this.packageInfo, this.configObject, this.storeData);

  @override
  _MarketPlaceAppState createState() => _MarketPlaceAppState();

}

class _MarketPlaceAppState extends State<MarketPlaceApp> {

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  LatLng initialPosition;
  bool userDisabledGps = false;

  @override
  void initState() {
    super.initState();
    initialPosition = null;
    userDisabledGps = false;
    getCurrentLocation(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '${widget.storeData.brand.name}',
      theme: ThemeData(
        primaryColor: appTheme,
      ),
      navigatorObservers: <NavigatorObserver>[MarketPlaceApp.observer],
      //home: showHomeScreen(widget.storeData,widget.configObject,widget.packageInfo),
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/mk_splash.png"),
                fit: BoxFit.cover)
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: initialPosition == null
              ? userDisabledGps?Container(child: LocationAlertDialog()):Container()
              : showHomeScreen(widget.storeData,widget.configObject,widget.packageInfo,initialPosition),
        ),
      ),
    );
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("----!_serviceEnabled----$_serviceEnabled");
        setState(() {
          userDisabledGps = true;
        });
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    print("permission sttsu $_permissionGranted");
    if (_permissionGranted == PermissionStatus.denied) {
      print("permission deniedddd");
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("permission not grantedd");
        setState(() {
          userDisabledGps = true;
        });
        return;
      }
    }
    if (Platform.isAndroid) {
      await location.changeSettings(accuracy: LocationAccuracy.high,distanceFilter: 0,interval: 1000,);
    }
    _locationData = await location.getLocation();
    initialPosition = LatLng(_locationData.latitude,_locationData.longitude);
    setState(() {
      print("initialPosition=$initialPosition");
    });
  }
}


Widget showHomeScreen(BrandVersionModel model, ConfigModel configObject, PackageInfo packageInfo, LatLng initialPosition) {
  String version = packageInfo.version;
  if (model.success) {
    setStoreCurrency(model, configObject);
    /*SharedPrefs.storeSharedValue(
        AppConstant.DeliverySlot, model.brand.deliverySlot);
    SharedPrefs.storeSharedValue(
        AppConstant.is24x7Open, model.store.is24x7Open);*/

    List<ForceDownload> forceDownload = model.brand.forceDownload;
    //print("app= ${version} and -androidAppVerison--${forceDownload[0].androidAppVerison}");
    int index1 = version.lastIndexOf(".");
    //print("--substring--${version.substring(0,index1)} ");
    double currentVesrion = double.parse(version.substring(0, index1).trim());
    double apiVesrion = 1.0;
    try {
      apiVesrion = double.parse(
          forceDownload[0].androidAppVerison.substring(0, index1).trim());
    } catch (e) {
      //print("-apiVesrion--catch--${e}----");
    }
    //print("--currentVesrion--${currentVesrion} and ${apiVesrion}");
    if (apiVesrion > currentVesrion) {
      //return ForceUpdateAlert(forceDownload[0].forceDownloadMessage,appName);
      return MarketPlaceHomeScreen(model.brand, configObject, true,initialPosition);
    } else {
      return MarketPlaceHomeScreen(model.brand, configObject, false,initialPosition);
    }
  } else {
    return Container();
  }
}

void setStoreCurrency(BrandVersionModel store, ConfigModel configObject) {
  if (store.brand.showCurrency == "symbol") {
    if (store.brand.currency.isEmpty) {
      AppConstant.currency = store.brand.currency;
    } else {
      AppConstant.currency = configObject.currency;
    }
  } else {
    AppConstant.currency = store.brand.currency;
  }
}

/*void setAppThemeColors(BrandVersionModel store) {
  AppThemeColors appThemeColors = store.appThemeColors;
  left_menu_header_bkground =
      Color(int.parse(appThemeColors.leftMenuHeaderBackgroundColor));
  left_menu_icon_colors = Color(int.parse(appThemeColors.leftMenuIconColor));
  left_menu_background_color =
      Color(int.parse(appThemeColors.leftMenuBackgroundColor));
  leftMenuWelcomeTextColors =
      Color(int.parse(appThemeColors.leftMenuUsernameColor));
  leftMenuUsernameColors =
      Color(int.parse(appThemeColors.leftMenuUsernameColor));
  bottomBarIconColor = Color(int.parse(appThemeColors.bottomBarIconColor));
  bottomBarTextColor = Color(int.parse(appThemeColors.bottomBarTextColor));
  dotIncreasedColor = Color(int.parse(appThemeColors.dotIncreasedColor));
  bottomBarBackgroundColor =
      Color(int.parse(appThemeColors.bottom_bar_background_color));
  leftMenuLabelTextColors =
      Color(int.parse(appThemeColors.left_menu_label_Color));


  //flow change
  if (store.webAppThemeColors != null) {
    WebAppThemeColors webAppThemeColors = store.webAppThemeColors;
    appTheme = Utils.colorGeneralization(
        appTheme, webAppThemeColors.webThemePrimaryColor);
    appThemeLight = appTheme.withOpacity(0.1);
    appThemeSecondary = Utils.colorGeneralization(
        appThemeSecondary, webAppThemeColors.webThemeSecondaryColor);

    dotIncreasedColor=appThemeSecondary;
    webThemeCategoryOpenColor = Utils.colorGeneralization(
        appThemeLight, webAppThemeColors.webThemeCategoryOpenColor);
    stripsColor =
        Utils.colorGeneralization(stripsColor, webAppThemeColors.stripsColor);
    footerColor =
        Utils.colorGeneralization(footerColor, webAppThemeColors.footerColor);
    listingBackgroundColor = Utils.colorGeneralization(
        listingBackgroundColor, webAppThemeColors.listingBackgroundColor);
    listingBorderColor = Utils.colorGeneralization(
        listingBorderColor, webAppThemeColors.listingBorderColor);
    listingBoxBackgroundColor = Utils.colorGeneralization(
        listingBoxBackgroundColor, webAppThemeColors.listingBoxBackgroundColor);
    homeSubHeadingColor = Utils.colorGeneralization(
        homeSubHeadingColor, webAppThemeColors.homeSubHeadingColor);
    homeDescriptionColor = Utils.colorGeneralization(
        homeDescriptionColor, webAppThemeColors.homeDescriptionColor);
    categoryListingButtonBorderColor = Utils.colorGeneralization(
        categoryListingButtonBorderColor,
        webAppThemeColors.categoryListingButtonBorderColor);
    categoryListingBoxBackgroundColor = Utils.colorGeneralization(
        categoryListingBoxBackgroundColor,
        webAppThemeColors.categoryListingBoxBackgroundColor);

    bottomBarTextColor = Utils.colorGeneralization(
        bottomBarBackgroundColor,
        "#000000");
    bottomBarIconColor= appTheme;
    bottomBarBackgroundColor =
        Utils.colorGeneralization(
            bottomBarBackgroundColor,
            "#ffffff");
    leftMenuLabelTextColors =
        Utils.colorGeneralization(
            leftMenuLabelTextColors,
            "#ffffff");
  } else {
    appTheme = Color(int.parse(appThemeColors.appThemeColor));
    appThemeLight = appTheme.withOpacity(0.1);
  }
}*/

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/app_config.json');
}

class LocationAlertDialog extends StatelessWidget {

  LocationAlertDialog();

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text("Location Required!"),
      content: Text("Please enable location permissions in settings.",
        textAlign: TextAlign.center,),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      actions: <Widget>[
        FlatButton(
          child: Text("Open Settings"),
          textColor: Colors.blue,
          onPressed: () {
            //Navigator.of(context).pop(false);
            permission_handler.openAppSettings();
          },
        ),
      ],
    );
  }
}