import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../generated/l10n.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/index.dart';
import '../../widgets/product/product_variant.dart';
import '../../widgets/webview.dart';

class ProductVariant extends StatefulWidget {
  final Product product;

  ProductVariant(this.product);

  @override
  StateProductVariant createState() => StateProductVariant(product);
}

class StateProductVariant extends State<ProductVariant> {
  Product product;
  ProductVariation productVariation;

  StateProductVariant(this.product);

  final services = Services();
  Map<String, String> mapAttribute = HashMap();
  List<ProductVariation> variations = [];

  int quantity = 1;

  Future<List<ProductVariation>> getProductVariantions() async {
    await services.getProductVariations(product).then((value) {
      setState(() {
        this.variations = value.toList();
      });
    });

    if (variations.isEmpty) {
      for (var attr in product.attributes) {
        setState(() {
          mapAttribute.update(attr.name, (value) => attr.options[0],
              ifAbsent: () => attr.options[0]);
        });
      }
    } else {
      await services.getProduct(product.id).then((onValue) {
        if (onValue != null) {
          setState(() {
            product = onValue;
          });
        }
      });
      for (var variant in variations) {
        if (variant.price == product.price) {
          for (var attribute in variant.attributes) {
            for (var attr in product.attributes) {
              setState(() {
                mapAttribute.update(attr.name, (value) => attr.options[0],
                    ifAbsent: () => attr.options[0]);
              });
            }
            setState(() {
              mapAttribute.update(attribute.name, (value) => attribute.option,
                  ifAbsent: () => attribute.option);
            });
          }
          break;
        }
        if (mapAttribute.isEmpty) {
          for (var attribute in product.attributes) {
            setState(() {
              mapAttribute.update(attribute.name, (value) => value,
                  ifAbsent: () {
                if (serverConfig["type"] == "magento") {
                  return attribute.options[0]["value"];
                }
                return attribute.options[0];
              });
            });
          }
        }
      }
    }
    checkVariation();
    return variations;
  }

  @override
  void initState() {
    super.initState();
    if (product.attributes.isNotEmpty) {
      getProductVariantions();
    }
  }

  void addToCart() {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final isExternal = product.type == "external" ? true : false;
    if (isExternal) {
      if (product.affiliateUrl == null || product.affiliateUrl.isEmpty) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios),
              ),
            ),
            body: Center(
              child: Text("Not found"),
            ),
          );
        }));
        return;
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebView(
                    url: product.affiliateUrl,
                    title: product.name,
                  )));
      return;
    }
    cartModel.addProductToCart(
        product: product, quantity: quantity, variation: productVariation);
  }

  bool checkLengths() {
    for (var variant in variations) {
      if (variant.attributes.length == mapAttribute.keys.toList().length) {
        bool check = true;
        for (var i = 0; i < variant.attributes.length; i++) {
          if (variant.attributes[i].option !=
              mapAttribute[variant.attributes[i].name]) {
            check = false;
            break;
          }
        }
        if (check) return true;
      }
    }
    return false;
  }

  void checkVariation() {
    if (variations != null) {
      bool checkLength = checkLengths();
      var variation = variations.firstWhere((item) {
        bool isCorrect = true;
        for (var attribute in item.attributes) {
          if (attribute.option != mapAttribute[attribute.name] &&
              (attribute.id != null || checkLength)) {
            isCorrect = false;
            break;
          }
        }
        if (isCorrect) {
          for (var key in mapAttribute.keys.toList()) {
            bool check = false;
            for (var attribute in item.attributes) {
              if (key == attribute.name) {
                check = true;
                break;
              }
            }
            if (!check) {
              Attribute att = Attribute();
              att.id = null;
              att.name = key;
              att.option = mapAttribute[key];
              item.attributes.add(att);
            }
          }
        }
        return isCorrect;
      }, orElse: () {
        return null;
      });
      if (variation == null && variations.isNotEmpty) variation = variations[0];
      if (variation != null) {
        setState(() {
          productVariation = variation;
        });
        Provider.of<ProductModel>(context, listen: false)
            .changeProductVariation(variation);
      }
    }
  }

  /// check limit select quality by maximum available stock
  int getMaxQuantity() {
    int limitSelectQuantity = kProductDetail['maxAllowQuantity'] ?? 100;
    if (product.stockQuantity != null) {
      limitSelectQuantity =
          math.min(product.stockQuantity, kProductDetail['maxAllowQuantity']);
    }
    return limitSelectQuantity;
  }

  List<Widget> getProductVariant() {
    final ThemeData theme = Theme.of(context);
    List<Widget> listWidget = List();
    final checkProductAttribute =
        product.attributes != null && product.attributes.isNotEmpty;
    bool inStock =
        productVariation != null ? productVariation.inStock : product.inStock;
    inStock = inStock ?? false;
    final isAvailable = productVariation != null
        ? (serverConfig["type"] == "magento"
            ? productVariation.sku != null
            : productVariation.id != null)
        : true;
    final isExternal = product.type == "external" ? true : false;

    if (isAvailable) {
      listWidget.add(
        SizedBox(height: 10.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            Text(
              "${S.of(context).availability}: ",
              style:
                  TextStyle(fontSize: 15, color: Theme.of(context).accentColor),
            ),
            Text(
              inStock ? S.of(context).inStock : S.of(context).outOfStock,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );

      listWidget.add(
        SizedBox(height: 10.0),
      );
    }

    listWidget.add(
      SizedBox(height: 10.0),
    );

    if (checkProductAttribute) {
      for (var attr in product.attributes) {
        if (attr.name != null && attr.name.isNotEmpty) {
          List<String> options;
          if (serverConfig["type"] == "magento") {
            options = [];
            for (var i = 0; i < attr.options.length; i++) {
              options.add(attr.options[i]["label"]);
            }
          } else {
            options = List<String>.from(attr.options);
          }

          String selectedValue =
              mapAttribute[attr.name] != null ? mapAttribute[attr.name] : "";

          listWidget.add(
            BasicSelection(
              options: options,
              title: attr.name,
              type: ProductVariantLayout[attr.name.toLowerCase()] ?? 'box',
              value: selectedValue,
              onChanged: (val) {
                if (serverConfig["type"] == "magento") {
                  setState(() {
                    //size = val;
                    mapAttribute.update(attr.name, (value) {
                      final option = attr.options.firstWhere(
                          (o) => o["label"] == val,
                          orElse: () => null);
                      if (option != null) {
                        return option["value"];
                      }
                      return val;
                    }, ifAbsent: () => val);
                  });
                } else {
                  setState(() {
                    //size = val;
                    mapAttribute.update(attr.name, (value) => val,
                        ifAbsent: () => val);
                  });
                }
                checkVariation();
              },
            ),
          );
          listWidget.add(
            SizedBox(height: 20.0),
          );
        }
      }
    }
    void cartActivity() {
      if (inStock &&
              (product.attributes.length == mapAttribute.length) &&
              (product.attributes.length == mapAttribute.length ||
                  product.type != "variable") &&
              (isAvailable) ||
          (isExternal)) {
        addToCart();
      }
    }

    listWidget.add(
      Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: cartActivity,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isExternal
                      ? true
                      : (inStock &&
                              (product.attributes.length ==
                                  mapAttribute.length) &&
                              isAvailable)
                          ? theme.primaryColor
                          : theme.disabledColor,
                ),
                child: Center(
                  child: Text(
                    ((inStock && isAvailable) || isExternal)
                        ? S.of(context).addToCart.toUpperCase()
                        : (isAvailable
                            ? S.of(context).outOfStock.toUpperCase()
                            : S.of(context).unavailable.toUpperCase()),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(color: theme.backgroundColor),
            child: QuantitySelection(
              value: quantity,
              color: theme.accentColor,
              limitSelectQuantity: getMaxQuantity(),
              onChanged: (val) {
                setState(() {
                  quantity = val;
                });
              },
            ),
          )
        ],
      ),
    );

    listWidget.add(
      SizedBox(
        height: 8.0,
      ),
    );

    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: getProductVariant(),
    );
  }
}
