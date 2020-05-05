// To parse this JSON data, do
//
//     final configModel = configModelFromJson(jsonString);

import 'dart:convert';

ConfigModel configModelFromJson(String str) => ConfigModel.fromJson(json.decode(str));

String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConfigModel {
  String storeId;
  String isAdminLogin;
  String appTheme;
  String leftMenuIconColors;
  String leftMenuBackgroundColor;
  String leftMenuTitleColors;
  String leftMenuUsernameColors;
  String bottomBarIconColor;
  String bottomBarTextColor;

  ConfigModel({
    this.storeId,
    this.isAdminLogin,
    this.appTheme,
    this.leftMenuIconColors,
    this.leftMenuBackgroundColor,
    this.leftMenuTitleColors,
    this.leftMenuUsernameColors,
    this.bottomBarIconColor,
    this.bottomBarTextColor,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
    storeId: json["store_id"],
    isAdminLogin: json["isAdminLogin"],
    appTheme: json["appTheme"],
    leftMenuIconColors: json["left_menu_icon_colors"],
    leftMenuBackgroundColor: json["left_menu_background_color"],
    leftMenuTitleColors: json["leftMenuTitleColors"],
    leftMenuUsernameColors: json["leftMenuUsernameColors"],
    bottomBarIconColor: json["bottomBarIconColor"],
    bottomBarTextColor: json["bottomBarTextColor"],
  );

  Map<String, dynamic> toJson() => {
    "store_id": storeId,
    "isAdminLogin": isAdminLogin,
    "appTheme": appTheme,
    "left_menu_icon_colors": leftMenuIconColors,
    "left_menu_background_color": leftMenuBackgroundColor,
    "leftMenuTitleColors": leftMenuTitleColors,
    "leftMenuUsernameColors": leftMenuUsernameColors,
    "bottomBarIconColor": bottomBarIconColor,
    "bottomBarTextColor": bottomBarTextColor,
  };
}
