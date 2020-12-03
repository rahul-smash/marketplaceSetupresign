import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';

class RestroListScreen extends StatefulWidget {
  StoresModel allStoreData;
  CustomCallback callback;
  HomeScreenEnum selectedScreen;

  bool isViewAllRestSelected = false;

  RestroListScreen(this.allStoreData, {this.callback, this.selectedScreen});

  @override
  _RestroListScreenState createState() => _RestroListScreenState();
}

class _RestroListScreenState extends State<RestroListScreen> {
  var storeData;

  @override
  Widget build(BuildContext context) {
    return _getView();
  }

  Widget getProductsWidget() {
    return Column(
      children: <Widget>[
        Container(
          height: 0,
          width: MediaQuery.of(context).size.width,
        ),
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: widget.isViewAllRestSelected
                  ? widget.allStoreData == null
                      ? 0
                      : widget.allStoreData.data.length
                  : storeData.data.length,
              itemBuilder: (context, index) {
                StoreData storeDataObj = widget.isViewAllRestSelected
                    ? widget.allStoreData.data[index]
                    : storeData.data[index];

                return InkWell(
                  onTap: () {
                    print("----onTap-${storeDataObj.id}--");
                    Utils.showProgressDialog(context);
                    ApiController.getStoreVersionData(storeDataObj.id)
                        .then((response) {
                      Utils.hideProgressDialog(context);
                      Utils.hideKeyboard(context);
                      StoreDataModel storeObject = response;
                      widget.callback(value: storeObject);
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                    height: 150,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          topLeft: Radius.circular(5)),
                                      child: storeDataObj.image.isNotEmpty
                                          ? CachedNetworkImage(
                                              height: 150,
                                              width:
                                                  Utils.getDeviceWidth(context),
                                              imageUrl: "${storeDataObj.image}",
                                              fit: BoxFit.cover)
                                          : null,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          topLeft: Radius.circular(5)),
                                      image: storeDataObj.image.isEmpty
                                          ? DecorationImage(
                                              image:
                                                  AssetImage('images/img1.png'),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${storeDataObj.storeName}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        /*Row(
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
                                            '4.0/',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            '5',
                                            style: TextStyle(
                                                fontSize: 16, color: Colors.grey),
                                          )
                                        ],
                                      ),*/
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 5,
                                        bottom: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${storeDataObj.state}',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        /*Text(
                                        '${AppConstant.currency}350 for two',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),*/
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
                      Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.only(top: 130, right: 20),
                            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                            decoration: BoxDecoration(
                                color: whiteWith70Opacity,
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: Text(
                                "45 mins",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                            ),
                            width: 70,
                          )),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }

  Widget _getView() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          widget.allStoreData == null ||
                  (widget.allStoreData != null &&
                      widget.allStoreData.data.isEmpty)
              ? Utils.getEmptyView2("No Result Found")
              : Expanded(
                  child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.allStoreData.data.length,
                  itemBuilder: (context, index) {
                    StoreData storeDataObj = widget.allStoreData.data[index];
                    return InkWell(
                      onTap: () {
                        print("----onTap-${storeDataObj.id}--");
                        Utils.showProgressDialog(context);
                        ApiController.getStoreVersionData(storeDataObj.id)
                            .then((response) {
                          Utils.hideProgressDialog(context);
                          Utils.hideKeyboard(context);
                          StoreDataModel storeObject = response;
                          widget.callback(value: storeObject);
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.all(10),
                            decoration: new BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  topLeft: Radius.circular(5)),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                        height: 150,
                                        child: storeDataObj.image.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(5),
                                                    topLeft:
                                                        Radius.circular(5)),
                                                child: CachedNetworkImage(
                                                    height: 150,
                                                    width: Utils.getDeviceWidth(
                                                        context),
                                                    imageUrl:
                                                        "${storeDataObj.image}",
                                                    fit: BoxFit.cover),
                                              )
                                            : null,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              topLeft: Radius.circular(5)),
                                          image: storeDataObj.image.isEmpty
                                              ? DecorationImage(
                                                  image: AssetImage(
                                                      'images/img1.png'),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16, top: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${storeDataObj.storeName}',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            /*Row(
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
                                            '4.0/',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            '5',
                                            style: TextStyle(
                                                fontSize: 16, color: Colors.grey),
                                          )
                                        ],
                                      ),*/
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 5,
                                            bottom: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${storeDataObj.state}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            /*Text(
                                        '${AppConstant.currency}350 for two',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),*/
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
                          Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: EdgeInsets.only(top: 130, right: 20),
                                padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                                decoration: BoxDecoration(
                                    color: whiteWith70Opacity,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                  child: Text(
                                    "45 mins",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ),
                                width: 70,
                              )),
                        ],
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }
}
