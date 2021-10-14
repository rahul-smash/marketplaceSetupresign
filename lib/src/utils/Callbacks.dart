import 'package:event_bus/event_bus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restroapp/src/models/StoresModel.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';
import 'package:restroapp/src/utils/Utils.dart';

typedef CustomCallback = T Function<T extends Object>({T value});

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class onViewAllSelected {
  bool isViewAllSelected;
  StoresModel allStoreData;
  HomeScreenEnum selectedScreen = HomeScreenEnum.HOME_BAND_VIEW;

  onViewAllSelected(this.isViewAllSelected, this.allStoreData,
      {this.selectedScreen});
}

class updateCartCount {
  updateCartCount();
}

class updateStoreSearch {
  List<Product> searchedProductList;

  updateStoreSearch(this.searchedProductList);
}

class onCartRemoved {
  onCartRemoved();
}

class onHomeSearch {
  StoresModel allStoreData;
  onHomeSearch(this.allStoreData);
}
class openHome {
  openHome();
}
class OnProductTileDbRefresh {
  OnProductTileDbRefresh();
}

class onCounterUpdate {
  int counter;
  String productId;
  String variantId;

  onCounterUpdate(this.counter, this.productId, this.variantId);
}

class onOpenMenu {
  onOpenMenu();
}
class onLocationChanged {
  LatLng latLng;
  onLocationChanged(this.latLng);
}

class onFavRemoved {
  onFavRemoved();
}

class refreshOrderHistory {
  refreshOrderHistory();
}

class onPageFinished {
  String url;

  onPageFinished(this.url);
}

class onPayTMPageFinished {
  String url;
  String orderId;
  String txnId;
  String amount;

  onPayTMPageFinished(this.url, this.orderId, this.txnId, {this.amount = ''});
}

class onPeachPayFinished {
  String url;
  String checkoutID;
  String resourcePath;
  String amount;

  onPeachPayFinished(this.url, this.checkoutID, this.resourcePath,{this.amount});
}
class onPhonePeFinished {
  String paymentRequestId;
  String transId;
  String amount;

  onPhonePeFinished( this.paymentRequestId, this.transId,{this.amount});
}
class onIPay88Finished {
  String url;
  String requestId;
  String transId;
  String status;

  onIPay88Finished(this.url, this.requestId, this.transId, this.status);
}
