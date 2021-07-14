// To parse this JSON data, do
//
//     final storeRadiousResponse = storeRadiousResponseFromJson(jsonString);

import 'dart:convert';

StoreRadiousResponse storeRadiousResponseFromJson(String str) => StoreRadiousResponse.fromJson(json.decode(str));

String storeRadiousResponseToJson(StoreRadiousResponse data) => json.encode(data.toJson());

class StoreRadiousResponse {
  StoreRadiousResponse({
    this.success,
    this.data,
  });

  bool success;
  List<Area> data;

  factory StoreRadiousResponse.fromJson(Map<String, dynamic> json) => StoreRadiousResponse(
    success: json["success"],
    data: List<Area>.from(json["data"].map((x) => Area.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Area {
  Area({
    this.areaId,
    this.area,
    this.minOrder,
    this.charges,
    this.note,
    this.notAllow,
    this.radius,
    this.radiusCircle,
    this.isShippingMandatory,
  });

  String areaId;
  String area;
  String minOrder;
  String charges;
  String note;
  bool notAllow;
  String radius;
  String radiusCircle;
  String isShippingMandatory;

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    areaId: json["area_id"],
    area: json["area"],
    minOrder: json["min_order"],
    charges: json["charges"],
    note: json["note"],
    notAllow: json["not_allow"],
    radius: json["radius"],
    radiusCircle: json["radius_circle"],
    isShippingMandatory: json["is_shipping_mandatory"],
  );

  Map<String, dynamic> toJson() => {
    "area_id": areaId,
    "area": area,
    "min_order": minOrder,
    "charges": charges,
    "note": note,
    "not_allow": notAllow,
    "radius": radius,
    "radius_circle": radiusCircle,
    "is_shipping_mandatory": isShippingMandatory,
  };
}
