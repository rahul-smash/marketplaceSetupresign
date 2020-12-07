import 'package:restroapp/src/utils/AppConstants.dart';

class ApiConstants{

  //Place Api key: AIzaSyDIrOUg5njtkZcWcnpfoMht1Ol1l7Q8Bys

  static String baseUrl = 'https://app.restroapp.com/storeId/api/';

  static String base_Url = 'http://devmarketplace.restroapp.com/brandId/v1/user_authentication/';
  static String baseUrl2 = 'http://devmarketplace.restroapp.com/brandId/v1/marketplace/';
  static String baseUrl3 = 'http://devmarketplace.restroapp.com/${AppConstant.brandID}/v1/storeId';

  static String storeList = 'storeList';
  static String version = 'version';
  static String storeLogin = 'storeLogin';


  static String getProductDetail = 'productDetail/';

  static String getStoreBranches = 'getStoreBranches';

  static String search = 'searchProducts';
  static String getTagsList = 'getTagsList';


  static String getAddress = '/deliveryAddress';
  static String getAddressArea = 'deliveryAreas/Area';
  static String getStorePickupAddress = 'storePickupAddress';
  static String getStoreRadius = '/storeRadius';
  static String getStoreArea = 'storearea';


//  static String validateCoupon = 'validateAllCoupons';
  static String multipleTaxCalculation = 'multiple_tax_calculation';
  static String stripeVerifyTransactionUrl = 'stripeVerifyTransaction?response=success';


  static String deliveryTimeSlot = 'deliveryTimeSlot';
  static String setStoreQuery = 'setStoreQuery';
  static String getLoyalityPoints = 'getLoyalityPoints';

  static String login = 'userLogin';
  static String signUp = 'userSignup';
  static String forgetPassword = 'forgetPassword';
  static String updateProfile = 'updateProfile';
  static String mobileVerification = 'mobileVerification';
  static String cancelOrder = 'orderCancel';



  static String deliveryAreasArea = 'deliveryAreas/Area';

  static String getReferDetails = 'getReferDetails';
  static String orderCancel = 'orderCancel';

  static String stripePaymentCheckout = 'stripePaymentCheckout';
  static String stripeVerifyTransaction = 'stripeVerifyTransaction';

  static String createPaytmTxnToken = 'createPaytmTxnToken';

  static String faqs = 'faqs';
  static String allNotifications = 'allNotifications';
  static String recommendedProduct = 'recommendedProduct';
  static String orderDetailHistory = 'orderDetailHistory';
  static String reviewRating = 'review_rating';



  static final String txt_mobile = "Please enter your Mobile No. to proceed further";
  static final String txt_Submit = "Submit";
  static final String pleaseFullname = "Enter FullName";

  static final String delivrey = "Delievery";
  static final String pickup = "PickUP";
  static final String dine = "dine";


  static String otp = 'verifyOtp';


  static final String txt_OTP = "Please enter your One Time Password.We \n have sent the same to your number.";

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
  static String razorpayVerifyTransaction = '/razorpay/razorpayVerifyTransaction';
  static String orderHistory = '/orders/orderHistory';
  static String storeOffers = '/coupons/offersList';
}