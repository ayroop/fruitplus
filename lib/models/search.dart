import 'package:flutter/material.dart';
import 'product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/index.dart';
import '../common/constants.dart';

class SearchModel extends ChangeNotifier {
  SearchModel() {
    getKeywords();
  }

  List<String> keywords = [];
  List<Product> products = [];
  bool loading = false;
  String errMsg;

  searchProducts({String name, page}) async {
    try {
      loading = true;
      notifyListeners();
      products = await Services().searchProducts(name: name, page: page);
      if (products.isNotEmpty && page == 1 && name.isNotEmpty) {
        int index = keywords.indexOf(name);
        if (index > -1) {
          keywords.removeAt(index);
        }
        keywords.insert(0, name);
        await saveKeywords(keywords);
      }
      loading = false;
      errMsg = null;
      notifyListeners();

      return products;
    } catch (err) {
      loading = false;
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      notifyListeners();
    }
  }

  void clearKeywords() {
    keywords = [];
    saveKeywords(keywords);
    notifyListeners();
  }

  Future<void> saveKeywords(List<String> keywords) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kLocalKey["recentSearches"], keywords);
    } catch (err) {
      print(err);
    }
  }

  Future<void> getKeywords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(kLocalKey["recentSearches"]);
      if (list != null && list.isNotEmpty) {
        keywords = list;
      }
    } catch (err) {
      print(err);
    }
  }
}
