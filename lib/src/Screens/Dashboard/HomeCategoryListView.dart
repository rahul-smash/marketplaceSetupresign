import 'package:flutter/material.dart';
import 'package:restroapp/src/UI/CategoryView.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/StoreResponseModel.dart';
import 'package:restroapp/src/utils/AppColor.dart';

class HomeCategoryListView extends StatelessWidget {
  final CategoryResponse categoryResponse;
  StoreModel store;
  HomeCategoryListView(this.categoryResponse, this.store,);

  @override
  Widget build(BuildContext context) {
    return _makeView();
  }

  Widget _makeView() {
    return true
        ? Container(
            height: 170,
            color: Colors.transparent,
            margin: EdgeInsets.only(left: 2.5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Top Categories",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: appTheme,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Flexible(
                    child: ListView.builder(
                  itemCount: categoryResponse.categories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return CategoryView(
                        categoryResponse.categories[index], store, false, index);
//                    return _makeStaffCard(index, context);
                  },
                ))
              ],
            ))
        : Container();
  }

//  Widget _makeStaffCard(index, BuildContext context) {
//    return Container(
//      margin: EdgeInsets.only(top: 15.0, bottom: 15.0, left: 7.5, right: 7.5),
//      width: Utils.deviceWidth(context) - (Utils.deviceWidth(context) / 1.5),
//      decoration: BoxDecoration(
//          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          ClipRRect(
//            borderRadius: BorderRadius.only(
//                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//            child: Image.network(
//              _staffModelList[index].image,
//              fit: BoxFit.fill,
//              height: 130,
//              errorBuilder: (context, error, stackTrace) {
//                return Image.asset(
//                  "images/dummyProfile.png",
//                  height: 130,
//                  fit: BoxFit.fill,
//                );
//              },
//            ),
//          ),
//          Padding(
//            padding: EdgeInsets.only(left: 10, right: 5, top: 10),
//            child: Text(
//              "${_staffModelList[index].name}",
//              style: TextStyle(
//                  color: gray1, fontSize: 16, fontWeight: FontWeight.bold),
//              overflow: TextOverflow.ellipsis,
//            ),
//          ),
//          Padding(
//            padding: EdgeInsets.only(left: 10, right: 5, bottom: 10),
//            child: Text(
//              "${_staffModelList[index].services != null && _staffModelList[index].services.isNotEmpty ? _staffModelList[index].services.first.title : ''}",
//              overflow: TextOverflow.ellipsis,
//              style: TextStyle(
//                color: pink1,
//                fontSize: 14,
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }
}
