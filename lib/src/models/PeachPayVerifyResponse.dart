// To parse this JSON data, do
//
//     final peachPayVerifyResponse = peachPayVerifyResponseFromJson(jsonString);

import 'dart:convert';

class PeachPayVerifyResponse {
  PeachPayVerifyResponse({
    this.success,
    this.data,
  });

  bool success;
  Data data;

  PeachPayVerifyResponse copyWith({
    bool success,
    Data data,
  }) =>
      PeachPayVerifyResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory PeachPayVerifyResponse.fromRawJson(String str) => PeachPayVerifyResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PeachPayVerifyResponse.fromJson(Map<String, dynamic> json) => PeachPayVerifyResponse(
    success: json["success"] == null ? null : json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "data": data == null ? null : data.toJson(),
  };
}

class Data {
  Data({
    this.id,
    this.amount,
    this.checkoutId,
  });

  String id;
  String amount;
  String checkoutId;

  Data copyWith({
    String id,
    String amount,
    String checkoutId,
  }) =>
      Data(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        checkoutId: checkoutId ?? this.checkoutId,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] == null ? null : json["id"],
    amount: json["amount"] == null ? null : json["amount"],
    checkoutId: json["checkout_id"] == null ? null : json["checkout_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "amount": amount == null ? null : amount,
    "checkout_id": checkoutId == null ? null : checkoutId,
  };
}
