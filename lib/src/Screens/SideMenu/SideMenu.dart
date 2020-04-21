import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginMobileScreen.dart';
import 'package:restroapp/src/Screens/SideMenu/AboutScreen.dart';
import 'package:restroapp/src/Screens/Address/DeliveryAddressList.dart';
import 'package:restroapp/src/Screens/SideMenu/BookNowScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginEmailScreen.dart';
import 'package:restroapp/src/Screens/Offers/MyOrderScreen.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';

import 'ProfileScreen.dart';

class NavDrawerMenu extends StatefulWidget {

  final StoreModel store;
  final String userName;
  NavDrawerMenu(this.store, this.userName);

  @override
  _NavDrawerMenuState createState() {
    return _NavDrawerMenuState();
  }
}

class _NavDrawerMenuState extends State<NavDrawerMenu> {

  _NavDrawerMenuState();

  final _drawerItems = [
    DrawerChildItem('Home', "images/home.png"),
    DrawerChildItem('My Profile', "images/myprofile.png"),
    DrawerChildItem('Delivery Address', "images/deliveryaddress.png"),
    DrawerChildItem('My Orders', "images/my_order.png"),
    DrawerChildItem('Book Now', "images/booknow.png"),
    DrawerChildItem('My Favorites', "images/myfav.png"),
    DrawerChildItem('About Us', "images/about.png"),
    DrawerChildItem('Refer & Earn', "images/refer.png"),
    DrawerChildItem('Login', "images/sign_in.png"),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xff151515),
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
        color: Colors.black,
        child: Padding(
            padding: EdgeInsets.only(left: 35, top: 40, bottom: 30),
            child: Row(children: [
              Image.asset("images/app_icon.png"),
              SizedBox(width: 10),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Welcome',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(AppConstant.isLoggedIn == false ? '' : widget.userName,
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ])
            ])));
  }

  Widget createDrawerItem(int index, BuildContext context) {
    var item = _drawerItems[index];
    return Padding(
        padding: EdgeInsets.only(left: 20),
        child: ListTile(
          leading: Image.asset(
              index == _drawerItems.length - 1
                  ? AppConstant.isLoggedIn == false
                  ? 'images/sign_in.png'
                  : 'images/sign_out.png'
                  : item.icon,
              width: 30),
          title: index == _drawerItems.length - 1
              ? Text(AppConstant.isLoggedIn == false ? 'Login' : 'Logout',
              style: TextStyle(color: Color(0xff6A6A6A), fontSize: 15))
              : Text(item.title,
              style: TextStyle(color: Color(0xff6A6A6A), fontSize: 15)),
          onTap: () {
            _openPageForIndex(index, context);
          },
        ));
  }

  _openPageForIndex(int pos, BuildContext context) {
    switch (pos) {
      case 0:
        Navigator.pop(context);
        break;
      case 1:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        } else {
          Utils.showLoginDialog(context);
        }
        break;
      case 2:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeliveryAddressList(false)),
          );
        } else {
          Utils.showLoginDialog(context);
        }
        break;
      case 3:
        if (AppConstant.isLoggedIn) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyOrderScreen(context)),
          );
        } else {
          Utils.showLoginDialog(context);
        }
        break;
      case 4:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookNowScreen(context)),
        );
        break;
      case 5:
        Navigator.pop(context);
        break;
      case 6:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutScreen(context)),
        );
        break;
      case 7:
        share();
        break;
      case 8:
        if (AppConstant.isLoggedIn) {
          _showDialog(context);
        } else {
          Navigator.pop(context);
          SharedPrefs.getStore().then((storeData){
            StoreModel model = storeData;
            print("---internationalOtp--${model.internationalOtp}");
            //User Login with Mobile and OTP = 0
            if(model.internationalOtp == "0"){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginMobileScreen("menu")),
              );
            }else{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginEmailScreen("menu")),
              );
            }
          });
        }
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
              onPressed: () {
                Navigator.of(context).pop();
                logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future logout(BuildContext context) async {
    try {

      SharedPrefs.setUserLoggedIn(false);
      AppConstant.isLoggedIn = false;
      DatabaseHelper databaseHelper = new DatabaseHelper();
      databaseHelper.deleteTable(DatabaseHelper.Categories_Table);
      databaseHelper.deleteTable(DatabaseHelper.Sub_Categories_Table);
      //databaseHelper.deleteTable(DatabaseHelper.Products_Table);
      databaseHelper.deleteTable(DatabaseHelper.CART_Table);
      Utils.showToast(AppConstant.logoutSuccess, true);

      setState(() {
        widget.userName == null;
      });
      /*SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear().then((status) {
        if (status == true) {

        }
      });*/
      //Pop Drawer
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'Kindly download',
        text: 'Kindly download' + widget.store.storeName + 'app from',
        linkUrl: widget.store.androidShareLink,
        chooserTitle: 'Refer & Earn');
  }
}



class DrawerChildItem {
  String title;
  String icon;
  DrawerChildItem(this.title, this.icon);
}