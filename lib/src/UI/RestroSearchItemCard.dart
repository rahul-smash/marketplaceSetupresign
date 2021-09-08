import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class RestroSearchItemCard extends StatelessWidget {
  StoreData storeDataObj;

  CustomCallback callback;
  LatLng initialPosition;
  BrandData brandData;
  String searchKeyword = '';

  RestroSearchItemCard(
      this.storeDataObj, this.callback, this.initialPosition, this.brandData,
      {this.searchKeyword});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (storeDataObj.storeStatus == "0") {
          DialogUtils.displayCommonDialog(
            context,
            storeDataObj.storeName,
            storeDataObj.storeMsg,
          );
          return;
        }
        if (!Utils.checkStoreOpenTiming(storeDataObj)) {
          DialogUtils.displayCommonDialog(
            context,
            storeDataObj.storeName,
            storeDataObj.timimg.closehoursMessage,
          );
          return;
        }
        bool isNetworkAvailable = await Utils.isNetworkAvailable();
        if (!isNetworkAvailable) {
          Utils.showToast("No Internet connection", false);
          return;
        }
        print("----onTap-${storeDataObj.id}--");
        Utils.showProgressDialog(context);
        ApiController.getStoreVersionData(storeDataObj.id).then((response) {
          Utils.hideProgressDialog(context);
          Utils.hideKeyboard(context);
          StoreDataModel storeObject = response;
          //TODO: Commented due to store keyword will not searched
//          storeObject.store.searchKeyWord = searchKeyword;
          callback(value: storeObject);
        });
      },
      child: Container(
        padding: EdgeInsets.only(top: 15),
//      color: listingBoxBackgroundColor,
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 0, bottom: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 10),
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 7, right: 20, top: 5),
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              left: 2,
                                              top: 2,
                                              right: 2,
                                              bottom: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          width: 75.0,
                                          height: 75.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: storeDataObj.image.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        "${storeDataObj.image}",
                                                    fit: BoxFit.cover)
                                                : Image.asset(
                                                    'images/img_placeholder.jpg',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ))),
                                ],
                              ),
                            ),
                            Flexible(
                                child: Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                  "${storeDataObj.storeName}",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: productHeadingColor,
                                                    fontWeight: FontWeight.w500,
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible: brandData
                                                  .display_store_location ==
                                              '1',
                                          child: Container(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10,
                                                      top: 5,
                                                      bottom: 5),
                                                  child: Text(
                                                    "${storeDataObj.location}, ${storeDataObj.city}, ${storeDataObj.state}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            staticHomeDescriptionColor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                        ),
                                        Container(
                                          height: 2,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: listingBorderColor,
                                          ),
                                        ),
                                        Container(
                                            child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 0, top: 5, bottom: 5),
                                              child: Text(
                                                "Order Now",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: appThemeSecondary,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_right,
                                              color: appThemeSecondary,
                                            )
                                          ],
                                        )),
                                        Visibility(
                                            visible: storeDataObj
                                                .preparationTime.isNotEmpty,
                                            child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 5, 3),
                                                  decoration: BoxDecoration(
                                                      color: whiteWith70Opacity,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Text(
                                                    'Delivery in ${storeDataObj.preparationTime} mins',
                                                    style: TextStyle(
                                                        color:
                                                            staticHomeDescriptionColor,
                                                        fontSize: 12),
                                                  ),
                                                )))
                                      ],
                                    ))),
                          ],
                        )),
                      ])),
              Visibility(
                visible: !Utils.checkStoreOpenTiming(storeDataObj) ||
                    storeDataObj.storeStatus == "0",
                child: Padding(
                  padding: EdgeInsets.only(left: 7, right: 20, top: 5),
                  child: Container(
                    height: 80.0,
                    color: Colors.white.withOpacity(0.9),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.red, width: 1),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Text(
                                  "Store Closed",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              )),
                          Container(
                              child: Padding(
                            padding: EdgeInsets.only(
                                left: 15, top: 5, bottom: 10, right: 15),
                            child: Text(
                              storeDataObj.storeStatus == "0"
                                  ? "${storeDataObj.storeMsg}"
                                  : "${storeDataObj.timimg.closehoursMessage}",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
              height: 1,
              width: MediaQuery.of(context).size.width,
              color: listingBorderColor)
        ]),
      ),
    );
  }

  _getDistance(StoreData storeDataObj) {
    double distanceInKm = Utils.calculateDistance(
        initialPosition.latitude,
        initialPosition.longitude,
        double.parse(storeDataObj.lat),
        double.parse(storeDataObj.lng));
    return distanceInKm.toStringAsFixed(1);
  }
}
