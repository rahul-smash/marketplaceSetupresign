import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/UI/RestroCardItem.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/Utils.dart';

class HomeSearchView extends StatelessWidget {
  StoresModel allStoreData;
  CustomCallback callback;
  HomeScreenEnum selectedScreen;
  LatLng initialPosition;

  HomeSearchView(this.allStoreData,this.initialPosition, {this.callback, this.selectedScreen});

  @override
  Widget build(BuildContext context) {
    return _getView();
  }

  Widget _getView() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          allStoreData == null ||
                  (allStoreData != null && allStoreData.data.isEmpty)
              ? Utils.getEmptyView2("No Result Found")
              : Expanded(
                  child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allStoreData.data.length,
                  itemBuilder: (context, index) {
                    StoreData storeDataObj = allStoreData.data[index];
                    return RestroCardItem(storeDataObj, callback,initialPosition);
                  },
                )),
        ],
      ),
    );
  }
}
