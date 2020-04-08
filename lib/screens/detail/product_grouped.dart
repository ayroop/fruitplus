import 'package:flutter/material.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../screens/detail/product_title.dart';
import '../../services/index.dart';
import 'package:provider/provider.dart';

class GroupedProduct extends StatefulWidget {
  final Product product;

  GroupedProduct(this.product);

  @override
  _GroupedProductState createState() => _GroupedProductState();
}

class _GroupedProductState extends State<GroupedProduct> {
  final services = Services();

  List<int> productCounts = [];
  List<Product> lstGroupedProducts = [];

  void addToCart(int index, int productCount) {
    final cartModel = Provider.of<CartModel>(context, listen: false);

    cartModel.addProductToCart(
        product: lstGroupedProducts[index], quantity: productCount);
  }

  void onUpdate({int index, int productCount}) {
    productCounts[index] = productCount;
    print('${lstGroupedProducts[index].name} : ${productCounts[index]}');
  }

  Widget availableWidget() {
    return Row(
      children: <Widget>[
        Text(
          "${S.of(context).availability}: ",
          style: TextStyle(fontSize: 15, color: Theme.of(context).accentColor),
        ),
        Text(
          S.of(context).inStock,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget addToCartWidget() {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        for (int i = 0; i < lstGroupedProducts.length; i++) {
          addToCart(i, productCounts[i]);
        }
      },
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.primaryColor,
        ),
        child: Center(
          child: Text(
            S.of(context).addToCart.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

//  Widget groupedProductList() {
//    List<Widget> lstWidget = [];
//    int i = 0;
//    for (var product in Provider.of<ProductModel>(context).lstGroupedProduct) {
//      lstGroupedProducts.add(product);
//      productCounts.add(0);
//      lstWidget.add(GroupProductRow(product, i, onUpdate));
//      i++;
//    }
//    return Column(
//      crossAxisAlignment: CrossAxisAlignment.stretch,
//      children: lstWidget,
//    );
//  }

  Widget groupedProductBuilder() {
    final currency = Provider.of<AppModel>(context).currency;
    return FutureBuilder(
        future: Provider.of<ProductModel>(context)
            .fetchGroupedProducts(product: widget.product),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              Provider.of<ProductModel>(context)
                  .changeDetailPriceRange(currency);
              List<Widget> lstWidget = [];

              int i = 0;
              for (var product in snapshot.data) {
                lstGroupedProducts.add(product);
                productCounts.add(0);
                lstWidget.add(GroupProductRow(product, i, onUpdate));
                i++;
              }

              return Column(
                children: <Widget>[
                  ProductTitle(widget.product),
                  SizedBox(
                    height: 10.0,
                  ),
                  availableWidget(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    children: lstWidget,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  addToCartWidget(),
                ],
              );
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 30,
                width: 200,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                height: 30,
                width: 150,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                height: 20,
                width: 130,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(
                height: 10.0,
              ),
             Container(
                height: 20,
                width: 140,
                color: Theme.of(context).primaryColorLight,
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                height: 44,
                width: double.infinity,
                color: Theme.of(context).primaryColorLight,
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return groupedProductBuilder();
  }
}

class GroupProductRow extends StatefulWidget {
  final Product product;
  final int index;
  final Function onUpdate;

  GroupProductRow(this.product, this.index, this.onUpdate);

  @override
  _GroupProductRowState createState() => _GroupProductRowState();
}

class _GroupProductRowState extends State<GroupProductRow> {
  int productCount = 0;

  void onUpdate() {
    widget.onUpdate(index: widget.index, productCount: productCount);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    var price =
        Tools.getCurrecyFormatted(widget.product.price, currency: currency);
    return Container(
      color: Color(0xFFFF4F4F4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Color(0xFFFFFFFF),
              ),
              height: 35.0,
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      icon: Icon(
                        Icons.remove,
                        color: Colors.black,
                      ),
                      iconSize: 16.0,
                      onPressed: () {
                        setState(() {
                          if (productCount > 0) productCount--;
                          this.onUpdate();
                        });
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '$productCount',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      icon: Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      iconSize: 16.0,
                      onPressed: () {
                        setState(() {
                          productCount++;
                          this.onUpdate();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          Expanded(
            child: Text(
              '${widget.product.name}',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            '$price',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }
}
