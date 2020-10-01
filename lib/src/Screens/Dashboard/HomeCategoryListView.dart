import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class HomeCategoryListView extends StatefulWidget {
  final CategoryResponse categoryResponse;
  StoreModel store;
  CustomCallback callback;

  //Product from SubCategory are going to display on the home screen
  SubCategoryModel subCategory;
  CategoryModel selectedCategory;
  String selectedCategoryId;

  HomeCategoryListView(this.categoryResponse, this.store, this.subCategory,
      {this.callback, this.selectedCategoryId, this.selectedCategory});

  @override
  _HomeCategoryListViewState createState() => _HomeCategoryListViewState();
}

class _HomeCategoryListViewState extends State<HomeCategoryListView> {
  @override
  Widget build(BuildContext context) {
    return _makeView();
  }

  Widget _makeView() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
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
                      Visibility(visible: widget.categoryResponse.categories.length>4,
                        child: InkWell(
                        child: Text(
                          "View All",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: appThemeSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () => widget.callback(value: 'toggle'),
                      )
                        ,)
                    ],
                  ),
                ),
                Flexible(
                    child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.categoryResponse.categories
                      .map((CategoryModel model) {
                    return GridTile(
                        child: CategoryView(
                      model,
                      widget.store,
                      false,
                      0,
                      isListView: true,
                      selectedSubCategoryId: widget.selectedCategoryId,
                      callback: <Object>({value}) {
                        setState(() {
                          widget.selectedCategory = (value as CategoryModel);
                          widget.selectedCategoryId =
                              widget.selectedCategory.subCategory.first.id;
                          widget.callback(value: widget.selectedCategory);
                        });
                        return;
                      },
                    ));
                  }).toList(),
                ))
              ],
            )),
        getProductsWidget()
      ],
    );
  }

  Widget getProductsWidget() {
    if((widget.categoryResponse.categories!=null&&widget.categoryResponse.categories.length==0)){
      return Utils.getEmptyView2("No Categories available");
    }

    if (widget.subCategory == null) {
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
      if (widget.subCategory.products == null) {
        return Utils.getEmptyView2("No Products found!");
      } else if (widget.subCategory.products.length == 0) {
        return Utils.getEmptyView2("No Products found!");
      } else {
        return Column(
          children: <Widget>[
            Container(
                height: 5,
                width: MediaQuery.of(context).size.width,
                color: listingBorderColor),
            Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 5,top:10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.subCategory.title,
                      style: TextStyle(
                          color: staticHomeDescriptionColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      child: Text(
                        "View All",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: appThemeSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _showAllSubCategories(),
                    )
                  ],
                ),
              ),
            ),
            ListView.builder(
              itemCount: widget.subCategory.products.length>2?2:widget.subCategory.products.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                Product product = widget.subCategory.products[index];
                return ProductTileItem(product, () {}, ClassType.Home);
              },
            )
          ],
        );
      }
    }
  }

  _showAllSubCategories() {
    if (Utils.checkIfStoreClosed(widget.store)) {
      DialogUtils.displayCommonDialog(
          context, widget.store.storeName, widget.store.storeMsg);
    } else {
      if (widget.selectedCategory != null &&
          widget.selectedCategory.subCategory != null &&
          widget.selectedCategory.subCategory.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return SubCategoryProductScreen(widget.selectedCategory, false, 0);
          }),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "${widget.selectedCategory.title}";
        Utils.sendAnalyticsEvent("Clicked category", attributeMap);
      } else {
        if (widget.selectedCategory != null &&
            widget.selectedCategory.subCategory != null) {
          if (widget.selectedCategory.subCategory.isEmpty) {
            Utils.showToast("No data found!", false);
          }
        }
      }
    }
  }
}
