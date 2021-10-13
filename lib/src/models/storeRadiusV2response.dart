import 'dart:convert';

class StoreRadiusV2 {
  StoreRadiusV2({
    this.success,
    this.data,
  });

  bool success;
  List<Datum> data;

  StoreRadiusV2 copyWith({
    bool success,
    List<Datum> data,
  }) =>
      StoreRadiusV2(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory StoreRadiusV2.fromRawJson(String str) =>
      StoreRadiusV2.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreRadiusV2.fromJson(Map<String, dynamic> json) => StoreRadiusV2(
        success: json["success"] == null ? null : json["success"],
        data: json["data"] == null
            ? null
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : success,
        "data": data == null
            ? null
            : List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.areaId,
    this.area,
    this.minOrder,
    this.charges,
    this.note,
    this.notAllow,
    this.isShippingMandatory,
    this.radius,
    this.radiusCircle,
  });

  String areaId;
  String area;
  String minOrder;
  String charges;
  String note;
  bool notAllow;
  String isShippingMandatory;
  String radius;
  String radiusCircle;

  Datum copyWith({
    String areaId,
    String area,
    String minOrder,
    String charges,
    String note,
    bool notAllow,
    String isShippingMandatory,
    String radius,
    String radiusCircle,
  }) =>
      Datum(
        areaId: areaId ?? this.areaId,
        area: area ?? this.area,
        minOrder: minOrder ?? this.minOrder,
        charges: charges ?? this.charges,
        note: note ?? this.note,
        notAllow: notAllow ?? this.notAllow,
        isShippingMandatory: isShippingMandatory ?? this.isShippingMandatory,
        radius: radius ?? this.radius,
        radiusCircle: radiusCircle ?? this.radiusCircle,
      );

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        areaId: json["area_id"] == null ? null : json["area_id"],
        area: json["area"] == null ? null : json["area"],
        minOrder: json["min_order"] == null ? null : json["min_order"],
        charges: json["charges"] == null ? null : json["charges"],
        note: json["note"] == null ? null : json["note"],
        notAllow: json["not_allow"] == null ? null : json["not_allow"],
        isShippingMandatory: json["is_shipping_mandatory"] == null
            ? null
            : json["is_shipping_mandatory"],
        radius: json["radius"] == null ? null : json["radius"],
        radiusCircle:
            json["radius_circle"] == null ? null : json["radius_circle"],
      );

  Map<String, dynamic> toJson() => {
        "area_id": areaId == null ? null : areaId,
        "area": area == null ? null : area,
        "min_order": minOrder == null ? null : minOrder,
        "charges": charges == null ? null : charges,
        "note": note == null ? null : note,
        "not_allow": notAllow == null ? null : notAllow,
        "is_shipping_mandatory":
            isShippingMandatory == null ? null : isShippingMandatory,
        "radius": radius == null ? null : radius,
        "radius_circle": radiusCircle == null ? null : radiusCircle,
      };
}
