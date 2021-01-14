import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';

class RestroSearchItemCard extends StatelessWidget {
  StoreData storeDataObj;

  CustomCallback callback;
  LatLng initialPosition;

  RestroSearchItemCard(this.storeDataObj, this.callback, this.initialPosition);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
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
      child: Container(
        padding: EdgeInsets.only(top: 15),
//      color: listingBoxBackgroundColor,
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                          left: 2, top: 2, right: 2, bottom: 2),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                              "${storeDataObj.storeName}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                color: productHeadingColor,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ),
                                      ],
                                    ),
                                    Container(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10, top: 5, bottom: 5),
                                            child: Text(
                                              "${storeDataObj.location}, ${storeDataObj.city}, ${storeDataObj.state}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      staticHomeDescriptionColor,
                                                  fontWeight: FontWeight.w400),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                    Container(
                                      height: 2,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
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
                                                color:
                                                    appThemeSecondary,
                                                fontWeight: FontWeight.w400),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.arrow_right,color: appThemeSecondary,)
                                      ],
                                    )),
                                    Visibility(
                                        visible: storeDataObj
                                            .preparationTime.isNotEmpty,
                                        child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,0, 5, 3),
                                              decoration: BoxDecoration(
                                                  color: whiteWith70Opacity,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text(
                                                'Delivery in ${storeDataObj.preparationTime} mins',
                                                style: TextStyle(
                                                    color: staticHomeDescriptionColor,
                                                    fontSize: 12),
                                              ),
                                            )))
                                  ],
                                ))),
                      ],
                    )),
                  ])),
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
