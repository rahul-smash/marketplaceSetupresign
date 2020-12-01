// To parse this JSON data, do
//
//     final storesModel = storesModelFromJson(jsonString);

import 'dart:convert';

StoresModel storesModelFromJson(String str) => StoresModel.fromJson(json.decode(str));

String storesModelToJson(StoresModel data) => json.encode(data.toJson());

class StoresModel {
  StoresModel({
    this.success,
    this.data,
  });

  bool success;
  List<StoreData> data;

  factory StoresModel.fromJson(Map<String, dynamic> json) => StoresModel(
    success: json["success"],
    data: List<StoreData>.from(json["data"].map((x) => StoreData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class StoreData {
  StoreData({
    this.id,
    this.storeName,
    this.location,
    this.city,
    this.state,
    this.lat,
    this.lng,
    this.contactNumber,
    this.contactPerson,
    this.contactEmail,
    this.image,
    this.image10080,
    this.image300200,
    this.preparationTime,
    this.distance,
  });

  String id;
  String storeName;
  String location;
  String city;
  String state;
  String lat;
  String lng;
  String contactNumber;
  String contactPerson;
  String contactEmail;
  String image;
  String image10080;
  String image300200;
  String preparationTime;
  String distance;

  factory StoreData.fromJson(Map<String, dynamic> json) => StoreData(
    id: json["id"],
    storeName: json["store_name"],
    location: json["location"],
    city: json["city"],
    state: json["state"],
    lat: json["lat"],
    lng: json["lng"],
    contactNumber: json["contact_number"],
    contactPerson: json["contact_person"],
    contactEmail: json["contact_email"],
    image: json["image"],
    image10080: json["image_100_80"],
    image300200: json["image_300_200"],
    preparationTime: json["preparation_time"],
    distance: json["distance"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "store_name": storeName,
    "location": location,
    "city": city,
    "state": state,
    "lat": lat,
    "lng": lng,
    "contact_number": contactNumber,
    "contact_person": contactPerson,
    "contact_email": contactEmail,
    "image": image,
    "image_100_80": image10080,
    "image_300_200": image300200,
    "preparation_time": preparationTime,
    "distance": distance,
  };
}
