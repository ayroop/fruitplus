import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../screens/products.dart';
import '../services/index.dart';
import '../widgets/layout/layout_web.dart';
import 'app.dart';

class ProductModel with ChangeNotifier {
  Services _service = Services();
  List<List<Product>> products;
  String message;

  /// current select product id/name
  int categoryId;
  String categoryName;

  //list products for products screen
  bool isFetching = false;
  List<Product> productsList;
  String errMsg;
  bool isEnd;

  ProductVariation productVariation;
  List<Product> lstGroupedProduct;
  String cardPriceRange;
  String detailPriceRange = '';

  changeProductVariation(ProductVariation variation) {
    productVariation = variation;
    notifyListeners();
  }

  Future<List<Product>> fetchGroupedProducts({Product product}) async {
    this.lstGroupedProduct = [];
    for (int productID in product.groupedProducts) {
      await _service.getProduct(productID).then((value) {
        lstGroupedProduct.add(value);
      });
    }
    return this.lstGroupedProduct;
  }

  changeDetailPriceRange(String currency) {
    if (lstGroupedProduct.isNotEmpty) {
      double currentPrice = double.parse(lstGroupedProduct[0].price);
      double max = currentPrice;
      double min = 0;
      for (var product in lstGroupedProduct) {
        min = double.parse(product.price);
        if (min > max) {
          double temp = min;
          max = min;
          min = temp;
        }
        this.detailPriceRange = currentPrice != max
            ? '${Tools.getCurrecyFormatted(currentPrice, currency: currency)} - ${Tools.getCurrecyFormatted(max, currency: currency)}'
            : '${Tools.getCurrecyFormatted(currentPrice, currency: currency)}';
      }
    }
  }

  Future<List<Product>> fetchProductLayout(config, lang) async {
    return await _service.fetchProductsLayout(config: config, lang: lang);
  }

  void fetchProductsByCategory({categoryId, categoryName}) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    notifyListeners();
  }

  Future<void> saveProducts(Map<String, dynamic> data) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["home"], data);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> getProductsList(
      {categoryId, minPrice, maxPrice, orderBy, order, lang, page, featured, onSale, attribute, attributeTerm}) async {
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final products = await _service.fetchProductsByCategory(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        page: page,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm,
      );
      if (products.isEmpty) {
        isEnd = true;
      }

      if (page == 0 || page == 1) {
        productsList = products;
      } else {
        productsList = []..addAll(productsList)..addAll(products);
      }
      isFetching = false;
      errMsg = null;
      notifyListeners();
    } catch (err) {
      errMsg = "There is an issue with the app during request the data, please contact admin for fixing the issues " +
          err.toString();
      isFetching = false;
      notifyListeners();
    }
  }

  void setProductsList(products) {
    productsList = products;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }
}

class Product {
  int id;
  String sku;
  String name;
  String description;
  String permalink;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  double averageRating;
  int ratingCount;
  List<String> images;
  String imageFeature;
  List<ProductAttribute> attributes;
  List<ProductAttribute> infors = [];
  int categoryId;
  String videoUrl;
  List<int> groupedProducts;
  List<String> files;
  int stockQuantity;

  /// is to check the type affiliate, simple, variant
  String type;
  String affiliateUrl;
  Map<String, dynamic> multiCurrencies;

  Product.empty(int id) {
    this.id = id;
    name = 'Loading...';
    price = '0.0';
    imageFeature = '';
  }

  bool isEmptyProduct() {
    return name == 'Loading...' && price == '0.0' && imageFeature == '';
  }

  Product.fromJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["id"];
      name = parsedJson["name"];
      type = parsedJson["type"];
      description = isNotBlank(parsedJson["description"]) ? parsedJson["description"] : parsedJson["short_description"];
      permalink = parsedJson["permalink"];
      price = parsedJson["price"] != null ? parsedJson["price"].toString() : "";

      regularPrice = parsedJson["regular_price"] != null ? parsedJson["regular_price"].toString() : null;
      salePrice = parsedJson["sale_price"] != null ? parsedJson["sale_price"].toString() : null;
      onSale = parsedJson["on_sale"];
      inStock = parsedJson["in_stock"] ?? parsedJson["stock_status"] == "instock";

      averageRating = double.parse(parsedJson["average_rating"]);
      ratingCount = int.parse(parsedJson["rating_count"].toString());
      categoryId = parsedJson["categories"] != null && parsedJson["categories"].length > 0
          ? parsedJson["categories"][0]["id"]
          : 0;


      // add stock limit
      if (parsedJson['manage_stock'] == true) {
        stockQuantity = parsedJson['stock_quantity'];
      }

      List<ProductAttribute> attributeList = [];
      parsedJson["attributes"].forEach((item) {
        if (item['visible'] && item['variation']) attributeList.add(ProductAttribute.fromJson(item));
      });
      attributes = attributeList;

      parsedJson["attributes"].forEach((item) {
        infors.add(ProductAttribute.fromJson(item));
      });

      List<String> list = [];
      for (var item in parsedJson["images"]) {
        list.add(item["src"]);
      }
      images = list;
      imageFeature = images[0];

      // get video link
      var video = parsedJson['meta_data'].firstWhere(
        (item) => item['key'] == '_video_url' || item['key'] == '_woofv_video_embed',
        orElse: () => null,
      );
      if (video != null) {
        videoUrl = video['value'] is String ? video['value'] : video['value']['url'] ?? '';
      }

      affiliateUrl = parsedJson['external_url'];
      multiCurrencies = parsedJson['multi-currency-prices'];

      List<int> groupedProductList = [];
      parsedJson['grouped_products'].forEach((item) {
        groupedProductList.add(item);
      });
      groupedProducts = groupedProductList;
      List<String> files = [];
      parsedJson['downloads'].forEach((item) {
        files.add(item['file']);
      });
      this.files = files;
    } catch (e) {
      print(e);
    }
  }

  /// Show the product list
  static showList({cateId, cateName, context, List<Product> products, config, noRouting}) {
    var categoryId = cateId ?? config['category'];
    var categoryName = cateName ?? config['name'];
    final product = Provider.of<ProductModel>(context, listen: false);

    if (kLayoutWeb) {
      LayoutWebCustom.changeStateMenu(false);
    }
    // for caching current products list
    if (products != null && products.isNotEmpty) {
      product.setProductsList(products);
      return Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProductsPage(products: products, categoryId: categoryId)));
    }

    // for fetching beforehand
    if (categoryId != null) product.fetchProductsByCategory(categoryId: categoryId, categoryName: categoryName);

    product.setProductsList(List<Product>()); //clear old products
    product.getProductsList(
      categoryId: categoryId,
      page: 1,
      lang: Provider.of<AppModel>(context, listen: false).locale,
    );

    if (noRouting == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ProductsPage(products: products ?? [], categoryId: categoryId)));
    }
    else {
      return ProductsPage(products: products ?? [], categoryId: categoryId);
    }

//    if (isMagic) {
//      Navigator.push(context,
//          MaterialPageRoute(builder: (context) => MagicScreen(products, categoryId, imageBanner)));
//    } else {
//      /// if the products list is not full just go straightaway
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) => ProductsPage(products, categoryId)));
//    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "name": name,
      "description": description,
      "permalink": permalink,
      "price": price,
      "regularPrice": regularPrice,
      "salePrice": salePrice,
      "onSale": onSale,
      "inStock": inStock,
      "averageRating": averageRating,
      "ratingCount": ratingCount,
      "images": images,
      "imageFeature": imageFeature,
      "attributes": attributes,
      "categoryId": categoryId,
      "multiCurrencies": multiCurrencies
    };
  }

  Product.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      sku = json['sku'];
      name = json['name'];
      description = json['description'];
      permalink = json['permalink'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      salePrice = json['salePrice'];
      onSale = json['onSale'];
      inStock = json['inStock'];
      averageRating = json['averageRating'];
      ratingCount = json['ratingCount'];
      List<String> imgs = [];
      for (var item in json['images']) {
        imgs.add(item);
      }
      images = imgs;
      imageFeature = json['imageFeature'];
      List<ProductAttribute> attrs = [];
      for (var item in json['attributes']) {
        attrs.add(ProductAttribute.fromLocalJson(item));
      }
      attributes = attrs;
      categoryId = json['categoryId'];
      multiCurrencies = json['multiCurrencies'];
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  String toString() => 'Product { id: $id name: $name }';
}

class ProductAttribute {
  int id;
  String name;
  List options;

  ProductAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    options = parsedJson["options"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "options": options};
  }

  ProductAttribute.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      options = json['options'];
    } catch (e) {
      print(e.toString());
    }
  }
}

class Attribute {
  int id;
  String name;
  String option;

  Attribute();

  Attribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    option = parsedJson["option"];
  }

  Attribute.fromLocalJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    option = parsedJson["option"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "option": option};
  }
}

class ProductVariation {
  int id;
  String sku;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  String imageFeature;
  List<Attribute> attributes = [];
  Map<String, dynamic> multiCurrencies;

  ProductVariation();

  ProductVariation.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    price = parsedJson["price"];
    regularPrice = parsedJson["regular_price"];
    salePrice = parsedJson["sale_price"];
    onSale = parsedJson["on_sale"];
    inStock = parsedJson["in_stock"];
    imageFeature = parsedJson["image"]["src"];

    List<Attribute> attributeList = [];
    parsedJson["attributes"].forEach((item) {
      attributeList.add(Attribute.fromJson(item));
    });
    attributes = attributeList;
    multiCurrencies = parsedJson['multi-currency-prices'];
  }


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "price": price,
      "regularPrice": regularPrice,
      "sale_price": salePrice,
      "on_sale": onSale,
      "in_stock": inStock,
      "image": {"src": imageFeature},
      "attributes": attributes.map((item) {
        return item.toJson();
      }).toList()
    };
  }

  ProductVariation.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      onSale = json['onSale'];
      salePrice = json['salePrice'];
      inStock = json['inStock'];
      imageFeature = json['image']["src"];
      List<Attribute> attributeList = [];
      for (var item in json['attributes']) {
        attributeList.add(Attribute.fromLocalJson(item));
      }
      attributes = attributeList;
    } catch (e) {
      print(e.toString());
    }
  }
}

class BookingDate {
  int value;
  String unit;

  BookingDate.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
  }
}
