import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class StoreDashboardScreen extends StatefulWidget {
  final StoreDataModel store;

  StoreDashboardScreen(this.store);

  @override
  State<StatefulWidget> createState() {
    return _StoreDashboardScreenState(this.store.store);
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
  bool isLoading = true;
  int _current = 0;

  CategoryResponse categoryResponse;

  CategoryModel selectedCategory;

  String selectedSubCategoryId;

  SubCategoryResponse subCategoryResponse;

  _StoreDashboardScreenState(this.store);

  List<dynamic> products = List();

  @override
  void initState() {
    super.initState();
    isStoreClosed = false;
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
//          decoration: BoxDecoration(
//            image: DecorationImage(
//              image: AssetImage("images/backgroundimg.png"),
//              fit: BoxFit.cover,
//            ),
//          ),
          color: Colors.white,
        ),
        Padding(
          padding: EdgeInsets.only(top: 0),
          child: _getCurrentBody(),
        ),
      ],
    );
  }

  Widget _getCurrentBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          addBanners(),
          categoryResponse != null && categoryResponse.categories.isNotEmpty
              ? Container(
                  height: 180,
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
//                              widget.callback(value: widget.selectedCategory);
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
    );
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
//            Container(
//              color: Colors.transparent,
//              child: Padding(
//                padding:
//                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 10),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Text(
//                      subCategory.title,
//                      style: TextStyle(
//                          color: staticHomeDescriptionColor,
//                          fontSize: 14,
//                          fontWeight: FontWeight.bold),
//                    ),
//                  ],
//                ),
//              ),
//            ),
            ListView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (products[index] is Product) {
                  Product product = products[index];
                  return Container(
                    child: ProductTileItem(product, () {}, ClassType.Home),
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
                  return Container();
                }
              },
            )
          ],
        );
      }
    }
  }

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
}
