// To parse this JSON data, do
//
//     final tagsModel = tagsModelFromJson(jsonString);

import 'dart:convert';

TagsModel tagsModelFromJson(String str) => TagsModel.fromJson(json.decode(str));

String tagsModelToJson(TagsModel data) => json.encode(data.toJson());

class TagsModel {
  TagsModel({
    this.success,
    this.data,
  });

  bool success;
  List<TagData> data;

  factory TagsModel.fromJson(Map<String, dynamic> json) => TagsModel(
    success: json["success"],
    data: List<TagData>.from(json["data"].map((x) => TagData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class TagData {
  TagData({
    this.id,
    this.name,
    this.image,
    this.image10080,
    this.image300200,
    this.tagGradientColor1,
    this.tagGradientColor2,
  });

  String id;
  String name;
  String image;
  String image10080;
  String image300200;
  String tagGradientColor1;
  String tagGradientColor2;
  bool isFilterView = false;

  factory TagData.fromJson(Map<String, dynamic> json) => TagData(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    image10080: json["image_100_80"],
    image300200: json["image_300_200"],
    tagGradientColor1: json["tag_gradient_color1"],
    tagGradientColor2: json["tag_gradient_color2"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "image_100_80": image10080,
    "image_300_200": image300200,
    "tag_gradient_color1": tagGradientColor1,
    "tag_gradient_color2": tagGradientColor2,
  };
}
