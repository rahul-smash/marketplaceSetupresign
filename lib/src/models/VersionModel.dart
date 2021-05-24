// To parse this JSON data, do
//
//     final brandVersionModel = brandVersionModelFromJson(jsonString);

import 'dart:convert';

import 'package:restroapp/src/models/StoreResponseModel.dart';

BrandVersionModel brandVersionModelFromJson(String str) =>
    BrandVersionModel.fromJson(json.decode(str));

String brandVersionModelToJson(BrandVersionModel data) =>
    json.encode(data.toJson());

class BrandVersionModel {
  BrandVersionModel({
    this.success,
    this.brand,
  });

  bool success;
  BrandData brand;

  factory BrandVersionModel.fromJson(Map<String, dynamic> json) =>
      BrandVersionModel(
        success: json["success"],
        brand: BrandData.fromJson(json["brand"]),
      );

  Map<String, dynamic> toJson() =>
      {
        "success": success,
        "brand": brand.toJson(),
      };
}

class BrandData {
  String allowCustomerForGst;

  BrandData({this.id,
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
    this.currencyAbbr,
    this.showCurrency,
    this.otpSkip,
    this.cod,
    this.social_login,
    this.deliveryFacility,
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
    this.reviewRatingDisplay,
    this.poweredByLink,
    this.paymentGateway,
    this.allowCustomerForGst,
    this.blDeviceIdUnique,
    this.isRefererFnEnable,
    this.homeScreenSection,
    this.filters,
    this.loyality,
    this.about_us,
    this.webAppThemeColors,
    this.display_distance,
    this.display_store_rating,
    this.display_prepration_time,
    this.display_store_location,
    this.isMembershipOn
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
  String cod;
  String currency;
  String currencyAbbr;
  String showCurrency;
  String favIcon;
  String appIcon;
  String appShareLink;
  String androidShareLink;
  String iphoneShareLink;
  String otpSkip;
  String social_login;
  String deliveryFacility;
  String currencyUnicode;
  String internationalOtp;
  String onlinePayment;
  String loyality;
  String about_us;
  List<PaymentGatewaySettings> paymentGatewaySettings;
  List<Banner> banners;
  List<Banner> webBanners;
  List<dynamic> footerBanners;
  List<dynamic> aboutusBanner;
  List<ForceDownload> forceDownload;
  String logo10080;
  String logo300200;
  AppThemeIcons appThemeIcons;
  String domain;
  String poweredByText;
  String reviewRatingDisplay;
  String poweredByLink;
  bool blDeviceIdUnique;
  bool isRefererFnEnable;
  List<HomeScreenSection> homeScreenSection;
  List<Filter> filters;
  WebAppThemeColors webAppThemeColors;
  String paymentGateway;
  String display_distance;
  String display_store_rating;
  String display_prepration_time;
  String display_store_location;
  String isMembershipOn;

  factory BrandData.fromJson(Map<String, dynamic> json) =>
      BrandData(
          id: json["id"],
          name: json["name"],
          userId: json["user_id"],
          address: json["address"],
          city: json["city"],
          state: json["state"],
          loyality: json["loyality"],
          about_us: json["about_us"],
          country: json["country"],
          timeZone: json["time_zone"],
          zipcode: json["zipcode"],
          logo: json["logo"],
          currency: json["currency"],
          currencyAbbr: json["currency_abbr"],
          otpSkip: json['otp_skip'],
          social_login: json['social_login'],
          deliveryFacility: json['delivery_facility'],
          showCurrency: json["show_currency"],
          favIcon: json["fav_icon"],
          appIcon: json["app_icon"],
          appShareLink: json["app_share_link"],
          androidShareLink: json["android_share_link"],
          iphoneShareLink: json["iphone_share_link"],
          currencyUnicode: json["currency_unicode"],
          internationalOtp: json["international_otp"],
          onlinePayment: json["online_payment"],
          reviewRatingDisplay: json["review_rating_display"],
          cod: json["cod"],
          isMembershipOn: json["is_membership_on"],
          paymentGatewaySettings: json["payment_gateway_settings"] == null
              ? null
              : List<PaymentGatewaySettings>.from(
              json["payment_gateway_settings"]
                  .map((x) => PaymentGatewaySettings.fromJson(x))),
          banners:
          List<Banner>.from(json["banners"].map((x) => Banner.fromJson(x))),
          webBanners:
          List<Banner>.from(json["web_banners"].map((x) => Banner.fromJson(x))),
          footerBanners: List<dynamic>.from(
              json["footer_banners"].map((x) => x)),
          aboutusBanner: List<dynamic>.from(
              json["aboutus_banner"].map((x) => x)),
          forceDownload: List<ForceDownload>.from(
              json["force_download"].map((x) => ForceDownload.fromJson(x))),
          logo10080: json["logo_100_80"],
          logo300200: json["logo_300_200"],
          appThemeIcons: AppThemeIcons.fromJson(json["app_theme_icons"]),
          domain: json["domain"],
          poweredByText: json["powered_by_text"],
          poweredByLink: json["powered_by_link"],
          blDeviceIdUnique: json["bl_device_id_unique"],
          isRefererFnEnable: json["is_referer_fn_enable"],
          allowCustomerForGst: json["allow_customer_for_gst"],
          paymentGateway: json["payment_gateway"],
          display_distance: json["display_distance"] == null
              ? null
              : json["display_distance"].toString(),
          display_store_rating: json["display_store_rating"] == null
              ? null
              : json["display_store_rating"].toString(),
          display_prepration_time: json["display_prepration_time"] == null
              ? null
              : json["display_prepration_time"].toString(),
          display_store_location: json["display_store_location"] == null
              ? null
              : json["display_store_location"].toString(),
          homeScreenSection: json["home_screen_section"] == null ? null : List<
              HomeScreenSection>.from(json["home_screen_section"].map((x) =>
              HomeScreenSection.fromJson(x))),
          filters:
          List<Filter>.from(json["filters"].map((x) => Filter.fromJson(x))),
          webAppThemeColors: json["web_app_theme_colors"] == null
              ? null
              : WebAppThemeColors.fromJson(json["web_app_theme_colors"]));


  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "name": name,
        "user_id": userId,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "time_zone": timeZone,
        "loyality": loyality,
        "about_us": about_us,
        "zipcode": zipcode,
        "logo": logo,
        "currency": currency,
        "currency_abbr": currencyAbbr,
        'otp_skip': otpSkip,
        'social_login': social_login,
        'delivery_facility': deliveryFacility,
        "show_currency": showCurrency,
        "fav_icon": favIcon,
        "app_icon": appIcon,
        "app_share_link": appShareLink,
        "android_share_link": androidShareLink,
        "iphone_share_link": iphoneShareLink,
        "currency_unicode": currencyUnicode,
        "international_otp": internationalOtp,
        "cod": cod,
        "online_payment": onlinePayment,
        "payment_gateway_settings":
        paymentGatewaySettings.map((v) => v.toJson()).toList(),
        "banners": List<dynamic>.from(banners.map((x) => x.toJson())),
        "web_banners": List<dynamic>.from(webBanners.map((x) => x.toJson())),
        "footer_banners": List<dynamic>.from(footerBanners.map((x) => x)),
        "aboutus_banner": List<dynamic>.from(aboutusBanner.map((x) => x)),
        "force_download":
        List<dynamic>.from(forceDownload.map((x) => x.toJson())),
        "logo_100_80": logo10080,
        "logo_300_200": logo300200,
        "app_theme_icons": appThemeIcons.toJson(),
        "domain": domain,
        "powered_by_text": poweredByText,
        "powered_by_link": poweredByLink,
        "bl_device_id_unique": blDeviceIdUnique,
        "is_referer_fn_enable": isRefererFnEnable,
        "web_app_theme_colors": webAppThemeColors,
        "allow_customer_for_gst": allowCustomerForGst,
        "payment_gateway": paymentGateway,
        "is_membership_on": isMembershipOn,
        "home_screen_section": homeScreenSection == null ? null : List<
            dynamic>.from(homeScreenSection.map((x) => x.toJson())),
        "filters": List<dynamic>.from(filters.map((x) => x.toJson())),
        "display_distance": display_distance == null ? null : display_distance,
        "display_store_rating": display_store_rating == null
            ? null
            : display_store_rating,
        "display_prepration_time": display_prepration_time == null
            ? null
            : display_prepration_time,
        "display_store_location": display_store_location == null
            ? null
            : display_store_location,
      };
}

class Filter {
  Filter({
    this.lable,
    this.value,
  });

  String lable;
  String value;

  factory Filter.fromJson(Map<String, dynamic> json) =>
      Filter(
        lable: json["lable"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() =>
      {
        "lable": lable,
        "value": value,
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

  factory AppThemeIcons.fromJson(Map<String, dynamic> json) =>
      AppThemeIcons(
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

  Map<String, dynamic> toJson() =>
      {
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

class Banner {
  Banner({
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

  factory Banner.fromJson(Map<String, dynamic> json) =>
      Banner(
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

  Map<String, dynamic> toJson() =>
      {
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

  factory ForceDownload.fromJson(Map<String, dynamic> json) =>
      ForceDownload(
        iosAppVersion: json["ios_app_version"],
        androidAppVerison: json["android_app_verison"],
        windowAppVersion: json["window_app_version"],
        forceDownload: json["force_download"],
        forceDownloadMessage: json["force_download_message"],
      );

  Map<String, dynamic> toJson() =>
      {
        "ios_app_version": iosAppVersion,
        "android_app_verison": androidAppVerison,
        "window_app_version": windowAppVersion,
        "force_download": forceDownload,
        "force_download_message": forceDownloadMessage,
      };
}

class PaymentGatewaySettings {
  String apiKey;
  String secretKey;
  String paymentGateway;

  PaymentGatewaySettings({this.apiKey, this.secretKey, this.paymentGateway});

  PaymentGatewaySettings.fromJson(Map<String, dynamic> json) {
    apiKey = json['api_key'];
    secretKey = json['secret_key'];
    paymentGateway = json['payment_gateway'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['api_key'] = this.apiKey;
    data['secret_key'] = this.secretKey;
    data['payment_gateway'] = this.paymentGateway;
    return data;
  }
}

class WebAppThemeColors {
  WebAppThemeColors({
    this.id,
    this.storeId,
    this.webThemePrimaryColor,
    this.webThemeSecondaryColor,
    this.webThemeCategoryOpenColor,
    this.stripsColor,
    this.footerColor,
    this.listingBackgroundColor,
    this.listingBorderColor,
    this.listingBoxBackgroundColor,
    this.homeSubHeadingColor,
    this.homeDescriptionColor,
    this.categoryListingButtonBorderColor,
    this.categoryListingBoxBackgroundColor,
  });

  String id;
  String storeId;
  String webThemePrimaryColor;
  String webThemeSecondaryColor;
  String webThemeCategoryOpenColor;
  String stripsColor;
  String footerColor;
  String listingBackgroundColor;
  String listingBorderColor;
  String listingBoxBackgroundColor;
  String homeSubHeadingColor;
  String homeDescriptionColor;
  String categoryListingButtonBorderColor;
  String categoryListingBoxBackgroundColor;

  WebAppThemeColors copyWith({
    String id,
    String storeId,
    String webThemePrimaryColor,
    String webThemeSecondaryColor,
    String webThemeCategoryOpenColor,
    String stripsColor,
    String footerColor,
    String listingBackgroundColor,
    String listingBorderColor,
    String listingBoxBackgroundColor,
    String homeSubHeadingColor,
    String homeDescriptionColor,
    String categoryListingButtonBorderColor,
    String categoryListingBoxBackgroundColor,
  }) =>
      WebAppThemeColors(
        id: id ?? this.id,
        storeId: storeId ?? this.storeId,
        webThemePrimaryColor: webThemePrimaryColor ?? this.webThemePrimaryColor,
        webThemeSecondaryColor:
        webThemeSecondaryColor ?? this.webThemeSecondaryColor,
        webThemeCategoryOpenColor:
        webThemeCategoryOpenColor ?? this.webThemeCategoryOpenColor,
        stripsColor: stripsColor ?? this.stripsColor,
        footerColor: footerColor ?? this.footerColor,
        listingBackgroundColor:
        listingBackgroundColor ?? this.listingBackgroundColor,
        listingBorderColor: listingBorderColor ?? this.listingBorderColor,
        listingBoxBackgroundColor:
        listingBoxBackgroundColor ?? this.listingBoxBackgroundColor,
        homeSubHeadingColor: homeSubHeadingColor ?? this.homeSubHeadingColor,
        homeDescriptionColor: homeDescriptionColor ?? this.homeDescriptionColor,
        categoryListingButtonBorderColor: categoryListingButtonBorderColor ??
            this.categoryListingButtonBorderColor,
        categoryListingBoxBackgroundColor: categoryListingBoxBackgroundColor ??
            this.categoryListingBoxBackgroundColor,
      );

  factory WebAppThemeColors.fromRawJson(String str) =>
      WebAppThemeColors.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WebAppThemeColors.fromJson(Map<String, dynamic> json) =>
      WebAppThemeColors(
        id: json["id"] == null ? null : json["id"],
        storeId: json["store_id"] == null ? null : json["store_id"],
        webThemePrimaryColor: json["web_theme_primary_color"] == null
            ? null
            : json["web_theme_primary_color"],
        webThemeSecondaryColor: json["web_theme_secondary_color"] == null
            ? null
            : json["web_theme_secondary_color"],
        webThemeCategoryOpenColor: json["web_theme_category_open_color"] == null
            ? null
            : json["web_theme_category_open_color"],
        stripsColor: json["strips_color"] == null ? null : json["strips_color"],
        footerColor: json["footer_color"] == null ? null : json["footer_color"],
        listingBackgroundColor: json["listing_background_color"] == null
            ? null
            : json["listing_background_color"],
        listingBorderColor: json["listing_border_color"] == null
            ? null
            : json["listing_border_color"],
        listingBoxBackgroundColor: json["listing_box_background_color"] == null
            ? null
            : json["listing_box_background_color"],
        homeSubHeadingColor: json["home_sub_heading_color"] == null
            ? null
            : json["home_sub_heading_color"],
        homeDescriptionColor: json["home_description_color"] == null
            ? null
            : json["home_description_color"],
        categoryListingButtonBorderColor:
        json["category_listing_button_border_color"] == null
            ? null
            : json["category_listing_button_border_color"],
        categoryListingBoxBackgroundColor:
        json["category_listing_box_background_color"] == null
            ? null
            : json["category_listing_box_background_color"],
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id == null ? null : id,
        "store_id": storeId == null ? null : storeId,
        "web_theme_primary_color":
        webThemePrimaryColor == null ? null : webThemePrimaryColor,
        "web_theme_secondary_color":
        webThemeSecondaryColor == null ? null : webThemeSecondaryColor,
        "web_theme_category_open_color": webThemeCategoryOpenColor == null
            ? null
            : webThemeCategoryOpenColor,
        "strips_color": stripsColor == null ? null : stripsColor,
        "footer_color": footerColor == null ? null : footerColor,
        "listing_background_color":
        listingBackgroundColor == null ? null : listingBackgroundColor,
        "listing_border_color":
        listingBorderColor == null ? null : listingBorderColor,
        "listing_box_background_color": listingBoxBackgroundColor == null
            ? null
            : listingBoxBackgroundColor,
        "home_sub_heading_color":
        homeSubHeadingColor == null ? null : homeSubHeadingColor,
        "home_description_color":
        homeDescriptionColor == null ? null : homeDescriptionColor,
        "category_listing_button_border_color":
        categoryListingButtonBorderColor == null
            ? null
            : categoryListingButtonBorderColor,
        "category_listing_box_background_color":
        categoryListingBoxBackgroundColor == null
            ? null
            : categoryListingBoxBackgroundColor,
      };
}

class HomeScreenSection {
  HomeScreenSection({
    this.section,
    this.display,
    this.position,
  });

  String section;
  bool display;
  String position;

  HomeScreenSection copyWith({
    String section,
    bool display,
    String position,
  }) =>
      HomeScreenSection(
        section: section ?? this.section,
        display: display ?? this.display,
        position: position ?? this.position,
      );

  factory HomeScreenSection.fromRawJson(String str) =>
      HomeScreenSection.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HomeScreenSection.fromJson(Map<String, dynamic> json) =>
      HomeScreenSection(
        section: json["section"] == null ? null : json["section"],
        display: json["display"] == null ? null : json["display"],
        position: json["position"] == null ? null : json["position"],
      );

  Map<String, dynamic> toJson() =>
      {
        "section": section == null ? null : section,
        "display": display == null ? null : display,
        "position": position == null ? null : position,
      };
}

