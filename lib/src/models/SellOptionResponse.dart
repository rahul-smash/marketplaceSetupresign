import 'dart:convert';

class SellOptionResponse {
  SellOptionResponse({
    this.success,
    this.message,
  });

  bool success;
  String message;

  SellOptionResponse copyWith({
    bool success,
    String message,
  }) =>
      SellOptionResponse(
        success: success ?? this.success,
        message: message ?? this.message,
      );

  factory SellOptionResponse.fromRawJson(String str) =>
      SellOptionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SellOptionResponse.fromJson(Map<String, dynamic> json) =>
      SellOptionResponse(
        success: json["success"] == null ? null : json["success"],
        message: json["message"] == null ? null : json["message"],
      );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "message": message == null ? null : message,
  };
}
