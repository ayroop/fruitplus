import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../common/styles.dart';
import '../common/tools.dart';
import '../common/config.dart';
import '../models/product.dart';
import '../widgets/product/product_variant.dart';
import '../models/app.dart';

class ShoppingCartRow extends StatelessWidget {
  ShoppingCartRow(
      {@required this.product,
      @required this.quantity,
      this.onRemove,
      this.onChangeQuantity,
      this.variation});

  final Product product;
  final ProductVariation variation;
  final int quantity;
  final Function onChangeQuantity;
  final VoidCallback onRemove;

  Widget showListVariation() {
    List<Widget> list = List<Widget>();
    for (var att in variation.attributes) {
      list.add(Row(
        children: <Widget>[
          ConstrainedBox(
            child:
                Text("${att.name[0].toUpperCase()}${att.name.substring(1)}: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
            constraints: BoxConstraints(minWidth: 50.0, maxWidth: 200),
          ),
          att.name == "color"
              ? Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: HexColor(
                      kColorNameToHex[att.option.toLowerCase()],
                    ),
                  ),
                )
              : Expanded(child: Text(att.option)),
          Container(
            height: 10,
          )
        ],
      ));
    }

    return Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    String currency = Provider.of<AppModel>(context).currency;
    final price = variation != null
        ? Tools.getVariantPriceProductValue(variation, currency, onSale: true)
        : Tools.getPriceProduct(product, currency, onSale: true);
    final imageFeature =
        variation != null ? variation.imageFeature : product.imageFeature;
    ThemeData theme = Theme.of(context);

    return Column(children: [
      Row(
        key: ValueKey(product.id),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: onRemove,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                        width: screenSize.width * 0.25,
                        height: screenSize.width * 0.3,
                        child: Tools.image(url: imageFeature)),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: QuantitySelection(
                          width: 60,
                          height: 32,
                          color: Colors.black,
                          value: quantity,
                          onChanged: onChangeQuantity,
                        ),
                      ),
                    )
                  ]),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Container(
                      height: screenSize.width * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: TextStyle(
                                color: theme.accentColor,
                              )),
                          SizedBox(height: 7),
                          Text(
                            price,
                            style: TextStyle(
                                color: theme.accentColor, fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          variation != null && serverConfig["type"] != "magento"
                              ? showListVariation()
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.0),
      Divider(color: kGrey200, height: 1),
      SizedBox(height: 10.0),
    ]);
  }
}
