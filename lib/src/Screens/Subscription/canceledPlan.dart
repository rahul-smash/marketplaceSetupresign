import 'package:flutter/material.dart';

class CanceledPlan extends StatefulWidget {
  const CanceledPlan({Key key}) : super(key: key);

  @override
  _CanceledPlanState createState() => _CanceledPlanState();
}

class _CanceledPlanState extends State<CanceledPlan> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(children: [Text('Your plan'),Text('has been canceled.')]),
    );
  }
}
