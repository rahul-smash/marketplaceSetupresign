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

class MarketPlaceHomeFiltersView extends StatefulWidget {
  LatLng initialPosition;
  CustomCallback callback;
  Map<String, HomeScreenSection> homeViewOrderMap;

  MarketPlaceHomeFiltersView(this.initialPosition,
      {this.callback, this.homeViewOrderMap});

  @override
  _MarketPlaceHomeFiltersViewState createState() =>
      _MarketPlaceHomeFiltersViewState();
}

class _MarketPlaceHomeFiltersViewState
    extends State<MarketPlaceHomeFiltersView> {
  List<Filter> tagsList = List.empty(growable: true);

  int selectedFilterIndex = -1;
  List<CategoriesData> categorieslist = new List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    addFilters();
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
              (widget.homeViewOrderMap[HomeScreenViewHelper.FILTER] != null &&
                  widget.homeViewOrderMap[HomeScreenViewHelper.FILTER].display),
          child: Container(
            margin: EdgeInsets.only(top: 15, left: 10, bottom: 10),
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
                          Utils.showToast("No Internet connection", false);
                          return;
                        }
                        Map<String, dynamic> data = {
                          "lat": widget.initialPosition == null
                              ? '0.0'
                              : widget.initialPosition.latitude,
                          "lng": widget.initialPosition == null
                              ? '0.0'
                              : widget.initialPosition.longitude,
                          "filter_by": tagsList[index].value,
                        };
                        Utils.showProgressDialog(context);
                        ApiController.getAllStores(params: data)
                            .then((storesResponse) {
                          Utils.hideProgressDialog(context);
                          Utils.hideKeyboard(context);
                          if (storesResponse != null &&
                              storesResponse.success) {
                            widget.callback(value: storesResponse);
                          } else {
                            DialogUtils.displayErrorDialog(
                                context, "${storesResponse.message}");
                          }
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
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : Row(
                                children: [
                                  Text('${tagsList[index].lable}',
                                      style: TextStyle(
                                          color: selectedFilterIndex == index
                                              ? Colors.grey[600]
                                              : Colors.grey)),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Visibility(
                                    visible: selectedFilterIndex == index
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
        ));
  }

  void addFilters() {
    Filter filterTag = Filter();
    filterTag.lable = "Filters";
    tagsList.add(filterTag);
    tagsList.addAll(SingletonBrandData.getInstance().brandVersionModel.brand.filters);
  }
}
