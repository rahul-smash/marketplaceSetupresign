import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/UI/DishTileItem.dart';
import 'package:restroapp/src/UI/RestroCardItem.dart';
import 'package:restroapp/src/UI/RestroSearchItemCard.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/TagsModel.dart';
import 'package:restroapp/src/models/VersionModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';

class HomeSearchView extends StatefulWidget {
  StoresModel allStoreData;
  CustomCallback callback;
  CustomCallback dishCallBack;
  HomeScreenEnum selectedScreen;
  LatLng initialPosition;
  TagsModel tagsModel;
  BrandData brandData;

  HomeSearchView(this.allStoreData, this.brandData,
      {this.callback,
      this.initialPosition,
      this.tagsModel,
      this.selectedScreen,
      this.dishCallBack});

  @override
  _HomeSearchViewState createState() => _HomeSearchViewState();
}

class _HomeSearchViewState extends State<HomeSearchView> {
  List<dynamic> itemList = List();
  bool visibleAllRestro = false;

  @override
  void initState() {
    super.initState();
    itemList.clear();
    _generalizedList();
    listenEvent();
  }

  @override
  Widget build(BuildContext context) {
    return _getView();
  }

  Widget _getView() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemCount: itemList.length,
            itemBuilder: (context, index) {
              if (itemList[index] is StoreData) {
                StoreData storeDataObj = itemList[index];
                return RestroSearchItemCard(storeDataObj, widget.callback,
                    widget.initialPosition, widget.brandData);
              } else if (itemList[index] is Dish) {
                Dish dish = itemList[index];
                return DishTileItem(
                    dish, widget.callback, widget.initialPosition,
                    dishCallBack: widget.dishCallBack);
              } else {
                return itemList[index];
              }
            },
          )),
        ],
      ),
    );
  }

  _generalizedList() {
    if (widget.allStoreData != null) {
      if (widget.allStoreData.data != null &&
          widget.allStoreData.data.isNotEmpty) {
        itemList.add(Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Restaurants",
                style: TextStyle(
                  fontSize: 18.0,
                  color: productHeadingColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Visibility(
                child: InkWell(
                  child: Text(
                    visibleAllRestro
                        ? "Hide all restaurant"
                        : "View all restaurant",
                    style: TextStyle(
                      fontSize: 16.0,
                      decoration: TextDecoration.underline,
                      color: appThemeSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    visibleAllRestro = !visibleAllRestro;
                    itemList.clear();
                    _generalizedList();
                    setState(() {});
                  },
                ),
                visible: widget.allStoreData.data.length > 2,
              ),
            ],
          ),
        ));
        itemList.addAll(widget.allStoreData.data.length > 2
            ? visibleAllRestro
                ? widget.allStoreData.data
                : widget.allStoreData.data.sublist(0, 2)
            : widget.allStoreData.data);
      }
      if (widget.allStoreData.dishes != null &&
          widget.allStoreData.dishes.isNotEmpty) {
        itemList.add(Padding(
          padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Dishes",
                style: TextStyle(
                  fontSize: 18.0,
                  color: productHeadingColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ));
        itemList.addAll(widget.allStoreData.dishes);
      }
    }
  }

  void listenEvent() {
    eventBus.on<onHomeSearch>().listen((event) {
      setState(() {
        widget.allStoreData = event.allStoreData;
        itemList.clear();
        visibleAllRestro = false;
        _generalizedList();
      });
    });
  }
}
