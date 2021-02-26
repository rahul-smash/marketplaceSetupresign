// To parse this JSON data, do
//
//     final dynamicResponse = dynamicResponseFromJson(jsonString);

import 'dart:convert';

class DynamicResponse {
  DynamicResponse({
    this.success,
    this.data,
  });

  bool success;
  Data data;

  DynamicResponse copyWith({
    bool success,
    Data data,
  }) =>
      DynamicResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory DynamicResponse.fromRawJson(String str) => DynamicResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DynamicResponse.fromJson(Map<String, dynamic> json) => DynamicResponse(
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
    this.downloadAppSection,
    this.partnerPage,
    this.offerPage,
    this.storePage,
  });

  DownloadAppSection downloadAppSection;
  PartnerPage partnerPage;
  Page offerPage;
  Page storePage;

  Data copyWith({
    DownloadAppSection downloadAppSection,
    PartnerPage partnerPage,
    Page offerPage,
    Page storePage,
  }) =>
      Data(
        downloadAppSection: downloadAppSection ?? this.downloadAppSection,
        partnerPage: partnerPage ?? this.partnerPage,
        offerPage: offerPage ?? this.offerPage,
        storePage: storePage ?? this.storePage,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    downloadAppSection: json["download_app_section"] == null ? null : DownloadAppSection.fromJson(json["download_app_section"]),
    partnerPage: json["partner_page"] == null ? null : PartnerPage.fromJson(json["partner_page"]),
    offerPage: json["offer_page"] == null ? null : Page.fromJson(json["offer_page"]),
    storePage: json["store_page"] == null ? null : Page.fromJson(json["store_page"]),
  );

  Map<String, dynamic> toJson() => {
    "download_app_section": downloadAppSection == null ? null : downloadAppSection.toJson(),
    "partner_page": partnerPage == null ? null : partnerPage.toJson(),
    "offer_page": offerPage == null ? null : offerPage.toJson(),
    "store_page": storePage == null ? null : storePage.toJson(),
  };
}

class DownloadAppSection {
  DownloadAppSection({
    this.downloadAppTitle,
    this.downloadAppHeading1,
    this.downloadAppHeading2,
    this.downloadAppImage,
  });

  String downloadAppTitle;
  String downloadAppHeading1;
  String downloadAppHeading2;
  String downloadAppImage;

  DownloadAppSection copyWith({
    String downloadAppTitle,
    String downloadAppHeading1,
    String downloadAppHeading2,
    String downloadAppImage,
  }) =>
      DownloadAppSection(
        downloadAppTitle: downloadAppTitle ?? this.downloadAppTitle,
        downloadAppHeading1: downloadAppHeading1 ?? this.downloadAppHeading1,
        downloadAppHeading2: downloadAppHeading2 ?? this.downloadAppHeading2,
        downloadAppImage: downloadAppImage ?? this.downloadAppImage,
      );

  factory DownloadAppSection.fromRawJson(String str) => DownloadAppSection.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DownloadAppSection.fromJson(Map<String, dynamic> json) => DownloadAppSection(
    downloadAppTitle: json["download_app_title"] == null ? null : json["download_app_title"],
    downloadAppHeading1: json["download_app_heading1"] == null ? null : json["download_app_heading1"],
    downloadAppHeading2: json["download_app_heading2"] == null ? null : json["download_app_heading2"],
    downloadAppImage: json["download_app_image"] == null ? null : json["download_app_image"],
  );

  Map<String, dynamic> toJson() => {
    "download_app_title": downloadAppTitle == null ? null : downloadAppTitle,
    "download_app_heading1": downloadAppHeading1 == null ? null : downloadAppHeading1,
    "download_app_heading2": downloadAppHeading2 == null ? null : downloadAppHeading2,
    "download_app_image": downloadAppImage == null ? null : downloadAppImage,
  };
}

class Page {
  Page({
    this.heading1,
    this.heading2,
  });

  String heading1;
  String heading2;

  Page copyWith({
    String heading1,
    String heading2,
  }) =>
      Page(
        heading1: heading1 ?? this.heading1,
        heading2: heading2 ?? this.heading2,
      );

  factory Page.fromRawJson(String str) => Page.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Page.fromJson(Map<String, dynamic> json) => Page(
    heading1: json["heading1"] == null ? null : json["heading1"],
    heading2: json["heading2"] == null ? null : json["heading2"],
  );

  Map<String, dynamic> toJson() => {
    "heading1": heading1 == null ? null : heading1,
    "heading2": heading2 == null ? null : heading2,
  };
}

class PartnerPage {
  PartnerPage({
    this.partnerPageImage,
  });

  String partnerPageImage;

  PartnerPage copyWith({
    String partnerPageImage,
  }) =>
      PartnerPage(
        partnerPageImage: partnerPageImage ?? this.partnerPageImage,
      );

  factory PartnerPage.fromRawJson(String str) => PartnerPage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PartnerPage.fromJson(Map<String, dynamic> json) => PartnerPage(
    partnerPageImage: json["partner_page_image"] == null ? null : json["partner_page_image"],
  );

  Map<String, dynamic> toJson() => {
    "partner_page_image": partnerPageImage == null ? null : partnerPageImage,
  };
}
