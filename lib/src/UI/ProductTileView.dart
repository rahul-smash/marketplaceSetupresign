import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:restroapp/src/Screens/Dashboard/ProductDetailScreen.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/models/CartTableData.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';
import 'package:html/parser.dart';

class ProductTileItem extends StatefulWidget {
  Product product;
  VoidCallback callback;
  ClassType classType;
  CustomCallback favCallback;
  List<String> tagsList = List();

  ProductTileItem(this.product, this.callback, this.classType,
      {this.favCallback});

  @override
  _ProductTileItemState createState() => _ProductTileItemState();
}

class _ProductTileItemState extends State<ProductTileItem> {
  DatabaseHelper databaseHelper = new DatabaseHelper();
  int counter = 0;
  CartData cartData;
  Variant variant;
  bool showAddButton;

  bool _isProductOutOfStock = false;

  @override
  initState() {
    super.initState();
    showAddButton = false;
    getDataFromDB();
    listenCartEvent();
    _checkOutOfStock(findNext: true);
  }

  @override
  void didUpdateWidget(ProductTileItem oldWidget) {
    super.didUpdateWidget(oldWidget);
//    getDataFromDB();
  }

  void getDataFromDB() {
    databaseHelper
        .getProductQuantitiy(
            variant == null ? widget.product.variantId : variant.id)
        .then((cartDataObj) {
      cartData = cartDataObj;
      counter = int.parse(cartData.QUANTITY);
      showAddButton = counter == 0 ? true : false;
      setState(() {});
    });
//    databaseHelper
//        .checkProductsExistInFavTable(
//            DatabaseHelper.Favorite_Table, widget.product.id)
//        .then((favValue) {
//      setState(() {
//        widget.product.isFav = favValue.toString();
//        if (widget.favCallback != null)
//          widget.favCallback(value: widget.product.isFav);
//      });
//    });
  }

  void listenCartEvent() {
    eventBus.on<onCartRemoved>().listen((event) {
      setState(() {
        counter = 0;
        showAddButton = true;
      });
    });
//    eventBus.on<onFavRemoved>().listen((event) {
//      databaseHelper
//          .checkProductsExistInFavTable(
//              DatabaseHelper.Favorite_Table, widget.product.id)
//          .then((favValue) {
//        setState(() {
//          widget.product.isFav = favValue.toString();
//          if (widget.favCallback != null)
//            widget.favCallback(value: widget.product.isFav);
//        });
//      });
//    });
    eventBus.on<onCounterUpdate>().listen((event) {
      setState(() {
        if (widget.product.id.compareTo(event.productId) == 0) {
          String vID = variant == null ? widget.product.variantId : variant.id;
          print("Product= ${widget.product.title} ");
          if (vID != null &&
              event.variantId != null &&
              vID.compareTo(event.variantId) == 0) {
            counter = event.counter;
            if (counter == 0) {
              showAddButton = true;
            } else {
              showAddButton = false;
            }
          }
        }
      });
    });

    eventBus.on<OnProductTileDbRefresh>().listen((event) {
      getDataFromDB();
    });
  }

  @override
  Widget build(BuildContext context) {
    String discount, price, variantId, weight, mrpPrice;
    variantId = variant == null ? widget.product.variantId : variant.id;
    if (variant == null) {
      discount = widget.product.discount.toString();
      price = widget.product.price.toString();
      weight = widget.product.weight;
      mrpPrice = widget.product.mrpPrice;
    } else {
      discount = variant.discount.toString();
      price = variant.price.toString();
      weight = variant.weight;
      mrpPrice = variant.mrpPrice;
    }
    String imageUrl = widget.product.imageType == "0"
        ? widget.product.image == null
            ? widget.product.image10080
            : widget.product.image
        : widget.product.imageUrl;
    bool variantsVisibility;
    variantsVisibility = widget.classType == ClassType.CART
        ? true
        : widget.product.variants != null &&
                widget.product.variants.isNotEmpty &&
                widget.product.variants.length >= 1
            ? true
            : false;

    if (weight.isEmpty) {
      variantsVisibility = false;
    }
    if (widget.product.tags != null && widget.product.tags.trim().length > 0) {
      widget.tagsList = widget.product.tags.split(',');
    }

    return Container(
      padding: EdgeInsets.only(top: 15),
//      color: listingBoxBackgroundColor,
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () async {
            //print("----print-----");
            if (widget.classType != ClassType.CART) {
              var result = await Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ProductDetailsScreen(widget.product, variant),
                    fullscreenDialog: true,
                  ));
              setState(() {
                if (result != null) {
                  variant = result;
                  discount = variant.discount.toString();
                  price = variant.price.toString();
                  weight = variant.weight;
                  variantId = variant.id;
                } else {
                  variantId = variant==null? widget.product.variantId:variant.id;
                }
                _checkOutOfStock(findNext: false);
                databaseHelper
                    .getProductQuantitiy(variantId)
                    .then((cartDataObj) {
                  setState(() {
                    cartData = cartDataObj;
                    counter = int.parse(cartData.QUANTITY);
                    showAddButton = counter == 0 ? true : false;
                  });
                });
//                databaseHelper
//                    .checkProductsExistInFavTable(
//                        DatabaseHelper.Favorite_Table, widget.product.id)
//                    .then((favValue) {
//                  setState(() {
//                    widget.product.isFav = favValue.toString();
//                    if (widget.favCallback != null)
//                      widget.favCallback(value: widget.product.isFav);
//                  });
//                });
                widget.callback();
                eventBus.fire(updateCartCount());
              });
            }
          },
          child: Padding(
              padding: EdgeInsets.only(top: 0, bottom: 15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Padding(
                          padding: EdgeInsets.only(top: 0),
                          child: Stack(
                            children: <Widget>[
                              imageUrl == ""
                                  ? Container(
                                      width: 75.0,
                                      height: 75.0,
                                      child: Utils.getImgPlaceHolder(),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 7, right: 20, top: 5),
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              left: 2, top: 2,
                                              right: 2,bottom: 2),
                                          decoration:  BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          width: 75.0,
                                          height: 75.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: CachedNetworkImage(
                                                imageUrl: "${imageUrl}",
                                                fit: BoxFit.fill),
                                          ))),
                              Visibility(
                                visible: (discount == "0.00" ||
                                        discount == "0" ||
                                        discount == "0.0")
                                    ? false
                                    : true,
                                child: Container(
                                  child: Text(
                                    "${discount.contains(".00") ? discount.replaceAll(".00", "") : discount}% OFF",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10.0),
                                  ),
                                  margin: EdgeInsets.only(left: 0),
                                  padding: EdgeInsets.all(5),
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: yellow,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        bottomRight: Radius.circular(15.0)),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _isProductOutOfStock,
                                child: Container(
                                  height: 80.0,
                                  color: Colors.white54,
                                  child: Center(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.red, width: 1),
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5)),
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Text(
                                            "Out of Stock",
                                            style: TextStyle(
                                                color: Colors.red, fontSize: 12),
                                          ),
                                        )),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                            child: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Visibility(
                                          visible: AppConstant.isRestroApp,
                                          child: addVegNonVegOption(),
                                        ),
                                        Expanded(
                                          child: Text("${widget.product.title}",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                color: productHeadingColor,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ),
//                                        Align(
//                                          alignment: Alignment.centerRight,
//                                          child: InkWell(
//                                            onTap: () async {
//                                              int count = await databaseHelper
//                                                  .checkProductsExistInFavTable(
//                                                      DatabaseHelper
//                                                          .Favorite_Table,
//                                                      widget.product.id);
//
//                                              Product product = widget.product;
//                                              if (count == 1) {
//                                                product.isFav = "0";
//                                                if (widget.classType ==
//                                                    ClassType.Favourites) {
//                                                  eventBus.fire(onFavRemoved());
//                                                }
//                                                await databaseHelper.deleteFav(
//                                                    DatabaseHelper
//                                                        .Favorite_Table,
//                                                    product.id);
//                                              } else if (count == 0) {
//                                                String variantId,
//                                                    weight,
//                                                    mrpPrice,
//                                                    price,
//                                                    discount,
//                                                    isUnitType;
//                                                variantId = variant == null
//                                                    ? widget.product.variantId
//                                                    : variant.id;
//                                                weight = variant == null
//                                                    ? widget.product.weight
//                                                    : variant.weight;
//                                                mrpPrice = variant == null
//                                                    ? widget.product.mrpPrice
//                                                    : variant.mrpPrice;
//                                                price = variant == null
//                                                    ? widget.product.price
//                                                    : variant.price;
//                                                discount = variant == null
//                                                    ? widget.product.discount
//                                                    : variant.discount;
//                                                isUnitType = variant == null
//                                                    ? widget.product.isUnitType
//                                                    : variant.unitType;
//
//                                                product.isFav = "1";
//                                                product.variantId = variantId;
//                                                product.weight = weight;
//                                                product.mrpPrice = mrpPrice;
//                                                product.price = price;
//                                                product.discount = discount;
//                                                product.isUnitType = isUnitType;
//                                                insertInFavTable(
//                                                    product, counter);
//                                              }
//                                              if (widget.favCallback != null)
//                                                widget.favCallback(
//                                                    value: product.isFav);
//                                              widget.callback();
//                                              setState(() {});
//                                            },
//                                            child: Visibility(
//                                              //TODO:uncomment this
////                                              visible: widget.classType ==
////                                                      ClassType.CART
////                                                  ? false
////                                                  : true,
//                                              visible:
//                                                  /*widget.classType ==
//                                                          ClassType
//                                                              .Favourites ||
//                                                      widget.classType ==
//                                                          ClassType.Home ||
//                                                      widget.classType ==
//                                                          ClassType.Search
//                                                  ? true:*/
//                                                  false,
//                                              child: Container(
//                                                height: 30,
//                                                width: 30,
//                                                decoration: BoxDecoration(
//                                                  color: widget.classType ==
//                                                          ClassType.CART
//                                                      ? Colors.white
//                                                      : favGrayColor,
//                                                  border: Border.all(
//                                                    color: favGrayColor,
//                                                    width: 1,
//                                                  ),
//                                                  borderRadius:
//                                                      BorderRadius.all(
//                                                          Radius.circular(5.0)),
//                                                ),
//                                                margin: EdgeInsets.fromLTRB(
//                                                    0, 5, 20, 0),
//                                                child: Visibility(
//                                                  visible: widget.classType ==
//                                                          ClassType.CART
//                                                      ? false
//                                                      : true,
//                                                  child: widget.classType ==
//                                                          ClassType.Favourites
//                                                      ? Icon(
//                                                          Icons.favorite,
//                                                          color: appTheme,
//                                                        )
//                                                      : Utils.showFavIcon(
//                                                          widget.product.isFav),
//                                                ),
//                                              ),
//                                            ),
//                                          ),
//                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          (discount == "0.00" ||
                                                  discount == "0" ||
                                                  discount == "0.0")
                                              ? Text(
                                                  "${AppConstant.currency}${price}",
                                                  style: TextStyle(
                                                      color:
                                                          productHeadingColor,
                                                      fontWeight:
                                                          FontWeight.w400,fontSize: 16.0),
                                                )
                                              : Row(
                                                  children: <Widget>[
                                                    Text(
                                                      "${AppConstant.currency}${price}",
                                                      style: TextStyle(
                                                          color:
                                                              productHeadingColor,
                                                          fontWeight:
                                                              FontWeight.w400,fontSize: 16.0),
                                                    ),
                                                    Text(" "),
                                                    Text(
                                                        "${AppConstant.currency}${mrpPrice}",
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            color:
                                                                staticHomeDescriptionColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400,fontSize: 14.0)),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        // color: Colors.blue,
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 10, top: 5, bottom: 5),
                                            child: Text(
                                              removeAllHtmlTags(
                                                  "${widget.product.description}"),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      staticHomeDescriptionColor,
                                                  fontWeight: FontWeight.w400),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: addQuantityView(variantId),
                                        ),
                                      ],
                                    ))
//                                    Visibility(
//                                      visible: (widget.product.tags == null ||
//                                              widget.product.tags.trim() == "")
//                                          ? false
//                                          : true,
//                                      child: Padding(
////                                        padding: EdgeInsets.only(top: 5, bottom: 15, left: 20),
//                                        padding: EdgeInsets.only(
//                                          top: 5,
//                                        ),
//                                        child: _makeTags(),
//                                      ),
//                                    ),
                                  ],
                                ))),
                      ],
                    )),
                  ])),
        ),
        Visibility(
            visible: variantsVisibility,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10, left: 15),
              child: widget.product.variants != null
                  ? Wrap(
                      children: widget.product.variants
                          .map((f) => GestureDetector(
                                child: Container(
                                  height: 35,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 3.0),
                                  margin: EdgeInsets.only(
                                      left: 5.0,right: 5.0,top: 5.0, bottom: 5.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: (f.id == (variant == null ? widget.product.variantId : variant.id))
                                              ? Colors.transparent
                                              : staticCategoryListingButtonBorderColor,
                                          width: 1.0),
                                      borderRadius: BorderRadius.all( Radius.circular( 5.0)  ),
                                      color: (f.id ==(variant == null ? widget.product.variantId : variant.id))
                                          ? appThemeSecondary
                                          : categoryListingBoxBackgroundColor
                                  ),
                                  child: priceContainer(f),
                                ),
                                onTap: () {
                                  if (widget.product.variants.length != null) {
                                    if (widget.product.variants.length == 1) {
                                      return;
                                    }
                                  }
                                  variant = f;
                                  if (variant != null) {
                                    databaseHelper
                                        .getProductQuantitiy(variant.id)
                                        .then((cartDataObj) {
                                      cartData = cartDataObj;
                                      counter = int.parse(cartData.QUANTITY);
                                      showAddButton =
                                          counter == 0 ? true : false;
                                      setState(() {});
                                    });
                                  }
                                  _checkOutOfStock(findNext: false);
                                },
                              ))
                          .toList(),
                    )
                  : Container(),
            )),
        Container(
            height: 5,
            width: MediaQuery.of(context).size.width,
            color: listingBorderColor)
      ]),
    );
  }

  priceContainer(Variant v) {
    var weight = (v.weight == null || v.weight == " " || v.weight == "")
        ? ""
//        : "${v.weight} -";
        : "${v.weight}";
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        /* Visibility(
          visible: (v.id ==
                  (variant == null ? widget.product.variantId : variant.id))
              ? true
              : false,
          child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: Image.asset(
                "images/tickicon.png",
                width: 15,
                height: 15,
              )),
        ),*/
        Padding(
            padding: EdgeInsets.only(right: 0),
//            padding: EdgeInsets.only(right: 8),
            child: Text("$weight",
                style: TextStyle(
                    color: (v.id == (variant == null? widget.product.variantId: variant.id))
                        ? whiteColor
                        : darkGrey))),
        /* (v.discount == "0.00" || v.discount == "0" || v.discount == "0.0")
            ? Text(
                "${AppConstant.currency}${v.price}",
                style: TextStyle(
                    color: (v.id ==
                            (variant == null
                                ? widget.product.variantId
                                : variant.id))
                        ? whiteColor
                        : appTheme,
                    fontWeight: FontWeight.w600),
              )
            : Row(
                children: <Widget>[
                  Text("${AppConstant.currency}${v.mrpPrice}",
                      style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: (v.id ==
                                  (variant == null
                                      ? widget.product.variantId
                                      : variant.id))
                              ? whiteColor
                              : appTheme,
                          fontWeight: FontWeight.w400)),
                  Text(" "),
                  Text(
                    "${AppConstant.currency}${v.price}",
                    style: TextStyle(
                        color: (v.id ==
                                (variant == null
                                    ? widget.product.variantId
                                    : variant.id))
                            ? whiteColor
                            : appTheme,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),*/
      ],
    );
  }

  Widget addQuantityView(String variantID) {
    return Wrap(
      children: <Widget>[
        Container(
          //color: orangeColor,
//      width: 90,
          height: 30,
          decoration: BoxDecoration(
              color: categoryListingBoxBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              border: Border.all(
                color: showAddButton
                    ? staticCategoryListingButtonBorderColor
                    : whiteColor,
                width: 1,
              )),
          margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
          child: showAddButton
              ? InkWell(
                  onTap: () async {
                    print("---1-----add onTap------------");
                    bool checkIfDifferentStore = await checkIfDifferentStoreInCart(widget.product);
                    if(checkIfDifferentStore){
                      return;
                    }
                    if (_checkStockQuantity(counter)) {
                      setState(() {});
                      counter++;
                      showAddButton = false;
                      insertInCartTable(widget.product, counter);
                      widget.callback();
                      eventBus.fire(
                          onCounterUpdate(
                              counter, widget.product.id, variantID));
                    }
                    },
                  child: Container(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Center(
                      child: Text(
                        "ADD +",
                        style: TextStyle(
                            color: appThemeSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              : Visibility(
                  visible: showAddButton == true ? false : true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: webThemeCategoryOpenColor,
                      border: Border.all(
                        color: staticCategoryListingButtonBorderColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(0.0),
                          width: 25.0, // you can adjust the width as you need
                          child: GestureDetector(
                              onTap: () async {
                                bool checkIfDifferentStore = await checkIfDifferentStoreInCart(widget.product);
                                if(checkIfDifferentStore){
                                  return;
                                }
                                print("--2------remove onTap------------");
                                if (counter != 0) {
                                  setState(() => counter--);
                                  if (counter == 0) {
                                    // delete from cart table
                                    removeFromCartTable(
                                        widget.product.variantId);
                                  } else {
                                    // insert/update to cart table
                                    insertInCartTable(widget.product, counter);
                                  }
                                  widget.callback();
                                } else {
                                  setState(() {
                                    showAddButton = true;
                                  });
                                }
                                eventBus.fire(onCounterUpdate(
                                    counter, widget.product.id, variantID));
                              },
                              child: Container(
                                width: 35,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: categoryListingBoxBackgroundColor,
                                  border: Border.all(
                                    color: categoryListingBoxBackgroundColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5.0),
                                      bottomLeft: Radius.circular(5.0)),
                                ),
                                child: Icon(Icons.remove,
                                    color: appThemeSecondary, size: 20),
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
//              width: 20.0,
                          decoration: new BoxDecoration(
                            color: webThemeCategoryOpenColor,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(15.0)),
                            border: new Border.all(
                              color: webThemeCategoryOpenColor,
                              width: 1.0,
                            ),
                          ),
                          child: Center(
                              child: Text(
                            "$counter",
                            style: TextStyle(
                                fontSize: 18, color: appThemeSecondary),
                          )),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0.0),
                          width: 25.0, // you can adjust the width as you need
                          child: GestureDetector(
                            onTap: () async {
                              print("--3------add onTap------------");
                              bool checkIfDifferentStore = await checkIfDifferentStoreInCart(widget.product);
                              if(checkIfDifferentStore){
                                return;
                              }
                              if (_checkStockQuantity(counter)) {
                                setState(() => counter++);
                                if (counter == 0) {
                                  // delete from cart table
                                  removeFromCartTable(widget.product.variantId);
                                } else {
                                  // insert/update to cart table
                                  insertInCartTable(widget.product, counter);
                                }
                                eventBus.fire(onCounterUpdate(
                                    counter, widget.product.id, variantID));
                              }},
                            child: Container(
                                width: 35,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: categoryListingBoxBackgroundColor,
                                  border: Border.all(
                                    color: categoryListingBoxBackgroundColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0)),
                                ),
                                child: Icon(Icons.add,
                                    color: appThemeSecondary, size: 20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        )
      ],
    );
  }

  Widget addVegNonVegOption() {
    Color foodOption =
        widget.product.nutrient.toLowerCase() == "Non Veg".toLowerCase()
            ? Colors.red
            : Colors.green;
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 7),
      child: widget.product.nutrient == "None"
          ? Container()
          : Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border.all(
                  color: foodOption,
                  width: 1.0,
                ),
              ),
              width: 14,
              height: 14,
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Container(
                    decoration: new BoxDecoration(
                  color: foodOption,
                  borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                )),
              )),
    );
  }

  Future<bool> checkIfDifferentStoreInCart(Product product) async {
    bool showInfoToEmptyCart = false;
    List<Product> cartItemList  = await databaseHelper.getCartItemList();
    print("count=${cartItemList.length}");
    if(cartItemList.isEmpty){
      showInfoToEmptyCart = false;
    }else{
      print("--storeId =>${product.storeId}");
      Product cartProduct = cartItemList[0];
      if(cartProduct.storeId == product.storeId){
        // same store and do nothing 389981
        showInfoToEmptyCart = false;
      }else{
        // User has selected differnt store to add in cart.
        print("--storeName =>${product.storeName} and ${cartProduct.storeName}");
        String msgBody = AppConstant.getCartReplaceMsg(cartProduct.storeName,product.storeName);
//        bool result = await DialogUtils.displayDialog(context, "Replace Cart?", "${msgBody}", "No", "Yes");
        bool result = await DialogUtils.displayCartReplaceDialog(context, "${msgBody}");
        print("result=${result}");
        if(result){
          await databaseHelper.deleteTable(DatabaseHelper.CART_Table);
          showInfoToEmptyCart = false;
        }else{
          showInfoToEmptyCart = true;
        }
      }
    }
    return showInfoToEmptyCart;
  }

  void insertInCartTable(Product product, int quantity) {
    String variantId, weight, mrpPrice, price, discount, isUnitType;
    variantId = variant == null ? widget.product.variantId : variant.id;
    weight = variant == null ? widget.product.weight : variant.weight;
    mrpPrice = variant == null ? widget.product.mrpPrice : variant.mrpPrice;
    price = variant == null ? widget.product.price : variant.price;
    discount = variant == null ? widget.product.discount : variant.discount;
    isUnitType = variant == null ? widget.product.isUnitType : variant.unitType;

    var mId = int.parse(product.id);
    //String variantId = product.variantId;

    Map<String, dynamic> row = {
      DatabaseHelper.ID: mId,
      DatabaseHelper.VARIENT_ID: variantId,
      DatabaseHelper.WEIGHT: weight,
      DatabaseHelper.MRP_PRICE: mrpPrice,
      DatabaseHelper.PRICE: price,
      DatabaseHelper.DISCOUNT: discount,
      DatabaseHelper.UNIT_TYPE: isUnitType,
      DatabaseHelper.PRODUCT_ID: product.id,
      DatabaseHelper.isFavorite: product.isFav,
      DatabaseHelper.QUANTITY: quantity.toString(),
      DatabaseHelper.IS_TAX_ENABLE: product.isTaxEnable,
      DatabaseHelper.Product_Name: product.title,
      DatabaseHelper.nutrient: product.nutrient,
      DatabaseHelper.description: product.description,
      DatabaseHelper.imageType: product.imageType,
      DatabaseHelper.imageUrl: product.imageUrl,

      DatabaseHelper.StoreId: product.storeId,
      DatabaseHelper.CategoryId: product.categoryIds,
      DatabaseHelper.Brand: product.brand,
      DatabaseHelper.GstTaxType: product.gstTaxType,
      DatabaseHelper.GstTaxRate: product.gstTaxRate,
      DatabaseHelper.Rating: product.rating,
      DatabaseHelper.Deleted: product.deleted.toString(),
      DatabaseHelper.tags: product.tags,
      DatabaseHelper.storeName: product.storeName,

      DatabaseHelper.image_100_80:
          product.image == null ? product.image10080 : product.image,
      DatabaseHelper.image_300_200: product.image300200,
    };

    databaseHelper
        .checkIfProductsExistInDb(DatabaseHelper.CART_Table, variantId)
        .then((count) {
      //print("-count-- ${count}");
      if (count == 0) {
        databaseHelper.addProductToCart(row).then((count) {
          widget.callback();
          eventBus.fire(updateCartCount());
        });
      } else {
        databaseHelper.updateProductInCart(row, variantId).then((count) {
          widget.callback();
          eventBus.fire(updateCartCount());
        });
      }
    });
  }

  void removeFromCartTable(String variant_Id) {
    try {
      //print("------removeFromCartTable-------");
      String variantId;
      variantId = variant == null ? variant_Id : variant.id;
      databaseHelper.delete(DatabaseHelper.CART_Table, variantId).then((count) {
        widget.callback();
        eventBus.fire(updateCartCount());
      });
    } catch (e) {
      print(e);
    }
  }

//  void insertInFavTable(Product product, int quantity) {
//    var mId = int.parse(product.id);
//    String productJson = JsonEncoder().convert(product.toJson());
//    //print("${productJson}");
//
//    Map<String, dynamic> row = {
//      DatabaseHelper.ID: mId,
//      DatabaseHelper.VARIENT_ID: product.variantId,
//      DatabaseHelper.PRODUCT_ID: product.id,
//      DatabaseHelper.WEIGHT: product.weight,
//      DatabaseHelper.isFavorite: product.isFav,
//      DatabaseHelper.Product_Json: productJson,
//      DatabaseHelper.MRP_PRICE: product.mrpPrice,
//      DatabaseHelper.PRICE: product.price,
//      DatabaseHelper.DISCOUNT: product.discount,
//      DatabaseHelper.QUANTITY: quantity.toString(),
//      DatabaseHelper.IS_TAX_ENABLE: product.isTaxEnable,
//      DatabaseHelper.Product_Name: product.title,
//      DatabaseHelper.UNIT_TYPE: product.isUnitType,
//      DatabaseHelper.nutrient: product.nutrient,
//      DatabaseHelper.description: product.description,
//      DatabaseHelper.imageType: product.imageType,
//      DatabaseHelper.imageUrl: product.imageUrl,
//      DatabaseHelper.image_100_80: product.image10080,
//      DatabaseHelper.image_300_200: product.image300200,
//      DatabaseHelper.StoreId: product.storeId,
//      DatabaseHelper.CategoryId: product.categoryIds,
//      DatabaseHelper.Brand: product.brand,
//      DatabaseHelper.GstTaxType: product.gstTaxType,
//      DatabaseHelper.GstTaxRate: product.gstTaxRate,
//      DatabaseHelper.Rating: product.rating,
//      DatabaseHelper.Deleted: product.deleted.toString(),
//      DatabaseHelper.tags: product.tags,
//      DatabaseHelper.storeName: product.storeName,
//
//    };
//
//    databaseHelper.addProductToFavTable(row).then((count) {
//      //print("-------count--------${count}-----");
//    });
//  }

  _makeTags() {
    List<Widget> widgetTagsList = List();
    Widget tagView(String tag, int index) {
      return Padding(
//        padding: EdgeInsets.only(left: 2),
        padding: EdgeInsets.only(left: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Visibility(
              visible: true,
              child: Image.asset(
                "images/starIcon.png",
                width: 20,
                height: 20,
                color: index % 2 != 0 ? yellow : appTheme,
              ),
            ),
            Flexible(
                child: Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(tag,
                  style: TextStyle(
                      color: index % 2 != 0 ? yellow : appTheme,
                      fontWeight: FontWeight.w600)),
            ))
          ],
        ),
      );
    }

    for (int i = 0; i < widget.tagsList.length; i++) {
      widgetTagsList.add(tagView(widget.tagsList[i], i));
      break;
    }
    return Wrap(
      children: widgetTagsList,
    );
  }

  String removeAllHtmlTags(String htmlText) {
    try {
      var document = parse(htmlText);
      String parsedString = parse(document.body.text).documentElement.text;
      return parsedString;
    } catch (e) {
      print(e);
      return "";
    }

//    RegExp exp = RegExp(
//        r"<[^>]*>",
//        multiLine: true,
//        caseSensitive: true
//    );
//
//    return htmlText.replaceAll(exp, '');
  }

  _checkOutOfStock({bool findNext = false}) async {
    _isProductOutOfStock = false;
//1)min_alert
//if product min_stock_alert  number is less than or equal to the product stock -> make the product oos
//2)threshold_quantity -
//if product stock number is less than or equal to zero -> make the product oos
//3)continue_selling -> no out of stock

    Variant selectedVariant =
    variant != null ? variant : findVariant(widget.product.variantId);
    if (selectedVariant != null &&
        selectedVariant.stockType != null &&
        selectedVariant.stockType.isNotEmpty) {
      switch (selectedVariant.stockType) {
        case 'min_alert':
          if (selectedVariant.minStockAlert != null &&
              selectedVariant.stock != null) {
            int stock = int.parse(selectedVariant.stock);
            int minStockAlert = int.parse(selectedVariant.minStockAlert);
            if (minStockAlert >= stock) {
              _isProductOutOfStock = true;
            }
          }
          break;
        case 'threshold_quantity':
          if (selectedVariant.stock != null) {
            int stock = int.parse(selectedVariant.stock);
            if (stock <= 0) {
              _isProductOutOfStock = true;
            }
          }
          break;
        case 'continue_selling':
          _isProductOutOfStock = false;
          break;
        default:
          _isProductOutOfStock = false;
      }
    }

    if (findNext &&
        variant == null &&
        selectedVariant != null &&
        _isProductOutOfStock &&
        widget.product.variants != null &&
        widget.product.variants.isNotEmpty) {
      //find next variant which is in the stocks
      for (int i = 0; i < widget.product.variants.length; i++) {
        variant = widget.product.variants[i];
        await _checkOutOfStock(findNext: false);
      }
    }
    if (mounted) setState(() {});
    return _isProductOutOfStock;
  }

  bool _checkStockQuantity(int counter) {
    bool isProductAvailable = true;
//1)min_alert
//if product min_stock_alert  number is less than or equal to the product stock -> make the product oos
//2)threshold_quantity -
//if product stock number is less than or equal to zero -> make the product oos
//3)continue_selling -> no out of stock

    Variant selectedVariant =
    variant != null ? variant : findVariant(widget.product.variantId);
    if (selectedVariant != null &&
        selectedVariant.stockType != null &&
        selectedVariant.stockType.isNotEmpty) {
      switch (selectedVariant.stockType) {
        case 'threshold_quantity':
          if (selectedVariant.stock != null) {
            int stock = int.parse(selectedVariant.stock);
            if (stock <= 0) {
              isProductAvailable = false;
              Utils.showToast("Out of Stock", true);
            } else if (stock <= counter) {
              isProductAvailable = false;
              Utils.showToast(
                  "Only ${counter} Items Available in Stocks", true);
            } else {
              isProductAvailable = true;
            }
          }
          break;
        case 'min_alert':
          if (selectedVariant.stock != null &&
              selectedVariant.minStockAlert != null) {
            int stock = int.parse(selectedVariant.stock);
            int minStockAlert = int.parse(selectedVariant.minStockAlert);
            if (stock <= 0) {
              isProductAvailable = false;
              Utils.showToast("Out of Stock", true);
            } else if (counter>=(stock-minStockAlert)) {
              isProductAvailable = false;
              Utils.showToast(
                  "Only ${counter} Items Available in Stocks", true);
            } else if (stock <= counter) {
              isProductAvailable = false;
              Utils.showToast(
                  "Only ${counter} Items Available in Stocks", true);
            } else {
              isProductAvailable = true;
            }
          }
          break;
        default:
          isProductAvailable = true;
      }
    }
    return isProductAvailable;
  }

  Variant findVariant(String variantId) {
    Variant foundVariant;
    if (widget.product.variants != null)
      for (int i = 0; i < widget.product.variants.length; i++) {
        if (widget.product.variants[i].id.compareTo(variantId) == 0) {
          foundVariant = widget.product.variants[i];
          break;
        }
      }
    return foundVariant;
  }
}
