import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../models/product.dart';
import '../../widgets/product/product_card_view.dart';

class ListCard extends StatelessWidget {
  final List<Product> data;
  final int id;

  ListCard(this.data, this.id);

  @override
  Widget build(BuildContext context) {
    double width =
        kLayoutWeb ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width;

    return Container(
      height: width * 0.4 + 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        key: ObjectKey(id),
        itemBuilder: (context, index) {
          return ProductCard(item: data[index], width: width * 0.35);
        },
        itemCount: data.length,
      ),
    );
  }
}
