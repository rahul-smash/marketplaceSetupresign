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

class MarketPlaceHomeTagsView extends StatefulWidget {
  LatLng initialPosition;

  CustomCallback callback;

  TagsModel tagsModel;
  Map<String, HomeScreenSection> homeViewOrderMap;

  MarketPlaceHomeTagsView(this.initialPosition,
      {this.callback, this.tagsModel, this.homeViewOrderMap});

  @override
  _MarketPlaceHomeTagsViewState createState() =>
      _MarketPlaceHomeTagsViewState();
}

class _MarketPlaceHomeTagsViewState
    extends State<MarketPlaceHomeTagsView> {
  bool isSeeAll = false;

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
                (widget.homeViewOrderMap[HomeScreenViewHelper.TAGS] != null &&
                    widget.homeViewOrderMap[HomeScreenViewHelper.TAGS].display),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        getTagHeadingPlaceHolderText(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      Visibility(
                        visible: widget.tagsModel != null &&
                            widget.tagsModel.data.length > 8,
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
              ],
            )));
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
                "lat": widget.initialPosition == null
                    ? '0.0'
                    : widget.initialPosition.latitude,
                "lng": widget.initialPosition == null
                    ? '0.0'
                    : widget.initialPosition.longitude,
                "search_by": "tag",
                "id": "${tagObject.id}",
              };
              Utils.showProgressDialog(context);
              ApiController.getAllStores(params: data).then((storesResponse) {
                Utils.hideProgressDialog(context);
                Utils.hideKeyboard(context);
                if (storesResponse != null && storesResponse.success)
                  widget.callback(value: storesResponse);
                else {
                  DialogUtils.displayErrorDialog(
                      context, "${storesResponse.message}");
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
            isSeeAll
                ? widget.tagsModel.data.length
                : (widget.tagsModel.data.length > 8)
                    ? 8
                    : widget.tagsModel.data.length);
  }
}
