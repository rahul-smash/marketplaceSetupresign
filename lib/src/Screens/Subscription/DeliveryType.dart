import 'package:flutter/material.dart';
import 'package:restroapp/src/utils/AppColor.dart';

import 'CongratsVoucher.dart';

class SelectDelivery extends StatefulWidget {
  const SelectDelivery({Key key}) : super(key: key);

  @override
  _SelectDeliveryState createState() => _SelectDeliveryState();
}

class _SelectDeliveryState extends State<SelectDelivery> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              child: Image(
                  image: AssetImage('images/cancelicon.png'),
                  height: 20,
                  width: 20
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Text('Select Your Option', style: TextStyle(color: Colors.black)),
          Divider(
              color: appTheme,
              thickness: 2,
              indent: 90,
              endIndent: 90,
              height: 30),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CongratsDialogue()));
            },
              child: Image(
                  image: AssetImage('images/nextdaydelivery.png'),
                  height: 130,
                  width: 130)),
          Text('30-day meal delivery plan -',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('next day delivery',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          Divider(height: 30, thickness: 2, indent: 40, endIndent: 40),
          InkWell(
            child: Image(
                image: AssetImage('images/delivernow.png'),
                height: 130,
                width: 130),
          ),
          Text('Deliver Now!\"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Divider(height: 30, thickness: 2, indent: 40, endIndent: 40),
          InkWell(
            child: Image(
                image: AssetImage('images/pickup.png'),
                height: 130,
                width: 130),
          ),
          Text('Pick Up',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
