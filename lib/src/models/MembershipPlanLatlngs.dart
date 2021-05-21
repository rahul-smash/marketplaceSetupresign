// To parse this JSON data, do
//
//     final membershipPlanLatlngs = membershipPlanLatlngsFromJson(jsonString);

import 'dart:convert';

class MembershipPlanLatlngs {
  MembershipPlanLatlngs({
    this.success,
    this.data,
  });

  bool success;
  List<Datum> data;

  MembershipPlanLatlngs copyWith({
    bool success,
    List<Datum> data,
  }) =>
      MembershipPlanLatlngs(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory MembershipPlanLatlngs.fromRawJson(String str) => MembershipPlanLatlngs.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MembershipPlanLatlngs.fromJson(Map<String, dynamic> json) => MembershipPlanLatlngs(
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

  Datum copyWith({
    String posBranchCode,
    String posBranchName,
    String posChannelName,
    String lat,
    String lng,
    String brandId,
  }) =>
      Datum(
        posBranchCode: posBranchCode ?? this.posBranchCode,
        posBranchName: posBranchName ?? this.posBranchName,
        posChannelName: posChannelName ?? this.posChannelName,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        brandId: brandId ?? this.brandId,
      );

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
