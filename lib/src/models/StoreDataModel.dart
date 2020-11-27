// To parse this JSON data, do
//
//     final storeDataModel = storeDataModelFromJson(jsonString);

import 'dart:convert';

class StoreDataModel {
  StoreDataModel({
    this.success,
    this.store,
  });

  bool success;
  StoreDataObj store;

  StoreDataModel copyWith({
    bool success,
    StoreDataObj store,
  }) =>
      StoreDataModel(
        success: success ?? this.success,
        store: store ?? this.store,
      );

  factory StoreDataModel.fromRawJson(String str) => StoreDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreDataModel.fromJson(Map<String, dynamic> json) => StoreDataModel(
    success: json["success"] == null ? null : json["success"],
    store: json["store"] == null ? null : StoreDataObj.fromJson(json["store"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success == null ? null : success,
    "store": store == null ? null : store.toJson(),
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
    this.version,
    this.currency,
    this.showCurrency,
    this.type,
    this.catType,
    this.storeLogo,
    this.preparationTime,
    this.orderFacilities,
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
  String version;
  String currency;
  String showCurrency;
  String type;
  String catType;
  String storeLogo;
  String preparationTime;
  String orderFacilities;
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
  dynamic mobileNotifications;
  dynamic emailNotifications;
  dynamic smsNotifications;
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

  StoreDataObj copyWith({
    String id,
    String brandId,
    String storeName,
    String location,
    String city,
    String state,
    String country,
    String timezone,
    String zipcode,
    String lat,
    String lng,
    String contactPerson,
    String contactNumber,
    String contactEmail,
    String aboutUs,
    String version,
    String currency,
    String showCurrency,
    String type,
    String catType,
    String storeLogo,
    String preparationTime,
    String orderFacilities,
    DateTime modified,
    String banner,
    String storeStatus,
    String storeMsg,
    bool homePageTitleStatus,
    String homePageTitle,
    bool homePageSubtitleStatus,
    String homePageSubtitle,
    String homePageHeaderRight,
    String homePageDisplayNumber,
    String homePageDisplayNumberType,
    String gaKey,
    String fbPixelKey,
    String gaPixelKey,
    String noCatHomePage,
    String noProductHomePage,
    String productTitleHomePage,
    String mapDisplay,
    String reviewRatingDisplay,
    String isEmailMandatoryPlaceorder,
    String displayStoreLogoName,
    String cod,
    String recommendedProducts,
    String deliverySlot,
    String geofencing,
    String loyality,
    String pickupFacility,
    String deliveryFacility,
    String inStore,
    String internationalOtp,
    String multipleStore,
    String webMenuSetting,
    dynamic mobileNotifications,
    dynamic emailNotifications,
    dynamic smsNotifications,
    String gst,
    String runnerManagement,
    String gaCode,
    String categoryLayout,
    String deliveryArea,
    String radiusIn,
    String productImage,
    String is24X7Open,
    String openhoursFrom,
    String openhoursTo,
    String closehoursMessage,
    String storeOpenDays,
    List<dynamic> banners,
    List<dynamic> webBanners,
    List<dynamic> footerBanners,
    List<dynamic> aboutusBanner,
    String banner10080,
    String banner300200,
    String repeatOrder,
  }) =>
      StoreDataObj(
        id: id ?? this.id,
        brandId: brandId ?? this.brandId,
        storeName: storeName ?? this.storeName,
        location: location ?? this.location,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
        timezone: timezone ?? this.timezone,
        zipcode: zipcode ?? this.zipcode,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        contactPerson: contactPerson ?? this.contactPerson,
        contactNumber: contactNumber ?? this.contactNumber,
        contactEmail: contactEmail ?? this.contactEmail,
        aboutUs: aboutUs ?? this.aboutUs,
        version: version ?? this.version,
        currency: currency ?? this.currency,
        showCurrency: showCurrency ?? this.showCurrency,
        type: type ?? this.type,
        catType: catType ?? this.catType,
        storeLogo: storeLogo ?? this.storeLogo,
        preparationTime: preparationTime ?? this.preparationTime,
        orderFacilities: orderFacilities ?? this.orderFacilities,
        modified: modified ?? this.modified,
        banner: banner ?? this.banner,
        storeStatus: storeStatus ?? this.storeStatus,
        storeMsg: storeMsg ?? this.storeMsg,
        homePageTitleStatus: homePageTitleStatus ?? this.homePageTitleStatus,
        homePageTitle: homePageTitle ?? this.homePageTitle,
        homePageSubtitleStatus: homePageSubtitleStatus ?? this.homePageSubtitleStatus,
        homePageSubtitle: homePageSubtitle ?? this.homePageSubtitle,
        homePageHeaderRight: homePageHeaderRight ?? this.homePageHeaderRight,
        homePageDisplayNumber: homePageDisplayNumber ?? this.homePageDisplayNumber,
        homePageDisplayNumberType: homePageDisplayNumberType ?? this.homePageDisplayNumberType,
        gaKey: gaKey ?? this.gaKey,
        fbPixelKey: fbPixelKey ?? this.fbPixelKey,
        gaPixelKey: gaPixelKey ?? this.gaPixelKey,
        noCatHomePage: noCatHomePage ?? this.noCatHomePage,
        noProductHomePage: noProductHomePage ?? this.noProductHomePage,
        productTitleHomePage: productTitleHomePage ?? this.productTitleHomePage,
        mapDisplay: mapDisplay ?? this.mapDisplay,
        reviewRatingDisplay: reviewRatingDisplay ?? this.reviewRatingDisplay,
        isEmailMandatoryPlaceorder: isEmailMandatoryPlaceorder ?? this.isEmailMandatoryPlaceorder,
        displayStoreLogoName: displayStoreLogoName ?? this.displayStoreLogoName,
        cod: cod ?? this.cod,
        recommendedProducts: recommendedProducts ?? this.recommendedProducts,
        deliverySlot: deliverySlot ?? this.deliverySlot,
        geofencing: geofencing ?? this.geofencing,
        loyality: loyality ?? this.loyality,
        pickupFacility: pickupFacility ?? this.pickupFacility,
        deliveryFacility: deliveryFacility ?? this.deliveryFacility,
        inStore: inStore ?? this.inStore,
        internationalOtp: internationalOtp ?? this.internationalOtp,
        multipleStore: multipleStore ?? this.multipleStore,
        webMenuSetting: webMenuSetting ?? this.webMenuSetting,
        mobileNotifications: mobileNotifications ?? this.mobileNotifications,
        emailNotifications: emailNotifications ?? this.emailNotifications,
        smsNotifications: smsNotifications ?? this.smsNotifications,
        gst: gst ?? this.gst,
        runnerManagement: runnerManagement ?? this.runnerManagement,
        gaCode: gaCode ?? this.gaCode,
        categoryLayout: categoryLayout ?? this.categoryLayout,
        deliveryArea: deliveryArea ?? this.deliveryArea,
        radiusIn: radiusIn ?? this.radiusIn,
        productImage: productImage ?? this.productImage,
        is24X7Open: is24X7Open ?? this.is24X7Open,
        openhoursFrom: openhoursFrom ?? this.openhoursFrom,
        openhoursTo: openhoursTo ?? this.openhoursTo,
        closehoursMessage: closehoursMessage ?? this.closehoursMessage,
        storeOpenDays: storeOpenDays ?? this.storeOpenDays,
        banners: banners ?? this.banners,
        webBanners: webBanners ?? this.webBanners,
        footerBanners: footerBanners ?? this.footerBanners,
        aboutusBanner: aboutusBanner ?? this.aboutusBanner,
        banner10080: banner10080 ?? this.banner10080,
        banner300200: banner300200 ?? this.banner300200,
        repeatOrder: repeatOrder ?? this.repeatOrder,
      );

  factory StoreDataObj.fromRawJson(String str) => StoreDataObj.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreDataObj.fromJson(Map<String, dynamic> json) => StoreDataObj(
    id: json["id"] == null ? null : json["id"],
    brandId: json["brand_id"] == null ? null : json["brand_id"],
    storeName: json["store_name"] == null ? null : json["store_name"],
    location: json["location"] == null ? null : json["location"],
    city: json["city"] == null ? null : json["city"],
    state: json["state"] == null ? null : json["state"],
    country: json["country"] == null ? null : json["country"],
    timezone: json["timezone"] == null ? null : json["timezone"],
    zipcode: json["zipcode"] == null ? null : json["zipcode"],
    lat: json["lat"] == null ? null : json["lat"],
    lng: json["lng"] == null ? null : json["lng"],
    contactPerson: json["contact_person"] == null ? null : json["contact_person"],
    contactNumber: json["contact_number"] == null ? null : json["contact_number"],
    contactEmail: json["contact_email"] == null ? null : json["contact_email"],
    aboutUs: json["about_us"] == null ? null : json["about_us"],
    version: json["version"] == null ? null : json["version"],
    currency: json["currency"] == null ? null : json["currency"],
    showCurrency: json["show_currency"] == null ? null : json["show_currency"],
    type: json["type"] == null ? null : json["type"],
    catType: json["cat_type"] == null ? null : json["cat_type"],
    storeLogo: json["store_logo"] == null ? null : json["store_logo"],
    preparationTime: json["preparation_time"] == null ? null : json["preparation_time"],
    orderFacilities: json["order_facilities"] == null ? null : json["order_facilities"],
    modified: json["modified"] == null ? null : DateTime.parse(json["modified"]),
    banner: json["banner"] == null ? null : json["banner"],
    storeStatus: json["store_status"] == null ? null : json["store_status"],
    storeMsg: json["store_msg"] == null ? null : json["store_msg"],
    homePageTitleStatus: json["home_page_title_status"] == null ? null : json["home_page_title_status"],
    homePageTitle: json["home_page_title"] == null ? null : json["home_page_title"],
    homePageSubtitleStatus: json["home_page_subtitle_status"] == null ? null : json["home_page_subtitle_status"],
    homePageSubtitle: json["home_page_subtitle"] == null ? null : json["home_page_subtitle"],
    homePageHeaderRight: json["home_page_header_right"] == null ? null : json["home_page_header_right"],
    homePageDisplayNumber: json["home_page_display_number"] == null ? null : json["home_page_display_number"],
    homePageDisplayNumberType: json["home_page_display_number_type"] == null ? null : json["home_page_display_number_type"],
    gaKey: json["ga_key"] == null ? null : json["ga_key"],
    fbPixelKey: json["fb_pixel_key"] == null ? null : json["fb_pixel_key"],
    gaPixelKey: json["ga_pixel_key"] == null ? null : json["ga_pixel_key"],
    noCatHomePage: json["no_cat_home_page"] == null ? null : json["no_cat_home_page"],
    noProductHomePage: json["no_product_home_page"] == null ? null : json["no_product_home_page"],
    productTitleHomePage: json["product_title_home_page"] == null ? null : json["product_title_home_page"],
    mapDisplay: json["map_display"] == null ? null : json["map_display"],
    reviewRatingDisplay: json["review_rating_display"] == null ? null : json["review_rating_display"],
    isEmailMandatoryPlaceorder: json["is_email_mandatory_placeorder"] == null ? null : json["is_email_mandatory_placeorder"],
    displayStoreLogoName: json["display_store_logo_name"] == null ? null : json["display_store_logo_name"],
    cod: json["cod"] == null ? null : json["cod"],
    recommendedProducts: json["recommended_products"] == null ? null : json["recommended_products"],
    deliverySlot: json["delivery_slot"] == null ? null : json["delivery_slot"],
    geofencing: json["geofencing"] == null ? null : json["geofencing"],
    loyality: json["loyality"] == null ? null : json["loyality"],
    pickupFacility: json["pickup_facility"] == null ? null : json["pickup_facility"],
    deliveryFacility: json["delivery_facility"] == null ? null : json["delivery_facility"],
    inStore: json["in_store"] == null ? null : json["in_store"],
    internationalOtp: json["international_otp"] == null ? null : json["international_otp"],
    multipleStore: json["multiple_store"] == null ? null : json["multiple_store"],
    webMenuSetting: json["web_menu_setting"] == null ? null : json["web_menu_setting"],
    mobileNotifications: json["mobile_notifications"] == null ? null : json["mobile_notifications"],
    emailNotifications: json["email_notifications"] == null ? null : json["email_notifications"],
    smsNotifications: json["sms_notifications"] == null ? null : json["sms_notifications"],
    gst: json["gst"] == null ? null : json["gst"],
    runnerManagement: json["runner_management"] == null ? null : json["runner_management"],
    gaCode: json["ga_code"] == null ? null : json["ga_code"],
    categoryLayout: json["category_layout"] == null ? null : json["category_layout"],
    deliveryArea: json["delivery_area"] == null ? null : json["delivery_area"],
    radiusIn: json["radius_in"] == null ? null : json["radius_in"],
    productImage: json["product_image"] == null ? null : json["product_image"],
    is24X7Open: json["is24x7_open"] == null ? null : json["is24x7_open"],
    openhoursFrom: json["openhours_from"] == null ? null : json["openhours_from"],
    openhoursTo: json["openhours_to"] == null ? null : json["openhours_to"],
    closehoursMessage: json["closehours_message"] == null ? null : json["closehours_message"],
    storeOpenDays: json["store_open_days"] == null ? null : json["store_open_days"],
    banners: json["banners"] == null ? null : List<dynamic>.from(json["banners"].map((x) => x)),
    webBanners: json["web_banners"] == null ? null : List<dynamic>.from(json["web_banners"].map((x) => x)),
    footerBanners: json["footer_banners"] == null ? null : List<dynamic>.from(json["footer_banners"].map((x) => x)),
    aboutusBanner: json["aboutus_banner"] == null ? null : List<dynamic>.from(json["aboutus_banner"].map((x) => x)),
    banner10080: json["banner_100_80"] == null ? null : json["banner_100_80"],
    banner300200: json["banner_300_200"] == null ? null : json["banner_300_200"],
    repeatOrder: json["repeat_order"] == null ? null : json["repeat_order"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "brand_id": brandId == null ? null : brandId,
    "store_name": storeName == null ? null : storeName,
    "location": location == null ? null : location,
    "city": city == null ? null : city,
    "state": state == null ? null : state,
    "country": country == null ? null : country,
    "timezone": timezone == null ? null : timezone,
    "zipcode": zipcode == null ? null : zipcode,
    "lat": lat == null ? null : lat,
    "lng": lng == null ? null : lng,
    "contact_person": contactPerson == null ? null : contactPerson,
    "contact_number": contactNumber == null ? null : contactNumber,
    "contact_email": contactEmail == null ? null : contactEmail,
    "about_us": aboutUs == null ? null : aboutUs,
    "version": version == null ? null : version,
    "currency": currency == null ? null : currency,
    "show_currency": showCurrency == null ? null : showCurrency,
    "type": type == null ? null : type,
    "cat_type": catType == null ? null : catType,
    "store_logo": storeLogo == null ? null : storeLogo,
    "preparation_time": preparationTime == null ? null : preparationTime,
    "order_facilities": orderFacilities == null ? null : orderFacilities,
    "modified": modified == null ? null : modified.toIso8601String(),
    "banner": banner == null ? null : banner,
    "store_status": storeStatus == null ? null : storeStatus,
    "store_msg": storeMsg == null ? null : storeMsg,
    "home_page_title_status": homePageTitleStatus == null ? null : homePageTitleStatus,
    "home_page_title": homePageTitle == null ? null : homePageTitle,
    "home_page_subtitle_status": homePageSubtitleStatus == null ? null : homePageSubtitleStatus,
    "home_page_subtitle": homePageSubtitle == null ? null : homePageSubtitle,
    "home_page_header_right": homePageHeaderRight == null ? null : homePageHeaderRight,
    "home_page_display_number": homePageDisplayNumber == null ? null : homePageDisplayNumber,
    "home_page_display_number_type": homePageDisplayNumberType == null ? null : homePageDisplayNumberType,
    "ga_key": gaKey == null ? null : gaKey,
    "fb_pixel_key": fbPixelKey == null ? null : fbPixelKey,
    "ga_pixel_key": gaPixelKey == null ? null : gaPixelKey,
    "no_cat_home_page": noCatHomePage == null ? null : noCatHomePage,
    "no_product_home_page": noProductHomePage == null ? null : noProductHomePage,
    "product_title_home_page": productTitleHomePage == null ? null : productTitleHomePage,
    "map_display": mapDisplay == null ? null : mapDisplay,
    "review_rating_display": reviewRatingDisplay == null ? null : reviewRatingDisplay,
    "is_email_mandatory_placeorder": isEmailMandatoryPlaceorder == null ? null : isEmailMandatoryPlaceorder,
    "display_store_logo_name": displayStoreLogoName == null ? null : displayStoreLogoName,
    "cod": cod == null ? null : cod,
    "recommended_products": recommendedProducts == null ? null : recommendedProducts,
    "delivery_slot": deliverySlot == null ? null : deliverySlot,
    "geofencing": geofencing == null ? null : geofencing,
    "loyality": loyality == null ? null : loyality,
    "pickup_facility": pickupFacility == null ? null : pickupFacility,
    "delivery_facility": deliveryFacility == null ? null : deliveryFacility,
    "in_store": inStore == null ? null : inStore,
    "international_otp": internationalOtp == null ? null : internationalOtp,
    "multiple_store": multipleStore == null ? null : multipleStore,
    "web_menu_setting": webMenuSetting == null ? null : webMenuSetting,
    "mobile_notifications": mobileNotifications == null ? null : mobileNotifications,
    "email_notifications": emailNotifications == null ? null : emailNotifications,
    "sms_notifications": smsNotifications == null ? null : smsNotifications,
    "gst": gst == null ? null : gst,
    "runner_management": runnerManagement == null ? null : runnerManagement,
    "ga_code": gaCode == null ? null : gaCode,
    "category_layout": categoryLayout == null ? null : categoryLayout,
    "delivery_area": deliveryArea == null ? null : deliveryArea,
    "radius_in": radiusIn == null ? null : radiusIn,
    "product_image": productImage == null ? null : productImage,
    "is24x7_open": is24X7Open == null ? null : is24X7Open,
    "openhours_from": openhoursFrom == null ? null : openhoursFrom,
    "openhours_to": openhoursTo == null ? null : openhoursTo,
    "closehours_message": closehoursMessage == null ? null : closehoursMessage,
    "store_open_days": storeOpenDays == null ? null : storeOpenDays,
    "banners": banners == null ? null : List<dynamic>.from(banners.map((x) => x)),
    "web_banners": webBanners == null ? null : List<dynamic>.from(webBanners.map((x) => x)),
    "footer_banners": footerBanners == null ? null : List<dynamic>.from(footerBanners.map((x) => x)),
    "aboutus_banner": aboutusBanner == null ? null : List<dynamic>.from(aboutusBanner.map((x) => x)),
    "banner_100_80": banner10080 == null ? null : banner10080,
    "banner_300_200": banner300200 == null ? null : banner300200,
    "repeat_order": repeatOrder == null ? null : repeatOrder,
  };
}
