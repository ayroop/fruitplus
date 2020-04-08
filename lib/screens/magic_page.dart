import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product/product_list.dart';

class MagicScreen extends StatefulWidget {
  final List<Product> products;
  final int categoryId;
  final String imageBanner;

  MagicScreen([this.products, this.categoryId, this.imageBanner]);

  @override
  State<StatefulWidget> createState() {
    return MagicScreenState();
  }
}

class MagicScreenState extends State<MagicScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bannerHigh = screenSize.height * 0.3;

    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 22,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Color(0xFF0084C9),
              expandedHeight: bannerHigh,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: "magic-${widget.categoryId}",
                  child: Image.network(widget.imageBanner, fit: BoxFit.cover),
                ),
              ),
            ),
          ];
        },
        body:
            Material(child: ProductList(products: widget.products)));
  }
}
