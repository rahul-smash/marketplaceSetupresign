import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:restroapp/src/Screens/Dashboard/ProductDetailScreen.dart';
import 'package:restroapp/src/database/DatabaseHelper.dart';
import 'package:restroapp/src/models/CartTableData.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';

class ProductTileItem extends StatefulWidget {
  Product product;
  VoidCallback callback;
  ClassType classType;

  ProductTileItem(this.product, this.callback, this.classType);

  @override
  _ProductTileItemState createState() => new _ProductTileItemState();
}

class _ProductTileItemState extends State<ProductTileItem> {
  DatabaseHelper databaseHelper = new DatabaseHelper();
  int counter = 0;
  CartData cartData;
  Variant variant;
  bool showAddButton;

  @override
  initState() {
    super.initState();
    showAddButton = false;
    //print("--_ProductTileItemState-- initState ${widget.classType}");
    getDataFromDB();
  }

  void getDataFromDB() {
    databaseHelper
        .getProductQuantitiy(widget.product.variantId)
        .then((cartDataObj) {
      cartData = cartDataObj;
      counter = int.parse(cartData.QUANTITY);
      showAddButton = counter == 0 ? true : false;
      //print("-QUANTITY-${counter}=");
      setState(() {});
    });
    databaseHelper
        .checkProductsExistInFavTable(
        DatabaseHelper.Favorite_Table, widget.product.id)
        .then((favValue) {
      //print("--ProductFavValue-- ${favValue} and ${widget.product.isFav}");
      setState(() {
        widget.product.isFav = favValue.toString();
        //print("-isFav-${widget.product.isFav}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String discount, price, variantId, weight, mrpPrice;
    variantId = variant == null ? widget.product.variantId : variant.id;
    if (variant == null) {
      //print("====-variant == null====");
      discount = widget.product.discount.toString();
      price = widget.product.price.toString();
      weight = widget.product.weight;
      mrpPrice = widget.product.mrpPrice;
    } else {
      //print("==else==-variant == null====");
      discount = variant.discount.toString();
      price = variant.price.toString();
      weight = variant.weight;
      mrpPrice = variant.mrpPrice;
    }
    String imageUrl = widget.product.imageType == "0"
        ? widget.product.image==null?widget.product.image10080:widget.product.image
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

    return Container(
      padding: EdgeInsets.only(top: 15),
      color: Colors.white,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                //print("----print-----");
                if (widget.classType != ClassType.CART) {
                  var result = await Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ProductDetailsScreen(widget.product),
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
                      variantId = widget.product.variantId;
                    }
                    databaseHelper
                        .getProductQuantitiy(variantId)
                        .then((cartDataObj) {
                      setState(() {
                        cartData = cartDataObj;
                        counter = int.parse(cartData.QUANTITY);
                        showAddButton = counter == 0 ? true : false;
                        //print("-QUANTITY-${counter}=");
                      });
                    });
                    databaseHelper
                        .checkProductsExistInFavTable(
                        DatabaseHelper.Favorite_Table, widget.product.id)
                        .then((favValue) {
                      //print("--ProductFavValue-- ${favValue} and ${widget.product.isFav}");
                      setState(() {
                        widget.product.isFav = favValue.toString();
                      });
                    });
                    widget.callback();
                    eventBus.fire(updateCartCount());
                  });
                  //print("--ProductDetails--result---${result}");
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
//                            Visibility(
//                              visible: AppConstant.isRestroApp,
//                              child: addVegNonVegOption(),
//                            ),

                                Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Stack(
                                    children: <Widget>[
                                      imageUrl == ""
                                          ? Container(
                                        width: 70.0,
                                        height: 80.0,
                                        child: Utils.getImgPlaceHolder(),
                                      )
                                          : Padding(
                                          padding:
                                          EdgeInsets.only(left: 7, right: 20,top: 5),
                                          child: Container(
                                              padding: EdgeInsets.only(left: 2,top: 2,right: 2,bottom: 2),
                                              decoration: new BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(2.0)),
                                                border : Border.all(
                                                  color: Colors.grey, //                   <--- border color
                                                  width: 1.0,
                                                ),
                                              ),
                                              width: 70.0,
                                              height: 80.0,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(2.0),
                                                child: CachedNetworkImage(
                                                    imageUrl: "${imageUrl}",
                                                    fit: BoxFit.fill
                                                  //placeholder: (context, url) => CircularProgressIndicator(),
                                                  //errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              )
                                            /*child: Image.network(imageUrl,width: 60.0,height: 60.0,
                                      fit: BoxFit.cover),*/
                                          )),
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
                                    ],
                                  ),
                                ),

                                Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Visibility(
                                                  visible: AppConstant.isRestroApp,
                                                  child: addVegNonVegOption(),
                                                ),
                                                Expanded(
                                                  child: Text(widget.product.title,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: darkGrey2,
                                                        fontWeight: FontWeight.bold,
                                                      )),
                                                ),

                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      int count = await databaseHelper
                                                          .checkProductsExistInFavTable(
                                                          DatabaseHelper.Favorite_Table,
                                                          widget.product.id);

                                                      Product product = widget.product;
//                                                      print("--product.count-- ${count}");
                                                      if (count == 1) {
                                                        product.isFav = "0";
                                                        await databaseHelper.deleteFav(
                                                            DatabaseHelper.Favorite_Table,
                                                            product.id);
                                                      } else if (count == 0) {
                                                        String variantId,
                                                            weight,
                                                            mrpPrice,
                                                            price,
                                                            discount,
                                                            isUnitType;
                                                        variantId = variant == null
                                                            ? widget.product.variantId
                                                            : variant.id;
                                                        weight = variant == null
                                                            ? widget.product.weight
                                                            : variant.weight;
                                                        mrpPrice = variant == null
                                                            ? widget.product.mrpPrice
                                                            : variant.mrpPrice;
                                                        price = variant == null
                                                            ? widget.product.price
                                                            : variant.price;
                                                        discount = variant == null
                                                            ? widget.product.discount
                                                            : variant.discount;
                                                        isUnitType = variant == null
                                                            ? widget.product.isUnitType
                                                            : variant.unitType;

                                                        product.isFav = "1";
                                                        product.variantId = variantId;
                                                        product.weight = weight;
                                                        product.mrpPrice = mrpPrice;
                                                        product.price = price;
                                                        product.discount = discount;
                                                        product.isUnitType = isUnitType;
                                                        insertInFavTable(product, counter);
                                                      }
                                                      //print("--product.isFav-- ${product.isFav}");
                                                      widget.callback();
                                                      setState(() {});
                                                    },
                                                    child: Visibility(
                                                      visible: widget.classType == ClassType.CART
                                                          ? false
                                                          : true,
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration: BoxDecoration(
                                                          color:
                                                          widget.classType == ClassType.CART
                                                              ? Colors.white
                                                              : favGrayColor,
                                                          border: Border.all(
                                                            color: favGrayColor,
                                                            width: 1,
                                                          ),
                                                          borderRadius: BorderRadius.all(
                                                              Radius.circular(5.0)),
                                                        ),
                                                        margin: EdgeInsets.fromLTRB(0, 5, 20, 0),
                                                        child: Visibility(
                                                          visible:
                                                          widget.classType == ClassType.CART
                                                              ? false
                                                              : true,
                                                          /* child: widget.product.isFav == null ? Icon(Icons.favorite_border)
                                                        :Utils.showFavIcon(widget.product.isFav),*/
                                                          child: widget.classType ==
                                                              ClassType.Favourites
                                                              ? Icon(
                                                            Icons.favorite,
                                                            color: darkRed,
                                                          )
                                                              : Utils.showFavIcon(
                                                              widget.product.isFav),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: variantsVisibility == true ? 0 : 20,
                                            ),
//                                            Visibility(
//                                              visible: false,
//                                              child: Padding(
//                                                padding: EdgeInsets.only(top: 20, bottom: 3),
//                                                child: InkWell(
//                                                  onTap: () async {
//                                                    //print("-variants.length--${widget.product.variants.length}");
//                                                    if (widget.product.variants.length !=
//                                                        null) {
//                                                      if (widget.product.variants.length == 1) {
//                                                        return;
//                                                      }
//                                                    }
//                                                    variant =
//                                                    await DialogUtils.displayVariantsDialog(
//                                                        context,
//                                                        "${widget.product.title}",
//                                                        widget.product.variants);
//                                                    if (variant != null) {
//                                                      /*print("variant.weight= ${variant.weight}");
//                                                  print("variant.discount= ${variant.discount}");
//                                                  print("variant.mrpPrice= ${variant.mrpPrice}");
//                                                  print("variant.price= ${variant.price}");*/
//                                                      databaseHelper
//                                                          .getProductQuantitiy(variant.id)
//                                                          .then((cartDataObj) {
//                                                        //print("QUANTITY= ${cartDataObj.QUANTITY}");
//                                                        cartData = cartDataObj;
//                                                        counter = int.parse(cartData.QUANTITY);
//                                                        showAddButton =
//                                                        counter == 0 ? true : false;
//                                                        setState(() {});
//                                                      });
//                                                    }
//                                                  },
//                                                  child: Container(
//                                                    padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                                                    decoration: BoxDecoration(
//                                                      border: Border.all(
//                                                        color: weight.trim() == ""
//                                                            ? whiteColor
//                                                            : orangeColor,
//                                                        width: 1,
//                                                      ),
//                                                      borderRadius: BorderRadius.all(
//                                                          Radius.circular(5.0)),
//                                                    ),
//                                                    child: Wrap(
//                                                      children: <Widget>[
//                                                        Padding(
//                                                          padding: EdgeInsets.only(
//                                                              top: 5,
//                                                              right: 5,
//                                                              bottom: widget.classType ==
//                                                                  ClassType.CART
//                                                                  ? 5
//                                                                  : 0),
//                                                          child: Text(
//                                                            "${weight}",
//                                                            textAlign: TextAlign.center,
//                                                            style:
//                                                            TextStyle(color: orangeColor),
//                                                          ),
//                                                        ),
//                                                        Visibility(
//                                                          visible:
//                                                          widget.classType == ClassType.CART
//                                                              ? false
//                                                              : true,
//                                                          child: Padding(
//                                                            padding: EdgeInsets.only(left: 10),
//                                                            child: Utils.showVariantDropDown(
//                                                                widget.classType,
//                                                                widget.product),
//                                                          ),
//                                                        ),
//                                                      ],
//                                                    ),
//                                                  ),
//                                                ),
//                                              ),
//                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                (discount == "0.00" ||
                                                    discount == "0" ||
                                                    discount == "0.0")
                                                    ? Text(
                                                  "${AppConstant.currency}${price}",
                                                  style: TextStyle(
                                                      color: grayColorTitle,
                                                      fontWeight: FontWeight.w600),
                                                )
                                                    : Row(
                                                  children: <Widget>[
                                                    Text(
                                                        "${AppConstant.currency}${mrpPrice}",
                                                        style: TextStyle(
                                                            decoration: TextDecoration
                                                                .lineThrough,
                                                            color: grayColorTitle,
                                                            fontWeight: FontWeight.w400)),
                                                    Text(" "),
                                                    Text(
                                                      "${AppConstant.currency}${price}",
                                                      style: TextStyle(
                                                          color: grayColorTitle,
                                                          fontWeight: FontWeight.w700),
                                                    )

                                                    ,
                                                  ],
                                                ),
                                              ],
                                            ),

                                            Container(
                                              // color: Colors.blue,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      width: 10,
                                                    ),
//                                                    Flexible(
//                                                        child: Container(
//                                                          child: Column(
//                                                            crossAxisAlignment: CrossAxisAlignment.start,
//                                                            children: <Widget>[
//                                                              Padding(
//                                                                  padding: EdgeInsets.only(right: 5),
//                                                                  child: Html(
//                                                                    data: (widget.product.description.length) > 30 ? widget.product.description.replaceRange(30, widget.product.description.length, '...') : widget.product.description,
//                                                                    padding: EdgeInsets.all(0.0),
//                                                                  )
//                                                              ),
//                                                              Text( (widget.product.description.trim() == "" || widget.product.description == null) ? "" : "Read more",style: TextStyle(color: darkRed,decoration: TextDecoration.underline),),
//                                                            ],
//                                                          ),
//                                                        )
//                                                    ),
                                                    Align(
                                                      alignment: Alignment.bottomRight,
                                                      child:  addQuantityView(),
                                                    ),
                                                  ],
                                                )
                                            )


                                          ],
                                        )
                                    )),
                              ],
                            )),
                      ])),
            ),

            Visibility(
              visible: false,
              child: Padding(
                padding: EdgeInsets.only(top: 5,bottom: 15,left: 20),
                child: Row(
                  children: <Widget>[
                    Image.asset("images/starIcon.png",width: 20,height: 20,),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text("sdfsd",style: TextStyle(color:darkRed,fontWeight: FontWeight.w600)),
                    )

                  ],
                ),
              ),
            ),

            Visibility(
                visible: variantsVisibility,
                child:  Padding(
                  padding: EdgeInsets.only(bottom: 10,left: 15),
                  child: widget.product.variants!=null?
                  Wrap(
                    children:  widget.product.variants.map((f) => GestureDetector(
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
                        margin: EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: (f.id == (variant == null ? widget.product.variantId : variant.id)) ? Colors.transparent : Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(
                                20.0) //                 <--- border radius here
                            ),
                            color: (f.id == (variant == null ? widget.product.variantId : variant.id)) ? darkRed : whiteColor
                        ),
                        child: priceContainer(f),
                      ),
                      onTap: () {
                        if (widget.product.variants.length !=
                            null) {
                          if (widget.product.variants.length == 1) {
                            return;
                          }
                        }
                        variant = f;
                        if (variant != null) {
                          /*print("variant.weight= ${variant.weight}");
                                      print("variant.discount= ${variant.discount}");
                                      print("variant.mrpPrice= ${variant.mrpPrice}");
                                      print("variant.price= ${variant.price}");*/
                          databaseHelper
                              .getProductQuantitiy(variant.id)
                              .then((cartDataObj) {
                            //print("QUANTITY= ${cartDataObj.QUANTITY}");
                            cartData = cartDataObj;
                            counter = int.parse(cartData.QUANTITY);
                            showAddButton =
                            counter == 0 ? true : false;
                            setState(() {});
                          });
                        }
                      },
                    )).toList(),
                  )
                      :Container(),
                )
            ),
            Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Color(0xFFBDBDBD))
          ]),
    );
  }


  priceContainer(Variant v){
   // print("this is weightttt ${widget.product.tags}");
    var weight = (v.weight == null || v.weight == " " || v.weight == "") ? "" : "${v.weight} -";
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: (v.id == (variant == null ? widget.product.variantId : variant.id)) ? true : false,
          child: Image.asset("images/tickicon.png",width: 15,height: 15,),
        ),
        Padding(padding: EdgeInsets.only(right: 8),
            child : Text("$weight",
                style: TextStyle(color: (v.id == (variant == null ? widget.product.variantId : variant.id)) ? whiteColor : darkGrey))
        ),
        (v.discount == "0.00" ||
            v.discount == "0" ||
            v.discount == "0.0")
            ? Text(
          "${AppConstant.currency}${v.price}",
          style: TextStyle(
              color: (v.id == (variant == null ? widget.product.variantId : variant.id)) ? whiteColor : darkRed,
              fontWeight: FontWeight.w600),
        )
            : Row(
          children: <Widget>[
            Text(
                "${AppConstant.currency}${v.mrpPrice}",
                style: TextStyle(
                    decoration: TextDecoration
                        .lineThrough,
                    color: (v.id == (variant == null ? widget.product.variantId : variant.id)) ? whiteColor : darkRed,
                    fontWeight: FontWeight.w400)),
            Text(" "),
            Text(
              "${AppConstant.currency}${v.price}",
              style: TextStyle(
                  color: (v.id == (variant == null ? widget.product.variantId : variant.id)) ? whiteColor : darkRed,
                  fontWeight: FontWeight.w700),
            )
            ,
          ],
        ),
      ],
    );






//      Row(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        mainAxisAlignment: MainAxisAlignment.start,
//        children: <Widget>[
//          Expanded(
//            child: Text(v.weight,
//                style: TextStyle(color: Colors.black)),
//          ),
//          Flexible(
//            child: Align(
//              alignment: Alignment.center,
//              child: RichText(
//                  overflow: TextOverflow.visible,
//                  text: (v.discount == "0.00" ||
//                      v.discount == "0" ||
//                      v.discount == "0.0")
//                      ? TextSpan(
//                    text:
//                    "${AppConstant.currency}${v.price}",
//                    style: TextStyle(
//                        color: grayColorTitle,
//                        fontWeight: FontWeight.w700),
//                  )
//                      : TextSpan(
//                    text:
//                    "${AppConstant.currency}${v.price}",
//                    style: TextStyle(
//                        color: grayColorTitle,
//                        fontWeight: FontWeight.w700),
//                    children: <TextSpan>[
//                      TextSpan(text: " "),
//                      TextSpan(
//                          text:
//                          "${AppConstant.currency}${v.mrpPrice}",
//                          style: TextStyle(
//                              decoration: TextDecoration
//                                  .lineThrough,
//                              color: grayColorTitle,
//                              fontWeight:
//                              FontWeight.w400)),
//                    ],
//                  )),
//            ),
//          )
////
//        ]
//    );
  }

  Widget addQuantityView() {
    return Container(
      //color: orangeColor,
      width: 90,
      height: 30,
      decoration: BoxDecoration(
          color: whiteColor,
          //border: Border.all(color: showAddButton == false ? whiteColor : orangeColor, width: 0,),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          border:  Border.all(
            color: showAddButton ? grayColor : whiteColor,
            width: 1,
          )
      ),
      margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
      child: showAddButton == true
          ? InkWell(
        onTap: () {
          //print("add onTap");
          setState(() {});
          counter++;
          showAddButton = false;
          insertInCartTable(widget.product, counter);
          widget.callback();
        },
        child: Container(
          child: Center(
            child: Text(
              "ADD +",
              style: TextStyle(color:darkRed,fontWeight: FontWeight.w600),
            ),
          ),
        ),
      )
          : Visibility(
        visible: showAddButton == true ? false : true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(0.0),
              width: 25.0, // you can adjust the width as you need
              child: GestureDetector(
                  onTap: () {
                    if (counter != 0) {
                      setState(() => counter--);
                      if (counter == 0) {
                        // delete from cart table
                        removeFromCartTable(widget.product.variantId);
                      } else {
                        // insert/update to cart table
                        insertInCartTable(widget.product, counter);
                      }
                      widget.callback();
                    }
                  },
                  child: Container(
                    width: 35,
                    height: 25,
                    decoration: BoxDecoration(
                      color: grayColor,
                      border: Border.all(
                        color: grayColor,
                        width: 1,
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child:
                    Icon(Icons.remove, color: Colors.white, size: 20),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              width: 20.0,
              height: 20.0,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius:
                new BorderRadius.all(new Radius.circular(15.0)),
                border: new Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
              ),
              child: Center(
                  child: Text(
                    "$counter",
                    style: TextStyle(fontSize: 18),
                  )),
            ),
            Container(
              padding: const EdgeInsets.all(0.0),
              width: 25.0, // you can adjust the width as you need
              child: GestureDetector(
                onTap: () {
                  setState(() => counter++);
                  if (counter == 0) {
                    // delete from cart table
                    removeFromCartTable(widget.product.variantId);
                  } else {
                    // insert/update to cart table
                    insertInCartTable(widget.product, counter);
                  }
                },
                child: Container(
                    width: 35,
                    height: 25,
                    decoration: BoxDecoration(
                      color: darkRed,
                      border: Border.all(
                        color: darkRed,
                        width: 1,
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child:
                    Icon(Icons.add, color: Colors.white, size: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addVegNonVegOption() {
    Color foodOption =
    widget.product.nutrient.toLowerCase() == "Non Veg".toLowerCase() ? Colors.red : Colors.green;
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
          width: 12,
          height: 12,
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
      DatabaseHelper.image_100_80: product.image10080,
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

  void insertInFavTable(Product product, int quantity) {
    var mId = int.parse(product.id);
    String productJson = JsonEncoder().convert(product.toJson());
    //print("${productJson}");

    Map<String, dynamic> row = {
      DatabaseHelper.ID: mId,
      DatabaseHelper.VARIENT_ID: product.variantId,
      DatabaseHelper.PRODUCT_ID: product.id,
      DatabaseHelper.WEIGHT: product.weight,
      DatabaseHelper.isFavorite: product.isFav,
      DatabaseHelper.Product_Json: productJson,
      DatabaseHelper.MRP_PRICE: product.mrpPrice,
      DatabaseHelper.PRICE: product.price,
      DatabaseHelper.DISCOUNT: product.discount,
      DatabaseHelper.QUANTITY: quantity.toString(),
      DatabaseHelper.IS_TAX_ENABLE: product.isTaxEnable,
      DatabaseHelper.Product_Name: product.title,
      DatabaseHelper.UNIT_TYPE: product.isUnitType,
      DatabaseHelper.nutrient: product.nutrient,
      DatabaseHelper.description: product.description,
      DatabaseHelper.imageType: product.imageType,
      DatabaseHelper.imageUrl: product.imageUrl,
      DatabaseHelper.image_100_80: product.image10080,
      DatabaseHelper.image_300_200: product.image300200,
    };

    databaseHelper.addProductToFavTable(row).then((count) {
      //print("-------count--------${count}-----");
    });
  }
}
