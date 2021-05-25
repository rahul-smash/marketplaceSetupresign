// To parse this JSON data, do
//
//     final userPurchaseMembershipResponse = userPurchaseMembershipResponseFromJson(jsonString);

import 'dart:convert';

class UserPurchaseMembershipResponse {
  UserPurchaseMembershipResponse({
    this.success,
    this.data,
  });

  bool success;
  Data data;

  UserPurchaseMembershipResponse copyWith({
    bool success,
    Data data,
  }) =>
      UserPurchaseMembershipResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory UserPurchaseMembershipResponse.fromRawJson(String str) =>
      UserPurchaseMembershipResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserPurchaseMembershipResponse.fromJson(Map<String, dynamic> json) =>
      UserPurchaseMembershipResponse(
        success: json["success"] == null ? null : json["success"],
        data: json["data"] == null
            ? null
            : json["data"] is List<dynamic>
                ? null
                : Data.fromJson(json["data"]),
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
    this.userId,
    this.membershipPlanDetailId,
    this.status,
    this.purchaseDateTime,
    this.puchaseType,
    this.amountPaid,
    this.startDate,
    this.endDate,
    this.cancelDate,
    this.additionalInfo,
    this.posBranchCode,
    this.defaultOrderInfo,
    this.defaultAddressId,
    this.created,
    this.modified,
    this.couponDetails,
    this.todayOrdered,
  });

  String id;
  String brandId;
  String userId;
  String membershipPlanDetailId;
  bool status;
  DateTime purchaseDateTime;
  String puchaseType;
  String amountPaid;
  DateTime startDate;
  DateTime endDate;
  String cancelDate;
  String additionalInfo;
  String posBranchCode;
  String defaultOrderInfo;
  String defaultAddressId;
  DateTime created;
  DateTime modified;
  CouponDetails couponDetails;
  bool todayOrdered;

  Data copyWith({
    String id,
    String brandId,
    String userId,
    String membershipPlanDetailId,
    bool status,
    DateTime purchaseDateTime,
    String puchaseType,
    String amountPaid,
    DateTime startDate,
    DateTime endDate,
    String cancelDate,
    String additionalInfo,
    String posBranchCode,
    String defaultOrderInfo,
    String defaultAddressId,
    DateTime created,
    DateTime modified,
    CouponDetails couponDetails,
    bool todayOrdered,
  }) =>
      Data(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        userId: userId ?? this.userId,
        membershipPlanDetailId:
            membershipPlanDetailId ?? this.membershipPlanDetailId,
        status: status ?? this.status,
        purchaseDateTime: purchaseDateTime ?? this.purchaseDateTime,
        puchaseType: puchaseType ?? this.puchaseType,
        amountPaid: amountPaid ?? this.amountPaid,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        cancelDate: cancelDate ?? this.cancelDate,
        additionalInfo: additionalInfo ?? this.additionalInfo,
        posBranchCode: posBranchCode ?? this.posBranchCode,
        defaultOrderInfo: defaultOrderInfo ?? this.defaultOrderInfo,
        defaultAddressId: defaultAddressId ?? this.defaultAddressId,
        created: created ?? this.created,
        modified: modified ?? this.modified,
        couponDetails: couponDetails ?? this.couponDetails,
        todayOrdered: todayOrdered ?? this.todayOrdered,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] == null ? null : json["id"],
        brandId: json["brand_id"] == null ? null : json["brand_id"],
        userId: json["user_id"] == null ? null : json["user_id"],
        membershipPlanDetailId: json["membership_plan_detail_id"] == null
            ? null
            : json["membership_plan_detail_id"],
        status: json["status"] == null ? null : json["status"],
        purchaseDateTime: json["purchase_date_time"] == null
            ? null
            : DateTime.parse(json["purchase_date_time"]),
        puchaseType: json["puchase_type"] == null ? null : json["puchase_type"],
        amountPaid: json["amount_paid"] == null ? null : json["amount_paid"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null :
            DateTime.parse(json["end_date"]),
        cancelDate: json["cancel_date"] == null ? null : json["cancel_date"],
        additionalInfo:
            json["additional_info"] == null ? null : json["additional_info"],
        posBranchCode:
            json["pos_branch_code"] == null ? null : json["pos_branch_code"],
        defaultOrderInfo: json["default_order_info"] == null
            ? null
            : json["default_order_info"],
        defaultAddressId: json["default_address_id"] == null
            ? null
            : json["default_address_id"],
        created:
            json["created"] == null ? null : DateTime.parse(json["created"]),
        modified:
            json["modified"] == null ? null : DateTime.parse(json["modified"]),
        couponDetails: json["coupon_details"] == null
            ? null
            : CouponDetails.fromJson(json["coupon_details"]),
        todayOrdered:
            json["today_ordered"] == null ? null : json["today_ordered"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "brand_id": brandId == null ? null : brandId,
        "user_id": userId == null ? null : userId,
        "membership_plan_detail_id":
            membershipPlanDetailId == null ? null : membershipPlanDetailId,
        "status": status == null ? null : status,
        "purchase_date_time": purchaseDateTime == null
            ? null
            : purchaseDateTime.toIso8601String(),
        "puchase_type": puchaseType == null ? null : puchaseType,
        "amount_paid": amountPaid == null ? null : amountPaid,
        "start_date": startDate == null
            ? null
            : "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": endDate == null
            ? null
            : "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "cancel_date": cancelDate == null ? null : cancelDate,
        "additional_info": additionalInfo == null ? null : additionalInfo,
        "pos_branch_code": posBranchCode == null ? null : posBranchCode,
        "default_order_info":
            defaultOrderInfo == null ? null : defaultOrderInfo,
        "default_address_id":
            defaultAddressId == null ? null : defaultAddressId,
        "created": created == null ? null : created.toIso8601String(),
        "modified": modified == null ? null : modified.toIso8601String(),
        "coupon_details": couponDetails == null ? null : couponDetails.toJson(),
        "today_ordered": todayOrdered == null ? null : todayOrdered,
      };
}

class CouponDetails {
  CouponDetails({
    this.id,
    this.brandId,
    this.membershipPlanDetailId,
    this.discountType,
    this.orderFacilities,
    this.paymentMethod,
    this.name,
    this.couponCode,
    this.discount,
    this.discountUpto,
    this.minimumOrderAmount,
    this.usageLimit,
    this.validFrom,
    this.validTo,
    this.offerNotification,
    this.offerTermCondition,
    this.offerDescription,
    this.banner,
    this.status,
    this.show,
    this.sort,
    this.created,
    this.modified,
  });

  String id;
  String brandId;
  String membershipPlanDetailId;
  String discountType;
  String orderFacilities;
  String paymentMethod;
  String name;
  String couponCode;
  String discount;
  String discountUpto;
  String minimumOrderAmount;
  String usageLimit;
  DateTime validFrom;
  DateTime validTo;
  String offerNotification;
  String offerTermCondition;
  String offerDescription;
  String banner;
  String status;
  String show;
  String sort;
  DateTime created;
  DateTime modified;

  CouponDetails copyWith({
    String id,
    String brandId,
    String membershipPlanDetailId,
    String discountType,
    String orderFacilities,
    String paymentMethod,
    String name,
    String couponCode,
    String discount,
    String discountUpto,
    String minimumOrderAmount,
    String usageLimit,
    DateTime validFrom,
    DateTime validTo,
    String offerNotification,
    String offerTermCondition,
    String offerDescription,
    String banner,
    String status,
    String show,
    String sort,
    DateTime created,
    DateTime modified,
  }) =>
      CouponDetails(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        membershipPlanDetailId:
            membershipPlanDetailId ?? this.membershipPlanDetailId,
        discountType: discountType ?? this.discountType,
        orderFacilities: orderFacilities ?? this.orderFacilities,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        name: name ?? this.name,
        couponCode: couponCode ?? this.couponCode,
        discount: discount ?? this.discount,
        discountUpto: discountUpto ?? this.discountUpto,
        minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
        usageLimit: usageLimit ?? this.usageLimit,
        validFrom: validFrom ?? this.validFrom,
        validTo: validTo ?? this.validTo,
        offerNotification: offerNotification ?? this.offerNotification,
        offerTermCondition: offerTermCondition ?? this.offerTermCondition,
        offerDescription: offerDescription ?? this.offerDescription,
        banner: banner ?? this.banner,
        status: status ?? this.status,
        show: show ?? this.show,
        sort: sort ?? this.sort,
        created: created ?? this.created,
        modified: modified ?? this.modified,
      );

  factory CouponDetails.fromRawJson(String str) =>
      CouponDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CouponDetails.fromJson(Map<String, dynamic> json) => CouponDetails(
        id: json["id"] == null ? null : json["id"],
        brandId: json["brand_id"] == null ? null : json["brand_id"],
        membershipPlanDetailId: json["membership_plan_detail_id"] == null
            ? null
            : json["membership_plan_detail_id"],
        discountType:
            json["discount_type"] == null ? null : json["discount_type"],
        orderFacilities:
            json["order_facilities"] == null ? null : json["order_facilities"],
        paymentMethod:
            json["payment_method"] == null ? null : json["payment_method"],
        name: json["name"] == null ? null : json["name"],
        couponCode: json["coupon_code"] == null ? null : json["coupon_code"],
        discount: json["discount"] == null ? null : json["discount"],
        discountUpto:
            json["discount_upto"] == null ? null : json["discount_upto"],
        minimumOrderAmount: json["minimum_order_amount"] == null
            ? null
            : json["minimum_order_amount"],
        usageLimit: json["usage_limit"] == null ? null : json["usage_limit"],
        validFrom: json["valid_from"] == null
            ? null
            : DateTime.parse(json["valid_from"]),
        validTo:
            json["valid_to"] == null ? null : DateTime.parse(json["valid_to"]),
        offerNotification: json["offer_notification"] == null
            ? null
            : json["offer_notification"],
        offerTermCondition: json["offer_term_condition"] == null
            ? null
            : json["offer_term_condition"],
        offerDescription: json["offer_description"] == null
            ? null
            : json["offer_description"],
        banner: json["banner"] == null ? null : json["banner"],
        status: json["status"] == null ? null : json["status"],
        show: json["show"] == null ? null : json["show"],
        sort: json["sort"] == null ? null : json["sort"],
        created:
            json["created"] == null ? null : DateTime.parse(json["created"]),
        modified:
            json["modified"] == null ? null : DateTime.parse(json["modified"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "brand_id": brandId == null ? null : brandId,
        "membership_plan_detail_id":
            membershipPlanDetailId == null ? null : membershipPlanDetailId,
        "discount_type": discountType == null ? null : discountType,
        "order_facilities": orderFacilities == null ? null : orderFacilities,
        "payment_method": paymentMethod == null ? null : paymentMethod,
        "name": name == null ? null : name,
        "coupon_code": couponCode == null ? null : couponCode,
        "discount": discount == null ? null : discount,
        "discount_upto": discountUpto == null ? null : discountUpto,
        "minimum_order_amount":
            minimumOrderAmount == null ? null : minimumOrderAmount,
        "usage_limit": usageLimit == null ? null : usageLimit,
        "valid_from": validFrom == null
            ? null
            : "${validFrom.year.toString().padLeft(4, '0')}-${validFrom.month.toString().padLeft(2, '0')}-${validFrom.day.toString().padLeft(2, '0')}",
        "valid_to": validTo == null
            ? null
            : "${validTo.year.toString().padLeft(4, '0')}-${validTo.month.toString().padLeft(2, '0')}-${validTo.day.toString().padLeft(2, '0')}",
        "offer_notification":
            offerNotification == null ? null : offerNotification,
        "offer_term_condition":
            offerTermCondition == null ? null : offerTermCondition,
        "offer_description": offerDescription == null ? null : offerDescription,
        "banner": banner == null ? null : banner,
        "status": status == null ? null : status,
        "show": show == null ? null : show,
        "sort": sort == null ? null : sort,
        "created": created == null ? null : created.toIso8601String(),
        "modified": modified == null ? null : modified.toIso8601String(),
      };
}
