import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  MarketPlaceHomeCategoryView(this.categoriesModel, this.initialPosition,
      this.brandData, this.subCategory,
      {this.callback, this.storeData, this.tagsModel});

  @override
  _MarketPlaceHomeCategoryViewState createState() =>
      _MarketPlaceHomeCategoryViewState();
}

class _MarketPlaceHomeCategoryViewState
    extends State<MarketPlaceHomeCategoryView> {
  List<Filter> tagsList = List();

  int selectedFilterIndex = -1;
  List<CategoriesData> categorieslist = new List();

  bool isSeeAll = false;
  bool isCateSeeAll = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoriesModel.data.length > 8) {
      isCateSeeAll = false;
      categorieslist = widget.categoriesModel.data;
      categorieslist = categorieslist.sublist(0, 8);
    } else {
      isCateSeeAll = false;
      categorieslist.addAll(widget.categoriesModel.data);
    }
    addFilters();
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
                  visible: true,
                  child: Column(
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
                              "Your neighbours are ordering..",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            InkWell(
                              onTap: () {
                                print("onTap =isCateSeeAll=${isCateSeeAll}");
                                if (isCateSeeAll) {
                                  isCateSeeAll = false;
                                  if (widget.categoriesModel.data.length > 8) {
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
                                  categorieslist = widget.categoriesModel.data;
                                }
                                setState(() {});
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
                                      "lst": widget.initialPosition.latitude,
                                      "lng": widget.initialPosition.latitude,
                                      "search_by": "category",
                                      "id": "${model.id}",
                                    };
                                    Utils.showProgressDialog(context);
                                    ApiController.getAllStores(params: data)
                                        .then((storesResponse) {
                                      Utils.hideProgressDialog(context);
                                      Utils.hideKeyboard(context);
                                      if (storesResponse != null &&
                                          storesResponse.success)
                                        widget.callback(value: storesResponse);
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
                      Container(
                        margin: EdgeInsets.only(top: 10, left: 10),
                        height: 30,
                        child: Container(
                          height: 30,
                          child: ListView.builder(
                            itemCount: tagsList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  print("onTap=${index}");
                                  if (index != 0) {
                                    bool isNetworkAvailable =
                                        await Utils.isNetworkAvailable();
                                    if (!isNetworkAvailable) {
                                      Utils.showToast(
                                          "No Internet connection", false);
                                      return;
                                    }
                                    Map<String, dynamic> data = {
                                      "lst": widget.initialPosition.latitude,
                                      "lng": widget.initialPosition.latitude,
                                      "filter_by": tagsList[index].value,
                                    };
                                    Utils.showProgressDialog(context);
                                    ApiController.getAllStores(params: data)
                                        .then((storesResponse) {
                                      Utils.hideProgressDialog(context);
                                      Utils.hideKeyboard(context);
                                      if (storesResponse != null &&
                                          storesResponse.success)
                                        widget.callback(value: storesResponse);
                                    });
                                    setState(() {
                                      selectedFilterIndex = index;
                                    });
                                  }
                                },
                                child: Container(
                                    height: 30,
                                    margin: EdgeInsets.only(left: 4, right: 4),
                                    padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
                                    decoration: BoxDecoration(
                                        color: selectedFilterIndex == index
                                            ? Colors.grey[200]
                                            : Colors.white,
                                        border: Border.all(
                                            color: selectedFilterIndex == index
                                                ? Colors.grey[400]
                                                : grayLightColor,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(2)),
                                    child: index == 0
                                        ? Row(
                                            children: [
                                              Image.asset(
                                                "images/filtericon.png",
                                                height: 20,
                                                width: 20,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text('${tagsList[index].lable}',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Text('${tagsList[index].lable}',
                                                  style: TextStyle(
                                                      color:
                                                          selectedFilterIndex ==
                                                                  index
                                                              ? Colors.grey[600]
                                                              : Colors.grey)),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Visibility(
                                                visible:
                                                    selectedFilterIndex == index
                                                        ? true
                                                        : false,
                                                child: Icon(
                                                  Icons.clear,
                                                  size: 15,
                                                ),
                                              )
                                            ],
                                          )),
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
                            onTap: () {
                              print("onTap =isSeeAll=${isSeeAll}");
                              setState(() {
                                if (isSeeAll) {
                                  isSeeAll = false;
                                } else {
                                  isSeeAll = true;
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
                widget.tagsModel == null
                    ? Utils.showIndicator()
                    : GridView.count(
                        crossAxisCount: 4,
                        childAspectRatio: 1.4,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 1.0,
                        crossAxisSpacing: 0.0,
                        shrinkWrap: true,
                        children: _getQuickLinksItem()),
                widget.storeData == null
                    ? Utils.showIndicator()
                    : Padding(
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkWell(
                              child: Text(
                                "Restaurants",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Visibility(
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
                                  bool isNetworkAvailable =
                                      await Utils.isNetworkAvailable();
                                  if (!isNetworkAvailable) {
                                    Utils.showToast(
                                        "No Internet connection", false);
                                    return;
                                  }
                                  Map<String, dynamic> data = {
                                    "lst": widget.initialPosition.latitude,
                                    "lng": widget.initialPosition.latitude,
                                  };
                                  Utils.showProgressDialog(context);
                                  ApiController.getAllStores(params: data)
                                      .then((storesResponse) {
                                    Utils.hideProgressDialog(context);
                                    Utils.hideKeyboard(context);
                                    setState(() {
                                      widget.callback(value: storesResponse);
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                widget.storeData == null ? Container() : getProductsWidget()
              ],
            )),
      ],
    );
  }

  void showBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Colors.white,
            child: FilterRadioGroup((selectedFilter) async {
              print("selectedFilter=${selectedFilter}");
              bool isNetworkAvailable = await Utils.isNetworkAvailable();
              if (!isNetworkAvailable) {
                Utils.showToast("No Internet connection", false);
                return;
              }
              Map<String, dynamic> data = {
                "lst": widget.initialPosition.latitude,
                "lng": widget.initialPosition.latitude,
                "filter_by": "${selectedFilter}",
              };
              Utils.showProgressDialog(context);
              ApiController.getAllStores(params: data).then((storesResponse) {
                Utils.hideProgressDialog(context);
                Utils.hideKeyboard(context);
                if (storesResponse != null && storesResponse.success)
                  widget.callback(value: storesResponse);
              });
            }),
          );
        });
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
              itemCount: widget.storeData.data.length,
              itemBuilder: (context, index) {
                StoreData storeDataObj = widget.storeData.data[index];
                return RestroCardItem(storeDataObj,widget.callback,widget.initialPosition);
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

  void addFilters() {
    Filter filterTag = Filter();
    filterTag.lable = "Filters";
    tagsList.add(filterTag);
    tagsList.addAll(BrandModel.getInstance().brandVersionModel.brand.filters);
  }

  _getQuickLinksItem() {
    return widget.tagsModel.data
        .map((TagData tagObject) {
          return InkWell(
            onTap: () async {
              bool isNetworkAvailable = await Utils.isNetworkAvailable();
              if (!isNetworkAvailable) {
                Utils.showToast("No Internet connection", false);
                return;
              }
              Map<String, dynamic> data = {
                "lst": widget.initialPosition.latitude,
                "lng": widget.initialPosition.latitude,
                "search_by": "tag",
                "id": "${tagObject.id}",
              };
              Utils.showProgressDialog(context);
              ApiController.getAllStores(params: data).then((storesResponse) {
                Utils.hideProgressDialog(context);
                Utils.hideKeyboard(context);
                if (storesResponse != null && storesResponse.success)
                  widget.callback(value: storesResponse);
              });
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                  image: NetworkImage("${tagObject.image}"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        })
        .toList()
        .sublist(
            0,
            isSeeAll
                ? widget.tagsModel.data.length
                : (widget.tagsModel.data.length > 8)
                    ? 8
                    : widget.tagsModel.data.length);
  }
}

class FilterRadioGroup extends StatefulWidget {
  Function(String) onFilterSelectedCallback;

  FilterRadioGroup(this.onFilterSelectedCallback);

  @override
  RadioGroupWidget createState() => RadioGroupWidget();
}

class RadioGroupWidget extends State<FilterRadioGroup> {
  List<Filter> filters =
      BrandModel.getInstance().brandVersionModel.brand.filters;

  // Default Radio Button Selected Item.
  String radioItemHolder = '';

  // Group Value for Radio Button.
  String id = "";

  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Wrap(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Filter', style: TextStyle(fontSize: 20)),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.clear),
                  )
                ],
              )),
          Wrap(
            children: filters.map((data) {
              return RadioListTile(
                title: Text("${data.lable}"),
                groupValue: id,
                value: data.value,
                onChanged: (val) {
                  setState(() {
                    radioItemHolder = data.lable;
                    id = data.value;
                  });
                },
              );
            }).toList(),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: ButtonTheme(
                    height: 40,
                    minWidth: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Clear All",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ButtonTheme(
                    height: 40,
                    minWidth: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      elevation: 0.0,
                      onPressed: () {
                        print(
                            "radioItemHolder=${radioItemHolder} and id=${id}");
                        if (id.isEmpty) {
                          Utils.showToast("Please select filter", true);
                        } else {
                          widget.onFilterSelectedCallback(id);
                          Navigator.pop(context);
                        }
                      },
                      color: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Apply",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
