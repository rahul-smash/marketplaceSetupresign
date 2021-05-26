import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/SideMenu/HtmlDisplayScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionTermsAndConditionsScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionTypeSelection.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionUtils.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/MembershipPlanResponse.dart';
import 'package:restroapp/src/models/UserPurchaseMembershipResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

class SubscribedPlanScreen extends StatefulWidget {
  @override
  _SubscribedPlanScreenState createState() => _SubscribedPlanScreenState();
}

class _SubscribedPlanScreenState extends State<SubscribedPlanScreen> {
  bool agree = false;
  MembershipPlanResponse _membershipPlanResponse;
  bool isApiLoading = false;

  @override
  void initState() {
    super.initState();
    _membershipPlanResponse =
        SingletonBrandData.getInstance().membershipPlanResponse;
    //fetching Subscription plan
    if (_membershipPlanResponse == null) _getSubscriptionPlan();
  }

  void _getSubscriptionPlan() {
    isApiLoading = true;
    ApiController.getSubscriptionMembershipPlan().then((value) {
      isApiLoading = false;
      if (value != null && value.success) {
        //Setting Subscription plan to globally (Singleton)
        SingletonBrandData.getInstance().membershipPlanResponse = value;
        _membershipPlanResponse = value;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Offers'),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: appTheme),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image(
                      image: AssetImage('images/bottomgraphic1.png'),
                      height: 150,
                    ),
                    Image(
                      image: AssetImage('images/bottomgraphic2.png'),
                      height: 80,
                    ),
                  ],
                ),
                isApiLoading
                    ? CircularProgressIndicator()
                    : Column(children: [
                        SizedBox(height: 20),
                        Image(
                            image: AssetImage('images/offergraphic1.png'),
                            height: 250,
                            width: 300),
                        Flexible(
                          child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Colors.white,
                                appTheme.withOpacity(0.1),
                                Colors.white
                              ])),
                              child: Center(
                                  child: Text(
                                      _membershipPlanResponse.data.planName,
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)))),
                        ),
                        Flexible(
                            flex: 1,
                            child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                  Colors.white,
                                  appTheme.withOpacity(0.1),
                                  Colors.white
                                ])),
                                child: Center(
                                    child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(
                                      child: Transform.translate(
                                        offset: const Offset(0.0, -4.0),
                                        child: Text(
                                          '${AppConstant.currency}',
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                        text:
                                            '${_membershipPlanResponse.data.planTotalCharges}',
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    WidgetSpan(
                                      child: Transform.translate(
                                        offset: const Offset(0.0, -7.0),
                                        child: Text(
                                          '*',
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ]),
                                )))),
                        SizedBox(height: 30),
                        Row(children: [
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: 10),
                            height: 60,
                            width: 120,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage('images/tickstarbg.png'),
                              child: Image(
                                image: AssetImage('images/startick.png'),
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: RichText(
                                text: TextSpan(
                                    text:
                                        '${convertSubscriptionDate(SingletonBrandData.getInstance().userPurchaseMembershipResponse.data.startDate)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18,
                                    ),
                                    children: [
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0.0, -6.0),
                                      child: Text(
                                        '_ ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${convertSubscriptionDate(SingletonBrandData.getInstance().userPurchaseMembershipResponse.data.endDate)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18,
                                    ),
                                  )
                                ])),
                          )
                        ]),

                        Visibility(
                          visible: SingletonBrandData.getInstance()
                              .userPurchaseMembershipResponse
                              .data
                              .status,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              RichText(
                                  text: TextSpan(
                                text: 'Cancel',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    showCancelSubscriptionDialog(
                                        context, _cancelSubscriptionPlan);
                                  },
                              )),
                            ],
                          ),
                        ),
                        Divider(
                          height: 50,
                          thickness: 2,
                          color: Colors.grey[300],
                          indent: 110,
                          endIndent: 110,
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Checkbox(
                              activeColor: appTheme,
                              value: agree,
                              onChanged: (value) {
                                setState(() {
                                  agree = value;
                                });
                              },
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'I accept ',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Terms & Conditions',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SubscriptionTermsAndConditionsScreen(
                                                        AdditionItemsConstants
                                                            .TERMS_CONDITIONS,
                                                        _membershipPlanResponse
                                                            .data.planTc)),
                                          );
                                        },
                                      style: TextStyle(
                                          color: appTheme,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          fontSize: 15)),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 170,
                          height: 40,
                          child: MaterialButton(
                              color: appThemeSecondary,
                              onPressed: () {
                                if (agree == true) {
                                  UserPurchaseMembershipResponse response =
                                      SingletonBrandData.getInstance()
                                          ?.userPurchaseMembershipResponse;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SubscriptionTypeSelection(
                                                  _membershipPlanResponse,
                                                  response != null &&
                                                          response.data !=
                                                              null &&
                                                          !response.data.status
                                                      ? MemberShipType.RENEW
                                                      : MemberShipType.NEW)));
                                } else {
                                  Utils.showToast(
                                      'Please check terms and conditions',
                                      false);
                                }
                              },
                              child: Text('Renew Now',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: appTheme))),
                        ),
                        SizedBox(height: 20),
//              RichText(
//                  text: TextSpan(
//                      text: '(Food - Rs 99 per day, Delivery - Rs 25 per day)',
//                      style: TextStyle(fontSize: 14, color: Colors.black),
//                      children: [
//                    WidgetSpan(
//                      child: Transform.translate(
//                        offset: const Offset(0.0, -3.0),
//                        child: Text(
//                          '*',
//                          style: TextStyle(
//                              fontSize: 19, fontWeight: FontWeight.bold),
//                        ),
//                      ),
//                    ),
//                  ])),
                      ]),
              ],
            )));
  }

  _cancelSubscriptionPlan() {
    Utils.showProgressDialog(context);
    ApiController.getCancelOnlineMembership(
            SingletonBrandData.getInstance()
                .userPurchaseMembershipResponse
                .data
                .id,
            SingletonBrandData.getInstance()
                .userPurchaseMembershipResponse
                .data
                .puchaseType)
        .then((value) async {
      Utils.hideProgressDialog(context);
      if (value != null && value.success) {
        ApiController.getUserMembershipPlanApi();
        bool result = await showCanceledSubscriptionDialog(context, () {
          Navigator.pop(context, true);
        });
        if (result) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    });
  }
}
