import 'package:dio/dio.dart';
import 'package:restroapp/src/Screens/LoginSignUp/ForgotPasswordScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/LoginMobileScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/OtpScreen.dart';
import 'package:restroapp/src/Screens/LoginSignUp/RegisterScreen.dart';
import 'package:restroapp/src/Screens/SideMenu/AboutScreen.dart';
import 'package:restroapp/src/apihandler/ApiConstants.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/AdminLoginModel.dart';
import 'package:restroapp/src/models/CancelOrderModel.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/CreateOrderData.dart';
import 'package:restroapp/src/models/DeliveryAddressResponse.dart';
import 'package:restroapp/src/models/DeliveryTimeSlotModel.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/OTPVerified.dart';
import 'package:restroapp/src/models/PickUpModel.dart';
import 'package:restroapp/src/models/RazorpayOrderData.dart';
import 'package:restroapp/src/models/ReferEarnData.dart';
import 'package:restroapp/src/models/SearchTagsModel.dart';
import 'package:restroapp/src/models/StoreAreaResponse.dart';
import 'package:restroapp/src/models/StoreRadiousResponse.dart';
import 'package:restroapp/src/models/StripeCheckOutModel.dart';
import 'package:restroapp/src/models/StripeVerifyModel.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/StoreDeliveryAreasResponse.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/StoreOffersResponse.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/models/TaxCalulationResponse.dart';
import 'package:restroapp/src/models/ValidateCouponsResponse.dart';
import 'package:restroapp/src/models/GetOrderHistory.dart';
import 'package:restroapp/src/models/forgotPassword/GetForgotPwdData.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiController {
  static final int timeout = 18;


  static Future<StoreResponse> versionApiRequest(String storeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", storeId) +
        ApiConstants.version;


    FormData formData = new FormData.from(
        {"device_id": deviceId, "device_token":"${deviceToken}",
          "platform": Platform.isIOS ? "IOS" : "Android"
        });
    Dio dio = new Dio();
    Response response = await dio.post(url, data: formData,
        options: new Options(
            contentType: ContentType.parse("application/json")));
    //print(response.data);
    StoreResponse storeData = StoreResponse.fromJson(response.data);
    print("-------store.success ---${storeData.success}");
    SharedPrefs.saveStore(storeData.store);
    return storeData;
  }

  static Future<UserResponse> registerApiRequest(UserData user) async {
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
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
        "platform": Platform.isIOS ? "IOS" : "Android"
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      final parsed = json.decode(respStr);
      UserResponse userResponse = UserResponse.fromJson(parsed);
      if (userResponse.success) {
        SharedPrefs.setUserLoggedIn(true);
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
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.login;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "email": username,
        "password": password,
        "device_id": deviceId,
        "device_token": deviceToken,
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
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);

    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
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

  static Future<CategoryResponse> getCategoriesApiRequest(String storeId) async {
    var url = ApiConstants.baseUrl.replaceAll("storeId", storeId) +
        ApiConstants.getCategories;

    Response response = await Dio().get(url);
    //print(response);
    CategoryResponse categoryResponse = CategoryResponse.fromJson(response.data);
    print("-------Categories.length ---${categoryResponse.categories.length}");
    try {
      DatabaseHelper databaseHelper = new DatabaseHelper();
      databaseHelper.getCount(DatabaseHelper.Categories_Table).then((count) {
        if (count == 0) {
          for (int i = 0; i < categoryResponse.categories.length; i++) {
            CategoryModel model = categoryResponse.categories[i];
            databaseHelper.saveCategories(model);
            if (model.subCategory != null) {
              for (int j = 0; j < model.subCategory.length; j++) {
                databaseHelper.saveSubCategories(
                    model.subCategory[j], model.id);
              }
            }
          }
        }
      });
    } catch (e) {
      print(e);
    }
    return categoryResponse;
  }


  static Future<SubCategoryResponse> getSubCategoryProducts(String subCategoryId) async {
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.getProducts +subCategoryId;

    FormData formData = new FormData.from(
        {
          "user_id": "",
          "device_id": deviceId,
          "device_token": deviceToken,
          "platform": Platform.isIOS ? "IOS" : "Android"
        });
    Dio dio = new Dio();
    Response response = await dio.post(url, data: formData,
        options: new Options(
            contentType: ContentType.parse("application/json")));
    //print(response.data);
    SubCategoryResponse subCategoryResponse = SubCategoryResponse.fromJson(response.data);
    //print("-------store.success ---${storeData.success}");
    return subCategoryResponse;
  }

  static Future<DeliveryAddressResponse> getAddressApiRequest() async {
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
      StoreAreaResponse storeArea =
      StoreAreaResponse.fromJson(parsed);
      return storeArea;
    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<PickUpModel> getStorePickupAddress() async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.getStorePickupAddress;

    var request = new http.MultipartRequest("GET", Uri.parse(url));
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
      String zipCode,
      String address,
      String areaId,
      String areaName,
      String addressId,
      String fullname,
      String city,
      String cityId,
      String lat,
      String lng) async {
    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();

    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.getAddress;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "method": method,
        "user_id": user.id,
        "zipcode": zipCode,
        "country": "",
        "address": address,
        "city": "${city}",
        "area_name": areaName,
        "mobile": user.phone,
        "state": "",
        "lat": "${lat}",
        "lng": "${lng}",
        "area_id": areaId,
        "first_name": fullname,
        "email": user.email
      });

      if (addressId != null) {
        request.fields["address_id"] = addressId;
      }
      print(
          '@@saveDeliveryAddressApiRequest' + url + request.fields.toString());

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
    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
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

  static Future<StoreOffersResponse> storeOffersApiRequest(
      String areaId) async {
    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();

    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.storeOffers;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "store_id": store.id,
        "user_id": user.id,
        "order_facility": "Delivery"
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
      String couponCode, String paymentMode, String orderJson) async {
    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.validateCoupon;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "coupon_code": couponCode,
        "device_id": deviceId,
        "user_id": user.id,
        "device_token": deviceToken,
        "orders": "$orderJson",
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
      String couponCode,
      String discount,
      String shipping,
      String orderJson) async {
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);

    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) + ApiConstants.multipleTaxCalculation;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    print("----url---${url}");
    print("----orderJson---${orderJson}");
    print("--discount-${discount}");
    try {
      request.fields.addAll({
        "fixed_discount_amount": "${discount}",
        "tax": "0",
        "discount": "0",
        "shipping": shipping,
        "order_detail": orderJson,
        "device_id": deviceId,
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print("----respStr---${respStr}");
      final parsed = json.decode(respStr);

      TaxCalculationResponse model = TaxCalculationResponse.fromJson(couponCode, parsed);
      return model;
    } catch (e) {
      print("----respStr---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<ResponseModel> placeOrderRequest(String shipping_charges,
      String note,
      String totalPrice,
      String paymentMethod,
      TaxCalculationModel taxModel,
      DeliveryAddressData address,
      String orderJson, bool isComingFromPickUpScreen, String areaId,OrderType deliveryType,
      String razorpay_order_id,String razorpay_payment_id,String online_method,
      String selectedDeliverSlotValue) async {

    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url;
    if(deliveryType == OrderType.Delivery){
      url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
          ApiConstants.placeOrder;
    }else{
      url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
          ApiConstants.pickupPlaceOrder;
    }

    /*var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.placeOrder;*/
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    //print("==orderJson==${orderJson}====");
    try {
      request.fields.addAll({
        "shipping_charges": "${shipping_charges}",
        "note": note,
        "calculated_tax_detail": "",
        "coupon_code": taxModel == null ? "" : '${taxModel.couponCode}',
        "device_id": deviceId,
        "user_address": isComingFromPickUpScreen == true ? areaId : address.address,
        "store_fixed_tax_detail": "",
        "tax": taxModel == null ? "0" : '${taxModel.tax}',
        "store_tax_rate_detail": "",
        "platform": Platform.isIOS ? "IOS" : "Android",
        "tax_rate": "0",
        "total": taxModel == null ? '${totalPrice}' : '${taxModel.total}',
        "user_id": user.id,
        "device_token": deviceToken,
        "user_address_id": isComingFromPickUpScreen == true ? areaId : address.address,
        "orders": orderJson,
        "checkout": totalPrice,
        "payment_method": paymentMethod == "2" ? "COD" : "online",
        "discount": taxModel == null ? "" : '${taxModel.discount}',
        "payment_request_id": razorpay_order_id,
        "payment_id": razorpay_payment_id,
        "online_method": online_method,
        "delivery_time_slot": selectedDeliverSlotValue,
      });

      print("----${url}");
      print("--fields--${request.fields.toString()}--");
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("--respStr--${respStr}--");
      final parsed = json.decode(respStr);

      ResponseModel model = ResponseModel.fromJson(parsed);
      return model;
    } catch (e) {
      print("-x-fields--${e.toString()}--");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<UserResponse> updateProfileRequest(String fullName, String emailId,
      String phoneNumber,bool isComingFromOtpScreen, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    StoreModel store = await SharedPrefs.getStore();
    String userId;
    if(isComingFromOtpScreen){
      userId = id;
    }else{
      UserModel user = await SharedPrefs.getUser();
      userId = user.id;
    }

    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +ApiConstants.updateProfile;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "full_name": fullName,
        "email": emailId,
        "user_id": userId,
        "device_id": deviceId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });

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
    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.setStoreQuery;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "store_id": store.id,
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
    StoreModel store = await SharedPrefs.getStore();
    UserModel user = await SharedPrefs.getUser();

    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.orderHistory;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "user_id": user.id,
        "platform": Platform.isIOS ? "IOS" : "android",
      });
      print('--url===  $url');
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      final parsed = json.decode(respStr);
      print('--respStr===  $respStr');
      GetOrderHistory getOrderHistory = GetOrderHistory.fromJson(parsed);
      return getOrderHistory;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<MobileVerified> mobileVerification(
      LoginMobile loginData) async {
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.mobileVerification;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "phone": loginData.phone,
        "device_id": deviceId,
        "device_token": deviceToken,
        "platform": Platform.isIOS ? "IOS" : "Android"
      });
      print('@@mobileVerification' + url + request.fields.toString());

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
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

  static Future<OtpVerified> otpVerified(OTPData otpData,LoginMobile phone) async {

    UserModelMobile userMobile = await SharedPrefs.getUserMobile();
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);
    var url =
        ApiConstants.baseUrl.replaceAll("storeId", store.id) + ApiConstants.otp;
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
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
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
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.getStoreRadius;
    var request = new http.MultipartRequest("GET", Uri.parse(url));
    print('@@storeRadiusApi' + url);

    try {
      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      final parsed = json.decode(respStr);

      StoreRadiousResponse res = StoreRadiousResponse.fromJson(parsed);
      return res;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }


  static Future<CreateOrderData> razorpayCreateOrderApi(String amount) async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
        ApiConstants.razorpayCreateOrder;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "amount": amount,
        "currency": "INR",
        "receipt": "Order",
        "payment_capture": "1",
      });

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();
      print('----respStr-----' + respStr);
      final parsed = json.decode(respStr);

      CreateOrderData model = CreateOrderData.fromJson(parsed);
      return model;
    } catch (e) {
      Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<RazorpayOrderData> razorpayVerifyTransactionApi(String razorpay_order_id) async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
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


  static Future<AdminLoginModel> getAdminApiRequest(String username,String password) async {
    var url = ApiConstants.baseUrl+ApiConstants.storeLogin;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll({
        "email": username,
        "password": password
      });
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
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    UserModel user = await SharedPrefs.getUser();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) +
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


  static Future<StripeCheckOutModel> stripePaymentApi(String amount) async {
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserModel user = await SharedPrefs.getUser();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id) + ApiConstants.stripePaymentCheckout;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "customer_email": user.email,
        "amount": amount,
        "currency":"usd"
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


  static Future<StripeVerifyModel> stripeVerifyTransactionApi(String payment_request_id) async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id)+ApiConstants.stripeVerifyTransaction;
    var request = new http.MultipartRequest("POST", Uri.parse(url));

    try {
      request.fields.addAll({
        "payment_request_id": payment_request_id,

      });
      print('--url===  $url');
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
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id)+ApiConstants.getTagsList;

    var request = new http.MultipartRequest("GET", Uri.parse(url));
    try {

      final response = await request.send().timeout(Duration(seconds: timeout));
      final respStr = await response.stream.bytesToString();

      final parsed = json.decode(respStr);

      SearchTagsModel storeArea = SearchTagsModel.fromJson(parsed);
      return storeArea;

    } catch (e) {
      print("----catch---${e.toString()}");
      //Utils.showToast(e.toString(), true);
      return null;
    }
  }

  static Future<SubCategoryResponse> getSearchResults(String keyword) async {
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceId = prefs.getString(AppConstant.deviceId);
    String deviceToken = prefs.getString(AppConstant.deviceToken);

    var url=ApiConstants.baseUrl.replaceAll("storeId", store.id)+ApiConstants.search;
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
      SubCategoryResponse subCategoryResponse = SubCategoryResponse.fromJson(parsed);
      return subCategoryResponse;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  static Future<DeliveryTimeSlotModel> deliveryTimeSlotApi() async {
    StoreModel store = await SharedPrefs.getStore();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id)+ApiConstants.deliveryTimeSlot;
    var request = new http.MultipartRequest("GET", Uri.parse(url));
    try {

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

  static Future<CancelOrderModel> orderCancelApi(String order_id) async {
    // 0 => 'pending' ,  1 =>'processing', 2 =>'rejected',
    // 4 =>'shipped', 5 =>'delivered', 6 => 'cancel'
    StoreModel store = await SharedPrefs.getStore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserModel user = await SharedPrefs.getUser();
    var url = ApiConstants.baseUrl.replaceAll("storeId", store.id)+ApiConstants.orderCancel;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    try {
      request.fields.addAll({"user_id": user.id,"order_id": order_id,});
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

}
