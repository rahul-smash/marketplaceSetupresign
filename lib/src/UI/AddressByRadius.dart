import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/widgets/AutoSearch.dart';
import 'package:google_maps_webservice/places.dart';

class DragMarkerMap extends StatefulWidget {
  DeliveryAddressData addressData;

  DragMarkerMap(this.addressData);

  @override
  _DragMarkerMapState createState() => _DragMarkerMapState();
}


class _DragMarkerMapState extends State<DragMarkerMap> {
  LatLng center, selectedLocation;
  final cityController = new TextEditingController();
  final stateController = new TextEditingController();
  final firstNameController = new TextEditingController();
  final lastNameController = new TextEditingController();
  final mobileController = new TextEditingController();
  final emailController = new TextEditingController();
  final addressController = new TextEditingController();
  String address;
  bool isButtonPressed = false;
  List<String> addressList = List();
  ScrollController controller = ScrollController();

  UserModelMobile user;

  String _selectedTag;

  @override
  void initState() {
    super.initState();
    addressList.add('Home');
    addressList.add('Work');
    addressList.add('Other');
    _selectedTag = addressList.first;

    if (widget.addressData != null) {
      //Edit address mode
      center = LatLng(double.parse(widget.addressData.lat),
          double.parse(widget.addressData.lng));
      selectedLocation = LatLng(double.parse(widget.addressData.lat),
          double.parse(widget.addressData.lng));
      address = widget.addressData.address2;
      cityController.text = widget.addressData.city.trim();
      stateController.text = widget.addressData.state.trim();
      firstNameController.text = widget.addressData.firstName.trim();
      lastNameController.text = widget.addressData.lastName.trim();
      mobileController.text = widget.addressData.mobile.trim();
      emailController.text = widget.addressData.email.trim();
      addressController.text = widget.addressData.address.trim();
      _selectedTag = widget.addressData.addressType.trim();
      //_mapController.moveCamera(CameraUpdate.newLatLng(center));
    } else {
      //new address adding
      center = LatLng(0.0, 0.0);
      selectedLocation = LatLng(0.0, 0.0);
      address = "";
      getLocation();
      getUserDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:
              Text(widget.addressData != null ? "Edit Address" : 'Add Address'),
          backgroundColor: appTheme,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
              controller: controller,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      addLabelWithField(
                          'First Name', 'Type first name', firstNameController),
                      addLabelWithField(
                          'Last Name', 'Type last name', lastNameController),
                      addLabelWithField(
                          'Mobile', 'Type mobile number', mobileController,
                          isNumericType: true),
                      addLabelWithField(
                          'Email', 'Type email ID', emailController,
                          isOptionaField: true),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 15),
                        child: Text.rich(
                          TextSpan(
                            text: 'Location',
                            style: TextStyle(color: infoLabel, fontSize: 12),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                  )),
                              // can add more TextSpans here...
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 15),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.zero,
//                            EdgeInsets.only(left: 10.0, right: 10, top: 5, bottom: 5),
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: TextSpan(
                                    text: "${address}",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ),
                            )),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () {
                                  showBottomSheet(
                                      context, center, selectedLocation);
                                },
                                child: Text('Change',
                                    style: TextStyle(
                                      color: Colors.lightBlue,
                                    )))
                          ],
                        ),
                      ),
                      addDivider(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 15),
                        child: Text.rich(
                          TextSpan(
                            text: 'Address',
                            style: TextStyle(color: infoLabel, fontSize: 12),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        color: Colors.grey[200],
                        height: 100.0,
                        child: new TextField(
                          controller: addressController,
                          keyboardType: TextInputType.text,
                          maxLength: 100,
                          maxLines: null,
                          decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 10, bottom: 10, top: 10, right: 10),
                              hintText:
                                  'Type address here' /*AppConstant.enterAddress*/),
                        ),
                      ),
                      addLabelWithField(
                          'City', 'Type city here', cityController,
                          isOptionaField: true),
                      addLabelWithField(
                          'State', 'Type state here', stateController,
                          isOptionaField: true),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 15,
                          children: addressList.map((tag) {
                            return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTag = tag;
                                  });
                                },
                                child: Container(
                                  width: 80,
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: _selectedTag.toLowerCase() ==
                                            tag.toLowerCase()
                                        ? webThemeCategoryOpenColor
                                        : grey2,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: _selectedTag.toLowerCase() ==
                                                  tag.toLowerCase()
                                              ? appTheme
                                              : Colors.black),
                                    ),
                                  ),
                                ));
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ButtonTheme(
                          minWidth: Utils.getDeviceWidth(context) - 100,
                          height: 40.0,
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                                side: BorderSide(color: appTheme)),
                            onPressed: () async {
                              checkIfOrderDeliveryWithInRadious();
                            },
                            color: appTheme,
                            padding: EdgeInsets.all(5.0),
                            textColor: Colors.white,
                            child: Text(
                              widget.addressData != null
                                  ? "Update Address"
                                  : "Save Address",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ))),
        ));
  }

  Widget addDivider() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Divider(color: Colors.grey, height: 2.0),
    );
  }

  void scrollTop() {
    controller.animateTo(0,
        curve: Curves.linear, duration: Duration(milliseconds: 100));
  }

  Future<void> getLocation() async {
//    Utils.showToast("Getting your location...", true);
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    center = LatLng(position.latitude, position.longitude);
    getAddressFromLocation(position.latitude, position.longitude);
  }

  String zipCode = "";

  getAddressFromLocation(double latitude, double longitude) async {
    try {
      selectedLocation = LatLng(latitude, longitude);
      Coordinates coordinates = new Coordinates(latitude, longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      if (addresses.isNotEmpty) {
        var first = addresses.first;
        //print("--addresses-${addresses} and ${first}");
        print(
            "----------${first.featureName} and ${first.addressLine}-postalCode-${first.postalCode}------");

        this.zipCode = "${first.postalCode}";

        setState(() {
          address = first.addressLine;
          cityController.text = first.locality;
          stateController.text = first.adminArea;
        });
      } else {
        address = "No address found!";
      }
    } catch (e) {
      print(e);
      address = "No address found!";
    }
  }

  Future<void> checkIfOrderDeliveryWithInRadious() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if (!isNetworkAvailable) {
      Utils.showToast(AppConstant.noInternet, false);
      return;
    }
    if (firstNameController.text.trim().isEmpty) {
      Utils.showToast("Please enter first name", false);
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      Utils.showToast("Please enter last name", false);
      return;
    }
    if (mobileController.text.trim().isEmpty) {
      Utils.showToast("Please enter mobile number", false);
      return;
    }
    if (emailController.text.trim().isNotEmpty) {
      if (!Utils.validateEmail(emailController.text.trim())) {
        Utils.showToast("Please enter valid email", true);
        return;
      }
    }
    if (addressController.text.trim().isEmpty) {
        Utils.showToast("Please enter address", true);
        return;
    }

    Utils.showProgressDialog(context);
    ApiController.saveDeliveryAddressApiRequest(
            widget.addressData != null ? "EDIT" : "ADD",
            "${firstNameController.text.trim()}",
            "${lastNameController.text.trim()}",
            "${mobileController.text.trim()}",
            "${emailController.text.trim()}",
            "${addressController.text.trim()}",
            "${cityController.text.trim()}",
            "${stateController.text.trim()}",
            "${zipCode}",
            "${selectedLocation.latitude}",
            "${selectedLocation.longitude}",
            _selectedTag,
            "${widget.addressData == null ? '' : widget.addressData.id}",
            address2: "${address}")
        .then((response) {
      Utils.hideProgressDialog(context);
      if (response != null && response.success) {
        Utils.showToast(response.message, false);
        Navigator.pop(context, true);
      } else {
        if (response != null) Utils.showToast(response.message, false);
      }
    });

    /*try {
      Area area;
      //print("---${areaList.length}---and-- ${distanceInKms}---");
      for (int i = 0; i < areaList.length; i++) {
        Area areaObject = areaList[i];
        int radius = int.parse(areaObject.radius);
        if (distanceInKms < radius && areaObject.radiusCircle == "Within") {
          //print("--if-${radius}---and-- ${distanceInKms}---");
          area = areaObject;
          break;
        } else {
          //print("--else-${radius}---and-- ${distanceInKms}---");
        }
      }
      if (area != null) {
        Utils.showProgressDialog(context);
        UserModel user = await SharedPrefs.getUser();
        ApiController.saveDeliveryAddressApiRequest(
            "ADD",
            zipCode,
            address,
            area.areaId,
            area.area,
            null,
            user.fullName,
            cityValue,
            cityId,
            "${selectedLocation.latitude}",
            "${selectedLocation.longitude}").then((response) {
          Utils.hideProgressDialog(context);
          if (response != null && response.success) {
            Utils.showToast(response.message, false);
            //Navigator.pop(context);
            Navigator.pop(context, area);
          } else {
            if (response != null)
              Utils.showToast(response.message, false);
          }
        });
      } else {
        Utils.showToast("We can not deliver at your location!", false);
      }
      print("---radius-- ${area.radius}-charges.and ${area.charges}--");
    } catch (e) {
      print(e);
    }*/
  }

  addLabelWithField(String label, String hint, TextEditingController controller,
      {bool isOptionaField = false, bool isNumericType = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
          child: !isOptionaField
              ? Text.rich(
                  TextSpan(
                    text: label,
                    style: TextStyle(color: infoLabel, fontSize: 12),
                    children: <TextSpan>[
                      TextSpan(
                          text: '*',
                          style: TextStyle(
                            color: Colors.red,
                          )),
                      // can add more TextSpans here...
                    ],
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(color: infoLabel, fontSize: 12.0),
                ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Padding(
              padding: EdgeInsets.only(top: 0.0),
              child: TextField(
                controller: controller,
                cursorColor: Colors.black,
                keyboardType:
                    isNumericType ? TextInputType.phone : TextInputType.text,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                  hintText: hint,
                ),
              ),
            ),
          ),
        ),
        addDivider(),
      ],
    );
  }

  void getUserDetails() async {
    user = await SharedPrefs.getUserMobile();
    setState(() {
      firstNameController.text = user.fullName.trim();
      mobileController.text = user.phone.trim();
      emailController.text = user.email.trim();
    });
  }

  void showBottomSheet(context, LatLng center, LatLng selectedLocation) {
    LatLng localCenter, localSelectedLocation;
    GoogleMapController _mapController;
    localCenter = center;
    localSelectedLocation = selectedLocation;
    Set<Marker> markers = Set();
    String localAddress = address;
    getAddressFromLocationFromMap(double latitude, double longitude,
        {StateSetter setState}) async {
      try {
        localCenter = LatLng(latitude, longitude);
        localSelectedLocation = LatLng(latitude, longitude);
        Coordinates coordinates = new Coordinates(latitude, longitude);
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var first = addresses.first;
        localAddress = first.addressLine;
        if (setState != null)
          setState(() {
            localAddress = first.addressLine;
          });
      } catch (e) {
        print(e);
        address = "No address found!";
      }
    }

    markers.addAll([
      Marker(
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          markerId: MarkerId('value'),
          position: localCenter,
          onDragEnd: (value) {
            getAddressFromLocationFromMap(value.latitude, value.longitude);
          })
    ]);
    getAddressFromLocationFromMap(localCenter.latitude, localCenter.longitude);
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return Wrap(children: <Widget>[
              Container(
                color: Colors.white,
                child: Column(
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
                        'Set Location',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.all(20),
                        //padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            color: searchGrayColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            border: Border.all(
                              color: searchGrayColor,
                            )),
                        child: InkWell(
                            onTap: () async {
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return CustomSearchScaffold();
                                    },
                                    fullscreenDialog: true,
                                  ));
                              if (result != null) {
//                                PlacesDetailsResponse detail = result;
//                                double lat =
//                                    detail.result.geometry.location.lat;
//                                double lng =
//                                    detail.result.geometry.location.lng;
                                LatLng detail = result;
                                double lat = detail.latitude;
                                double lng = detail.longitude;
                                print("location = ${lat},${lng}");

                                localCenter = LatLng(lat, lng);
                                localSelectedLocation = LatLng(lat, lng);
                                getAddressFromLocationFromMap(lat, lng,
                                    setState: setState);
                                markers.clear();
                                markers.addAll([
                                  Marker(
                                      draggable: true,
                                      icon: BitmapDescriptor.defaultMarker,
                                      markerId: MarkerId('value'),
                                      position: localCenter,
                                      onDragEnd: (value) {
                                        getAddressFromLocationFromMap(
                                            value.latitude, value.longitude,
                                            setState: setState);
                                      })
                                ]);
                                setState(() {
                                  _mapController.moveCamera(
                                      CameraUpdate.newLatLng(localCenter));
                                });
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(3, 3, 10, 3),
                                          child: Image.asset(
                                              'images/searchicon.png',
                                              width: 20,
                                              fit: BoxFit.scaleDown,
                                              color: appTheme)),
                                      Expanded(
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          text: TextSpan(
                                            text: "${localAddress}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                        ),
                                      )
                                    ]),
                              ),
                            ))),
                    Container(
                        height: Utils.getDeviceHeight(context) >
                                Utils.getDeviceWidth(context)
                            ? Utils.getDeviceWidth(context) - 50
                            : Utils.getDeviceHeight(context) / 2 - 50,
                        margin:
                            EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: localCenter,
                            zoom: 15.0,
                          ),
                          mapType: MapType.normal,
                          markers: markers,
                          onTap: (latLng) {
                            if (markers.length >= 1) {
                              markers.clear();
                            }
                            setState(() {
                              markers.add(Marker(
                                  draggable: true,
                                  icon: BitmapDescriptor.defaultMarker,
                                  markerId: MarkerId('value'),
                                  position: latLng,
                                  onDragEnd: (value) {
                                    print(value.latitude);
                                    print(value.longitude);
                                    getAddressFromLocationFromMap(
                                        value.latitude, value.longitude,
                                        setState: setState);
                                  }));
                              getAddressFromLocationFromMap(
                                  latLng.latitude, latLng.longitude,
                                  setState: setState);
                            });
                          },
                          onCameraMove: (CameraPosition position) {
                            CameraPosition newPos =
                                CameraPosition(target: position.target);
                            Marker marker = markers.first;

                            setState(() {
                              markers.first
                                  .copyWith(positionParam: newPos.target);
                            });
                          },
                          //onCameraMove: _onCameraMove,
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: ButtonTheme(
                        minWidth: 180.0,
                        height: 40.0,
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              side: BorderSide(color: appTheme)),
                          onPressed: () async {
                            this.center = localCenter;
                            this.selectedLocation = localSelectedLocation;
                            getAddressFromLocation(
                                localCenter.latitude, localCenter.longitude);
                            Navigator.pop(context);
                          },
                          color: appTheme,
                          padding: EdgeInsets.all(5.0),
                          textColor: Colors.white,
                          child: Text("Submit"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              )
            ]);
          });
        });
  }
}

class AddressTags {
  String title;

  AddressTags(this.title);
}
