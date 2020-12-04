import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:restroapp/src/widgets/AutoSearch.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';


class DragMarkerMap extends StatefulWidget {


  DragMarkerMap();

  @override
  _DragMarkerMapState createState() => _DragMarkerMapState();
}

class _DragMarkerMapState extends State<DragMarkerMap> {

  GoogleMapController _mapController;
  Set<Marker> markers = Set();
  LatLng center, selectedLocation;
  bool enableDialog;
  final cityController = new TextEditingController();
  final stateController = new TextEditingController();
  String address;


  @override
  void initState() {
    super.initState();
    center = LatLng(0.0, 0.0);
    selectedLocation = LatLng(0.0, 0.0);
    address = "";
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Choose Your Location'),
        backgroundColor: appTheme,
        actions: [
          InkWell(
            onTap: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {

                      return CustomSearchScaffold();
                    },
                    fullscreenDialog: true,
                  )
              );
              if(result != null){
                PlacesDetailsResponse detail  = result;
                double lat = detail.result.geometry.location.lat;
                double lng = detail.result.geometry.location.lng;
                print("location = ${lat},${lng}");

                center = LatLng(lat, lng);
                getAddressFromLocation(lat, lng);
                markers.addAll([
                  Marker(
                      draggable: true,
                      icon: BitmapDescriptor.defaultMarker,
                      markerId: MarkerId('value'),
                      position: center,
                      onDragEnd: (value) {
                        print(value.latitude);
                        print(value.longitude);
                        getAddressFromLocation(value.latitude, value.longitude);
                      })
                ]);
                setState(() {
                  _mapController.moveCamera(CameraUpdate.newLatLng(center));
                });
              }

            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Icon(Icons.search),
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[

          Container(
            margin: EdgeInsets.fromLTRB(0, 00, 0, 0),
            height: 50,
            color: Colors.white,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 10.0, right: 10, top: 5, bottom: 5),
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    text: "Address: ${address}",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          Divider(color: Colors.grey, height: 2.0),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: TextFormField(
                        controller: cityController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding:
                            EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                            hintText: "City"),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: TextFormField(
                        controller: stateController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding:
                            EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                            hintText: "State"),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: center, zoom: 15.0,),
              mapType: MapType.normal,
              markers: markers,
              onCameraMove: _onCameraMove,
              //onCameraMove: _onCameraMove,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          child: InkWell(
            onTap: () async {
              StoreDataObj store = await SharedPrefs.getStoreData();

              print("====${selectedLocation.latitude},${selectedLocation
                  .longitude}===");
              double distanceInKm = Utils.calculateDistance(
                  selectedLocation.latitude, selectedLocation.longitude,
                  double.parse(store.lat), double.parse(store.lng));
              int distanceInKms = distanceInKm.toInt();

              print("==distanceInKm==${distanceInKm}=AND=${distanceInKms}=");

              //checkIfOrderDeliveryWithInRadious(distanceInKms);
            },
            child: Container(
              height: 45,
              color: appTheme,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: RichText(
                    text: TextSpan(
                      text: "Save Address",
                      style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getLocation() async {
    Utils.showToast("Getting your location...", true);
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // final coordinates = new Coordinates(position.latitude, position.longitude);
    center = LatLng(position.latitude, position.longitude);
    getAddressFromLocation(position.latitude, position.longitude);
    markers.addAll([
      Marker(
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          markerId: MarkerId('value'),
          position: center,
          onDragEnd: (value) {
            print(value.latitude);
            print(value.longitude);
            getAddressFromLocation(value.latitude, value.longitude);
          })
    ]);
    setState(() {
      _mapController.moveCamera(CameraUpdate.newLatLng(center));
    });
  }

  getAddressFromLocation(double latitude, double longitude) async {
    try {
      selectedLocation = LatLng(latitude, longitude);
      Coordinates coordinates = new Coordinates(latitude, longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(
          coordinates);
      var first = addresses.first;
      //print("--addresses-${addresses} and ${first}");
      print("----------${first.featureName} and ${first
          .addressLine}-postalCode-${first.postalCode}------");

      setState(() {
        address = first.addressLine;
        cityController.text = first.locality;
        stateController.text = first.adminArea;
      });
    } catch (e) {
      print(e);
      address = "No address found!";
    }
  }

  void _onCameraMove(CameraPosition position) {
    CameraPosition newPos = CameraPosition(
        target: position.target
    );
    Marker marker = markers.first;

    setState(() {
      markers.first.copyWith(
          positionParam: newPos.target
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }


  Future<void> checkIfOrderDeliveryWithInRadious(int distanceInKms) async {
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


}