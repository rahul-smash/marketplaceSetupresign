import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/SideMenu/HtmlDisplayScreen.dart';
import 'package:restroapp/src/Screens/Subscription/CancelAlert.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Utils.dart';

class SubscriptionRenew extends StatefulWidget {
  const SubscriptionRenew({Key key}) : super(key: key);

  @override
  _SubscriptionRenewState createState() => _SubscriptionRenewState();
}

class _SubscriptionRenewState extends State<SubscriptionRenew> {
  bool agree = false;
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
            child: Column(children: [
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
                        child: Text('30-day Meal Delivery Plan',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)))),
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
                                '\u{20B9}',
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TextSpan(
                              text: '3740',
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
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ]),
                      )))),
              SizedBox(height: 30),
              Row(
                children:[
                  Container(
                    alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 10),
                      height: 60,
                      width: 120,
                      child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('images/tickstarbg.png'),
                      child: Image(image: AssetImage('images/startick.png'), height: 25, width: 25,),
                      ),
                    ),
                  Expanded(
                    flex: 2,
                    child:  RichText(
                        text: TextSpan(
                            text: '7th May 2021 ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,),
                            children: [
                              WidgetSpan(
                                child: Transform.translate(
                                  offset: const Offset(0.0, -6.0),
                                  child: Text(
                                    '_ ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18,),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: '6th June 2021',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18,
                                ),
                              )
                            ]
                        )
                    ),
                  )
            ]
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RichText(
                      text: TextSpan(
                        text: 'Cancel',
                      style: TextStyle(fontSize: 17, color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CancelAlertBox()));
                              },)
                    ),
                  ],
              ),
              Divider(height: 50, thickness: 2, color: Colors.grey[300], indent: 110, endIndent: 110,),
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
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Terms & Conditions',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HtmlDisplayScreen(
                                          AdditionItemsConstants
                                              .TERMS_CONDITIONS)),
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
                  color: appTheme,
                  onPressed: (){
                    print('User Wants to renew');
                  },
                  child: Text(
                    'Renew Now', style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black
                  )
                  )
                ),
              ),
              SizedBox(height: 20),
              RichText(
                  text: TextSpan(
                      text: '(Food - Rs 99 per day, Delivery - Rs 25 per day)',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black),
                      children: [
                        WidgetSpan(
                          child: Transform.translate(
                            offset: const Offset(0.0, -3.0),
                            child: Text(
                              '*',
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ]
                  )
              ),
            ])));
  }
}
