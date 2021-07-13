// To parse this JSON data, do
//
//     final bannerResponse = bannerResponseFromJson(jsonString);

import 'dart:convert';

import 'StoreResponseModel.dart';

class BannerResponse {
  BannerResponse({
    this.success,
    this.data,
  });

  bool success;
  Data data;

  BannerResponse copyWith({
    bool success,
    Data data,
  }) =>
      BannerResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory BannerResponse.fromRawJson(String str) => BannerResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BannerResponse.fromJson(Map<String, dynamic> json) => BannerResponse(
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
    this.banners,
    this.webBanners,
    this.footerBanners,
    this.aboutusBanner,
  });

  List<Banner> banners;
  List<Banner> webBanners;
  List<Banner> footerBanners;
  List<Banner> aboutusBanner;

  Data copyWith({
    List<Banner> banners,
    List<Banner> webBanners,
    List<Banner> footerBanners,
    List<Banner> aboutusBanner,
  }) =>
      Data(
        banners: banners ?? this.banners,
        webBanners: webBanners ?? this.webBanners,
        footerBanners: footerBanners ?? this.footerBanners,
        aboutusBanner: aboutusBanner ?? this.aboutusBanner,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    banners: json["banners"] == null ? null : List<Banner>.from(json["banners"].map((x) => Banner.fromJson(x))),
    webBanners: json["web_banners"] == null ? null : List<Banner>.from(json["web_banners"].map((x) => Banner.fromJson(x))),
    footerBanners: json["footer_banners"] == null ? null : List<Banner>.from(json["footer_banners"].map((x) => Banner.fromJson(x))),
    aboutusBanner: json["aboutus_banner"] == null ? null : List<Banner>.from(json["aboutus_banner"].map((x) => Banner.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "banners": banners == null ? null : List<dynamic>.from(banners.map((x) => x.toJson())),
    "web_banners": webBanners == null ? null : List<dynamic>.from(webBanners.map((x) => x.toJson())),
    "footer_banners": footerBanners == null ? null : List<dynamic>.from(footerBanners.map((x) => x.toJson())),
    "aboutus_banner": aboutusBanner == null ? null : List<dynamic>.from(aboutusBanner.map((x) => x.toJson())),
  };
}

