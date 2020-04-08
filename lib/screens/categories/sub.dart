import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../widgets/product/product_list.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/app.dart';

class SubCategories extends StatefulWidget {
  final List<Category> categories;
  SubCategories(this.categories);

  @override
  State<StatefulWidget> createState() {
    return SubCategoriesState();
  }
}

class SubCategoriesState extends State<SubCategories> {
  int selectedIndex = 0;
  Services _service = Services();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: Text(widget.categories[index].name,
                        style: TextStyle(
                            fontSize: 18,
                            color: selectedIndex == index
                                ? theme.primaryColor
                                : theme.hintColor)),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FutureBuilder<List<Product>>(
                future: _service.fetchProductsByCategory(
                    lang: Provider.of<AppModel>(context).locale,
                    categoryId: widget.categories[selectedIndex].id),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Product>> snapshot) {
                  return ProductList(
                      width: constraints.maxWidth,
//                  isLoading: snapshot.connectionState == ConnectionState.none ||
//                      snapshot.connectionState == ConnectionState.active ||
//                      snapshot.connectionState == ConnectionState.waiting,
//                  errorMsg: snapshot.hasError ? snapshot.error : null,
                      products: snapshot.data);
                },
              );
            },
          ),
        )
      ],
    );
  }
}
