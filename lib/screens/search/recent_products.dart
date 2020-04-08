import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/search.dart';
import '../../widgets/product/product_card_view.dart';

class Recent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return ListenableProvider.value (
      value: Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (model.products == null || model.products.isEmpty) {
          return Container();
        }
        return Container(
          width: screenSize.width,
          constraints: BoxConstraints(minHeight: 0),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Container(
              width: screenSize.width,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: screenSize.width,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        width: screenSize.width / ( 2 / (screenSize.height / screenSize.width)),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(S.of(context).recents,
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
//                FlatButton(
//                    onPressed: null,
//                    child: Text(
//                      S.of(context).seeAll,
//                      style: TextStyle(color: Colors.greenAccent, fontSize: 13),
//                    ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: kGrey200,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: screenSize.width,
                    height: screenSize.width * 0.35 + 120,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var item in model.products)
                            FittedBox(
                              child: ProductCard(item: item, width: MediaQuery.of(context).size.width * 0.35),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}