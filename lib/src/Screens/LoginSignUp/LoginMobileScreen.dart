import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restroapp/src/Screens/LoginSignUp/OtpScreen.dart';
import 'package:restroapp/src/Screens/SideMenu/HtmlDisplayScreen.dart';
import 'package:restroapp/src/Screens/SideMenu/ProfileScreen.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/BrandModel.dart';
import 'package:restroapp/src/models/FacebookModel.dart';
import 'package:restroapp/src/models/MobileVerified.dart';
import 'package:restroapp/src/models/UserResponseModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'dart:io';

class LoginMobileScreen extends StatefulWidget {
  String menu;

  LoginMobileScreen(this.menu);

  @override
  _LoginMobileScreen createState() => _LoginMobileScreen(menu);
}

class _LoginMobileScreen extends State<LoginMobileScreen> {
  String menu;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  LoginMobile loginMobile = new LoginMobile();
  final phoneController = new TextEditingController();
  BrandData store;
  FacebookLogin facebookSignIn = new FacebookLogin();
  GoogleSignIn _googleSignIn;
  GoogleSignInAccount _currentUser;

  bool agree = false;

  _LoginMobileScreen(this.menu);

  @override
  void initState() {
    super.initState();
    store = SingletonBrandData.getInstance().brandVersionModel.brand;
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
        print("displayName=${_currentUser.displayName}");
        print("email=${_currentUser.email}");
        print("id=${_currentUser.id}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: new Text(
          'Login',
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Utils.hideKeyboard(context);
            return Navigator.pop(context, false);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: Utils.getDeviceWidth(context),
                  child: AppConstant.isRestroApp
                      ? Image.asset(
                          "images/login_restro_bg.jpg",
                          fit: BoxFit.fitWidth,
                        )
                      : Image.asset(
                          "images/login_img.jpg",
                          fit: BoxFit.fitWidth,
                        ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 40.0),
                              child: Text(
                                AppConstant.txt_mobile,
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              )),
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              hintText: 'Mobile Number',
                              labelText: 'Mobile Number',
                            ),
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            validator: (val) =>
                                val.isEmpty ? AppConstant.enterPhone : null,
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                            ],
                            onSaved: (val) {
                              loginMobile.phone = val;
                            },
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                  left: 0.0, top: 0.0, right: 0.0),
                              child: new RaisedButton(
                                color: appThemeSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                textColor: Colors.white,
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: _submitForm,
                              )),
                          Visibility(
                            visible: Platform.isIOS
                                ? false
                                : store == null
                                    ? false
                                    : store.social_login == "0"
                                        ? false
                                        : true,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              width: Utils.getDeviceWidth(context),
                              child: Center(
                                child: Text(
                                  "OR CONNECT WITH",
                                  style: TextStyle(color: gray9),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: Platform.isIOS
                                ? false
                                : store == null
                                    ? false
                                    : store.social_login == "0"
                                        ? false
                                        : true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (!agree) {
                                      selectTermsAndConditionMessage();
                                      return;
                                    }
                                    print("------fblogin------");
                                    bool isNetworkAvailable =
                                        await Utils.isNetworkAvailable();
                                    if (!isNetworkAvailable) {
                                      Utils.showToast(
                                          AppConstant.noInternet, true);
                                      return;
                                    }

                                    bool isFbLoggedIn =
                                        await facebookSignIn.isLoggedIn;
                                    print("isFbLoggedIn=${isFbLoggedIn}");
                                    if (isFbLoggedIn) {
                                      await facebookSignIn.logOut();
                                    }

                                    fblogin();
                                  },
                                  child: Container(
                                      width:
                                          Utils.getDeviceWidth(context) / 2.6,
                                      margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                      decoration: BoxDecoration(
                                          color: fbblue,
                                          border: Border.all(
                                            color: fbblue,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                            child: Image.asset(
                                                "images/f_logo_white.png",
                                                height: 25.0),
                                          ),
                                          Expanded(
                                              child: Container(
                                            margin:
                                                EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            child: Text(
                                              "Facebook",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ))
                                        ],
                                      )),
                                ),
                                Container(
//                                  height: 35,
                                  width: Utils.getDeviceWidth(context) / 2.6,
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
                                  child: _googleSignInButton(),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                              visible: Platform.isIOS ? false : false,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5)),
                                margin: EdgeInsets.only(bottom: 60),
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: AppleSignInButton(
                                    onPressed: appleLogIn,
                                  ),
                                ),
                              )),
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
                                  text: 'I agree to the ',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Terms and Conditions',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HtmlDisplayScreen(
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
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        if (!agree) {
          selectTermsAndConditionMessage();
          return;
        }

        bool isNetworkAvailable = await Utils.isNetworkAvailable();
        if (!isNetworkAvailable) {
          Utils.showToast(AppConstant.noInternet, true);
        } else {
          bool isGoogleSignedIn = await _googleSignIn.isSignedIn();
          print("isGoogleSignedIn=${isGoogleSignedIn}");
          if (isGoogleSignedIn) {
            await _googleSignIn.signOut();
          }

          try {
            GoogleSignInAccount result = await _googleSignIn.signIn();
            if (result != null) {
              print("result.id=${result.id}");

              Utils.showProgressDialog(context);
              MobileVerified verifyEmailModel =
                  await ApiController.verifyEmail(result.email);
              Utils.hideProgressDialog(context);
              if (verifyEmailModel.userExists == 0) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                          true, "", "${result.displayName}", null, result)),
                );
              } else if (verifyEmailModel.userExists == 1) {
                SharedPrefs.setUserLoggedIn(true);
                SharedPrefs.saveUserMobile(verifyEmailModel.user);
                UserModel user = UserModel();
                user.fullName = verifyEmailModel.user.fullName;
                user.email = verifyEmailModel.user.email;
                user.phone = verifyEmailModel.user.phone;
                user.id = verifyEmailModel.user.id;
                SharedPrefs.saveUser(user);
                ApiController.getUserMembershipPlanApi();
                Navigator.pop(context);
              }
            } else {
//              Utils.showToast("Something went wrong while login!", false);
            }
          } catch (error) {
            print("catch.googleSignIn=${error}");
          }
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("images/google_logo.png"), height: 25.0),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Google',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Future<Null> fblogin() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        FacebookAccessToken accessToken = result.accessToken;
        Utils.showProgressDialog(context);
        FacebookModel fbModel =
            await ApiController.getFbUserData(accessToken.token);
        if (fbModel != null) {
          print("email=${fbModel.email} AND id=${fbModel.id}");

          MobileVerified verifyEmailModel =
              await ApiController.verifyEmail(fbModel.email);
          Utils.hideProgressDialog(context);
          if (verifyEmailModel.userExists == 0) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                      true, "", "${fbModel.name}", fbModel, null)),
            );
          } else if (verifyEmailModel.userExists == 1) {
            SharedPrefs.setUserLoggedIn(true);
            SharedPrefs.saveUserMobile(verifyEmailModel.user);

            UserModel user = UserModel();
            user.fullName = verifyEmailModel.user.fullName;
            user.email = verifyEmailModel.user.email;
            user.phone = verifyEmailModel.user.phone;
            user.id = verifyEmailModel.user.id;
            SharedPrefs.saveUser(user);
            ApiController.getUserMembershipPlanApi();
            Navigator.pop(context);
          }
        } else {
//          Utils.showToast("Something went wrong while login!", false);
          Utils.hideProgressDialog(context);
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        //_showMessage('Login cancelled by the user.');
        Utils.showToast("Login cancelled", false);
        break;
      case FacebookLoginStatus.error:
        Utils.showToast("Something went wrong ${result.errorMessage}", false);
        break;
    }
  }

  appleLogIn() async {
    if (await AppleSignIn.isAvailable()) {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          var credential = result.credential;
          var id = credential.user;
          print("this is iddd $id");
          print(result.credential.email);
          print(result.credential.fullName.givenName);
          print(result.credential.fullName.familyName);
          String email = result.credential.email ?? "";
          String name =
              "${result.credential.fullName.givenName} ${result.credential.fullName.familyName}";

          if (email == "") {
            email = await SharedPrefs.getappleId();
          } else {
            SharedPrefs.setAppleId(email);
          }

          if (email == "") {
            Utils.showToast("Email id require for sign in", false);
          } else {
            MobileVerified verifyEmailModel =
                await ApiController.verifyEmail(email);
            Utils.hideProgressDialog(context);
            if (verifyEmailModel.userExists == 0) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                          true,
                          "",
                          "${name}",
                          null,
                          null,
                          appleMail: email,
                          isAppleLogin: true,
                        )),
              );
            } else if (verifyEmailModel.userExists == 1) {
              SharedPrefs.setUserLoggedIn(true);
              SharedPrefs.saveUserMobile(verifyEmailModel.user);

              UserModel user = UserModel();
              user.fullName = verifyEmailModel.user.fullName;
              user.email = verifyEmailModel.user.email;
              user.phone = verifyEmailModel.user.phone;
              user.id = verifyEmailModel.user.id;
              SharedPrefs.saveUser(user);
              ApiController.getUserMembershipPlanApi();
              Navigator.pop(context);
            }
          }
          break; //All the required credentials
        case AuthorizationStatus.error:
          Utils.showToast(result.error.localizedDescription, false);
          break;
        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } else {
      Utils.showToast('Apple SignIn is not available for your device', false);
    }
  }

  void _submitForm() {
    print('@@MENUGET' + menu);

    final FormState form = _formKey.currentState;
    if (!agree) {
      selectTermsAndConditionMessage();
      return;
    }
    if (form.validate()) {
      form.save(); //This invokes each onSaved event
      Utils.isNetworkAvailable().then((isNetworkAvailable) async {
        if (isNetworkAvailable) {
          Utils.showProgressDialog(context);
          ApiController.mobileVerification(loginMobile).then((response) {
            Utils.hideProgressDialog(context);
            if (response != null && response.success) {
              print(
                  "=====otpVerify===${response.user.otpVerify}--and--${response.userExists}-----");
              //Code commented due to Client Request
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OtpScreen(menu, response, loginMobile)),
                //    MaterialPageRoute(builder: (context) => LoginScreen()),
              );
//              if (response.userExists == 1) {
//                print(
//                    '@@userExists=${response.userExists} and otpSkip = ${response.user.otpVerify}');
//                if (response.success) {
//                  SharedPrefs.setUserLoggedIn(true);
//                  SharedPrefs.saveUserMobile(response.user);
//                }
//                Navigator.pop(context);
//              } else {
//                //print('@@NOTP__Screen');
//                Navigator.pop(context);
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) =>
//                          OtpScreen(menu, response, loginMobile)),
//                  //    MaterialPageRoute(builder: (context) => LoginScreen()),
//                );
//              }
            }
          });
        } else {
          Utils.showToast(AppConstant.noInternet, true);
        }
      });
    } else {
      Utils.showToast("Please enter Mobile number", true);
    }
  }

  void selectTermsAndConditionMessage() {
    Utils.showToast('Please select Terms and Conditions!', true);
  }
}

void _showMessage(String s) {
  print("_showMessage=${s}");
}

class LoginMobile {
  String phone;
}
