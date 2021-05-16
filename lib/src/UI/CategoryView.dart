import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class CategoryView extends StatefulWidget {
  final CategoryModel categoryModel;
  StoreDataObj store;
  int index;
  bool isComingFromBaner;
  bool isListView;
  CustomCallback callback;
  String selectedSubCategoryId;

  CategoryView(
      this.categoryModel, this.store, this.isComingFromBaner, this.index,
      {this.isListView = false,
      this.selectedSubCategoryId = '',
      this.callback});

  @override
  _CategoryViewState createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  int searchResultCount = 0;

  @override
  void initState() {
    super.initState();
    eventBus.on<updateStoreSearch>().listen((event) {
      setState(() {
        searchResultCount = event.searchedProductList.length;
      });

    });
  }

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.isListView)
          _onListTapHandle(context);
        else
          _onTapPressed(context);
      },
      child: Container(
        width: widget.isListView
            ? (Utils.getDeviceWidth(context) / 4.2) - 3
            : null,
        margin: EdgeInsets.fromLTRB(
            widget.isListView ? 3 : 10, 0, widget.isListView ? 3 : 10, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color:
                            _isCategoryViewSelected() && searchResultCount == 0
                                ? appThemeSecondary
                                : Colors.white,
                        width: _isCategoryViewSelected() ? 2 : 0),
                    borderRadius: BorderRadius.circular(10.0)),
                height: (Utils.getDeviceWidth(context) / 5) - 3,
                margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: widget.categoryModel.image300200.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: "${widget.categoryModel.image300200}",
                          width: (Utils.getDeviceWidth(context) / 4),
                          fit: BoxFit.cover,
                          //placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            print('image error ${url}');
                            return Container();
                          },
                        )
                      : Image.asset(
                          'images/img_placeholder.jpg',
                          fit: BoxFit.cover,
                        ),
                )),
            Padding(
//              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              padding: EdgeInsets.only(top: 10.0),
              child: Center(
                child: Text(widget.categoryModel.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                    style: new TextStyle(
                        color: _isCategoryViewSelected()&& searchResultCount==0
                            ? appThemeSecondary
                            : Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapPressed(BuildContext context) async {
    if (checkIfStoreClosed(widget.store)) {
      DialogUtils.displayCommonDialog(
          context, widget.store.storeName, widget.store.storeMsg);
    } else {
      if (widget.categoryModel != null &&
          widget.categoryModel.subCategory.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return SubCategoryProductScreen(
                widget.categoryModel, widget.isComingFromBaner, widget.index);
          }),
        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "${widget.categoryModel.title}";
        Utils.sendAnalyticsEvent("Clicked category", attributeMap);
      } else {
        if (widget.categoryModel != null &&
            widget.categoryModel.subCategory != null) {
          if (widget.categoryModel.subCategory.isEmpty) {
            Utils.showToast("No data found!", false);
          }
        }
      }
    }
  }

  void _onListTapHandle(BuildContext context) {
    if (checkIfStoreClosed(widget.store)) {
      DialogUtils.displayCommonDialog(
          context, widget.store.storeName, widget.store.storeMsg);
    } else {
      if (widget.categoryModel != null &&
          widget.categoryModel.subCategory.isNotEmpty) {
        widget.callback(value: widget.categoryModel);
//        Navigator.push(
//          context,
//          MaterialPageRoute(builder: (context) {
//            return SubCategoryProductScreen(
//                categoryModel, isComingFromBaner, index);
//          }),
//        );
        Map<String, dynamic> attributeMap = new Map<String, dynamic>();
        attributeMap["ScreenName"] = "${widget.categoryModel.title}";
        Utils.sendAnalyticsEvent("Clicked category", attributeMap);
      } else {
        if (widget.categoryModel != null &&
            widget.categoryModel.subCategory != null) {
          if (widget.categoryModel.subCategory.isEmpty) {
            Utils.showToast("No data found!", false);
          }
        }
      }
    }
  }

  bool _isCategoryViewSelected() {
    if (widget.isListView &&
        widget.selectedSubCategoryId != null &&
        widget.categoryModel != null &&
        widget.categoryModel.subCategory != null &&
        widget.categoryModel.subCategory.isNotEmpty) {
      return widget.selectedSubCategoryId.compareTo(widget.categoryModel.id) ==
          0;
    } else {
      return false;
    }
  }

  bool checkIfStoreClosed(StoreDataObj store) {
    if (store.storeStatus == "0") {
      //0 mean Store close
      return true;
    } else {
      return false;
    }
  }
}
