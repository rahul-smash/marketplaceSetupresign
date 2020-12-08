import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/UI/CartBottomView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/SearchTagsModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/BaseState.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:flutter_tags/flutter_tags.dart';

class SearchScreen extends StatefulWidget {
  LatLng initialPosition;
  CustomCallback callback;

  SearchScreen(
    this.initialPosition,
    this.callback,
  );

  @override
  _SearchScreenState createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends BaseState<SearchScreen> {
  TextEditingController controller = TextEditingController();
  int selctedTag;
  List<String> tagsList = List();
  List<SubCategoryModel> subCategoryList = List();
  SubCategoryModel subCategory;
  List<Product> productsList = List();
  CartTotalPriceBottomBar bottomBar =
      CartTotalPriceBottomBar(ParentInfo.searchList);
  bool isSearchEmpty;

  ScrollController _scrollController;
  GlobalKey tagskey;
  StoresModel allStoreData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selctedTag = -1;
    isSearchEmpty = true;
    _scrollController = ScrollController();
    tagskey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //return a `Future` with false value so this route cant be popped or closed.
        Navigator.pop(context, false);
        return new Future(() {
          return false;
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Search"),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: 40,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              //padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: searchGrayColor,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(
                    color: searchGrayColor,
                  )),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.search,
                              color: appTheme,
                            ),
                            onPressed: () {
                              if (controller.text.trim().isEmpty) {
                                Utils.showToast(
                                    "Please enter some valid keyword", false);
                              } else {
                                selctedTag = -1;
                                callSearchAPI();
                              }
                            }),
                        Flexible(
                          child: TextField(
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) {
                              if (value.trim().isEmpty) {
                                Utils.showToast(
                                    "Please enter some valid keyword", false);
                              } else {
                                selctedTag = -1;
                                callSearchAPI();
                              }
                            },
                            onChanged: (text) {
                              print("onChanged ${text}");
                              if (text.trim().isEmpty) {
                                isSearchEmpty = true;
                              } else {
                                isSearchEmpty = false;
                              }
                              setState(() {});
                            },
                            controller: controller,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: "Search"),
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: appTheme,
                            ),
                            onPressed: () {
                              setState(() {
                                controller.text = "";
                                setState(() {
                                  subCategory = null;
                                  productsList.clear();
                                });
                              });
                            }),
                      ]),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _scrollController,
                child: _getView(),
              ),
            )
          ],
        ),
        bottomNavigationBar: bottomBar,
      ),
    );
  }

  Widget showTagsList() {
    Color chipSelectedColor, textColor;
    print("---selctedTag-${selctedTag}---");
    Widget horizontalList = new Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      //height: 150.0,
      child: Tags(
        itemCount: tagsList.length,
        alignment: WrapAlignment.start,
        //horizontalScroll: true,
        itemBuilder: (int index) {
          String tagName = tagsList[index];
          return ItemTags(
            key: Key(index.toString()),
            index: index,
            elevation: 0.0,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              width: 1,
              color: favGrayColor,
            ),
            color: favGrayColor,
            activeColor: searchTagsColor,
            textActiveColor: Colors.white,
            singleItem: true,
            splashColor: Colors.green,
            combine: ItemTagsCombine.withTextBefore,
            title: tagName,
            onPressed: (item) {
              setState(() {
                selctedTag = index;
                //print("selctedTag= ${tagsList[selctedTag]}");
                controller.text = tagsList[selctedTag];
                callSearchAPI();
              });
            },
          );
        },
      ),
    );
    return horizontalList;
  }

  void callSearchAPI() {
    Utils.hideKeyboard(context);
    Utils.isNetworkAvailable().then((isNetworkAvailable) async {
      if (isNetworkAvailable) {
        Utils.sendSearchAnalyticsEvent(controller.text);
        Utils.showProgressDialog(context);

        Map<String, dynamic> data = {
          "lst": widget.initialPosition.latitude,
          "lng": widget.initialPosition.latitude,
          "search_by": "Keyword",
          "keyward": "${controller.text}",
        };
        ApiController.getAllStores(params: data).then((storesResponse) {
          Utils.hideProgressDialog(context);
          Utils.hideKeyboard(context);
          if (storesResponse != null) {
            allStoreData = storesResponse;
            setState(() {});
          }
        });
      } else {
        Utils.showToast(AppConstant.noInternet, false);
      }
    });
  }

  Widget _getView() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          allStoreData == null
              ? Container()
              : (allStoreData != null && allStoreData.data.isEmpty)
                  ? Utils.getEmptyView2("No Result Found")
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: allStoreData.data.length,
                      itemBuilder: (context, index) {
                        StoreData storeDataObj = allStoreData.data[index];
                        return InkWell(
                          onTap: () {
                            print("----onTap-${storeDataObj.id}--");
                            Utils.showProgressDialog(context);
                            ApiController.getStoreVersionData(storeDataObj.id)
                                .then((response) {
                              Utils.hideProgressDialog(context);
                              Utils.hideKeyboard(context);
                              StoreDataModel storeObject = response;
                              widget.callback(value: storeObject);
                              Navigator.pop(context);
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 150,
                                            child: storeDataObj.image.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight: Radius
                                                                .circular(5),
                                                            topLeft:
                                                                Radius.circular(
                                                                    5)),
                                                    child: CachedNetworkImage(
                                                        height: 150,
                                                        width: Utils
                                                            .getDeviceWidth(
                                                                context),
                                                        imageUrl:
                                                            "${storeDataObj.image}",
                                                        fit: BoxFit.cover),
                                                  )
                                                : null,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(5),
                                                  topLeft: Radius.circular(5)),
                                              image: storeDataObj.image.isEmpty
                                                  ? DecorationImage(
                                                      image: AssetImage(
                                                          'images/img1.png'),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 16, right: 16, top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${storeDataObj.storeName}',
                                                  style:
                                                      TextStyle(fontSize: 18),
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
                                                left: 16,
                                                right: 16,
                                                top: 5,
                                                bottom: 16),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${storeDataObj.state}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                ),
                                                /*Text(
                                        '${AppConstant.currency}350 for two',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),*/
                                              ],
                                            )),
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
                                    margin:
                                        EdgeInsets.only(top: 130, right: 20),
                                    padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                                    decoration: BoxDecoration(
                                        color: whiteWith70Opacity,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                      child: Text(
                                        "45 mins",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                    ),
                                    width: 70,
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
