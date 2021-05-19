import 'package:flutter/material.dart';
import 'package:restroapp/src/Screens/Subscription/canceledPlan.dart';
import 'package:restroapp/src/utils/AppColor.dart';

class CancelAlertBox extends StatefulWidget {
  const CancelAlertBox({Key key}) : super(key: key);

  @override
  _CancelAlertBoxState createState() => _CancelAlertBoxState();
}

class _CancelAlertBoxState extends State<CancelAlertBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Column(children: [
      Text('Sorry you won\'t get any refund on cancellation of this plan.', textAlign: TextAlign.center,),
          Divider(thickness: 2, indent: 50, endIndent: 50, height: 40),
          Text('Are you sure, you want to cancel your meal delivery plan?', textAlign: TextAlign.center,),
          SizedBox(height: 20,),
          MaterialButton(
            color: appTheme,
            child: Text('Proceed to Cancel'),
            onPressed: (){
              print('Your Subscription has been cancelled !');
              Navigator.push(context, MaterialPageRoute(builder: (context) => CanceledPlan()));
            },
          )
    ]),
    );
  }
}
