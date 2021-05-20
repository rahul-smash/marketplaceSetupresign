import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/SideMenu/HtmlDisplayScreen.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Utils.dart';

import 'TimeSelection.dart';


class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key key}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
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
          height:  MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/bottomgraphic1.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomLeft,
            )
          ),
          child: Column(
              children: [
                SizedBox(height: 20),
                Image(image: AssetImage('images/offergraphic1.png'), height: 250, width: 300),
                Flexible(
                  child: Container(
                    height: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
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
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Terms and Conditions',
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
                      child: Text('Buy Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      color: appTheme.withOpacity(0.8),
                      onPressed: (){
                        if(agree == true){
                          print('Buying');
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MealTime() ));
                        } else {
                          print('showing toast');
                          Utils.showToast('Please check terms and conditions',false);
                        }
                      }
                    ),
                  )
                ),
                Divider(thickness: 2, height: 40, indent: 40, endIndent: 40),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: 300,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Now, order your',style: TextStyle(color: Colors.black, fontSize: 17),
                        children: [
                          TextSpan(
                            text: ' favorite meal ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17)
                          ),
                          TextSpan(
                            text: 'on daily basis from any 1 of our 7 Brands and ', style: TextStyle(color: Colors.black, fontSize: 17)
                          ),
                          TextSpan(
                            text: 'SAVE upto \u{20B9} 6030 per month', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17)
                          )
                        ]
                      )
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 10),
                    child: RichText(
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
                  ),
                ),
              ],
            ),
        ),
        );
  }
}