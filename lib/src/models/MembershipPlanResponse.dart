// To parse this JSON data, do
//
//     final membershipPlanResponse = membershipPlanResponseFromJson(jsonString);

import 'dart:convert';

class MembershipPlanResponse {
  MembershipPlanResponse({
    this.success,
    this.data,
  });

  bool success;
  Data data;

  MembershipPlanResponse copyWith({
    bool success,
    Data data,
  }) =>
      MembershipPlanResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory MembershipPlanResponse.fromRawJson(String str) => MembershipPlanResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MembershipPlanResponse.fromJson(Map<String, dynamic> json) => MembershipPlanResponse(
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
    this.brandId,
    this.planCode,
    this.planName,
    this.planDescription,
    this.planTc,
    this.planTotalCharges,
    this.planBasicCharges,
    this.planDeliveryCharges,
    this.tax,
    this.planPeriod,
    this.discountType,
    this.discountValue,
    this.discountOrdersperday,
    this.minimumOrderValue,
    this.orderType,
    this.eligibleMerchants,
    this.created,
    this.modified,
  });

  String id;
  String brandId;
  String planCode;
  String planName;
  String planDescription;
  String planTc;
  String planTotalCharges;
  String planBasicCharges;
  String planDeliveryCharges;
  String tax;
  String planPeriod;
  String discountType;
  String discountValue;
  String discountOrdersperday;
  String minimumOrderValue;
  String orderType;
  String eligibleMerchants;
  DateTime created;
  DateTime modified;

  Data copyWith({
    String id,
    String brandId,
    String planCode,
    String planName,
    String planDescription,
    String planTc,
    String planTotalCharges,
    String planBasicCharges,
    String planDeliveryCharges,
    String tax,
    String planPeriod,
    String discountType,
    String discountValue,
    String discountOrdersperday,
    String minimumOrderValue,
    String orderType,
    String eligibleMerchants,
    DateTime created,
    DateTime modified,
  }) =>
      Data(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        planCode: planCode ?? this.planCode,
        planName: planName ?? this.planName,
        planDescription: planDescription ?? this.planDescription,
        planTc: planTc ?? this.planTc,
        planTotalCharges: planTotalCharges ?? this.planTotalCharges,
        planBasicCharges: planBasicCharges ?? this.planBasicCharges,
        planDeliveryCharges: planDeliveryCharges ?? this.planDeliveryCharges,
        tax: tax ?? this.tax,
        planPeriod: planPeriod ?? this.planPeriod,
        discountType: discountType ?? this.discountType,
        discountValue: discountValue ?? this.discountValue,
        discountOrdersperday: discountOrdersperday ?? this.discountOrdersperday,
        minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
        orderType: orderType ?? this.orderType,
        eligibleMerchants: eligibleMerchants ?? this.eligibleMerchants,
        created: created ?? this.created,
        modified: modified ?? this.modified,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] == null ? null : json["id"],
    brandId: json["brand_id"] == null ? null : json["brand_id"],
    planCode: json["plan_code"] == null ? null : json["plan_code"],
    planName: json["plan_name"] == null ? null : json["plan_name"],
    planDescription: json["plan_description"] == null ? null : json["plan_description"],
    planTc: json["plan_tc"] == null ? null : json["plan_tc"],
    planTotalCharges: json["plan_total_charges"] == null ? null : json["plan_total_charges"],
    planBasicCharges: json["plan_basic_charges"] == null ? null : json["plan_basic_charges"],
    planDeliveryCharges: json["Plan_delivery_charges"] == null ? null : json["Plan_delivery_charges"],
    tax: json["tax"] == null ? null : json["tax"],
    planPeriod: json["plan_period"] == null ? null : json["plan_period"],
    discountType: json["discount_type"] == null ? null : json["discount_type"],
    discountValue: json["discount_value"] == null ? null : json["discount_value"],
    discountOrdersperday: json["discount_ordersperday"] == null ? null : json["discount_ordersperday"],
    minimumOrderValue: json["minimum_order_value"] == null ? null : json["minimum_order_value"],
    orderType: json["order_type"] == null ? null : json["order_type"],
    eligibleMerchants: json["eligible_merchants"] == null ? null : json["eligible_merchants"],
    created: json["created"] == null ? null : DateTime.parse(json["created"]),
    modified: json["modified"] == null ? null : DateTime.parse(json["modified"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "brand_id": brandId == null ? null : brandId,
    "plan_code": planCode == null ? null : planCode,
    "plan_name": planName == null ? null : planName,
    "plan_description": planDescription == null ? null : planDescription,
    "plan_tc": planTc == null ? null : planTc,
    "plan_total_charges": planTotalCharges == null ? null : planTotalCharges,
    "plan_basic_charges": planBasicCharges == null ? null : planBasicCharges,
    "Plan_delivery_charges": planDeliveryCharges == null ? null : planDeliveryCharges,
    "tax": tax == null ? null : tax,
    "plan_period": planPeriod == null ? null : planPeriod,
    "discount_type": discountType == null ? null : discountType,
    "discount_value": discountValue == null ? null : discountValue,
    "discount_ordersperday": discountOrdersperday == null ? null : discountOrdersperday,
    "minimum_order_value": minimumOrderValue == null ? null : minimumOrderValue,
    "order_type": orderType == null ? null : orderType,
    "eligible_merchants": eligibleMerchants == null ? null : eligibleMerchants,
    "created": created == null ? null : created.toIso8601String(),
    "modified": modified == null ? null : modified.toIso8601String(),
  };
}
