import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class ContactUs extends StatefulWidget {
  UserModelMobile model;

  ContactUs();

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController mobileNameController = TextEditingController();

  TextEditingController emailNameController = TextEditingController();

  TextEditingController cityNameController = TextEditingController();

  TextEditingController messagetNameController = TextEditingController();

  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  String locationAddress;

  @override
  void initState() {
    super.initState();
    try {
      if (widget.model != null) {
        fillDetails();
      } else {
        getUser();
      }
    } catch (e) {
      print(e);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
  }

  void getUser() async {
    widget.model = await SharedPrefs.getUserMobile();
    fillDetails();
  }

  void fillDetails() {
    firstNameController.text = widget.model.fullName;
    lastNameController.text = widget.model.lastName;
    mobileNameController.text = widget.model.phone;
    emailNameController.text = widget.model.email;
  }

  Future<void> getCurrentLocation() async {
    print("AppBar onTap");
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    if (!isNetworkAvailable) {
      Utils.showToast("No Internet connection", false);
      return;
    }
    LatLng _initialPosition;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
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
        var result = await DialogUtils.displayDialog(
            context,
            "Location Permission Required",
            "Please enable location permissions in settings.",
            "Cancel",
            "Ok");
        if (result == true) {
          permission_handler.openAppSettings();
        }
        return;
      }
    }
    if (Platform.isAndroid) {
      await location.changeSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        interval: 1000,
      );
    }
    _locationData = await location.getLocation();
    _initialPosition = LatLng(_locationData.latitude, _locationData.longitude);
    if (_initialPosition != null) {
      Coordinates coordinates = new Coordinates(
          _initialPosition.latitude, _initialPosition.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      //print("--addresses-${addresses} and ${first}");
      print(
          "----------${first.featureName} and ${first.addressLine}-postalCode-${first.postalCode}------");
      setState(() {
//        locationAddress = first.addressLine;
        locationAddress =
            '${first.locality != null ? ' ' + first.locality : ''} ${first.adminArea != null ? ' ' + first.adminArea : ''}';
        cityNameController.text = locationAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: new Text('Contact'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("First Name*"),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
                  child: Container(
                    //width: width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
                            child: Icon(Icons.person),
                          ),
                          Expanded(
                            child: TextField(
                              controller: firstNameController,
                              textAlign: TextAlign.left,
                              decoration: new InputDecoration.collapsed(
                                hintText: "Enter your first Name",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text("Last Name*"),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
                  child: Container(
                    //width: width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
                            child: Icon(Icons.person),
                          ),
                          Expanded(
                            child: TextField(
                              controller: lastNameController,
                              textAlign: TextAlign.left,
                              decoration: new InputDecoration.collapsed(
                                hintText: "Enter your last Name",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text("Mobile*"),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
                  child: Container(
                    //width: width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
                            child: Icon(Icons.call),
                          ),
                          Expanded(
                            child: TextField(
                              controller: mobileNameController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.left,
                              decoration: new InputDecoration.collapsed(
                                hintText: "Enter your mobile number",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text("Email*"),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
                  child: Container(
                    //width: width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
                            child: Icon(Icons.email),
                          ),
                          Expanded(
                            child: TextField(
                              controller: emailNameController,
                              keyboardType: TextInputType.emailAddress,
                              textAlign: TextAlign.left,
                              decoration: new InputDecoration.collapsed(
                                hintText: "Enter your email",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text("Location *"),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
                  child: Container(
                    //width: width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
                            child: Icon(Icons.location_on),
                          ),
                          Expanded(
                            child: TextField(
                              controller: cityNameController,
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.left,
                              decoration: new InputDecoration.collapsed(
                                hintText: "Enter your Location",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text("Write Your Message"),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
                  child: Container(
                    //width: width,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 15, 10.0, 0),
                            child: Icon(Icons.chat_bubble),
                          ),
                          Expanded(
                            child: TextField(
                              controller: messagetNameController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              textAlign: TextAlign.left,
                              decoration: new InputDecoration.collapsed(
                                hintText: "Enter your message",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 20, 10),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: appThemeSecondary)),
                    child: Text('Send Your Message'),
                    color: appThemeSecondary,
                    textColor: Colors.white,
                    onPressed: () async {
                      bool isNetworkAvailable =
                          await Utils.isNetworkAvailable();
                      if (!isNetworkAvailable) {
                        Utils.showToast(AppConstant.noInternet, true);
                        return;
                      }
                      if (firstNameController.text.trim().isEmpty) {
                        Utils.showToast("Please enter first name", true);
                        return;
                      }
                      if (lastNameController.text.trim().isEmpty) {
                        Utils.showToast("Please enter last name", true);
                        return;
                      }
                      if (mobileNameController.text.trim().isEmpty) {
                        Utils.showToast("Please enter mobile number", true);
                        return;
                      }
                      if (emailNameController.text.isEmpty) {
                        Utils.showToast("Please enter email", true);
                        return;
                      }
                      if (!Utils.validateEmail(
                          emailNameController.text.trim())) {
                        Utils.showToast("Please enter valid email", true);
                        return;
                      }
                      if (cityNameController.text.trim().isEmpty) {
                        Utils.showToast("Please enter location", true);
                        return;
                      }

                      Utils.showProgressDialog(context);

                      String queryString = json.encode({
                        "name":
                            "${firstNameController.text} ${lastNameController.text}",
                        "email": emailNameController.text,
                        "mobile": mobileNameController.text,
                        "city": cityNameController.text,
                        "datetime": "${Utils.getCurrentDateTime()}",
                        "message": messagetNameController.text
                      });

                      ApiController.setStoreQuery(queryString).then((response) {
                        Utils.hideProgressDialog(context);
                        if (response.success) {
                          Utils.hideProgressDialog(context);
                          ResponseModel resModel = response;
                          Utils.showToast(resModel.message, true);
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
