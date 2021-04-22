import 'package:restroapp/src/utils/AppConstants.dart';

String getLocationSearchPlaceHolderText() {
  return AppConstant
          .dynamicResponse?.data?.homepage?.locationSearchPlaceholder ??
      (AppConstant.isShowStaticPlaceHolder ? AppConstant.selectAddress : "");
}
String getSearchPlaceHolderText() {
  return AppConstant
          .dynamicResponse?.data?.homepage?.productSearchPlaceholder ??
      (AppConstant.isShowStaticPlaceHolder ? "Search" : "");
}

String getCategoryHeadingPlaceHolderText() {
  return AppConstant.dynamicResponse?.data?.homepage?.categoryHeading ??
      (AppConstant.isShowStaticPlaceHolder
          ? "Your neighbours are ordering.."
          : "");
}

String getTagHeadingPlaceHolderText() {
  return AppConstant.dynamicResponse?.data?.homepage?.tagHeading ??
      (AppConstant.isShowStaticPlaceHolder ? "Quick Links" : "");
}

String getStoreHeadingPlaceHolderText() {
  return AppConstant.dynamicResponse?.data?.homepage?.storeHeading ??
      (AppConstant.isShowStaticPlaceHolder ? "Restaurants" : "");
}

String getStoreShowAllPlaceHolderText() {
  return AppConstant.dynamicResponse?.data?.homepage?.storeShowAll ??
      (AppConstant.isShowStaticPlaceHolder ? "View All" : "");
}
