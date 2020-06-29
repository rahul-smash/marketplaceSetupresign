import 'dart:io';
import 'package:flutter/material.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Utils.dart';

class ProfileScreen extends StatefulWidget {

  bool isComingFromOtpScreen;
  String id;
  ProfileScreen(this.isComingFromOtpScreen,this.id);

  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  UserModel user;

  final firstNameController = new TextEditingController();
  final lastNameController = new TextEditingController();
  final emailController = new TextEditingController();
  final phoneController = new TextEditingController();
  final referCodeController = new TextEditingController();

  File image;
  StoreModel storeModel;
  bool isEmailEditable = false;
  bool isPhonereadOnly = true;

  @override
  initState() {
    super.initState();
    getProfileData();
  }

  getProfileData() async {
    //User Login with Mobile and OTP
    // 1 = email and 0 = ph-no
    user = await SharedPrefs.getUser();
    storeModel = await SharedPrefs.getStore();
    setState(() {
      firstNameController.text = user.fullName;
      emailController.text = user.email;
      phoneController.text = user.phone;
      if(storeModel.internationalOtp == "0"){
        isEmailEditable = false;
      }else{
        isEmailEditable = true;
        isPhonereadOnly = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: new Text(widget.isComingFromOtpScreen == true ? 'SignUp' : "My Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(20, 25, 20, 20),
          child: SafeArea(
            top: false,
            bottom: false,
            child: new Form(
              key: _formKey,
              autovalidate: true,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Center(
                          child: Icon(Icons.account_circle,size: 100,color: Colors.grey,),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: 'Full name *',
                          ),
                          style: TextStyle(fontSize: 18,
                              color: Color(0xFF495056),fontWeight: FontWeight.w500
                          ),
                        ),

                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text("Private Information",style: TextStyle(
                            fontSize: 16,color: Color(0xFF8F9396),fontWeight: FontWeight.w500),
                        ),
                      ),*/
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextField(
                          controller: referCodeController,
                          decoration: InputDecoration(
                            labelText: 'Referral Code',
                          ),
                          style: TextStyle(fontSize: 18,
                              color: Color(0xFF495056),fontWeight: FontWeight.w500
                          ),
                        ),

                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextField(
                          readOnly: isEmailEditable,
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                          style: TextStyle(
                              fontSize: 18,color: Color(0xFF495056),fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: TextField(
                          readOnly: isPhonereadOnly,
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                          ),
                          style: TextStyle(
                              fontSize: 18,color: Color(0xFF495056),fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0,left: 20,right: 20),
                        child: ButtonTheme(
                          height: 40,
                          minWidth: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            onPressed: (){
                              _submitForm();
                            },
                            color: orangeColor,
                            shape : RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Update",style: TextStyle(color: Colors.white,fontSize: 18)),
                                SizedBox(width: 6),
                                Image.asset("images/rightArrow.png",width: 15,height: 15,),
                              ],
                            ),
                          ),
                        ) ,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  bool isValidEmail(String input) {
    final RegExp regex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(input);
  }

  void _submitForm() {

    if(firstNameController.text.trim().isEmpty){
      Utils.showToast("Please enter your name", false);
      return;
    }

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
    } else {
      form.save();
      Utils.showProgressDialog(context);
      ApiController.updateProfileRequest(firstNameController.text, emailController.text,
          phoneController.text,widget.isComingFromOtpScreen,widget.id,
          referCodeController.text).then((response) {
        Utils.hideProgressDialog(context);
        if (response.success) {
          if(widget.isComingFromOtpScreen){

            UserModel user = UserModel();
            user.fullName =  firstNameController.text.trim();
            user.email =  emailController.text.trim();
            user.phone =  phoneController.text.trim();
            user.id = widget.id;
            Utils.showToast(response.message, true);
            SharedPrefs.saveUser(user);
            SharedPrefs.setUserLoggedIn(true);
            Navigator.pop(context);

          }else{
            user.fullName =  firstNameController.text.trim();
            user.email =  emailController.text.trim();
            user.phone =  phoneController.text.trim();
            Utils.showToast(response.message, true);
            SharedPrefs.saveUser(user);
            Navigator.pop(context);
          }
        }else{
          Utils.showToast(response.message, true);
        }

      });

    }
  }
}
