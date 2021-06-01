import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:restroapp/src/Screens/Subscription/BaseState.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionPurchasedScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionUtils.dart';
import 'package:restroapp/src/UI/AddressByRadius.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/MembershipPlanResponse.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
import 'package:restroapp/src/models/StorelatlngsResponse.dart';
import 'package:restroapp/src/models/UserPurchaseMembershipResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class SubscriptionTypeSelection extends StatefulWidget {
  MembershipPlanResponse membershipPlanResponse;
  MemberShipType _passedMemberShipType;

  @override
  _SubscriptionTypeSelectionState createState() =>
      _SubscriptionTypeSelectionState(
          membershipPlanResponse, _passedMemberShipType);

  SubscriptionTypeSelection(
      this.membershipPlanResponse, this._passedMemberShipType);
}

enum SubscriptionType { Subscription_Lunch, Subscription_Dinner }

class _SubscriptionTypeSelectionState
    extends BaseState<SubscriptionTypeSelection> {
  SubscriptionType _selectedType;
  DeliveryAddressResponse responsesData;
  int _selectedAddressIndex = 0;

  bool isLoading = true;

  List<DeliveryAddressData> addressList = List.empty(growable: true);
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  StoreLatLngModel _selectedSourceStore;
  MembershipPlanResponse membershipPlanResponse;

  MemberShipType _passedMemberShipType;

  callApi() {
    isLoading = true;
    ApiController.getAddressApiRequest()
        .then((responses) => _handleResponse(responses));

    //fetch stores
    _callSourceStoresApi();
    enablePaymentModule(
        PaymentMethod.SUBSCRIPTION, _handlePaymentSuccess, _handlePaymentError);
  }

  _SubscriptionTypeSelectionState(
      this.membershipPlanResponse, this._passedMemberShipType);

  _handleResponse(DeliveryAddressResponse responses) async {
    print('hfdsfffff----------------------------');
    responsesData = responses;
    print(responses.data.length);
    if (responsesData != null && responsesData.success) {
      addressList.clear();
      _selectedAddressIndex = 0;
      print('hfdsfffff----------------------------1');

      String defaultAddressID = SingletonBrandData.getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.defaultAddressId ??
          '';
      print('hfdsfffff----------------------------2');
      bool isSubscriptionActive = SingletonBrandData.getInstance()
              ?.userPurchaseMembershipResponse
              ?.data
              ?.status ??
          false;
      print('hfdsfffff----------------------------3');
      for (int i = 0; i < responsesData.data.length; i++) {
//        if (defaultAddressID != responses.data[i].id || !isSubscriptionActive)
//          addressList.add(responsesData.data[i]);
        if (defaultAddressID == responses.data[i].id && isSubscriptionActive) {
          responsesData.data[i].isSubscriptionOAddress = true;
          print('hfdsfffff----------------------------4');
        }

        addressList.add(responsesData.data[i]);
        print('hfdsfffff----------------------------5');
      }
    }

    setState(() {
      print('hfdsfffff----------------------------6');
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appTheme,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 25, bottom: 25),
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Select your Meal type',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                    Padding(
                      padding: EdgeInsets.only(left: 26.0, right: 26.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedType =
                                      SubscriptionType.Subscription_Lunch;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedType ==
                                          SubscriptionType.Subscription_Lunch
                                      ? appThemeSecondary
                                      : Colors.grey[200],
                                ),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 15, bottom: 15),
                                      width: double.maxFinite,
                                      child: Column(children: [
                                        Image(
                                          image: AssetImage(
                                              'images/lunchicon.png'),
                                          height: 40,
                                          width: 80,
                                          color: _selectedType ==
                                                  SubscriptionType
                                                      .Subscription_Lunch
                                              ? Colors.white
                                              : appTheme,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Lunch',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: _selectedType ==
                                                      SubscriptionType
                                                          .Subscription_Lunch
                                                  ? Colors.white
                                                  : appTheme),
                                          textAlign: TextAlign.center,
                                        ),
                                      ]),
                                    ),
                                    Visibility(
                                      visible: _selectedType ==
                                          SubscriptionType.Subscription_Lunch,
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                              height: 25,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                  ),
                                                  color: Colors.red[900]),
                                              child: Image(image: AssetImage('images/selectmealtick.png'),color: Colors.white,))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 30,
                            margin: EdgeInsets.only(left: 20, right: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                'or',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedType =
                                      SubscriptionType.Subscription_Dinner;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _selectedType ==
                                          SubscriptionType.Subscription_Dinner
                                      ? appThemeSecondary
                                      : Colors.grey[200],
                                ),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 15, bottom: 15),
                                      width: double.maxFinite,
                                      child: Column(children: [
                                        Image(
                                            image: AssetImage(
                                                'images/dinnericon.png'),
                                            height: 40,
                                            width: 80,
                                            color: _selectedType ==
                                                    SubscriptionType
                                                        .Subscription_Dinner
                                                ? Colors.white
                                                : appTheme),
                                        SizedBox(height: 5),
                                        Text(
                                          'Dinner',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: _selectedType ==
                                                      SubscriptionType
                                                          .Subscription_Dinner
                                                  ? Colors.white
                                                  : appTheme),
                                          textAlign: TextAlign.center,
                                        ),
                                      ]),
                                    ),
                                    Visibility(
                                      visible: _selectedType ==
                                          SubscriptionType.Subscription_Dinner,
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                              height: 25,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                  ),
                                                  color: Colors.red[900]),
                                              child:Image(image: AssetImage('images/selectmealtick.png'),color: Colors.white,))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 30,
                          bottom: isLoading == false &&
                                  addressList != null &&
                                  addressList.isNotEmpty
                              ? 15
                              : 30),
                      child: Divider(
                          height: 2, thickness: 2, indent: 80, endIndent: 80),
                    ),
                    Container(
                        color: isLoading == false &&
                                addressList != null &&
                                addressList.isNotEmpty
                            ? Colors.transparent
                            : appTheme,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(
                            left: 46,
                            right: 46,
                            bottom: isLoading == false &&
                                    addressList != null &&
                                    addressList.isNotEmpty
                                ? 0
                                : 20),
                        padding: EdgeInsets.all(10),
                        child: InkWell(
                          child: Text('+ Add delivery Address',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  decoration: isLoading == false &&
                                          addressList != null &&
                                          addressList.isNotEmpty
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                  color: appThemeSecondary),
                              textAlign: TextAlign.center),
                          onTap: _addAddress,
                        )),
                    Expanded(
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : addressList == null
                                ? Center(child: Text("Something went wrong!"))
                                : addAddressList())
                  ],
                )),
            Visibility(
              visible: _selectedType != null &&
                  addressList != null &&
                  addressList.isNotEmpty,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return appThemeSecondary; // Defer to the widget's default.
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return Colors.white; // Defer to the widget's default.
                      }),
                    ),
                    onPressed: _handleConfirmClick,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        'Confirm',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget addAddressList() {
    //Utils.hideProgressDialog(context);
    if (addressList.isEmpty) {
      return Container(
        margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: addressList.length,
        itemBuilder: (context, index) {
          DeliveryAddressData area = addressList[index];
          return addAddressCard(area, index);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.grey[200],
            height: 10,
          );
        },
      );
    }
  }

  Widget addAddressCard(DeliveryAddressData area, int index) {
    return Container(
      margin: EdgeInsets.only(left: 26, right: 26, top: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAddressIndex = index;
          });
        },
        child: Padding(
            padding: EdgeInsets.only(top: 10, left: 6),
            child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        _selectedAddressIndex == index
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: appTheme,
                        size: 25,
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${area.firstName}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20.0),
                              ),
                              Visibility(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                          top: 5,
                                          bottom: 5),
                                      decoration: BoxDecoration(
                                        color: grey2,
//                                        border: Border.all(
//                                            color: grayLightColorSecondary),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        area.addressType != null &&
                                                area.addressType.isNotEmpty
                                            ? area.addressType
                                            : '',
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                                visible: area.addressType != null &&
                                    area.addressType.isNotEmpty,
                              ),
                              Visibility(
                                visible: area.set_default_address == '1',
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                    color: grey2,
//                                    border: Border.all(
//                                        color: grayLightColorSecondary),
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
                              )
                            ],
                          ),
                          addAddressInfoRow(Icons.phone, area.mobile),
                          addAddressInfoRow(
                            Icons.location_on,
                            area.address2 != null &&
                                    area.address2.trim().isNotEmpty
                                ? '${area.address != null && area.address.trim().isNotEmpty ? '${area.address}, ${area.address2}' : "${area.address2}"}'
                                : area.address,
                          ),
                          addAddressInfoRow(Icons.email, area.email),
                        ],
                      ),
                    ),
                  ]),
              Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(color: Color(0xFFBDBDBD), height: 1.0)),
              addOperationBar(area, index),
              Visibility(
                visible: index == addressList.length - 1,
                child: Padding(
                    padding: EdgeInsets.only(top: 0, bottom: 100),
                    child: Container(color: Color(0xFFBDBDBD), height: 1.0)),
              ),
            ])),
      ),
    );
  }

  Widget addAddressInfoRow(IconData icon, String info) {
    return Visibility(
      visible: info.isNotEmpty,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
        child: Text(info,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: infoLabel)),
      ),
    );
  }

  Widget addOperationBar(DeliveryAddressData area, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
      child: addressList[index].isSubscriptionOAddress
          ? InkWell(
              onTap: () {
                DialogUtils.displayCommonDialog(
                    context,
                    'Subscription Delivery Address',
                    'This Address is used for subscription orders.\nThats why we are not allowing to edit/Remove this address.');
              },
              child: SizedBox(
                height: 30,
                child: Center(
                  child: Text("Subscription Delivery Address",
                      style: TextStyle(
                          color: infoLabel, fontWeight: FontWeight.w500)),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: InkWell(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("Edit Address",
                          style: TextStyle(
                              color: infoLabel,
                              fontWeight: FontWeight.w400,
                              fontSize: 16)),
                    ),
                    onTap: () async {
                      print("edit=${area.address}");

                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DragMarkerMap(area),
                            fullscreenDialog: true,
                          ));
                      print("-Edit-result--${result}-------");
                      if (result == true) {
                        setState(() {
                          isLoading = true;
                        });
                        ApiController.getAddressApiRequest()
                            .then((responses) => _handleResponse(responses));
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
                            color: infoLabel,
                            fontWeight: FontWeight.w400,
                            fontSize: 16)),
                  ),
                  onTap: () async {
                    print(
                        "--selectedIndex ${_selectedAddressIndex} and ${index} and ${area.id}");
                    var results = await DialogUtils.displayDialog(context,
                        "Delete", AppConstant.deleteAddress, "Cancel", "OK");

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
                                "--selectedIndex ${_selectedAddressIndex} and ${index}");
                            if (_selectedAddressIndex == index &&
                                addressList.isNotEmpty) {
                              _selectedAddressIndex = 0;
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

  void _addAddress() async {
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
      ApiController.getAddressApiRequest().then((value) => _handleResponse(value));
    } else {
      print("--result--else------");
    }
  }

  void _handlePaymentSuccess() async {
    Utils.showProgressDialog(context);
    UserPurchaseMembershipResponse response =
        await ApiController.getUserMembershipPlanApi();
    bool isSucceed = await showSubscriptionSuccessDialog(context, () {
      Navigator.pop(context, true);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SubscriptionPurchasedScreen()));
    });
//    if (isSucceed) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handlePaymentError() {
    showSubscriptionFailedDialog(context);
  }

  void _handleConfirmClick() async {
    if (_selectedSourceStore == null)
      _selectedSourceStore = await _callSourceStoresApi();

    print(
        "====${addressList[_selectedAddressIndex].lat},${addressList[_selectedAddressIndex].lng}===");
    double distanceInKm = Utils.calculateDistance(
        double.parse(addressList[_selectedAddressIndex].lat),
        double.parse(addressList[_selectedAddressIndex].lng),
        double.parse(_selectedSourceStore.lat),
        double.parse(_selectedSourceStore.lng));

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
      bool dialogResult = await DialogUtils.displayLocationNotAvailbleDialog(
          context, 'We dont\'t serve\nin your area');
      if (dialogResult != null && dialogResult) {
        var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  DragMarkerMap(addressList[_selectedAddressIndex]),
              fullscreenDialog: true,
            ));
        print("-Edit-result--${result}-------");
        if (result == true) {
          setState(() {
            isLoading = true;
          });
          ApiController.getAddressApiRequest().then((value) => _handleResponse(value));
        }
      }
    } else {
      //_extra fields
      Map<String, dynamic> _subscriptionPlanFields = Map();
      _subscriptionPlanFields.putIfAbsent(
          'purchaseType', () => checkIsRewPlanPurchased(_passedMemberShipType));
      _subscriptionPlanFields.putIfAbsent(
          'amountPaid', () => membershipPlanResponse.data.planTotalCharges);
      _subscriptionPlanFields.putIfAbsent(
          'additionalInfo',
          () => _selectedType == SubscriptionType.Subscription_Lunch
              ? 'Lunch'
              : 'Dinner');
      _subscriptionPlanFields.putIfAbsent(
          'posBranchCode', () => _selectedSourceStore.posBranchCode);
      _subscriptionPlanFields.putIfAbsent(
          'defaultAddressId', () => addressList[_selectedAddressIndex].id);
      initRazorPayPayment(
        PaymentMethod.SUBSCRIPTION,
        _subscriptionPlanFields,
        membershipPlanResponse.data.planTotalCharges,
      );
    }
  }

  Future<StoreLatLngModel> _callSourceStoresApi() {
    ApiController.getStoreLatlngsApi().then((value) async {
      if (value != null && value.success && value.data.isNotEmpty) {
        StoreLatlngsResponse response = value;
        _selectedSourceStore = response.data.first;
        if (response.data.length > 1)
          _selectedSourceStore =
              await DialogUtils.displaySubscriptionsStoreList(
                  context, 'Select Store', response);
        setState(() {});

        return _selectedSourceStore;
      }
    });
  }
}
