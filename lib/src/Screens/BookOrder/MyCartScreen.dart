import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:restroapp/src/UI/CartBottomView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class MyCartScreen extends StatefulWidget {
  final VoidCallback callback;

  MyCartScreen(this.callback);

  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final CartTotalPriceBottomBar bottomBar =
      CartTotalPriceBottomBar(ParentInfo.cartList);
  DatabaseHelper databaseHelper = new DatabaseHelper();
  List<Product> cartList = List();
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    getCartListFromDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MY CART"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          Visibility(
            visible: cartList.isEmpty ? false : true,
            child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: IconButton(
                icon: Image.asset('images/cancel_cart.png', width: 25),
                onPressed: () async {
                  var result = await DialogUtils.displayCommonDialog2(context,
                      "Clear Cart?", AppConstant.emptyCartMsg, "Cancel", "Yes");
                  if (result == true) {
                    print("Yes");
                    setState(() {
                      databaseHelper.deleteTable(DatabaseHelper.CART_Table);
                      getCartListFromDB();
                      eventBus.fire(updateCartCount());
                      eventBus.fire(onCartRemoved());
                      bottomBar.state.updateTotalPrice();
                      widget.callback();
                    });
                  }
                },
              ),
            ),
          ),
          Visibility(
            visible: cartList.isNotEmpty,
            child: InkWell(
              onTap: () {
                eventBus.fire(openHome());
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Padding(
                padding:
                    EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0, right: 10),
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      body: WillPopScope(
          child: Column(
            children: <Widget>[
              Divider(color: Colors.white, height: 2.0),
              isLoading ? Utils.getIndicatorView() : showCartList(),
              //TODO: add here
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Wrap(
                    children: [bottomBar],
                  ),
                ),
              )
            ],
          ),
          onWillPop: () async {
            Navigator.pop(context);
            return new Future(() => false);
          }),
      floatingActionButton: cartList.length == 0
          ? FloatingActionButton.extended(
              backgroundColor: appThemeSecondary,
              onPressed: () async {
                eventBus.fire(openHome());
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: Image.asset(
                'images/restauranticon.png',
                width: 20,
                color: Colors.white,
              ),
              label: Text("Home"),
            )
          : Container(),
    );
  }

  void getCartListFromDB() {
    isLoading = true;
    databaseHelper.getCartItemList().then((response) {
      setState(() {
        cartList = response;
        isLoading = false;
        eventBus.fire(updateCartCount());
        _getSelectedStore(cartList.length);
      });
    });
  }

  Widget showCartList() {
    if (cartList.length == 0) {
      return Container(
        child: Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "images/empty_cart.png",
                  fit: BoxFit.fill,
                  width: 100,
                  height: 100,
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Your Cart is Empty",
                    overflow: TextOverflow.ellipsis,
                    style: new TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    )),
              ],
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: cartList.length,
          itemBuilder: (context, index) {
            Product product = cartList[index];
            return ProductTileItem(product, () {
              //print("----bottomBar.updateTotalPrice----");
              bottomBar.state.updateTotalPrice();
              widget.callback();
            }, ClassType.CART);
          },
        ),
      );
    }
  }

  void _getSelectedStore(int length) async {
    if (length != null && length > 0) {
      StoreDataObj store = await SharedPrefs.getStoreData();
//      Utils.showProgressDialog(context);
      ApiController.getStoreVersionData(store.id).then((response) {
//        Utils.hideProgressDialog(context);
        Utils.hideKeyboard(context);
        StoreDataModel storeObject = response;
        if (storeObject != null && storeObject.success)
          setState(() {
            SharedPrefs.saveStoreData(storeObject.store);
          });
      });
    }
  }
}
