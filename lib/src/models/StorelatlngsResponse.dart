// To parse this JSON data, do
//
//     final membershipPlanLatlngs = membershipPlanLatlngsFromJson(jsonString);

import 'dart:convert';

class StoreLatlngsResponse {
  StoreLatlngsResponse({
    this.success,
    this.data,
  });

  bool success;
  List<StoreLatLngModel> data;

  StoreLatlngsResponse copyWith({
    bool success,
    List<StoreLatLngModel> data,
  }) =>
      StoreLatlngsResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory StoreLatlngsResponse.fromRawJson(String str) => StoreLatlngsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreLatlngsResponse.fromJson(Map<String, dynamic> json) => StoreLatlngsResponse(
    success: json["success"] == null ? null : json["success"],
    data: json["data"] == null ? null : List<StoreLatLngModel>.from(json["data"].map((x) => StoreLatLngModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class StoreLatLngModel {
  StoreLatLngModel({
    this.posBranchCode,
    this.posBranchName,
    this.posChannelName,
    this.lat,
    this.lng,
    this.brandId,
  });

  String posBranchCode;
  String posBranchName;
  String posChannelName;
  String lat;
  String lng;
  String brandId;

  StoreLatLngModel copyWith({
    String posBranchCode,
    String posBranchName,
    String posChannelName,
    String lat,
    String lng,
    String brandId,
  }) =>
      StoreLatLngModel(
        posBranchCode: posBranchCode ?? this.posBranchCode,
        posBranchName: posBranchName ?? this.posBranchName,
        posChannelName: posChannelName ?? this.posChannelName,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        brandId: brandId ?? this.brandId,
      );

  factory StoreLatLngModel.fromRawJson(String str) => StoreLatLngModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreLatLngModel.fromJson(Map<String, dynamic> json) => StoreLatLngModel(
    posBranchCode: json["pos_branch_code"] == null ? null : json["pos_branch_code"],
    posBranchName: json["pos_branch_name"] == null ? null : json["pos_branch_name"],
    posChannelName: json["pos_channel_name"] == null ? null : json["pos_channel_name"],
    lat: json["lat"] == null ? null : json["lat"],
    lng: json["lng"] == null ? null : json["lng"],
    brandId: json["brand_id"] == null ? null : json["brand_id"],
  );

  Map<String, dynamic> toJson() => {
    "pos_branch_code": posBranchCode == null ? null : posBranchCode,
    "pos_branch_name": posBranchName == null ? null : posBranchName,
    "pos_channel_name": posChannelName == null ? null : posChannelName,
    "lat": lat == null ? null : lat,
    "lng": lng == null ? null : lng,
    "brand_id": brandId == null ? null : brandId,
  };
}
