import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/UI/MarketPlaceCategoryView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/Categorys.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TagsModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class MarketPlaceHomeCategoryView extends StatefulWidget {

  CategoriesModel categoriesModel;
  List<CategoriesData> categorieslist = new List();

  final CategoryResponse categoryResponse;
  //List<CategoryModel> categories = new List();
  List<String> quickListUrls = new List();
  StoreModel store;
  CustomCallback callback;

  //Product from SubCategory are going to display on the home screen
  SubCategoryModel subCategory;
  CategoryModel selectedCategory;
  String selectedCategoryId;

  MarketPlaceHomeCategoryView(this.categoriesModel,
      this.categoryResponse, this.store, this.subCategory,
      {this.callback, this.selectedCategoryId, this.selectedCategory}) {

    /*if (categoryResponse.categories.length > 8) {
      for (int i = 0; i < 8; i++) {
        categories.add(categoryResponse.categories[i]);
      }
    } else {
      categories.addAll(categoryResponse.categories);
    }*/

    if (categoriesModel.data.length > 8) {
      for (int i = 0; i < 8; i++) {
        categorieslist.add(categoriesModel.data[i]);
      }
    } else {
      categorieslist.addAll(categoriesModel.data);
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

class _MarketPlaceHomeCategoryViewState extends State<MarketPlaceHomeCategoryView> {

  TagsModel tagsModel;
  List<TagData> tagsList = List();
  StoresModel storeData;

  @override
  void initState() {
    super.initState();
    ApiController.tagsApiRequest().then((tagsResponse){
      setState(() {
        this.tagsModel = tagsResponse;
        TagData filterTag = TagData();
        filterTag.name = "Filters";
        filterTag.isFilterView = true;
        tagsList.add(filterTag);
        tagsList.addAll(this.tagsModel.data);
      });
    });
    //----------------------------------------------
    ApiController.storesApiRequest().then((storesResponse){
      setState(() {
        this.storeData = storesResponse;
      });
    });

  }

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
                    children: widget.categorieslist.map((CategoriesData model) {
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
                Container(
                  margin: EdgeInsets.only(top: 0,left: 10),
                  height: 30,
                  child: tagsModel == null
                      ? Container()
                      : Container(
                    height: 30,
                    child: ListView.builder(
                      itemCount: tagsList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 30,
                          margin:EdgeInsets.only(left:4,right:4),
                          padding:EdgeInsets.fromLTRB(6,3,6,3),
                          decoration: BoxDecoration(
                              border: Border.all(color:grayLightColor,width:  1),
                              borderRadius: BorderRadius.circular(2)
                          ),
                          child:  index == 0
                              ? Row(
                            children: [
                              Image.asset("images/filtericon.png",height: 20,width: 20,),
                              SizedBox(width: 5,),
                              Text('${tagsList[index].name}',style:TextStyle(color:Colors.grey)),
                            ],)
                              :Center(child: Text('${tagsList[index].name}',style:TextStyle(color:Colors.grey)),),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 25, 10, 10),
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
                tagsModel == null ? Utils.showIndicator() :GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 1.4,
                    physics: NeverScrollableScrollPhysics(),
//                    padding:
//                    EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 0.0,
                    shrinkWrap: true,
                    children: tagsModel.data.map((TagData tagObject) {

                      return Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: DecorationImage(
                              image: NetworkImage("${tagObject.image}"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        child: Center(child: Text("${tagObject.name}",maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white),),),
                      );
                    }).toList()
                ),
                storeData == null ? Container() : getProductsWidget()
              ],
            )),
      ],
    );
  }

  Widget getProductsWidget() {
    return Column(
      children: <Widget>[
        Container(
          height: 10,
          width: MediaQuery.of(context).size.width,
        ),

        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: storeData.data.length,
              itemBuilder: (context, index) {
                StoreData storeDataObj = storeData.data[index];
                return Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            topLeft: Radius.circular(5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 5,
                            //offset: Offset(10, 13), // changes position of shadow
                          ),
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
                                        '${storeDataObj.storeName}',
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
                );
              },
            ),
          ],
        ),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width,
        ),
        /*ListView(
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
        ),*/
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
