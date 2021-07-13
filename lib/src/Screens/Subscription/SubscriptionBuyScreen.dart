import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
          title: Text('Subscription'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: appTheme),
      body: Container(
        height: Utils.getDeviceHeight(context),
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
                : Container(
                    height: Utils.getDeviceHeight(context),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 40),
                          Image(
                              image: AssetImage('images/graphic1.png'),
                              height: 220,
                              width: 270),
                          Container(
                            padding: EdgeInsets.only(top: 20,bottom: 20),
                              width: 260,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Colors.white,
                                Colors.grey.withOpacity(0.2),
                                Colors.white
                              ])),
                              child: Column(children: [
                                Text('${_membershipPlanResponse.data.planName}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                Center(
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
                                )),
                              ])),
                          SizedBox(height: 20),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                height: 15,
                                width: 30,
                                child: Checkbox(
                                  activeColor: appTheme,
                                  value: agree,
                                  onChanged: (value) {
                                    setState(() {
                                      agree = value;
                                    });
                                  },
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'I accept ',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black),
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
                                                              .TERMS_CONDITIONS,
                                                          _membershipPlanResponse
                                                              .data.planTc)),
                                            );
                                          },
                                        style: TextStyle(
                                            color: appTheme,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 15)),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 40,
                            width: 150,
                            child: MaterialButton(
                                child: Text('Buy Now',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                color: appThemeSecondary,
                                onPressed: () {
                                  if (agree == true) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriptionTypeSelection(
                                                    _membershipPlanResponse,
                                                    MemberShipType.NEW)));
                                  } else {
                                    print('showing toast');
                                    Utils.showToast(
                                        'Please check terms and conditions',
                                        false);
                                  }
                                }),
                          ),
                          SizedBox(height: 20),
                          Divider(thickness: 2, indent: 75, endIndent: 75),
                          Container(
                            width: 300,
                            margin:
                                EdgeInsets.only(top: 15, left: 15, right: 15),
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: _membershipPlanResponse
                                          .data.planDescription,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 17),
                                    ))),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
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
