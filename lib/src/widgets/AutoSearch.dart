import 'dart:async';

import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'dart:math';

const kGoogleApiKey = "AIzaSyCJFo82HR55bnLYFb2GUA8-d-E-o8uBpos";

// to get places detail (lat/lng)
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

// custom scaffold that handle search
// basically your widget need to extends [GooglePlacesAutocompleteWidget]
// and your state [GooglePlacesAutocompleteState]
class CustomSearchScaffold extends PlacesAutocompleteWidget {

  CustomSearchScaffold()
      : super(apiKey: kGoogleApiKey,/*
    sessionToken: Uuid().generateV4(),language: "en",
    components: [Component(Component.country, "uk")],*/
  );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {

  @override
  Widget build(BuildContext context) {

    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());

    final body = PlacesAutocompleteResult(
      onTap: (prediction) {
        print("onTap = ${prediction}");
        displayPrediction(prediction);
      },
      logo: Row(
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );

    return Scaffold(
        appBar: appBar,
        body: body
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      print("location = ${lat},${lng}");
      //var address = await Geocoder.local.findAddressesFromQuery(p.description);

      print(lat);
      print(lng);
    }
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    print("onResponseError=${response.errorMessage}");
    /*searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );*/
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {
      print("response=${response.predictions}");
      /*searchScaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Got answer")),
      );*/
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}