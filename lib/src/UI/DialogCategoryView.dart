import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class DialogCategoryView extends StatelessWidget {
  final CategoryModel categoryModel;
  StoreModel store;
  CustomCallback callback;

  DialogCategoryView(this.categoryModel, this.store, {this.callback});

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _onTapPressed(context);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),border: Border.all(color: appTheme.withOpacity(.5),width: 1)),
        margin: EdgeInsets.fromLTRB(10, 0, 10, 15),
        padding: EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: Center(child:
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),),
                  margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: categoryModel.image300200.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.all(0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: "${categoryModel.image300200}",
                              fit: BoxFit.cover,
                              width: 70,
                              height: 60,
                              //placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) {
                                print('image error ${url}');
                                return Container();
                              },
                            ),
                          ))
                      : Padding(
                          padding: EdgeInsets.all(0),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0))),
                        ))),
            ),
            Expanded(
                child: Padding(
//              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              padding: EdgeInsets.only(top: 10.0,left: 2,right: 2),
              child: Center(
                child: Text(
                    categoryModel.title,
//                    'hdshfghjsgjhjsgjsd js hjgh fhjsj gf hjsgf jhgsj hfghs fgs fg jhg ghgj sfgj gsgf j ',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                    style: new TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                    )),
              ),
            )),
          ],
        ),
      ),
    );
  }

  _onTapPressed(BuildContext context) async {
    if (Utils.checkIfStoreClosed(store)) {
      DialogUtils.displayCommonDialog(context, store.storeName, store.storeMsg);
    } else {
      if (categoryModel != null && categoryModel.subCategory.isNotEmpty) {
        callback();
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
  }
}
