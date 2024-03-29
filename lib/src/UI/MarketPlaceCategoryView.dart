import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/Categorys.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class MarketPlaceCategoryView extends StatelessWidget {
  //final CategoryModel categoryModel;
  CategoriesData categoryModel;

  //StoreModel store;
  BrandData brandData;
  int index;
  bool isComingFromBaner;
  bool isListView;
  CustomCallback callback;
  String selectedSubCategoryId;

  MarketPlaceCategoryView(
      this.categoryModel, this.brandData, this.isComingFromBaner, this.index,
      {this.isListView = false,
      this.selectedSubCategoryId = '',
      this.callback});

  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: isListView ? (Utils.getDeviceWidth(context) / 4.2) - 3 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: (Utils.getDeviceWidth(context) / 5) - 3,
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: categoryModel.image300200.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: "${categoryModel.image300200}",
                            width: (Utils.getDeviceWidth(context) / 4),
                            fit: BoxFit.cover,
                            //placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              print('image error ${url}');
                              return Container();
                            },
                          ),
                        )
                      : Padding(
                          padding:
                              EdgeInsets.all(_isCategoryViewSelected() ? 4 : 0),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0))),
                        )),
              Padding(
//              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                padding: EdgeInsets.only(top: 5.0),
                child: Center(
                  child: Text(categoryModel.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                      style: new TextStyle(
                        color: _isCategoryViewSelected()
                            ? Colors.black
                            : Colors.black,
                        fontSize: 14.0,
                      )),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  _onTapPressed(BuildContext context) async {
    /*if (Utils.checkIfStoreClosed(store)) {
      DialogUtils.displayCommonDialog(context, store.storeName, store.storeMsg);
    } else {
      if (categoryModel != null && categoryModel.subCategory.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return SubCategoryProductScreen(
                categoryModel, isComingFromBaner, index);
          }),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "${categoryModel.title}";
        Utils.sendAnalyticsEvent("Clicked category", attributeMap);
      } else {
        if (categoryModel != null && categoryModel.subCategory != null) {
          if (categoryModel.subCategory.isEmpty) {
            Utils.showToast("No data found!", false);
          }
        }
      }
    }*/
  }

  void _onListTapHandle(BuildContext context) {
    /*if (Utils.checkIfStoreClosed(store)) {
      DialogUtils.displayCommonDialog(context, store.storeName, store.storeMsg);
    } else {
      if (categoryModel != null && categoryModel.subCategory.isNotEmpty) {
//        callback(value: categoryModel);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return SubCategoryProductScreen(
                categoryModel, isComingFromBaner, index);
          }),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "${categoryModel.title}";
        Utils.sendAnalyticsEvent("Clicked category", attributeMap);
      } else {
        if (categoryModel != null && categoryModel.subCategory != null) {
          if (categoryModel.subCategory.isEmpty) {
            Utils.showToast("No data found!", false);
          }
        }
      }
    }*/
  }

  bool _isCategoryViewSelected() {
    /*if (isListView &&
        selectedSubCategoryId != null &&
        categoryModel != null &&
        categoryModel.subCategory != null &&
        categoryModel.subCategory.isNotEmpty) {
      return selectedSubCategoryId
              .compareTo(categoryModel.subCategory.first.id) ==
          0;
    } else {
      return false;
    }*/
    return false;
  }
}
