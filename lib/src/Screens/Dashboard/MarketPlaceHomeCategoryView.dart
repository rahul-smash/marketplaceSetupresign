import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/Screens/Dashboard/MarketPlaceHomeScreen.dart';
import 'package:restroapp/src/UI/MarketPlaceCategoryView.dart';
import 'package:restroapp/src/UI/RestroCardItem.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/Categorys.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TagsModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/HomeScreenContentText.dart';
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
  StoresModel storeData;
  TagsModel tagsModel;
  Map<String, HomeScreenSection> homeViewOrderMap;

  MarketPlaceHomeCategoryView(this.categoriesModel, this.initialPosition,
      this.brandData, this.subCategory,
      {this.callback, this.storeData, this.tagsModel, this.homeViewOrderMap});

  @override
  _MarketPlaceHomeCategoryViewState createState() =>
      _MarketPlaceHomeCategoryViewState();
}

class _MarketPlaceHomeCategoryViewState
    extends State<MarketPlaceHomeCategoryView> {
  List<Filter> tagsList = List.empty(growable: true);

  int selectedFilterIndex = -1;
  List<CategoriesData> categorieslist = new List.empty(growable: true);

  bool isCateSeeAll = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoriesModel != null) {
      if (widget.categoriesModel.data.length > 8) {
        isCateSeeAll = false;
        categorieslist = widget.categoriesModel.data;
        categorieslist = categorieslist.sublist(0, 8);
      } else {
        isCateSeeAll = false;
        categorieslist.addAll(widget.categoriesModel.data);
      }
    }
    eventBus.on<onLocationChanged>().listen((event) {
      setState(() {
        widget.initialPosition = event.latLng;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _makeView();
  }

  Widget _makeView() {
    return Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 2.5),
        child: Visibility(
          visible: (widget.homeViewOrderMap.length == 0) ||
              (widget.homeViewOrderMap[HomeScreenViewHelper.CATEGORIES] !=
                      null &&
                  widget.homeViewOrderMap[HomeScreenViewHelper.CATEGORIES]
                      .display),
          child: categorieslist.length == 0
              ? Container()
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getCategoryHeadingPlaceHolderText(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: GridView.count(
                          crossAxisCount: 4,
                          childAspectRatio: .75,
                          physics: NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 0.0,
                          shrinkWrap: true,
                          children:
                              categorieslist.map((CategoriesData model) {
                            return GridTile(
                              child: InkWell(
                                onTap: () async {
                                  print("onTap===>${model.id}");
                                  bool isNetworkAvailable =
                                      await Utils.isNetworkAvailable();
                                  if (!isNetworkAvailable) {
                                    Utils.showToast(
                                        "No Internet connection", false);
                                    return;
                                  }
                                  Map<String, dynamic> data = {
                                    "lat": widget.initialPosition == null
                                        ? '0.0'
                                        : widget.initialPosition.latitude,
                                    "lng": widget.initialPosition == null
                                        ? '0.0'
                                        : widget.initialPosition.longitude,
                                    "search_by": "category",
                                    "id": "${model.id}",
                                  };
                                  Utils.showProgressDialog(context);
                                  ApiController.getAllStores(params: data)
                                      .then((storesResponse) {
                                    Utils.hideProgressDialog(context);
                                    Utils.hideKeyboard(context);
                                    if (storesResponse != null &&
                                        storesResponse.success) {
                                      widget.callback(
                                          value: storesResponse);
                                    } else {
                                      DialogUtils.displayErrorDialog(
                                          context,
                                          "${storesResponse.message}");
                                    }
                                  });
                                },
                                child: MarketPlaceCategoryView(
                                  model,
                                  widget.brandData,
                                  false,
                                  0,
                                  isListView: true,
                                  selectedSubCategoryId:
                                      widget.selectedCategoryId,
                                ),
                              ),
                            );
                          }).toList()),
                    ),
                    Visibility(
                        visible: widget.categoriesModel != null &&
                            widget.categoriesModel.data != null &&
                            widget.categoriesModel.data.length > 8,
                        child: InkWell(
                            onTap: () {
                              print("onTap =isCateSeeAll=${isCateSeeAll}");
                              if (isCateSeeAll) {
                                isCateSeeAll = false;
                                if (widget.categoriesModel.data.length >
                                    8) {
                                  categorieslist =
                                      widget.categoriesModel.data;
                                  categorieslist =
                                      categorieslist.sublist(0, 8);
                                } else {
                                  categorieslist =
                                      widget.categoriesModel.data;
                                }
                              } else {
                                isCateSeeAll = true;
                                categorieslist =
                                    widget.categoriesModel.data;
                              }
                              setState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                              color: grayLightColor,
                              width: Utils.getDeviceWidth(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isCateSeeAll
                                        ? "View Less"
                                        : "View More",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(isCateSeeAll
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down)
                                ],
                              ),
                            ))),
                  ],
                ),
        ));
  }

  Widget getProductsWidget() {
    return Column(
      children: <Widget>[
        Container(
          height: 0,
          width: MediaQuery.of(context).size.width,
        ),
        widget.storeData.data != null && widget.storeData.data.isNotEmpty
            ? ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: widget.storeData.data.length,
                    itemBuilder: (context, index) {
                      StoreData storeDataObj = widget.storeData.data[index];
                      return RestroCardItem(storeDataObj, widget.callback,
                          widget.initialPosition, widget.brandData);
                    },
                  ),
                ],
              )
            : Container(),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }
}
