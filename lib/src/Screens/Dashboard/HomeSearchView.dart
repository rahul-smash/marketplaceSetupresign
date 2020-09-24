import 'package:flutter/material.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/Utils.dart';

class HomeSearchView extends StatelessWidget {
  List<Product> productsList;

  HomeSearchView(this.productsList);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          productsList.length == 0
              ? Utils.getEmptyView2("")
              : Expanded(
                  child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: productsList.length,
                  itemBuilder: (context, index) {
                    Product product = productsList[0];
                    return ProductTileItem(product, () {}, ClassType.Search);
                  },
                )),
        ],
      ),
    );
  }
}
