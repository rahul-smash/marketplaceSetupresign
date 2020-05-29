import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/StoreOffersResponse.dart';
import 'package:restroapp/src/models/TaxCalulationResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

class AvailableOffersDialog extends StatefulWidget {

  final DeliveryAddressData address;
  final String paymentMode; // 2 = COD, 3 = Online Payment
  final Function(TaxCalculationModel) callback;
  bool isComingFromPickUpScreen;
  String areaId;

  AvailableOffersDialog(this.address, this.paymentMode,
      this.isComingFromPickUpScreen , this. areaId,this.callback);

  @override
  AvailableOffersState createState() => AvailableOffersState();
}

class AvailableOffersState extends State<AvailableOffersDialog> {

  DatabaseHelper databaseHelper = new DatabaseHelper();
  String area_id_value;

  @override
  void initState() {
    super.initState();
    area_id_value = widget.isComingFromPickUpScreen ? widget.areaId : widget.address.areaId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffdbdbdb),
        appBar: AppBar(
            title: Text("Available Offers"),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context, false),
            )),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
        //elevation: 0.0,
        body: Container(
          color: Color(0xffdbdbdb),
          child: Column(
            children: <Widget>[
              FutureBuilder(
                future:ApiController.storeOffersApiRequest(area_id_value),
                builder: (context, projectSnap) {
                  if (projectSnap.connectionState == ConnectionState.none &&
                      projectSnap.hasData == null) {
                    return Container();
                  } else {
                    if (projectSnap.hasData) {
                      StoreOffersResponse response = projectSnap.data;
                      if (response.success) {
                        List<OfferModel> offerList = response.offers;
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: offerList.length,
                            itemBuilder: (context, index) {
                              OfferModel offer = offerList[index];

                              return Container(
                                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                color: Color(0xffffffff),
                                child: Row(
                                  children: <Widget>[
                                    Text("${offer.name}",style: TextStyle(fontWeight: FontWeight.bold),),
                                    Container(
                                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        height: 60,
                                        child: VerticalDivider(color: Colors.grey)
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Text("Use code",),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(5, 0, 0, 3),
                                                  child: Text("${offer.couponCode}",
                                                    style: TextStyle(color: orangeColor,fontSize: 16,fontWeight: FontWeight.bold),),
                                                ),
                                              ],
                                            ),
                                            Text("to avail this offer",),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                              child: Text("Min Booking - ${AppConstant.currency} ${offer.minimumOrderAmount}"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding:EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: RaisedButton(
                                          padding:EdgeInsets.fromLTRB(5, 0, 5, 0),
                                          textColor: Colors.black,
                                          color: Color(0xffdbdbdb),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                            //side: BorderSide(color: Colors.red)
                                          ),
                                          onPressed: () async {
                                            bool isNetworkAvailable = await Utils.isNetworkAvailable();
                                            if(!isNetworkAvailable){
                                              Utils.showToast(AppConstant.noInternet, false);
                                              return;
                                            }
                                            Utils.showProgressDialog(context);
                                            databaseHelper.getCartItemsListToJson().then((json) {
                                              validateCouponApi(offer.couponCode, json);
                                            });
                                          },
                                          child: new Text("APPLY"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Container(
                            child: Center(
                              child: Text(response.message,textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black45, fontSize: 18.0,)),
                        ));
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.black26,
                            valueColor:AlwaysStoppedAnimation<Color>(Colors.black26)),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        )
    );
  }

  void validateCouponApi(String couponCode, String json) {
    //print("----couponCode-----=>${couponCode}");
    ApiController.validateOfferApiRequest(couponCode, widget.paymentMode, json).then((validCouponModel) {
      if (validCouponModel != null &&validCouponModel.success) {

        Utils.showToast(validCouponModel.message, true);

        ApiController.multipleTaxCalculationRequest(couponCode,validCouponModel.discountAmount, "0", json)
            .then((response) async {
          Utils.hideProgressDialog(context);
          if (response.success) {
            widget.callback(response.taxCalculation);
          }
          Navigator.pop(context, true);
        });
      } else {
        Utils.hideProgressDialog(context);
        Utils.showToast(validCouponModel.message, true);
      }
    });
  }
}
