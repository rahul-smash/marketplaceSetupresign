import 'package:restroapp/src/utils/AppConstants.dart';

class ApiConstants {
  //Place Api key: AIzaSyDIrOUg5njtkZcWcnpfoMht1Ol1l7Q8Bys

  static String baseUrl = 'https://app.restroapp.com/storeId/api/';
  static String base= 'http://devmarketplace.restroapp.com/brandId/v1/';
// live url
//   static String base_Url = 'https://marketplace.restroapp.com/brandId/v1/user_authentication/';
//   static String baseUrl2 = 'https://marketplace.restroapp.com/brandId/v1/marketplace/';
//   static String baseUrl3 = 'https://marketplace.restroapp.com/${AppConstant.brandID}/v1/storeId';
  static String base_Url = '${base}user_authentication/';
  static String baseUrl2 = '${base}marketplace/';
  static String baseUrl3 =
      'http://devmarketplace.restroapp.com/${AppConstant.brandID}/v1/storeId';

  static String storeList = 'storeList';
  static String version = 'version';
  static String storeLogin = 'storeLogin';

  static String getStoreBranches = 'getStoreBranches';

  static String getAddressArea = 'deliveryAreas/Area';
  static String getStoreRadius = '/storeRadius';
  static String getStoreArea = 'storearea';

//  static String validateCoupon = 'validateAllCoupons';
  static String multipleTaxCalculation = 'multiple_tax_calculation';
  static String stripeVerifyTransactionUrl =
      'stripeVerifyTransaction?response=success';

  static String deliveryTimeSlot = 'deliveryTimeSlot';
  static String setStoreQuery = 'setStoreQuery';

  static String login = 'userLogin';
  static String signUp = 'userSignup';
  static String forgetPassword = 'forgetPassword';
  static String updateProfile = 'updateProfile';
  static String mobileVerification = 'mobileVerification';
  static String cancelOrder = 'orderCancel';

  static String deliveryAreasArea = 'deliveryAreas/Area';

  static String getReferDetails = 'getReferDetails';

  static String stripePaymentCheckout = 'stripe/stripePaymentCheckout';
  static String stripeVerifyTransaction = 'stripe/stripeVerifyTransaction';

  static String createPaytmTxnToken = 'createPaytmTxnToken';

  static String faqs = '/faqs';
  static String allNotifications = 'allNotifications';

  static final String txt_mobile =
      "Please enter your Mobile No. to proceed further";
  static final String txt_Submit = "Submit";
  static final String pleaseFullname = "Enter FullName";

  static final String delivrey = "Delievery";
  static final String pickup = "PickUP";
  static final String dine = "dine";
  static String termCondition = 'getHtmlPages/term_condition';
  static String privacyPolicy = 'getHtmlPages/privacy_policy';
  static String refundPolicy = 'getHtmlPages/refund_policy';

  static String otp = 'verifyOtp';

  static final String txt_OTP =
      "Please enter your One Time Password.We \n have sent the same to your number.";

  static final String enterOtp = "Please enter otp number";

  //----------------------MARKET PLACE APIs-----------------------------

  static final String brandVersion = "homescreen/version";
  static final String homescreenCategories = "homescreen/getCategories";
  static final String homescreenTags = "homescreen/getTags";
  static final String homescreenStores = "homescreen/getStores";
  static final String allStores = "stores";
  static final String store_configuration = "/store_configuration";
  static final String getCategories = "/inventory/getCategories";
  static String getProducts = '/inventory/getSubCategoryProducts/';

  static String socialLogin = 'socialLogin';
  static String verifyEmail = 'verifyEmail';
  static String multipleTaxCalculation_2 = '/tax_calculation';
  static String coupons_validate = '/coupons/validateCoupon';
  static String placeOrder = '/orders/placeOrder';
  static String pickupPlaceOrder = '/orders/pickupPlaceOrder';
  static String razorpayCreateOrder = '/razorpay/razorpayCreateOrder';
  static String razorpayVerifyTransaction =
      '/razorpay/razorpayVerifyTransaction';
  static String orderHistory = '/orders/orderHistory';
  static String storeOffers = '/coupons/offersList';
  static String getStorePickupAddress = 'delivery_zones/storePickupAddress';
  static String getLoyalityPoints = '/coupons/getLoyalityPoints';
  static String orderCancel = '/orders/orderCancel';
  static String orderDetailHistory = '/orders/orderDetailHistory';
  static String recommendedProduct = '/inventory/recommendedProduct';
  static String getTagsList = '/inventory/getTagsList';
  static String getProductDetail = '/inventory/productDetail/';
  static String search = '/inventory/searchProducts';
  static String getAddress = '/deliveryAddress';
  static String homeOffers = '/coupons/homeOffersList';
  static String couponDetails = '/coupons/couponDetail';
  static String reviewRating = '/review_rating';
  static String logout = 'logout';

  // New subscription module
  static String membershipPlanDetails = 'membership_plan/plan_details';
  static String membershipPlanLatlngs = 'membership_plan/branch_latlngs';
  static String userMembershipPlan = 'membership_plan/userMembershipPlan';
  static String createOnlineMembership =
      'membership_plan/createOnlineMemberShip';
  static String placeMembershipOrder = 'membership_plan/placeMembershipOrder';
  static String cancelUserMembershipPlan =
      'membership_plan/cancelUserMembershipPlan';

  static String peachPayCreateOrder='/peachpay/peachpayCreateOrder';
  static String processPeachpayPayment='/peachpay/processPeachpayPayment/';
  static String peachpayVerifyTransaction='/peachpay/peachpayVerifyTransaction';

  //new Banner Api
  static String banners = 'homescreen/banners';
// get peach pay details
// http://devmarketplace.restroapp.com/2/v1/marketplace/homescreen/version?ip=124.253.110.23
// detailspeach payament is added
// API : create order
// http://devmarketplace.restroapp.com/2/v1/2167/peachpay/peachpayCreateOrder
// order_info,orders,amount,currency
// load web page : process order
// http://devmarketplace.restroapp.com/2/v1/2167/peachpay/processPeachpayPayment/19885B13DA6E12D269B02F772737C999.uat01-vm-tx04
// API : verifyOrder
// http://devmarketplace.restroapp.com/2/v1/2167/peachpay/VerifyTransaction
// checkout_id=19885B13DA6E12D269B02F772737C999.uat01-vm-tx04
//http://devmarketplace.restroapp.com/2/v1/storeId/peachpay/peachPayVerify?id=C19277FB92BFDFFBBF716818766F3BC4.uat01-vm-tx02&resourcePath=%2Fv1%2Fcheckouts%2FC19277FB92BFDFFBBF716818766F3BC4.uat01-vm-tx02%2Fpayment
}
