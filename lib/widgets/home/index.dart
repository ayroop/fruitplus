import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider_items.dart';
import 'category/category_icon_items.dart';
import 'category/category_image_items.dart';
import 'header/header_search.dart';
import 'header/header_text.dart';
import 'horizontal/blog_list_items.dart';
import 'horizontal/horizontal_list_items.dart';
import 'horizontal/instagram_items.dart';
import 'horizontal/simple_list.dart';
import 'horizontal/video/index.dart';
import 'logo.dart';
import 'product_list_layout.dart';
import 'vertical.dart';

class HomeLayout extends StatefulWidget {
  final configs;

  HomeLayout({this.configs, Key key}) : super(key: key);

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  /// convert the JSON to list of horizontal widgets
  Widget jsonWidget(config) {
    switch (config["layout"]) {
      case "logo":
        if (kLayoutWeb) return Container();
        return Logo(config: config);

      case 'header_text':
        if (kLayoutWeb) return Container();
        return HeaderText(config: config);

      case 'header_search':
        if (kLayoutWeb) return Container();
        return HeaderSearch(config: config);

      case "category":
        return (config['type'] == 'image') ? CategoryImages(config: config) : CategoryIcons(config: config);

      case "bannerAnimated":
        if (kLayoutWeb) return Container();
        return BannerAnimated(config: config);

      case "bannerImage":
        if (config['isSlider'] == true) return BannerSliderItems(config: config);
        return BannerGroupItems(config: config);

      case "largeCardHorizontalListItems":
        return LargeCardHorizontalListItems(config: config);

      case "simpleVerticalListItems":
        return SimpleVerticalProductList(
          config: config,
        );

      case "instagram":
        return InstagramItems(config: config);

      case "blog":
        return BlogListItems(config: config);

      case "video":
        return VideoLayout(config: config);

      default:
        return ProductListLayout(config: config);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.configs == null) return Container();
    ErrorWidget.builder = (error) {
      return Container(
        constraints: BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// *   Hide error, if you're developer, enable it to fix error it has
        child: Center(
          child: Text('Error in ${error.exceptionAsString()}'),
        ),
      );
    };

    Widget content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: <Widget>[
          for (var config in widget.configs["HorizonLayout"])
            jsonWidget(
              config,
            ),
          if (widget.configs["VerticalLayout"] != null)
            VerticalLayout(
              config: widget.configs["VerticalLayout"],
            ),
        ],
      ),
    );

    if (kIsWeb) return content;

    return RefreshIndicator(
      onRefresh: () => Future.delayed(
        Duration(milliseconds: 300),
      ),
      child: content,
    );
  }
}
