import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restroapp/src/Screens/BookOrder/MyCartScreen.dart';
import 'package:restroapp/src/Screens/Favourites/Favourite.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginMobileScreen.dart';
import 'package:restroapp/src/Screens/Offers/MyOrderScreenVersion2.dart';
import 'package:restroapp/src/Screens/SideMenu/AboutScreen.dart';
import 'package:restroapp/src/Screens/Address/DeliveryAddressList.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginEmailScreen.dart';
import 'package:restroapp/src/Screens/Offers/MyOrderScreen.dart';
import 'package:restroapp/src/Screens/SideMenu/FAQScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionBuyScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionPurchasedScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriedPlanScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionUtils.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/ReferEarnData.dart';
import 'package:restroapp/src/models/SocialModel.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';

import 'AdditionalInformation.dart';
import 'LoyalityPoints.dart';
import 'ProfileScreen.dart';

class NavDrawerMenu extends StatefulWidget {
  //final StoreModel store;
  final BrandData brandData;
  final String userName;
  VoidCallback callback;
  bool isPWAThemeEnable = true;

  NavDrawerMenu(
    this.brandData,
    this.userName,
    this.callback,
  );

  @override
  _NavDrawerMenuState createState() {
    return _NavDrawerMenuState();
  }
}

class _NavDrawerMenuState extends State<NavDrawerMenu> {
  List<dynamic> _drawerItems = List();
  SocialModel socialModel;
  double iconHeight = 25;
  GoogleSignIn _googleSignIn;

  _NavDrawerMenuState();

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    //print("isRefererFnEnable=${widget.store.isRefererFnEnable}");
    _drawerItems
        .add(DrawerChildItem(DrawerChildConstants.HOME, "images/home.png"));
    _drawerItems.add(DrawerChildItem(
        DrawerChildConstants.MY_PROFILE, "images/myprofile.png"));
    //Subscription
    if (widget.brandData.isMembershipOn == '1')
      _drawerItems.add(DrawerChildItem(
          DrawerChildConstants.SUBSCRIBE, "images/sunscriptionicon.png"));
    _drawerItems.add(DrawerChildItem(
        DrawerChildConstants.DELIVERY_ADDRESS, "images/deliveryaddress.png"));
    _drawerItems
        .add(DrawerChildItem(DrawerChildConstants.Cart, "images/carticon.png"));
    _drawerItems.add(
        DrawerChildItem(DrawerChildConstants.MY_ORDERS, "images/my_order.png"));
    if (widget.brandData.loyality == "1")
      _drawerItems.add(DrawerChildItem(
          DrawerChildConstants.LOYALITY_POINTS, "images/loyality.png"));
//    _drawerItems.add(
//        DrawerChildItem(DrawerChildConstants.MY_FAVORITES, "images/myfav.png"));
//    _drawerItems.add(
//        DrawerChildItem(DrawerChildConstants.ABOUT_US, "images/about_image.png"));
    _drawerItems.add(DrawerChildItem(
        widget.brandData.isRefererFnEnable && AppConstant.isLoggedIn
            ? DrawerChildConstants.ReferEarn
            : DrawerChildConstants.SHARE,
        "images/refer.png"));
    _drawerItems.add(DrawerChildItem(
        DrawerChildConstants.ADDITION_INFORMATION, "images/about.png"));
//    _drawerItems
//        .add(DrawerChildItem(DrawerChildConstants.FAQ, "images/about.png"));
    _drawerItems
        .add(DrawerChildItem(DrawerChildConstants.LOGIN, "images/sign_in.png"));
    try {
      _setSetUserId();
    } catch (e) {
      print(e);
    }

    if (widget.isPWAThemeEnable) {
      left_menu_background_color = Colors.white;
      left_menu_header_bkground = Colors.white;
      left_menu_icon_colors = Colors.black;
      leftMenuLabelTextColors = Colors.black;
      leftMenuWelcomeTextColors = Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: left_menu_background_color,
        ),
        child: Drawer(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _drawerItems.length + 1,
              itemBuilder: (BuildContext context, int index) {
                return (index == 0
                    ? createHeaderInfoItem()
                    : createDrawerItem(index - 1, context));
              }),
        ));
  }

  Widget createHeaderInfoItem() {
    return Container(
        color: left_menu_header_bkground,
        padding: EdgeInsets.only(top: 40, bottom: 15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              /*Image.asset('images/profileimg.png',color: Color(0xFFD6D6D6),*/
              Icon(
                Icons.account_circle,
                size: 100,
                color: Color(0xFFD6D6D6),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                  child: Text(
                      'Welcome' +
                          '${AppConstant.isLoggedIn == false ? '' : ' ' + widget.userName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: leftMenuWelcomeTextColors,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
//          Visibility(
//              visible: AppConstant.isLoggedIn,
//              child: Column(
//                children: [
//                  SizedBox(height: 5),
//                  Text(AppConstant.isLoggedIn == false ? '' : widget.userName,
//                      maxLines: 2,
//                      overflow: TextOverflow.ellipsis,
//                      style: TextStyle(
//                          color: leftMenuWelcomeTextColors, fontSize: 15)),
//                ],
//              ))
            ]));
  }

  Widget createDrawerItem(int index, BuildContext context) {
    var item = _drawerItems[index];
    return Padding(
        padding: EdgeInsets.only(left: 20),
        child: ListTile(
          leading: Image.asset(
              item.title == DrawerChildConstants.LOGIN ||
                      item.title == DrawerChildConstants.LOGOUT
                  ? AppConstant.isLoggedIn == false
                      ? 'images/sign_in.png'
                      : 'images/sign_out.png'
                  : item.icon,
              color: left_menu_icon_colors,
              width: 30),
          title: item.title == DrawerChildConstants.LOGIN ||
                  item.title == DrawerChildConstants.LOGOUT
              ? Text(
                  AppConstant.isLoggedIn == false
                      ? DrawerChildConstants.LOGIN
                      : DrawerChildConstants.LOGOUT,
                  style:
                      TextStyle(color: leftMenuLabelTextColors, fontSize: 15))
              : Text(item.title,
                  style:
                      TextStyle(color: leftMenuLabelTextColors, fontSize: 15)),
          onTap: () {
            _openPageForIndex(item, index, context);
          },
        ));
  }

  _openPageForIndex(DrawerChildItem item, int pos, BuildContext context) async {
    switch (item.title) {
      case DrawerChildConstants.HOME:
        widget.callback();
        Navigator.pop(context);
        break;
      case DrawerChildConstants.MY_PROFILE:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileScreen(false, "", "", null, null)),
          );
          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "ProfileScreen";
          Utils.sendAnalyticsEvent("Clicked ProfileScreen", attributeMap);
        } else {
          Navigator.pop(context);
          Utils.showLoginDialog(context);
        }
        break;
      case DrawerChildConstants.SUBSCRIBE:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  checkIsPlanPurchased()
                      ? SubscribedPlanScreen()
                      : SubscriptionBuyScreen()));
        } else {
          Utils.showLoginDialog(context);
        }
        break;
      case DrawerChildConstants.Cart:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyCartScreen(() {}),
              ));
          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "MyCartScreen";
          Utils.sendAnalyticsEvent("Clicked MyCartScreen", attributeMap);
        } else {
          Utils.showLoginDialog(context);
        }
        break;

      case DrawerChildConstants.DELIVERY_ADDRESS:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DeliveryAddressList(false, OrderType.Menu)),
          );
          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "DeliveryAddressList";
          Utils.sendAnalyticsEvent("Clicked DeliveryAddressList", attributeMap);
        } else {
          Navigator.pop(context);
          Utils.showLoginDialog(context);
        }
        break;
      case DrawerChildConstants.MY_ORDERS:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyOrderScreenVersion2(widget.brandData)),
          );
          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "MyOrderScreen";
          Utils.sendAnalyticsEvent("Clicked MyOrderScreen", attributeMap);
        } else {
          Navigator.pop(context);
          Utils.showLoginDialog(context);
        }
        break;
      case DrawerChildConstants.LOYALITY_POINTS:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoyalityPointsScreen(widget.brandData)),
          );
        } else {
          Navigator.pop(context);
          Utils.showLoginDialog(context);
        }

        break;
//      case DrawerChildConstants.MY_FAVORITES:
//        if (AppConstant.isLoggedIn) {
//          Navigator.pop(context);
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => Favourites(() {})),
//          );
//          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
//          attributeMap["ScreenName"] = "Favourites";
//          Utils.sendAnalyticsEvent("Clicked Favourites", attributeMap);
//        } else {
//          Utils.showLoginDialog(context);
//        }
        break;
      case DrawerChildConstants.ABOUT_US:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AboutScreen(widget.brandData)),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "AboutScreen";
        Utils.sendAnalyticsEvent("Clicked AboutScreen", attributeMap);
        break;

      case DrawerChildConstants.ADDITION_INFORMATION:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AdditionalInformation(widget.brandData)),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "AdditionalInformation";
        Utils.sendAnalyticsEvent("Clicked AdditionalInformation", attributeMap);
        break;
      case DrawerChildConstants.ReferEarn:
      case DrawerChildConstants.SHARE:
        if (AppConstant.isLoggedIn) {
          if (widget.brandData.isRefererFnEnable) {
            Navigator.pop(context);

            Utils.showProgressDialog(context);
            ReferEarnData referEarn = await ApiController.referEarn();
            Utils.hideProgressDialog(context);
            share2(referEarn.referEarn.sharedMessage, widget.brandData);
          } else {
            //Utils.showToast("Refer Earn is inactive!", true);
            share2(null, widget.brandData);
          }
        } else {
          Navigator.pop(context);
          if (widget.brandData.isRefererFnEnable) {
            var result = await DialogUtils.showInviteEarnAlert(context);
            print("showInviteEarnAlert=${result}");
          } else {
            share2(null, widget.brandData);
          }
        }
        //share();

        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "share apk url";
        Utils.sendAnalyticsEvent("Clicked share", attributeMap);

        //DialogUtils.showInviteEarnAlert2(context);

        break;
      case DrawerChildConstants.LOGIN:
      case DrawerChildConstants.LOGOUT:
        if (AppConstant.isLoggedIn) {
          _showDialog(context);
        } else {
          Navigator.pop(context);
          BrandData model =
              SingletonBrandData.getInstance().brandVersionModel.brand;
          print("---internationalOtp--${model.internationalOtp}");
          //User Login with Mobile and OTP = 0
          // 1 = email and 0 = ph-no
          if (model.internationalOtp == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginMobileScreen("menu")),
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

          /*SharedPrefs.getStore().then((storeData) {

          });*/
        }
        break;
      case DrawerChildConstants.FAQ:
        Navigator.pop(context);
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FAQScreen(widget.store)),
        );*/
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "FAQ";
        Utils.sendAnalyticsEvent("Clicked AboutScreen", attributeMap);
        break;
    }
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Logout"),
          content: new Text(AppConstant.logoutConfirm),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('YES'),
              onPressed: () async {
                Navigator.of(context).pop();
                logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Kindly download',
        text: 'Kindly download' + widget.brandData.name + 'app from',
        linkUrl: Platform.isIOS
            ? widget.brandData.iphoneShareLink
            : widget.brandData.androidShareLink,
        chooserTitle: 'Share');
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
          text: 'Kindly download' + widget.brandData.name + 'app from',
          linkUrl: Platform.isIOS
              ? widget.brandData.iphoneShareLink
              : widget.brandData.androidShareLink,
          chooserTitle: 'Share');
    }
  }

  Future logout(BuildContext context) async {
    try {
      FacebookLogin facebookSignIn = new FacebookLogin();
      bool isFbLoggedIn = await facebookSignIn.isLoggedIn;
      print("isFbLoggedIn=${isFbLoggedIn}");
      if (isFbLoggedIn) {
        await facebookSignIn.logOut();
      }

      bool isGoogleSignedIn = await _googleSignIn.isSignedIn();
      print("isGoogleSignedIn=${isGoogleSignedIn}");
      if (isGoogleSignedIn) {
        await _googleSignIn.signOut();
      }

      SharedPrefs.setUserLoggedIn(false);
      SharedPrefs.storeSharedValue(AppConstant.isAdminLogin, "false");
      SharedPrefs.removeKey(AppConstant.showReferEarnAlert);
      SharedPrefs.removeKey(AppConstant.referEarnMsg);
      SharedPrefs.removeKey("user");
      SingletonBrandData.getInstance().clearData();
      AppConstant.isLoggedIn = false;
      DatabaseHelper databaseHelper = new DatabaseHelper();
//      databaseHelper.deleteTable(DatabaseHelper.Categories_Table);
//      databaseHelper.deleteTable(DatabaseHelper.Sub_Categories_Table);
//      databaseHelper.deleteTable(DatabaseHelper.Favorite_Table);
      databaseHelper.deleteTable(DatabaseHelper.CART_Table);
//      databaseHelper.deleteTable(DatabaseHelper.Products_Table);
      eventBus.fire(updateCartCount());
      eventBus.fire(onCartRemoved());
      Utils.showToast(AppConstant.logoutSuccess, true);

      setState(() {
        widget.userName == null;
      });
      //Pop Drawer
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _setSetUserId() async {
    try {
      if (AppConstant.isLoggedIn) {
        UserModel user = await SharedPrefs.getUser();
        await Utils.analytics.setUserId('${user.id}');
        await Utils.analytics.setUserProperty(name: "userid", value: user.id);
        await Utils.analytics
            .setUserProperty(name: "useremail", value: user.email);
        await Utils.analytics
            .setUserProperty(name: "userfullName", value: user.fullName);
        await Utils.analytics
            .setUserProperty(name: "userphone", value: user.phone);
      }
    } catch (e) {
      print(e);
    }
  }
}

class DrawerChildItem {
  String title;
  String icon;

  DrawerChildItem(this.title, this.icon);
}

class DrawerChildConstants {
  static const HOME = "Home";
  static const MY_PROFILE = "My Profile";
  static const SUBSCRIBE = "Subscription";
  static const DELIVERY_ADDRESS = "Delivery Address";
  static const MY_ORDERS = "My Orders";
  static const Cart = "Cart";
  static const Categories = "Categories";
  static const LOYALITY_POINTS = "Loyality Points";
  static const MY_FAVORITES = "My Favorites";
  static const ABOUT_US = "About Us";
  static const ADDITION_INFORMATION = "Additional \nInformation";
  static const SHARE = "Share";
  static const FAQ = "FAQ";
  static const TERMS_CONDITIONS = "Terms and Conditions";
  static const PRIVACY_POLICY = "Privacy Policy";
  static const REFUND_POLICY = "Refund Policy";
  static const ReferEarn = "Refer & Earn";
  static const LOGIN = "Login";
  static const LOGOUT = "Logout";
}
