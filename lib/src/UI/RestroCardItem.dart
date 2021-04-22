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

class RestroCardItem extends StatelessWidget {
  StoreData storeDataObj;

  CustomCallback callback;
  LatLng initialPosition;
  BrandData brandData;

  RestroCardItem(
      this.storeDataObj, this.callback, this.initialPosition, this.brandData);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
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
          callback(value: storeObject);
        });
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5), topLeft: Radius.circular(5)),
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
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Column(
                  children: [
                    Container(
                        height: 150,
                        child: storeDataObj.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    topLeft: Radius.circular(5)),
                                child: CachedNetworkImage(
                                    height: 150,
                                    width: Utils.getDeviceWidth(context),
                                    imageUrl: "${storeDataObj.image}",
                                    fit: BoxFit.cover))
                            : null,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)),
                          image: storeDataObj.image.isEmpty
                              ? DecorationImage(
                                  image:
                                      AssetImage('images/img_placeholder.jpg'),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        )),
                    Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                              '${storeDataObj.storeName}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 18),
                            )),
                            SizedBox(
                              width: 16,
                            ),
                            Visibility(
                                visible:
                                    brandData.display_store_rating == '1' &&
                                        storeDataObj.rating.isNotEmpty &&
                                        storeDataObj.rating != '0.0' &&
                                        storeDataObj.rating != '0',
                                child: Row(
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
                                      storeDataObj.rating,
                                      style: TextStyle(fontSize: 16),
                                    ),
//                                    Text(
//                                      '5',
//                                      style: TextStyle(
//                                          fontSize: 16, color: Colors.grey),
//                                    )
                                  ],
                                )),
                          ],
                        )),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 5, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: brandData.display_store_location == '1'
                                    ? Text(
                                        '${storeDataObj.location}',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      )
                                    : Container()),
                            Visibility(
                              visible: brandData.display_distance == '1',
                              child: Text(
//                                  '${storeDataObj.distance} kms',
                                '${_getDistance(storeDataObj)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
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
          Visibility(
              visible: brandData.display_prepration_time == '1' &&
                  storeDataObj.preparationTime.isNotEmpty,
              child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(top: 130, right: 20),
                    padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                    decoration: BoxDecoration(
                        color: whiteWith70Opacity,
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
//                    "45 mins",
                        '${storeDataObj.preparationTime} mins',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                    width: 70,
                  ))),
          Visibility(
            visible: !Utils.checkStoreOpenTiming(storeDataObj),
            child: Container(
              height: 170.0,
              color: Colors.white54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Store Closed",
                                style: TextStyle(color: Colors.red, fontSize: 18),
                              ),
                            )),

                      ],
                    ),
                    Container(
                        child: Padding(
                      padding: EdgeInsets.only(
                          left: 15, top: 5, bottom: 10, right: 15),
                      child: Text(
                        "${storeDataObj.timimg.closehoursMessage}",
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
          )
        ],
      ),
    );
  }

  _getDistance(StoreData storeDataObj) {
    if (initialPosition != null) {
      double distanceInKm = Utils.calculateDistance(
          initialPosition.latitude,
          initialPosition.longitude,
          double.parse(storeDataObj.lat),
          double.parse(storeDataObj.lng));
      return distanceInKm.toStringAsFixed(1) + ' kms';
    } else {
      return '';
    }
  }
}
