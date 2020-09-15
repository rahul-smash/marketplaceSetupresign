import 'package:flutter/material.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

class HomeCategoryListView extends StatelessWidget {
  final CategoryResponse categoryResponse;
  StoreModel store;
  VoidCallback callback;

  HomeCategoryListView(this.categoryResponse, this.store, {this.callback});

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
                        "Top Categories",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        child: Text(
                          "View All",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: appTheme,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () => callback(),
                      )
                    ],
                  ),
                ),
                Flexible(
                    child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      categoryResponse.categories.map((CategoryModel model) {
                    return GridTile(
                        child: CategoryView(
                      model,
                      store,
                      false,
                      0,
                      isListView: true,
                    ));
                  }).toList(),
                ))
              ],
            )),
        getProductsWidget(categoryResponse.categories.first.subCategory[0].id)
      ],
    );
  }

  Widget getProductsWidget(String subCategoryId) {
    return FutureBuilder(
      future: ApiController.getSubCategoryProducts(subCategoryId),
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.hasData == null) {
          return Container();
        } else {
          if (projectSnap.hasData) {
            SubCategoryResponse response = projectSnap.data;
            if (response.success) {
              //Check
              SubCategoryModel subCategory = SubCategoryModel();
//              SubCategoryModel subCategory =response.subCategories.first;
              for (int i = 0; i < response.subCategories.length; i++) {
                if (subCategoryId == response.subCategories[i].id) {
                  subCategory = response.subCategories[i];
                  break;
                }
              }
              if (subCategory.products == null) {
                return Container();
              }
              //print("products.length= ${subCategory.products.length}");
              if (subCategory.products.length == 0) {
                return Utils.getEmptyView2("No Products found!");
              } else {
                return ListView.builder(
                  itemCount: subCategory.products.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Product product = subCategory.products[index];
                    return ProductTileItem(product, () {
//                      bottomBar.state.updateTotalPrice();
                    }, ClassType.SubCategory);
                  },
                );
              }
            } else {
              //print("no products.length=");
              return Utils.getEmptyView2(AppConstant.noInternet);
//                return Utils.getEmptyView2("No Products found!");
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.black26,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
            );
          }
        }
      },
    );
  }
}
