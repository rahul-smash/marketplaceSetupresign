import 'package:restroapp/src/models/MembershipPlanResponse.dart';
import 'package:restroapp/src/models/UserPurchaseMembershipResponse.dart';
import 'package:restroapp/src/models/VersionModel.dart';

class SingletonBrandData {
  final BrandVersionModel brandVersionModel;

  SingletonBrandData({
    this.brandVersionModel,
  });

  static SingletonBrandData _instance;

  static SingletonBrandData getInstance({brandVersionModelObj}) {
    if (_instance == null) {
      _instance = SingletonBrandData(brandVersionModel: brandVersionModelObj);
      return _instance;
    }
    return _instance;
  }

  /*Subscription plan details*/
  MembershipPlanResponse _membershipPlanResponse;

  MembershipPlanResponse get membershipPlanResponse => _membershipPlanResponse;

  set membershipPlanResponse(MembershipPlanResponse value) {
    _membershipPlanResponse = value;
  }

  UserPurchaseMembershipResponse _userPurchaseMembershipResponse;

  UserPurchaseMembershipResponse get userPurchaseMembershipResponse =>
      _userPurchaseMembershipResponse;

  set userPurchaseMembershipResponse(
      UserPurchaseMembershipResponse userPurchaseMembershipResponse) {
    _userPurchaseMembershipResponse = userPurchaseMembershipResponse;
  }

  //Clear User Plan details
  clearData() {
    userPurchaseMembershipResponse = null;
  }
}
