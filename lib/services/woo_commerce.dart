import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import "dart:core";

import '../models/filter_attribute.dart';
import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../common/config.dart';
import '../models/address.dart';
import '../models/aftership.dart';
import '../models/blog_news.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/coupon.dart';
import '../models/order.dart';
import '../models/order_note.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/shipping_method.dart';
import '../models/user.dart';
import 'helper/blognews_api.dart';
import 'helper/woocommerce_api.dart';
import 'index.dart';

class WooCommerce implements BaseServices {
  static final WooCommerce _instance = WooCommerce._internal();

  factory WooCommerce() => _instance;

  WooCommerce._internal();

  Map<String, dynamic> configCache;
  static BlogNewsApi blogApi;
  WooCommerceAPI wcApi;
  String isSecure;
  String url;
  List<Category> categories = [];
  Map<String, List<Product>> categoryCache = Map<String, List<Product>>();

  void appConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig["blog"] ?? appConfig["url"]);
    wcApi = WooCommerceAPI(appConfig["url"], appConfig["consumerKey"], appConfig["consumerSecret"]);
    isSecure = appConfig["url"].indexOf('https') != -1 ? '' : '&insecure=cool';
    url = appConfig["url"];
  }

  @override
  Future<List<BlogNews>> fetchBlogLayout({config, lang}) async {
    try {
      List<BlogNews> list = [];

      var endPoint = "posts?_embed&lang=$lang";
      if (config.containsKey("category")) {
        endPoint += "&categories=${config["category"]}";
      }
      if (config.containsKey("limit")) {
        endPoint += "&per_page=${config["limit"] ?? 20}";
      }

      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        if (BlogNews.fromJson(item) != null) {
          list.add(BlogNews.fromJson(item));
        }
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category>> getCategoriesByPage({lang, page}) async {
    try {
      String url = "products/categories?exclude=311&per_page=100&page=$page";
      if (lang != null) {
        url += "&lang=$lang";
      }
      var response = await wcApi.getAsync(url);
      if (page == 1) {
        categories = [];
      }
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          if (item['slug'] != "uncategorized" && item['count'] > 0) {
            categories.add(Category.fromJson(item));
          }
        }
        if (response.length == 100) {
          return getCategoriesByPage(lang: lang, page: page + 1);
        } else {
          return categories;
        }
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      List<Category> list = await getCategoriesByPage(lang: lang, page: 1);

      return list;
    } catch (e) {
      return categories;
      //rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      var response = await wcApi.getAsync("products");
      List<Product> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(Product.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang}) async {
    try {
      List<Product> list = [];

      if (kAdvanceConfig['isCaching'] && configCache != null) {
        var obj;
        final horizontalLayout = configCache["HorizonLayout"] as List;
        if (horizontalLayout != null) {
          obj = horizontalLayout.firstWhere(
              (o) =>
                  o["layout"] == config["layout"] &&
                  ((o["category"] != null && o["category"] == config["category"]) ||
                      (o["tag"] != null && o["tag"] == config["tag"])),
              orElse: () => null);
          if (obj != null && obj["data"].length > 0) return obj["data"];
        }

        final verticalLayout = configCache["VerticalLayout"] as List;
        if (verticalLayout != null) {
          obj = verticalLayout.firstWhere(
              (o) =>
                  o["layout"] == config["layout"] &&
                  ((o["category"] != null && o["category"] == config["category"]) ||
                      (o["tag"] != null && o["tag"] == config["tag"])),
              orElse: () => null);
          if (obj != null && obj["data"].length > 0) return obj["data"];
        }
      }

      var endPoint = "products?lang=$lang&status=publish";
      if (config.containsKey("category") && config["category"] != null) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey("tag") && config["tag"] != null) {
        endPoint += "&tag=${config["tag"]}";
      }
      if (config.containsKey("featured") && config["featured"] != null) {
        endPoint += "&featured=${config["featured"]}";
      }
      if (config.containsKey("page")) {
        endPoint += "&page=${config["page"]}";
      }
      if (config.containsKey("limit")) {
        endPoint += "&per_page=${config["limit"] ?? 100}";
      }

      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          if (!kAdvanceConfig['hideOutOfStock'] || item["in_stock"]) {
            Product product = Product.fromJson(item);
            product.categoryId = config["category"];
            list.add(product);
          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      return [];
    }
  }

  //get all attribute_term for selected attribute for filter menu
  @override
  Future<List<SubAttribute>> getSubAttributes({int id}) async {
    try {
      List<SubAttribute> list = [];
      var endPoint = 'products/attributes/$id/terms';
      print(endPoint);

      var response = await wcApi.getAsync(endPoint, version: 3);

      for (var item in response) {
        list.add(SubAttribute.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  //get all attributes for filter menu
  Future<List<FilterAttribute>> getFilterAttributes() async {
    try {
      List<FilterAttribute> list = [];
      var endPoint = 'products/attributes';
      print(endPoint);

      var response = await wcApi.getAsync(endPoint);

      for (var item in response) {
        list.add(FilterAttribute.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId, page, minPrice, maxPrice, orderBy, lang, order, attribute, attributeTerm, featured, onSale}) async {
    try {
      List<Product> list = [];
      featured ??= 0;
      onSale ??= 0;

      if ((page == 0 || page == 1) &&
          categoryCache["$categoryId"] != null &&
          categoryCache["$categoryId"].isNotEmpty &&
          (featured + onSale == 0) &&
          attributeTerm == null) {
        return categoryCache["$categoryId"];
      }

      var endPoint = "products?status=publish&lang=$lang&per_page=10&page=$page";
      if (categoryId != null) {
        endPoint += "&category=$categoryId";
      }
      if (minPrice != null) {
        endPoint += "&min_price=${(minPrice as double).toInt().toString()}";
      }
      if (maxPrice != null && maxPrice > 0) {
        endPoint += "&max_price=${(maxPrice as double).toInt().toString()}";
      }
      if (orderBy != null) {
        endPoint += "&orderby=$orderBy";
      }
      if (order != null) {
        endPoint += "&order=$order";
      }
      if (featured != null) {
        endPoint += "&featured=$featured";
      }
      if (onSale != null) {
        endPoint += "&on_sale=$onSale";
      }
      if (attribute != null && attributeTerm != null) {
        endPoint += "&attribute=$attribute&attribute_term=$attributeTerm";
      }

      print('fetchProductsByCategory: ' + endPoint);
      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          if (!kAdvanceConfig['hideOutOfStock'] || item["in_stock"]) {
            list.add(Product.fromJson(item));
          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint = "$url/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime"
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode["cookie"] == null) {
        throw Exception(jsonDecode['msg']);
      }

      return User.fromJsonFB(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      //var endPoint = "$url/wp-json/api/flutter_user/sms_login/?access_token=$token$isSecure";
      var endPoint = "$url/wp-json/api/flutter_user/firebase_sms_login?phone=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromJsonSMS(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    try {
      var endPoint =
          "$url/wp-json/api/flutter_user/apple_login?email=$email&display_name=$fullName&user_name=${email.split("@")[0]}$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromJsonSMS(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response = await wcApi.getAsync("products/$productId/reviews", version: 2);
      List<Review> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(Review.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Null> createReview({int productId, Map<String, dynamic> data}) async {
    try {
      await wcApi.postAsync("products/$productId/reviews", data, version: 2);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) async {
    try {
      var response = await wcApi.getAsync("products/${product.id}/variations?per_page=20");
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        List<ProductVariation> list = [];
        for (var item in response) {
          if (item['visible']) list.add(ProductVariation.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({Address address, String token}) async {
    try {
      List<ShippingMethod> list = [];
      var response = await wcApi.getAsync("shipping/zones");
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var zone in response) {
          final id = zone["id"];
          var response = await wcApi.getAsync("shipping/zones/$id/methods");
          if (response is Map && isNotBlank(response["message"])) {
            throw Exception(response["message"]);
          } else {
            var res = await wcApi.getAsync("shipping/zones/$id/locations");
            if (res is Map && isNotBlank(res["message"])) {
              throw Exception(res["message"]);
            } else {
              List locations = res;
              bool isValid = true;
              bool checkedPostcode = false;
              locations.forEach((o) {
                if (o["type"] == "country" && isValid) {
                  isValid = address.country == o["code"];
                }
                if (o["type"] == "postcode" && ((!checkedPostcode && isValid) || (checkedPostcode && !isValid))) {
                  isValid = address.zipCode == o["code"];
                  checkedPostcode = true;
                }
              });
              if (isValid) {
                for (var item in response) {
                  list.add(ShippingMethod.fromJson(item));
                }
              }
            }
          }
        }
      }
      return list;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods({Address address, ShippingMethod shippingMethod, String token}) async {
    try {
      var response = await wcApi.getAsync("payment_gateways");
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        List<PaymentMethod> list = [];
        for (var item in response) {
          bool isAllowed = false;
          if (item["settings"].length > 0 &&
              item["settings"]["enable_for_methods"] != null &&
              kAdvanceConfig["EnableShipping"]) {
            final allowedShipping = item["settings"]["enable_for_methods"]["value"];
            if (allowedShipping is List) {
              allowedShipping.forEach((shipping) {
                if (shipping == "${shippingMethod.methodId}:${shippingMethod.id}") {
                  isAllowed = true;
                }
              });
            } else {
              isAllowed = true;
            }
          } else {
            isAllowed = true;
          }
          if (item["enabled"] && isAllowed) {
            list.add(PaymentMethod.fromJson(item));
          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    try {
      var response = await wcApi.getAsync("orders?customer=${userModel.user.id}&per_page=20&page=$page");
      List<Order> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(Order.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<OrderNote>> getOrderNote({UserModel userModel, int orderId}) async {
    try {
      var response = await wcApi.getAsync("orders/$orderId/notes?customer=${userModel.user.id}&per_page=20");
      List<OrderNote> list = [];
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        for (var item in response) {
          list.add(OrderNote.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Order> createOrder({CartModel cartModel, UserModel user, bool paid}) async {
    try {
      final params = Order().toJson(cartModel, user.user != null ? user.user.id : null, paid);
      var response = await wcApi.postAsync("orders", params);
      if (cartModel.shippingMethod == null && kAdvanceConfig["EnableShipping"]) {
        response["shipping_lines"][0]["method_title"] = null;
      }

      print(response);
      if (response["message"] != null) {
        throw Exception(response["message"]);
      } else {
        return Order.fromJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) async {
    try {
      var response = await wcApi.putAsync("orders/$orderId", {"status": status});
      if (response["message"] != null) {
        throw Exception(response["message"]);
      } else {
//        print(response);
        return Order.fromJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts({name, page}) async {
    try {
      String endPoint = "products?status=publish&search=$name&page=$page&per_page=50";
      var response = await wcApi.getAsync(endPoint);
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        List<Product> list = [];
        for (var item in response) {
          if (!kAdvanceConfig['hideOutOfStock'] || item["in_stock"]) {
            list.add(Product.fromJson(item));
          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  /// Auth
  @override
  Future<User> getUserInfo(cookie, {password}) async {
    try {
//      print("$url/wp-json/api/flutter_user/get_currentuserinfo/?cookie=$cookie&$isSecure");

      final http.Response response =
          await http.get("$url/wp-json/api/flutter_user/get_currentuserinfo?cookie=$cookie&$isSecure");
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["user"] != null) {
        var user = body['user'];
        user['password'] = password;
        return User.fromAuthUser(user, cookie);
      } else {
        throw Exception(body["message"]);
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> json, String token) async {
    try {
      final http.Response response = await http.post("$url/wp-json/api/flutter_user/update_user_profile/?insecure=coo",
          body: convert.jsonEncode(json));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Can not updte user infor");
      }
    } catch (err) {
      rethrow;
    }
  }

  /// Create a New User
  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      String niceName = firstName + " " + lastName;
      final http.Response response = await http.post("$url/wp-json/api/flutter_user/register/?insecure=cool&$isSecure",
          body: convert.jsonEncode({
            "user_email": username,
            "user_login": username,
            "username": username,
            "user_pass": password,
            "email": username,
            "user_nicename": niceName,
            "display_name": niceName,
          }));
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["message"] == null) {
        var cookie = body['cookie'];
        return await this.getUserInfo(cookie, password: password);
      } else {
        var message = body["message"];
        throw Exception(message != null ? message : "Can not create the user.");
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  /// login
  @override
  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final http.Response response = await http.post(
          "$url/wp-json/api/flutter_user/generate_auth_cookie/?insecure=cool&$isSecure",
          body: convert.jsonEncode({"seconds": cookieLifeTime.toString(), "username": username, "password": password}));

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        return await this.getUserInfo(body['cookie'], password: password);
      } else {
        throw Exception("The username or password is incorrect.");
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  Future<Stream<Product>> streamProductsLayout({config}) async {
    try {
      var endPoint = "products?per_page=10";
      if (config.containsKey("category")) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey("tag")) {
        endPoint += "&tag=${config["tag"]}";
      }

      http.StreamedResponse response = await wcApi.getStream(endPoint);

      return response.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .expand((data) => (data as List))
          .map((data) => Product.fromJson(data));
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id) async {
    try {
      var response = await wcApi.getAsync("products/$id");
      return Product.fromJson(response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      var response = await wcApi.getAsync("coupons");
      //print(response.toString());
      return Coupons.getListCoupons(response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<AfterShip> getAllTracking() async {
    final data =
        await http.get('https://api.aftership.com/v4/trackings', headers: {'aftership-api-key': afterShip['api']});
    return AfterShip.fromJson(json.decode(data.body));
  }

  @override
  Future<User> getUserInfor({int id}) async {
    try {
      var response = await wcApi.getAsync('customers/${id.toString()}');
      if (response is Map && isNotBlank(response["message"])) {
        throw Exception(response["message"]);
      } else {
        return User.fromWoJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getHomeCache() async {
    try {
      final data = await wcApi.getAsync('flutter/cache');
      if (data['message'] != null) {
        throw Exception(data['message']);
      }
      var config = data;
      if (config['HorizonLayout'] != null) {
        var horizontalLayout = config['HorizonLayout'] as List;
        var items = [];
        var products = [];
        List<Product> list;
        for (var i = 0; i < horizontalLayout.length; i++) {
          if (horizontalLayout[i]["radius"] != null) {
            horizontalLayout[i]["radius"] = double.parse("${horizontalLayout[i]["radius"]}");
          }
          if (horizontalLayout[i]["size"] != null) {
            horizontalLayout[i]["size"] = double.parse("${horizontalLayout[i]["size"]}");
          }
          if (horizontalLayout[i]["padding"] != null) {
            horizontalLayout[i]["padding"] = double.parse("${horizontalLayout[i]["padding"]}");
          }

          products = horizontalLayout[i]["data"] as List;
          list = [];
          if (products != null && products.isNotEmpty) {
            for (var item in products) {
              Product product = Product.fromJson(item);
              product.categoryId = horizontalLayout[i]["category"];
              list.add(product);
            }
            horizontalLayout[i]["data"] = list;
          }

          items = horizontalLayout[i]["items"] as List;
          if (items != null && items.isNotEmpty) {
            for (var j = 0; j < items.length; j++) {
              if (items[j]["padding"] != null) {
                items[j]["padding"] = double.parse("${items[j]["padding"]}");
              }

              List<Product> listProduct = [];
              var prods = items[j]["data"] as List;
              if (prods != null && prods.isNotEmpty) {
                for (var prod in prods) {
                  listProduct.add(Product.fromJson(prod));
                }
                items[j]["data"] = listProduct;
              }
            }
          }
        }

        configCache = config;
        return config;
      }
      return null;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginGoogle({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint = "$url/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime"
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode["cookie"] == null) {
        throw Exception(jsonDecode['error']);
      }

      return User.fromJsonFB(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future getCategoryWithCache() async {
    List<Category> getSubCategories(id) {
      return categories.where((o) => o.parent == id).toList();
    }

    bool hasChildren(id) {
      return categories.where((o) => o.parent == id).toList().isNotEmpty;
    }

    List<Category> getParentCategory() {
      return categories.where((item) => item.parent == 0).toList();
    }

    List<int> categoryIds = [];
    List<Category> parentCategories = getParentCategory();
    for (var item in parentCategories) {
      if (hasChildren(item.id)) {
        List<Category> subCategories = getSubCategories(item.id);
        for (var item in subCategories) {
          categoryIds.add(item.id);
        }
      } else {
        categoryIds.add(item.id);
      }
    }

    return await getCategoryCache(categoryIds);
  }

  Future<Map<String, dynamic>> getCategoryCache(categoryIds) async {
    try {
      final data = await wcApi.getAsync('flutter/category/cache?categoryIds=${List<int>.from(categoryIds).join(",")}');
      if (data['message'] != null) {
        throw Exception(data['message']);
      } else {
        for (var i = 0; i < categoryIds.length; i++) {
          var productsJson = data["${categoryIds[i]}"] as List;
          List<Product> list = [];
          if (productsJson != null && productsJson.isNotEmpty) {
            for (var item in productsJson) {
              Product product = Product.fromJson(item);
              product.categoryId = categoryIds[i];
              list.add(product);
            }
          }
          categoryCache["${categoryIds[i]}"] = list;
        }
      }
      return categoryCache;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.ayrop.com/fruitplus/woocommerce-setup/
      rethrow;
    }
  }
}
