import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/SideMenu/HtmlDisplayScreen.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionTypeSelection.dart';
import 'package:restroapp/src/Screens/Subscription/SubscriptionUtils.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/MembershipPlanResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

class SubscriptionPurchasedScreen extends StatefulWidget {
  @override
  _SubscriptionPurchasedScreenState createState() =>
      _SubscriptionPurchasedScreenState();
}

class _SubscriptionPurchasedScreenState
    extends State<SubscriptionPurchasedScreen> {
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
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            backgroundColor: appTheme),
        body: WillPopScope(
          onWillPop: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return Future(() => false);
          },
          child: Container(
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
                      : Container(
                          height: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Image(
                                      image: AssetImage(
                                          'images/congratulationgraphic.png'),
                                      height: 250,
                                      width: 300),
                                  Text('Congrats, Your\nSubscription for',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal)),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      '${_membershipPlanResponse.data.planName} is Active',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 30),
                                    Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'images/tickstarbg.png'),
                                                fit: BoxFit.cover)),
                                        height: 60,
                                        width: 60,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Image(
                                              image: AssetImage(
                                                  'images/startick.png'),
                                              height: 30,
                                              width: 20,
                                            ))),
                                  SizedBox(height: 30),
                                    Flexible(
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
                                    ),
                                  Divider(
                                    height: 30,
                                    thickness: 2,
                                    color: Colors.grey[300],
                                    indent: 110,
                                    endIndent: 110,
                                  ),
                                  SizedBox(height: 20),
                                  Visibility(
                                    visible: checkCurrentDateWithInThePlan(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                                text: 'You can Start placing\n',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                children: [
                                                  WidgetSpan(
                                                    child: Transform.translate(
                                                      offset: const Offset(
                                                          0.0, -3.0),
                                                      child: Text(
                                                        'orders from ${convertSubscriptionDate(SingletonBrandData.getInstance().userPurchaseMembershipResponse.data.modified)}',
                                                        style: TextStyle(
                                                            fontSize: 19,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ])),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                          width: 170,
                                          height: 40,
                                          child: MaterialButton(
                                              color: appThemeSecondary,
                                              onPressed: () {
                                                Navigator.of(context).popUntil(
                                                    (route) => route.isFirst);
                                              },
                                              child: Text('Order Now',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                      color: Colors.white))),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                ],
              )),
        ));
  }
}
