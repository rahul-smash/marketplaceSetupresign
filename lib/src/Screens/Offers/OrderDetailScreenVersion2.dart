import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/CancelOrderModel.dart';
import 'package:restroapp/src/models/GetOrderHistory.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/UI/OrderTracker.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailScreenVersion2 extends StatefulWidget {
  OrderData orderHistoryData;
  bool isRatingEnable;
  String bullet = "\u2022 ";

  OrderDetailScreenVersion2(this.orderHistoryData, this.isRatingEnable);

  @override
  _OrderDetailScreenVersion2State createState() =>
      _OrderDetailScreenVersion2State();
}

class _OrderDetailScreenVersion2State extends State<OrderDetailScreenVersion2> {
  var screenWidth;

  OrderData orderHistoryData;
  var mainContext;
  String deliverySlotDate = '';

  String _totalCartSaving = '0', _totalPrice = '0';
  File _image;

  bool isLoading = true;

  String userId = '';

  double _ratingHygiene = 0;

  double _ratingPackaging = 0; // <---- Another instance variable
  double _ratingRunner = 0; // <---- Another instance variable

  @override
  void initState() {
    super.initState();
    getOrderListApi();
  }

  Future<Null> getOrderListApi({bool isLoading = true}) async {
    this.isLoading = isLoading;
    UserModelMobile user = await SharedPrefs.getUserMobile();
    userId = user.id;

    return ApiController.getOrderDetail(widget.orderHistoryData.orderId)
        .then((respone) {
      if (respone != null &&
          respone.success &&
          respone.orders != null &&
          respone.orders.isNotEmpty) {
        widget.orderHistoryData = respone.orders.first;
        deliverySlotDate =
            _generalizedDeliverySlotTime(widget.orderHistoryData);
        calculateSaving();
        _checkReviewsHygeineAndPack(widget.orderHistoryData);
      }

      if (!isLoading) {
        Utils.hideProgressDialog(context);
      }
      isLoading = false;
      this.isLoading = isLoading;
      if (mounted) {
        setState(() {});
      }
    });
  }

  calculateSaving() {
    try {
      double _cartSaving = widget.orderHistoryData.cartSaving != null
          ? double.parse(widget.orderHistoryData.cartSaving)
          : 0;
      double _couponDiscount = widget.orderHistoryData.discount != null
          ? double.parse(widget.orderHistoryData.discount)
          : 0;
      double _totalSaving = _cartSaving + _couponDiscount;
      _totalCartSaving =
          _totalSaving != 0 ? _totalSaving.toStringAsFixed(2) : '0';
      double _totalPriceVar =
          double.parse(widget.orderHistoryData.total) + _totalSaving;
      if (_totalSaving != 0)
        _totalPrice = _totalPriceVar.toStringAsFixed(2);
      else {
        _totalPrice = widget.orderHistoryData.total;
      }
    } catch (e) {
      _totalPrice = widget.orderHistoryData.total;
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    mainContext = context;
    String itemText = widget.orderHistoryData.orderItems.length > 1
        ? '${widget.orderHistoryData.orderItems.length} Items, '
        : '${widget.orderHistoryData.orderItems.length} Item, ';
    String orderFacility = widget.orderHistoryData.orderFacility != null
        ? '${widget.orderHistoryData.orderFacility}, '
        : '';
    if (isLoading) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Order Details',
                style: TextStyle(),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return new Scaffold(
        backgroundColor: Color(0xffDCDCDC),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Order - ${widget.orderHistoryData.displayOrderId}',
                style: TextStyle(),
                textAlign: TextAlign.left,
              ),
              Text(
                '$orderFacility$itemText${AppConstant.currency} ${widget.orderHistoryData.total}',
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
          centerTitle: false,
          actions: <Widget>[
            Visibility(
              visible: showCancelButton(widget.orderHistoryData.status),
              child: InkWell(
                  onTap: () async {
                    cancelOrderBottomSheet(context, widget.orderHistoryData);
                  },
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                        )),
                  )),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Container(
                  color: Color(0xffDCDCDC),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      firstRow(widget.orderHistoryData),
                      Container(
                        color: Colors.white,
                        margin: EdgeInsets.only(top: 5),
                        padding: EdgeInsets.all(16),
                        width: Utils.getDeviceWidth(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Track Order',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            _getTrackWidget(),
                            SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                      secondRow(widget.orderHistoryData)
                    ],
                  ),
                ),
              ),
            ),
            maincontainer(widget.orderHistoryData),
          ],
        ),
      );
    }
  }

  Widget maincontainer(OrderData orderHistoryData) {
    String bullet = "\u2022 ";
    if (widget.orderHistoryData.status != '5') {
      if (orderHistoryData.runnerDetail != null &&
          orderHistoryData.runnerDetail.isNotEmpty)
        {
          print("${widget.orderHistoryData.status}");
        if(widget.orderHistoryData.status == '6' ||
          widget.orderHistoryData.status == '7' || widget.orderHistoryData.status == '8'
        ) {
        return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 10.0, color: Colors.grey[300]),
              ),
              color: Colors.white,
            ),
            height: 100,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                        margin: EdgeInsets.only(left: 40, top: 5),
                        height: 30,
                        width: 200,
                        child: RichText(
                            text: TextSpan(
                          text: '${bullet}',
                          style:
                              TextStyle(fontSize: 15, color: Color(0xff75990B)),
                          children: [
                            TextSpan(
                              text: '${_getBottomTrack()}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black),
                            )
                          ],
                        ))),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      margin: EdgeInsets.only(left: 30, right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _getImage(widget.orderHistoryData),
                    ),
                    Expanded(
                      // margin: EdgeInsets.only(top: 5),
                      child: RichText(
                        text: TextSpan(
                            text: '${_getRunnertitle(widget.orderHistoryData)}',
                            style: TextStyle(color: Colors.black, fontSize: 13),
                            children: [
                              TextSpan(
                                  text:
                                      '\n${_getRunnerName(widget.orderHistoryData)}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))
                              //TextSpan(text: '\n${widget.runnerDetail.fullName}',style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
                            ]),
                      ),
                    ),
                    caller(widget.orderHistoryData),
                    mapper(widget.orderHistoryData)
                  ],
                ),
              ],
            ));
      }else
          return Container(
              height: 10
          );
        } else
        return Container(height: 10);
    } else
      return Container(height: 10);
  }

  Widget caller(OrderData orderHistoryData) {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(right: 20.0),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Color(0xff75990B),
            border: Border.all(
              width: 4,
              color: Colors.grey[200],
            ),
            borderRadius: BorderRadius.circular(25)),
        child: GestureDetector(
          onTap: () {
            print('Calling');
            _launchCaller(widget.orderHistoryData);
          },
          child: Icon(
            Icons.call_outlined,
            size: 25.0,
            color: Colors.white,
          ),
        ),
      );
    } else
      return Container();
  }

  Widget mapper(OrderData orderHistoryData) {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(right: 20.0),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Color(0xff75990B),
            border: Border.all(
              width: 4,
              color: Colors.grey[200],
            ),
            borderRadius: BorderRadius.circular(25)),
        child: GestureDetector(
          onTap: () {
            print('Map');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackerLive(widget.orderHistoryData),
              ),
            );
            //_launchCaller(widget.runnerDetail.phone);
          },
          child: Icon(
            Icons.gps_fixed_outlined,
            size: 25.0,
            color: Colors.white,
          ),
        ),
      );
    } else
      return Container();
  }

  Widget firstRow(OrderData orderHistoryData) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            orderHistoryData.orderFacility.toLowerCase().contains('pick')
                ? 'PickUp Address'
                : 'Delivery Address',
            style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A7C80),
                fontWeight: FontWeight.w300),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Text(
                    _getAddress(orderHistoryData),
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  width: 80,
                ),
                Container(
                    margin: EdgeInsets.only(left: 3),
                    padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffD7D7D7)),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Text('${orderHistoryData.orderFacility}',
                        style:
                            TextStyle(color: Color(0xFF968788), fontSize: 13))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Text(
                    deliverySlotDate,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Visibility(
                  visible: orderHistoryData.paymentMethod != null &&
                      orderHistoryData.paymentMethod.trim().isNotEmpty,
                  child: Container(
                      margin: EdgeInsets.only(left: 6),
                      padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE6E6E6)),
                        color: Color(0xFFE6E6E6),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Text(
                          '${orderHistoryData.paymentMethod.trim().toUpperCase()}',
                          style: TextStyle(
                              color: Color(0xFF39444D), fontSize: 13))),
                ),
              ],
            ),
          ),
          Visibility(
              visible: orderHistoryData.IsMembershipCouponEnabled == '1',
              child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  padding: EdgeInsets.fromLTRB(15, 3, 15, 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE6E6E6)),
                    color: Color(0xFFE6E6E6),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  child: Text(
                    'Subscription Order',
                    style: TextStyle(
                        color: appTheme,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )))
        ],
      ),
    );
  }

  secondRow(OrderData orderHistoryData) {
    String itemText = orderHistoryData.orderItems.length > 1
        ? '${orderHistoryData.orderItems.length} Items '
        : '${orderHistoryData.orderItems.length} Item ';
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            itemText,
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          SizedBox(
            height: 16,
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: orderHistoryData.orderItems.length,
              itemBuilder: (context, index) {
                return listItem(context, orderHistoryData, index);
              }),
          Container(
            height: 1,
            color: Color(0xFFE1E1E1),
          ),
          Visibility(
              visible: widget.isRatingEnable &&
                  widget.orderHistoryData.status.contains('5'),
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFFE1E1E1), width: 1),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: InkWell(
                              onTap: () {
                                if (_ratingPackaging == 0)
                                  orderRatebottomSheet(context, '2');
                              },
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.asset('images/packaging.png',
                                          fit: BoxFit.fitHeight)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Rate on Packaging',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  RatingBar(
                                    initialRating: _ratingPackaging,
                                    minRating: 0,
                                    itemSize: 24,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    ignoreGestures: true,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 2.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: appThemeSecondary,
                                    ),
                                    onRatingUpdate: (rating) {
                                      _ratingPackaging = rating;
                                    },
                                  ),
                                ],
                              )),
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFFE1E1E1), width: 1),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: InkWell(
                              onTap: () {
                                if (_ratingHygiene == 0)
                                  orderRatebottomSheet(context, '1');
                              },
                              child: Column(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Image.asset('images/hygiene.png',
                                          fit: BoxFit.fitHeight)),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Rate on Hygiene',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  RatingBar(
                                    initialRating: _ratingHygiene,
                                    minRating: 0,
                                    itemSize: 24,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    ignoreGestures: true,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 2.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: appThemeSecondary,
                                    ),
                                    onRatingUpdate: (rating) {
                                      _ratingHygiene = rating;
                                    },
                                  ),
                                ],
                              )),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: widget.orderHistoryData.orderFacility
                          .toLowerCase()
                          .contains('delivery'),
                      child: Container(
                        padding: EdgeInsets.only(bottom: 16),
                        child: InkWell(
                            onTap: () {
                              if (_ratingRunner == 0)
                                orderRatebottomSheet(context, '3');
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Rate Delivery Person:',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                RatingBar(
                                  initialRating: _ratingRunner,
                                  minRating: 0,
                                  itemSize: 24,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  ignoreGestures: true,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 2.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: appThemeSecondary,
                                  ),
                                  onRatingUpdate: (rating) {
                                    _ratingRunner = rating;
                                  },
                                ),
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
              )),
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 0, top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                          visible: orderHistoryData.walletRefund!=null&&orderHistoryData.walletRefund == "0.00"
                              ? false
                              : true,
                          child: Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text('(-)Wallet Amount',
                                        style: TextStyle(
                                          color: Color(0xff74BA33),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        )),
                                  ),
                                  Text(
                                      "${AppConstant.currency} ${orderHistoryData.walletRefund}",
                                      style: TextStyle(
                                          color: Color(0xff74BA33),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500))
                                ],
                              ))),
                      Visibility(
                          visible: orderHistoryData.shippingCharges == "0.00"
                              ? false
                              : true,
                          child: Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text('Delivery Charges',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        )),
                                  ),
                                  Text(
                                      "${AppConstant.currency} ${orderHistoryData.shippingCharges}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))
                                ],
                              ))),
                      Visibility(
                          visible:
                              orderHistoryData.tax == "0.00" ? false : true,
                          child: Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      orderHistoryData.shippingCharges == "0.00"
                                          ? 16
                                          : 0,
                                  bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text('Tax',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        )),
                                  ),
                                  Text(
                                      "${AppConstant.currency} ${orderHistoryData.tax}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))
                                ],
                              ))),
                      Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: Text('Total',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    )),
                              ),
                              Text("${AppConstant.currency} ${_totalPrice}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ],
                          )),
                      Visibility(
                          visible: orderHistoryData.cartSaving != null &&
                              (orderHistoryData.cartSaving != '0.00'),
                          child: Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text('MRP Discount',
                                        style: TextStyle(
                                          color: Color(0xff74BA33),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        )),
                                  ),
                                  Text(
                                      "${AppConstant.currency} ${orderHistoryData.cartSaving != null ? orderHistoryData.cartSaving : '0.00'}",
                                      style: TextStyle(
                                          color: Color(0xff74BA33),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))
                                ],
                              ))),
                      Visibility(
                          visible: orderHistoryData.discount != '0.00',
                          child: Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text('Coupon Discount',
                                        style: TextStyle(
                                          color: Color(0xff74BA33),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        )),
                                  ),
                                  Text(
                                      "${AppConstant.currency} ${orderHistoryData.discount != null ? orderHistoryData.discount : '0.00'}",
                                      style: TextStyle(
                                          color: Color(0xff74BA33),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500))
                                ],
                              ))),
                      Container(
                        margin: EdgeInsets.only(top: 16, bottom: 16),
                        color: Color(0xFFE1E1E1),
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text('Payable Amount',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                  "${AppConstant.currency} ${orderHistoryData.total}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500)),
                              Visibility(
                                visible:
                                    !(_totalCartSaving.compareTo('0') == 0),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Text(
                                      "Cart Saving ${AppConstant.currency} ${_totalCartSaving}",
                                      style: TextStyle(
                                          color: Color(0xff74BA33),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem(
      BuildContext context, OrderData cardOrderHistoryItems, int index) {
    double findRating = _findRating(cardOrderHistoryItems, index);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Text(
                    '${cardOrderHistoryItems.orderItems[index].productName}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 16)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(right: 3),
                      padding: EdgeInsets.fromLTRB(8, 1, 8, 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE6E6E6)),
                        color: Color(0xFFE6E6E6),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Text(
                          '${cardOrderHistoryItems.orderItems[index].quantity}',
                          style: TextStyle(color: Colors.black, fontSize: 12))),
                  Text('X ${cardOrderHistoryItems.orderItems[index].price}',
                      style: TextStyle(
                        color: Color(0xFF818387),
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      )),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 0, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                          'Weight: ${cardOrderHistoryItems.orderItems[index].weight}',
                          style: TextStyle(
                            color: Color(0xFF818387),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          )),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            cardOrderHistoryItems.orderItems[index].status ==
                                    '2'
                                ? "Rejected"
                                : "${AppConstant.currency} ${(double.parse(cardOrderHistoryItems.orderItems[index].quantity) * double.parse(cardOrderHistoryItems.orderItems[index].price)).toStringAsFixed(2)}",
                            style: TextStyle(
                                color: cardOrderHistoryItems
                                            .orderItems[index].status ==
                                        '2'
                                    ? Colors.red
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        Visibility(
                            visible: cardOrderHistoryItems
                                        .orderItems[index].refundStatus ==
                                    '2' ||
                                cardOrderHistoryItems
                                        .orderItems[index].refundStatus ==
                                    '1',
                            child: Text(
                                cardOrderHistoryItems
                                            .orderItems[index].refundStatus ==
                                        '1'
                                    ? "Refund Pending"
                                    : "Refunded",
                                style: TextStyle(
                                    color: cardOrderHistoryItems
                                                .orderItems[index]
                                                .refundStatus ==
                                            '1'
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)))
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                        visible: widget.isRatingEnable &&
                            cardOrderHistoryItems.status.contains('5'),
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: InkWell(
                            child: RatingBar(
                              initialRating: findRating,
                              minRating: 0,
                              itemSize: 26,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: appThemeSecondary,
                              ),
                              ignoreGestures: true,
                              onRatingUpdate: (rating) {},
                            ),
                            onTap: () {
                              if (findRating == 0)
                                bottomSheet(
                                    context, cardOrderHistoryItems, index);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Visibility(
            visible: index != cardOrderHistoryItems.orderItems.length - 1,
            child: Container(
              color: Color(0xFFE1E1E1),
              height: 1,
            ),
          )
        ],
      ),
    );
  }

  bottomSheet(context, OrderData cardOrderHistoryItems, int index) async {
    double _rating = 0;
    _image = null;
    final commentController = TextEditingController();
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Wrap(children: <Widget>[
                    Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                              child: Icon(
                                Icons.cancel,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: Text(
                            "Rating",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
//                            Text(
//                              "(Select a star amount)",
//                              textAlign: TextAlign.center,
//                              style: TextStyle(
//                                  color: Colors.black,
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.w400),
//                            ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          color: appThemeSecondary,
                          width: 50,
                          height: 3,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "Product Name",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xff797C82),
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            "${cardOrderHistoryItems.orderItems[index].productName}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RatingBar(
                          initialRating: _rating,
                          minRating: 0,
                          itemSize: 35,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: appThemeSecondary,
                          ),
                          onRatingUpdate: (rating) {
                            _rating = rating;
                          },
                        ),
                        Container(
                          height: 120,
                          margin: EdgeInsets.fromLTRB(20, 15, 20, 20),
                          decoration: new BoxDecoration(
                            color: grayLightColor,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(3.0)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                            child: TextField(
                              textAlign: TextAlign.left,
                              maxLength: 250,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              controller: commentController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10.0),
                                  border: InputBorder.none,
                                  fillColor: grayLightColor,
                                  hintText: 'Write your Review...'),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 0, bottom: 16, left: 16, right: 16),
                          color: Color(0xFFE1E1E1),
                          height: 1,
                        ),
                        Container(
                          width: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                  onTap: () {
                                    showAlertDialog(context, setState);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: 0, bottom: 6, left: 16, right: 16),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "images/placeholder.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    height: 100,
                                    width: 120,
                                    child: _image != null
                                        ? Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Image.file(
                                              _image,
                                              fit: BoxFit.cover,
                                            ))
                                        : null,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 0, left: 18, bottom: 30),
                                child: Text(
                                  "File Size limit - 1MB",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: 130,
                                child: FlatButton(
                                  child: Text('Submit'),
                                  color: appThemeSecondary,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    if (_rating == 0) {
                                      Utils.showToast(
                                          'Please give some rating .', true);
                                      return;
                                    }
                                    Utils.hideKeyboard(context);
                                    Navigator.pop(context);
                                    postRating(
                                        cardOrderHistoryItems, index, _rating,
                                        desc: commentController.text.trim(),
                                        imageFile: _image);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
                ),
              ));
            },
          );
        });
  }

  orderRatebottomSheet(context, String type) async {
    double _rating = 0;
    _image = null;
    final commentController = TextEditingController();
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Wrap(children: <Widget>[
                    Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                              child: Icon(
                                Icons.cancel,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: Text(
                            "Rating",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          "(Select a star amount)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          color: appThemeSecondary,
                          width: 50,
                          height: 3,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            "Rate On",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xff797C82),
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            "${type != '1' ? type == '3' ? 'Delivery Person' : 'Packaging' : 'Hygiene'}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RatingBar(
                          initialRating: _rating,
                          minRating: 0,
                          itemSize: 35,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: appThemeSecondary,
                          ),
                          onRatingUpdate: (rating) {
                            _rating = rating;
                          },
                        ),
                        Container(
                          height: 120,
                          margin: EdgeInsets.fromLTRB(20, 15, 20, 20),
                          decoration: new BoxDecoration(
                            color: grayLightColor,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(3.0)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                            child: TextField(
                              textAlign: TextAlign.left,
                              maxLength: 250,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              controller: commentController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10.0),
                                  border: InputBorder.none,
                                  fillColor: grayLightColor,
                                  hintText: 'Write your Review...'),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 0, bottom: 16, left: 16, right: 16),
                          color: Color(0xFFE1E1E1),
                          height: 1,
                        ),
                        Visibility(
                          visible: type != '3',
                          child: Container(
                            width: double.maxFinite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                    onTap: () {
                                      showAlertDialog(context, setState);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: 0,
                                          bottom: 6,
                                          left: 16,
                                          right: 16),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "images/placeholder.png"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      height: 100,
                                      width: 120,
                                      child: _image != null
                                          ? Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Image.file(
                                                _image,
                                                fit: BoxFit.cover,
                                              ))
                                          : null,
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 0, left: 18, bottom: 30),
                                  child: Text(
                                    "File Size limit - 1MB",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: 130,
                                child: FlatButton(
                                  child: Text('Submit'),
                                  color: appThemeSecondary,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    if (_rating == 0) {
                                      Utils.showToast(
                                          'Please give some rating .', true);
                                      return;
                                    }
                                    Utils.hideKeyboard(context);
                                    Navigator.pop(context);
                                    postRating(null, 0, _rating,
                                        desc: commentController.text.trim(),
                                        imageFile: _image,
                                        type: type);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
                ),
              ));
            },
          );
        });
  }

  cancelOrderBottomSheet(context, OrderData cardOrderHistoryItems) async {
    final commentController = TextEditingController();
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Wrap(children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
                          child: Text(
                            "Cancel Confirm",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          "Are you sure you want to\n cancel your order?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        Container(
                          height: 130,
                          margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
                          decoration: new BoxDecoration(
                            color: grayLightColor,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
                            child: TextField(
                              textAlign: TextAlign.left,
                              maxLength: 250,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              controller: commentController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10.0),
                                  border: InputBorder.none,
                                  fillColor: grayLightColor,
                                  hintText: 'Add the reason for cancellation.'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                width: 120,
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(5.0)),
                                ),
                                child: FlatButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  color: Colors.grey,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Utils.hideKeyboard(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Container(
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(5.0)),
                                ),
                                child: FlatButton(
                                  child: Text(
                                    'Yes, cancel my order',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  color: orangeColor,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    String comment = commentController.text;
                                    Utils.hideKeyboard(context);
                                    Navigator.pop(context);
                                    _hitCancelOrderApi(
                                        orderRejectionNote: comment);
                                  },
                                ),
                              ))
                            ],
                          ),
                        ),
                      ],
                    )
                  ]),
                ),
              ));
            },
          );
        });
  }

  _hitCancelOrderApi({String orderRejectionNote}) async {
    Utils.showProgressDialog(context);
    CancelOrderModel cancelOrder = await ApiController.orderCancelApi(
        widget.orderHistoryData.orderId,
        storeID: widget.orderHistoryData.orderItems.first.storeId,
        order_rejection_note: orderRejectionNote);
    if (cancelOrder != null && cancelOrder.success) {
      setState(() {
        widget.orderHistoryData.status = '6';
      });
    }
    try {
      Utils.showToast("${cancelOrder.data}", false);
    } catch (e) {
      print(e);
    }
//                          Utils.hideProgressDialog(context);
    eventBus.fire(refreshOrderHistory());
    getOrderListApi(isLoading: false);
  }

  bottomDeviderView() {
    return Container(
      width: MediaQuery.of(mainContext).size.width,
      height: 10,
      color: Color(0xFFDBDCDD),
    );
  }

  bool showCancelButton(status) {
    bool showCancelButton;
    // 0 => 'pending' ,  1 =>'processing', 2 =>'rejected',
// 4 =>'shipped', 5 =>'delivered', 6 => 'cancel'
    //Remove cancel button on processing status
    if (/*status == "1" || status == "4" ||*/ status == "0") {
      showCancelButton = true;
    } else {
      showCancelButton = false;
    }
    return showCancelButton;
  }

  deviderLine() {
    return Divider(
      color: Color(0xFFDBDCDD),
      height: 1,
      thickness: 1,
      indent: 12,
      endIndent: 12,
    );
  }

  sheetDeviderLine() {
    return Divider(
      color: Color(0xFFDBDCDD),
      height: 1,
      thickness: 1,
      indent: 0,
      endIndent: 0,
    );
  }

  String getStatus(status) {
    print("---${status}---");
    /*0 =pending ,
    1= active,
    2 = rejected = show view only for this else hide status.*/
    if (status == "0") {
      return 'Pending';
    } else if (status == "1") {
      return 'Active';
    }
    if (status == "2") {
      return 'Rejected';
    } else {}
  }

  Color getStatusColor(status) {
    return status == "0"
        ? Color(0xFFA1BF4C)
        : status == "1"
            ? Color(0xFFA0C057)
            : Color(0xFFCF0000);
  }

  String getDeliveryAddress() {
    if (widget.orderHistoryData.deliveryAddress != null &&
        widget.orderHistoryData.deliveryAddress.isNotEmpty)
      return '${widget.orderHistoryData.address} '
          '${widget.orderHistoryData.deliveryAddress.first.areaName} '
          '${widget.orderHistoryData.deliveryAddress.first.city} '
          '${widget.orderHistoryData.deliveryAddress.first.state}';
    else
      return widget.orderHistoryData.address;
  }

  String _getAddress(OrderData orderHistoryData) {
    if (orderHistoryData.deliveryAddress != null &&
        orderHistoryData.deliveryAddress.isNotEmpty) {
      String name =
          orderHistoryData?.deliveryAddress?.first?.firstName!=null
              ? '${orderHistoryData.deliveryAddress.first.firstName}'
              : '';
      String address =
          orderHistoryData?.deliveryAddress?.first?.address!=null
              ? ', ${orderHistoryData.deliveryAddress.first.address}'
              : '';
      String area =
          orderHistoryData?.deliveryAddress?.first?.areaName!=null
              ? ', ${orderHistoryData.deliveryAddress.first.areaName}'
              : '';
      String city = orderHistoryData?.deliveryAddress?.first?.city!=null
          ? ', ${orderHistoryData.deliveryAddress.first.city}'
          : '';
      String ZipCode =
          orderHistoryData?.deliveryAddress?.first?.zipcode!=null
              ? ', ${orderHistoryData.deliveryAddress.first.zipcode}'
              : '';
      return '$name$address$area$city$ZipCode';
    } else {
      String address = '${orderHistoryData.address}';
      return address;
    }
  }

  String _generalizedDeliverySlotTime(OrderData orderHistoryData) {
    if (orderHistoryData.deliveryTimeSlot != null &&
        orderHistoryData.deliveryTimeSlot.isNotEmpty) {
      int dateEndIndex = orderHistoryData.deliveryTimeSlot.indexOf(' ');
      String date =
          orderHistoryData.deliveryTimeSlot.substring(0, dateEndIndex);
      String convertedDate = convertOrderDateTime(date);
      String returnedDate =
          orderHistoryData.deliveryTimeSlot.replaceFirst(' ', ' | ');
      return returnedDate.replaceAll(date, convertedDate);
    } else {
      return '';
    }
  }

  String convertOrderDateTime(String date) {
    String formatted = date;
    try {
      DateFormat format = new DateFormat("yyyy-MM-dd");
      //UTC time true
      DateTime time = format.parse(date, true);
      time = time.toLocal();
      //print("time.toLocal()=   ${time.toLocal()}");
      DateFormat formatter = new DateFormat('dd MMM yyyy');
      formatted = formatter.format(time.toLocal());
    } catch (e) {
      print(e);
    }

    return formatted;
  }

  Widget _getTrackWidget() {
    // 0 => 'pending' ,  1 =>'processing', 2 =>'rejected',
    // 4 =>'shipped', 5 =>'delivered', 6 => 'cancel'

//    bool isPickup =widget.orderHistoryData.orderFacility.contains('Pick');

    Color orderPlaced = Colors.black;
    Color orderConfirmed = widget.orderHistoryData.status == '1' ||
            widget.orderHistoryData.status == '4' ||
            widget.orderHistoryData.status == '5' ||
            widget.orderHistoryData.status == '8' ||
            widget.orderHistoryData.status == '7'
        ? Colors.black
        : grayLightColorSecondary;
    Color orderReadyForPickUp = widget.orderHistoryData.status == '4' ||
            widget.orderHistoryData.status == '5' ||
            widget.orderHistoryData.status == '8' ||
            widget.orderHistoryData.status == '7'
        ? Colors.black
        : grayLightColorSecondary;

//    Color orderOnTheWay = widget.orderHistoryData.status == '4' ||
//            widget.orderHistoryData.status == '5' ||
//            widget.orderHistoryData.status == '7'
//        ? Colors.black
//        : grayLightColorSecondary;

    Color orderShipped = widget.orderHistoryData.status == '4' ||
            widget.orderHistoryData.status == '5' ||
            widget.orderHistoryData.status == '7'
        ? Colors.black
        : grayLightColorSecondary;
    Color orderDelivered = widget.orderHistoryData.status == '2' ||
            widget.orderHistoryData.status == '6'
        ? Colors.red
        : widget.orderHistoryData.status == '5'
            ? Colors.black
            : grayLightColorSecondary;

    double orderPlacedProgress = 100;
    double orderConfirmedProgress = widget.orderHistoryData.status == '1' ||
            widget.orderHistoryData.status == '4' ||
            widget.orderHistoryData.status == '5' ||
            widget.orderHistoryData.status == '8' ||
            widget.orderHistoryData.status == '7'
        ? 100
        : 0;
    double orderReadyForPickUpProgress =
        widget.orderHistoryData.status == '4' ||
                widget.orderHistoryData.status == '5' ||
                widget.orderHistoryData.status == '8' ||
                widget.orderHistoryData.status == '7'
            ? 100
            : 0;
//    double orderOnTheWayProgress = widget.orderHistoryData.status == '4' ||
//            widget.orderHistoryData.status == '5' ||
//            widget.orderHistoryData.status == '7'
//        ? 100
//        : 0;
    double orderShippedProgress = widget.orderHistoryData.status == '4' ||
            widget.orderHistoryData.status == '5' ||
            widget.orderHistoryData.status == '7'
        ? 100
        : 0;
    double orderDeliveredProgress = widget.orderHistoryData.status == '2' ||
            widget.orderHistoryData.status == '6'
        ? 100
        : widget.orderHistoryData.status == '5'
            ? 100
            : 0;
    bool isOrderCanceledOrRejected = widget.orderHistoryData.status == '2' ||
            widget.orderHistoryData.status == '6'
        ? true
        : false;
    bool isNoteVisible = (widget.orderHistoryData.status == '2' ||
            widget.orderHistoryData.status == '6') &&
        widget.orderHistoryData.orderRejectionNote != null &&
        widget.orderHistoryData.orderRejectionNote.isNotEmpty;
    String noteHeading = widget.orderHistoryData.orderRejectionNote != null &&
            widget.orderHistoryData.orderRejectionNote.isNotEmpty
        ? widget.orderHistoryData.status == '6'
            ? "Cancellation Comment:-"
            : widget.orderHistoryData.status == '2'
                ? "Reason of Rejection:-"
                : ""
        : "";
    String orderRejectionNote =
        widget.orderHistoryData.orderRejectionNote != null &&
                widget.orderHistoryData.orderRejectionNote.isNotEmpty
            ? widget.orderHistoryData.orderRejectionNote
            : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              height: 25,
              margin: EdgeInsets.only(left: 4, top: 5),
              width: 2,
              child: LinearProgressIndicator(
                backgroundColor: grayLightColorSecondary,
                value: orderPlacedProgress,
                valueColor: AlwaysStoppedAnimation<Color>(appTheme),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 / 2),
                      color: appTheme),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: Text(
                  'Order Placed',
                  style: TextStyle(fontSize: 16, color: orderPlaced),
                )),
                Text(
                  '${Utils.convertOrderDate(widget.orderHistoryData.orderDate)}',
                  style: TextStyle(color: orderPlaced),
                )
              ],
            )
          ],
        ),
        Visibility(
          visible: !isOrderCanceledOrRejected,
          child: Stack(
            children: <Widget>[
              Container(
                height: 30,
                margin: EdgeInsets.only(
                  left: 4,
                ),
                width: 2,
                child: LinearProgressIndicator(
                  backgroundColor: grayLightColorSecondary,
                  value: orderConfirmedProgress,
                  valueColor: AlwaysStoppedAnimation<Color>(appTheme),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10 / 2),
                        color: orderConfirmed == Colors.black
                            ? appTheme
                            : grayLightColorSecondary),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Text(
                    'Order Confirmed',
                    style: TextStyle(fontSize: 16, color: orderConfirmed),
                  )),
                  Text(
                    orderConfirmed == Colors.black ? 'Done' : 'Pending',
                    style: TextStyle(color: orderConfirmed, fontSize: 16),
                  )
                ],
              )
            ],
          ),
        ),
        Visibility(
          visible: !isOrderCanceledOrRejected,
          child: Stack(
            children: <Widget>[
              Container(
                height: 30,
                margin: EdgeInsets.only(
                  left: 4,
                ),
                width: 2,
                child: LinearProgressIndicator(
                  backgroundColor: grayLightColorSecondary,
                  value: orderReadyForPickUpProgress,
                  valueColor: AlwaysStoppedAnimation<Color>(appTheme),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10 / 2),
                        color: orderReadyForPickUp == Colors.black
                            ? appTheme
                            : grayLightColorSecondary),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Text(
                    widget.orderHistoryData.orderFacility
                            .toLowerCase()
                            .contains('dinein')
                        ? 'Ready to Serve'
                        : 'Ready for PickUp',
                    style: TextStyle(fontSize: 16, color: orderReadyForPickUp),
                  )),
                  Text(
                    orderReadyForPickUp == Colors.black ? 'Done' : 'Pending',
                    style: TextStyle(color: orderReadyForPickUp, fontSize: 16),
                  )
                ],
              )
            ],
          ),
        ),
//        Visibility(
//          visible: !isOrderCanceledOrRejected && !widget.orderHistoryData.orderFacility
//        .toLowerCase()
//        .contains('pick'),
//          child: Stack(
//            children: <Widget>[
//              Container(
//                height: 30,
//                margin: EdgeInsets.only(
//                  left: 4,
//                ),
//                width: 2,
//                child: LinearProgressIndicator(
//                  backgroundColor: grayLightColorSecondary,
//                  value: orderOnTheWayProgress,
//                  valueColor: AlwaysStoppedAnimation<Color>(appTheme),
//                ),
//              ),
//              Row(
//                children: <Widget>[
//                  Container(
//                    width: 10,
//                    height: 10,
//                    decoration: BoxDecoration(
//                        borderRadius: BorderRadius.circular(10 / 2),
//                        color: orderOnTheWay == Colors.black
//                            ? appTheme
//                            : grayLightColorSecondary),
//                  ),
//                  SizedBox(
//                    width: 5,
//                  ),
//                  Expanded(
//                      child: Text(
//                    'On the way',
//                    style: TextStyle(fontSize: 16, color: orderReadyForPickUp),
//                  )),
//                  Text(
//                    orderOnTheWay == Colors.black ? 'Done' : 'Pending',
//                    style: TextStyle(color: orderOnTheWay, fontSize: 16),
//                  )
//                ],
//              )
//            ],
//          ),
//        ),
        Visibility(
          visible: !isOrderCanceledOrRejected &&
              !widget.orderHistoryData.orderFacility
                  .toLowerCase()
                  .contains('pick'),
          child: Stack(
            children: <Widget>[
              Container(
                height: 30,
                margin: EdgeInsets.only(
                  left: 4,
                ),
                width: 2,
                child: LinearProgressIndicator(
                  backgroundColor: grayLightColorSecondary,
                  value: orderShippedProgress,
                  valueColor: AlwaysStoppedAnimation<Color>(appTheme),
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10 / 2),
                        color: orderShipped == Colors.black
                            ? appTheme
                            : grayLightColorSecondary),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Text(
                    widget.orderHistoryData.orderFacility
                            .toLowerCase()
                            .contains('dinein')
                        ? 'Order Served'
                        : 'Order Shipped',
                    style: TextStyle(fontSize: 16, color: orderShipped),
                  )),
                  Text(
                    orderShipped == Colors.black ? 'Done' : 'Pending',
                    style: TextStyle(color: orderShipped, fontSize: 16),
                  )
                ],
              )
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            Container(
              height: 15,
              margin: EdgeInsets.only(
                left: 4,
              ),
              width: 2,
              child: LinearProgressIndicator(
                backgroundColor: grayLightColorSecondary,
                value: orderDeliveredProgress,
                valueColor: AlwaysStoppedAnimation<Color>(appTheme),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 / 2),
                      color: orderDelivered == Colors.black
                          ? appTheme
                          : orderDelivered),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: Text(
                  isOrderCanceledOrRejected
                      ? widget.orderHistoryData.status == '2'
                          ? 'Order Rejected'
                          : 'Order Cancelled'
                      : !widget.orderHistoryData.orderFacility
                              .toLowerCase()
                              .contains('pick')
                          ? widget.orderHistoryData.orderFacility
                                  .toLowerCase()
                                  .contains('dinein')
                              ? 'Order Completed'
                              : 'Order Delivered'
                          : 'Order Picked',
                  style: TextStyle(fontSize: 16, color: orderDelivered),
                )),
                Text(
                  orderDelivered == Colors.black || orderDelivered == Colors.red
                      ? 'Done'
                      : 'Pending',
                  style: TextStyle(color: orderDelivered, fontSize: 16),
                )
              ],
            )
          ],
        ),
        Visibility(
          visible: isNoteVisible,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                noteHeading,
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  orderRejectionNote,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: widget.orderHistoryData.status == '5',
          child: RichText(
            text: TextSpan(
              text: '${_getRunnerBy(widget.orderHistoryData)}',
              style: TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                  text: ' ${_getRunnerName(widget.orderHistoryData)}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                //TextSpan(text: '\n${widget.runnerDetail.fullName}',style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ],
    );
  }

  showAlertDialog(BuildContext context, setState) {
    SimpleDialog dialog = SimpleDialog(
      title: const Text('Choose option'),
      children: <Widget>[
        SimpleDialogOption(
          child: Text(
            'Camera',
            style: TextStyle(fontSize: 16.0),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            var image =
                await ImagePicker().getImage(source: ImageSource.camera);
            if (image == null) {
              print("---image == null----");
            } else {
              _image = File(image.path);
            }
            setState(() {});
          },
        ),
        SimpleDialogOption(
          child: Text(
            'Gallery',
            style: TextStyle(fontSize: 16.0),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            var image =
                await ImagePicker().getImage(source: ImageSource.gallery);
            if (image == null) {
              print("---image == null----");
            } else {
              print("---image.length----${image.path}");
              _image = File(image.path);
            }
            setState(() {});
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  double _findRating(OrderData cardOrderHistoryItems, int index) {
    double foundRating = 0;
    List<Review> reviewList = cardOrderHistoryItems.orderItems[index].review;

    if (reviewList != null && reviewList.isNotEmpty) {
      for (int i = 0; i < reviewList.length; i++) {
        if (userId.compareTo(reviewList[i].userId) == 0) {
          foundRating = double.parse(reviewList[i].rating);
        }
      }
    }
    return foundRating;
  }

  void postRating(OrderData cardOrderHistoryItems, int index, double _rating,
      {String desc = "", File imageFile, String type = '0'}) {
    Utils.showProgressDialog(context);
    String orderId = cardOrderHistoryItems != null
        ? cardOrderHistoryItems.orderId
        : widget.orderHistoryData.orderId;
    String productId = cardOrderHistoryItems != null
        ? cardOrderHistoryItems.orderItems[index].productId
        : '0';
    String storeId = cardOrderHistoryItems != null
        ? cardOrderHistoryItems.orderItems[index].storeId
        : widget.orderHistoryData.orderItems.first.storeId;
    ApiController.postProductRating(
            orderId, productId, _rating.toString(), storeId,
            desc: desc, imageFile: imageFile, type: type)
        .then((value) {
      if (value != null && value.success) {
        //Hit event Bus
        eventBus.fire(refreshOrderHistory());
        getOrderListApi(isLoading: false);
      }
    });
  }

  void _checkReviewsHygeineAndPack(OrderData orderHistoryData) {
    if (orderHistoryData.reviewsHygeineAndPack != null &&
        orderHistoryData.reviewsHygeineAndPack.isNotEmpty) {
      for (int i = 0; i < orderHistoryData.reviewsHygeineAndPack.length; i++) {
        if (orderHistoryData.reviewsHygeineAndPack[i].rating != '0' ||
            orderHistoryData.reviewsHygeineAndPack[i].rating != '') {
          switch (orderHistoryData.reviewsHygeineAndPack[i].type) {
            case '0':
              break;
            case '1':
              _ratingHygiene = double.parse(
                  orderHistoryData.reviewsHygeineAndPack[i].rating);
              break;
            case '2':
              _ratingPackaging = double.parse(
                  orderHistoryData.reviewsHygeineAndPack[i].rating);
              break;
            case '3':
              _ratingRunner = double.parse(
                  orderHistoryData.reviewsHygeineAndPack[i].rating);
              break;
          }
        }
      }
    }
  }

  String _getRunnertitle(OrderData orderHistoryData) {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      String name = '${orderHistoryData.runnerDetail.first.fullName}';

      return 'Delivery Boy';
    } else {
      return '';
    }
  }

  String _getRunnerName(OrderData orderHistoryData) {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      String name = '${orderHistoryData.runnerDetail.first.fullName}';

      return '$name';
    } else {
      return '';
    }
  }

  String _getRunnerBy(OrderData orderHistoryData) {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      return '     by';
    } else {
      return '';
    }
  }

  _getImage(OrderData orderHistoryData) {
    //Image(image: AssetImage('images/whatsapp.png' ),

    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      AppConstant.placeholderUrl =
          '${orderHistoryData.runnerDetail.first.profileImage}';
      return CachedNetworkImage(
          imageUrl: "${orderHistoryData.runnerDetail.first.profileImage}");
    } else {
      return;
    }
  }

  _getBottomTrack() {
    // Delivered == 5, On Way to destination == 7
    String bullet = "\u2022 ";
    print('${widget.orderHistoryData.status}');
    switch (widget.orderHistoryData.status) {
      case '6':
        return 'Order Cancelled';
        break;
      case '7':
        return 'On the way to destination';
        break;
      case '8':
        return 'On the way to take your order';
        break;
      default:
        return '';
    }
  }

  void _launchCaller(OrderData orderHistoryData) async {
    if (orderHistoryData.runnerDetail != null &&
        orderHistoryData.runnerDetail.isNotEmpty) {
      String contact = '${orderHistoryData.runnerDetail.first.phone}';
      String url = "tel://${contact}";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
