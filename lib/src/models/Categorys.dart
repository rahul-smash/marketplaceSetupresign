// To parse this JSON data, do
//
//     final categoriesModel = categoriesModelFromJson(jsonString);

import 'dart:convert';

CategoriesModel categoriesModelFromJson(String str) => CategoriesModel.fromJson(json.decode(str));

String categoriesModelToJson(CategoriesModel data) => json.encode(data.toJson());

class CategoriesModel {
  CategoriesModel({
    this.success,
    this.data,
  });

  bool success;
  List<CategoriesData> data;

  factory CategoriesModel.fromJson(Map<String, dynamic> json) => CategoriesModel(
    success: json["success"],
    data: List<CategoriesData>.from(json["data"].map((x) => CategoriesData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CategoriesData {
  CategoriesData({
    this.id,
    this.title,
    this.image,
    this.image10080,
    this.image300200,
  });

  String id;
  String title;
  String image;
  String image10080;
  String image300200;

  factory CategoriesData.fromJson(Map<String, dynamic> json) => CategoriesData(
    id: json["id"],
    title: json["title"],
    image: json["image"],
    image10080: json["image_100_80"],
    image300200: json["image_300_200"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image": image,
    "image_100_80": image10080,
    "image_300_200": image300200,
  };
}
