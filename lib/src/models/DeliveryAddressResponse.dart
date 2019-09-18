// To parse this JSON data, do
//
//     final deliveryAddressResponse = deliveryAddressResponseFromJson(jsonString);

import 'dart:convert';

DeliveryAddressResponse deliveryAddressResponseFromJson(String str) => DeliveryAddressResponse.fromJson(json.decode(str));

String deliveryAddressResponseToJson(DeliveryAddressResponse data) => json.encode(data.toJson());

class DeliveryAddressResponse {
  bool success;
  List<DeliveryAddressData> data;

  DeliveryAddressResponse({
    this.success,
    this.data,
  });

  factory DeliveryAddressResponse.fromJson(Map<String, dynamic> json) => DeliveryAddressResponse(
    success: json["success"],
    data: List<DeliveryAddressData>.from(json["data"].map((x) => DeliveryAddressData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DeliveryAddressData {
  String id;
  String userId;
  String storeId;
  String firstName;
  String lastName;
  String mobile;
  String email;
  String address;
  String areaId;
  String areaName;
  String city;
  String state;
  String zipcode;
  String country;
  bool notAllow;
  String areaCharges;
  String minAmount;
  String note;
  String cityId;
  DeliveryTimeSlot deliveryTimeSlot;

  DeliveryAddressData({
    this.id,
    this.userId,
    this.storeId,
    this.firstName,
    this.lastName,
    this.mobile,
    this.email,
    this.address,
    this.areaId,
    this.areaName,
    this.city,
    this.state,
    this.zipcode,
    this.country,
    this.notAllow,
    this.areaCharges,
    this.minAmount,
    this.note,
    this.cityId,
    this.deliveryTimeSlot,
  });

  factory DeliveryAddressData.fromJson(Map<String, dynamic> json) => DeliveryAddressData(
    id: json["id"],
    userId: json["user_id"],
    storeId: json["store_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    mobile: json["mobile"],
    email: json["email"],
    address: json["address"],
    areaId: json["area_id"],
    areaName: json["area_name"],
    city: json["city"],
    state: json["state"],
    zipcode: json["zipcode"],
    country: json["country"],
    notAllow: json["not_allow"],
    areaCharges: json["area_charges"],
    minAmount: json["min_amount"],
    note: json["note"],
    cityId: json["city_id"],
    deliveryTimeSlot: DeliveryTimeSlot.fromJson(json["delivery_time_slot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "store_id": storeId,
    "first_name": firstName,
    "last_name": lastName,
    "mobile": mobile,
    "email": email,
    "address": address,
    "area_id": areaId,
    "area_name": areaName,
    "city": city,
    "state": state,
    "zipcode": zipcode,
    "country": country,
    "not_allow": notAllow,
    "area_charges": areaCharges,
    "min_amount": minAmount,
    "note": note,
    "city_id": cityId,
    "delivery_time_slot": deliveryTimeSlot.toJson(),
  };
}

class DeliveryTimeSlot {
  String zoneId;
  String is24X7Open;

  DeliveryTimeSlot({
    this.zoneId,
    this.is24X7Open,
  });

  factory DeliveryTimeSlot.fromJson(Map<String, dynamic> json) => DeliveryTimeSlot(
    zoneId: json["zone_id"],
    is24X7Open: json["is24x7_open"],
  );

  Map<String, dynamic> toJson() => {
    "zone_id": zoneId,
    "is24x7_open": is24X7Open,
  };
}