import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/UI/CartBottomView.dart';
import 'package:restroapp/src/UI/DishTileItem.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/UI/RestroCardItem.dart';
import 'package:restroapp/src/UI/RestroSearchItemCard.dart';
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
  List<dynamic> itemList = List();

  bool visibleAllRestro = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selctedTag = -1;
    isSearchEmpty = true;
    _scrollController = ScrollController();
    tagskey = GlobalKey();
    eventBus.on<onLocationChanged>().listen((event) {
      setState(() {
        widget.initialPosition = event.latLng;
      });
    });
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
          "lat": widget.initialPosition.latitude,
          "lng": widget.initialPosition.latitude,
          "search_by": "Keyword",
          "keyword": "${controller.text}",
        };
        ApiController.getAllStores(params: data).then((storesResponse) {
          Utils.hideProgressDialog(context);
          Utils.hideKeyboard(context);
          if (storesResponse != null) {
            allStoreData = storesResponse;
            itemList.clear();
            visibleAllRestro = false;
            _generalizedList();
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
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        if (itemList[index] is StoreData) {
                          StoreData storeDataObj = itemList[index];
                          return RestroSearchItemCard(storeDataObj,
                              widget.callback, widget.initialPosition);
                        } else if (itemList[index] is Dish) {
                          Dish dish = itemList[index];
                          return DishTileItem(
                              dish, widget.callback, widget.initialPosition);
                        } else {
                          return itemList[index];
                        }
                      },
                    ),
        ],
      ),
    );
  }

  _generalizedList() {
    if (allStoreData != null) {
      if (allStoreData.data != null&&allStoreData.data.isNotEmpty) {
        itemList.add(Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Restaurants",
                style: TextStyle(
                  fontSize: 18.0,
                  color: productHeadingColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Visibility(
                child: InkWell(
                  child: Text(
                    visibleAllRestro
                        ? "Hide all restaurant"
                        : "View all restaurant",
                    style: TextStyle(
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      color: appThemeSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    visibleAllRestro = !visibleAllRestro;
                    itemList.clear();
                    _generalizedList();
                    setState(() {

                    });
                  },
                ),
                visible: allStoreData.data.length > 2,
              ),
            ],
          ),
        ));
        itemList.addAll(allStoreData.data.length > 2
            ? visibleAllRestro
                ? allStoreData.data
                : allStoreData.data.sublist(0, 2)
            : allStoreData.data);
      }
      if (allStoreData.dishes != null&&allStoreData.dishes.isNotEmpty) {
        itemList.add(Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Dishes",
                style: TextStyle(
                  fontSize: 18.0,
                  color: productHeadingColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ));
        itemList.addAll(allStoreData.dishes);
      }
    }
  }
}
