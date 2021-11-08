import 'package:flutter/material.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Utils.dart';

class SellStuff extends StatefulWidget {
  const SellStuff({key}) : super(key: key);

  @override
  _SellStuffState createState() => _SellStuffState();
}

class _SellStuffState extends State<SellStuff> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final storeNameController = new TextEditingController();
  final storeAddressController = new TextEditingController();
  final yourNameController = new TextEditingController();
  final yourEmailController = new TextEditingController();
  final phoneNumberController = new TextEditingController();
  final additionalDetailController = new TextEditingController();
  final businessTypeController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: new Text(
            "Sell",
            style: new TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Form(
                key: _formKey,
                autovalidate: true,
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Get Started',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextField(
                            controller: storeNameController,
                            decoration: InputDecoration(
                              labelText: 'Store Name *',
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
                            controller: storeAddressController,
                            decoration: InputDecoration(
                              labelText: 'Store Address *',
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
                                  controller: yourNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Your Name *',
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
                                child: TextField(
                                  controller: yourEmailController,
                                  decoration: InputDecoration(
                                    labelText: 'Your Email *',
                                  ),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF495056),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextField(
                            controller: phoneNumberController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number *',
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
                            controller: additionalDetailController,
                            decoration: InputDecoration(
                              labelText: 'Additional Detail *',
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
                            controller: businessTypeController,
                            decoration: InputDecoration(
                              labelText: 'Business Type *',
                            ),
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF495056),
                                fontWeight: FontWeight.w500),
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
                              child: Text("Send Your Message",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
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
      ),
    );
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
    if (yourNameController.text.trim().isEmpty) {
      Utils.showToast("Please enter your name", false);
      return false;
    } else if (storeNameController.text.trim().isEmpty) {
      Utils.showToast("Please enter your store's name", false);
    } else if (storeAddressController.text.trim().isEmpty) {
      Utils.showToast("Please enter your store's address", false);
    } else if (phoneNumberController.text.trim().isEmpty) {
      Utils.showToast("Please enter your phone number", false);
    } else if (businessTypeController.text.trim().isEmpty) {
      Utils.showToast("Please enter business type", false);
    } else if (additionalDetailController.text.trim().isEmpty) {
      Utils.showToast("Please enter additional details of your store.", false);
    } else if (!isValidEmail(yourEmailController.text.trim()) ||
        yourEmailController.text.trim().isEmpty) {
      Utils.showToast("Please enter a valid email address.", false);
    } else {
      return true;
    }
  }

  Future<void> _submitForm() async {
    if (!nameValidation()) {
      return;
    }
    if (!isValidEmail(yourEmailController.text.trim())) {
      Utils.showToast("Please enter valid email", false);
      return;
    }
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
    } else {
      form.save();
      ApiController.sellOptionsApi(
          yourNameController.text.trim(),
          yourEmailController.text.trim(),
          phoneNumberController.text.trim(),
          storeNameController.text.trim(),
          storeAddressController.text.trim(),
          additionalDetailController.text.trim(),
          businessTypeController.text.trim())
          .then((response) {
        Utils.hideProgressDialog(context);
        if (response.success) {
          Utils.showToast(response.message, true);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Utils.showToast(response.message, true);
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }
    ;
  }
}
