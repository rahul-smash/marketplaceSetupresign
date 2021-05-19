import 'package:flutter/material.dart';

class CongratsDialogue extends StatefulWidget {
  const CongratsDialogue({Key key}) : super(key: key);

  @override
  _CongratsDialogueState createState() => _CongratsDialogueState();
}

class _CongratsDialogueState extends State<CongratsDialogue> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Column(
      children: [
        Image(image: AssetImage('images/congratsgiftimage.png')),
        SizedBox(height: 10),
        Text(
          'Congrats,',
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'you will get',
          style: TextStyle(color: Colors.black, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
            WidgetSpan(
              child: Transform.translate(
                offset: const Offset(0.0, -8.0),
                child: Text(
                  '\u{20B9}',
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
              TextSpan(
                  text: '300',
                  style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ]
          )
        ),
        SizedBox(height: 10),
        RichText(
          text: TextSpan(
            text: 'discount ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black),
            children: [
              TextSpan(
                text: 'on this order',
                style: TextStyle(fontSize: 14,color: Colors.black)
              )
            ]
          )
        )
      ],
    ));
  }
}
