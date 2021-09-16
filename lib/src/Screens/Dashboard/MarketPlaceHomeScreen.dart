import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:restroapp/src/Screens/BookOrder/MyCartScreen.dart';
import 'package:restroapp/src/Screens/Dashboard/HomeSearchView.dart';
import 'package:restroapp/src/Screens/Dashboard/MarketPlaceHomeCategoryView.dart';
import 'package:restroapp/src/Screens/Dashboard/MarketPlaceHomeFiltersView.dart';
import 'package:restroapp/src/Screens/Dashboard/MarketPlaceHomeStoresView.dart';
import 'package:restroapp/src/Screens/Dashboard/MarketPlaceHomeTagsView.dart';
//import 'package:google_maps_webservice/places.dart';
import 'package:restroapp/src/Screens/Dashboard/StoreDashboardScreen.dart';
import 'package:restroapp/src/Screens/Notification/NotificationScreen.dart';
import 'package:restroapp/src/Screens/Offers/MyOrderScreenVersion2.dart';
import 'package:restroapp/src/Screens/SideMenu/SideMenu.dart';
import 'package:restroapp/src/UI/OffersList.dart';
import 'package:restroapp/src/UI/OffersListDetail.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/Categorys.dart';
import 'package:restroapp/src/models/ConfigModel.dart';
import 'package:restroapp/src/models/StoreBranchesModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TagsModel.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/HomeScreenContentText.dart';
import 'package:restroapp/src/utils/LogicalStack.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/widgets/AutoSearch.dart';
import 'package:url_launcher/url_launcher.dart';

import 'RestroLIstScreen.dart';
import 'SearchScreen.dart';

class MarketPlaceHomeScreen extends StatefulWidget {
  //final StoreModel store;
  LatLng initialPosition;
  final BrandData brandData;
  ConfigModel configObject;
  bool showForceUploadAlert;

  MarketPlaceHomeScreen(this.brandData, this.configObject,
      this.showForceUploadAlert, this.initialPosition);

  @override
  State<StatefulWidget> createState() {
    return _MarketPlaceHomeScreenState(this.brandData);
  }
}

class _MarketPlaceHomeScreenState extends State<MarketPlaceHomeScreen> {
  BrandData store;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  List<NetworkImage> imgList = List.empty(growable: true);
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
  int _current = 0;

  final _controller = TextEditingController();

  bool isCategoryViewSelected = false;

  SubCategoryModel subCategory;

  CategoriesModel categoriesModel;

  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  String locationAddress = getLocationSearchPlaceHolderText();
  ScrollController controller = ScrollController();

  StoresModel allStoreData;

  StoreDataModel _selectedSingleStore;

  HomeScreenEnum _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
  HomeScreenEnum _previousSelectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;

  TagsModel tagsModel;

  StoresModel storeData;
  DateTime currentBackPressTime;

  _MarketPlaceHomeScreenState(this.store);

  Map<String, HomeScreenSection> homeViewOrderMap = Map();
  LogicalStack<HomeScreenSection> homeScreenStack;

  @override
  void initState() {
    super.initState();
    isStoreClosed = false;
//    isViewAllSelected = false;
    initFirebase();
    _setSetCurrentScreen();
    cartBadgeCount = 0;
    listenEvent();
    getCartCount();
    checkForMultiStore();
    getAddressFromLocation();
    getCategoryApi();
    _getTagApi();
    _getStoreApi();
    //fetching Subscription plan
    _getSubscriptionPlan();
    homeScreenStack = new LogicalStack();

    for (HomeScreenSection item in store.homeScreenSection) {
      _homeScreenItemsort(item);
      homeViewOrderMap.putIfAbsent(item.section, () => item);
    }

    try {
      print("-----store.banners-----${store.banners.length}------");
      if (store.banners.isEmpty) {
//        imgList = [NetworkImage(AppConstant.placeholderImageUrl)];
      } else {
//        for (var i = 0; i < store.banners.length; i++) {
//          String imageUrl = store.banners[i].image;
//          imgList.add(
//            NetworkImage(
//                imageUrl.isEmpty ? AppConstant.placeholderImageUrl : imageUrl),
//          );
//        }
      }
      if (widget.showForceUploadAlert) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          DialogUtils.showForceUpdateDialog(
              context, store.name, store.forceDownload[0].forceDownloadMessage,
              storeModel: store);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPosition == null) {
        getCurrentLocation();
//        DialogUtils.displayLocationNotAvailbleDialog(
//            context, "Location not available", buttonText1: 'Dismiss',
//            button1: () async {
//
//          Navigator.pop(context);
//        });
      }
      location.onLocationChanged.listen((LocationData currentLocation) {
        // Use current location
        if (widget.initialPosition == null) {
          widget.initialPosition =
              LatLng(currentLocation.latitude, currentLocation.longitude);
          //ReloadApi
          _getStoreApi();
          setState(() {
            print("----initialPosition----=${widget.initialPosition}");
          });
        }
      });
      _getContentApi();
    });
  }

  void listenEvent() {
    eventBus.on<updateCartCount>().listen((event) {
      getCartCount();
    });
    eventBus.on<openHome>().listen((event) {
      setState(() {
        _controller.text = '';
        isCategoryViewSelected = false;
        _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
      });
    });

//    eventBus.on<onViewAllSelected>().listen((event) {
//      print("isViewAllSelected=${event.isViewAllSelected}");
//      _selectedHomeScreen = event.selectedScreen;
//      isViewAllSelected = event.isViewAllSelected;
//      allStoreData = event.allStoreData;
//      setState(() {});
//      scrollTop();
//    });

    eventBus.on<onCartRemoved>().listen((event) {
      setState(() {
        setState(() {
          _controller.text = '';
          _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
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
            drawerEnableOpenDragGesture: false,
            drawer: NavDrawerMenu(store, user == null ? "" : user.fullName, () {
              FocusScope.of(context).unfocus();
              _controller.text = "";
              isCategoryViewSelected = false;
              if (_selectedHomeScreen == HomeScreenEnum.HOME_SEARCH_VIEW) {
                _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
              }
              setState(() {});
            }),
            bottomNavigationBar: SafeArea(
              child: addBottomBar(),
            ),
          ),
          onWillPop: () {
            switch (_selectedHomeScreen) {
              case HomeScreenEnum.HOME_SELECTED_STORE_VIEW:
                setState(() {
                  _selectedHomeScreen = _previousSelectedHomeScreen;
                });
                return new Future(() => false);
              case HomeScreenEnum.HOME_SEARCH_VIEW:
                _clearSearchResult();
                return new Future(() => false);
                break;
              case HomeScreenEnum.HOME_RESTAURANT_VIEW:
                setState(() {
                  _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
                });
                return new Future(() => false);
                break;
              case HomeScreenEnum.HOME_BAND_VIEW:
              default:
                DateTime now = DateTime.now();
                if (currentBackPressTime == null ||
                    now.difference(currentBackPressTime) >
                        Duration(seconds: 2)) {
                  currentBackPressTime = now;
                  Utils.showToast('Please click BACK again to exit', false);
                  return Future.value(false);
                }
                return Future.value(true);
                return new Future(() => true);
            }
          },
        ));
  }

  Widget addBanners() {
    if (imgList.length == 0) {
      return Container();
    } else
      return Visibility(
        visible: (homeViewOrderMap.length == 0) ||
            (homeViewOrderMap[HomeScreenViewHelper.SLIDER] != null &&
                homeViewOrderMap[HomeScreenViewHelper.SLIDER].display),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: 200.0,
                width: Utils.getDeviceWidth(context),
                child: _CarouselView(),
              ),
            ),
            Padding(
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
            ),
          ],
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
          width: Utils.getDeviceWidth(context) -
              (Utils.getDeviceWidth(context) / 4),
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

  void _onBannerTap(position) async {
    print("onImageTap ${position}");
    print("linkTo=${store.banners[position].linkTo}");

    if (store.banners[position].linkTo.isNotEmpty) {
      if (store.banners[position].linkTo == "category") {
        if (store.banners[position].categoryId != null &&
            store.banners[position].categoryId == "0") {
          print("return");
          return;
        }

        print("onTap===>${store.banners[position].categoryId}");
        bool isNetworkAvailable = await Utils.isNetworkAvailable();
        if (!isNetworkAvailable) {
          Utils.showToast("No Internet connection", false);
          return;
        }
        Map<String, dynamic> data = {
          "lat": widget.initialPosition.latitude,
          "lng": widget.initialPosition.longitude,
          "search_by": "category",
          "id": "${store.banners[position].categoryId}",
        };
        Utils.showProgressDialog(context);
        ApiController.getAllStores(params: data).then((storesResponse) {
          Utils.hideProgressDialog(context);
          Utils.hideKeyboard(context);
          if (storesResponse != null && storesResponse.success)
            setState(() {
              allStoreData = storesResponse;
              _previousSelectedHomeScreen = _selectedHomeScreen;
              _selectedHomeScreen = HomeScreenEnum.HOME_RESTAURANT_VIEW;
            });
        });
      } else if (store.banners[position].linkTo == "pages") {
        if (store.banners[position].pageId != null &&
            store.banners[position].pageId == "0") {
          print("return");
          return;
        }
        print("----onTap-${store.banners[position].pageId}--");
        bool isNetworkAvailable = await Utils.isNetworkAvailable();
        if (!isNetworkAvailable) {
          Utils.showToast("No Internet connection", false);
          return;
        }
        Utils.showProgressDialog(context);
        ApiController.getStoreVersionData(store.banners[position].pageId)
            .then((response) {
          Utils.hideProgressDialog(context);
          Utils.hideKeyboard(context);
          StoreDataModel storeObject = response;
          if (storeObject != null && storeObject.success)
            setState(() {
              _selectedSingleStore = storeObject;
              _previousSelectedHomeScreen = _selectedHomeScreen;
              _selectedHomeScreen = HomeScreenEnum.HOME_SELECTED_STORE_VIEW;
            });
        });
      } else if (store.banners[position].linkTo == "offers") {
        if (store.banners[position].offerId != null &&
            store.banners[position].offerId == "0") {
          print("return");
          return;
        }
        print("----onTap-${store.banners[position].offerId}--");
        bool isNetworkAvailable = await Utils.isNetworkAvailable();
        if (!isNetworkAvailable) {
          Utils.showToast("No Internet connection", false);
          return;
        }
        Utils.showProgressDialog(context);
        ApiController.homeOffersDetails(
                coupon_id: store.banners[position].offerId)
            .then((response) {
          Utils.hideProgressDialog(context);
          Utils.hideKeyboard(context);
          if (response != null &&
              response.success &&
              response.offers.isNotEmpty) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OffersListDetail(response.offers.first),
                ));
          }
        });
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
          elevation: 30.0,
          type: BottomNavigationBarType.fixed,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('images/homeicon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: _selectedHomeScreen != HomeScreenEnum.HOME_BAND_VIEW
                      ? staticHomeDescriptionColor
                      : appThemeSecondary),
              title: Text('Home',
                  style: TextStyle(
                      color:
                          _selectedHomeScreen != HomeScreenEnum.HOME_BAND_VIEW
                              ? staticHomeDescriptionColor
                              : appThemeSecondary)),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/unselectedexploreicon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: staticHomeDescriptionColor),
              title: Text('Search',
                  style: TextStyle(color: staticHomeDescriptionColor)),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/offericon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: staticHomeDescriptionColor),
              title: Text('Offers',
                  style: TextStyle(color: staticHomeDescriptionColor)),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('images/unselectedmyordericon.png',
                  width: 24,
                  fit: BoxFit.scaleDown,
                  color: staticHomeDescriptionColor),
              title: Text(Platform.isIOS ? 'Orders' : 'My Orders',
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
      DialogUtils.displayCommonDialog(
          context, store.name, /*store.storeMsg*/ "Store Closed");
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
        if (_currentIndex == 1) {
//          if (AppConstant.isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SearchScreen(widget.initialPosition, <Object>({value}) {
                      setState(() {
                        if (value == null) {
                          Utils.showToast('No Data found', false);
                          return;
                        }
                        if (value is StoreDataModel) {
                          Navigator.pop(context);
                          _selectedSingleStore = value;
                          if (_selectedHomeScreen ==
                              HomeScreenEnum.HOME_SELECTED_STORE_VIEW) {
                            setState(() {
                              _selectedHomeScreen =
                                  HomeScreenEnum.HOME_BAND_VIEW;
                            });
                            Future.delayed(const Duration(seconds: 1), () {
                              setState(() {
                                _previousSelectedHomeScreen =
                                    _selectedHomeScreen;
                                _selectedHomeScreen =
                                    HomeScreenEnum.HOME_SELECTED_STORE_VIEW;
                              });
                            });
                          } else {
                            setState(() {
                              _selectedSingleStore = value;
                              _previousSelectedHomeScreen = _selectedHomeScreen;
                              _selectedHomeScreen =
                                  HomeScreenEnum.HOME_SELECTED_STORE_VIEW;
                            });
                          }
                          return;
                        }
                        if (value is StoresModel) {
                          setState(() {
                            allStoreData = value;
                            _previousSelectedHomeScreen = _selectedHomeScreen;
                            _selectedHomeScreen =
                                HomeScreenEnum.HOME_RESTAURANT_VIEW;
                          });
                          return;
                        }
                      });
                      return;
                    }, widget.brandData)),
          );
//          } else {
//            Utils.showLoginDialog(context);
//          }
          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "SearchScreen";
          Utils.sendAnalyticsEvent("Clicked SearchScreen", attributeMap);
        }
        if (_currentIndex == 3) {
          if (AppConstant.isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyOrderScreenVersion2(store)),
            );
            Map<String, dynamic> attributeMap = new Map<String, dynamic>();
            attributeMap["ScreenName"] = "MyOrderScreen";
            Utils.sendAnalyticsEvent("Clicked MyOrderScreen", attributeMap);
          } else {
            Utils.showLoginDialog(context);
          }
        }
        if (_currentIndex == 2) {
//          if (AppConstant.isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OffersListScreenScreen()),
          );
          Map<String, dynamic> attributeMap = new Map<String, dynamic>();
          attributeMap["ScreenName"] = "OffersListScreen";
          Utils.sendAnalyticsEvent("Clicked OffersListScreen", attributeMap);
//          } else {
//            Utils.showLoginDialog(context);
//          }
        }
//        if (_currentIndex == 1) {
//          setState(() {
//            _controller.text = '';
//            isCategoryViewSelected = true;
//          });
//        }
        if (_currentIndex == 0) {
          //show categories
          setState(() {
            _controller.text = '';
            _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
          });
        }
      });
    }
  }

  _handleDrawer() async {
    try {
      if (checkIfStoreClosed()) {
        DialogUtils.displayCommonDialog(
            context, store.name, /*store.storeMsg*/ "Store Closed");
      } else {
        _key.currentState.openDrawer();
        if (AppConstant.isLoggedIn) {
          user = await SharedPrefs.getUser();
          if (user != null) setState(() {});
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
        style: AndroidNotificationStyle.BigText,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
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
      return false;
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
    ApiController.categoriesApiRequest().then((response) {
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

  void _getTagApi() {
    ApiController.tagsApiRequest().then((tagsResponse) {
      setState(() {
        this.tagsModel = tagsResponse;
      });
    });
  }

  void _getStoreApi() async {
    //----------------------------------------------
    ApiController.storesApiRequest(widget.initialPosition)
        .then((storesResponse) {
      setState(() {
        this.storeData = storesResponse;
      });
    });
  }

  void _getBannersApi({String city = ""}) {
    ApiController.getBannersApi(city).then((bannerResponse) {
      setState(() {
        if (bannerResponse != null && bannerResponse.success) {
          imgList.clear();
          for (var i = 0; i < bannerResponse.data.banners.length; i++) {
            String imageUrl = bannerResponse.data.banners[i].image;
            imgList.add(
              NetworkImage(imageUrl.isEmpty
                  ? AppConstant.placeholderImageUrl
                  : imageUrl),
            );
          }
        }
      });
    });
  }

  Future logout(BuildContext context, BranchData selectedStore) async {}

  getAddressFromLocation() async {
    if (widget.initialPosition != null) {
      print("--widget.initialPosition != null----");
      Coordinates coordinates = new Coordinates(
          widget.initialPosition.latitude, widget.initialPosition.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      //print("--addresses-${addresses} and ${first}");
      print(
          "---getAddressFromLocation-------${first.featureName} and ${first.addressLine}-postalCode-${first.postalCode}------");
      setState(() {
//        locationAddress =  first.addressLine;
        locationAddress =
            '${first.subLocality != null ? first.subLocality : ''}${first.locality != null ? ', ' + first.locality : ''}${first.subAdminArea != null ? ', ' + first.subAdminArea : ''}${first.adminArea != null ? ', ' + first.adminArea : ''}';
        if (locationAddress.length > 0)
          locationAddress = locationAddress[0] == ','
              ? locationAddress.replaceFirst(',', '')
              : locationAddress;
      });
    } else {
      print(
          "-else-widget.initialPosition != null----${widget.initialPosition}");
    }
  }

  void showBottomSheet(
      context, LatLng center, LatLng selectedLocation, String address) {
    LatLng localCenter, localSelectedLocation;
    GoogleMapController _mapController;
    localCenter = center;
    localSelectedLocation = selectedLocation;
    Set<Marker> markers = Set();
    String localAddress = address;
    var firstAddress;
    getAddressFromLocationFromMap(double latitude, double longitude,
        {StateSetter setState}) async {
      try {
        localCenter = LatLng(latitude, longitude);
        localSelectedLocation = LatLng(latitude, longitude);
        Coordinates coordinates = new Coordinates(latitude, longitude);
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        firstAddress = addresses.first;
//        localAddress = first.addressLine;

        localAddress =
            '${firstAddress.subLocality != null ? firstAddress.subLocality : ''}${firstAddress.locality != null ? ', ' + firstAddress.locality : ''}${firstAddress.subAdminArea != null ? ', ' + firstAddress.subAdminArea : ''}${firstAddress.adminArea != null ? ', ' + firstAddress.adminArea : ''}';
        if (setState != null)
          setState(() {
//            localAddress = first.addressLine;
            localAddress =
                '${firstAddress.subLocality != null ? firstAddress.subLocality : ''}${firstAddress.locality != null ? ', ' + firstAddress.locality : ''}${firstAddress.subAdminArea != null ? ', ' + firstAddress.subAdminArea : ''}${firstAddress.adminArea != null ? ', ' + firstAddress.adminArea : ''}';
            if (localAddress.length > 0)
              localAddress = localAddress[0] == ','
                  ? localAddress.replaceFirst(',', '')
                  : localAddress;
          });
      } catch (e) {
        print(e);
        address = "No address found!";
      }
    }

    markers.addAll([
      Marker(
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          markerId: MarkerId('value'),
          position: localCenter,
          onDragEnd: (value) {
            getAddressFromLocationFromMap(value.latitude, value.longitude);
          })
    ]);
    getAddressFromLocationFromMap(localCenter.latitude, localCenter.longitude);
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Wrap(children: <Widget>[
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                          child: Icon(
                            Icons.cancel,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                      child: Text(
                        'Set Location',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.all(20),
                        //padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            color: searchGrayColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            border: Border.all(
                              color: searchGrayColor,
                            )),
                        child: InkWell(
                            onTap: () async {
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return CustomSearchScaffold();
                                    },
                                    fullscreenDialog: true,
                                  ));
                              if (result != null) {
                                LatLng detail = result;
                                double lat = detail.latitude;
                                double lng = detail.longitude;
                                print("location = ${lat},${lng}");

                                localCenter = LatLng(lat, lng);
                                localSelectedLocation = LatLng(lat, lng);
                                getAddressFromLocationFromMap(lat, lng,
                                    setState: setState);
                                markers.clear();
                                markers.addAll([
                                  Marker(
                                      draggable: true,
                                      icon: BitmapDescriptor.defaultMarker,
                                      markerId: MarkerId('value'),
                                      position: localCenter,
                                      onDragEnd: (value) {
                                        getAddressFromLocationFromMap(
                                            value.latitude, value.longitude,
                                            setState: setState);
                                      })
                                ]);
                                setState(() {
                                  _mapController.moveCamera(
                                      CameraUpdate.newLatLng(localCenter));
                                });
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(3, 3, 10, 3),
                                          child: Image.asset(
                                              'images/searchicon.png',
                                              width: 20,
                                              fit: BoxFit.scaleDown,
                                              color: appTheme)),
                                      Expanded(
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          text: TextSpan(
                                            text: "${localAddress}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      )
                                    ]),
                              ),
                            ))),
                    Container(
                        height: Utils.getDeviceHeight(context) >
                                Utils.getDeviceWidth(context)
                            ? Utils.getDeviceWidth(context) - 50
                            : Utils.getDeviceHeight(context) / 2 - 50,
                        margin:
                            EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: localCenter,
                            zoom: 15.0,
                          ),
                          mapType: MapType.normal,
                          markers: markers,
                          onTap: (latLng) {
                            if (markers.length >= 1) {
                              markers.clear();
                            }
                            setState(() {
                              markers.add(Marker(
                                  draggable: true,
                                  icon: BitmapDescriptor.defaultMarker,
                                  markerId: MarkerId('value'),
                                  position: latLng,
                                  onDragEnd: (value) {
                                    print(value.latitude);
                                    print(value.longitude);
                                    getAddressFromLocationFromMap(
                                        value.latitude, value.longitude,
                                        setState: setState);
                                  }));
                              getAddressFromLocationFromMap(
                                  latLng.latitude, latLng.longitude,
                                  setState: setState);
                            });
                          },
                          onCameraMove: (CameraPosition position) {
                            CameraPosition newPos =
                                CameraPosition(target: position.target);
                            Marker marker = markers.first;

                            setState(() {
                              markers.first
                                  .copyWith(positionParam: newPos.target);
                            });
                          },
                          //onCameraMove: _onCameraMove,
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: ButtonTheme(
                        minWidth: 180.0,
                        height: 40.0,
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              side: BorderSide(color: appTheme)),
                          onPressed: () async {
                            widget.initialPosition = localSelectedLocation;
                            locationAddress = localAddress;
                            eventBus.fire(
                                onLocationChanged(widget.initialPosition));
                            Navigator.pop(context);

                            // banners api
                            _getBannersApi(
                                city: (firstAddress != null &&
                                        firstAddress.subAdminArea != null &&
                                        firstAddress.subAdminArea.isNotEmpty)
                                    ? firstAddress.subAdminArea
                                    : "");
                            //ReloadApi
                            _getStoreApi();
                          },
                          color: appTheme,
                          padding: EdgeInsets.all(5.0),
                          textColor: Colors.white,
                          child: Text("Submit"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              )
            ]);
          });
        });
  }

  Widget getAppBar() {
    bool rightActionsEnable = false,
        whatIconEnable = false,
        dialIconEnable = false;

    return AppBar(
      titleSpacing: 0,
      title: widget.configObject.isMultiStore == false
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    if (widget.initialPosition != null &&
                        locationAddress != getLocationSearchPlaceHolderText()) {
                      showBottomSheet(context, widget.initialPosition,
                          widget.initialPosition, locationAddress);
                      return;
                    }

                    await getCurrentLocation();
                  },
                  child: Visibility(
                    visible:
                        _selectedHomeScreen == HomeScreenEnum.HOME_BAND_VIEW,
                    child: Row(
                      children: [
                        SizedBox(
                          width: (Utils.getDeviceWidth(context) / 2.2),
                          child: Text(
                            "${locationAddress}",
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
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
      leading: _getAppBarLeftIcon(),
      actions: <Widget>[
        Visibility(
//            visible: AppConstant.isLoggedIn,
            visible: false,
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
      clipBehavior: Clip.antiAlias,
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
          padding: EdgeInsets.only(
              top:
                  _selectedHomeScreen == HomeScreenEnum.HOME_SELECTED_STORE_VIEW
                      ? 0
                      : 10),
          child: _getCurrentBody(),
        ),
//        _getStoreView(),
      ],
    );
  }

  Widget _getStoreView() {
    if (_selectedHomeScreen == HomeScreenEnum.HOME_SELECTED_STORE_VIEW)
      return Padding(
        padding: EdgeInsets.only(top: 0),
        child: StoreDashboardScreen(_selectedSingleStore, widget.brandData),
      );
    else
      return Container();
  }

  Widget _addSearchView() {
    return Visibility(
      visible: (homeViewOrderMap.length == 0) ||
          (homeViewOrderMap[HomeScreenViewHelper.SEARCH] != null &&
              homeViewOrderMap[HomeScreenViewHelper.SEARCH].display),
      child: Container(
        height: 40,
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                  Padding(
                      padding: EdgeInsets.fromLTRB(3, 3, 6, 3),
                      child: Image.asset('images/searchicon.png',
                          width: 20, fit: BoxFit.scaleDown, color: appTheme)),
                  Flexible(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) async {
                        if (value.trim().isEmpty) {
                          Utils.showToast(
                              "Please enter some valid keyword", false);
                        } else {
                          Map<String, dynamic> data = {
                            "lat": widget.initialPosition.latitude,
                            "lng": widget.initialPosition.longitude,
                            "search_by": "Keyword",
                            "keyword": "${value.trim()}",
                          };
                          Utils.showProgressDialog(context);
                          ApiController.getAllStores(params: data)
                              .then((storesResponse) {
                            Utils.hideProgressDialog(context);
                            Utils.hideKeyboard(context);
                            if (storesResponse != null) {
                              if (!storesResponse.success &&
                                  storesResponse.dishes != null &&
                                  storesResponse.dishes.isEmpty) {
                                Utils.showToast("No results Found", false);
                                return;
                              }
                              allStoreData = storesResponse;
                              setState(() {
                                _selectedHomeScreen =
                                    HomeScreenEnum.HOME_SEARCH_VIEW;
                              });
                              eventBus.fire(onHomeSearch(allStoreData));
                            }
                          });
                          //callSearchAPI();
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
                          hintText: getSearchPlaceHolderText()),
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
                            _clearSearchResult();
                          }))
                ]),
          ),
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

  void scrollTop() {
    controller.animateTo(0,
        curve: Curves.linear, duration: Duration(milliseconds: 100));
  }

  Widget _getCurrentBody() {
    switch (_selectedHomeScreen) {
      case HomeScreenEnum.HOME_BAND_CATEGORIES_VIEW:
      case HomeScreenEnum.HOME_RESTAURANT_VIEW:
        return _getRestaurantList();
        break;
      case HomeScreenEnum.HOME_SELECTED_STORE_VIEW:
        return StoreDashboardScreen(_selectedSingleStore, widget.brandData);
        break;
      case HomeScreenEnum.HOME_SEARCH_VIEW:
      case HomeScreenEnum.HOME_BAND_VIEW:
      default:
        return Column(
          children: [
            SizedBox(
              height: 10,
            ),
            _getMiddleView()
          ],
        );
    }
  }

  Widget _getRestaurantList() {
    return RestroListScreen(
      allStoreData,
      widget.brandData,
      initialPosition: widget.initialPosition,
      tagsModel: tagsModel,
      selectedScreen: _selectedHomeScreen,
      callback: <Object>({value}) {
        setState(() {
          if (value == null) {
            Utils.showToast('No Data found', false);
            return;
          }
          if (value is StoreDataModel) {
            setState(() {
              _selectedSingleStore = value;
              _previousSelectedHomeScreen = _selectedHomeScreen;
              _selectedHomeScreen = HomeScreenEnum.HOME_SELECTED_STORE_VIEW;
            });
            return;
          }

          if (value is StoresModel) {
            setState(() {
              allStoreData = value;
              _previousSelectedHomeScreen = _selectedHomeScreen;
              _selectedHomeScreen = HomeScreenEnum.HOME_RESTAURANT_VIEW;
            });
            return;
          }
        });
        return;
      },
      homeViewOrderMap: homeViewOrderMap,
    );
  }

  Widget _getSearchList({String searchKeyword = ''}) {
    return HomeSearchView(
      allStoreData,
      widget.brandData,
      initialPosition: widget.initialPosition,
      tagsModel: tagsModel,
      selectedScreen: _selectedHomeScreen,
      searchKeyword: searchKeyword,
      dishCallBack: <Object>({value}) {
        if (value is Dish) {
//          Dish item = value;
//          Navigator.push(
//              context,
//              new MaterialPageRoute(
//                builder: (BuildContext context) => ProductDetailsScreen(
//                    null, null,
//                    productID: item.id, storeId: item.storeId),
//                fullscreenDialog: true,
//              ));
          return;
        }
        return;
      },
      callback: <Object>({value}) {
        setState(() {
          if (value == null) {
            Utils.showToast('No Data found', false);
            return;
          }
          if (value is StoreDataModel) {
            setState(() {
              _selectedSingleStore = value;
              _previousSelectedHomeScreen = _selectedHomeScreen;
              _selectedHomeScreen = HomeScreenEnum.HOME_SELECTED_STORE_VIEW;
            });
            return;
          }
          if (value is StoresModel) {
            setState(() {
              allStoreData = value;
              _previousSelectedHomeScreen = _selectedHomeScreen;
              _selectedHomeScreen = HomeScreenEnum.HOME_RESTAURANT_VIEW;
            });
            return;
          }
        });
        return;
      },
    );
    ;
  }

  _getViewCallBack() {
    return <Object>({value}) {
      setState(() {
        if (value == null) {
          Utils.showToast('No Data found', false);
          return;
        }
        if (value is StoreDataModel) {
          setState(() {
            _selectedSingleStore = value;
            _previousSelectedHomeScreen = _selectedHomeScreen;
            _selectedHomeScreen = HomeScreenEnum.HOME_SELECTED_STORE_VIEW;
          });
          return;
        }

        if (value is StoresModel) {
          setState(() {
            allStoreData = value;
            _previousSelectedHomeScreen = _selectedHomeScreen;
            _selectedHomeScreen = HomeScreenEnum.HOME_RESTAURANT_VIEW;
          });
          return;
        }
      });
      return;
    };
  }

  List<Widget> _getWidgetList() {
    return isLoading
        ? <Widget>[
//            _addSearchView(),
//            addBanners(),
            Center(child: CircularProgressIndicator())
          ]
        : _makeHomeScreenList();
  }

  Widget _getMiddleView() {
    return (_selectedHomeScreen == HomeScreenEnum.HOME_SEARCH_VIEW)
        ? Expanded(
            child: Column(
            children: [
              _addSearchView(),
              Expanded(child: _getSearchList(searchKeyword: _controller.text)),
            ],
          ))
        : Expanded(
            child: SingleChildScrollView(
            controller: controller,
            child: Column(
                mainAxisSize: MainAxisSize.max, children: _getWidgetList()),
          ));
  }

  _getAppBarLeftIcon() {
    switch (_selectedHomeScreen) {
      case HomeScreenEnum.HOME_RESTAURANT_VIEW:
        return IconButton(
          icon: Icon(Icons.keyboard_arrow_left, size: 35),
          onPressed: () {
            setState(() {
              _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
            });
          },
        );
        break;
      case HomeScreenEnum.HOME_BAND_CATEGORIES_VIEW:
      case HomeScreenEnum.HOME_SELECTED_STORE_VIEW:
        return IconButton(
          icon: Icon(Icons.keyboard_arrow_left, size: 35),
          onPressed: () {
            setState(() {
              if (_selectedHomeScreen == HomeScreenEnum.HOME_BAND_VIEW) {
                _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
              } else {
                _selectedHomeScreen = _previousSelectedHomeScreen;
              }
            });
          },
        );
        break;
      case HomeScreenEnum.HOME_SEARCH_VIEW:
      case HomeScreenEnum.HOME_BAND_VIEW:
      default:
        return IconButton(
          icon: Image.asset('images/menuicon.png', width: 25),
          onPressed: _handleDrawer,
        );
        break;
    }
  }

  void _clearSearchResult() {
    FocusScope.of(context).unfocus();
    setState(() {
      _controller.text = "";
      _selectedHomeScreen = HomeScreenEnum.HOME_BAND_VIEW;
    });
  }

  Future<void> getCurrentLocation() async {
    print("AppBar onTap");
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if (!isNetworkAvailable) {
      Utils.showToast("No Internet connection", false);
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
        var result = await DialogUtils.displayDialog(
            context,
            "Location Permission Required",
            "Please enable location permissions in settings.",
            "Cancel",
            "Ok");
        if (result == true) {
          permission_handler.openAppSettings();
        }
        return;
      }
    }
    if (Platform.isAndroid) {
      await location.changeSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        interval: 1000,
      );
    }
    _locationData = await location.getLocation();
    _initialPosition = LatLng(_locationData.latitude, _locationData.longitude);
    if (_initialPosition != null) {
      Coordinates coordinates = new Coordinates(
          _initialPosition.latitude, _initialPosition.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      //print("--addresses-${addresses} and ${first}");
      print(
          "----------${first.featureName} and ${first.addressLine}-postalCode-${first.postalCode}------");
      setState(() {
//        locationAddress = first.addressLine;
        locationAddress =
            '${first.subLocality != null ? first.subLocality : ''}${first.locality != null ? ', ' + first.locality : ''}${first.subAdminArea != null ? ', ' + first.subAdminArea : ''}${first.adminArea != null ? ', ' + first.adminArea : ''}';
        if (locationAddress.length > 0)
          locationAddress = locationAddress[0] == ','
              ? locationAddress.replaceFirst(',', '')
              : locationAddress;
        //banners reload
        _getBannersApi(city: getCity(first));
        //ReloadApi
        _getStoreApi();
      });
    }
  }

  String getCity(Address address) {
    return '${(address.subAdminArea != null && address.subAdminArea.isNotEmpty) ? address.subAdminArea : ""}' +
        ',${(address.adminArea != null && address.adminArea.isNotEmpty) ? address.adminArea : ""}';
  }

  void _getContentApi() {
    ApiController.getDynamicText().then((value) {
      if (value != null && value.success) {
        AppConstant.dynamicResponse = value;
      }
      setState(() {});
    });
  }

  //1,5,4,2,10,3,0,19
  //iteration 7n
  //stack- 0,1,2,3,4,5,10,19
  //tempList
  void _homeScreenItemsort(HomeScreenSection item) {
    if (homeScreenStack.length == 0) {
      homeScreenStack.push(item);
    } else {
      List<HomeScreenSection> tempList = List.empty(growable: true);
      for (int i = 0; i < homeScreenStack.length; i++) {
        if (int.parse(homeScreenStack.peak().position) >
            int.parse(item.position)) {
          tempList.add(homeScreenStack.pop());
        }
      }
      homeScreenStack.push(item);
      for (int j = tempList.length - 1; j >= 0; j--) {
        homeScreenStack.push(tempList[j]);
      }
      tempList.clear();
    }
  }

  List<Widget> _makeHomeScreenList() {
    List<Widget> homeScreenList = List.empty(growable: true);
    List<HomeScreenSection> sectionsList =
        homeScreenStack.stack.toList(growable: true);
    for (int i = 0; i < sectionsList.length; i++) {
      HomeScreenSection item = sectionsList[i];
      switch (item.section) {
        case HomeScreenViewHelper.SEARCH:
          homeScreenList.add(_addSearchView());
          break;
        case HomeScreenViewHelper.SLIDER:
          homeScreenList.add(addBanners());
          break;
        case HomeScreenViewHelper.CATEGORIES:
          homeScreenList.add(MarketPlaceHomeCategoryView(
              categoriesModel,
              widget.initialPosition,
              /*categoryResponse,*/
              store,
              subCategory,
              storeData: storeData,
              tagsModel: tagsModel,
              callback: _getViewCallBack(),
              homeViewOrderMap: homeViewOrderMap));

          break;
        case HomeScreenViewHelper.FILTER:
          homeScreenList.add(MarketPlaceHomeFiltersView(widget.initialPosition,
              callback: _getViewCallBack(),
              homeViewOrderMap: homeViewOrderMap));
          break;
        case HomeScreenViewHelper.TAGS:
          homeScreenList.add(MarketPlaceHomeTagsView(widget.initialPosition,
              tagsModel: tagsModel,
              callback: _getViewCallBack(),
              homeViewOrderMap: homeViewOrderMap));
          break;
        case HomeScreenViewHelper.STORES:
          homeScreenList.add(MarketPlaceHomeStoresView(
              widget.initialPosition, store,
              storeData: storeData,
              tagsModel: tagsModel,
              callback: _getViewCallBack(),
              homeViewOrderMap: homeViewOrderMap));
          break;
      }
    }
    return homeScreenList;
  }

  void _getSubscriptionPlan() {
    ApiController.getSubscriptionMembershipPlan().then((value) {
      if (value != null && value.success) {
        //Setting Subscription plan to globally (Singleton)
        SingletonBrandData.getInstance().membershipPlanResponse = value;
        //fetching user Subscribed plan
        if (AppConstant.isLoggedIn) ApiController.getUserMembershipPlanApi();
      }
    });
  }
}

class HomeScreenViewHelper {
  static const SEARCH = "search";
  static const SLIDER = "slider";
  static const CATEGORIES = "categories";
  static const FILTER = "filter";
  static const TAGS = "tags";
  static const STORES = "stores";
}
