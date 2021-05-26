import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:restroapp/src/UI/AddressByRadius.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import '../BookOrder/ConfirmOrderScreen.dart';
import 'package:location/location.dart';

class DeliveryAddressList extends StatefulWidget {
  final bool showProceedBar;
  OrderType delivery;

  DeliveryAddressList(this.showProceedBar, this.delivery);

  @override
  _AddDeliveryAddressState createState() => _AddDeliveryAddressState();
}

class _AddDeliveryAddressState extends State<DeliveryAddressList> {
  int selectedIndex = 0;
  List<DeliveryAddressData> addressList = List.empty(growable: true);
  Area radiusArea;
  Coordinates coordinates;
  bool isLoading = false;
  DeliveryAddressResponse responsesData;
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
    coordinates = new Coordinates(0.0, 0.0);
    callDeliverListApi();
  }

  callDeliverListApi() {
    isLoading = true;
    ApiController.getAddressApiRequest()
        .then((value) => _handleResponse(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery Addresses"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Padding(
              padding:
              EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0, right: 10),
              child: Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : addressList == null
          ? SingleChildScrollView(
          child: Center(child: Text("Something went wrong!")))
          : Column(
        children: <Widget>[
          Divider(color: Colors.white, height: 2.0),
          addCreateAddressButton(),
          addAddressList()
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: widget.showProceedBar ? addProceedBar() : Container(height: 5),
      ),
    );
  }

  Widget addCreateAddressButton() {
    return Container(
      height: 50.0,
      color: appTheme,
      child: InkWell(
        onTap: () async {
          print("----addCreateAddressButton-------");
          _serviceEnabled = await location.serviceEnabled();
          if (!_serviceEnabled) {
            _serviceEnabled = await location.requestService();
            if (!_serviceEnabled) {
              print("----!_serviceEnabled----$_serviceEnabled");
              return;
            }
          }
          _permissionGranted = await location.hasPermission();
          print("permission sttsu $_permissionGranted");
          if (_permissionGranted == PermissionStatus.denied) {
            print("permission deniedddd");
            _permissionGranted = await location.requestPermission();
            if (_permissionGranted != PermissionStatus.granted) {
              print("permission not grantedd");
              return;
            }
          }
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return DragMarkerMap(null);
                },
                fullscreenDialog: true,
              ));
          if (result == true) {
            //Utils.showProgressDialog(context);
            setState(() {
              isLoading = true;
            });
            ApiController.getAddressApiRequest()
                .then((value) => _handleResponse(value));
            ;
            //Utils.hideProgressDialog(context);
          } else {
            print("--result--else------");
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 35.0,
            ),
            Text(
              "Add Delivery Address",
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget addAddressList() {
    //Utils.hideProgressDialog(context);
    if (addressList.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: Text("No Delivery Address found!"),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: addressList.length,
          itemBuilder: (context, index) {
            DeliveryAddressData area = addressList[index];
            return addAddressCard(area, index);
          },
        ),
      );
    }
  }

  Widget addAddressCard(DeliveryAddressData area, int index) {
    return Card(
      child: Padding(
          padding: EdgeInsets.only(top: 10, left: 6),
          child: Column(children: [
            Stack(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: (Utils.getDeviceWidth(context) - 100),
                            child: Text(
                              "${area.firstName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16.0),
                            ),
                          ),
                          addAddressInfoRow(Icons.phone, area.mobile),
                          addAddressInfoRow(
                            Icons.location_on,
                            area.address2 != null &&
                                area.address2
                                    .trim()
                                    .isNotEmpty
                                ? '${area.address != null && area.address
                                .trim()
                                .isNotEmpty ? '${area.address}, ${area
                                .address2}' : "${area.address2}"}'
                                : area.address,
                          ),
                          addAddressInfoRow(Icons.email, area.email),
                        ],
                      ),
                      Container(
                        child: Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              activeColor: Color(0xFFE0E0E0),
                              checkColor: Colors.green,
                              value: selectedIndex == index,
                              onChanged: (value) {
                                setState(() {
                                  print("index = ${index}");
                                  selectedIndex = index;
                                });
                              },
                            )),
                      )
                    ]),
                Align(
                    alignment: Alignment.topRight,
                    child: Visibility(
                      child: Wrap(
                        children: [
                          Container(
//                        width: 70,
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: grey2,
                              border:
                              Border.all(color: grayLightColorSecondary),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              area.addressType != null &&
                                  area.addressType.isNotEmpty
                                  ? area.addressType
                                  : '',
                              style:
                              TextStyle(fontSize: 13, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      visible: area.addressType != null &&
                          area.addressType.isNotEmpty,
                    )),
              ],
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Visibility(
                  child: Wrap(
                    children: [
                      Visibility(
                        visible: area.set_default_address == '1',
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: grey2,
                            border: Border.all(color: grayLightColorSecondary),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Default Address',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ],
                  ),
                  visible:
                  area.addressType != null && area.addressType.isNotEmpty,
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Divider(color: Color(0xFFBDBDBD), thickness: 1.0),
            ),
            addOperationBar(area, index)
          ])),
    );
  }

  Widget addAddressInfoRow(IconData icon, String info) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 5, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          //Icon(icon, color: Colors.grey,),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: SizedBox(
              width: (Utils.getDeviceWidth(context) - 130),
              child: Text(info,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: infoLabel)),
            ),
          ),
        ],
      ),
    );
  }

  Widget addOperationBar(DeliveryAddressData area, int index) {
    return
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
        child: addressList[index].isSubscriptionOAddress ? InkWell(
          onTap: () {
            DialogUtils.displayCommonDialog(
                context, 'Subcription Delivery Address', 'This Address is used for subscription orders.\nThats why we are not allowing to edit/Remove this address.');
          },
          child: SizedBox(
            height: 30,
            child: Center(
              child: Text("Subcription Delivery Address",
                  style: TextStyle(
                      color: infoLabel, fontWeight: FontWeight.w500)),
            ),
          ),
        ) :
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: InkWell(
                child: Align(
                  alignment: Alignment.center,
                  child: Text("Edit Address",
                      style: TextStyle(
                          color: infoLabel, fontWeight: FontWeight.w500)),
                ),
                onTap: () async {
                  print("edit=${area.address}");

                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => DragMarkerMap(area),
                        fullscreenDialog: true,
                      ));
                  print("-Edit-result--${result}-------");
                  if (result == true) {
                    setState(() {
                      isLoading = true;
                    });
                    ApiController.getAddressApiRequest()
                        .then((value) => _handleResponse(value));
                    ;
                  }
                },
              ),
            ),
            Container(
              color: Colors.grey,
              height: 30,
              width: 1,
            ),
            Flexible(
                child: InkWell(
                  child: Align(
                    alignment: Alignment.center,
                    child: new Text("Remove Address",
                        style: TextStyle(
                            color: infoLabel, fontWeight: FontWeight.w500)),
                  ),
                  onTap: () async {
                    print(
                        "--selectedIndex ${selectedIndex} and ${index} and ${area
                            .id}");
                    var results = await DialogUtils.displayDialog(
                        context, "Delete",
                        AppConstant.deleteAddress, "Cancel", "OK");

                    if (results == true) {
                      Utils.showProgressDialog(context);

                      ApiController.deleteDeliveryAddressApiRequest(area.id)
                          .then((response) async {
                        Utils.hideProgressDialog(context);
                        if (response != null && response.success) {
                          print("---showDialogForDelete-----");
                          Utils.showToast(response.message, false);
                          setState(() {
                            addressList.removeAt(index);
                            print(
                                "--selectedIndex ${selectedIndex} and ${index}");
                            if (selectedIndex == index &&
                                addressList.isNotEmpty) {
                              selectedIndex = 0;
                            }
                          });
                        }
                      });
                    }
                  },
                )),
          ],
        ),
      );
  }

  Widget addProceedBar() {
    return Container(
      height: 50.0,
      color: appTheme,
      child: InkWell(
        onTap: () async {
          StoreDataObj store = await SharedPrefs.getStoreData();
          print(
              "====${addressList[selectedIndex]
                  .lat},${addressList[selectedIndex].lng}===");
          double distanceInKm = Utils.calculateDistance(
              double.parse(addressList[selectedIndex].lat),
              double.parse(addressList[selectedIndex].lng),
              double.parse(store.lat),
              double.parse(store.lng));

          int distanceInKms = distanceInKm.toInt();

          print("==distanceInKm==${distanceInKms}");

          StoreRadiousResponse storeRadiousResponse =
          await ApiController.storeRadiusApi();

          Area area;
          //print("---${areaList.length}---and-- ${distanceInKms}---");
          for (int i = 0; i < storeRadiousResponse.data.length; i++) {
            Area areaObject = storeRadiousResponse.data[i];
            int radius = int.parse(areaObject.radius);
            if (distanceInKms < radius && areaObject.radiusCircle == "Within") {
              area = areaObject;
              break;
            } else {}
          }
          if (area == null) {
            bool dialogResult =
            await DialogUtils.displayLocationNotAvailbleDialog(
                context, 'We dont\'t serve\nin your area');
            if (dialogResult != null && dialogResult) {
              var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        DragMarkerMap(addressList[selectedIndex]),
                    fullscreenDialog: true,
                  ));
              print("-Edit-result--${result}-------");
              if (result == true) {
                setState(() {
                  isLoading = true;
                });
                ApiController.getAddressApiRequest()
                    .then((value) => _handleResponse(value));
              }
            }
          } else {
            StoreDataObj storeModel = await SharedPrefs.getStoreData();
            if (addressList.length == 0) {
              Utils.showToast(AppConstant.selectAddress, false);
            } else {
              print("---radius-- ${area.radius}-charges.and ${area.charges}--");
              print("minAmount=${addressList[selectedIndex].minAmount}");
              print("notAllow=${addressList[selectedIndex].notAllow}");
              if (area.note.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ConfirmOrderScreen(
                            addressList[selectedIndex],
                            false,
                            "",
                            widget.delivery,
                            areaObject: area,
                            storeModel: storeModel,
                          )),
                );
              } else {
                var result = await DialogUtils.displayOrderConfirmationDialog(
                  context,
                  "Confirmation",
                  area.note,
                );
                if (result == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ConfirmOrderScreen(
                                addressList[selectedIndex],
                                false,
                                "",
                                widget.delivery,
                                areaObject: area,
                                storeModel: storeModel)),
                  );
                }
              }
            }
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Proceed",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }

  _handleResponse(DeliveryAddressResponse responses) async {
    responsesData = responses;
    if (responsesData != null && responsesData.success) {
      addressList.clear();
      selectedIndex = 0;
      String defaultAddressID = SingletonBrandData
          .getInstance()
          ?.userPurchaseMembershipResponse
          ?.data
          ?.defaultAddressId ??
          '';
      bool isSubscriptionActive = SingletonBrandData
          .getInstance()
          ?.userPurchaseMembershipResponse
          ?.data
          ?.status ??
          false;
      for (int i = 0; i < responsesData.data.length; i++) {
//        if (defaultAddressID != responses.data[i].id || !isSubscriptionActive)
//          addressList.add(responsesData.data[i]);
        if (defaultAddressID == responses.data[i].id && isSubscriptionActive) {
          responsesData.data[i].isSubscriptionOAddress = true;
        }
        addressList.add(responsesData.data[i]);
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
