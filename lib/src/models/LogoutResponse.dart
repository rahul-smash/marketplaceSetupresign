// To parse this JSON data, do
//
//     final logoutResponse = logoutResponseFromJson(jsonString);

import 'dart:convert';

class LogoutResponse {
  LogoutResponse({
    this.success,
    this.message,
  });

  bool success;
  String message;

  LogoutResponse copyWith({
    bool success,
    String message,
  }) =>
      LogoutResponse(
        success: success ?? this.success,
        message: message ?? this.message,
      );

  factory LogoutResponse.fromRawJson(String str) => LogoutResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LogoutResponse.fromJson(Map<String, dynamic> json) => LogoutResponse(
    success: json["success"] == null ? null : json["success"],
    message: json["message"] == null ? null : json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "message": message == null ? null : message,
  };
}
