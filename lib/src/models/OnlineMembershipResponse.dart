// To parse this JSON data, do
//
//     final createOnlineMembership = createOnlineMembershipFromJson(jsonString);

import 'dart:convert';

class OnlineMembershipResponse {
  OnlineMembershipResponse({
    this.success,
    this.message,
  });

  bool success;
  String message;

  OnlineMembershipResponse copyWith({
    bool success,
    String message,
  }) =>
      OnlineMembershipResponse(
        success: success ?? this.success,
        message: message ?? this.message,
      );

  factory OnlineMembershipResponse.fromRawJson(String str) => OnlineMembershipResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OnlineMembershipResponse.fromJson(Map<String, dynamic> json) => OnlineMembershipResponse(
    success: json["success"] == null ? null : json["success"],
    message: json["message"] == null ? null : json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "message": message == null ? null : message,
  };
}
