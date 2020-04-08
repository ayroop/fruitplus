import './woo_commerce.dart';
import '../common/constants.dart';
import '../models/address.dart';
import '../models/aftership.dart';
import '../models/blog_news.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/coupon.dart';
import '../models/filter_attribute.dart';
import '../models/order.dart';
import '../models/order_note.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/shipping_method.dart';
import '../models/user.dart';

abstract class BaseServices {
  Future<List<Category>> getCategories({lang});

  Future<List<Product>> getProducts();

  Future<List<Product>> fetchProductsLayout({config, lang});

  Future<List<Product>> fetchProductsByCategory(
      {categoryId, page, minPrice, maxPrice, orderBy, lang, order, featured, onSale, attribute, attributeTerm});

  Future<User> loginFacebook({String token});

  Future<User> loginSMS({String token});

  Future<User> loginApple({String email, String fullName});

  Future<User> loginGoogle({String token});

  Future<List<Review>> getReviews(productId);

  Future<List<ProductVariation>> getProductVariations(Product product);

  Future<List<ShippingMethod>> getShippingMethods({Address address, String token});

  Future<List<PaymentMethod>> getPaymentMethods({Address address, ShippingMethod shippingMethod, String token});

  Future<Order> createOrder({CartModel cartModel, UserModel user, bool paid});

  Future<List<Order>> getMyOrders({UserModel userModel, int page});

  Future updateOrder(orderId, {status, token});

  Future<List<Product>> searchProducts({name, page});

  Future<User> getUserInfo(cookie);

  Future<User> createUser({
    firstName,
    lastName,
    username,
    password,
  });

  Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> json, String token);

  Future<User> login({username, password});

  Future<Product> getProduct(id);

  Future<Coupons> getCoupons();

  Future<AfterShip> getAllTracking();

  Future<List<OrderNote>> getOrderNote({UserModel userModel, int orderId});

  Future<Null> createReview({int productId, Map<String, dynamic> data});

  Future<User> getUserInfor({int id});

  Future<Map<String, dynamic>> getHomeCache();

  Future<List<BlogNews>> fetchBlogLayout({config, lang});

  Future getCategoryWithCache();

  Future<List<FilterAttribute>> getFilterAttributes();

  Future<List<SubAttribute>> getSubAttributes({int id});
}

class Services implements BaseServices {
  BaseServices serviceApi;

  static final Services _instance = Services._internal();

  factory Services() => _instance;

  Services._internal();

  void setAppConfig(appConfig) {
    printLog("[Services] setAppConfig: --> ${appConfig["type"]} <--");
    WooCommerce().appConfig(appConfig);
    serviceApi = WooCommerce();
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId,
      page = 1,
      minPrice,
      maxPrice,
      orderBy,
      order,
      lang,
      featured,
      onSale,
      attribute,
      attributeTerm}) async {
    return serviceApi.fetchProductsByCategory(
        categoryId: categoryId,
        page: page,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        lang: lang,
        order: order,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm);
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang = "en"}) async {
    return serviceApi.fetchProductsLayout(config: config, lang: lang);
  }

  @override
  Future<List<Category>> getCategories({lang = "en"}) async {
    return serviceApi.getCategories(lang: lang);
  }

  @override
  Future<List<Product>> getProducts() async {
    return serviceApi.getProducts();
  }

  @override
  Future<User> loginFacebook({String token}) async {
    return serviceApi.loginFacebook(token: token);
  }

  @override
  Future<User> loginSMS({String token}) async {
    return serviceApi.loginSMS(token: token);
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    return serviceApi.loginApple(email: email, fullName: fullName);
  }

  @override
  Future<User> loginGoogle({String token}) async {
    return serviceApi.loginGoogle(token: token);
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    return serviceApi.getReviews(productId);
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) async {
    return serviceApi.getProductVariations(product);
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({Address address, String token}) async {
    return serviceApi.getShippingMethods(address: address, token: token);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods({Address address, ShippingMethod shippingMethod, String token}) async {
    return serviceApi.getPaymentMethods(address: address, shippingMethod: shippingMethod, token: token);
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    return serviceApi.getMyOrders(userModel: userModel, page: page);
  }

  @override
  Future<Order> createOrder({CartModel cartModel, UserModel user, bool paid}) async {
    return serviceApi.createOrder(cartModel: cartModel, user: user, paid: paid);
  }

  @override
  Future updateOrder(orderId, {status, token}) async {
    return serviceApi.updateOrder(orderId, status: status, token: token);
  }

  @override
  Future<List<Product>> searchProducts({name, page}) async {
    return serviceApi.searchProducts(name: name, page: page);
  }

  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    return serviceApi.createUser(
      firstName: firstName,
      lastName: lastName,
      username: username,
      password: password,
    );
  }

  @override
  Future<User> getUserInfo(cookie) async {
    return serviceApi.getUserInfo(cookie);
  }

  @override
  Future<User> login({username, password}) async {
    return serviceApi.login(
      username: username,
      password: password,
    );
  }

  @override
  Future<Product> getProduct(id) async {
    return serviceApi.getProduct(id);
  }

  @override
  Future<Coupons> getCoupons() async {
    return serviceApi.getCoupons();
  }

  @override
  Future<AfterShip> getAllTracking() async {
    return serviceApi.getAllTracking();
  }

  @override
  Future<List<OrderNote>> getOrderNote({UserModel userModel, int orderId}) async {
    return serviceApi.getOrderNote(userModel: userModel, orderId: orderId);
  }

  @override
  Future<Null> createReview({int productId, Map<String, dynamic> data}) async {
    return serviceApi.createReview(productId: productId, data: data);
  }

  @override
  Future<User> getUserInfor({int id}) async {
    return serviceApi.getUserInfor(id: id);
  }

  @override
  Future<Map<String, dynamic>> getHomeCache() async {
    return serviceApi.getHomeCache();
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> json, String token) async {
    return serviceApi.updateUserInfo(json, token);
  }

  @override
  Future<List<BlogNews>> fetchBlogLayout({config, lang}) {
    return serviceApi.fetchBlogLayout(config: config, lang: lang);
  }

  @override
  Future getCategoryWithCache() {
    return serviceApi.getCategoryWithCache();
  }

  Future<List<FilterAttribute>> getFilterAttributes() {
    return serviceApi.getFilterAttributes();
  }

  @override
  Future<List<SubAttribute>> getSubAttributes({int id}) {
    return serviceApi.getSubAttributes(id: id);
  }
}
