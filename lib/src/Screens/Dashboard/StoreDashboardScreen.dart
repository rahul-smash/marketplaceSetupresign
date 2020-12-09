import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
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
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
  AutoScrollController controller;
  final scrollDirection = Axis.vertical;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    isStoreClosed = false;
    controller = AutoScrollController(
        viewportBoundaryGetter: () {
          return Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom);
        },
        axis: scrollDirection
    );
    getCategoryApi();
    listenEvent();
    try {
      AppConstant.placeholderUrl = store.banner300200;
      if (store.banners.isEmpty) {
        imgList = [NetworkImage(store.banner300200)];
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
    /*try {
      _scrollController.addListener(() {
            double currentScroll = _scrollController.position.pixels;
            //print("------isScrollingNotifier=${_scrollController.position.isScrollingNotifier}");
            //print("------addListener--------${currentScroll}");
            double maxScroll = _scrollController.position.maxScrollExtent;
            double delta = 200.0; // or something else..
            if (maxScroll - currentScroll <= delta) { // whatever you determine here
              //print("------load more--------${currentScroll}");
            }
          });
    } catch (e) {
      print(e);
    }*/
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
            visible: true,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () async {
                    print("--onTap---${products.length}");

                    var result = await DialogUtils.displayMenuAlert(context, "Menu", subCategoryResponse.subCategories);
                    if(result != null){
                      SubCategoryModel object = result;
                      print("--selected---${object.id} and ${object.title}");
                      print("Index=${subCathashMap['${object.id}']}");
                      await controller.scrollToIndex(int.parse(subCathashMap['${object.id}']));
                      controller.highlight(int.parse(subCathashMap['${object.id}']));

                    }

                  },
                  child: Container(
                    width: 140,height: 50,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(
                            Radius.circular(40)
                        )
                    ),
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
                            child: Text("Menu",style: TextStyle(color: Colors.white,fontSize: 16),),
                          ),

                        ],
                      ),
                    ),
                  ),
                )
            ),
          )
        )
      ],
    );
  }

  Widget _getCurrentBody() {
    return NotificationListener(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          _onStartScroll(scrollNotification.metrics);
        } else if (scrollNotification is ScrollUpdateNotification) {
          _onUpdateScroll(scrollNotification.metrics);
        } else if (scrollNotification is ScrollEndNotification) {
          _onEndScroll(scrollNotification.metrics);
        }
      },
      child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: <Widget>[
              addBanners(),
              categoryResponse != null && categoryResponse.categories.isNotEmpty
                  ? Container(
                  height: 190,
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
                      Flexible(
                        child: ListView.builder(
                          itemCount: categoryResponse.categories.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            CategoryModel model =
                            categoryResponse.categories[index];
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
                          },
                        ),
                      )
                    ],
                  ))
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
              ),
              getProductsWidget(),
            ],
          ),
      ),
    );
  }

  bool showBrowseMenuButton = true;
  _onStartScroll(ScrollMetrics metrics) {
    print("--------Scroll Start--------");
    /*setState(() {
      this.showBrowseMenuButton = false;
    });*/
  }

  _onUpdateScroll(ScrollMetrics metrics) {
    //print("--------Scroll Update--------");
    /*setState(() {
      this.showBrowseMenuButton = true;
    });*/
  }

  _onEndScroll(ScrollMetrics metrics) {
    print("--------Scroll End--------");
  }

  Widget addBanners() {
    return Stack(
      children: <Widget>[
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
        ),
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

  Widget getProductsWidget() {
    if (categoryResponse == null) {
      return Container();
    }
    if ((categoryResponse.categories != null &&
        categoryResponse.categories.length == 0)) {
      return Utils.getEmptyView2("No Categories available");
    }

    if (subCategoryResponse == null) {
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
                height: 5,
                width: MediaQuery.of(context).size.width,
                color: listingBorderColor),
            ListView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                  subCathashMap['${subCategory.id}'] = "${index}";

                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: controller,
                    index: index,
                    child: Container(
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
                    ),
                  );
                } else {
                  return Container();
                }
              },
            )
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
      }
      ApiController.getSubCategoryProducts(subCategoryId, store: store)
          .then((response) {
        if (response != null && response.success) {
          subCategoryResponse = response;
          selectedSubCategoryId = subCategoryId;
          for (int i = 0; i < response.subCategories.length; i++) {
            if (response.subCategories[i].products.isNotEmpty) {
              products.add(response.subCategories[i]);
              products.addAll(response.subCategories[i].products);
            }
          }
          setState(() {});
        }
      });
      eventBus.fire(OnProductTileDbRefresh());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // it is a good practice to dispose the controller
    super.dispose();
  }
}
