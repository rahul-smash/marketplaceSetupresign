// To parse this JSON data, do
//
//     final pickUpModel = pickUpModelFromJson(jsonString);

import 'dart:convert';

class PickUpModel {
  PickUpModel({
    this.success,
    this.data,
  });

  bool success;
  List<Datum> data;

  PickUpModel copyWith({
    bool success,
    List<Datum> data,
  }) =>
      PickUpModel(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory PickUpModel.fromRawJson(String str) => PickUpModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PickUpModel.fromJson(Map<String, dynamic> json) => PickUpModel(
    success: json["success"] == null ? null : json["success"],
    data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.areaId,
    this.areaName,
    this.pickupAdd,
    this.pickupPhone,
    this.pickupEmail,
    this.pickupLat,
    this.pickupLng,
    this.cityId,
    this.minOrder,
    this.charges,
    this.note,
    this.notAllow,
  });

  int areaId;
  String areaName;
  String pickupAdd;
  String pickupPhone;
  String pickupEmail;
  String pickupLat;
  String pickupLng;
  int cityId;
  int minOrder;
  int charges;
  String note;
  int notAllow;

  Datum copyWith({
    int areaId,
    String areaName,
    String pickupAdd,
    String pickupPhone,
    String pickupEmail,
    String pickupLat,
    String pickupLng,
    int cityId,
    int minOrder,
    int charges,
    String note,
    int notAllow,
  }) =>
      Datum(
        areaId: areaId ?? this.areaId,
        areaName: areaName ?? this.areaName,
        pickupAdd: pickupAdd ?? this.pickupAdd,
        pickupPhone: pickupPhone ?? this.pickupPhone,
        pickupEmail: pickupEmail ?? this.pickupEmail,
        pickupLat: pickupLat ?? this.pickupLat,
        pickupLng: pickupLng ?? this.pickupLng,
        cityId: cityId ?? this.cityId,
        minOrder: minOrder ?? this.minOrder,
        charges: charges ?? this.charges,
        note: note ?? this.note,
        notAllow: notAllow ?? this.notAllow,
      );

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    areaId: json["area_id"] == null ? null : json["area_id"],
    areaName: json["area_name"] == null ? null : json["area_name"],
    pickupAdd: json["pickup_add"] == null ? null : json["pickup_add"],
    pickupPhone: json["pickup_phone"] == null ? null : json["pickup_phone"],
    pickupEmail: json["pickup_email"] == null ? null : json["pickup_email"],
    pickupLat: json["pickup_lat"] == null ? null : json["pickup_lat"],
    pickupLng: json["pickup_lng"] == null ? null : json["pickup_lng"],
    cityId: json["city_id"] == null ? null : json["city_id"],
    minOrder: json["min_order"] == null ? null : json["min_order"],
    charges: json["charges"] == null ? null : json["charges"],
    note: json["note"] == null ? null : json["note"],
    notAllow: json["not_allow"] == null ? null : json["not_allow"],
  );

  Map<String, dynamic> toJson() => {
    "area_id": areaId == null ? null : areaId,
    "area_name": areaName == null ? null : areaName,
    "pickup_add": pickupAdd == null ? null : pickupAdd,
    "pickup_phone": pickupPhone == null ? null : pickupPhone,
    "pickup_email": pickupEmail == null ? null : pickupEmail,
    "pickup_lat": pickupLat == null ? null : pickupLat,
    "pickup_lng": pickupLng == null ? null : pickupLng,
    "city_id": cityId == null ? null : cityId,
    "min_order": minOrder == null ? null : minOrder,
    "charges": charges == null ? null : charges,
    "note": note == null ? null : note,
    "not_allow": notAllow == null ? null : notAllow,
  };
}
