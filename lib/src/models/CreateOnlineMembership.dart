// To parse this JSON data, do
//
//     final createOnlineMembership = createOnlineMembershipFromJson(jsonString);

import 'dart:convert';

class CreateOnlineMembership {
  CreateOnlineMembership({
    this.success,
    this.message,
  });

  bool success;
  String message;

  CreateOnlineMembership copyWith({
    bool success,
    String message,
  }) =>
      CreateOnlineMembership(
        success: success ?? this.success,
        message: message ?? this.message,
      );

  factory CreateOnlineMembership.fromRawJson(String str) => CreateOnlineMembership.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreateOnlineMembership.fromJson(Map<String, dynamic> json) => CreateOnlineMembership(
    success: json["success"] == null ? null : json["success"],
    message: json["message"] == null ? null : json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "message": message == null ? null : message,
  };
}
