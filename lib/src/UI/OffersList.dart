import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restroapp/src/UI/OffersListDetail.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/DynamicResponse.dart';
import 'package:restroapp/src/models/StoreOffersResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/utils/fdottedline.dart';

class OffersListScreenScreen extends StatefulWidget {
  OffersListScreenScreen();

  @override
  _OffersListScreenScreenState createState() => _OffersListScreenScreenState();
}

class _OffersListScreenScreenState extends State<OffersListScreenScreen> {
  bool isLoading = true;
  StoreOffersResponse offersResponse;
  DynamicResponse dynamicResponse;

  @override
  void initState() {
    super.initState();
    dynamicResponse=AppConstant.dynamicResponse;
    if(dynamicResponse!=null)


    ApiController.homeOffersApiRequest().then((value) {
      isLoading = false;
      if (value != null && value.success) {
        offersResponse = value;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        "images/graphicimg.png",
                        width: Utils.getDeviceWidth(context),
                      ),
                    ),
                  ),
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
                      Padding(
                        padding: EdgeInsets.only(left: 26, right: 16),
                        child: Text(
                          dynamicResponse != null
                              ? dynamicResponse.data.offerPage.heading1
                              : "",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 26, right: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                    dynamicResponse != null
                                        ? dynamicResponse
                                            .data.offerPage.heading2
                                        : "",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14)),
                              ),
                              Expanded(child: Container())
                            ],
                          )),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : offersResponse == null
                        ? Utils.getEmptyView2('No Data Found!')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 5),
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        'Restaurants with offers (${offersResponse.offers.length})',
                                    style: TextStyle(
                                        fontFamily: 'Medium',
                                        fontSize: 16,
                                        color: Colors.black),
                                    children: [],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(16, 0, 16, 10),
                                child: Text(
                                    "All offers and deals, from restaurants near you",
                                    style: TextStyle(
                                        color: Colors.black45, fontSize: 13)),
                              ),
                              Expanded(
                                  child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5)),
                                margin:
                                    EdgeInsets.only(top: 0, left: 6, right: 6),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: offersResponse.offers.length,
                                  itemBuilder: (context, index) {
                                    return getView(index);
                                  },
                                ),
                              ))
                            ],
                          ),
              )
            ],
          ),
        ),
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

  Widget getView(int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OffersListDetail(offersResponse.offers[index])),
        );
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
                        height: 130,
                        child: offersResponse.offers[index].image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    topLeft: Radius.circular(5)),
                                child: CachedNetworkImage(
                                    height: 150,
                                    width: Utils.getDeviceWidth(context),
                                    imageUrl:
                                        "${offersResponse.offers[index].image}",
                                    fit: BoxFit.cover),
                              )
                            : null,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)),
                          image: offersResponse.offers[index].image.isEmpty
                              ? DecorationImage(
                                  image: AssetImage(
                                      'images/offerdetailgraphic.png'),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        )),
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
//                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${offersResponse.offers[index].name}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${getOfferTypeFullVersion(offersResponse.offers[index])}',
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 14),
                                ),
                              ],
                            )),
                            Expanded(
                              child: Row(
//                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Use Code',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      GestureDetector(
                                        child: FDottedLine(
                                          corner: FDottedLineCorner(
                                              leftTopCorner: 5,
                                              leftBottomCorner: 5,
                                              rightBottomCorner: 5,
                                              rightTopCorner: 5),
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 2, 10, 2),
                                            child: Text(
                                              offersResponse
                                                  .offers[index].couponCode,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          color: yellowColor,
                                          strokeWidth: 1.0,
                                          dottedLength: 2.0,
                                          space: 2.0,
                                        ),
                                        onTap: () {
                                          Clipboard.setData(new ClipboardData(
                                              text: offersResponse
                                                  .offers[index].couponCode));
                                          Utils.showToast(
                                              "Coupon code ${offersResponse.offers[index].couponCode} copied to clipboard!",
                                              false);
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
                                  Flexible(
                                    child: Visibility(
                                      visible: offersResponse.offers[index]
                                                  .minimumOrderAmount !=
                                              null &&
                                          offersResponse.offers[index]
                                              .minimumOrderAmount.isNotEmpty,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Min Order',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14, color: Colors.grey,),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '${offersResponse.offers[index].minimumOrderAmount}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14, color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                  ],
                )),
          ),
          Container(
            margin: EdgeInsets.only(top: 100),
            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
            decoration: BoxDecoration(
                color: yellowColor, borderRadius: BorderRadius.circular(5)),
            child: Text(
              getOfferTypeText(offersResponse.offers[index]),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
