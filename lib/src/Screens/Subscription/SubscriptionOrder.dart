import 'package:flutter/material.dart';
import 'package:restroapp/src/utils/AppColor.dart';

class SubscriptionOrder extends StatefulWidget {
  const SubscriptionOrder({Key key}) : super(key: key);

  @override
  _SubscriptionOrderState createState() => _SubscriptionOrderState();
}

class _SubscriptionOrderState extends State<SubscriptionOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appTheme,
        actions: [
          Container(
            width: 50,
            margin: EdgeInsets.only(right: 10),
            child: InkWell(
              child: Image(
                  image: AssetImage('images/cancelicon.png'),
                  height: 10,
                  width: 10),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ]
      ),
      body: Container(
        height:  MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(height: 20),
            Image(image: AssetImage('images/congratulationgraphic.png'), height: 250, width: 300),
            SizedBox(height: 10),
            Container(
              child: Text(
                'Congrats, Your', style: TextStyle(
                fontSize: 21,
              ),
              ),
            ),
            Container(
              child: Text(
                'Subscription for', style: TextStyle(
                fontSize: 20,
              ),
              ),
            ),
            Container(
              child: Text(
                '30-day Meal Delivery is Active', style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              height: 60,
              width: 120,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/tickstarbg.png'),
                child: Image(image: AssetImage('images/startick.png'), height: 25, width: 25,),
              ),
            ),
            SizedBox(height: 20),
            // Text('7th May 2021 - 6th June 2021',
            //   style: TextStyle(
            //     color: Colors.grey[600],
            //     fontSize: 18,
            //   ),
            // ),
            RichText(
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
            Divider(thickness: 2, height: 50, indent: 100, endIndent: 100,),
            Text(
              'You can start placing',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              'orders from today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 170,
              height: 40,
              child: MaterialButton(
                  color: appTheme,
                  onPressed: (){
                    print('User Wants to renew');
                  },
                  child: Text(
                      'Order Now', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black
                  )
                  )
              ),
            ),
          ],
        ),
      )
    );
  }
}
