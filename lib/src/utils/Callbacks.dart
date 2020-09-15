
import 'package:event_bus/event_bus.dart';

typedef CustomCallback = T Function<T extends Object>({T value});

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class updateCartCount {
  updateCartCount();
}

class refreshOrderHistory {
  refreshOrderHistory();
}

class onPageFinished {
  String url;
  onPageFinished(this.url);
}