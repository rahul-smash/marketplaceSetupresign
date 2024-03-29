import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/StoreOffersResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/utils/fdottedline.dart';

class OffersListDetail extends StatefulWidget {
  OfferModel offerModel;

  OffersListDetail(this.offerModel);

  @override
  _OffersListDetailState createState() => _OffersListDetailState();
}

class _OffersListDetailState extends State<OffersListDetail> {
  @override
  void initState() {
    super.initState();
    if (widget.offerModel.image == null ||
        (widget.offerModel.image != null && widget.offerModel.image.isEmpty)) {
      if (widget.offerModel.banner != null &&
          widget.offerModel.banner.isNotEmpty) {
        if (!widget.offerModel.banner
            .contains('https://d39vol41m7feya.cloudfront.net/'))
          widget.offerModel.image = 'https://d39vol41m7feya.cloudfront.net/' +
              widget.offerModel.banner;
        else
          widget.offerModel.image = widget.offerModel.banner;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
            child: Column(
          children: [
            Stack(
              children: [
                Container(
                    height: 170,
                    child: widget.offerModel.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(5),
                                topLeft: Radius.circular(5)),
                            child: CachedNetworkImage(
                                width: Utils.getDeviceWidth(context),
                                imageUrl: "${widget.offerModel.image}",
                                fit: BoxFit.cover),
                          )
                        : null,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          topLeft: Radius.circular(5)),
                      image: widget.offerModel.image.isEmpty
                          ? DecorationImage(
                              image:
                                  AssetImage('images/offerdetailgraphic.png'),
                              fit: BoxFit.cover,
                            )
                          : null,
                    )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Image.asset(
                        "images/backicon.png",
                        height: 15,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
                child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex:2,
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 16, left: 16),
                          child: Text("${widget.offerModel.name}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                              "${getOfferTypeFullVersion(widget.offerModel)}",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13)),
                        ),
                      ],
                    )),
                    Expanded(
                      flex:3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 45,
                            width: 1,
                            color: Colors.grey,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Use Code',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  )),
                              GestureDetector(
                                child: FDottedLine(
                                  corner: FDottedLineCorner(
                                      leftTopCorner: 5,
                                      leftBottomCorner: 5,
                                      rightBottomCorner: 5,
                                      rightTopCorner: 5),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                    child: Text(
                                      widget.offerModel.couponCode,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  color: yellowColor,
                                  strokeWidth: 2.0,
                                  dottedLength: 2.0,
                                  space: 2.0,
                                ),
                                onTap: () {
                                  Clipboard.setData(new ClipboardData(
                                      text: widget.offerModel.couponCode));
                                  Utils.showToast("Coupon code ${widget.offerModel.couponCode} copied to clipboard", false);
                                },
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                    color: Colors.blue,
                                    style: BorderStyle.none,
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
//                                    child:  Text(
//                                      offersResponse.offers[index].couponCode,
//                                      style: TextStyle(
//                                          fontSize: 14, color: Colors.grey),
//                                    )
                              ),
                            ],
                          ),
                          Visibility(
                            visible: widget.offerModel.minimumOrderAmount !=
                                    null &&
                                widget.offerModel.minimumOrderAmount.isNotEmpty,
                            child: Column(
                              children: [
                                Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      'Min Order',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    )),
                                Text(
                                  '${widget.offerModel.minimumOrderAmount}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  height: 1,
                  color: Colors.black45,
                ),
                Visibility(
                  visible: widget.offerModel.offerTermCondition != null &&
                      widget.offerModel.offerTermCondition.isNotEmpty,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16),
                          child: Text("Terms and Conditions",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text("${widget.offerModel.offerTermCondition}",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13)),
                        ),
                        Container(
                          height: 1,
                          color: Colors.black45,
                        )
                      ]),
                ),
                Visibility(
                  visible: widget.offerModel.validFrom != null &&
                      widget.offerModel.validFrom.isNotEmpty &&
                      widget.offerModel.validTo != null &&
                      widget.offerModel.validTo.isNotEmpty,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.all(16),
                          child: Text("Offer Validity",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                              "${widget.offerModel.validFrom} - ${widget.offerModel.validTo}",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 13)),
                        ),
                        Container(
                          height: 1,
                          color: Colors.black45,
                        )
                      ]),
                ),
              ],
            )),
          ],
        )),
      ),
    );
  }

  getOfferTypeText(OfferModel offer) {
    /*
    "discount_type": "3" == discount %oFF \n discount_upto black Uptp Rs100
    "discount_type": "2" == and discount_upto  OFF
    "discount_type": "1" == Uptp Rs100
    */

    String offerName = "";
    if (offer.discount_type == "3") {
      offerName = "${offer.discount}% OFF";
    }
    if (offer.discount_type == "2") {
      offerName = "${AppConstant.currency}${offer.discount_upto} Off";
    }
    if (offer.discount_type == "1") {
      offerName = "${AppConstant.currency}${offer.discount_upto} Off";
    }
    return offerName;
  }

  getOfferTypeFullVersion(OfferModel offer) {
    /*
    "discount_type": "3" == discount %oFF \n discount_upto black Uptp Rs100
    "discount_type": "2" == and discount_upto  OFF
    "discount_type": "1" == Uptp Rs100
    */

    String offerName = "";
    if (offer.discount_type == "3") {
      offerName =
          "${offer.discount}% OFF Upto ${AppConstant.currency}${offer.discount_upto}";
    }
    if (offer.discount_type == "2") {
      offerName = "Upto ${AppConstant.currency}${offer.discount_upto} Off";
    }
    if (offer.discount_type == "1") {
      offerName = "Upto ${AppConstant.currency}${offer.discount_upto} Off";
    }
    return offerName;
  }

//  Widget getView(int index) {
//    return InkWell(
//      onTap: () {},
//      child: Stack(
//        children: [
//          Container(
//            margin: EdgeInsets.all(10),
//            decoration: new BoxDecoration(
//              borderRadius: BorderRadius.only(
//                  topRight: Radius.circular(5), topLeft: Radius.circular(5)),
//              boxShadow: [
//                BoxShadow(
//                  color: Colors.grey,
//                  spreadRadius: 1,
//                  blurRadius: 5,
//                  //offset: Offset(10, 13), // changes position of shadow
//                ),
//              ],
//            ),
//            child: Container(
//                decoration: BoxDecoration(
//                  color: Colors.white,
//                  borderRadius: BorderRadius.all(Radius.circular(5)),
//                ),
//                child: Column(
//                  children: [
//                    Container(
//                        height: 130,
//                        child: offersResponse.offers[index].image.isNotEmpty
//                            ? ClipRRect(
//                                borderRadius: BorderRadius.only(
//                                    topRight: Radius.circular(5),
//                                    topLeft: Radius.circular(5)),
//                                child: CachedNetworkImage(
//                                    height: 150,
//                                    width: Utils.getDeviceWidth(context),
//                                    imageUrl:
//                                        "${offersResponse.offers[index].image}",
//                                    fit: BoxFit.cover),
//                              )
//                            : null,
//                        decoration: BoxDecoration(
//                          color: Colors.white,
//                          borderRadius: BorderRadius.only(
//                              topRight: Radius.circular(5),
//                              topLeft: Radius.circular(5)),
//                          image: offersResponse.offers[index].image.isEmpty
//                              ? DecorationImage(
//                                  image: AssetImage('images/offerdetailgraphic.png'),
//                                  fit: BoxFit.cover,
//                                )
//                              : null,
//                        )),
//                    Padding(
//                        padding: EdgeInsets.all(16),
//                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.baseline,
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: [
//                            Expanded(
//                                child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: [
//                                Text(
//                                  '${offersResponse.offers[index].name}',
//                                  style: TextStyle(fontSize: 16),
//                                ),
//                                SizedBox(
//                                  height: 5,
//                                ),
//                                Text(
//                                  '${getOfferTypeFullVersion(offersResponse.offers[index])}',
//                                  style: TextStyle(
//                                      color: Colors.black45, fontSize: 14),
//                                ),
//                              ],
//                            )),
//                            Expanded(
//                              child: Row(
//                                crossAxisAlignment: CrossAxisAlignment.baseline,
//                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                children: [
//                                  Container(
//                                    height: 40,
//                                    width: 1,
//                                    color: Colors.grey,
//                                  ),
//                                  Column(
//                                    crossAxisAlignment:
//                                        CrossAxisAlignment.center,
//                                    children: [
//                                      Text(
//                                        'Use Code',
//                                        style: TextStyle(
//                                            fontSize: 14, color: Colors.grey),
//                                      ),
//                                      SizedBox(
//                                        height: 3,
//                                      ),
//                                      FDottedLine(
//                                        corner: FDottedLineCorner(
//                                            leftTopCorner: 5,
//                                            leftBottomCorner: 5,
//                                            rightBottomCorner: 5,
//                                            rightTopCorner: 5),
//                                        child: Padding(
//                                          padding:
//                                              EdgeInsets.fromLTRB(10, 2, 10, 2),
//                                          child: Text(
//                                            offersResponse
//                                                .offers[index].couponCode,
//                                            style: TextStyle(
//                                                fontSize: 14,
//                                                color: Colors.grey),
//                                          ),
//                                        ),
//                                        color: yellowColor,
//                                        strokeWidth: 1.0,
//                                        dottedLength: 2.0,
//                                        space: 2.0,
//                                      ),
//                                      Container(
//                                        margin: EdgeInsets.only(right: 5),
//                                        decoration: BoxDecoration(
//                                          border: Border.all(
//                                            width: 2.0,
//                                            color: Colors.blue,
//                                            style: BorderStyle.none,
//                                          ),
//                                          shape: BoxShape.rectangle,
//                                        ),
////                                    child:  Text(
////                                      offersResponse.offers[index].couponCode,
////                                      style: TextStyle(
////                                          fontSize: 14, color: Colors.grey),
////                                    )
//                                      ),
//                                    ],
//                                  ),
//                                  Visibility(
//                                    visible: offersResponse.offers[index]
//                                                .minimumOrderAmount !=
//                                            null &&
//                                        offersResponse.offers[index]
//                                            .minimumOrderAmount.isNotEmpty,
//                                    child: Column(
//                                      children: [
//                                        Text(
//                                          'Min Order',
//                                          style: TextStyle(
//                                              fontSize: 14, color: Colors.grey),
//                                        ),
//                                        SizedBox(
//                                          height: 5,
//                                        ),
//                                        Text(
//                                          '${offersResponse.offers[index].minimumOrderAmount}',
//                                          style: TextStyle(
//                                              fontSize: 14, color: Colors.grey),
//                                        )
//                                      ],
//                                    ),
//                                  )
//                                ],
//                              ),
//                            )
//                          ],
//                        )),
//                  ],
//                )),
//          ),
//          Container(
//            margin: EdgeInsets.only(top: 100),
//            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
//            decoration: BoxDecoration(
//                color: yellowColor, borderRadius: BorderRadius.circular(5)),
//            child: Text(
//              getOfferTypeText(offersResponse.offers[index]),
//              style: TextStyle(color: Colors.white, fontSize: 12),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
}
