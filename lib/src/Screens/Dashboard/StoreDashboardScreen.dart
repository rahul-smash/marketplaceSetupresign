import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

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
//        this.categoryResponse = response;
//        getHomeCategoryProductApi();
      });
    });
  }

//  void getHomeCategoryProductApi() {
//    if (categoryResponse != null &&
//        categoryResponse.categories != null &&
//        categoryResponse.categories.isNotEmpty) {
//      String subCategoryId =
//          categoryResponse.categories.first.subCategory[0].id;
//      if (selectedCategory == null)
//        selectedCategory = categoryResponse.categories.first;
//
//      if (selectedSubCategoryId != null && selectedSubCategoryId.isNotEmpty) {
//        subCategoryId = selectedSubCategoryId;
//      }
//      ApiController.getSubCategoryProducts(subCategoryId).then((response) {
//        if (response != null && response.success) {
//          subCategory = SubCategoryModel();
//          selectedSubCategoryId = subCategoryId;
//          for (int i = 0; i < response.subCategories.length; i++) {
//            if (subCategoryId == response.subCategories[i].id) {
//              subCategory = response.subCategories[i];
//              break;
//            }
//          }
//          setState(() {});
//        }
//      });
//      eventBus.fire(OnProductTileDbRefresh());
//    }
//  }

  Widget _newBody() {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/backgroundimg.png"),
              fit: BoxFit.cover,
            ),
          ),
          color: Colors.white,
        ),
        Padding(
          padding: EdgeInsets.only(top: 60),
          child: _getCurrentBody(),
        ),
      ],
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
                ?
//            Center(child: CircularProgressIndicator())
                 /*HomeCategoryListView(
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
