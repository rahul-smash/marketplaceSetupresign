// To parse this JSON data, do
//
//     final createOrderData = createOrderDataFromJson(jsonString);

import 'dart:convert';

CreateOrderData createOrderDataFromJson(String str) => CreateOrderData.fromJson(json.decode(str));

String createOrderDataToJson(CreateOrderData data) => json.encode(data.toJson());

class CreateOrderData {
  bool success;
  Data data;
  String message;

  CreateOrderData({
    this.success,
    this.data,
    this.message,
  });

  factory CreateOrderData.fromJson(Map<String, dynamic> json) => CreateOrderData(
    success: json["success"],
    data: json["data"] == null ? null :Data.fromJson(json["data"]),
    message: json["message"]==null?null:json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String id;
  String entity;
  int amount;
  int amountPaid;
  int amountDue;
  String currency;
  String receipt;
  String offerId;
  String status;
  int attempts;
  List<dynamic> notes;
  int createdAt;
  String message;

  Data({
    this.id,
    this.entity,
    this.amount,
    this.amountPaid,
    this.amountDue,
    this.currency,
    this.receipt,
    this.offerId,
    this.status,
    this.attempts,
    this.notes,
    this.createdAt,
    this.message,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] == null ? null :json["id"],
    entity: json["entity"] == null ? null :json["entity"],
    amount: json["amount"] == null ? null :json["amount"],
    amountPaid: json["amount_paid"] == null ? null :json["amount_paid"],
    amountDue: json["amount_due"] == null ? null :json["amount_due"],
    currency: json["currency"] == null ? null :json["currency"],
    receipt: json["receipt"] == null ? null :json["receipt"],
    offerId: json["offer_id"] == null ? null :json["offer_id"],
    status: json["status"] == null ? null :json["status"] ,
    attempts: json["attempts"] == null ? null :json["attempts"],
    notes: json["notes"] == null ? null :List<dynamic>.from(json["notes"].map((x) => x)),
    createdAt: json["created_at"] == null ? null :json["created_at"],
    message: json["message"]==null?null:json["message"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "entity": entity,
    "amount": amount,
    "amount_paid": amountPaid,
    "amount_due": amountDue,
    "currency": currency,
    "receipt": receipt,
    "offer_id": offerId,
    "status": status,
    "attempts": attempts,
    "notes": List<dynamic>.from(notes.map((x) => x)),
    "created_at": createdAt,
  };
}
