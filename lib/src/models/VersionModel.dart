// To parse this JSON data, do
//
//     final versionModel = versionModelFromJson(jsonString);

import 'dart:convert';

BrandVersionModel versionModelFromJson(String str) => BrandVersionModel.fromJson(json.decode(str));

String versionModelToJson(BrandVersionModel data) => json.encode(data.toJson());

class BrandVersionModel {
  BrandVersionModel({
    this.success,
    this.brand,
  });

  bool success;
  BrandData brand;

  factory BrandVersionModel.fromJson(Map<String, dynamic> json) => BrandVersionModel(
    success: json["success"],
    brand: json["brand"] == null ? null : BrandData.fromJson(json["brand"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "brand": brand.toJson(),
  };
}

class BrandData {
  BrandData({
    this.id,
    this.name,
    this.userId,
    this.address,
    this.city,
    this.state,
    this.country,
    this.timeZone,
    this.zipcode,
    this.logo,
    this.currency,
    this.showCurrency,
    this.favIcon,
    this.appIcon,
    this.appShareLink,
    this.androidShareLink,
    this.iphoneShareLink,
    this.currencyUnicode,
    this.internationalOtp,
    this.onlinePayment,
    this.paymentGatewaySettings,
    this.banners,
    this.webBanners,
    this.footerBanners,
    this.aboutusBanner,
    this.forceDownload,
    this.logo10080,
    this.logo300200,
    this.appThemeIcons,
    this.domain,
    this.poweredByText,
    this.poweredByLink,
    this.blDeviceIdUnique,
    this.isRefererFnEnable,
    this.homeScreenSection,
  });

  String id;
  String name;
  String userId;
  String address;
  String city;
  String state;
  String country;
  String timeZone;
  String zipcode;
  String logo;
  String currency;
  String showCurrency;
  String favIcon;
  String appIcon;
  String appShareLink;
  String androidShareLink;
  String iphoneShareLink;
  String currencyUnicode;
  String internationalOtp;
  String onlinePayment;
  List<dynamic> paymentGatewaySettings;
  List<dynamic> banners;
  List<WebBanner> webBanners;
  List<dynamic> footerBanners;
  List<dynamic> aboutusBanner;
  List<ForceDownload> forceDownload;
  String logo10080;
  String logo300200;
  AppThemeIcons appThemeIcons;
  String domain;
  String poweredByText;
  String poweredByLink;
  bool blDeviceIdUnique;
  bool isRefererFnEnable;
  List<dynamic> homeScreenSection;

  factory BrandData.fromJson(Map<String, dynamic> json) => BrandData(
    id: json["id"],
    name: json["name"],
    userId: json["user_id"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    timeZone: json["time_zone"],
    zipcode: json["zipcode"],
    logo: json["logo"],
    currency: json["currency"],
    showCurrency: json["show_currency"],
    favIcon: json["fav_icon"],
    appIcon: json["app_icon"],
    appShareLink: json["app_share_link"],
    androidShareLink: json["android_share_link"],
    iphoneShareLink: json["iphone_share_link"],
    currencyUnicode: json["currency_unicode"],
    internationalOtp: json["international_otp"],
    onlinePayment: json["online_payment"],
    paymentGatewaySettings: List<dynamic>.from(json["payment_gateway_settings"].map((x) => x)),
    banners: List<dynamic>.from(json["banners"].map((x) => x)),
    webBanners: List<WebBanner>.from(json["web_banners"].map((x) => WebBanner.fromJson(x))),
    footerBanners: List<dynamic>.from(json["footer_banners"].map((x) => x)),
    aboutusBanner: List<dynamic>.from(json["aboutus_banner"].map((x) => x)),
    forceDownload: List<ForceDownload>.from(json["force_download"].map((x) => ForceDownload.fromJson(x))),
    logo10080: json["logo_100_80"],
    logo300200: json["logo_300_200"],
    appThemeIcons: AppThemeIcons.fromJson(json["app_theme_icons"]),
    domain: json["domain"],
    poweredByText: json["powered_by_text"],
    poweredByLink: json["powered_by_link"],
    blDeviceIdUnique: json["bl_device_id_unique"],
    isRefererFnEnable: json["is_referer_fn_enable"],
    homeScreenSection: List<dynamic>.from(json["home_screen_section"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "user_id": userId,
    "address": address,
    "city": city,
    "state": state,
    "country": country,
    "time_zone": timeZone,
    "zipcode": zipcode,
    "logo": logo,
    "currency": currency,
    "show_currency": showCurrency,
    "fav_icon": favIcon,
    "app_icon": appIcon,
    "app_share_link": appShareLink,
    "android_share_link": androidShareLink,
    "iphone_share_link": iphoneShareLink,
    "currency_unicode": currencyUnicode,
    "international_otp": internationalOtp,
    "online_payment": onlinePayment,
    "payment_gateway_settings": List<dynamic>.from(paymentGatewaySettings.map((x) => x)),
    "banners": List<dynamic>.from(banners.map((x) => x)),
    "web_banners": List<dynamic>.from(webBanners.map((x) => x.toJson())),
    "footer_banners": List<dynamic>.from(footerBanners.map((x) => x)),
    "aboutus_banner": List<dynamic>.from(aboutusBanner.map((x) => x)),
    "force_download": List<dynamic>.from(forceDownload.map((x) => x.toJson())),
    "logo_100_80": logo10080,
    "logo_300_200": logo300200,
    "app_theme_icons": appThemeIcons.toJson(),
    "domain": domain,
    "powered_by_text": poweredByText,
    "powered_by_link": poweredByLink,
    "bl_device_id_unique": blDeviceIdUnique,
    "is_referer_fn_enable": isRefererFnEnable,
    "home_screen_section": List<dynamic>.from(homeScreenSection.map((x) => x)),
  };
}

class AppThemeIcons {
  AppThemeIcons({
    this.id,
    this.icon7272,
    this.icon9696,
    this.icon128128,
    this.icon144144,
    this.icon152152,
    this.icon192192,
    this.icon384384,
    this.icon512512,
  });

  String id;
  String icon7272;
  String icon9696;
  String icon128128;
  String icon144144;
  String icon152152;
  String icon192192;
  String icon384384;
  String icon512512;

  factory AppThemeIcons.fromJson(Map<String, dynamic> json) => AppThemeIcons(
    id: json["id"],
    icon7272: json["icon_72_72"],
    icon9696: json["icon_96_96"],
    icon128128: json["icon_128_128"],
    icon144144: json["icon_144_144"],
    icon152152: json["icon_152_152"],
    icon192192: json["icon_192_192"],
    icon384384: json["icon_384_384"],
    icon512512: json["icon_512_512"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "icon_72_72": icon7272,
    "icon_96_96": icon9696,
    "icon_128_128": icon128128,
    "icon_144_144": icon144144,
    "icon_152_152": icon152152,
    "icon_192_192": icon192192,
    "icon_384_384": icon384384,
    "icon_512_512": icon512512,
  };
}

class ForceDownload {
  ForceDownload({
    this.iosAppVersion,
    this.androidAppVerison,
    this.windowAppVersion,
    this.forceDownload,
    this.forceDownloadMessage,
  });

  String iosAppVersion;
  String androidAppVerison;
  String windowAppVersion;
  String forceDownload;
  String forceDownloadMessage;

  factory ForceDownload.fromJson(Map<String, dynamic> json) => ForceDownload(
    iosAppVersion: json["ios_app_version"],
    androidAppVerison: json["android_app_verison"],
    windowAppVersion: json["window_app_version"],
    forceDownload: json["force_download"],
    forceDownloadMessage: json["force_download_message"],
  );

  Map<String, dynamic> toJson() => {
    "ios_app_version": iosAppVersion,
    "android_app_verison": androidAppVerison,
    "window_app_version": windowAppVersion,
    "force_download": forceDownload,
    "force_download_message": forceDownloadMessage,
  };
}

class WebBanner {
  WebBanner({
    this.id,
    this.storeId,
    this.link,
    this.title,
    this.categoryId,
    this.subCategoryId,
    this.productId,
    this.offerId,
    this.image,
    this.linkTo,
    this.pageId,
    this.status,
    this.type,
    this.platform,
  });

  String id;
  String storeId;
  String link;
  String title;
  String categoryId;
  String subCategoryId;
  String productId;
  String offerId;
  String image;
  String linkTo;
  String pageId;
  bool status;
  String type;
  String platform;

  factory WebBanner.fromJson(Map<String, dynamic> json) => WebBanner(
    id: json["id"],
    storeId: json["store_id"],
    link: json["link"],
    title: json["title"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    productId: json["product_id"],
    offerId: json["offer_id"],
    image: json["image"],
    linkTo: json["link_to"],
    pageId: json["page_id"],
    status: json["status"],
    type: json["type"],
    platform: json["platform"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "store_id": storeId,
    "link": link,
    "title": title,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "product_id": productId,
    "offer_id": offerId,
    "image": image,
    "link_to": linkTo,
    "page_id": pageId,
    "status": status,
    "type": type,
    "platform": platform,
  };
}
