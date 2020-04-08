import 'package:flutter/material.dart';

import '../common/config.dart';
import '../services/index.dart';
import 'address.dart';
import 'cart.dart';
import 'user.dart';

class OrderModel extends ChangeNotifier {
  List<Order> myOrders;
  bool isLoading = true;
  String errMsg;
  int page = 1;
  bool endPage = false;

  Future<void> getMyOrder({UserModel userModel}) async {
    try {
      isLoading = true;
      notifyListeners();
      myOrders = await Services().getMyOrders(userModel: userModel, page: 1);
      page = 1;
      errMsg = null;
      isLoading = false;
      endPage = false;
      notifyListeners();
    } catch (err) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({UserModel userModel}) async {
    try {
      isLoading = true;
      page = page + 1;
      notifyListeners();
      var orders =
          await Services().getMyOrders(userModel: userModel, page: page);
      myOrders = [...myOrders, ...orders];
      if (orders.isEmpty) endPage = true;
      errMsg = null;
      isLoading = false;
      notifyListeners();
    } catch (err) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}

class Order {
  int id;
  String number;
  String status;
  DateTime createdAt;
  DateTime dateModified;
  double total;
  double totalTax;
  String paymentMethodTitle;
  String shippingMethodTitle;
  String customerNote;
  List<ProductItem> lineItems = [];
  Address billing;

  Order({this.id, this.number, this.status, this.createdAt, this.total});

  Order.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    customerNote = parsedJson["customer_note"];
    number = parsedJson["number"];
    status = parsedJson["status"];
    createdAt = parsedJson["date_created"] != null
        ? DateTime.parse(parsedJson["date_created"])
        : DateTime.now();
    dateModified = parsedJson["date_modified"] != null
        ? DateTime.parse(parsedJson["date_modified"])
        : DateTime.now();
    total =
        parsedJson["total"] != null ? double.parse(parsedJson["total"]) : 0.0;
    totalTax = parsedJson["total_tax"] != null
        ? double.parse(parsedJson["total_tax"])
        : 0.0;
    paymentMethodTitle = parsedJson["payment_method_title"];

    parsedJson["line_items"].forEach((item) {
      lineItems.add(ProductItem.fromJson(item));
    });

    billing = Address.fromJson(parsedJson["billing"]);
    shippingMethodTitle = parsedJson["shipping_lines"] != null &&
            parsedJson["shipping_lines"].length > 0
        ? parsedJson["shipping_lines"][0]["method_title"]
        : null;
  }

  Map<String, dynamic> toOrderJson(CartModel cartModel, userId) {
    var items = lineItems.map((index) {
      return index.toJson();
    }).toList();

    return {
      "status": status,
      "total": total.toString(),
      "shipping_lines": [
        {"method_title": shippingMethodTitle}
      ],
      "number": number,
      "billing": billing,
      "line_items": items,
      "id": id,
      "date_created": createdAt.toString(),
      "payment_method_title": paymentMethodTitle
    };
  }

  Map<String, dynamic> toJson(CartModel cartModel, userId, paid) {
    var lineItems = cartModel.productsInCart.keys.map((key) {
      var productId;
      if (key.contains("-")) {
        productId = int.parse(key.split("-")[0]);
      } else {
        productId = int.parse(key);
      }
      var item = {
        "product_id": productId,
        "quantity": cartModel.productsInCart[key]
      };
      if (cartModel.productVariationInCart[key] != null) {
        item["variation_id"] = cartModel.productVariationInCart[key].id;
      }
      return item;
    }).toList();

    var params = {
      "payment_method": cartModel.paymentMethod.id,
      "payment_method_title": cartModel.paymentMethod.title,
      "set_paid": paid,
      "line_items": lineItems,
      "customer_id": userId
    };
    if (paid) params["status"] = "completed";

    if (kAdvanceConfig['EnableReview'] &&
        cartModel.notes != null &&
        cartModel.notes.isNotEmpty) {
      params["customer_note"] = cartModel.notes;
    }

    if (kAdvanceConfig['EnableAddress']) {
      params["billing"] = cartModel.address.toJson();
      params["shipping"] = cartModel.address.toJson();
    }

    if (kAdvanceConfig['EnableShipping']) {
      params["shipping_lines"] = [
        {
          "method_id": cartModel.shippingMethod.methodId,
          "method_title": cartModel.shippingMethod.title,
          "total": cartModel.getShippingCost().toString()
        }
      ];
    }

    if (cartModel.couponObj != null) {
      params["coupon_lines"] = [
        {"code": cartModel.couponObj.code}
      ];
    }

    return params;
  }

  @override
  String toString() => 'Order { id: $id  number: $number}';
}

class ProductItem {
  int productId;
  String name;
  int quantity;
  String total;

  ProductItem.fromJson(Map<String, dynamic> parsedJson) {
    productId = parsedJson["product_id"];
    name = parsedJson["name"];
    quantity = parsedJson["quantity"];
    total = parsedJson["total"];
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "name": name,
      "quantity": quantity,
      "total": total
    };
  }

}
