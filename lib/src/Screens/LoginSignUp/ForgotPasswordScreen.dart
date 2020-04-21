import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restroapp/src/Screens/Address/DeliveryAddressList.dart';
import 'package:restroapp/src/Screens/Address/PickUpOrderScreen.dart';
import 'package:restroapp/src/Screens/Dashboard/HomeScreen.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

class ForgotPasswordScreen extends StatefulWidget {

  String menu;
  ForgotPasswordScreen(this.menu);

  @override
  _ForgotPasswordScreen createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ForgotPasswordData forgotPwddData = new ForgotPasswordData();
  final emailController = new TextEditingController();

  StoreModel store;
  String otpSkip,pickupfacility,delieveryAdress;
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text('Forgot Password',style: new TextStyle(
          color: Colors.white,
        ),),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new Container(
                      padding: const EdgeInsets.only(top: 40.0),
                      margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                      child: new Text(
                        AppConstant.entertxForgotPssword,
                        style: new TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      )),
                  new TextFormField(
                    //    controller: phoneController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Email',
                      labelText: 'Enter Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                    val.isEmpty ? AppConstant.enterEmailAddress : null,

                    onSaved: (val) {
                      forgotPwddData.email = val;
                    },
                  ),
                  GestureDetector(
                    child: new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new Row(
                        children: [
                          // First child in the Row for the name and the
                          new Expanded(
                            // Name and Address are in the same column
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Code to create the view for name.
                                new Container(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, top: 10.0, right: 40.0),
                                    child: new RaisedButton(
                                      color: appTheme,
                                      textColor: Colors.white,
                                      child: Text(AppConstant.txtSendEmail,style: TextStyle(
                                        color: Colors.white,
                                      ),
                                      ),
                                      onPressed: _forgotPassword,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }




  void _forgotPassword() {
    print('@@_forgotPassword');

    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save(); //This invokes each onSaved event
      Utils.isNetworkAvailable().then((isNetworkAvailable) async {
        if (isNetworkAvailable) {
          Utils.showProgressDialog(context);
          ApiController.forgotPasswordApiRequest(forgotPwddData)
              .then((response) {
            Utils.hideProgressDialog(context);
            if (response != null && response.success) {
              print('@@----forgotPasswordApiRequest+'+response.success.toString());
             // Utils.showToast(response.message, true);
              //Navigator.pop(context);
              sowDialogForForgot(response.message);
            }
          });
        } else {
          Utils.showToast(AppConstant.noInternet, true);
        }
      });
    }
  }

  void sowDialogForForgot(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Success"),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();

              },
            ),
          ],
        );
      },
    );
  }
}

class ForgotPasswordData {
  String email;
}
