import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/database/SharedPrefs.dart';
import 'package:restroapp/src/models/StoreDataModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/Callbacks.dart';
import 'package:restroapp/src/utils/DialogUtils.dart';
import 'package:restroapp/src/utils/Utils.dart';

class StoreSearchUI extends StatefulWidget {
  List<Product> searchedProductList = List.empty(growable: true);

  StoreDataObj store;

  StoreSearchUI(this.searchedProductList, this.store);

  @override
  _StoreSearchUIState createState() => _StoreSearchUIState();
}

class _StoreSearchUIState extends State<StoreSearchUI> {
  Key key = UniqueKey();

  @override
  void initState() {
    super.initState();
    eventBus.on<updateStoreSearch>().listen((event) {
      resetView(event.searchedProductList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: Visibility(
        visible: widget.searchedProductList.isNotEmpty,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Search Result',
                      style: TextStyle(
                          color: staticHomeDescriptionColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.searchedProductList.length,
                itemBuilder: (BuildContext context, int index) {
                  Product product = widget.searchedProductList[index];
                  bool isStoreClosed = !Utils.checkStoreOpenTime(widget.store);
                  return InkWell(
                    onTap: () {
                      if (isStoreClosed) {
                        DialogUtils.displayCommonDialog(
                          context,
                          widget.store.storeName,
                          widget.store.closehoursMessage,
                        );
                        return;
                      }
                    },
                    child: Container(
                      child: ProductTileItem(
                        product,
                        () {},
                        ClassType.Home,
                        isStoreClosed: isStoreClosed,
                        storeID: widget.store.id,
                        saveStore: () {
                          SharedPrefs.saveStoreData(widget.store);
                        },
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  void resetView(List<Product> searchedProductList) {
    widget.searchedProductList = searchedProductList;
    setState(() {
      key = UniqueKey();
    });
  }
}
