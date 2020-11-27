import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/Screens/BookOrder/SubCategoryProductScreen.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/UI/MarketPlaceCategoryView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/Categorys.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TagsModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class MarketPlaceHomeCategoryView extends StatefulWidget {

  CategoriesModel categoriesModel;
  LatLng initialPosition;
  //final CategoryResponse categoryResponse;
  //List<CategoryModel> categories = new List();
  //StoreModel store;
  BrandData brandData;
  CustomCallback callback;

  //Product from SubCategory are going to display on the home screen
  SubCategoryModel subCategory;
  CategoryModel selectedCategory;
  String selectedCategoryId;

  MarketPlaceHomeCategoryView(this.categoriesModel,this.initialPosition,this.brandData, this.subCategory,
      {this.callback, this.selectedCategoryId, this.selectedCategory});

  @override
  _MarketPlaceHomeCategoryViewState createState() =>
      _MarketPlaceHomeCategoryViewState();
}

class _MarketPlaceHomeCategoryViewState extends State<MarketPlaceHomeCategoryView> {

  TagsModel tagsModel;
  List<TagData> tagsList = List();
  StoresModel storeData;
  bool isViewAllRestSelected = false;
  StoresModel allStoreData;
  int selectedFilterIndex = -1;
  List<CategoriesData> categorieslist = new List();

  List<TagData> tagsDataList;
  bool isSeeAll = false;
  bool isCateSeeAll = false;

  @override
  void initState() {
    super.initState();
    isViewAllRestSelected = false;

    if(widget.categoriesModel.data.length > 8){
      isCateSeeAll = false;
      categorieslist = widget.categoriesModel.data;
      categorieslist = categorieslist.sublist(0,8);
    }else{
      isCateSeeAll = false;
      categorieslist.addAll(widget.categoriesModel.data);
    }

    addFilters();
    ApiController.tagsApiRequest().then((tagsResponse){
      setState(() {
        this.tagsModel = tagsResponse;
        if(this.tagsModel.data.length > 8){
          tagsDataList = this.tagsModel.data;
          tagsDataList = tagsDataList.sublist(0,8);
          isSeeAll = false;
        }else{
          isSeeAll = false;
          tagsDataList = this.tagsModel.data;
        }
      });
    });
    //----------------------------------------------
    ApiController.storesApiRequest(widget.initialPosition).then((storesResponse){
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
                Visibility(
                  visible: isViewAllRestSelected ? false : true,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            InkWell(
                              onTap: (){
                                print("onTap =isCateSeeAll=${isCateSeeAll}");
                                if(isCateSeeAll){
                                  isCateSeeAll = false;
                                  if(this.tagsModel.data.length > 8){
                                    categorieslist = widget.categoriesModel.data;
                                    categorieslist = categorieslist.sublist(0,8);
                                  }else{
                                    categorieslist = widget.categoriesModel.data;
                                  }
                                }else{
                                  isCateSeeAll = true;
                                  categorieslist = widget.categoriesModel.data;
                                }
                                setState(() {
                                });
                              },
                              child: Text(
                                isCateSeeAll ? "View Less" : "View More",
                                style: TextStyle(
                                    color: appThemeSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GridView.count(
                          crossAxisCount: 4,
                          childAspectRatio: .75,
                          physics: NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 0.0,
                          shrinkWrap: true,
                          children: categorieslist.map((CategoriesData model) {
                            return GridTile(
                                child: MarketPlaceCategoryView(
                                  model,
                                  widget.brandData,
                                  false,
                                  0,
                                  isListView: true,
                                  selectedSubCategoryId: widget.selectedCategoryId,
                                ));
                          }).toList()),
                      Container(
                        margin: EdgeInsets.only(top: 10,left: 10),
                        height: 30,
                        child: Container(
                          height: 30,
                          child: ListView.builder(
                            itemCount: tagsList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: (){
                                  print("onTap=${index}");
                                  if(index != 0){
                                    setState(() {
                                      selectedFilterIndex = index;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  margin:EdgeInsets.only(left:4,right:4),
                                  padding:EdgeInsets.fromLTRB(6,3,6,3),
                                  decoration: BoxDecoration(
                                    color: selectedFilterIndex==index?Colors.grey[200]:Colors.white,
                                      border: Border.all(color: selectedFilterIndex==index?Colors.grey[400]:grayLightColor, width:1),
                                      borderRadius: BorderRadius.circular(2)
                                  ),
                                  child: index == 0
                                      ? Row(
                                    children: [
                                      Image.asset("images/filtericon.png",height: 20,width: 20,),
                                      SizedBox(width: 5,),
                                      Text('${tagsList[index].name}',style:TextStyle(color:Colors.grey)),
                                    ],) :
                                  Row(
                                    children: [
                                      Text('${tagsList[index].name}',
                                          style:TextStyle(color: selectedFilterIndex==index?Colors.grey[600]:Colors.grey)),
                                      SizedBox(width: 5,),
                                      Visibility(
                                        visible: selectedFilterIndex == index ? true : false,
                                        child: Icon(Icons.clear,size: 15,),
                                      )
                                    ],
                                  )
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //Quick Links
                Visibility(
                  visible: true,
                  child: Padding(
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
                            onTap: (){
                              print("onTap =isSeeAll=${isSeeAll}");
                              setState(() {
                                if(isSeeAll){
                                  isSeeAll = false;
                                  if(this.tagsModel.data.length > 8){
                                    tagsDataList = this.tagsModel.data;
                                    tagsDataList = tagsDataList.sublist(0,8);
                                  }else{
                                    tagsDataList = tagsModel.data;
                                  }
                                }else{
                                  isSeeAll = true;
                                  tagsDataList = tagsModel.data;
                                }
                              });
                            },
                            child: Text(
                              isSeeAll ? "View Less" : "View More",
                              style: TextStyle(
                                  color: appThemeSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                tagsModel == null ? Utils.showIndicator() : GridView.count(
                    crossAxisCount: 4,
                    childAspectRatio: 1.4,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 0.0,
                    shrinkWrap: true,
                    children: tagsDataList.map((TagData tagObject) {

                      return Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: DecorationImage(
                              image: NetworkImage("${tagObject.image}"),
                              fit: BoxFit.cover,
                            ),
                          ),
                      );
                    }).toList()
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        isViewAllRestSelected ? "All Restaurants": "Restaurants",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      isViewAllRestSelected
                          ? Container(
                        height: 30,
                        margin:EdgeInsets.only(left:4,right:4),
                        padding:EdgeInsets.fromLTRB(6,3,6,3),
                        decoration: BoxDecoration(
                            border: Border.all(color:grayLightColor,width:  1),
                            borderRadius: BorderRadius.circular(2)
                        ),
                        child: Row(
                          children: [
                            Image.asset("images/filtericon.png",height: 20,width: 20,),
                            SizedBox(width: 5,),
                            Text('Filters',style:TextStyle(color:Colors.grey)),
                          ],),
                      )
                          : Visibility(
                        visible: true,
                        child: InkWell(
                          child: Text(
                            "View All",
                            style: TextStyle(
                                color: appThemeSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                          ),
                          onTap: () async {
                            print("onTap");
                            bool isNetworkAvailable = await Utils.isNetworkAvailable();
                            if(!isNetworkAvailable){
                              Utils.showToast("No Internet connection",false);
                              return;
                            }
                            Map data = {
                              "lst" : widget.initialPosition.latitude,
                              "lng": widget.initialPosition.latitude,
                            };
                            Utils.showProgressDialog(context);
                            ApiController.getAllStores(params: data).then((storesResponse){
                              Utils.hideProgressDialog(context);
                              Utils.hideKeyboard(context);
                              setState(() {
                                isViewAllRestSelected = true;
                                allStoreData = storesResponse;
                                eventBus.fire(onViewAllSelected(isViewAllRestSelected,allStoreData));
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                storeData == null ? Container() : getProductsWidget()
              ],
            )
        ),
      ],
    );
  }

  Widget getProductsWidget() {
    return Column(
      children: <Widget>[
        Container(
          height: 0,
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
              itemCount: isViewAllRestSelected ? allStoreData.data.length :storeData.data.length,
              itemBuilder: (context, index) {
                StoreData storeDataObj = isViewAllRestSelected
                    ? allStoreData.data[index]
                    : storeData.data[index];

                return InkWell(
                  onTap: (){
                    print("----onTap-${storeDataObj.id}--");
                    Utils.showProgressDialog(context);
                    ApiController.getStoreVersionData(storeDataObj.id).then((response){
                      Utils.hideProgressDialog(context);
                      Utils.hideKeyboard(context);
                      StoreDataModel storeObject = response;

                    });

                  },
                  child: Stack(
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
                                        /*Row(
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
                                      ),*/
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
                                          '${storeDataObj.state}',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        /*Text(
                                        '${AppConstant.currency}350 for two',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),*/
                                      ],
                                    )
                                ),
                              ],
                            )),
                      ),
                      /*Container(
                      margin: EdgeInsets.only(top: 130),
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      decoration: BoxDecoration(
                          color: yellowColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "5% OFF",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),*/
                      Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(top: 130, right: 20),
                            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                            decoration: BoxDecoration(
                                color: whiteWith70Opacity,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: Text("45 mins",style: TextStyle(color: Colors.black, fontSize: 12),),
                            ),
                            width: 70,
                          )
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }

  _showAllSubCategories() {
    /*if (Utils.checkIfStoreClosed(widget.store)) {
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
    }*/
  }

  void addFilters() {
    TagData filterTag = TagData();
    filterTag.name = "Filters";
    filterTag.isFilterView = true;
    tagsList.add(filterTag);

    TagData filter1 = TagData();
    filter1.name = "Distance";
    filter1.isFilterView = false;
    tagsList.add(filter1);

    TagData filter2 = TagData();
    filter2.name = "Newly Added";
    filter2.isFilterView = false;
    tagsList.add(filter2);
  }
}
