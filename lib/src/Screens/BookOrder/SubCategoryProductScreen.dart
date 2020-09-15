import 'package:flutter/material.dart';
import 'package:restroapp/src/UI/CartBottomView.dart';
import 'package:restroapp/src/UI/ProductTileView.dart';
import 'package:restroapp/src/apihandler/ApiController.dart';
import 'package:restroapp/src/models/CategoryResponseModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/AppColor.dart';
import 'package:restroapp/src/utils/AppConstants.dart';
import 'package:restroapp/src/utils/Utils.dart';

class SubCategoryProductScreen extends StatefulWidget {

  final CategoryModel categoryModel;
  bool isComingFromBaner;
  int index;

  SubCategoryProductScreen(
      this.categoryModel, this.isComingFromBaner, this.index);

  @override
  _SubCategoryProductScreenState createState() => _SubCategoryProductScreenState();
}

class _SubCategoryProductScreenState extends State<SubCategoryProductScreen> {
  final CartTotalPriceBottomBar bottomBar =
      CartTotalPriceBottomBar(ParentInfo.productList);

 // TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    _tabController = new TabController(vsync: this, initialIndex: 0, length: widget.categoryModel.subCategory.length);

  }

  @override
  Widget build(BuildContext context) {
    //print("---subCategory.length--=${categoryModel.subCategory.length}");
    print("reloadddddd");
    return DefaultTabController(
      length: widget.categoryModel.subCategory.length,
      initialIndex: widget.isComingFromBaner ? widget.index : widget.index,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.categoryModel.title),
          centerTitle: false,
        ),
        body: Column(children: <Widget>[
          TabBar(
            isScrollable: widget.categoryModel.subCategory.length == 1 ? false : true,
            labelColor: Colors.red,
            unselectedLabelColor: grayColorTitle,
            indicatorColor: whiteColor,
//            indicatorColor:
//                widget.categoryModel.subCategory.length == 1 ? appTheme : orangeColor,
            indicatorWeight: 0.1,
            tabs: List.generate(widget.categoryModel.subCategory.length, (int index) {
              bool isTabVisible;
              if (widget.categoryModel.subCategory.length == 1) {
                isTabVisible = false;
              } else {
                isTabVisible = true;
              }
              return Visibility(
                visible: isTabVisible,
                child: Tab(
                  child: Container(
                    padding: EdgeInsets.only(left: 4,right: 4),
                    height: 30,
                    decoration: BoxDecoration(
                      color: grey2,
                        borderRadius: BorderRadius.circular(4),
                        ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(widget.categoryModel.subCategory[index].title,style: TextStyle(fontSize: 12),),
                    ),
                  ),
                 // text: categoryModel.subCategory[index].title,
                ),
              );
            }),
          ),
          Expanded(
              child: TabBarView(
            children:
                List.generate(widget.categoryModel.subCategory.length, (int index) {
              return getProductsWidget(widget.categoryModel.subCategory[index].id);
            }),
          ))
        ]),
        bottomNavigationBar: bottomBar,
      ),
    );
  }

  Widget getProductsWidget(String subCategoryId) {
    return FutureBuilder(
      future: ApiController.getSubCategoryProducts(subCategoryId),
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.hasData == null) {
          return Container();
        } else {
          if (projectSnap.hasData) {
            SubCategoryResponse response = projectSnap.data;

            if (response.success) {
              //Check
              SubCategoryModel subCategory = SubCategoryModel();
//              SubCategoryModel subCategory =response.subCategories.first;
              for (int i = 0; i < response.subCategories.length; i++) {
                if (subCategoryId == response.subCategories[i].id) {
                  subCategory = response.subCategories[i];
                  break;
                }
              }
              if (subCategory.products == null) {
                return Container();
              }

              //print("products.length= ${subCategory.products.length}");
              if (subCategory.products.length == 0) {
                return Utils.getEmptyView2("No Products found!");
              } else {
                return  Column(
                  children: <Widget>[
                     Container(
                       padding: EdgeInsets.only(left: 10,top: 8),
                      height: 30,
                      width: Utils.getDeviceWidth(context),
                      color: grey2,
                       child: Text("${subCategory.products.length} items",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),
                     ),
                     Expanded(child: ListView.builder(
                       itemCount: subCategory.products.length,
                       itemBuilder: (context, index) {
                         Product product = subCategory.products[index];
                    return ProductTileItem(product, () {
                      bottomBar.state.updateTotalPrice();
                    }, ClassType.SubCategory);
                       },
                     ))

                  ],
                );

              }
            } else {
              //print("no products.length=");
              return Utils.getEmptyView2(AppConstant.noInternet);
//                return Utils.getEmptyView2("No Products found!");
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.black26,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black26)),
            );
          }
        }
      },
    );
  }
}
