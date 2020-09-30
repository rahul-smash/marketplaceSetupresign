import 'package:event_bus/event_bus.dart';
import 'package:restroapp/src/models/SubCategoryResponse.dart';

typedef CustomCallback = T Function<T extends Object>({T value});

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class updateCartCount {
  updateCartCount();
}

class onCartRemoved {
  onCartRemoved();
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
