// To parse this JSON data, do
//
//     final storeDataModel = storeDataModelFromJson(jsonString);

import 'dart:convert';

import 'StoreResponseModel.dart';

StoreDataModel storeDataModelFromJson(String str) => StoreDataModel.fromJson(json.decode(str));

String storeDataModelToJson(StoreDataModel data) => json.encode(data.toJson());

class StoreDataModel {
  StoreDataModel({
    this.success,
    this.store,
  });

  bool success;
  StoreDataObj store;

  factory StoreDataModel.fromJson(Map<String, dynamic> json) => StoreDataModel(
    success: json["success"],
    store: StoreDataObj.fromJson(json["store"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "store": store.toJson(),
  };
}

class StoreDataObj {
  StoreDataObj({
    this.id,
    this.brandId,
    this.storeName,
    this.location,
    this.city,
    this.state,
    this.country,
    this.timezone,
    this.zipcode,
    this.lat,
    this.lng,
    this.contactPerson,
    this.contactNumber,
    this.contactEmail,
    this.aboutUs,
    this.termConditions,
    this.privacyPolicy,
    this.refundPolicy,
    this.otpSkip,
    this.version,
    this.currency,
    this.showCurrency,
    this.appShareLink,
    this.androidShareLink,
    this.iphoneShareLink,
    this.theme,
    this.webTheme,
    this.pwaTheme,
    this.type,
    this.catType,
    this.storeLogo,
    this.preparationTime,
    this.orderFacilities,
    this.favIcon,
    this.appIcon,
    this.bannerTime,
    this.webCache,
    this.scoMetaTitle,
    this.scoMetaDescription,
    this.scoMetaKeywords,
    this.payment,
    this.paymentEmailCount,
    this.modified,
    this.banner,
    this.storeStatus,
    this.storeMsg,
    this.homePageTitleStatus,
    this.homePageTitle,
    this.homePageSubtitleStatus,
    this.homePageSubtitle,
    this.homePageHeaderRight,
    this.homePageDisplayNumber,
    this.homePageDisplayNumberType,
    this.gaKey,
    this.fbPixelKey,
    this.gaPixelKey,
    this.noCatHomePage,
    this.noProductHomePage,
    this.productTitleHomePage,
    this.mapDisplay,
    this.reviewRatingDisplay,
    this.isEmailMandatoryPlaceorder,
    this.displayStoreLogoName,
    this.cod,
    this.recommendedProducts,
    this.deliverySlot,
    this.geofencing,
    this.loyality,
    this.pickupFacility,
    this.deliveryFacility,
    this.inStore,
    this.internationalOtp,
    this.multipleStore,
    this.webMenuSetting,
    this.mobileNotifications,
    this.emailNotifications,
    this.smsNotifications,
    this.gst,
    this.runnerManagement,
    this.gaCode,
    this.categoryLayout,
    this.deliveryArea,
    this.radiusIn,
    this.productImage,
    this.is24X7Open,
    this.openhoursFrom,
    this.openhoursTo,
    this.closehoursMessage,
    this.storeOpenDays,
    this.banners,
    this.webBanners,
    this.footerBanners,
    this.aboutusBanner,
    this.banner10080,
    this.banner300200,
    this.repeatOrder,
  });

  String id;
  String brandId;
  String storeName;
  String location;
  String city;
  String state;
  String country;
  String timezone;
  String zipcode;
  String lat;
  String lng;
  String contactPerson;
  String contactNumber;
  String contactEmail;
  String aboutUs;
  String termConditions;
  String privacyPolicy;
  String refundPolicy;
  String otpSkip;
  String version;
  String currency;
  String showCurrency;
  String appShareLink;
  String androidShareLink;
  String iphoneShareLink;
  String theme;
  String webTheme;
  String pwaTheme;
  String type;
  String catType;
  String storeLogo;
  String preparationTime;
  String orderFacilities;
  String favIcon;
  String appIcon;
  String bannerTime;
  String webCache;
  String scoMetaTitle;
  String scoMetaDescription;
  String scoMetaKeywords;
  String payment;
  String paymentEmailCount;
  DateTime modified;
  String banner;
  String storeStatus;
  String storeMsg;
  bool homePageTitleStatus;
  String homePageTitle;
  bool homePageSubtitleStatus;
  String homePageSubtitle;
  String homePageHeaderRight;
  String homePageDisplayNumber;
  String homePageDisplayNumberType;
  String gaKey;
  String fbPixelKey;
  String gaPixelKey;
  String noCatHomePage;
  String noProductHomePage;
  String productTitleHomePage;
  String mapDisplay;
  String reviewRatingDisplay;
  String isEmailMandatoryPlaceorder;
  String displayStoreLogoName;
  String cod;
  String recommendedProducts;
  String deliverySlot;
  String geofencing;
  String loyality;
  String pickupFacility;
  String deliveryFacility;
  String inStore;
  String internationalOtp;
  String multipleStore;
  String webMenuSetting;
  String mobileNotifications;
  String emailNotifications;
  String smsNotifications;
  String gst;
  String runnerManagement;
  String gaCode;
  String categoryLayout;
  String deliveryArea;
  String radiusIn;
  String productImage;
  String is24X7Open;
  String openhoursFrom;
  String openhoursTo;
  String closehoursMessage;
  String storeOpenDays;
  List<dynamic> banners;
  List<dynamic> webBanners;
  List<dynamic> footerBanners;
  List<dynamic> aboutusBanner;
  String banner10080;
  String banner300200;
  String repeatOrder;

  factory StoreDataObj.fromJson(Map<String, dynamic> json) => StoreDataObj(
    id: json["id"],
    brandId: json["brand_id"],
    storeName: json["store_name"],
    location: json["location"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    timezone: json["timezone"],
    zipcode: json["zipcode"],
    lat: json["lat"],
    lng: json["lng"],
    contactPerson: json["contact_person"],
    contactNumber: json["contact_number"],
    contactEmail: json["contact_email"],
    aboutUs: json["about_us"],
    termConditions: json["term_conditions"],
    privacyPolicy: json["privacy_policy"],
    refundPolicy: json["refund_policy"],
    otpSkip: json["otp_skip"],
    version: json["version"],
    currency: json["currency"],
    showCurrency: json["show_currency"],
    appShareLink: json["app_share_link"],
    androidShareLink: json["android_share_link"],
    iphoneShareLink: json["iphone_share_link"],
    theme: json["theme"],
    webTheme: json["web_theme"],
    pwaTheme: json["pwa_theme"],
    type: json["type"],
    catType: json["cat_type"],
    storeLogo: json["store_logo"],
    preparationTime: json["preparation_time"],
    orderFacilities: json["order_facilities"],
    favIcon: json["fav_icon"],
    appIcon: json["app_icon"],
    bannerTime: json["banner_time"],
    webCache: json["web_cache"],
    scoMetaTitle: json["sco_meta_title"],
    scoMetaDescription: json["sco_meta_description"],
    scoMetaKeywords: json["sco_meta_keywords"],
    payment: json["payment"],
    paymentEmailCount: json["payment_email_count"],
    modified: DateTime.parse(json["modified"]),
    banner: json["banner"],
    storeStatus: json["store_status"],
    storeMsg: json["store_msg"],
    homePageTitleStatus: json["home_page_title_status"],
    homePageTitle: json["home_page_title"],
    homePageSubtitleStatus: json["home_page_subtitle_status"],
    homePageSubtitle: json["home_page_subtitle"],
    homePageHeaderRight: json["home_page_header_right"],
    homePageDisplayNumber: json["home_page_display_number"],
    homePageDisplayNumberType: json["home_page_display_number_type"],
    gaKey: json["ga_key"],
    fbPixelKey: json["fb_pixel_key"],
    gaPixelKey: json["ga_pixel_key"],
    noCatHomePage: json["no_cat_home_page"],
    noProductHomePage: json["no_product_home_page"],
    productTitleHomePage: json["product_title_home_page"],
    mapDisplay: json["map_display"],
    reviewRatingDisplay: json["review_rating_display"],
    isEmailMandatoryPlaceorder: json["is_email_mandatory_placeorder"],
    displayStoreLogoName: json["display_store_logo_name"],
    cod: json["cod"],
    recommendedProducts: json["recommended_products"],
    deliverySlot: json["delivery_slot"],
    geofencing: json["geofencing"],
    loyality: json["loyality"],
    pickupFacility: json["pickup_facility"],
    deliveryFacility: json["delivery_facility"],
    inStore: json["in_store"],
    internationalOtp: json["international_otp"],
    multipleStore: json["multiple_store"],
    webMenuSetting: json["web_menu_setting"],
    mobileNotifications: json["mobile_notifications"],
    emailNotifications: json["email_notifications"],
    smsNotifications: json["sms_notifications"],
    gst: json["gst"],
    runnerManagement: json["runner_management"],
    gaCode: json["ga_code"],
    categoryLayout: json["category_layout"],
    deliveryArea: json["delivery_area"],
    radiusIn: json["radius_in"],
    productImage: json["product_image"],
    is24X7Open: json["is24x7_open"],
    openhoursFrom: json["openhours_from"],
    openhoursTo: json["openhours_to"],
    closehoursMessage: json["closehours_message"],
    storeOpenDays: json["store_open_days"],
    banners: List<dynamic>.from(json["banners"].map((x) => x)),
    webBanners: List<dynamic>.from(json["web_banners"].map((x) => x)),
    footerBanners: List<dynamic>.from(json["footer_banners"].map((x) => x)),
    aboutusBanner: List<dynamic>.from(json["aboutus_banner"].map((x) => x)),
    banner10080: json["banner_100_80"],
    banner300200: json["banner_300_200"],
    repeatOrder: json["repeat_order"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_id": brandId,
    "store_name": storeName,
    "location": location,
    "city": city,
    "state": state,
    "country": country,
    "timezone": timezone,
    "zipcode": zipcode,
    "lat": lat,
    "lng": lng,
    "contact_person": contactPerson,
    "contact_number": contactNumber,
    "contact_email": contactEmail,
    "about_us": aboutUs,
    "term_conditions": termConditions,
    "privacy_policy": privacyPolicy,
    "refund_policy": refundPolicy,
    "otp_skip": otpSkip,
    "version": version,
    "currency": currency,
    "show_currency": showCurrency,
    "app_share_link": appShareLink,
    "android_share_link": androidShareLink,
    "iphone_share_link": iphoneShareLink,
    "theme": theme,
    "web_theme": webTheme,
    "pwa_theme": pwaTheme,
    "type": type,
    "cat_type": catType,
    "store_logo": storeLogo,
    "preparation_time": preparationTime,
    "order_facilities": orderFacilities,
    "fav_icon": favIcon,
    "app_icon": appIcon,
    "banner_time": bannerTime,
    "web_cache": webCache,
    "sco_meta_title": scoMetaTitle,
    "sco_meta_description": scoMetaDescription,
    "sco_meta_keywords": scoMetaKeywords,
    "payment": payment,
    "payment_email_count": paymentEmailCount,
    "modified": modified.toIso8601String(),
    "banner": banner,
    "store_status": storeStatus,
    "store_msg": storeMsg,
    "home_page_title_status": homePageTitleStatus,
    "home_page_title": homePageTitle,
    "home_page_subtitle_status": homePageSubtitleStatus,
    "home_page_subtitle": homePageSubtitle,
    "home_page_header_right": homePageHeaderRight,
    "home_page_display_number": homePageDisplayNumber,
    "home_page_display_number_type": homePageDisplayNumberType,
    "ga_key": gaKey,
    "fb_pixel_key": fbPixelKey,
    "ga_pixel_key": gaPixelKey,
    "no_cat_home_page": noCatHomePage,
    "no_product_home_page": noProductHomePage,
    "product_title_home_page": productTitleHomePage,
    "map_display": mapDisplay,
    "review_rating_display": reviewRatingDisplay,
    "is_email_mandatory_placeorder": isEmailMandatoryPlaceorder,
    "display_store_logo_name": displayStoreLogoName,
    "cod": cod,
    "recommended_products": recommendedProducts,
    "delivery_slot": deliverySlot,
    "geofencing": geofencing,
    "loyality": loyality,
    "pickup_facility": pickupFacility,
    "delivery_facility": deliveryFacility,
    "in_store": inStore,
    "international_otp": internationalOtp,
    "multiple_store": multipleStore,
    "web_menu_setting": webMenuSetting,
    "mobile_notifications": mobileNotifications,
    "email_notifications": emailNotifications,
    "sms_notifications": smsNotifications,
    "gst": gst,
    "runner_management": runnerManagement,
    "ga_code": gaCode,
    "category_layout": categoryLayout,
    "delivery_area": deliveryArea,
    "radius_in": radiusIn,
    "product_image": productImage,
    "is24x7_open": is24X7Open,
    "openhours_from": openhoursFrom,
    "openhours_to": openhoursTo,
    "closehours_message": closehoursMessage,
    "store_open_days": storeOpenDays,
    "banners": List<dynamic>.from(banners.map((x) => x)),
    "web_banners": List<dynamic>.from(webBanners.map((x) => x)),
    "footer_banners": List<dynamic>.from(footerBanners.map((x) => x)),
    "aboutus_banner": List<dynamic>.from(aboutusBanner.map((x) => x)),
    "banner_100_80": banner10080,
    "banner_300_200": banner300200,
    "repeat_order": repeatOrder,
  };
}
