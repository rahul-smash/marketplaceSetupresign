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

  factory DynamicResponse.fromRawJson(String str) =>
      DynamicResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DynamicResponse.fromJson(Map<String, dynamic> json) =>
      DynamicResponse(
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
    this.homepage,
    this.downloadAppSection,
    this.partnerPage,
    this.offerPage,
    this.storePage,
  });

  Homepage homepage;
  DownloadAppSection downloadAppSection;
  PartnerPage partnerPage;
  Page offerPage;
  Page storePage;

  Data copyWith({
    Homepage homepage,
    DownloadAppSection downloadAppSection,
    PartnerPage partnerPage,
    Page offerPage,
    Page storePage,
  }) =>
      Data(
        homepage: homepage ?? this.homepage,
        downloadAppSection: downloadAppSection ?? this.downloadAppSection,
        partnerPage: partnerPage ?? this.partnerPage,
        offerPage: offerPage ?? this.offerPage,
        storePage: storePage ?? this.storePage,
      );

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        homepage: json["homepage"] == null
            ? null
            : Homepage.fromJson(json["homepage"]),
        downloadAppSection: json["download_app_section"] == null
            ? null
            : DownloadAppSection.fromJson(json["download_app_section"]),
        partnerPage: json["partner_page"] == null
            ? null
            : PartnerPage.fromJson(json["partner_page"]),
        offerPage: json["offer_page"] == null
            ? null
            : Page.fromJson(json["offer_page"]),
        storePage: json["store_page"] == null
            ? null
            : Page.fromJson(json["store_page"]),
      );

  Map<String, dynamic> toJson() => {
        "download_app_section":
            downloadAppSection == null ? null : downloadAppSection.toJson(),
        "partner_page": partnerPage == null ? null : partnerPage.toJson(),
        "offer_page": offerPage == null ? null : offerPage.toJson(),
        "store_page": storePage == null ? null : storePage.toJson(),
      };
}

class DownloadAppSection {
  DownloadAppSection({
    this.homepage,
    this.downloadAppTitle,
    this.downloadAppHeading1,
    this.downloadAppHeading2,
    this.downloadAppImage,
  });

  Homepage homepage;
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

  factory DownloadAppSection.fromRawJson(String str) =>
      DownloadAppSection.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DownloadAppSection.fromJson(Map<String, dynamic> json) =>
      DownloadAppSection(
        downloadAppTitle: json["download_app_title"] == null
            ? null
            : json["download_app_title"],
        downloadAppHeading1: json["download_app_heading1"] == null
            ? null
            : json["download_app_heading1"],
        downloadAppHeading2: json["download_app_heading2"] == null
            ? null
            : json["download_app_heading2"],
        downloadAppImage: json["download_app_image"] == null
            ? null
            : json["download_app_image"],
      );

  Map<String, dynamic> toJson() => {
        "homepage": homepage == null ? null : homepage.toJson(),
        "download_app_title":
            downloadAppTitle == null ? null : downloadAppTitle,
        "download_app_heading1":
            downloadAppHeading1 == null ? null : downloadAppHeading1,
        "download_app_heading2":
            downloadAppHeading2 == null ? null : downloadAppHeading2,
        "download_app_image":
            downloadAppImage == null ? null : downloadAppImage,
      };
}

class Homepage {
  Homepage({
    this.headerOrderNow,
    this.headerLoginText,
    this.locationSearchPlaceholder,
    this.productSearchPlaceholder,
    this.categoryHeading,
    this.tagHeading,
    this.storeHeading,
    this.storeShowAll,
    this.aboutHeading,
    this.footerUsefulLinks,
    this.footerContactUs,
  });

  String headerOrderNow;
  String headerLoginText;
  String locationSearchPlaceholder;
  String productSearchPlaceholder;
  String categoryHeading;
  String tagHeading;
  String storeHeading;
  String storeShowAll;
  String aboutHeading;
  String footerUsefulLinks;
  String footerContactUs;

  Homepage copyWith({
    String headerOrderNow,
    String headerLoginText,
    String locationSearchPlaceholder,
    String productSearchPlaceholder,
    String categoryHeading,
    String tagHeading,
    String storeHeading,
    String storeShowAll,
    String aboutHeading,
    String footerUsefulLinks,
    String footerContactUs,
  }) =>
      Homepage(
        headerOrderNow: headerOrderNow ?? this.headerOrderNow,
        headerLoginText: headerLoginText ?? this.headerLoginText,
        locationSearchPlaceholder:
            locationSearchPlaceholder ?? this.locationSearchPlaceholder,
        productSearchPlaceholder:
            productSearchPlaceholder ?? this.productSearchPlaceholder,
        categoryHeading: categoryHeading ?? this.categoryHeading,
        tagHeading: tagHeading ?? this.tagHeading,
        storeHeading: storeHeading ?? this.storeHeading,
        storeShowAll: storeShowAll ?? this.storeShowAll,
        aboutHeading: aboutHeading ?? this.aboutHeading,
        footerUsefulLinks: footerUsefulLinks ?? this.footerUsefulLinks,
        footerContactUs: footerContactUs ?? this.footerContactUs,
      );

  factory Homepage.fromRawJson(String str) =>
      Homepage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Homepage.fromJson(Map<String, dynamic> json) => Homepage(
        headerOrderNow:
            json["header_order_now"] == null ? null : json["header_order_now"],
        headerLoginText: json["header_login_text"] == null
            ? null
            : json["header_login_text"],
        locationSearchPlaceholder: json["location_search_placeholder"] == null
            ? null
            : json["location_search_placeholder"],
        productSearchPlaceholder: json["product_search_placeholder"] == null
            ? null
            : json["product_search_placeholder"],
        categoryHeading:
            json["category_heading"] == null ? null : json["category_heading"],
        tagHeading: json["tag_heading"] == null ? null : json["tag_heading"],
        storeHeading:
            json["store_heading"] == null ? null : json["store_heading"],
        storeShowAll:
            json["store_show_all"] == null ? null : json["store_show_all"],
        aboutHeading:
            json["about_heading"] == null ? null : json["about_heading"],
        footerUsefulLinks: json["footer_useful_links"] == null
            ? null
            : json["footer_useful_links"],
        footerContactUs: json["footer_contact_us"] == null
            ? null
            : json["footer_contact_us"],
      );

  Map<String, dynamic> toJson() => {
        "header_order_now": headerOrderNow == null ? null : headerOrderNow,
        "header_login_text": headerLoginText == null ? null : headerLoginText,
        "location_search_placeholder": locationSearchPlaceholder == null
            ? null
            : locationSearchPlaceholder,
        "product_search_placeholder":
            productSearchPlaceholder == null ? null : productSearchPlaceholder,
        "category_heading": categoryHeading == null ? null : categoryHeading,
        "tag_heading": tagHeading == null ? null : tagHeading,
        "store_heading": storeHeading == null ? null : storeHeading,
        "store_show_all": storeShowAll == null ? null : storeShowAll,
        "about_heading": aboutHeading == null ? null : aboutHeading,
        "footer_useful_links":
            footerUsefulLinks == null ? null : footerUsefulLinks,
        "footer_contact_us": footerContactUs == null ? null : footerContactUs,
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

  factory PartnerPage.fromRawJson(String str) =>
      PartnerPage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PartnerPage.fromJson(Map<String, dynamic> json) => PartnerPage(
        partnerPageImage: json["partner_page_image"] == null
            ? null
            : json["partner_page_image"],
      );

  Map<String, dynamic> toJson() => {
        "partner_page_image":
            partnerPageImage == null ? null : partnerPageImage,
      };
}
