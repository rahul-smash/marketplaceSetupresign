import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/Screens/Dashboard/ContactScreen.dart';
import 'package:restroapp/src/Screens/BookOrder/MyCartScreen.dart';
import 'package:restroapp/src/Screens/Notification/NotificationScreen.dart';
import 'package:restroapp/src/Screens/Dashboard/HomeSearchView.dart';
import 'package:restroapp/src/Screens/Notification/NotificationScreen.dart';
import 'package:restroapp/src/Screens/Offers/MyOrderScreen.dart';
import 'package:restroapp/src/Screens/Offers/MyOrderScreenVersion2.dart';
import 'package:restroapp/src/Screens/SideMenu/SideMenu.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/ConfigModel.dart';
import 'package:restroapp/src/models/StoreBranchesModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ForceUpdate.dart';
import 'HomeCategoryListView.dart';
import 'SearchScreen.dart';
import 'dart:io';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';

class StoreDashboardScreen extends StatefulWidget {
  //final StoreModel store;
  final StoreDataObj store;

  StoreDashboardScreen(this.store);

  @override
  State<StatefulWidget> createState() {
    return _StoreDashboardScreenState(this.store);
  }
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> {
  //StoreModel store;
  StoreDataObj store;
  List<NetworkImage> imgList = [];
  int _currentIndex = 0;
  UserModel user;
  bool isStoreClosed;
  final DatabaseHelper databaseHelper = new DatabaseHelper();
  bool isLoading;
  int _current = 0;

  _StoreDashboardScreenState(this.store);

  @override
  void initState() {
    super.initState();
    isStoreClosed = false;
    initFirebase();
    _setSetCurrentScreen();
    getCartCount();
    listenCartChanges();
    checkForMultiStore();
    getCategoryApi();
    listenEvent();
    try {
      AppConstant.placeholderUrl = store.banner10080;
      //print("-----store.banners-----${store.banners.length}------");
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
    } catch (e) {
      print(e);
    }
  }

  void listenEvent() {

  }

  @override
  Widget build(BuildContext context) {
    return this.keyboardDismisser(
        context: context,
        child: WillPopScope(
          child: Container(child: _newBody(),
          ),
          onWillPop: () {
            return new Future(() => true);
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

  void _onBannerTap(position) {
    print("onImageTap ${position}");
    print("linkTo=${store.banners[position].linkTo}");

//    if (store.banners[position].linkTo.isNotEmpty) {
//      if (store.banners[position].linkTo == "category") {
//        if (store.banners[position].categoryId == "0" &&
//            store.banners[position].subCategoryId == "0" &&
//            store.banners[position].productId == "0") {
//          print("return");
//          return;
//        }
//
//        if (store.banners[position].categoryId != "0" &&
//            store.banners[position].subCategoryId != "0" &&
//            store.banners[position].productId != "0") {
//          // here we have to open the product detail
//          print("open the product detail ${position}");
//        } else if (store.banners[position].categoryId != "0" &&
//            store.banners[position].subCategoryId != "0" &&
//            store.banners[position].productId == "0") {
//          //here open the banner sub category
//          print("open the subCategory ${position}");
//
//          for (int i = 0; i < categoryResponse.categories.length; i++) {
//            CategoryModel categories = categoryResponse.categories[i];
//            if (store.banners[position].categoryId == categories.id) {
//              print(
//                  "title ${categories.title} and ${categories.id} and ${store.banners[position].categoryId}");
//              if (categories.subCategory != null) {
//                for (int j = 0; j < categories.subCategory.length; j++) {
//                  SubCategory subCategory = categories.subCategory[j];
//
//                  if (subCategory.id == store.banners[position].subCategoryId) {
//                    print(
//                        "open the subCategory ${subCategory.title} and ${subCategory.id} = ${store.banners[position].subCategoryId}");
//
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(builder: (context) {
//                        return SubCategoryProductScreen(categories, true, j);
//                      }),
//                    );
//
//                    break;
//                  }
//                }
//              }
//            }
//            //print("Category ${categories.id} = ${categories.title} = ${categories.subCategory.length}");
//          }
//        } else if (store.banners[position].categoryId != "0" &&
//            store.banners[position].subCategoryId == "0" &&
//            store.banners[position].productId == "0") {
//          print("open the Category ${position}");
//
//          for (int i = 0; i < categoryResponse.categories.length; i++) {
//            CategoryModel categories = categoryResponse.categories[i];
//            if (store.banners[position].categoryId == categories.id) {
//              print(
//                  "title ${categories.title} and ${categories.id} and ${store.banners[position].categoryId}");
//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) {
//                  return SubCategoryProductScreen(categories, true, 0);
//                }),
//              );
//              break;
//            }
//          }
//        }
//      }
//    }
  }


  bool checkIfStoreClosed() {
    if (store.storeStatus == "0") {
      //0 mean Store close
      return true;
    } else {
      return false;
    }
  }

  void getCategoryApi() {
    isLoading = true;
    ApiController.getCategoriesApiRequest(store.id).then((response) {
      setState(() {
        isLoading = false;
        this.categoryResponse = response;
        getHomeCategoryProductApi();
      });
    });
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

    if (store.homePageDisplayNumberType != null &&
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
    }

    return AppBar(
      title: widget.configObject.isMultiStore == false
          ? Column(
        children: <Widget>[
          Visibility(
            visible: store.homePageTitleStatus,
            child: Text(
              store.homePageTitle != null
                  ? store.homePageTitle
                  : store.storeName,
            ),
          ),
          Visibility(
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
          )
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
      centerTitle: widget.configObject.isMultiStore == true ? false : true,
      leading: new IconButton(
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
                  FlutterOpenWhatsapp.sendSingleMessage(
                      store.homePageDisplayNumber, "");
                },
              )),
        ),
        Visibility(
            visible: rightActionsEnable && dialIconEnable,
            child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    _launchCaller(store.homePageDisplayNumber);
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
          padding: EdgeInsets.only(top: 60),
          child: _getCurrentBody(),
        ),
        _addSearchView(),
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
                        hintText: "Search for dishes"),
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

  Widget _getCurrentBody() {
    if (productsList.length > 0) {
      return HomeSearchView(productsList);
    } else {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            addBanners(),
            Visibility(
                visible: imgList.length > 1,
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
                : categoryResponse == null
                ? Center(child: Text(""))
                : !isCategoryViewSelected
                ? /*HomeCategoryListView(
                            categoryResponse,
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
                          )*/Container()
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
                                children: categoryResponse.categories
                                    .map((CategoryModel model) {
                                  return GridTile(
                                      child:
                                          CategoryView(model, store, false, 0));
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
