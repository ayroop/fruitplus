import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'product.dart';
import '../models/product.dart';
import '../models/address.dart';
import '../models/shipping_method.dart';
import '../models/payment_method.dart';
import '../models/user.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../models/coupon.dart';
import '../services/index.dart';
import '../common/config.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartModel with ChangeNotifier {
  CartModel() {
    initData();
  }

  Address address;
  ShippingMethod shippingMethod;
  PaymentMethod paymentMethod;
  Coupon couponObj;
  String notes;
  String currency;

  // The IDs and product Object currently in the cart.
  Map<int, Product> _item = {};

  // The IDs and quantities of products currently in the cart.
  Map<String, int> _productsInCart = {};
  Map<String, int> get productsInCart => Map.from(_productsInCart);

  // The IDs and product variation of products currently in the cart.
  Map<String, ProductVariation> _productVariationInCart = {};
  Map<String, ProductVariation> get productVariationInCart =>
      Map.from(_productVariationInCart);

  //The IDs and product sku of products currently in the cart.
  Map<String, String> _productSkuInCart = {};
  Map<String, String> get productSkuInCart => Map.from(_productSkuInCart);

  int get totalCartQuantity => _productsInCart.values.fold(0, (v, e) => v + e);

  double getSubTotal() {
    return _productsInCart.keys.fold(0.0, (sum, key) {
      if (_productVariationInCart[key] != null &&
          _productVariationInCart[key].price != null &&
          _productVariationInCart[key].price.isNotEmpty) {
        return sum +
            double.parse(_productVariationInCart[key].price) *
                _productsInCart[key];
      } else {
        var productId;
        if (key.contains("-")) {
          productId = int.parse(key.split("-")[0]);
        } else {
          productId = int.parse(key);
        }
        String price = Tools.getPriceProductValue(_item[productId], currency,
            onSale: true);
        if (price.isNotEmpty) {
          return sum + double.parse(price) * _productsInCart[key];
        }
        return sum;
      }
    });
  }

  String getCoupon() {
    if (couponObj != null) {
      if (couponObj.discountType == "percent") {
        return "-${couponObj.amount}%";
      } else {
        return "-" +
            Tools.getCurrecyFormatted(couponObj.amount * totalCartQuantity,
                currency: currency);
      }
    } else {
      return "";
    }
  }

  double getTotal() {
    double subtotal = getSubTotal();
    if (kAdvanceConfig['EnableShipping']) {
      subtotal += getShippingCost();
    }
    if (couponObj != null) {
      if (couponObj.discountType == "percent") {
        return subtotal - subtotal * couponObj.amount / 100;
      } else {
        return subtotal - (couponObj.amount * totalCartQuantity);
      }
    } else {
      return subtotal;
    }
  }

  double getCouponCost() {
    double subtotal = getSubTotal();
    if (couponObj != null) {
      if (couponObj.discountType == "percent") {
        return subtotal * couponObj.amount / 100;
      } else {
        return couponObj.amount * totalCartQuantity;
      }
    } else {
      return 0.0;
    }
  }

  double getShippingCost() {
    if (shippingMethod != null && shippingMethod.cost > 0) {
      return shippingMethod.cost;
    }
    if (shippingMethod != null && isNotBlank(shippingMethod.classCost)) {
      List items = shippingMethod.classCost.split("*");
      String cost = items[0] != "[qty]" ? items[0] : items[1];
      double shippingCost =
          double.parse(cost) != null ? double.parse(cost) : 0.0;
      int count = 0;
      _productsInCart.keys.forEach((key) {
        count += _productsInCart[key];
      });
      return shippingCost * count;
    }
    return 0.0;
  }

  // Adds a product to the cart.
  void addProductToCart(
      {Product product,
      int quantity = 1,
      ProductVariation variation,
      isSaveLocal = true}) {
    if (isSaveLocal) {
      saveCartToLocal(
          product: product, quantity: quantity, variation: variation);
    }

    var key = "${product.id}";
    if (variation != null) {
      if (variation.id != null) {
        key += "-" + "${variation.id}";
      }
      for (var attribute in variation.attributes) {
        if (attribute.id == null) {
          key += "-" + attribute.name + attribute.option;
        }
      }
    }
    if (!_productsInCart.containsKey(key)) {
      _productsInCart[key] = quantity;
    } else {
      _productsInCart[key] += quantity;
    }
    _item[product.id] = product;
    _productVariationInCart[key] = variation;
    _productSkuInCart[key] = product.sku;

    notifyListeners();
  }

  void updateQuantity(String key, int quantity) {
    if (_productsInCart.containsKey(key)) {
      _productsInCart[key] = quantity;
      updateQuantityCartLocal(key: key, quantity: quantity);
      notifyListeners();
    }
  }

  // Removes an item from the cart.
  void removeItemFromCart(String key) {
    if (_productsInCart.containsKey(key)) {
      removeProductLocal(key);
      if (_productsInCart[key] == 1) {
        _productsInCart.remove(key);
        _productVariationInCart.remove(key);
        _productSkuInCart.remove(key);
      } else {
        _productsInCart[key]--;
      }
    }
    notifyListeners();
  }

  void setAddress(data) {
    address = data;
    saveShippingAddress(data);
  }

  Future getAddress() async {
    if (address == null) {
      await getShippingAddress();
    }
    return address;
  }

  void setShippingMethod(data) {
    shippingMethod = data;
  }

  void setPaymentMethod(data) {
    paymentMethod = data;
  }

  // Returns the Product instance matching the provided id.
  Product getProductById(int id) {
    return _item[id];
  }

  // Returns the Product instance matching the provided id.
  ProductVariation getProductVariationById(String key) {
    return _productVariationInCart[key];
  }

  // Removes everything from the cart.
  void clearCart() {
    clearCartLocal();
    _productsInCart.clear();
    _item.clear();
    _productVariationInCart.clear();
    _productSkuInCart.clear();
    shippingMethod = null;
    paymentMethod = null;
    couponObj = null;
    notes = null;
    notifyListeners();
  }

  Future<void> initData() async {
    await getShippingAddress();
    await getCartInLocal();
    await getCurrency();
  }

  Future<void> saveShippingAddress(Address address) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["shippingAddress"], address);
      }
    } catch (err) {
      print(err);
    }
  }

  Future getShippingAddress() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem(kLocalKey["shippingAddress"]);
        if (json != null) {
          address = Address.fromLocalJson(json);
          return address;
        } else {
          final userJson = storage.getItem(kLocalKey["userInfo"]);
          if (userJson != null) {
            final User user = await Services()
                .getUserInfor(id: User.fromLocalJson(userJson).id);
            address = Address(
                firstName: user.billing.firstName.isNotEmpty
                    ? user.billing.firstName
                    : user.firstName,
                lastName: user.billing.lastName.isNotEmpty
                    ? user.billing.lastName
                    : user.lastName,
                email: user.billing.email.isNotEmpty
                    ? user.billing.email
                    : user.email,
                street: user.billing.address1,
                country: isNotBlank(user.billing.country)
                    ? user.billing.country
                    : kAdvanceConfig["DefaultCountryISOCode"],
                state: user.billing.state,
                phoneNumber: user.billing.phone,
                city: user.billing.city,
                zipCode: user.billing.postCode);
            return address;
          }
        }
      }
      return null;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<void> saveCartToLocal({
    Product product,
    int quantity = 1,
    ProductVariation variation,
  }) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          items.add({
            "product": product.toJson(),
            "quantity": quantity,
            "variation": variation != null ? variation.toJson() : "null"
          });
        } else {
          items = [
            {
              "product": product.toJson(),
              "quantity": quantity,
              "variation": variation != null ? variation.toJson() : "null"
            }
          ];
        }
        await storage.setItem(kLocalKey["cart"], items);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> updateQuantityCartLocal({String key, int quantity = 1}) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        List results = [];
        if (items != null && items.isNotEmpty) {
          for (var item in items) {
            final product = Product.fromLocalJson(item["product"]);
            final ids = key.split("-");
            ProductVariation variant = item["variation"] != "null"
                ? ProductVariation.fromLocalJson(item["variation"])
                : null;
            if ((product.id == int.parse(ids[0]) && ids.length == 1) ||
                (variant != null &&
                    product.id == int.parse(ids[0]) &&
                    variant.id == int.parse(ids[1]))) {
              results.add(
                {
                  "product": product.toJson(),
                  "quantity": quantity,
                  "variation": variant
                },
              );
            } else {
              results.add(item);
            }
          }
        }
        await storage.setItem(kLocalKey["cart"], results);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> getCartInLocal() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          items.forEach((item) {
            addProductToCart(
                product: Product.fromLocalJson(item["product"]),
                quantity: item["quantity"],
                variation: item["variation"] != "null"
                    ? ProductVariation.fromLocalJson(item["variation"])
                    : null,
                isSaveLocal: false);
          });
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> clearCartLocal() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.deleteItem(kLocalKey["cart"]);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> removeProductLocal(String key) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          final ids = key.split("-");
          var item = items.firstWhere(
              (item) =>
                  Product.fromLocalJson(item["product"]).id ==
                  int.parse(ids[0]),
              orElse: () => null);
          if (item != null) {
            if (item["quantity"] == 1) {
              items.remove(item);
            } else {
              item["quantity"]--;
            }
          }
          await storage.setItem(kLocalKey["cart"], items);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  void setOrderNotes(String note) {
    notes = note;
    notifyListeners();
  }

  Future getCurrency() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString("currency") ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
  }

  void changeCurrency(value) {
    currency = value;
  }
}
