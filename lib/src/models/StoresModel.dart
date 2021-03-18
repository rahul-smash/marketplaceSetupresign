// To parse this JSON data, do
//
//     final storesModel = storesModelFromJson(jsonString);

import 'dart:convert';

StoresModel storesModelFromJson(String str) => StoresModel.fromJson(json.decode(str));

String storesModelToJson(StoresModel data) => json.encode(data.toJson());

class StoresModel {
  StoresModel({
    this.success,
    this.data,
    this.dishes,
    this.message
  });

  bool success;
  List<StoreData> data;
  List<Dish> dishes;
  String message;

  factory StoresModel.fromJson(Map<String, dynamic> json) => StoresModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null :List<StoreData>.from(json["data"].map((x) => StoreData.fromJson(x))),
    dishes: json["dishes"] == null ? null : List<Dish>.from(json["dishes"].map((x) => Dish.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "dishes": dishes == null ? null : List<dynamic>.from(dishes.map((x) => x.toJson())),
  };
}

class StoreData {
  StoreData({
    this.id,
    this.storeName,
    this.location,
    this.city,
    this.state,
    this.lat,
    this.lng,
    this.contactNumber,
    this.contactPerson,
    this.contactEmail,
    this.image,
    this.image10080,
    this.image300200,
    this.preparationTime,
    this.distance,
    this.timimg,
    this.rating,
  });

  String id;
  String storeName;
  String location;
  String city;
  String state;
  String lat;
  String lng;
  String contactNumber;
  String contactPerson;
  String contactEmail;
  String image;
  String image10080;
  String image300200;
  String preparationTime;
  String distance;
  String rating;
  Timimg timimg;

  factory StoreData.fromJson(Map<String, dynamic> json) => StoreData(
    id: json["id"],
    storeName: json["store_name"],
    location: json["location"],
    city: json["city"],
    state: json["state"],
    lat: json["lat"],
    lng: json["lng"],
    contactNumber: json["contact_number"],
    contactPerson: json["contact_person"],
    contactEmail: json["contact_email"],
    image: json["image"],
    image10080: json["image_100_80"],
    image300200: json["image_300_200"],
    preparationTime: json["preparation_time"],
    distance: json["distance"],
    rating: json["rating"],
    timimg: json["timimg"] == null ? null : Timimg.fromJson(json["timimg"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "store_name": storeName,
    "location": location,
    "city": city,
    "state": state,
    "lat": lat,
    "lng": lng,
    "contact_number": contactNumber,
    "contact_person": contactPerson,
    "contact_email": contactEmail,
    "image": image,
    "image_100_80": image10080,
    "image_300_200": image300200,
    "preparation_time": preparationTime,
    "distance": distance,
    "rating": rating,
  };
}

class Timimg {
  Timimg({
    this.is24X7Open,
    this.openhoursFrom,
    this.openhoursTo,
    this.closehoursMessage,
    this.storeOpenDays,
  });

  String is24X7Open;
  String openhoursFrom;
  String openhoursTo;
  String closehoursMessage;
  String storeOpenDays;

  Timimg copyWith({
    String is24X7Open,
    String openhoursFrom,
    String openhoursTo,
    String closehoursMessage,
    String storeOpenDays,
  }) =>
      Timimg(
        is24X7Open: is24X7Open ?? this.is24X7Open,
        openhoursFrom: openhoursFrom ?? this.openhoursFrom,
        openhoursTo: openhoursTo ?? this.openhoursTo,
        closehoursMessage: closehoursMessage ?? this.closehoursMessage,
        storeOpenDays: storeOpenDays ?? this.storeOpenDays,
      );

  factory Timimg.fromRawJson(String str) => Timimg.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Timimg.fromJson(Map<String, dynamic> json) => Timimg(
    is24X7Open: json["is24x7_open"] == null ? null : json["is24x7_open"],
    openhoursFrom: json["openhours_from"] == null ? null : json["openhours_from"],
    openhoursTo: json["openhours_to"] == null ? null : json["openhours_to"],
    closehoursMessage: json["closehours_message"] == null ? null : json["closehours_message"],
    storeOpenDays: json["store_open_days"] == null ? null : json["store_open_days"],
  );

  Map<String, dynamic> toJson() => {
    "is24x7_open": is24X7Open == null ? null : is24X7Open,
    "openhours_from": openhoursFrom == null ? null : openhoursFrom,
    "openhours_to": openhoursTo == null ? null : openhoursTo,
    "closehours_message": closehoursMessage == null ? null : closehoursMessage,
    "store_open_days": storeOpenDays == null ? null : storeOpenDays,
  };
}

class Dish {
  Dish({
    this.title,
    this.id,
    this.image,
    this.storeId,
    this.subCategory,
    this.subCategoryId,
    this.category,
    this.categoryId,
    this.image10080,
    this.image300200,
  });

  String title;
  String id;
  String image;
  String storeId;
  String subCategory;
  String subCategoryId;
  String category;
  String categoryId;
  String image10080;
  String image300200;

  Dish copyWith({
    String title,
    String id,
    String image,
    String storeId,
    String subCategory,
    String subCategoryId,
    String category,
    String categoryId,
    String image10080,
    String image300200,
  }) =>
      Dish(
        title: title ?? this.title,
        id: id ?? this.id,
        image: image ?? this.image,
        storeId: storeId ?? this.storeId,
        subCategory: subCategory ?? this.subCategory,
        subCategoryId: subCategoryId ?? this.subCategoryId,
        category: category ?? this.category,
        categoryId: categoryId ?? this.categoryId,
        image10080: image10080 ?? this.image10080,
        image300200: image300200 ?? this.image300200,
      );

  factory Dish.fromRawJson(String str) => Dish.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    title: json["title"] == null ? null : json["title"],
    id: json["id"] == null ? null : json["id"],
    image: json["image"] == null ? null : json["image"],
    storeId: json["store_id"] == null ? null : json["store_id"],
    subCategory: json["sub_category"] == null ? null : json["sub_category"],
    subCategoryId: json["sub_category_id"] == null ? null : json["sub_category_id"],
    category: json["category"] == null ? null : json["category"],
    categoryId: json["category_id"] == null ? null : json["category_id"],
    image10080: json["image_100_80"] == null ? null : json["image_100_80"],
    image300200: json["image_300_200"] == null ? null : json["image_300_200"],
  );

  Map<String, dynamic> toJson() => {
    "title": title == null ? null : title,
    "id": id == null ? null : id,
    "image": image == null ? null : image,
    "store_id": storeId == null ? null : storeId,
    "sub_category": subCategory == null ? null : subCategory,
    "sub_category_id": subCategoryId == null ? null : subCategoryId,
    "category": category == null ? null : category,
    "category_id": categoryId == null ? null : categoryId,
    "image_100_80": image10080 == null ? null : image10080,
    "image_300_200": image300200 == null ? null : image300200,
  };
}
