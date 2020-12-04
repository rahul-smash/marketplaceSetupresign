import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/TagsModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';

class RestroListScreen extends StatefulWidget {
  StoresModel allStoreData;
  CustomCallback callback;
  HomeScreenEnum selectedScreen;
  LatLng initialPosition;
  TagsModel tagsModel;

  RestroListScreen(this.allStoreData,
      {this.callback,
      this.initialPosition,
      this.tagsModel,
      this.selectedScreen});

  @override
  _RestroListScreenState createState() => _RestroListScreenState();
}

class _RestroListScreenState extends State<RestroListScreen> {
  bool isSeeAll = false;
  bool isCateSeeAll = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
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
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          "All Restaurants",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showBottomSheet(context);
                        },
                        child: Container(
                          height: 30,
                          margin: EdgeInsets.only(left: 4, right: 4),
                          padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: grayLightColor, width: 1),
                              borderRadius: BorderRadius.circular(2)),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/filtericon.png",
                                height: 20,
                                width: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Filters',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                getProductsWidget()
              ],
            )),
      ],
    ));
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
                if (storesResponse != null && storesResponse.success) {
                  widget.allStoreData = storesResponse;
                }
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
            !isSeeAll
                ? widget.tagsModel.data.length > (4)
                    ? (4)
                    : widget.tagsModel.data.length
                : widget.tagsModel.data.length);
  }

  Widget getProductsWidget() {
    return Column(
      children: <Widget>[
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: widget.allStoreData.data.length,
              itemBuilder: (context, index) {
                StoreData storeDataObj = widget.allStoreData.data[index];
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          topLeft: Radius.circular(5)),
                                      child: storeDataObj.image.isNotEmpty
                                          ? CachedNetworkImage(
                                              height: 150,
                                              width:
                                                  Utils.getDeviceWidth(context),
                                              imageUrl: "${storeDataObj.image}",
                                              fit: BoxFit.cover)
                                          : null,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          topLeft: Radius.circular(5)),
                                      image: storeDataObj.image.isEmpty
                                          ? DecorationImage(
                                              image:
                                                  AssetImage('images/img1.png'),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, top: 10),
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
                                        left: 16,
                                        right: 16,
                                        top: 5,
                                        bottom: 16),
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
                            margin: EdgeInsets.only(top: 130, right: 20),
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
                if (storesResponse != null && storesResponse.success) {
                widget.allStoreData=storesResponse;
                }
              });
            }),
          );
        });
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
