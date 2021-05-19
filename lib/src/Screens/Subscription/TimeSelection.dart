import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/Address/DeliveryAddressList.dart';
import 'package:restroapp/src/Screens/Subscription/CancelAlert.dart';
import 'package:restroapp/src/Screens/Subscription/CongratsVoucher.dart';
import 'package:restroapp/src/Screens/Subscription/DeliveryType.dart';
import 'package:restroapp/src/utils/AppColor.dart';

class MealTime extends StatefulWidget {
  const MealTime({Key key}) : super(key: key);

  @override
  _MealTimeState createState() => _MealTimeState();
}
class _MealTimeState extends State<MealTime> {

  bool SelectedMeal = false;
  Color color1 = Colors.grey[200];
  Color color2 = Colors.grey[200];
  Color checkColor1 = Colors.grey[200];
  Color checkColor2 = Colors.grey[200];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appTheme,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Select your Meal type',
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    )),
                SizedBox(height: 20),
                Row(
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          if(color1 == Colors.grey[200]){
                          color1 = appTheme;
                          color2 = Colors.grey[200];
                          checkColor1 = Colors.black;
                          checkColor2 = Colors.grey[200];
                          }
                        });
                      },
                      child: Container(
                              height: 100,
                              width: 150,
                              margin: EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                color: color1,
                              ),
                              child: Column(
                                children: [
                                  Align(alignment: Alignment.topRight,child: Icon(Icons.check, color: checkColor1)),
                                  Image(image: AssetImage('images/lunchicon.png'), height: 40, width: 80),
                                  SizedBox(height: 5),
                                  Text(
                                  'Lunch',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                        ]
                              )),
                    ),
                    SizedBox(width: 20),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'or',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: (){
                        setState(() {
                          if(color2 == Colors.grey[200]){
                            color2 = appTheme;
                            color1 = Colors.grey[200];
                            checkColor2 = Colors.black;
                            checkColor1 = Colors.grey[200];
                          }
                        });
                         },
                      child: Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: color2,
                              ),
                            child: Column(
                              children: [
                                Align(alignment: Alignment.topRight,child: Icon(Icons.check, color: checkColor2)),
                                Image(image: AssetImage('images/dinnericon.png'), height: 40, width: 80),
                                SizedBox(height: 5),
                                Text(
                                'Dinner',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),]
                            ),
                          ),
                    ),
                  ],
                ),
                Divider(height: 70, thickness: 2, indent: 80, endIndent: 80),
                Container(
                    height: 40,
                    width: 300,
                    color: appTheme,
                    child: MaterialButton(
                      child: Text('+ Add delivery Address',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                          textAlign: TextAlign.center),
                      onPressed: () {
                        print('Add your Address');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SelectDelivery()));
                      },
                    ))
              ],
            )));
  }
}