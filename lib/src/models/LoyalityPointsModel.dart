// To parse this JSON data, do
//
//     final loyalityPointsModel = loyalityPointsModelFromJson(jsonString);

import 'dart:convert';

LoyalityPointsModel loyalityPointsModelFromJson(String str) => LoyalityPointsModel.fromJson(json.decode(str));

String loyalityPointsModelToJson(LoyalityPointsModel data) => json.encode(data.toJson());

class LoyalityPointsModel {
  LoyalityPointsModel({
    this.success,
    this.loyalityPoints,
    this.redeemLimit,
    this.data,
  });

  bool success;
  String loyalityPoints;
  String redeemLimit;
  List<LoyalityData> data;

  factory LoyalityPointsModel.fromJson(Map<String, dynamic> json) => LoyalityPointsModel(
    success: json["success"],
    loyalityPoints: json["loyality_points"] == null ? null : json["loyality_points"],
    redeemLimit: json["redeem_limit"] == null ? null : json["redeem_limit"],
    data: json["data"] == null ? null : List<LoyalityData>.from(json["data"].map((x) => LoyalityData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "loyality_points": loyalityPoints,
    "redeem_limit": redeemLimit,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class LoyalityData {
  LoyalityData({
    this.id,
    this.storeId,
    this.amount,
    this.points,
    this.couponCode,
  });

  String id;
  String storeId;
  String amount;
  String points;
  String couponCode;

  factory LoyalityData.fromJson(Map<String, dynamic> json) => LoyalityData(
    id: json["id"],
    storeId: json["store_id"],
    amount: json["amount"],
    points: json["points"],
    couponCode: json["coupon_code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "store_id": storeId,
    "amount": amount,
    "points": points,
    "coupon_code": couponCode,
  };
}
