import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/UI/MarketPlaceCategoryView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class MarketPlaceHomeCategoryView extends StatefulWidget {
  final CategoryResponse categoryResponse;
  List<CategoryModel> categories = new List();
  List<String> quickListUrls = new List();
  StoreModel store;
  CustomCallback callback;

  //Product from SubCategory are going to display on the home screen
  SubCategoryModel subCategory;
  CategoryModel selectedCategory;
  String selectedCategoryId;

  MarketPlaceHomeCategoryView(
      this.categoryResponse, this.store, this.subCategory,
      {this.callback, this.selectedCategoryId, this.selectedCategory}) {
    if (categoryResponse.categories.length > 8) {
      for (int i = 0; i < 8; i++) {
        categories.add(categoryResponse.categories[i]);
      }
    } else {
      categories.addAll(categoryResponse.categories);
    }
    quickListUrls.add('images/purevegbg.png');
    quickListUrls.add('images/offersbg.png');
    quickListUrls.add('images/premiumbg.png');
    quickListUrls.add('images/mealsforonebg.png');
    quickListUrls.add('images/nonvegbd.png');
    quickListUrls.add('images/trendingbg.png');
    quickListUrls.add('images/newarrivalsbg.png');
    quickListUrls.add('images/safetybg.png');
  }

  @override
  _MarketPlaceHomeCategoryViewState createState() =>
      _MarketPlaceHomeCategoryViewState();
}

class _MarketPlaceHomeCategoryViewState
    extends State<MarketPlaceHomeCategoryView> {
  @override
  Widget build(BuildContext context) {
    return _makeView();
  }

  Widget _makeView() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
            color: Colors.transparent,
            margin: EdgeInsets.only(left: 2.5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Your neighbours are ordering..",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: .75,
                    physics: NeverScrollableScrollPhysics(),
//                    padding:
//                    EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 0.0,
                    shrinkWrap: true,
                    children: widget.categories.map((CategoryModel model) {
                      return GridTile(
                          child: MarketPlaceCategoryView(
                        model,
                        widget.store,
                        false,
                        0,
                        isListView: true,
                        selectedSubCategoryId: widget.selectedCategoryId,
                      ));
                    }).toList()),
                //Static
                Container(
                  margin: EdgeInsets.only(top: 30,left: 10),
                  height: 30,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                        Wrap(children: [Container(
                          margin:EdgeInsets.only(left:3,right:4),
                          padding:EdgeInsets.fromLTRB(6,3,6,3),
                          decoration: BoxDecoration( border: Border.all(
                              color: grayLightColor,
                              width:  1),
                          borderRadius: BorderRadius.circular(2)),
                          child:  Row(
                            children: [
                              Image.asset('images/filtericon.png',
                                  width: 12,
                                  fit: BoxFit.scaleDown,
                                 ),
                              SizedBox(width: 5,),
                              Text(
                                'Filters',
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),)],),
                        Wrap(children: [Container(
                          margin:EdgeInsets.only(left:4,right:4),
                          padding:EdgeInsets.fromLTRB(6,3,6,3),
                          decoration: BoxDecoration( border: Border.all(
                              color:grayLightColor,
                              width:  1),
                          borderRadius: BorderRadius.circular(2)),
                          child:  Row(
                            children: [
                              Text(
                                'Nearest',
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),)],),
                        Wrap(children: [Container(
                          margin:EdgeInsets.only(left:4,right:4),

                          padding:EdgeInsets.fromLTRB(6,3,6,3),
                          decoration: BoxDecoration(
                            color: grayLightColor,
                              border: Border.all(

                              color: Colors.grey,
                              width:  1),
                          borderRadius: BorderRadius.circular(2)),
                          child:  Row(
                            children: [
                              Text(
                                'Distance',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(width: 5,),
                              Image.asset('images/cancelicon.png',
                                width: 10,
                                fit: BoxFit.scaleDown,
                                color: Colors.black,
                              ),

                            ],
                          ),)],),
                        Wrap(children: [Container(
                          margin:EdgeInsets.only(left:4,right:4),
                          padding:EdgeInsets.fromLTRB(6,3,6,3),
                          decoration: BoxDecoration( border: Border.all(
                              color: grayLightColor,
                              width:  1),
                          borderRadius: BorderRadius.circular(2)),
                          child:  Row(
                            children: [
                              Text(
                                'Cuisne',
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),)],),
                        Wrap(children: [Container(
                          margin:EdgeInsets.only(left:4,right:4),
                          padding:EdgeInsets.fromLTRB(6,3,6,3),
                          decoration: BoxDecoration( border: Border.all(
                              color: grayLightColor,
                              width:  1),
                          borderRadius: BorderRadius.circular(2)),
                          child:  Row(
                            children: [
                              Text(
                                'Rating 4.0+',
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),)],),
                        Wrap(children: [Container(
                          margin:EdgeInsets.only(left:4,right:4),
                          padding:EdgeInsets.fromLTRB(6,3,6,3),
                          decoration: BoxDecoration( border: Border.all(
                              color: grayLightColor,
                              width:  1),
                          borderRadius: BorderRadius.circular(2)),
                          child:  Row(
                            children: [
                              Text(
                                'Others',
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),)],),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "QUICK LINKS",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      Visibility(
                        visible: true,
                        child: InkWell(
                          child: Text(
                            "see all",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: appThemeSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 1.4,
                    physics: NeverScrollableScrollPhysics(),
//                    padding:
//                    EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 0.0,
                    shrinkWrap: true,
                    children: widget.quickListUrls.map((String url) {
                      return Container(
                          margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: DecorationImage(
                              image: AssetImage(url),
                              fit: BoxFit.cover,
                            ),
                          ));
                    }).toList()),
                getProductsWidget()
              ],
            )),
      ],
    );
  }

  Widget getProductsWidget() {
    return Column(
      children: <Widget>[
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width,
        ),
        ListView(
          padding: EdgeInsets.only(bottom: 20),
          children: [
            //to be dynamic
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(
                    10,
                  ),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                    boxShadow: [
//                  color: Colors.white, //background color of box
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 75.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
//                    offset: Offset(
//                      5.0, // Move to right 10  horizontally
//                      5.0, // Move to bottom 10 Vertically
//                    ),
                      )
                    ],
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    topLeft: Radius.circular(5)),
                                image: DecorationImage(
                                  image: AssetImage('images/img1.png'),
                                  fit: BoxFit.cover,
                                ),
                              )),
                          Padding(
                              padding:
                                  EdgeInsets.only(left: 16, right: 16, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pizza Hut',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            color: appThemeSecondary,
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(3),
                                            child: Image.asset(
                                                'images/staricon.png',
                                                width: 15,
                                                fit: BoxFit.scaleDown,
                                                color: Colors.white),
                                          )),
                                      Text(
                                        '4.0/',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '5',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 5, bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pizza, Fast Food',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    '${AppConstant.currency}350 for two',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              )),
                        ],
                      )),
                ),
                Container(
                  margin: EdgeInsets.only(top: 130),
                  padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                  decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    "5% OFF",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(top: 130, right: 20),
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      decoration: BoxDecoration(
                          color: whiteWith70Opacity,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "45 mins",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ))
              ],
            ),
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(
                    10,
                  ),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                    boxShadow: [
//                  color: Colors.white, //background color of box
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 75.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
//                    offset: Offset(
//                      5.0, // Move to right 10  horizontally
//                      5.0, // Move to bottom 10 Vertically
//                    ),
                      )
                    ],
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    topLeft: Radius.circular(5)),
                                image: DecorationImage(
                                  image: AssetImage('images/img2.png'),
                                  fit: BoxFit.cover,
                                ),
                              )),
                          Padding(
                              padding:
                                  EdgeInsets.only(left: 16, right: 16, top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sagar Ratna',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            color: appThemeSecondary,
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(3),
                                            child: Image.asset(
                                                'images/staricon.png',
                                                width: 15,
                                                fit: BoxFit.scaleDown,
                                                color: Colors.white),
                                          )),
                                      Text(
                                        '4.5/',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        '5',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 5, bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'South Indian',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    '${AppConstant.currency}100 for one',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              )),
                        ],
                      )),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: EdgeInsets.only(top: 130, right: 20),
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      decoration: BoxDecoration(
                          color: whiteWith70Opacity,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "45 mins",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ))
              ],
            )
          ],
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        )
      ],
    );
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
