// To parse this JSON data, do
//
//     final ipay88OrderData = ipay88OrderDataFromJson(jsonString);

import 'dart:convert';

class Ipay88OrderData {
  Ipay88OrderData({
    this.success,
    this.data,
  });

  bool success;
  Data data;

  Ipay88OrderData copyWith({
    bool success,
    Data data,
  }) =>
      Ipay88OrderData(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory Ipay88OrderData.fromRawJson(String str) =>
      Ipay88OrderData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Ipay88OrderData.fromJson(Map<String, dynamic> json) =>
      Ipay88OrderData(
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
    this.orderId,
    this.signature,
    this.url,
  });

  String orderId;
  String signature;
  String url;

  Data copyWith({
    String orderId,
    String signature,
    String url,
  }) =>
      Data(
        orderId: orderId ?? this.orderId,
        signature: signature ?? this.signature,
        url: url ?? this.url,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderId: json["order_id"] == null ? null : json["order_id"],
        signature: json["signature"] == null ? null : json["signature"],
        url: json["url"] == null ? null : json["url"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId == null ? null : orderId,
        "signature": signature == null ? null : signature,
        "url": url == null ? null : url,
      };
}
