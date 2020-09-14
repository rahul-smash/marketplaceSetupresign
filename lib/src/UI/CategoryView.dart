import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class CategoryView extends StatelessWidget {
  final CategoryModel categoryModel;
  StoreModel store;
  int index;
  bool isComingFromBaner;

  bool _imageError = false;

  CategoryView(
      this.categoryModel, this.store, this.isComingFromBaner, this.index);

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (checkIfStoreClosed()) {
          DialogUtils.displayCommonDialog(
              context, store.storeName, store.storeMsg);
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
        }
      },
      child: Container(
//        color: Colors.red,
        margin: EdgeInsets.fromLTRB(10, 0, 10, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  height: 75,
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: categoryModel.image300200.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: "${categoryModel.image300200}",
                            width: Utils.getDeviceWidth(context),
                            fit: BoxFit.cover,
                            //placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              _imageError = true;
                              print('image error ${url}');
                            },
                          ),
                        )
                      : null),
            ),
            Expanded(
                child: Padding(
//              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              padding: EdgeInsets.only(top: 10.0),
              child: Center(
                child: Text(categoryModel.title,
//                    'hdshfg hjsgj hjs gjsd js hjgh fhjsj gf hjsgf jhgsj hfghs fgs fg jhg ghgj sfgj gsgf j ',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    )),
              ),
            )),
          ],
        ),
      ),
    );
  }

  bool checkIfStoreClosed() {
    if (store.storeStatus == "0") {
      //0 mean Store close
      return true;
    } else {
      return false;
    }
  }
}
