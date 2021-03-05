import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/FacebookModel.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Utils.dart';

class ProfileScreen extends StatefulWidget {
  bool isComingFromOtpScreen;
  String id;
  String fullName = "";
  FacebookModel fbModel;
  GoogleSignInAccount googleResult;
  bool isAppleLogin = false;
  String appleMail = "";

  ProfileScreen(this.isComingFromOtpScreen, this.id, String fullName,
      this.fbModel, this.googleResult,
      {this.isAppleLogin = false, this.appleMail});

  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  UserModelMobile user;
  bool showGstNumber = false;
  final firstNameController = new TextEditingController();
  final lastNameController = new TextEditingController();
  final emailController = new TextEditingController();
  final phoneController = new TextEditingController();
  final referCodeController = new TextEditingController();
  final gstCodeController = new TextEditingController();
  bool isLoginViaSocial = false;

  File image;
  BrandData storeModel;
  bool isEmailEditable = false;
  bool isPhonereadOnly = true;
  bool showReferralCodeView = false;

  var controllerStartDate = TextEditingController();
//  var controllerGender = TextEditingController();
  String gender='Male';

  DateTime selectedStartDate;

  List<String> _categories=List();

  @override
  initState() {
    super.initState();
    _categories.add('Male');
    _categories.add('Female');
    _categories.add('Other');
    gender='Male';
    getProfileData();
  }

  getProfileData() async {
    //User Login with Mobile and OTP
    // 1 = email and 0 = ph-no
    try {
      user = await SharedPrefs.getUserMobile();
    } catch (e) {
      print(e);
    }
    storeModel = await BrandModel.getInstance().brandVersionModel.brand;
    setState(() {
      if (user != null) {
        firstNameController.text = user.fullName;
        lastNameController.text = user.lastName;
        controllerStartDate.text = user.dob;
        gender = user.gender.trim().isNotEmpty?user.gender:'Male';
        emailController.text = user.email;
        phoneController.text = user.phone;
      }
      print("storeModel.isRefererFnEnable=${storeModel.isRefererFnEnable}");
      if (storeModel.isRefererFnEnable && widget.fullName.isEmpty) {
        showReferralCodeView = true;
      } else {
        showReferralCodeView = false;
      }
      if (!widget.isComingFromOtpScreen) {
        showReferralCodeView = false;
      }
      if (storeModel.allowCustomerForGst != null &&
          storeModel.allowCustomerForGst.toLowerCase() == 'yes') {
        showGstNumber = true;
      } else {
        showGstNumber = false;
      }
      if (storeModel.internationalOtp == "0") {
        isEmailEditable = false;
      } else {
        isEmailEditable = true;
        isPhonereadOnly = false;
        showReferralCodeView = false;
      }

      if (widget.fbModel != null) {
        print("----------widget.fbModel != null---------");
        firstNameController.text = widget.fbModel.name;
        emailController.text = widget.fbModel.email;
        isPhonereadOnly = false;
        isLoginViaSocial = true;
      }
      if (widget.googleResult != null) {
        print("----------widget.googleResult != null---------");
        firstNameController.text = widget.googleResult.displayName;
        emailController.text = widget.googleResult.email;
        isPhonereadOnly = false;
        isLoginViaSocial = true;
      }
      if (widget.isAppleLogin) {
        print("----------widget.isAppleLogin != null---------");
        firstNameController.text = widget.fullName;
        emailController.text = widget.appleMail;
        isPhonereadOnly = false;
        isLoginViaSocial = true;
      }

      if (isLoginViaSocial) {
        if (widget.fbModel != null) {
          if (widget.fbModel.email.isEmpty) {
            isEmailEditable = false;
          }
        } else if (widget.googleResult != null) {
          if (widget.googleResult.email.isEmpty) {
            isEmailEditable = false;
          }
        } else if (widget.isAppleLogin) {
          if (widget.appleMail.isEmpty) {
            isEmailEditable = false;
          }
        }
      }

      if (storeModel.internationalOtp == "1" && isLoginViaSocial) {
        if (widget.fbModel != null) {
          if (widget.fbModel.email.isNotEmpty) {
            isEmailEditable = true;
          }
        } else if (widget.googleResult != null) {
          if (widget.googleResult.email.isNotEmpty) {
            isEmailEditable = true;
          }
        }
      }else{
        if(phoneController.text==null){
          isPhonereadOnly=false;
        }
        else if(phoneController.text!=null&&phoneController.text.isEmpty){
          isPhonereadOnly=false;
        }
      }

      print(
          "showReferralCodeView=${showReferralCodeView} and ${storeModel.isRefererFnEnable}");
    });
  }

  Future<DateTime> selectDate(
    BuildContext context, {
    bool isStartIndex,
    bool isEndIndex,
  }) async {
    DateTime selectedDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        currentDate: DateTime.now(),
        firstDate: DateTime(1970, 1),
        lastDate: DateTime(2101, 1));
    print(picked);
    if (picked != null)
      //dayName = DateFormat('DD-MM-yyyy').format(selectedDate);
      return picked;
  }

  @override
  Widget build(BuildContext context) {
    //print("showReferralCodeView=${showReferralCodeView} and ${storeModel.isRefererFnEnable}");
    return WillPopScope(
        onWillPop: () async {
          if (storeModel != null) {
            if (phoneController.text.trim().isEmpty) {
              Utils.showToast("Please enter your valid mobile number", false);
              return false;
            }
          }
          return await nameValidation() && isValidEmail(emailController.text);
        },
        child: new Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: new Text("My Profile"),
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
                              child: Icon(
                                Icons.account_circle,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First name *',
                              ),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF495056),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: 'last name *',
                              ),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF495056),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: TextField(
                                    controller: controllerStartDate,
                                    onTap: () async {
                                      selectedStartDate = await selectDate(
                                          context,
                                          isStartIndex: true);
                                      if (selectedStartDate != null) {
                                        String date = DateFormat('dd-MM-yyyy')
                                            .format(selectedStartDate);
                                        setState(() {
                                          controllerStartDate.text = date;
                                        });
                                      }
                                    },
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Date of birth *',
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.calendar_today,
                                          ),
                                          onPressed: () {}),
                                    ),
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF495056),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: DropdownButtonFormField(
                                    dropdownColor: Colors.white,
                                    items:_categories
                                        .map((String category) {
                                      return new DropdownMenuItem(
                                          value: category,
                                          child: Row(
                                            children: <Widget>[
                                              Text(category),
                                            ],
                                          ));
                                    }).toList(),
                                    onTap: (){

                                    },
                                    onChanged: (newValue) {
                                      // do other stuff with _category
                                      setState(() =>
                                          gender = newValue);
                                    },
                                    value: gender,
                                    decoration: InputDecoration(
//                                      contentPadding:
//                                          EdgeInsets.fromLTRB(10, 20, 10, 20),
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: 'Gender',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /*Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text("Private Information",style: TextStyle(
                            fontSize: 16,color: Color(0xFF8F9396),fontWeight: FontWeight.w500),
                        ),
                      ),*/
                          Visibility(
                            visible: showReferralCodeView,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextField(
                                controller: referCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Referral Code',
                                ),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF495056),
                                    fontWeight: FontWeight.w500),
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
                                  fontSize: 18,
                                  color: Color(0xFF495056),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: TextField(
                              readOnly: isPhonereadOnly,
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Phone number',
                              ),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF495056),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Visibility(
                            visible:
                                widget.isComingFromOtpScreen && showGstNumber,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: TextField(
                                controller: gstCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Enter Your GST number',
                                ),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF495056),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 35.0, left: 20, right: 20),
                            child: ButtonTheme(
                              height: 40,
                              minWidth: MediaQuery.of(context).size.width,
                              child: RaisedButton(
                                onPressed: () {
                                  _submitForm();
                                },
                                color: appThemeSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Update",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18)),
                                    SizedBox(width: 6),
                                    Image.asset(
                                      "images/rightArrow.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  bool isValidEmail(String input) {
    //Email is opation
    if (input.trim().isEmpty) return true;
    final RegExp regex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    bool isMatch = regex.hasMatch(input);
    if (!isMatch) Utils.showToast("Please enter valid email", false);
    return isMatch;
  }

  bool nameValidation() {
    if (firstNameController.text.trim().isEmpty) {
      Utils.showToast("Please enter your first name", false);
      return false;
    } else if (lastNameController.text.trim().isEmpty) {
      Utils.showToast("Please enter your last name", false);
      return false;
    } else if (gender.trim().isEmpty) {
      Utils.showToast("Please select your gender", false);
      return false;
    } else if (controllerStartDate.text.trim().isEmpty) {
      Utils.showToast("Please select your Date of birth", false);
      return false;
    } else {
      return true;
    }
  }

  Future<void> _submitForm() async {
    if (!nameValidation()) {
      return;
    }
    if (!isValidEmail(emailController.text.trim())) {
      Utils.showToast("Please enter valid email", false);
      return;
    }
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
    } else {
      form.save();

      if (storeModel != null) {
//        if(storeModel.internationalOtp == "0"){
        if (phoneController.text.trim().isEmpty) {
          Utils.showToast("Please enter your valid mobile number", false);
          return;
        }
//        }
      }

      if (isLoginViaSocial) {
        Utils.showProgressDialog(context);
        MobileVerified userResponse = await ApiController.socialSignUp(
            widget.fbModel,
            widget.googleResult,
            firstNameController.text.trim(),
            emailController.text.trim(),
            phoneController.text.trim(),
            referCodeController.text.trim(),
            gstCodeController.text.trim(),
            appleLogin: widget.isAppleLogin ? 'apple' : '',
            lastName: lastNameController.text.trim());

        UserModel user = UserModel();
        user.fullName = firstNameController.text.trim();
        user.lastName = lastNameController.text.trim();
        user.dob = controllerStartDate.text.trim();
        user.gender = gender.trim();
        user.email = emailController.text.trim();
        user.phone = phoneController.text.trim();
        user.id = userResponse.user.id;
        SharedPrefs.saveUser(user);

        Utils.hideProgressDialog(context);
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ApiController.updateProfileRequest(
                firstNameController.text.trim(),
                emailController.text.trim(),
                phoneController.text.trim(),
                widget.isComingFromOtpScreen,
                widget.id,
                referCodeController.text.trim(),
                gstCodeController.text.trim(),
                lastName: lastNameController.text.trim(),dob:controllerStartDate.text.trim(),gender:gender.trim())
            .then((response) {
          Utils.hideProgressDialog(context);
          if (response.success) {
            if (widget.isComingFromOtpScreen) {
              UserModelMobile user = UserModelMobile();
              user.fullName = firstNameController.text.trim();
              user.lastName = lastNameController.text.trim();
              user.dob = controllerStartDate.text.trim();
              user.gender = gender.trim();
              user.email = emailController.text.trim();
              user.phone = phoneController.text.trim();
              user.id = widget.id;
              Utils.showToast(response.message, true);
              SharedPrefs.saveUserMobile(user);
              SharedPrefs.setUserLoggedIn(true);
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else {
              user.fullName = firstNameController.text.trim();
              user.lastName = lastNameController.text.trim();
              user.dob = controllerStartDate.text.trim();
              user.gender = gender.trim();
              user.email = emailController.text.trim();
              user.phone = phoneController.text.trim();
              Utils.showToast(response.message, true);
              SharedPrefs.saveUserMobile(user);
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } else {
            Utils.showToast(response.message, true);
          }
        });
      }
    }
  }
}
