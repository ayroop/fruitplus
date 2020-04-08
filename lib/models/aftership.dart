class AfterShip {
  List<Tracking> trackings = [];

  AfterShip.fromJson(Map<String, dynamic> json) {
    var _trackings = json['data']['trackings'];
    for (var item in _trackings) {
      trackings.add(Tracking.fromJson(item));
    }
  }
}

class Tracking {
  String id;
  String trackingNumber;
  String slug;
  String orderId;

  Tracking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trackingNumber = json['tracking_number'];
    slug = json['slug'];
    orderId = json['order_id'];
  }
}
