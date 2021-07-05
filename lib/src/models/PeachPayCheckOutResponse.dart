import 'dart:convert';

class PeachPayCheckOutResponse {
  PeachPayCheckOutResponse({
    this.success,
    this.data,
  });

  bool success;
  Data data;

  PeachPayCheckOutResponse copyWith({
    bool success,
    Data data,
  }) =>
      PeachPayCheckOutResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory PeachPayCheckOutResponse.fromRawJson(String str) =>
      PeachPayCheckOutResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PeachPayCheckOutResponse.fromJson(Map<String, dynamic> json) =>
      PeachPayCheckOutResponse(
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
    this.result,
    this.buildNumber,
    this.timestamp,
    this.ndc,
    this.id,
  });

  Result result;
  String buildNumber;
  String timestamp;
  String ndc;
  String id;

  Data copyWith({
    Result result,
    String buildNumber,
    String timestamp,
    String ndc,
    String id,
  }) =>
      Data(
        result: result ?? this.result,
        buildNumber: buildNumber ?? this.buildNumber,
        timestamp: timestamp ?? this.timestamp,
        ndc: ndc ?? this.ndc,
        id: id ?? this.id,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
        buildNumber: json["buildNumber"] == null ? null : json["buildNumber"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        ndc: json["ndc"] == null ? null : json["ndc"],
        id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toJson() => {
        "result": result == null ? null : result.toJson(),
        "buildNumber": buildNumber == null ? null : buildNumber,
        "timestamp": timestamp == null ? null : timestamp,
        "ndc": ndc == null ? null : ndc,
        "id": id == null ? null : id,
      };
}

class Result {
  Result({
    this.code,
    this.description,
  });

  String code;
  String description;

  Result copyWith({
    String code,
    String description,
  }) =>
      Result(
        code: code ?? this.code,
        description: description ?? this.description,
      );

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        code: json["code"] == null ? null : json["code"],
        description: json["description"] == null ? null : json["description"],
      );

  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "description": description == null ? null : description,
      };
}
