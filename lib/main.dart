import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
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
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'src/models/BrandModel.dart';
import 'src/models/VersionModel.dart';

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
  AppConstant.brandID = configObject.storeId;
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
  SingletonBrandData.getInstance(brandVersionModelObj: brandVersionModel)
      .brandVersionModel;

  setAppThemeColors(brandVersionModel);
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  SharedPrefs.storeSharedValue(AppConstant.isAdminLogin, "${isAdminLogin}");

  PackageInfo packageInfo = await Utils.getAppVersionDetails();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Utils.getDeviceInfo();
  // To turn off landscape mode
  runZoned(() {
    runApp(MarketPlaceApp(packageInfo, configObject, brandVersionModel));
  }, onError: Crashlytics.instance.recordError);
}

class MarketPlaceApp extends StatefulWidget {
  ConfigModel configObject;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  BrandVersionModel storeData;
  PackageInfo packageInfo;

  MarketPlaceApp(this.packageInfo, this.configObject, this.storeData);

  @override
  _MarketPlaceAppState createState() => _MarketPlaceAppState();
}

class _MarketPlaceAppState extends State<MarketPlaceApp> {

  @override
  void initState() {
    super.initState();
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
      home: showHomeScreen(widget.storeData,widget.configObject,widget.packageInfo,),
    );
  }
}

Widget showHomeScreen(BrandVersionModel model, ConfigModel configObject,
    PackageInfo packageInfo,) {
  String version = packageInfo.version;
  if (model.success) {
    setStoreCurrency(model, configObject);
    List<ForceDownload> forceDownload = model.brand.forceDownload;
    //print("app= ${version} and -androidAppVerison--${forceDownload[0].androidAppVerison}");
    int index1 = version.lastIndexOf(".");
    //print("--substring--${version.substring(0,index1)} ");
    double currentVesrion = double.parse(version.substring(0, index1).trim());
    double apiVesrion = 1.0;
    try {
      if (Platform.isIOS) {
        apiVesrion = double.parse(
            forceDownload[0].iosAppVersion.substring(0, index1).trim());
      } else {
        apiVesrion = double.parse(
            forceDownload[0].androidAppVerison.substring(0, index1).trim());
      }
    } catch (e) {
      //print("-apiVesrion--catch--${e}----");
    }
    //print("--currentVesrion--${currentVesrion} and ${apiVesrion}");
    if (apiVesrion > currentVesrion) {
      //return ForceUpdateAlert(forceDownload[0].forceDownloadMessage,appName);
      return MarketPlaceHomeScreen(
          model.brand, configObject, true, );
    } else {
      return MarketPlaceHomeScreen(
          model.brand, configObject, false, );
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
    if (store.brand.currency.isEmpty) {
      AppConstant.currency = store.brand.currency;
    } else {
      AppConstant.currency = configObject.currency;
    }
  }
}

void setAppThemeColors(BrandVersionModel store) {
  if (store.brand.webAppThemeColors != null) {
    WebAppThemeColors webAppThemeColors = store.brand.webAppThemeColors;
    appTheme = Utils.colorGeneralization(
        appTheme, webAppThemeColors.webThemePrimaryColor);
    appThemeLight = appTheme.withOpacity(0.1);
    appThemeSecondary = Utils.colorGeneralization(
        appThemeSecondary, webAppThemeColors.webThemeSecondaryColor);

    dotIncreasedColor = appThemeSecondary;
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

    bottomBarTextColor =
        Utils.colorGeneralization(bottomBarBackgroundColor, "#000000");
    bottomBarIconColor = appTheme;
    bottomBarBackgroundColor =
        Utils.colorGeneralization(bottomBarBackgroundColor, "#ffffff");
    leftMenuLabelTextColors =
        Utils.colorGeneralization(leftMenuLabelTextColors, "#ffffff");
  } else {
//    appTheme = Color(int.parse(appThemeColors.appThemeColor));
    appThemeLight = appTheme.withOpacity(0.1);
  }
}

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/app_config.json');
}

class LocationAlertDialog extends StatelessWidget {
  LocationAlertDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Location Required!"),
      content: Text(
        "Please enable location permissions in settings.",
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
