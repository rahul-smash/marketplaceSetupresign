import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/Screens/BookOrder/MyCartScreen.dart';
import 'package:restroapp/src/Screens/Dashboard/MarketPlaceHomeCategoryView.dart';
import 'package:restroapp/src/Screens/Notification/NotificationScreen.dart';
import 'package:restroapp/src/Screens/Dashboard/HomeSearchView.dart';
import 'package:restroapp/src/Screens/Offers/MyOrderScreenVersion2.dart';
import 'package:restroapp/src/Screens/SideMenu/SideMenu.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/Categorys.dart';
import 'package:restroapp/src/models/ConfigModel.dart';
import 'package:restroapp/src/models/StoreBranchesModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SearchScreen.dart';
import 'dart:io';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

class MarketPlaceHomeScreen extends StatefulWidget {
  //final StoreModel store;
  LatLng initialPosition;
  final BrandData brandData;
  ConfigModel configObject;
  bool showForceUploadAlert;

  MarketPlaceHomeScreen(this.brandData, this.configObject, this.showForceUploadAlert, initialPosition);

  @override
  State<StatefulWidget> createState() {
    return _MarketPlaceHomeScreenState(this.brandData);
  }
}

class _MarketPlaceHomeScreenState extends State<MarketPlaceHomeScreen> {

  BrandData store;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  List<NetworkImage> imgList = [];
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  UserModel user;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);
  bool isStoreClosed;
  final DatabaseHelper databaseHelper = new DatabaseHelper();
  int cartBadgeCount;
  StoreBranchesModel storeBranchesModel;
  BranchData branchData;
  bool isLoading;
  CategoryResponse categoryResponse;
  List<SubCategoryModel> subCategoryList = List();
  List<Product> productsList = List();
  int _current = 0;

  final _controller = TextEditingController();

  bool isCategoryViewSelected = false;

  SubCategoryModel subCategory;

  String selectedSubCategoryId;
  CategoryModel selectedCategory;
  CategoriesModel categoriesModel;

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  String locationAddress = "Select Location";
  ScrollController controller = ScrollController();
  bool isViewAllSelected = false;
  StoresModel allStoreData;

  _MarketPlaceHomeScreenState(this.store);

  @override
  void initState() {
    super.initState();
    isStoreClosed = false;
    isViewAllSelected = false;
    initFirebase();
    _setSetCurrentScreen();
    cartBadgeCount = 0;
    getCartCount();
    listenCartChanges();
    checkForMultiStore();
    getCategoryApi();
    listenEvent();
    try {
      //AppConstant.placeholderUrl = store.banner10080;
      print("-----store.banners-----${store.banners.length}------");
      if (store.banners.isEmpty) {
//        imgList = [NetworkImage(AppConstant.placeholderImageUrl)];
      } else {
        for (var i = 0; i < store.banners.length; i++) {
          String imageUrl = store.banners[i].image;
          imgList.add(
            NetworkImage(
                imageUrl.isEmpty ? AppConstant.placeholderImageUrl : imageUrl),
          );
        }
      }
      if (widget.showForceUploadAlert) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          DialogUtils.showForceUpdateDialog(context, store.name,
              store.forceDownload[0].forceDownloadMessage,storeModel: store);
        });
      } else {
        if (!checkIfStoreClosed()) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!AppConstant.isLoggedIn && store.isRefererFnEnable) {
              String showReferEarnAlert = await SharedPrefs.getStoreSharedValue(
                  AppConstant.showReferEarnAlert);
              print("showReferEarnAlert=${showReferEarnAlert}");
              if (showReferEarnAlert == null) {
                SharedPrefs.storeSharedValue(
                    AppConstant.showReferEarnAlert, "true");
                DialogUtils.showInviteEarnAlert2(context);
              }
            }
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void listenEvent() {
    eventBus.on<onViewAllSelected>().listen((event) {
      print("isViewAllSelected=${event.isViewAllSelected}");
      setState(() {
        isViewAllSelected = event.isViewAllSelected;
        allStoreData = event.allStoreData;
      });
      scrollTop();
    });

    eventBus.on<onCartRemoved>().listen((event) {
      setState(() {
        setState(() {
          _controller.text = '';
          productsList.clear();
          if (isCategoryViewSelected) {
            isCategoryViewSelected = !isCategoryViewSelected;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return this.keyboardDismisser(
        context: context,
        child: WillPopScope(
          child: Scaffold(
            key: _key,
            appBar: getAppBar(),
            body: _newBody(),
            drawer: NavDrawerMenu(store, user == null ? "" : user.fullName, () {
              FocusScope.of(context).unfocus();
              _controller.text = "";
              subCategoryList.clear();
              productsList.clear();
              isCategoryViewSelected = false;
              setState(() {});
            }),
            bottomNavigationBar: SafeArea(
              child: addBottomBar(),
            ),
          ),
          onWillPop: () {
            if (productsList.length > 0) {
              setState(() {
                _controller.text = '';
                productsList.clear();
              });
              return new Future(() => false);
            } else {
              if (isCategoryViewSelected) {
                setState(() {
                  isCategoryViewSelected = !isCategoryViewSelected;
                });
                return new Future(() => false);
              } else
                return new Future(() => true);
            }
          },
        ));
  }

  Widget addBanners() {
    if (imgList.length == 0) {
      return Container();
    } else
      return Center(
        child: SizedBox(
          height: 200.0,
          width: Utils.getDeviceWidth(context),
          child: _CarouselView(),
        ),
      );
  }

  Widget _CarouselView() {
    return CarouselSlider.builder(
      itemCount: imgList.length,
      options: CarouselOptions(
        aspectRatio: 16 / 9,
        height: 200,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
        enlargeCenterPage: false,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.ease,
        scrollDirection: Axis.horizontal,
      ),
      itemBuilder: (BuildContext context, int itemIndex) => Container(
        child: _makeBanner(context, itemIndex),
      ),
    );
  }

  Widget _makeBanner(BuildContext context, int _index) {
    return InkWell(
      onTap: () => _onBannerTap(_index),
      child: Container(
          margin:
          EdgeInsets.only(top: 0.0, bottom: 15.0, left: 7.5, right: 7.5),
          width: Utils.getDeviceWidth(context)-(Utils.getDeviceWidth(context) / 4),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: "${imgList[_index].url}",
              fit: BoxFit.fill,
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          )),
    );
  }

  void _onBannerTap(position) {
    print("onImageTap ${position}");
    print("linkTo=${store.banners[position].linkTo}");

    if (store.banners[position].linkTo.isNotEmpty) {
      if (store.banners[position].linkTo == "category") {
        if (store.banners[position].categoryId == "0" &&
            store.banners[position].subCategoryId == "0" &&
            store.banners[position].productId == "0") {
          print("return");
          return;
        }

        if (store.banners[position].categoryId != "0" &&
            store.banners[position].subCategoryId != "0" &&
            store.banners[position].productId != "0") {
          // here we have to open the product detail
          print("open the product detail ${position}");
        } else if (store.banners[position].categoryId != "0" &&
            store.banners[position].subCategoryId != "0" &&
            store.banners[position].productId == "0") {
          //here open the banner sub category
          print("open the subCategory ${position}");

          for (int i = 0; i < categoryResponse.categories.length; i++) {
            CategoryModel categories = categoryResponse.categories[i];
            if (store.banners[position].categoryId == categories.id) {
              print(
                  "title ${categories.title} and ${categories.id} and ${store.banners[position].categoryId}");
              if (categories.subCategory != null) {
                for (int j = 0; j < categories.subCategory.length; j++) {
                  SubCategory subCategory = categories.subCategory[j];

                  if (subCategory.id == store.banners[position].subCategoryId) {
                    print(
                        "open the subCategory ${subCategory.title} and ${subCategory.id} = ${store.banners[position].subCategoryId}");

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return SubCategoryProductScreen(categories, true, j);
                      }),
                    );

                    break;
                  }
                }
              }
            }
            //print("Category ${categories.id} = ${categories.title} = ${categories.subCategory.length}");
          }
        } else if (store.banners[position].categoryId != "0" &&
            store.banners[position].subCategoryId == "0" &&
            store.banners[position].productId == "0") {
          print("open the Category ${position}");

          for (int i = 0; i < categoryResponse.categories.length; i++) {
            CategoryModel categories = categoryResponse.categories[i];
            if (store.banners[position].categoryId == categories.id) {
              print(
                  "title ${categories.title} and ${categories.id} and ${store.banners[position].categoryId}");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SubCategoryProductScreen(categories, true, 0);
                }),
              );
              break;
            }
          }
        }
      }
    }
  }

  Widget addBottomBar() {
    return Stack(
      overflow: Overflow.visible,
      alignment: new FractionalOffset(.5, 1.0),
      children: <Widget>[
        BottomNavigationBar(
          currentIndex: _currentIndex,
//          backgroundColor: bottomBarBackgroundColor,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('images/homeicon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: isCategoryViewSelected
                      ? staticHomeDescriptionColor
                      : appThemeSecondary),
              title: Text('Home',
                  style: TextStyle(
                      color: isCategoryViewSelected
                          ? staticHomeDescriptionColor
                          : appThemeSecondary)),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/unselectedcategoryicon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: !isCategoryViewSelected
                      ? staticHomeDescriptionColor
                      : appThemeSecondary),
              title: Text('Category',
                  style: TextStyle(
                      color: !isCategoryViewSelected
                          ? staticHomeDescriptionColor
                          : appThemeSecondary)),
            ),
//            BottomNavigationBarItem(
//              icon: Image.asset('images/contacticon.png',
//                  width: 24,
//                  fit: BoxFit.scaleDown,
//                  color: staticHomeDescriptionColor),
//              title: Text('Contact',
//                  style: TextStyle(color: staticHomeDescriptionColor)),
//            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/unselectedexploreicon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: staticHomeDescriptionColor),
              title: Text('Search',
                  style: TextStyle(color: staticHomeDescriptionColor)),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/unselectedmyordericon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: staticHomeDescriptionColor),
              title: Text('My Orders',
                  style: TextStyle(color: staticHomeDescriptionColor)),
            ),
            BottomNavigationBarItem(
              icon: Badge(
                badgeColor: appThemeSecondary,
                showBadge: cartBadgeCount == 0 ? false : true,
                badgeContent: Text('${cartBadgeCount}',
                    style: TextStyle(color: Colors.white)),
                child: Image.asset('images/unselectedcarticon.png',
                    width: 24,
                    fit: BoxFit.scaleDown,
                    color: staticHomeDescriptionColor),
              ),
              title: Padding(
                padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: Text('Cart',
                    style: TextStyle(color: staticHomeDescriptionColor)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  onTabTapped(int index) {
    if (checkIfStoreClosed()) {
      DialogUtils.displayCommonDialog(context, store.name, /*store.storeMsg*/"Store Closed");
    } else {
      setState(() {
        _currentIndex = index;
        if (_currentIndex == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyCartScreen(() {
                  getCartCount();
                })),
          );

          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "MyCartScreen";
          Utils.sendAnalyticsEvent("Clicked MyCartScreen", attributeMap);
        }
        if (_currentIndex == 2) {
          if (AppConstant.isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          } else {
            Utils.showLoginDialog(context);
          }
          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "SearchScreen";
          Utils.sendAnalyticsEvent("Clicked SearchScreen", attributeMap);
        }
        if (_currentIndex == 3) {
          if (AppConstant.isLoggedIn) {
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyOrderScreenVersion2(store)),
            );*/
            Map<String, dynamic> attributeMap = new Map<String, dynamic>();
            attributeMap["ScreenName"] = "MyOrderScreen";
            Utils.sendAnalyticsEvent("Clicked MyOrderScreen", attributeMap);
          } else {
            Utils.showLoginDialog(context);
          }
        }
        if (_currentIndex == 1) {
          setState(() {
            _controller.text = '';
            productsList.clear();
            isCategoryViewSelected = true;
          });
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => ContactScreen(store)),
//          );
//          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
//          attributeMap["ScreenName"] = "ContactScreen";
//          Utils.sendAnalyticsEvent("Clicked ContactScreen", attributeMap);
        }
        if (_currentIndex == 0) {
          //show categories
          setState(() {
            _controller.text = '';
            productsList.clear();
            isCategoryViewSelected = false;
          });
        }
      });
    }
  }

  _handleDrawer() async {
    try {
      if(isViewAllSelected){

      }else{
        if (checkIfStoreClosed()) {
          DialogUtils.displayCommonDialog(
              context, store.name, /*store.storeMsg*/"Store Closed");
        } else {
          _key.currentState.openDrawer();
          if (AppConstant.isLoggedIn) {
            user = await SharedPrefs.getUser();
            if (user != null) setState(() {});
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void initFirebase() {
    if (widget.configObject.isGroceryApp == "true") {
      AppConstant.isRestroApp = false;
    } else {
      AppConstant.isRestroApp = true;
    }
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        try {
          print("------onMessage: $message");
          if (AppConstant.isLoggedIn) {
            if (Platform.isIOS) {
              print("iosssssssssssssssss");
              String title = message['aps']['alert']['title'];
              String body = message['aps']['alert']['body'];
              showNotification(title, body, message);
            } else {
              print("androiddddddddddd");
              String title = message['notification']['title'];
              String body = message['notification']['body'];
              showNotification(title, body, message);
            }
          }
        } catch (e) {
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        //print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        //print("onResume: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      //print("----token---- ${token}");
      try {
        SharedPrefs.storeSharedValue(AppConstant.deviceToken, token.toString());
      } catch (e) {
        print(e);
      }
    });
  }

  Future showNotification(
      String title, String body, Map<String, dynamic> message) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();

    String appName = await SharedPrefs.getStoreSharedValue(AppConstant.appName);

    var initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '${appName}', '${appName}', '${appName}',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  Future<void> onSelectNotification(String payload) async {
    debugPrint('onSelectNotification : ');
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    debugPrint('onDidReceiveLocalNotification : ');
  }

  void listenCartChanges() {
    eventBus.on<updateCartCount>().listen((event) {
      getCartCount();
    });
    eventBus.on<openHome>().listen((event) {
      setState(() {
        _controller.text = '';
        productsList.clear();
        isCategoryViewSelected = false;
      });
    });
  }

  void checkForMultiStore() {
    print("isMultiStore=${widget.configObject.isMultiStore}");
    /*if (widget.configObject.isMultiStore) {
      ApiController.multiStoreApiRequest(widget.configObject.primaryStoreId)
          .then((response) {
        setState(() {
          this.storeBranchesModel = response;
          if (storeBranchesModel != null) {
            if (storeBranchesModel.data.isNotEmpty) {
              for (int i = 0; i < storeBranchesModel.data.length; i++) {
                if (widget.store.id == storeBranchesModel.data[i].id) {
                  branchData = storeBranchesModel.data[i];
                  break;
                }
              }
            }
          }
        });
      });
    }*/
  }

  bool checkIfStoreClosed() {
    String storeStatus = "0";
    if (storeStatus == "0") {
      //0 mean Store close
      return true;
    } else {
      return false;
    }
  }

  Future<void> _setSetCurrentScreen() async {
    await analytics.setCurrentScreen(
      screenName: 'MarketPlaceHomeScreen',
      screenClassOverride: 'MarketPlaceHomeScreenView',
    );
  }

  getCartCount() {
    databaseHelper.getCount(DatabaseHelper.CART_Table).then((value) {
      setState(() {
        cartBadgeCount = value;
      });
    });
  }

  void getCategoryApi() {
    isLoading = true;
    ApiController.categoriesApiRequest().then((response){
      setState(() {
        isLoading = false;
        this.categoriesModel = response;
        print("---CategoriesData-${categoriesModel.success}---");
      });
    });
    /*ApiController.getCategoriesApiRequest(store.id).then((response) {
      setState(() {
        isLoading = false;
        this.categoryResponse = response;
        //getHomeCategoryProductApi();
      });
    });*/
  }

  void getHomeCategoryProductApi() {
    if (categoryResponse != null &&
        categoryResponse.categories != null &&
        categoryResponse.categories.isNotEmpty) {
      String subCategoryId =
          categoryResponse.categories.first.subCategory[0].id;
      if (selectedCategory == null)
        selectedCategory = categoryResponse.categories.first;

      if (selectedSubCategoryId != null && selectedSubCategoryId.isNotEmpty) {
        subCategoryId = selectedSubCategoryId;
      }
      ApiController.getSubCategoryProducts(subCategoryId).then((response) {
        if (response != null && response.success) {
          subCategory = SubCategoryModel();
          selectedSubCategoryId = subCategoryId;
          for (int i = 0; i < response.subCategories.length; i++) {
            if (subCategoryId == response.subCategories[i].id) {
              subCategory = response.subCategories[i];
              break;
            }
          }
          setState(() {});
        }
      });
      eventBus.fire(OnProductTileDbRefresh());
    }
  }

  Future logout(BuildContext context, BranchData selectedStore) async {
    /*try {
      Utils.showProgressDialog(context);
      SharedPrefs.setUserLoggedIn(false);
      SharedPrefs.storeSharedValue(AppConstant.isAdminLogin, "false");
      SharedPrefs.removeKey(AppConstant.showReferEarnAlert);
      SharedPrefs.removeKey(AppConstant.referEarnMsg);
      AppConstant.isLoggedIn = false;
      DatabaseHelper databaseHelper = new DatabaseHelper();
      databaseHelper.deleteTable(DatabaseHelper.Categories_Table);
      databaseHelper.deleteTable(DatabaseHelper.Sub_Categories_Table);
      databaseHelper.deleteTable(DatabaseHelper.Favorite_Table);
      databaseHelper.deleteTable(DatabaseHelper.CART_Table);
      databaseHelper.deleteTable(DatabaseHelper.Products_Table);
      eventBus.fire(updateCartCount());

      StoreResponse storeData =
      await ApiController.versionApiRequest(selectedStore.id);
      CategoryResponse categoryResponse =
      await ApiController.getCategoriesApiRequest(storeData.store.id);
      setState(() {
        this.store = storeData.store;
        this.branchData = selectedStore;
        this.categoryResponse = categoryResponse;
        Utils.hideProgressDialog(context);
      });
    } catch (e) {
      print(e);
    }*/
  }

  Widget getAppBar() {
    bool rightActionsEnable = false,
        whatIconEnable = false,
        dialIconEnable = false;

    /*if (store.homePageDisplayNumberType != null &&
        store.homePageDisplayNumberType.isNotEmpty) {
      //0=>Contact Number,1=>App Icon,2=>None
      switch (store.homePageHeaderRight) {
        case "0":
          rightActionsEnable = true;
          break;
        case "1":
          rightActionsEnable = true;
          break;
        case "2":
          rightActionsEnable = false;
          break;
      }
      if (store.homePageDisplayNumber != null &&
          store.homePageDisplayNumber.isNotEmpty) {
        //0=>Whats app, 1=>Phone Call
        if (store.homePageDisplayNumberType.compareTo("0") == 0) {
          whatIconEnable = true;
        }
        //0=>Whats app, 1=>Phone Call
        if (store.homePageDisplayNumberType.compareTo("1") == 0) {
          dialIconEnable = true;
        }
      }
    }*/

    return AppBar(
      titleSpacing: 0,
      title: widget.configObject.isMultiStore == false
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () async {
              print("AppBar onTap");
              bool isNetworkAvailable = await Utils.isNetworkAvailable();
              if(!isNetworkAvailable){
                Utils.showToast("No Internet connection",false);
                return;
              }
              LatLng _initialPosition;
              _serviceEnabled = await location.serviceEnabled();
              if (!_serviceEnabled) {
                _serviceEnabled = await location.requestService();
                if (!_serviceEnabled) {
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
                  var result = await DialogUtils.displayDialog(context, "Location Permission Required",
                      "Please enable location permissions in settings.", "Cancel", "Ok");
                  if(result == true){
                    permission_handler.openAppSettings();
                  }
                  return;
                }
              }
              if (Platform.isAndroid) {
                await location.changeSettings(accuracy: LocationAccuracy.high,distanceFilter: 0,interval: 1000,);
              }
              _locationData = await location.getLocation();
              _initialPosition = LatLng(_locationData.latitude,_locationData.longitude);
              if (_initialPosition != null) {
                Coordinates coordinates = new Coordinates(_initialPosition.latitude, _initialPosition.longitude);
                var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
                var first = addresses.first;
                //print("--addresses-${addresses} and ${first}");
                print("----------${first.featureName} and ${first.addressLine}-postalCode-${first.postalCode}------");
                setState(() {
                  locationAddress = first.addressLine;
                });
              }
            },
            child: Visibility(
              visible: true,
              child: Row(
                children: [
                  SizedBox(
                    width: (Utils.getDeviceWidth(context)/2.6),
                    child: Text("${locationAddress}",
                      maxLines: 2,textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),),
                  ),
                  Icon(Icons.keyboard_arrow_down)
                ],
              ),
            ),
          ),
          /*Visibility(
            visible: store.homePageSubtitleStatus &&
                store.homePageSubtitle != null,
            child: Text(
              store.homePageSubtitle != null
                  ? store.homePageSubtitle
                  : "",
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          )*/
        ],
      ) : InkWell(
        onTap: () async {
          BranchData selectedStore =
          await DialogUtils.displayBranchDialog(context,
              "Select Branch", storeBranchesModel, branchData);
          if (selectedStore != null &&
              store.id.compareTo(selectedStore.id) != 0)
            logout(context, selectedStore);
        },
        child: Row(
          children: <Widget>[
            Text(branchData == null ? "" : branchData.storeName),
            Icon(Icons.keyboard_arrow_down)
          ],
        ),
      ),
      centerTitle: widget.configObject.isMultiStore == true ? false : false,
      leading: isViewAllSelected
          ? Icon(Icons.keyboard_arrow_left, size: 35)
          : IconButton(
        icon: Image.asset('images/menuicon.png', width: 25),
        onPressed: _handleDrawer,
      ),
      actions: <Widget>[
        Visibility(
            visible: AppConstant.isLoggedIn,
            child: IconButton(
              icon: Icon(
                Icons.notifications,
                size: 25.0,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return NotificationScreen();
                  }),
                );
              },
            )),
        Visibility(
          visible: rightActionsEnable && whatIconEnable,
          child: Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: Image.asset(
                  'images/whatsapp.png',
                  width: 28,
                  height: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  /*FlutterOpenWhatsapp.sendSingleMessage(
                      store.homePageDisplayNumber, "");*/
                },
              )),
        ),
        Visibility(
            visible: rightActionsEnable && dialIconEnable,
            child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    //_launchCaller(store.homePageDisplayNumber);
                  },
                  child: Icon(
                    Icons.call,
                    size: 25.0,
                    color: Colors.white,
                  ),
                )))
      ],
    );
  }


  _launchCaller(String call) async {
    String url = "tel:${call}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _newBody() {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          decoration: isCategoryViewSelected
              ? BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/backgroundimg.png"),
              fit: BoxFit.cover,
            ),
          )
              : null,
          color: !isCategoryViewSelected ? Colors.white : null,
        ),
        Padding(
          padding: EdgeInsets.only(top: isViewAllSelected ? 10 : 60),
          child: _getCurrentBody(),
        ),
        Visibility(
          visible: isViewAllSelected ? false : true,
          child: _addSearchView(),
        ),

      ],
    );
  }

  Widget _addSearchView() {
    return Container(
      height: 40,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      //padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          color: searchGrayColor,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          border: Border.all(
            color: searchGrayColor,
          )),
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Center(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(padding: EdgeInsets.fromLTRB(3,3,6,3),child:
                Image.asset('images/searchicon.png',
                    width: 20,
                    fit: BoxFit.scaleDown,
                    color: appTheme)),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      if (value.trim().isEmpty) {
                        Utils.showToast(
                            "Please enter some valid keyword", false);
                      } else {
                        callSearchAPI();
                      }
                    },
                    onChanged: (text) {
                      print("onChanged ${text}");
                    },
                    controller: _controller,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.text,
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: "Search for restaurants"),
                  ),
                ),
                Visibility(
                    visible: _controller.text.isNotEmpty,
                    child: IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: appTheme,
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _controller.text = "";
                            setState(() {
                              subCategoryList.clear();
                              productsList.clear();
                            });
                          });
                        }))
              ]),
        ),
      ),
    );
  }

  Widget keyboardDismisser({BuildContext context, Widget child}) {
    final gesture = GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
    return gesture;
  }

  void scrollTop(){
    controller.animateTo(0,
        curve: Curves.linear, duration: Duration(milliseconds: 100));
  }

  Widget _getCurrentBody() {
    if (productsList.length > 0) {
      return HomeSearchView(productsList);
    } else {
      return SingleChildScrollView(
        controller: controller,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
              visible: isViewAllSelected ? false : true,
              child: addBanners(),
            ),
            Visibility(
                visible: isViewAllSelected ? false : imgList.length > 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: imgList.map((url) {
                      int index = imgList.indexOf(url);
                      return _current == index
                          ? Container(
                        width: 7.0,
                        height: 7.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotIncreasedColor,
                        ),
                      )
                          : Container(
                        width: 6.0,
                        height: 6.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                )),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : categoriesModel == null
                ? Center(child: Text(""))
                : !isCategoryViewSelected
                ? MarketPlaceHomeCategoryView(categoriesModel,
              /*categoryResponse,*/
              store,
              subCategory,
              callback: <Object>({value}) {
                setState(() {
                  if (value is String) {
                    setState(() {
                      isCategoryViewSelected =
                      !isCategoryViewSelected;
                    });
                    return;
                  }
                  selectedCategory = value as CategoryModel;
                  this.selectedSubCategoryId =
                      selectedCategory.subCategory.first.id;
                  subCategory = null;
                  getHomeCategoryProductApi();
                });
                return;
              },
              selectedCategoryId: selectedSubCategoryId,
              selectedCategory: selectedCategory,
            )
                : Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              /*child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: .8,
                  physics: NeverScrollableScrollPhysics(),
                  padding:
                  EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 0.0,
                  shrinkWrap: true,
                  children: categoryResponse.categories.map((CategoryModel model) {
                    return GridTile(
                        child: CategoryView(model, store, false, 0));
                  }).toList()
              ),*/
            )
          ],
        ),
      );
    }
  }

  void callSearchAPI() {
    Utils.hideKeyboard(context);
    Utils.isNetworkAvailable().then((isNetworkAvailable) async {
      if (isNetworkAvailable) {
        Utils.sendSearchAnalyticsEvent(_controller.text);
        Utils.showProgressDialog(context);
        SubCategoryResponse subCategoryResponse =
        await ApiController.getSearchResults(_controller.text);
        Utils.hideKeyboard(context);
        Utils.hideProgressDialog(context);
        if (subCategoryResponse == null ||
            subCategoryResponse.subCategories.isEmpty) {
          Utils.showToast("No result found.", false);
          setState(() {
            subCategoryList.clear();
            productsList.clear();
          });
        } else {
          setState(() {
            subCategoryList = subCategoryResponse.subCategories;
            productsList.clear();
            for (int i = 0; i < subCategoryList.length; i++) {
              productsList.addAll(subCategoryList[i].products);
            }
          });
        }
      } else {
        Utils.showToast(AppConstant.noInternet, false);
      }
    });
  }
}
