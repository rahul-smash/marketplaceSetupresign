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

class MarketPlaceHomeStoresView extends StatefulWidget {
  LatLng initialPosition;

  CustomCallback callback;
  BrandData brandData;

  //Product from SubCategory are going to display on the home screen
  CategoryModel selectedCategory;
  String selectedCategoryId;
  StoresModel storeData;
  TagsModel tagsModel;
  Map<String, HomeScreenSection> homeViewOrderMap;

  MarketPlaceHomeStoresView(
      this.initialPosition, this.brandData,
      {this.callback, this.storeData, this.tagsModel, this.homeViewOrderMap});

  @override
  _MarketPlaceHomeStoresViewState createState() =>
      _MarketPlaceHomeStoresViewState();
}

class _MarketPlaceHomeStoresViewState extends State<MarketPlaceHomeStoresView> {
  @override
  void initState() {
    super.initState();
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
              (widget.homeViewOrderMap[HomeScreenViewHelper.STORES] != null &&
                  widget.homeViewOrderMap[HomeScreenViewHelper.STORES].display),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.storeData == null
                  ? Utils.showIndicator()
                  : widget.storeData != null &&
                          widget.storeData.data != null &&
                          widget.storeData.data.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                child: Text(
                                  getStoreHeadingPlaceHolderText(),
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
                                    getStoreShowAllPlaceHolderText(),
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
                                      "lat": widget.initialPosition == null
                                          ? '0.0'
                                          : widget.initialPosition.latitude,
                                      "lng": widget.initialPosition == null
                                          ? '0.0'
                                          : widget.initialPosition.longitude,
                                    };
                                    Utils.showProgressDialog(context);
                                    ApiController.getAllStores(params: data)
                                        .then((storesResponse) {
                                      Utils.hideProgressDialog(context);
                                      Utils.hideKeyboard(context);
                                      if (storesResponse != null &&
                                          storesResponse.success)
                                        setState(() {
                                          widget.callback(
                                              value: storesResponse);
                                        });
                                      else {
                                        DialogUtils.displayErrorDialog(context,
                                            "${storesResponse.message}");
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
              widget.storeData == null ? Container() : getProductsWidget(),
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
