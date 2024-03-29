import 'dart:convert';
import 'dart:io';

import 'package:compressimage/compressimage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:restroapp/src/Screens/LoginSignUp/ForgotPasswordScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginMobileScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/OtpScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/RegisterScreen.dart';
import 'package:restroapp/src/apihandler/ApiConstants.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/AdminLoginModel.dart';
import 'package:restroapp/src/models/BannerResponse.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/CancelOrderModel.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/Categorys.dart';
import 'package:restroapp/src/models/OnlineMembershipResponse.dart';
import 'package:restroapp/src/models/CreateOrderData.dart';
import 'package:restroapp/src/models/CreatePaytmTxnTokenResponse.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/DeliveryTimeSlotModel.dart';
import 'package:restroapp/src/models/DeviceInfo.dart';
import 'package:restroapp/src/models/DynamicResponse.dart';
import 'package:restroapp/src/models/FAQModel.dart';
import 'package:restroapp/src/models/FacebookModel.dart';
import 'package:restroapp/src/models/GetOrderHistory.dart';
import 'package:restroapp/src/models/HtmlModelResponse.dart';
import 'package:restroapp/src/models/IpayOrderData.dart';
import 'package:restroapp/src/models/LogoutResponse.dart';
import 'package:restroapp/src/models/LoyalityPointsModel.dart';
import 'package:restroapp/src/models/PeachPayCheckOutResponse.dart';
import 'package:restroapp/src/models/PeachPayVerifyResponse.dart';
import 'package:restroapp/src/models/PhonePeResponse.dart';
import 'package:restroapp/src/models/PhonePeVerifyResponse.dart';
import 'package:restroapp/src/models/StorelatlngsResponse.dart';
import 'package:restroapp/src/models/MembershipPlanResponse.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/NotificationResponseModel.dart';
import 'package:restroapp/src/models/OTPVerified.dart';
import 'package:restroapp/src/models/OnlineMembershipResponse.dart';
import 'package:restroapp/src/models/PeachPayCheckOutResponse.dart';
import 'package:restroapp/src/models/PeachPayVerifyResponse.dart';
import 'package:restroapp/src/models/PickUpModel.dart';
import 'package:restroapp/src/models/ProductRatingResponse.dart';
import 'package:restroapp/src/models/RazorpayOrderData.dart';
import 'package:restroapp/src/models/RecommendedProductsResponse.dart';
import 'package:restroapp/src/models/ReferEarnData.dart';
import 'package:restroapp/src/models/SearchTagsModel.dart';
import 'package:restroapp/src/models/RazorPayTopUP.dart';
import 'package:restroapp/src/models/SocialModel.dart';
import 'package:restroapp/src/models/SellOptionResponse.dart';
import 'package:restroapp/src/models/StoreAreaResponse.dart';
import 'package:restroapp/src/models/StoreBranchesModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoreDeliveryAreasResponse.dart';
import 'package:restroapp/src/models/StoreOffersResponse.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StorelatlngsResponse.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/StripeCheckOutModel.dart';
import 'package:restroapp/src/models/StripeVerifyModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TagsModel.dart';
import 'package:restroapp/src/models/TaxCalulationResponse.dart';
import 'package:restroapp/src/models/UserPurchaseMembershipResponse.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/StoreDeliveryAreasResponse.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StoreOffersResponse.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TaxCalulationResponse.dart';
import 'package:restroapp/src/models/ValidateCouponsResponse.dart';
import 'package:restroapp/src/models/GetOrderHistory.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/models/WalletModel.dart';
import 'package:restroapp/src/models/WalletOnlineTopUp.dart';
import 'package:restroapp/src/models/forgotPassword/GetForgotPwdData.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiController {
  static final int timeout = 18;

  static Future<StoreResponse> versionApiRequest(String storeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", storeId) +
        ApiConstants.version;

    print("----url--${url}");
    try {
      FormData formData = new FormData.fromMap({
        "device_id": deviceId,
        "device_token": "${deviceToken}",
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      StoreResponse storeData =
          StoreResponse.fromJson(json.decode(response.data));
      print("-------store.success ---${storeData.success}");
      SharedPrefs.saveStore(storeData.store);
      //check older version
      String version = await SharedPrefs.getAPiDetailsVersion();
      print("older version is $version");
      if (version != storeData.store.version) {
        //TODO: store version saved
        print(
            "version not matched older version is $version and new version is ${storeData.store.version}.");
        SharedPrefs.saveAPiDetailsVersion(storeData.store.version);
        DatabaseHelper databaseHelper = DatabaseHelper();
        databaseHelper.clearDataBase();
      }

      return storeData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<BrandVersionModel> getBrandVersion() async {
    var url = ApiConstants.baseUrl2.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.brandVersion;

    var request = new http.MultipartRequest("GET", Uri.parse(url));
    print("----url---${url}");
    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----url---${url}");
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);
      BrandVersionModel storeArea = BrandVersionModel.fromJson(parsed);

      return storeArea;
    } catch (e) {
      print("--allStores--catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<CategoriesModel> categoriesApiRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.baseUrl2.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.homescreenCategories;

    print("----url--${url}");
    try {
      FormData formData = new FormData.fromMap({
        "device_id": deviceId,
        "device_token": "${deviceToken}",
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      CategoriesModel storeData =
          CategoriesModel.fromJson(json.decode(response.data));
      print("-------categoriesModel ---${storeData.success}");

      return storeData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<TagsModel> tagsApiRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.baseUrl2.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.homescreenTags;

    print("----url--${url}");
    try {
      FormData formData = new FormData.fromMap({
        "device_id": deviceId,
        "device_token": "${deviceToken}",
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      TagsModel storeData = TagsModel.fromJson(json.decode(response.data));
      print("-------tagsApiRequest ---${storeData.success}");

      return storeData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<StoresModel> getAllStores({Map<String, dynamic> params}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.baseUrl2.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.allStores;

    params.putIfAbsent("device_id", () => "deviceId");
    params.putIfAbsent("device_token", () => "${deviceToken}");
    params.putIfAbsent("platform", () => Platform.isIOS ? "IOS" : "Android");
    print("----url--${url}");

    try {
      FormData formData = new FormData.fromMap(params
          /*{
        "device_id": deviceId,
        "device_token": "${deviceToken}",
        "platform": Platform.isIOS ? "IOS" : "Android"
      }*/
          );
      print(formData.fields.toString());
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      StoresModel storeData = StoresModel.fromJson(json.decode(response.data));
      print("-------getAllStores ---${storeData.success}");

      return storeData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static String getQueryParams(LatLng initialPosition) {
    if (initialPosition != null) {
      String location =
          "?lat=${initialPosition.latitude}&lng=${initialPosition.longitude}";
      return location;
    } else
      return '';
  }

  static Future<StoresModel> storesApiRequest(LatLng initialPosition) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.baseUrl2.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.homescreenStores +
        getQueryParams(initialPosition);
    print("----url--${url}");
    try {
      FormData formData = new FormData.fromMap({
        "device_id": deviceId,
        "device_token": "${deviceToken}",
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      StoresModel storeData = StoresModel.fromJson(json.decode(response.data));
      print("-------StoresModel ---${storeData.success}");

      return storeData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<StoreDataModel> getStoreVersionData(String storeId) async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeId) +
        ApiConstants.store_configuration;

    var request = new http.MultipartRequest("GET", Uri.parse(url));
    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----url---${url}");
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);
      StoreDataModel storeArea = StoreDataModel.fromJson(parsed);
      return storeArea;
    } catch (e) {
      print("--allStores--catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<UserResponse> registerApiRequest(
      UserData user, String referralCode) async {
    //StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.signUp;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "full_name": user.name,
        "phone": user.phone,
        "email": user.email,
        "password": user.password,
        "device_id": deviceId,
        "device_token": deviceToken,
        "user_refer_code": referralCode,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      final parsed = json.decode(respStr);
      UserResponse userResponse = UserResponse.fromJson(parsed);
      if (userResponse.success) {
        //SharedPrefs.setUserLoggedIn(true);
        SharedPrefs.saveUser(userResponse.user);
      }
      Utils.showToast(userResponse.message, true);
      return userResponse;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<UserResponse> loginApiRequest(
      String username, String password) async {
    //StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.login;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    var deviceInfoJson = DeviceInfo.getInstance().getInfo();
    try {
      request.fields.addAll({
        "email": username,
        "password": password,
        "device_id": deviceId,
        "device_token": deviceToken,
        "device_info": deviceInfoJson,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      final parsed = json.decode(respStr);
      print(parsed);
      UserResponse userResponse = UserResponse.fromJson(parsed);
      if (userResponse.success) {
        SharedPrefs.setUserLoggedIn(true);
        SharedPrefs.saveUser(userResponse.user);
      }
      //Utils.showToast(userResponse.message ?? "User loggedin successfully", true);
      return userResponse;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<GetForgotPwdData> forgotPasswordApiRequest(
      ForgotPasswordData forgotPasswordData) async {
    //StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);

    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.forgetPassword;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "email_id": forgotPasswordData.email,
        /*     "device_id": deviceId,
        "device_token": "",
        "platform": Platform.isIOS ? "IOS" : "Android"*/
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('---forgotPassword--${respStr}');
      final parsed = json.decode(respStr);
      GetForgotPwdData userResponse = GetForgotPwdData.fromJson(parsed);
      //Utils.showToast(userResponse.message, true);
      return userResponse;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<CategoryResponse> getCategoriesApiRequest(
      String storeId) async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeId) +
        ApiConstants.getCategories;
    CategoryResponse categoryResponse = CategoryResponse();

    try {
      bool isNetworkAviable = await Utils.isNetworkAvailable();
      if (isNetworkAviable) {
        print("catttttt  $url");
        Response response = await Dio()
            .get(url, options: new Options(responseType: ResponseType.plain));
        //print(response);
        categoryResponse =
            CategoryResponse.fromJson(json.decode(response.data));
        //print("-------Categories.length ---${categoryResponse.categories.length}");
      } else if (!isNetworkAviable) {
        categoryResponse.success = false;
        return categoryResponse;
      } else {
        print("database has values");
        //prepare model object
        categoryResponse.success = false;
      }
    } catch (e) {
      print(e);
    }
    return categoryResponse;
  }

  static Future<SubCategoryResponse> getSubCategoryProducts(
      String subCategoryId,
      {StoreDataObj store}) async {
    SubCategoryResponse subCategoryResponse = SubCategoryResponse();
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAviable) {
//        StoreModel store = await SharedPrefs.getStore();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceId = prefs.getString(AppConstant.deviceId);
        print("deviceID $deviceId");
        String deviceToken = prefs.getString(AppConstant.deviceToken);
        print("deviceToken $deviceToken");

        var url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
            ApiConstants.getProducts +
            subCategoryId;
        print(url);
        FormData formData = new FormData.fromMap({
          "user_id": "",
          "device_id": deviceId,
          "device_token": deviceToken,
          "platform": Platform.isIOS ? "IOS" : "Android"
        });
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(
                contentType: "application/json",
                responseType: ResponseType.plain));
        print("this is responseeee $response");
        subCategoryResponse =
            SubCategoryResponse.fromJson(json.decode(response.data));
        return subCategoryResponse;
      } else if (!isNetworkAviable) {
        subCategoryResponse.success = false;
        return subCategoryResponse;
      } else {
        subCategoryResponse.success = false;
        return subCategoryResponse;
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<SubCategoryResponse> getSubCategoryProductDetail(
      String productID, String storeId) async {
    SubCategoryResponse subCategoryResponse = SubCategoryResponse();
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAviable) {
//        StoreDataObj store = await SharedPrefs.getStoreData();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceId = prefs.getString(AppConstant.deviceId);
        print("deviceID $deviceId");
        String deviceToken = prefs.getString(AppConstant.deviceToken);
        print("deviceToken $deviceToken");

        var url = ApiConstants.baseUrl3.replaceAll("storeId", storeId) +
            ApiConstants.getProductDetail +
            productID;
        print(url);
        FormData formData = new FormData.fromMap({
          "user_id": "",
          "device_id": deviceId,
          "device_token": deviceToken,
          "platform": Platform.isIOS ? "IOS" : "Android",
          "product_id": productID
        });
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(
                contentType: "application/json",
                responseType: ResponseType.plain));
        print(response.data);
        subCategoryResponse =
            SubCategoryResponse.fromJson(json.decode(response.data));
        if (subCategoryResponse.success) {
          return subCategoryResponse;
        } else
          return null;
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<DeliveryAddressResponse> getAddressApiRequest() async {
//    StoreDataObj store = await SharedPrefs.getStoreData();
    UserModel user = await SharedPrefs.getUser();

    var url = ApiConstants.baseUrl3.replaceAll("storeId", "delivery_zones") +
        ApiConstants.getAddress;
    print("----url--${url}");
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll({
        "user_id": user.id,
        "method": "GET",
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("-1--getAddress-respStr---${respStr}");
      final parsed = json.decode(respStr);
      DeliveryAddressResponse deliveryAddressResponse =
          DeliveryAddressResponse.fromJson(parsed);
      //print("----respStr---${deliveryAddressResponse.success}");
      return deliveryAddressResponse;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<StoreDeliveryAreasResponse> getDeliveryArea() async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.getAddressArea;

    var request = new http.MultipartRequest("GET", Uri.parse(url));
    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----url---${url}");
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);
      StoreDeliveryAreasResponse storeArea =
          StoreDeliveryAreasResponse.fromJson(parsed);
      return storeArea;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<StoreAreaResponse> getStoreAreaApiRequest() async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.getStoreArea;

    var request = new http.MultipartRequest("GET", Uri.parse(url));
    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----url---${url}");
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);
      StoreAreaResponse storeArea = StoreAreaResponse.fromJson(parsed);
      return storeArea;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<PickUpModel> getStorePickupAddress() async {
    StoreDataObj store = await SharedPrefs.getStoreData();
    var url = ApiConstants.baseUrl3.replaceAll("storeId", '') +
        ApiConstants.getStorePickupAddress;

    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.fields.addAll({
      "store_id": store.id,
      "method": "POST",
    });
    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----url---${url}");
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);
      PickUpModel storeArea = PickUpModel.fromJson(parsed);
      return storeArea;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<DeliveryAddressResponse> saveDeliveryAddressApiRequest(
      String method,
      String firstName,
      String lastName,
      String mobile,
      String email,
      String address,
      String city,
      String state,
      String zipCode,
      String lat,
      String lng,
      String address_type,
      String address_id,
      {String address2 = '',
      String setDefaultAddress}) async {
    UserModel user = await SharedPrefs.getUser();

    var url = ApiConstants.baseUrl3.replaceAll("storeId", "delivery_zones") +
        ApiConstants.getAddress;

    print(url);

    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "method": method, //
        "user_id": user.id, //
        "first_name": firstName,
        "last_name": lastName,
        "mobile": mobile,
        "email": email,
        "address": address,
        "address2": address2,
        "city": "${city}",
        "state": "${state}",
        "zipcode": zipCode,
        "country": "",
        "lat": "${lat}",
        "lng": "${lng}",
        "address_type": address_type,
        "set_default_address": setDefaultAddress,
      });

      if (method == "EDIT") {
        request.fields.addAll({
          "address_id": address_id,
        });
      }

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      print("-getAddress--respStr>---${respStr}");

      final parsed = json.decode(respStr);

      DeliveryAddressResponse res = DeliveryAddressResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<DeliveryAddressResponse> deleteDeliveryAddressApiRequest(
      String addressId) async {
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.baseUrl3.replaceAll("storeId", "delivery_zones") +
        ApiConstants.getAddress;

    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "method": "DELETE",
        "device_id": deviceId,
        "user_id": user.id,
        "address_id": addressId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      final parsed = json.decode(respStr);
      print("---respStr>---${respStr}");
      DeliveryAddressResponse res = DeliveryAddressResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<StoreOffersResponse> storeOffersApiRequest(String areaId,
      {bool isComingFromPickUpScreen = false}) async {
    StoreDataObj store = await SharedPrefs.getStoreData();
    UserModelMobile user = await SharedPrefs.getUserMobile();

    var url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
        ApiConstants.storeOffers;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "store_id": store.id,
        "user_id": user.id,
        "order_facility": isComingFromPickUpScreen ? "PickUp" : "Delivery"
      });

      if (areaId != null) {
        request.fields["area_id"] = areaId;
      }
      print("----url---${url}");
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      final parsed = json.decode(respStr);
      print("----respStr---${respStr}");
      StoreOffersResponse res = StoreOffersResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<ValidateCouponResponse> validateOfferApiRequest(
      String couponCode,
      String paymentMode,
      String orderJson,
      String coupon_type,
      String orderFacilities) async {
    StoreDataObj store = await SharedPrefs.getStoreData();
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
        ApiConstants.coupons_validate;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print("----url---${url}");
    try {
      request.fields.addAll({
        "coupon_code": couponCode,
        "coupon_type": coupon_type,
        "device_id": deviceId,
        "user_id": user.id,
        "device_token": deviceToken,
        "orders": "$orderJson",
        "order_facilities": orderFacilities,
        "payment_method": paymentMode,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });

      print("----url---${request.fields.toString()}");
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);
      ValidateCouponResponse model = ValidateCouponResponse.fromJson(parsed);
      return model;
    } catch (e) {
      print("----respStr---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<TaxCalculationResponse> multipleTaxCalculationRequest(
      String couponCode, String discount, String shipping, String orderJson,
      {String couponType = '', String isMembershipCouponEnabled = '0'}) async {
    StoreDataObj store = await SharedPrefs.getStoreData();
    UserModel user = await SharedPrefs.getUser();
    WalletModel userWallet = await SharedPrefs.getUserWallet();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);

    var url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
        ApiConstants.multipleTaxCalculation_2;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print("----url---${url}");
    //print("----orderJson---${orderJson}");
    print("--discount-${discount}");
    try {
      request.fields.addAll({
        "fixed_discount_amount": "${discount}",
        "tax": "0",
        "user_id": user.id,
        "discount": "0",
        "shipping": shipping,
        "user_wallet": userWallet == null ? "0" : userWallet.data.userWallet,
        "order_detail": orderJson,
        "device_id": deviceId,
        "coupon_code": couponCode.toString(),
        "is_membership_coupon_enabled": isMembershipCouponEnabled
      });
      print("--fields---${request.fields.toString()}");
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("--Tax--respStr---${respStr}");
      final parsed = json.decode(respStr);

      TaxCalculationResponse model =
          TaxCalculationResponse.fromJson(couponCode, couponType, parsed);
      return model;
    } catch (e) {
      print("--multipleTax--respStr---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<ResponseModel> placeOrderRequest(
      String shipping_charges,
      String note,
      String totalPrice,
      String paymentMethod,
      TaxCalculationModel taxModel,
      DeliveryAddressData address,
      String orderJson,
      bool isComingFromPickUpScreen,
      String areaId,
      OrderType deliveryType,
      String razorpay_order_id,
      String razorpay_payment_id,
      String online_method,
      String selectedDeliverSlotValue,
      {String cart_saving = "0.00",
      String posBranchCode = '',
      String membershipPlanDetailId = '',
      String membershipId = '',
      String additionalInfo = '',
      String isMembershipCouponEnabled = '0',String walletRefund="0"}) async {
    StoreDataObj store = await SharedPrefs.getStoreData();
    UserModelMobile user = await SharedPrefs.getUserMobile();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    String orderFacility = deliveryType == OrderType.Delivery
        ? 'Delivery'
        : deliveryType == OrderType.PickUp
            ? 'PickUp'
            : 'DineIn';
    var url;
    if (deliveryType == OrderType.Delivery) {
      url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
          ApiConstants.placeOrder;
    } else if (deliveryType == OrderType.PickUp ||
        deliveryType == OrderType.DineIn) {
      url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
          ApiConstants.pickupPlaceOrder;
    }
    String storeAddress = "";
    try {
      storeAddress = "${store.storeName}, ${store.location},"
          "${store.city}, ${store.state}, ${store.country}, ${store.zipcode}";
      print("storeAddress= ${storeAddress}");
    } catch (e) {
      print(e);
    }

    /*var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.placeOrder;*/
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    //print("==orderJson==${orderJson}====");
    String encodedtaxDetail = "[]";
    String encodedtaxLabel = "[]";
    String encodedFixedTax = "[]";
    try {
      /*print("fixedTax= ${taxModel.fixedTax}");
      print("taxLabel= ${taxModel.taxLabel}");
      print("taxDetail= ${taxModel.taxDetail}");*/

      try {
        List jsonfixedTaxList =
            taxModel.fixedTax.map((fixedTax) => fixedTax.toJson()).toList();
        encodedFixedTax = jsonEncode(jsonfixedTaxList);
        //print("encodedFixedTax= ${encodedFixedTax}");
      } catch (e) {
        print(e);
      }

      try {
        List jsontaxDetailList =
            taxModel.taxDetail.map((taxDetail) => taxDetail.toJson()).toList();
        encodedtaxDetail = jsonEncode(jsontaxDetailList);
        //print("encodedtaxDetail= ${encodedtaxDetail}");
      } catch (e) {
        print(e);
      }

      try {
        List jsontaxLabelList =
            taxModel.taxLabel.map((taxLabel) => taxLabel.toJson()).toList();
        encodedtaxLabel = jsonEncode(jsontaxLabelList);
        //print("encodedtaxLabel= ${encodedtaxLabel}");
      } catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
    String checkOutPrice =
        double.parse(taxModel.itemSubTotal) > 0 || posBranchCode.isNotEmpty
            ? taxModel.itemSubTotal
            : '0';
    String total = double.parse(taxModel.total) > 0 || posBranchCode.isNotEmpty
        ? taxModel.total
        : '0';
    try {
      request.fields.addAll({
        "shipping_charges": "${taxModel.shipping}",
        "note": note,
        "calculated_tax_detail": "",
        "wallet_refund": walletRefund,
        "coupon_code": taxModel == null ? "" : '${taxModel.couponCode}',
        "device_id": deviceId,
        "user_address": isComingFromPickUpScreen == true
            ? storeAddress
            : address.address2 != null && address.address2.trim().isNotEmpty
                ? '${address.address != null && address.address.trim().isNotEmpty ? '${address.address}, ${address.address2}' : "${address.address2}"}'
                : address.address,
        "store_fixed_tax_detail": "",
        "tax": taxModel == null ? "0" : '${taxModel.tax}',
        "store_tax_rate_detail": "",
        "platform": Platform.isIOS ? "IOS" : "Android",
        "tax_rate": "0",
        "total": /*taxModel == null ? '${totalPrice}' : */ '${total}',
        "user_id": user.id,
        "device_token": deviceToken,
        "user_address_id":
            isComingFromPickUpScreen == true ? '0' /*areaId*/ : address.id,
        "orders": orderJson,
        "checkout": "${checkOutPrice}",
        "payment_method": paymentMethod == "2" ? "COD" : "online",
        "discount": taxModel == null ? "" : '${taxModel.discount}',
        "payment_request_id": razorpay_order_id,
        "payment_id": razorpay_payment_id,
        "online_method": online_method,
        "delivery_time_slot": selectedDeliverSlotValue,
        "store_fixed_tax_detail": encodedFixedTax,
        "store_tax_rate_detail": encodedtaxLabel,
        "calculated_tax_detail": encodedtaxDetail,
        "cart_saving": cart_saving,
        "pos_branch_code": posBranchCode,
        "membership_plan_detail_id": membershipPlanDetailId,
        "membership_id": membershipId,
        "additional_info": additionalInfo,
        "order_facility": orderFacility,
        "is_membership_coupon_enabled": isMembershipCouponEnabled,
        "shipping_tax_rate": taxModel != null ? taxModel.shipping_tax_rate : '',
        "shipping_tax": taxModel != null ? taxModel.shipping_tax : '',
      });

      print("----${url}");
      print("--fields--${request.fields.toString()}--");
      final response = await request.send();
      var respStr = await response.stream.bytesToString();
      print("--respStr--${respStr}--");
      respStr = respStr.replaceAll('ion{', '{');
      final parsed = json.decode(respStr);

      ResponseModel model = ResponseModel.fromJson(parsed);
      return model;
    } catch (e) {
      print("-x-fields--${e.toString()}--");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<UserResponse> updateProfileRequest(
    String fullName,
    String emailId,
    String phoneNumber,
    bool isComingFromOtpScreen,
    String id,
    String user_refer_code,
    String gstNumber, {
    String lastName = '',
    String dob = '',
    String gender = '',
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //StoreModel store = await SharedPrefs.getStore();
    String userId;
    if (isComingFromOtpScreen) {
      userId = id;
    } else {
      UserModel user = await SharedPrefs.getUser();
      userId = user.id;
    }

    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.updateProfile;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print("--url--${url}--");
    try {
      request.fields.addAll({
        "full_name": fullName,
        "email": emailId,
        "user_refer_code": user_refer_code,
        "user_id": userId,
        "device_id": deviceId,
        "device_token": deviceToken,
        "gst_number": gstNumber,
        "last_name": lastName,
        "dob": dob,
        "gender": gender,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      print("--fields--${request.fields.toString()}--");
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("--respStr--${respStr}--");
      final parsed = json.decode(respStr);

      UserResponse model = UserResponse.fromJson(parsed);
      return model;
    } catch (e) {
      print("--fields--${e.toString()}--");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<ResponseModel> setStoreQuery(String queryString) async {
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl3.replaceAll("storeId", 'static_pages/') +
        ApiConstants.setStoreQuery;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "device_id": deviceId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "Android",
        "user_id": user.id,
        "query": queryString
      });
      print('--url===  $url');
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      final parsed = json.decode(respStr);
      print('--respStr===  $respStr');
      ResponseModel resModel = ResponseModel.fromJson(parsed);
      return resModel;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<GetOrderHistory> getOrderHistory() async {
    UserModel user = await SharedPrefs.getUser();
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    var url = ApiConstants.baseUrl3.replaceAll("storeId", '3') +
        ApiConstants.orderHistory;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (isNetworkAvailable) {
      try {
        request.fields.addAll({
          "user_id": user.id,
          "platform": Platform.isIOS ? "IOS" : "android",
        });
        print('--url===  $url');
        print('--user.id=== ${user.id}');
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        var respStr = await response.stream.bytesToString();
        respStr = respStr.replaceAll('ion{', '{');
        final parsed = json.decode(respStr);
        print('--respStr===  $respStr');
        GetOrderHistory getOrderHistory = GetOrderHistory.fromJson(parsed);
        return getOrderHistory;
      } catch (e) {
        Utils.showToast(e.toString(), true);
        return null;
      }
    } else {
      Utils.showToast(AppConstant.noInternet, true);
      return null;
    }
  }

  static Future<GetOrderHistory> getOrderDetail(String orderID) async {
//    StoreDataObj store = await SharedPrefs.getStoreData();
    UserModelMobile user = await SharedPrefs.getUserMobile();
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    var url = ApiConstants.baseUrl3.replaceAll("storeId", '0') +
        ApiConstants.orderDetailHistory;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (isNetworkAvailable) {
      try {
        request.fields.addAll({
          "user_id": user.id,
          "order_id": orderID,
          "platform": Platform.isIOS ? "IOS" : "android",
        });

        print('--url===  $url');
        print('--url===  ${request.fields.toString()}');
        print('--user.id=== ${user.id}');
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        var respStr = await response.stream.bytesToString();
        respStr = respStr.replaceAll('ion{', '{');
        final parsed = json.decode(respStr);
        print('--respStr===  $respStr');
        GetOrderHistory getOrderHistory = GetOrderHistory.fromJson(parsed);
        return getOrderHistory;
      } catch (e) {
        Utils.showToast(e.toString(), true);
        return null;
      }
    } else {
      Utils.showToast(AppConstant.noInternet, true);
      return null;
    }
  }

  static Future<ProductRatingResponse> postProductRating(
      String orderID, String productID, String rating, String storeID,
      {String desc = '', File imageFile, String type = '0'}) async {
    UserModelMobile user = await SharedPrefs.getUserMobile();
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeID) +
        ApiConstants.reviewRating;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (isNetworkAvailable) {
      if (imageFile != null) {
        //print("====FILE SIZE BEFORE: " + imageFile.lengthSync().toString());
        await CompressImage.compress(
            imageSrc: imageFile.path,
            desiredQuality: 80); //desiredQuality ranges from 0 to 100
        //print("====FILE SIZE  AFTER: " + imageFile.lengthSync().toString());
      }
      try {
        request.fields.addAll({
          "user_id": user.id,
          "order_id": orderID,
          "platform": Platform.isIOS ? "IOS" : "android",
          "product_id": productID,
          "rating": rating,
          "type": type,
          "description": desc
        });
        if (imageFile != null) {
          DateTime currentDate = DateTime.now();
          var multipartFile = http.MultipartFile.fromBytes(
            'image',
            await imageFile.readAsBytes(),
            filename: "Image_$currentDate",
          );
          request.files.add(multipartFile);
        }
        print('--url===  $url');
        print('--url===  ${request.fields.toString()}');
        print('--user.id=== ${user.id}');
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        final respStr = await response.stream.bytesToString();
        final parsed = json.decode(respStr);
        print('--respStr===  $respStr');
        ProductRatingResponse ratingResponse =
            ProductRatingResponse.fromJson(parsed);
        return ratingResponse;
      } catch (e) {
        Utils.showToast(e.toString(), true);
        return null;
      }
    } else {
      Utils.showToast(AppConstant.noInternet, true);
      return null;
    }
  }

  static Future<MobileVerified> mobileVerification(
      LoginMobile loginData) async {
    //StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.mobileVerification;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    var deviceInfoJson = await DeviceInfo.getInstance().getInfo();
    try {
      request.fields.addAll({
        "phone": loginData.phone,
        "device_id": deviceId,
        "device_token": deviceToken,
        "device_info": deviceInfoJson,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      //print('@@mobileVerification' + url + request.fields.toString());

      print('--url===  $url');
      print('--fields===${request.fields.toString()}');

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('--statusCode===${response.statusCode}');
      print('--response===  $respStr');
      final parsed = json.decode(respStr);
      MobileVerified userResponse = MobileVerified.fromJson(parsed);
      if (userResponse.success) {
        //SharedPrefs.setUserLoggedIn(true);
        SharedPrefs.saveUserMobile(userResponse.user);
      }
      return userResponse;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('=mobileVerification==catch==' + e.toString());
      return null;
    }
  }

  static Future<OtpVerified> otpVerified(
      OTPData otpData, LoginMobile phone) async {
    UserModelMobile userMobile = await SharedPrefs.getUserMobile();
    //StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.otp;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "phone": userMobile.phone,
        "otp": otpData.otp,
        "device_id": deviceId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "android"
      });
      print('@@url=${url}');
      //print('@@fields' + request.fields.toString());
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('response= ${respStr}');
      final parsed = json.decode(respStr);

      OtpVerified userResponse = OtpVerified.fromJson(parsed);
      if (userResponse.success) {
        SharedPrefs.setUserLoggedIn(true);
        SharedPrefs.saveUserOTP(userResponse);
      }
      return userResponse;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('catch' + e.toString());
      return null;
    }
  }

  static Future<StoreOffersResponse> myOffersApiRequest() async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
        ApiConstants.storeOffers;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print('@@myOffersApiRequest' + url);

    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('respStr' + respStr);
      final parsed = json.decode(respStr);

      StoreOffersResponse res = StoreOffersResponse.fromJson(parsed);
      return res;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('storeOffers catch' + e.toString());
      return null;
    }
  }

  static Future<StoreRadiousResponse> storeRadiusApi() async {
    //StoreModel store = await SharedPrefs.getStore();

    var url = ApiConstants.baseUrl3.replaceAll("storeId", "delivery_zones") +
        ApiConstants.getStoreRadius;

    var request = new http.MultipartRequest("GET", Uri.parse(url));
    print('@@url=${url}');

    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('@@respStr' + respStr);
      final parsed = json.decode(respStr);

      StoreRadiousResponse res = StoreRadiousResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<StoreRadiousResponse> storeRadiusV2Api(
      String operatingZone) async {
    //StoreModel store = await SharedPrefs.getStore();

    var url = ApiConstants.baseUrl3.replaceAll("storeId", "delivery_zones") +
        ApiConstants.getStoreRadiusv2;

    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print('@@url=${url}');

    try {
      request.fields.addAll({"operating_zone_id": operatingZone});
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('@@respStr' + respStr);
      final parsed = json.decode(respStr);

      StoreRadiousResponse res = StoreRadiousResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<CreateOrderData> razorpayCreateOrderApi(
      String amount,
      String orderJson,
      dynamic detailsJson,
      storeId,
      String currencyAbbr) async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeId) +
        ApiConstants.razorpayCreateOrder;
    print(url);
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "amount": amount,
        "currency": currencyAbbr.trim(),
        "receipt": "Order",
        "payment_capture": "1",
        "order_info": detailsJson != null ? detailsJson : '',
        //JSONObject details
        "orders": orderJson != null ? orderJson : ''
        //cart jsonObject
      });
      print(request.fields);

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      CreateOrderData model = CreateOrderData.fromJson(parsed);
      return model;
    } catch (e) {
      print('---catch-razorpayCreateOrder-----' + e.toString());
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<RazorpayOrderData> razorpayVerifyTransactionApi(
      String razorpay_order_id, String storeID) async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeID) +
        ApiConstants.razorpayVerifyTransaction;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "razorpay_order_id": razorpay_order_id,
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      RazorpayOrderData model = RazorpayOrderData.fromJson(parsed);
      return model;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<AdminLoginModel> getAdminApiRequest(
      String username, String password) async {
    var url = ApiConstants.baseUrl + ApiConstants.storeLogin;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll({"email": username, "password": password});
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      AdminLoginModel model = AdminLoginModel.fromJson(parsed);

      return model;
    } catch (e) {
      print('----catch-----' + e.toString());
      return null;
    }
  }

  static Future<ReferEarnData> referEarn() async {
    //StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    UserModel user = await SharedPrefs.getUser();
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.getReferDetails;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "user_id": user.id,
        "device_id": deviceId,
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('--response===  $respStr');
      final parsed = json.decode(respStr);
      ReferEarnData referEarn = ReferEarnData.fromJson(parsed);

      return referEarn;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('---referEarn catch' + e.toString());
      return null;
    }
  }

  static Future<StripeCheckOutModel> stripePaymentApi(
      String amount, String storeID,{String currency='usd'}) async {
    UserModel user = await SharedPrefs.getUser();
    var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.stripePaymentCheckout;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "customer_email": user.email,
        "amount": amount,
        "currency": currency,
        "store_id": storeID
      });
      print('--url===  $url');
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('--response===  $respStr');
      final parsed = json.decode(respStr);
      StripeCheckOutModel object = StripeCheckOutModel.fromJson(parsed);

      return object;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('catch' + e.toString());
      return null;
    }
  }

  static Future<StripeVerifyModel> stripeVerifyTransactionApi(
      String payment_request_id, String storeID) async {
    var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.stripeVerifyTransaction;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll(
          {"payment_request_id": payment_request_id, "store_id": storeID});
      print('--url===  $url');
      print('--payment_request_id===  $payment_request_id');
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('--response===  $respStr');
      final parsed = json.decode(respStr);
      StripeVerifyModel object = StripeVerifyModel.fromJson(parsed);

      return object;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('catch' + e.toString());
      return null;
    }
  }

  static Future<SearchTagsModel> searchTagsAPI() async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", '0') +
        ApiConstants.getTagsList;
    print("----respStr---${url}");
    var request = new http.MultipartRequest("GET", Uri.parse(url));
    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      final parsed = json.decode(respStr);
      print("----respStr---${respStr}");
      SearchTagsModel storeArea = SearchTagsModel.fromJson(parsed);
      return storeArea;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<DeliveryTimeSlotModel> deliveryTimeSlotApi(
      String storeID) async {
    UserModelMobile user = await SharedPrefs.getUserMobile();
    var url = ApiConstants.baseUrl3.replaceAll("storeId", 'delivery_zones/') +
        ApiConstants.deliveryTimeSlot;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll({"user_id": user.id, "store_id": storeID});
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      final parsed = json.decode(respStr);
      print("---deliveryTimeSlot-respStr---${respStr}");
      DeliveryTimeSlotModel storeArea = DeliveryTimeSlotModel.fromJson(parsed);
      return storeArea;
    } catch (e) {
      print("----catch---${e.toString()}");
      return null;
    }
  }

  static Future<CancelOrderModel> orderCancelApi(String order_id,
      {String storeID = '', String order_rejection_note = ""}) async {
    // 0 => 'pending' ,  1 =>'processing', 2 =>'rejected',
    // 4 =>'shipped', 5 =>'delivered', 6 => 'cancel'
    UserModelMobile user = await SharedPrefs.getUserMobile();
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeID) +
        ApiConstants.orderCancel;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll({
        "user_id": user.id,
        "order_id": order_id,
        "order_rejection_note": order_rejection_note
      });
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('--response===  $respStr');
      final parsed = json.decode(respStr);
      CancelOrderModel referEarn = CancelOrderModel.fromJson(parsed);
      return referEarn;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('---CancelOrderModel catch' + e.toString());
      return null;
    }
  }

  static Future<DeliveryAddressResponse> storeQueryApi() async {
    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();

    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.getAddress;
    print("----user.id---${user.id}");
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll({
        "user_id": user.id,
        "method": "GET",
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("-1--getAddress-respStr---${respStr}");
      final parsed = json.decode(respStr);

      DeliveryAddressResponse deliveryAddressResponse =
          DeliveryAddressResponse.fromJson(parsed);
      //print("----respStr---${deliveryAddressResponse.success}");
      return deliveryAddressResponse;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<StoreBranchesModel> multiStoreApiRequest(String storeId) async {
    var url = ApiConstants.baseUrl.replaceAll("storeId", storeId) +
        ApiConstants.getStoreBranches;

    Response response = await Dio()
        .get(url, options: Options(responseType: ResponseType.plain));
    print(url);
    print(response.data);
    StoreBranchesModel storeBranchesModel =
        StoreBranchesModel.fromJson(json.decode(response.data));
    print("---storeBranchesModel ---${storeBranchesModel.data.length}");

    return storeBranchesModel;
  }

  static Future<LoyalityPointsModel> getLoyalityPointsApiRequest() async {
//    StoreDataObj store = await SharedPrefs.getStoreData();
    UserModelMobile user = await SharedPrefs.getUserMobile();

    var url = ApiConstants.baseUrl3.replaceAll("storeId", "0") +
        ApiConstants.getLoyalityPoints;

    print("----url--${url}");
    print("--user.id--${user.id}");
    try {
      FormData formData = new FormData.fromMap(
          {"user_id": user.id, "platform": Platform.isIOS ? "IOS" : "Android"});
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);

      LoyalityPointsModel storeData =
          LoyalityPointsModel.fromJson(json.decode(response.data));
      print("-----LoyalityPointsModel ---${storeData.success}");

      return storeData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<CreatePaytmTxnTokenResponse> createPaytmTxnToken(String address,
      String pin, double amount, String orderJson, dynamic detailsJson) async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAviable) {
        StoreModel store = await SharedPrefs.getStore();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        UserModel user = await SharedPrefs.getUser();
        String email = user.email == null
            ? 'NA'
            : user.email.isEmpty
                ? "NA"
                : user.email;
//        address = "170,phase1";
        String firstName = user.fullName.contains(" ") == true
            ? user.fullName.substring(0, user.fullName.indexOf(" "))
            : user.fullName;
        String lastName = user.fullName.contains(" ") == true
            ? user.fullName.substring(user.fullName.indexOf(" "))
            : 'NA';
        print(firstName);
        print(lastName);
        String mobile = user.phone;
//        String pin = '160002';
//        String amount = '34.00';
        var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
            ApiConstants.createPaytmTxnToken;
        //TODO: remove this static url
//        url = "https://stage.grocersapp.com/393/api/createPaytmTxnToken";
        print(url);
        FormData formData = new FormData.fromMap({
          "customer_id": user.id,
          "customer_email": email,
          "customer_add": address,
          "customer_firstname": firstName,
          "customer_lastname": lastName,
          "customer_mobile": mobile,
          "customer_pin": pin,
          "amount": amount,
          "order_info": detailsJson, //JSONObject details
          "orders": orderJson
        });
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(responseType: ResponseType.plain));
        print(response.data);
        CreatePaytmTxnTokenResponse txnTokenResponse =
            CreatePaytmTxnTokenResponse.fromJson(json.decode(response.data));
        if (txnTokenResponse.success) {
          return txnTokenResponse;
        } else {
          return null;
        }
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<FaqModel> getFAQRequest() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAvailable) {
//        StoreModel store = await SharedPrefs.getStore();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceId = prefs.getString(AppConstant.deviceId);
        String deviceToken = prefs.getString(AppConstant.deviceToken);

        var url = ApiConstants.baseUrl3.replaceAll("storeId", 'static_pages') +
            ApiConstants.faqs;
        var request = new http.MultipartRequest("GET", Uri.parse(url));
//
//        request.fields.addAll({
//          "method": "POST",
//          "device_id": deviceId,
//          "device_token": deviceToken,
//          "platform": Platform.isIOS ? "IOS" : "Android"
//        });
        print("${url}");
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        final respStr = await response.stream.bytesToString();
        print("${respStr}");
        final parsed = json.decode(respStr);
        FaqModel model = FaqModel.fromJson(parsed);
        return model;
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<NotificationResponseModel> getAllNotifications() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAvailable) {
        StoreModel store = await SharedPrefs.getStore();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        UserModel user = await SharedPrefs.getUser();
        String deviceId = prefs.getString(AppConstant.deviceId);
        String deviceToken = prefs.getString(AppConstant.deviceToken);

        var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
            ApiConstants.allNotifications;
        var request = new http.MultipartRequest("POST", Uri.parse(url));
        print("user id ${user.id}");
        request.fields.addAll({
          "user_id": user.id,
          "method": "POST",
          "device_id": deviceId,
          "device_token": deviceToken,
          "platform": Platform.isIOS ? "IOS" : "Android"
        });
        print("${url}");
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        final respStr = await response.stream.bytesToString();
        print("${respStr}");
        final parsed = json.decode(respStr);
        NotificationResponseModel model =
            NotificationResponseModel.fromJson(parsed);
        return model;
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<RecommendedProductsResponse> getRecommendedProducts(
      String productID) async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAvailable) {
        StoreDataObj store = await SharedPrefs.getStoreData();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceId = prefs.getString(AppConstant.deviceId);
        String deviceToken = prefs.getString(AppConstant.deviceToken);

        var url = ApiConstants.baseUrl3.replaceAll("storeId", store.id) +
            ApiConstants.recommendedProduct;
        var request = new http.MultipartRequest("POST", Uri.parse(url));
        request.fields.addAll({
          "product_id": productID,
          "method": "POST",
          "device_id": deviceId,
          "device_token": deviceToken,
          "platform": Platform.isIOS ? "IOS" : "Android"
        });
        print("${url}");
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        final respStr = await response.stream.bytesToString();
        print("${respStr}");
        final parsed = json.decode(respStr);
        RecommendedProductsResponse model =
            RecommendedProductsResponse.fromJson(parsed);
        return model;
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<FacebookModel> getFbUserData(String fbtoken) async {
    //String url1 = "https://graph.facebook.com/${user_id}?fields=name,first_name,last_name,email,&access_token=${fbtoken}";
    String url =
        'https://graph.facebook.com/v8.0/me?fields=name,first_name,last_name,email&access_token=${fbtoken}';

    var request = new http.MultipartRequest("GET", Uri.parse(url));

    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----url---${url}");
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);
      FacebookModel fbModel = FacebookModel.fromJson(parsed);
      return fbModel;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<MobileVerified> verifyEmail(String email) async {
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.verifyEmail;

    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll(
          {"email": email, "platform": Platform.isIOS ? "IOS" : "Android"});
      print('@@url=${url}');

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('--response===  $respStr');
      final parsed = json.decode(respStr);
      MobileVerified userResponse = MobileVerified.fromJson(parsed);
      return userResponse;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('=mobileVerification==catch==' + e.toString());
      return null;
    }
  }

  static Future<MobileVerified> socialSignUp(
      FacebookModel fbModel,
      GoogleSignInAccount googleResult,
      String fullName,
      String emailId,
      String phoneNumber,
      String user_refer_code,
      String gstNumber,
      {String appleLogin = '',
      String lastName = ''}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var deviceInfoJson = await DeviceInfo.getInstance().getInfo();
    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.socialLogin;

    var request = new http.MultipartRequest("POST", Uri.parse(url));

    String socialPlatform;
    if (fbModel != null) {
      socialPlatform = "facebook";
    } else if (googleResult != null) {
      socialPlatform = "google";
    } else if (appleLogin.isNotEmpty) {
      socialPlatform = appleLogin;
    }

    try {
      request.fields.addAll({
        "phone": phoneNumber,
        "country": /*store.internationalOtp == "0" ?*/ "92" /* :"0"*/,
        "email": emailId,
        "social_platform": socialPlatform,
        "full_name": fullName,
        "user_refer_code": user_refer_code,
        "device_id": deviceId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "Android",
        "device_info": deviceInfoJson
      });
      print('@@url=${url}');
      print('@@fields=${request.fields.toString()}');

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('--response===  $respStr');
      final parsed = json.decode(respStr);
      MobileVerified userResponse = MobileVerified.fromJson(parsed);
      if (userResponse.success) {
        SharedPrefs.setUserLoggedIn(true);
        SharedPrefs.saveUserMobile(userResponse.user);
      }
      return userResponse;
    } catch (e) {
      //Utils.showToast(e.toString(), true);
      print('=mobileVerification==catch==' + e.toString());
      return null;
    }
  }

  static Future<StoreOffersResponse> homeOffersApiRequest() async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", '0') +
        ApiConstants.homeOffers;
    var request = new http.MultipartRequest("GET", Uri.parse(url));

    try {
      print("----url---${url}");
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      final parsed = json.decode(respStr);
      print("----respStr---${respStr}");
      StoreOffersResponse res = StoreOffersResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<StoreOffersResponse> homeOffersDetails(
      {String coupon_id}) async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", '0') +
        ApiConstants.couponDetails;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      print("----url---${url}");
      request.fields.addAll({'coupon_id': coupon_id});
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      final parsed = json.decode(respStr);
      print("----respStr---${respStr}");
      StoreOffersResponse res = StoreOffersResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<HtmlModelResponse> getHtmlForOptions(String appScreen) async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAvailable) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceId = prefs.getString(AppConstant.deviceId);
        String deviceToken = prefs.getString(AppConstant.deviceToken);
        var url = '';
        switch (appScreen) {
          case AdditionItemsConstants.TERMS_CONDITIONS:
            url = ApiConstants.baseUrl3.replaceAll("storeId", "static_pages/") +
                ApiConstants.termCondition;
            break;
          case AdditionItemsConstants.PRIVACY_POLICY:
            url = ApiConstants.baseUrl3.replaceAll("storeId", "static_pages/") +
                ApiConstants.privacyPolicy;
            break;
          case AdditionItemsConstants.REFUND_POLICY:
            url = ApiConstants.baseUrl3.replaceAll("storeId", "static_pages/") +
                ApiConstants.refundPolicy;
            break;
            case AdditionItemsConstants.Shipping_Charge:
            url = ApiConstants.baseUrl3.replaceAll("storeId", "static_pages/") +
                ApiConstants.shippingCharge;
            break;
        }
        var request = new http.MultipartRequest("POST", Uri.parse(url));
        request.fields.addAll({
          "method": "GET",
          "device_id": deviceId,
          "device_token": deviceToken,
          "platform": Platform.isIOS ? "IOS" : "Android"
        });
        print("${url}");
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        final respStr = await response.stream.bytesToString();
        print("${respStr}");
        final parsed = json.decode(respStr);
        HtmlModelResponse model = HtmlModelResponse.fromJson(parsed);
        return model;
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<DynamicResponse> getDynamicText() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAvailable) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceId = prefs.getString(AppConstant.deviceId);
        String deviceToken = prefs.getString(AppConstant.deviceToken);
        var url = ApiConstants.baseUrl3.replaceAll(
            "storeId", "marketplace/homescreen/webPagesSectionContents");

        var request = new http.MultipartRequest("POST", Uri.parse(url));
        request.fields.addAll({
          "method": "GET",
          "device_id": deviceId,
          "device_token": deviceToken,
          "platform": Platform.isIOS ? "IOS" : "Android"
        });
        print("${url}");
        final response =
            await request.send().timeout(Duration(seconds: timeout));
        final respStr = await response.stream.bytesToString();
        print("${respStr}");
        final parsed = json.decode(respStr);
        DynamicResponse model = DynamicResponse.fromJson(parsed);
        return model;
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<SubCategoryResponse> getSearchProductResults(
      String keyword, String storeID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeID) +
        ApiConstants.search;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "keyword": "${keyword}",
        "user_id": "",
        "device_id": deviceId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      print("${url}");
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("${respStr}");

      final parsed = json.decode(respStr);
      SubCategoryResponse subCategoryResponse =
          SubCategoryResponse.fromJson(parsed);
      return subCategoryResponse;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // New Subscription Module Start from here.
  static Future<MembershipPlanResponse> getSubscriptionMembershipPlan() async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAviable) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
            ApiConstants.membershipPlanDetails;
        print(url);
        FormData formData = new FormData.fromMap(
            {"platform": Platform.isIOS ? "IOS" : "Android"});
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(responseType: ResponseType.plain));
        print(response.data);
        MembershipPlanResponse membershipPlan =
            MembershipPlanResponse.fromJson(json.decode(response.data));
        if (membershipPlan.success) {
          return membershipPlan;
        } else {
          return null;
        }
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<StoreLatlngsResponse> getStoreLatlngsApi() async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAviable) {
        var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
            ApiConstants.membershipPlanLatlngs;
        print(url);
        FormData formData = new FormData.fromMap(
            {"platform": Platform.isIOS ? "IOS" : "Android"});
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(responseType: ResponseType.plain));
        print(response.data);
        StoreLatlngsResponse membershipPlanlatlngs =
            StoreLatlngsResponse.fromJson(json.decode(response.data));
        if (membershipPlanlatlngs.success) {
          return membershipPlanlatlngs;
        } else {
          return null;
        }
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<UserPurchaseMembershipResponse>
      getUserMembershipPlanApi() async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    String membershipPlanDetailId =
        SingletonBrandData.getInstance().membershipPlanResponse?.data?.id;
    if (membershipPlanDetailId == null) {
      return null;
    }
    UserModel user = await SharedPrefs.getUser();

    try {
      if (isNetworkAviable) {
        var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
            ApiConstants.userMembershipPlan;
        print(url);
        FormData formData = new FormData.fromMap({
          "platform": Platform.isIOS ? "IOS" : "Android",
          "user_id": user.id,
          "membership_plan_detail_id": membershipPlanDetailId,
        });
        print(formData.fields);
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(responseType: ResponseType.plain));
        print(response.data);
        UserPurchaseMembershipResponse userPurchaseMembershipResponse =
            UserPurchaseMembershipResponse.fromJson(json.decode(response.data));
        if (userPurchaseMembershipResponse.success) {
          SingletonBrandData.getInstance().userPurchaseMembershipResponse =
              userPurchaseMembershipResponse;
          return userPurchaseMembershipResponse;
        } else {
          return null;
        }
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<OnlineMembershipResponse> getPurchaseOnlineMembership(
      String amount, String razorpay_order_id, String paymentType) async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    String membershipPlanDetailId =
        SingletonBrandData.getInstance().membershipPlanResponse?.data?.id;
    if (membershipPlanDetailId == null) {
      return null;
    }
    UserModel user = await SharedPrefs.getUser();
    try {
      if (isNetworkAviable) {
        var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
            ApiConstants.createOnlineMembership;
        print(url);
        FormData formData = new FormData.fromMap({
          "user_id": user.id,
          "membership_plan_detail_id": membershipPlanDetailId,
          "payment_type": paymentType,
          "amount": amount,
          "payment_request_id": razorpay_order_id,
          "currency": SingletonBrandData.getInstance()
              .brandVersionModel
              .brand
              .currencyAbbr,
        });
        print(formData.fields.toString());
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(responseType: ResponseType.plain));
        print(response.data);
        OnlineMembershipResponse onlneMembership =
            OnlineMembershipResponse.fromJson(json.decode(response.data));
        if (onlneMembership.success) {
          return onlneMembership;
        } else {
          return null;
        }
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<OnlineMembershipResponse> getPurchasedOnlineMembership(
      {@required String razorpay_order_id,
      @required String puchaseType,
      @required String amountPaid,
      @required String additionalInfo,
      @required String posBranchCode,
      @required String defaultAddressId,
      @required String paymentId,
      @required String onlineMethod}) async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    String membershipPlanDetailId =
        SingletonBrandData.getInstance().membershipPlanResponse?.data?.id;
    if (membershipPlanDetailId == null) {
      return null;
    }
    UserModel user = await SharedPrefs.getUser();
    try {
      if (isNetworkAviable) {
        var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
            ApiConstants.placeMembershipOrder;
        print(url);
        FormData formData = new FormData.fromMap({
          "user_id": user.id,
          "membership_plan_detail_id": membershipPlanDetailId,
          "puchase_type": puchaseType,
          "amount_paid": amountPaid,
          "additional_info": additionalInfo,
          "online_method": onlineMethod,
          "pos_branch_code": posBranchCode,
          "default_address_id": defaultAddressId,
          "payment_id": paymentId,
          "payment_request_id": razorpay_order_id,
          "currency": SingletonBrandData.getInstance()
              .brandVersionModel
              .brand
              .currencyAbbr,
        });
        print(formData.fields.toString());
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(responseType: ResponseType.plain));
        print(response.data);
        OnlineMembershipResponse onlneMembership =
            OnlineMembershipResponse.fromJson(json.decode(response.data));
        if (onlneMembership.success) {
          return onlneMembership;
        } else {
          return null;
        }
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<OnlineMembershipResponse> getCancelOnlineMembership(
      String membershipId, String puchaseType) async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    String membershipPlanDetailId =
        SingletonBrandData.getInstance().membershipPlanResponse?.data?.id;
    if (membershipPlanDetailId == null) {
      return null;
    }
    UserModel user = await SharedPrefs.getUser();
    try {
      if (isNetworkAviable) {
        var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
            ApiConstants.cancelUserMembershipPlan;
        print(url);
        FormData formData = new FormData.fromMap({
          "user_id": user.id,
          "membership_plan_detail_id": membershipPlanDetailId,
          "membership_id": membershipId,
          "puchase_type": puchaseType
        });
        Dio dio = new Dio();
        Response response = await dio.post(url,
            data: formData,
            options: new Options(responseType: ResponseType.plain));
        print(response.data);
        OnlineMembershipResponse onlneMembership =
            OnlineMembershipResponse.fromJson(json.decode(response.data));
        if (onlneMembership.success) {
          return onlneMembership;
        } else {
          return null;
        }
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<LogoutResponse> getLogout() async {
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.base_Url.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.logout;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "user_id": user.id,
        "device_id": deviceId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      print("${url}");
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("${respStr}");

      final parsed = json.decode(respStr);
      LogoutResponse logoutResponse = LogoutResponse.fromJson(parsed);
      return logoutResponse;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<BannerResponse> getBannersApi(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url = ApiConstants.baseUrl2.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.banners;

    print("----url--${url}");
    try {
      FormData formData = new FormData.fromMap({
        "device_id": deviceId,
        "device_token": "${deviceToken}",
        "platform": Platform.isIOS ? "IOS" : "Android",
        "city": city
      });
      print(formData.fields.toString());
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      BannerResponse bannerResponse =
          BannerResponse.fromJson(json.decode(response.data));
      print("-------tagsApiRequest ---${bannerResponse.success}");

      return bannerResponse;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /*PeachPay payment Gateway*/
  static Future<PeachPayCheckOutResponse> peachPayCreateOrderApi(
      String amount,
      String orderJson,
      dynamic detailsJson,
      storeId,
      String currencyAbr) async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    if (!isNetworkAviable) {
      return null;
    }
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeId) +
        ApiConstants.peachPayCreateOrder;
    print(url);
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "amount": amount,
//        "currency": currencyAbr.trim(),
        "currency": "ZAR",
        "order_info": detailsJson != null ? detailsJson : '',
        //JSONObject details
        "orders": orderJson != null ? orderJson : ''
        //cart jsonObject
      });
      print(request.fields);

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      PeachPayCheckOutResponse model =
          PeachPayCheckOutResponse.fromJson(parsed);
      return model;
    } catch (e) {
      print('---catch-razorpayCreateOrder-----' + e.toString());
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<PeachPayVerifyResponse> peachPayVerifyTransactionApi(
      String checkout_id, String storeID) async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeID) +
        ApiConstants.peachpayVerifyTransaction;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print(url);
    try {
      request.fields.addAll({
        "checkout_id": checkout_id,
      });
      print(request.fields.toString());

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      PeachPayVerifyResponse model = PeachPayVerifyResponse.fromJson(parsed);
      return model;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

// ipay88 Create order Api

  static Future<Ipay88OrderData> ipay88CreateOrderApi(
      String amount,
      String orderJson,
      String fullName,
      String username,
      String contact,
      dynamic detailsJson,
      storeId,
      String currencyAbbr) async {
    var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
        storeId +
        '/' +
        ApiConstants.ipay88CreateOrder;
    print(url);
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "amount": "1.00",
        "currency": currencyAbbr.trim(),
        //"receipt": "Order",
        "name": fullName,
        "email": username,
        "contact": contact,
        //"payment_capture": "1",
        "order_info": detailsJson != null ? detailsJson : '',
        //JSONObject details
        "orders": orderJson != null ? orderJson : ''
        //cart jsonObject
      });
      print(request.fields);

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      Ipay88OrderData model = Ipay88OrderData.fromJson(parsed);
      return model;
    } catch (e) {
      print('---catch-ipay88CreateOrder-----' + e.toString());
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  /*Phonepe*/
  static Future<PhonePeResponse> phonepeCreateOrderApi(String amount,
      String orderJson, dynamic detailsJson, storeId, String currencyAbr,
      {String merchantUserId = ''}) async {
    bool isNetworkAviable = await Utils.isNetworkAvailable();
    if (!isNetworkAviable) {
      return null;
    }
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeId) +
        ApiConstants.phonepeCreateOrder;
    print(url);
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "amount": amount,
        "merchantUserId": merchantUserId,
        "currency": currencyAbr.trim(),
        "order_info": detailsJson != null ? detailsJson : '',
        //JSONObject details
        "orders": orderJson != null ? orderJson : ''
        //cart jsonObject
      });
      print(request.fields);

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      PhonePeResponse model =
          PhonePeResponse.fromJson(parsed);
      return model;
    } catch (e) {
      print('---catch-phonepeCreateOrderApi-----' + e.toString());
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<PhonePeVerifyResponse> phonePeVerifyTransactionApi(
      String paymentRequestId, String storeID) async {
    var url = ApiConstants.baseUrl3.replaceAll("storeId", storeID) +
        ApiConstants.checkPhonepeTransactionStatus;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print(url);
    try {
      request.fields.addAll({
        "payment_request_id": paymentRequestId,
      });
      print(request.fields.toString());

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      PhonePeVerifyResponse model = PhonePeVerifyResponse.fromJson(parsed);
      return model;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }
  static Future<SellOptionResponse> sellOptionsApi(
      String name,
      String email,
      String phone,
      String store_name,
      String address,
      String additional_detail,
      String business_type) async {
    var url =
        ApiConstants.base.replaceAll("brandId", AppConstant.brandID) + ApiConstants.sell;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print(url);
    try {
      request.fields.addAll({
        "name": name,
        "email": email,
        "phone": phone,
        "store_name": store_name,
        "address": address,
        "additional_detail": additional_detail,
        "business_type": business_type
      });
      print(request.fields.toString());

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      SellOptionResponse model = SellOptionResponse.fromJson(parsed);
      return model;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<WalletModel> getUserWallet() async {
    bool isNetworkAvailable = await Utils.isNetworkAvailable();
    try {
      if (isNetworkAvailable) {
        UserModel user = await SharedPrefs.getUser();

        var url = ApiConstants.baseUrl2.replaceAll("brandId", AppConstant.brandID) +
            ApiConstants.userWallet;

        var request = new http.MultipartRequest("POST", Uri.parse(url));
        request.fields.addAll({
          "user_id": user.id,
          "brand_id": AppConstant.brandID,
        });
        print("fields=${request.fields.toString()}");
        print("${url}");
        final response =
        await request.send().timeout(Duration(seconds: timeout));
        final respStr = await response.stream.bytesToString();
        print("${respStr}");
        final parsed = json.decode(respStr);
        WalletModel welletModel = WalletModel.fromJson(parsed);
        SharedPrefs.saveUserWallet(welletModel);
        return welletModel;
      } else {
        Utils.showToast(AppConstant.noInternet, true);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<RazorPayTopUP> createOnlineTopUPApi(
      String price, dynamic Id,String payment_type,{String currency='INR'}) async {
    UserModel user = await SharedPrefs.getUser();
    var url = ApiConstants.base.replaceAll("brandId",AppConstant.brandID) +
        ApiConstants.createOnlineTopUP;
    print(url);
    try {
      FormData formData = new FormData.fromMap({
        "amount": price,
        "user_id": user.id,
        "payment_request_id": Id,
        "payment_type": payment_type,
        "currency": currency,
        "platform": Platform.isIOS ? "IOS" : "android",
      });
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      RazorPayTopUP razorTopStore =
      RazorPayTopUP.fromJson(json.decode(response.data));
      RazorPayTopUP.fromJson(json.decode(response.data));
      print("-----RazortopUpData---${razorTopStore.success}");
      return razorTopStore;
    } catch (e) {
      print(e);
    }
  }

  static Future<WalletOnlineTopUp> onlineTopUP(String paymentId,
      String paymentRequestId, String amount, String paymentType) async {
    UserModel user = await SharedPrefs.getUser();
    var url = ApiConstants.base.replaceAll("brandId", AppConstant.brandID) +
        ApiConstants.onlineTopUP;
    print(url);
    try {
      FormData formData = new FormData.fromMap({
        "price": amount,
        "user_id": user.id,
        "payment_request_id": paymentRequestId,
        "online_method": paymentType,
        "payment_id": paymentId,
        "platform": Platform.isIOS ? "IOS" : "android",
      });
      Dio dio = new Dio();
      Response response = await dio.post(url,
          data: formData,
          options: new Options(
              contentType: "application/json",
              responseType: ResponseType.plain));
      print(response.statusCode);
      print(response.data);
      WalletOnlineTopUp razorTopStore =
      WalletOnlineTopUp.fromJson(json.decode(response.data));
      print("-----RazortopUpData---${razorTopStore.success}");
      return razorTopStore;
    } catch (e) {
      print(e);
    }
  }
}
