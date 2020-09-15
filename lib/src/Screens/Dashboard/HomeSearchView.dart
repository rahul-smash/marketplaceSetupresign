import 'package:flutter/material.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/Utils.dart';

class HomeSearchView extends StatefulWidget {
  List<Product> productsList;

  @override
  _HomeSearchViewState createState() => _HomeSearchViewState();

  HomeSearchView(this.productsList);
}

class _HomeSearchViewState extends State<HomeSearchView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          widget.productsList.length == 0
              ? Utils.getEmptyView2("")
              : Expanded(
                  child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.productsList.length,
//                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Product product = widget.productsList[0];
                    return ProductTileItem(product, () {}, ClassType.Search);
                  },
                )),
        ],
      ),
    );
  }
}
