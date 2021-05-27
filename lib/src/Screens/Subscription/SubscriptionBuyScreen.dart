import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/SideMenu/HtmlDisplayScreen.dart';
import 'package:restroapp/src/Screens/Subscription/BaseState.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionTermsAndConditionsScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionUtils.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/MembershipPlanResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

import 'SubscriptionTypeSelection.dart';

class SubscriptionBuyScreen extends StatefulWidget {

  @override
  _SubscriptionBuyScreenState createState() => _SubscriptionBuyScreenState();
}

class _SubscriptionBuyScreenState extends BaseState<SubscriptionBuyScreen> {
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
                : Column(
                    children: [
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
                      SizedBox(height: 20),
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
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Terms and Conditions',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SubscriptionTermsAndConditionsScreen(
                                                      AdditionItemsConstants
                                                          .TERMS_CONDITIONS,_membershipPlanResponse.data.planTc)),
                                        );
                                      },
                                    style: TextStyle(
                                        color: appTheme,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      Flexible(
                          child: Container(
                        height: 40,
                        width: 150,
                        child: MaterialButton(
                            child: Text('Buy Now',
                                style: TextStyle(
                                    color: appTheme,
                                    fontWeight: FontWeight.bold)),
                            color: appThemeSecondary,
                            onPressed: () {
                              if (agree == true) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionTypeSelection(_membershipPlanResponse,MemberShipType.NEW)));
                              } else {
                                print('showing toast');
                                Utils.showToast(
                                    'Please check terms and conditions', false);
                              }
                            }),
                      )),
                      Divider(
                          thickness: 2, height: 40, indent: 40, endIndent: 40),
                      Expanded(
                          flex: 2,
                          child: Container(
                            width: 300,
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
//                                    text: 'Now, order your',
                                  text: _membershipPlanResponse
                                      .data.planDescription,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 17),
                                  /* children: [
                                      TextSpan(
                                          text: ' favorite meal ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 17)),
                                      TextSpan(
                                          text:
                                              'on daily basis from any 1 of our 7 Brands and ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17)),
                                      TextSpan(
                                          text:
                                              'SAVE upto \u{20B9} 6030 per month',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontSize: 17))
                                    ]*/
                                )),
                          )),
//                      Expanded(
//                        flex: 1,
//                        child: Container(
//                          alignment: Alignment.bottomCenter,
//                          margin: EdgeInsets.only(bottom: 10),
//                          child: RichText(
//                              text: TextSpan(
//                                  text:
//                                      '(Food - Rs 99 per day, Delivery - Rs 25 per day)',
//                                  style: TextStyle(
//                                      fontSize: 14, color: Colors.black),
//                                  children: [
//                                WidgetSpan(
//                                  child: Transform.translate(
//                                    offset: const Offset(0.0, -3.0),
//                                    child: Text(
//                                      '*',
//                                      style: TextStyle(
//                                          fontSize: 19,
//                                          fontWeight: FontWeight.bold),
//                                    ),
//                                  ),
//                                ),
//                              ])),
//                        ),
//                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
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
}
