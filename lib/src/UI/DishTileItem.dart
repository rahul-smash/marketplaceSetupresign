import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:html/parser.dart';

class DishTileItem extends StatefulWidget {
  Dish dish;
  CustomCallback callback;
  CustomCallback dishCallBack;
  List<String> tagsList = List.empty(growable: true);
  LatLng initialPosition;

  DishTileItem(
    this.dish,
    this.callback,
    this.initialPosition,{this.dishCallBack}
  );

  @override
  _DishTileItemState createState() => _DishTileItemState();
}

class _DishTileItemState extends State<DishTileItem> {
  @override
  initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(DishTileItem oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String discount, price, mrpPrice;
    String imageUrl =
        widget.dish.image == null ? widget.dish.image10080 : widget.dish.image;

    return Container(
      padding: EdgeInsets.only(top: 15),
//      color: listingBoxBackgroundColor,
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () async {
            bool isNetworkAvailable = await Utils.isNetworkAvailable();
            if (!isNetworkAvailable) {
              Utils.showToast("No Internet connection", false);
              return;
            }
            Utils.showProgressDialog(context);
            ApiController.getStoreVersionData(widget.dish.storeId)
                .then((response) {
              Utils.hideProgressDialog(context);
              Utils.hideKeyboard(context);
              StoreDataModel storeObject = response;
              if (storeObject != null && storeObject.success)
                storeObject.store.dish = widget.dish;
              widget.callback(value: storeObject);
              widget.dishCallBack(value: widget.dish);
            });
          },
          child: Padding(
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
                                        child: imageUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: "${imageUrl}",
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
//                                            Visibility(
//                                              visible: AppConstant.isRestroApp,
//                                              child: addVegNonVegOption(),
//                                            ),
                                        Expanded(
                                          child: Text("${widget.dish.title}",
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
//                                        Padding(
//                                          padding: EdgeInsets.only(top: 5),
//                                          child: Row(
//                                            mainAxisAlignment:
//                                            MainAxisAlignment.spaceBetween,
//                                            children: <Widget>[
//                                              (discount == "0.00" ||
//                                                  discount == "0" ||
//                                                  discount == "0.0")
//                                                  ? Text(
//                                                "${AppConstant.currency}${price}",
//                                                style: TextStyle(
//                                                    color:
//                                                    productHeadingColor,
//                                                    fontWeight:
//                                                    FontWeight.w400,
//                                                    fontSize: 16.0),
//                                              )
//                                                  : Row(
//                                                children: <Widget>[
//                                                  Text(
//                                                    "${AppConstant.currency}${price}",
//                                                    style: TextStyle(
//                                                        color:
//                                                        productHeadingColor,
//                                                        fontWeight:
//                                                        FontWeight.w400,
//                                                        fontSize: 16.0),
//                                                  ),
//                                                  Text(" "),
//                                                  Text(
//                                                      "${AppConstant.currency}${mrpPrice}",
//                                                      style: TextStyle(
//                                                          decoration:
//                                                          TextDecoration
//                                                              .lineThrough,
//                                                          color:
//                                                          staticHomeDescriptionColor,
//                                                          fontWeight:
//                                                          FontWeight.w400,
//                                                          fontSize: 14.0)),
//                                                ],
//                                              ),
//                                            ],
//                                          ),
//                                        ),
                                    Container(
                                        // color: Colors.blue,
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10, top: 5, bottom: 5),
                                            child: Text(
                                              removeAllHtmlTags(
                                                  "${widget.dish.subCategory}"),
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
//                                                Container(
//                                                  width: 10,
//                                                ),
//                                                Align(
//                                                  alignment: Alignment.bottomRight,
//                                                  child: addQuantityView(variantId),
//                                                ),
                                      ],
                                    )),
                                    Container(
                                        // color: Colors.blue,
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10, top: 5, bottom: 5),
                                            child: Text(
                                              removeAllHtmlTags(
                                                  "${widget.dish.store_name}"),
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
//                                                Container(
//                                                  width: 10,
//                                                ),
//                                                Align(
//                                                  alignment: Alignment.bottomRight,
//                                                  child: addQuantityView(variantId),
//                                                ),
                                      ],
                                    ))
                                  ],
                                ))),
                      ],
                    )),
                  ])),
        ),
        Container(
            height: 1,
            width: MediaQuery.of(context).size.width,
            color: listingBorderColor)
      ]),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    try {
      var document = parse(htmlText);
      String parsedString = parse(document.body.text).documentElement.text;
      return parsedString;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
