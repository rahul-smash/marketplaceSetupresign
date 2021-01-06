import 'dart:collection';
import 'package:flutter/painting.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class StoreDashboardScreen extends StatefulWidget {
  final StoreDataModel store;

  StoreDashboardScreen(this.store);

  @override
  State<StatefulWidget> createState() {
    return _StoreDashboardScreenState(this.store.store);
  }
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> {
  StoreDataObj store;
  List<NetworkImage> imgList = [];
  UserModel user;
  bool isStoreClosed;
  final DatabaseHelper databaseHelper = new DatabaseHelper();
  bool isLoading = true;

  CategoryResponse categoryResponse;

  CategoryModel selectedCategory;

  String selectedSubCategoryId;

  SubCategoryResponse subCategoryResponse;

  _StoreDashboardScreenState(this.store);

  List<dynamic> products = List();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    isStoreClosed = false;
    getCategoryApi();
    listenEvent();
    try {
      AppConstant.placeholderUrl = store.banner300200;
      if (store.banner300200.isNotEmpty) {
        imgList = [NetworkImage(store.banner300200)];
      } else {
        for (var i = 0; i < store.banners.length; i++) {
          String imageUrl = store.banners[i].image;
//          imgList.add(
//            NetworkImage(
//                imageUrl.isEmpty ? AppConstant.placeholderImageUrl : imageUrl),
//          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void listenEvent() {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Container(
        child: _newBody(),
      ),
      onWillPop: () {
        return new Future(() => true);
      },
    );
  }

  Widget _newBody() {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          color: Colors.white,
        ),
        Padding(
          padding: EdgeInsets.only(top: 0),
          child: _getCurrentBody(),
        ),
        Positioned.fill(
            child: Visibility(
          visible: subCategoryResponse != null &&
              subCategoryResponse.subCategories.isNotEmpty,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () async {
                  //print("--onTap---${products.length}");
                  var result = await DialogUtils.displayMenuAlert(
                      context, "Menu", subCategoryResponse.subCategories);
                  if (result != null) {
                    SubCategoryModel object = result;
                    /*print("--selected---${object.id} and ${object.title}");
                      print("Index=${subCathashMap['${object.id}']}");
                      print("subCathashMap=${subCathashMap.toString()}");*/
                    await _scrollControllers.scrollTo(
                        index: int.parse(subCathashMap['${object.id}']),
                        duration: Duration(milliseconds: 400));
                  }
                },
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(bottom: 10),
                  height: 50,
                  decoration: BoxDecoration(
                      color: appTheme,
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          child: Image.asset(
                            'images/restauranticon.png',
                            width: 25,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
                          child: Text(
                            "Menu",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ))
      ],
    );
  }

  Widget _getCurrentBody() {
    return NotificationListener(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final before = scrollNotification.metrics.extentBefore;
          final max = scrollNotification.metrics.maxScrollExtent;
          if (before == max) {
            print("--------load next page-------");
            // load next page
            // code here will be called only if scrolled to the very bottom
          }
        }
        /*if (scrollNotification is ScrollStartNotification) {
          print("scroll");
          print("detail:"+scrollNotification.dragDetails.toString());
          /// your code
        }*/
        return false;
        /*if (scrollNotification is ScrollStartNotification) {
          _onStartScroll(scrollNotification.metrics);
        } else if (scrollNotification is ScrollUpdateNotification) {
          _onUpdateScroll(scrollNotification.metrics);
        } else if (scrollNotification is ScrollEndNotification) {
          _onEndScroll(scrollNotification.metrics);
        }*/
      },
      child: getProductsWidget(),
    );
  }

  bool showBrowseMenuButton = true;

  _onStartScroll(ScrollMetrics metrics) {
    print("--------Scroll Start--------");
  }

  _onUpdateScroll(ScrollMetrics metrics) {
    //print("--------Scroll Update--------");
  }

  _onEndScroll(ScrollMetrics metrics) {
    print("--------Scroll End--------");
  }

  Widget addBanners() {
    return Stack(
      children: <Widget>[
        imgList.isNotEmpty?
        Center(
          child: SizedBox(
            height: 150.0,
            width: Utils.getDeviceWidth(context),
            child: Carousel(
              boxFit: BoxFit.cover,
              autoplay: true,
              animationCurve: Curves.ease,
              autoplayDuration: Duration(milliseconds: 5000),
              animationDuration: Duration(milliseconds: 3000),
              dotSize: 6.0,
              dotIncreasedColor: dotIncreasedColor,
              dotBgColor: Colors.transparent,
              dotPosition: DotPosition.bottomCenter,
              dotVerticalPadding: 10.0,
              showIndicator: imgList.length == 1 ? false : true,
              indicatorBgPadding: 7.0,
              images: imgList,
              onImageTap: (position) {},
            ),
          ),
        ):Container(
          height: 150.0,
          width: Utils.getDeviceWidth(context),
        ),
        Container(
          margin: EdgeInsets.only(top: 80),
          width: Utils.getDeviceWidth(context),
          height: 70,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black45],
          )),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  store.storeName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )),
              Visibility(
                  visible: store.rating.isNotEmpty &&
                      store.rating != '0.0' &&
                      store.rating != '0',
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: appThemeSecondary,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: Image.asset('images/staricon.png',
                                    width: 15,
                                    fit: BoxFit.scaleDown,
                                    color: Colors.white),
                              )),
                          Text(
                            store.rating,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ))),
            ],
          ),
        )
      ],
    );
  }

  void getCategoryApi() {
    isLoading = true;
    ApiController.getCategoriesApiRequest(store.id).then((response) {
      setState(() {
        isLoading = false;
        this.categoryResponse = response;
        if (categoryResponse == null) {
          return;
        }
        getHomeCategoryProductApi();
      });
    });
  }

  ItemScrollController _scrollControllers = ItemScrollController();

  Widget getProductsWidget() {
//    if (categoryResponse == null) {
//      return Container();
//    }
//    if ((categoryResponse.categories != null &&
//        categoryResponse.categories.length == 0)) {
//      return Utils.getEmptyView2("No Categories available");
//    }

    if (products.length == 0) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
              backgroundColor: Colors.black26,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
        ),
      );
    } else {
      //print("products.length= ${subCategory.products.length}");
      if (products.length == 0) {
        return Utils.getEmptyView2("No Products found!");
      } else {
        return Column(
          children: <Widget>[
            Container(
              height: (Utils.getDeviceHeight(context) / 1.3),
              child: ScrollablePositionedList.builder(
                itemCount: products.length,
                itemScrollController: _scrollControllers,
                itemBuilder: (context, index) {
                  if (products[index] is Product) {
                    Product product = products[index];
                    product.storeName = store.storeName;
                    return Container(
                      child: ProductTileItem(product, () {
                        SharedPrefs.saveStoreData(store);
                      }, ClassType.Home),
                    );
                  } else if (products[index] is SubCategoryModel) {
                    SubCategoryModel subCategory = products[index];
                    return Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, bottom: 5, top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              subCategory.title,
                              style: TextStyle(
                                  color: staticHomeDescriptionColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return products[index];
                  }
                },
              ),
            ),
          ],
        );
      }
    }
  }

  HashMap subCathashMap = new HashMap<String, String>();

  void getHomeCategoryProductApi() {
    subCategoryResponse = null;
    products.clear();
    if (categoryResponse != null &&
        categoryResponse.categories != null &&
        categoryResponse.categories.isNotEmpty) {
      String subCategoryId = categoryResponse.categories.first.id;
      if (selectedCategory == null)
        selectedCategory = categoryResponse.categories.first;

      if (selectedSubCategoryId != null && selectedSubCategoryId.isNotEmpty) {
        subCategoryId = selectedSubCategoryId;
      } else {
        selectedSubCategoryId = subCategoryId;
      }

      products.add(addBanners());
      products.add(categoryResponse != null &&
              categoryResponse.categories.isNotEmpty
          ? Wrap(
              children: [
                Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.only(left: 2.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Categories",
                              style: TextStyle(
                                  color: staticHomeDescriptionColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categoryResponse.categories.map((model) {
                            return CategoryView(
                              model,
                              store,
                              false,
                              0,
                              isListView: true,
                              selectedSubCategoryId: selectedSubCategoryId,
                              callback: <Object>({value}) {
                                setState(() {
                                  selectedCategory = (value as CategoryModel);
                                  selectedSubCategoryId = selectedCategory.id;
                                  getHomeCategoryProductApi();
                                });
                                return;
                              },
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          : categoryResponse != null && categoryResponse.categories.isEmpty
              ? Utils.getEmptyView2('')
              : Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.black26,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black26)),
                  ),
                ));
      products.add(Container(
          height: 5,
          width: MediaQuery.of(context).size.width,
          color: listingBorderColor));

      products.add(Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
              backgroundColor: Colors.black26,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
        ),
      ));
      ApiController.getSubCategoryProducts(subCategoryId, store: store)
          .then((response) {
        if (response != null && response.success) {
          subCategoryResponse = response;
          selectedSubCategoryId = subCategoryId;
          products.removeLast();
          for (int i = 0; i < response.subCategories.length; i++) {
            if (response.subCategories[i].products.isNotEmpty) {
              products.add(response.subCategories[i]);
              products.addAll(response.subCategories[i].products);
            }
          }

          for (int i = 0; i < products.length; i++) {
            if (products[i] is SubCategoryModel) {
              SubCategoryModel subCategory = products[i];
              subCathashMap['${subCategory.id}'] = "${i}";
            }
          }
          setState(() {});
        }
      });
      eventBus.fire(OnProductTileDbRefresh());
    } else {
      products.add(addBanners());
      if (categoryResponse == null) {
        products.add(Container());
      }
      if ((categoryResponse.categories != null &&
          categoryResponse.categories.length == 0)) {
        products.add(Container(margin: EdgeInsets.only(top: 30),
          child: Utils.getEmptyView2("No Categories available"),)
            );
      }
    }
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // it is a good practice to dispose the controller
    super.dispose();
  }
}
