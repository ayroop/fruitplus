import 'package:flutter/material.dart';
import '../services/index.dart';
import '../common/constants.dart';
import 'package:html_unescape/html_unescape.dart';

class CategoryModel with ChangeNotifier {
  Services _service = Services();
  List<Category> categories;
  Map<int, Category> categoryList = {};

  bool isLoading = false;
  String message;

  Future<void> getCategories({lang}) async {
    try {
      printLog("[Category] getCategories");
      isLoading = true;
      notifyListeners();
      categories = await _service.getCategories(lang: lang);
      isLoading = false;
      message = null;
      for (Category cat in categories) {
        categoryList[cat.id] = cat;
      }
      notifyListeners();
      await _service.getCategoryWithCache();
    } catch (err) {
      isLoading = false;
      message =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      notifyListeners();
    }
  }
}

class Category {
  int id;
  String name;
  String image;
  int parent;
  int totalProduct;

  Category.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson["slug"] == 'uncategorized') {
      return;
    }

    id = parsedJson["id"];
    name = HtmlUnescape().convert(parsedJson["name"]);
    parent = parsedJson["parent"];
    totalProduct = parsedJson["count"];

    final image = parsedJson["image"];
    if (image != null) {
      this.image = image["src"].toString();
    } else {
      this.image = kDefaultImage;
    }
  }

  @override
  String toString() => 'Category { id: $id  name: $name}';
}
