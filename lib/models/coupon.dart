class Coupons {
  var coupons = [];

  Coupons.getListCoupons(List a) {
    for (var i in a) {
      coupons.add(Coupon.fromJson(i));
      //print(i.toString());
    }
    //print("hallo ${coupons.length}");
  }
}

class Coupon {
  double amount;
  var code;
  var message;
  var id;
  var discountType;
  var dateExpires;
  var description;
  double minimumAmount;
  double maximumAmount;

  Coupon.fromJson(Map<String, dynamic> json) {
    try {
      print(json);

      amount = double.parse(json["amount"]);
      code = json["code"];
      id = json["id"];
      discountType = json["discount_type"];
      description = json["description"];
      minimumAmount =
          json["minimum_amount"] != null ? double.parse(json["minimum_amount"].toString()) : 0.0;
      maximumAmount =
          json["maximum_amount"] != null ? double.parse(json["maximum_amount"].toString()) : 0.0;
      dateExpires =
          json["date_expires"] != null ? DateTime.parse(json["date_expires"]) : null;
      message = "Hello";
    } catch (e) {
      print(e.toString());
      // example data - {id: 10021, code: halfprice, amount: 50.00, date_created: 2016-11-12T10:44:40, date_created_gmt: 2016-11-12T03:44:40, date_modified: 2016-11-12T10:44:40, date_modified_gmt: 2016-11-12T03:44:40, discount_type: percent, description: , date_expires: null, date_expires_gmt: null, usage_count: 0, individual_use: true, product_ids: [], excluded_product_ids: [], usage_limit: null, usage_limit_per_user: 1, limit_usage_to_x_items: null, free_shipping: false, product_categories: [], excluded_product_categories: [], exclude_sale_items: false, minimum_amount: 0.00, maximum_amount: 0.00, email_restrictions: [], used_by: [], meta_data: [{id: 12692, key: _vc_post_settings, value: {vc_grid_id: []}}, {id: 12711, key: slide_template, value: default}]
    }
  }
}
